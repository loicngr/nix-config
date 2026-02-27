#!/usr/bin/env bash
set -euo pipefail

BRANCH="${1:-}"

if [ -z "$BRANCH" ]; then
    echo "Usage: claude-merge <branch>"
    exit 1
fi

# Résolution de la branche (locale, remote tracking, ou avec préfixe origin/)
resolve_branch() {
    local ref="$1"
    git show-ref --quiet "refs/heads/$ref" ||
    git show-ref --quiet "refs/remotes/$ref" ||
    git show-ref --quiet "refs/remotes/origin/$ref"
}

if ! resolve_branch "$BRANCH"; then
    echo "Branche '$BRANCH' non trouvée localement, tentative de fetch..."
    git fetch --all --quiet 2>/dev/null || true
fi

if resolve_branch "$BRANCH"; then
    : # Branche trouvée telle quelle
elif git show-ref --quiet "refs/remotes/origin/$BRANCH"; then
    echo "Branche trouvée en tant que 'origin/$BRANCH'."
    BRANCH="origin/$BRANCH"
else
    echo "Erreur: La branche '$BRANCH' n'existe pas."
    echo "Refs cherchées:"
    echo "  - refs/heads/$BRANCH"
    echo "  - refs/remotes/$BRANCH"
    echo "  - refs/remotes/origin/$BRANCH"
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)

# Trap pour nettoyer en cas d'interruption (Ctrl+C, erreur, etc.)
MERGE_IN_PROGRESS=false
CLAUDE_ERR=""
tmpfile=""

cleanup() {
    if [ "$MERGE_IN_PROGRESS" = true ]; then
        echo ""
        echo "Interruption détectée, annulation du merge..."
        git merge --abort 2>/dev/null || true
    fi
    [ -n "${CLAUDE_ERR:-}" ] && [ -f "$CLAUDE_ERR" ] && rm -f "$CLAUDE_ERR"
    [ -n "${tmpfile:-}" ] && [ -f "$tmpfile" ] && rm -f "$tmpfile"
    return 0
}
trap cleanup EXIT INT TERM

echo "Merge de '$BRANCH' dans '$CURRENT_BRANCH' (--no-ff --no-commit)..."

MERGE_OUTPUT=$(git merge --no-ff --no-commit "$BRANCH" 2>&1) || true
MERGE_IN_PROGRESS=true

# Vérifier s'il y a des conflits (indépendamment du code de sortie de git merge)
CONFLICTS=()
while IFS= read -r file; do
    CONFLICTS+=("$file")
done < <(git diff --name-only --diff-filter=U)

if [ ${#CONFLICTS[@]} -eq 0 ]; then
    # Pas de conflits — vérifier si le merge a bien eu lieu
    if [ -f "$(git rev-parse --git-dir)/MERGE_HEAD" ]; then
        echo "Merge réussi sans conflits."
        echo "Les changements sont staged, prêts à être commités."
        MERGE_IN_PROGRESS=false
        exit 0
    else
        echo "Merge échoué:"
        echo "$MERGE_OUTPUT"
        MERGE_IN_PROGRESS=false
        exit 1
    fi
fi

echo ""
echo "Conflits détectés dans:"
printf '  %s\n' "${CONFLICTS[@]}"
echo ""

# --- Collecte du contexte des deux branches ---
echo "Collecte du contexte..."

# Limite à 30 commits par branche pour garder le prompt à une taille raisonnable
echo "  Commits de la branche source '$BRANCH'..."
echo "    > git log --format='- %h %s' $CURRENT_BRANCH..$BRANCH | head -30"
SOURCE_LOG=$(git log --format="- %h %s" "$CURRENT_BRANCH".."$BRANCH" 2>/dev/null | head -30) || SOURCE_LOG=""
if [ -n "$SOURCE_LOG" ]; then
    SOURCE_COUNT=$(echo "$SOURCE_LOG" | wc -l)
    echo "    $SOURCE_COUNT commit(s) trouvé(s)"
else
    echo "    Aucun commit trouvé"
fi

echo "  Commits de la branche cible '$CURRENT_BRANCH'..."
echo "    > git log --format='- %h %s' $BRANCH..$CURRENT_BRANCH | head -30"
TARGET_LOG=$(git log --format="- %h %s" "$BRANCH".."$CURRENT_BRANCH" 2>/dev/null | head -30) || TARGET_LOG=""
if [ -n "$TARGET_LOG" ]; then
    TARGET_COUNT=$(echo "$TARGET_LOG" | wc -l)
    echo "    $TARGET_COUNT commit(s) trouvé(s)"
else
    echo "    Aucun commit trouvé"
fi

echo "  PR de la branche source '${BRANCH#origin/}'..."
echo "    > gh pr list --head ${BRANCH#origin/} --json title,body --limit 1"
SRC_PR_JSON=$(gh pr list --head "${BRANCH#origin/}" --json title,body --limit 1 2>/dev/null) || SRC_PR_JSON="[]"
SRC_PR_TITLE=$(echo "$SRC_PR_JSON" | jq -r '.[0].title // empty' 2>/dev/null) || SRC_PR_TITLE=""
SRC_PR_BODY=$(echo "$SRC_PR_JSON" | jq -r '.[0].body // empty' 2>/dev/null) || SRC_PR_BODY=""
if [ -n "$SRC_PR_TITLE" ]; then
    echo "    PR trouvée: $SRC_PR_TITLE"
else
    echo "    Aucune PR trouvée"
fi

echo "  PR de la branche cible '$CURRENT_BRANCH'..."
echo "    > gh pr list --head $CURRENT_BRANCH --json title,body --limit 1"
TGT_PR_JSON=$(gh pr list --head "$CURRENT_BRANCH" --json title,body --limit 1 2>/dev/null) || TGT_PR_JSON="[]"
TGT_PR_TITLE=$(echo "$TGT_PR_JSON" | jq -r '.[0].title // empty' 2>/dev/null) || TGT_PR_TITLE=""
TGT_PR_BODY=$(echo "$TGT_PR_JSON" | jq -r '.[0].body // empty' 2>/dev/null) || TGT_PR_BODY=""
if [ -n "$TGT_PR_TITLE" ]; then
    echo "    PR trouvée: $TGT_PR_TITLE"
else
    echo "    Aucune PR trouvée"
fi

CONTEXT="## Contexte du merge

Branche source (ce qui arrive): $BRANCH
Branche cible (où on merge): $CURRENT_BRANCH

### Commits de la branche source '$BRANCH':
${SOURCE_LOG:-Aucun commit trouvé}

### Commits de la branche cible '$CURRENT_BRANCH':
${TARGET_LOG:-Aucun commit trouvé}"

if [ -n "$SRC_PR_TITLE" ]; then
    CONTEXT="$CONTEXT

### PR de la branche source:
**Titre:** $SRC_PR_TITLE
**Description:** ${SRC_PR_BODY:-Aucune description}"
fi

if [ -n "$TGT_PR_TITLE" ]; then
    CONTEXT="$CONTEXT

### PR de la branche cible:
**Titre:** $TGT_PR_TITLE
**Description:** ${TGT_PR_BODY:-Aucune description}"
fi

echo "Contexte collecté."

# --- Collecte des fichiers en conflit ---
FILES_CONTENT=""
for FILE in "${CONFLICTS[@]}"; do
    FILES_CONTENT="$FILES_CONTENT
===FILE:$FILE===
$(cat "$FILE")
===END_FILE==="
done

# --- Fonction d'appel Claude avec spinner et logs ---
# Usage: call_claude LABEL PROMPT_CONTENT
# Résultat dans la variable globale RESPONSE
call_claude() {
    local label="$1"
    local prompt_content="$2"
    local prompt_size=${#prompt_content}
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

    # Seuil ~150k caractères (~50k tokens) → bascule vers sonnet[1m]
    local model="sonnet"
    if [ "$prompt_size" -gt 150000 ]; then
        model="sonnet[1m]"
    fi

    echo ""
    echo "[$label] Envoi à Claude ($model)..."
    echo "  Taille du prompt: $prompt_size caractères"
    if [ "$prompt_size" -gt 500000 ]; then
        echo "  Avertissement: prompt très volumineux, la résolution pourrait échouer."
    fi

    local resp_file
    resp_file=$(mktemp)
    CLAUDE_ERR=$(mktemp)

    echo "  > timeout 600 claude -p ... --model $model"
    timeout 600 claude -p "$prompt_content" --model "$model" > "$resp_file" 2>"$CLAUDE_ERR" &
    local claude_pid=$!

    local start_time=$SECONDS
    local i=0
    while kill -0 "$claude_pid" 2>/dev/null; do
        local elapsed=$(( SECONDS - start_time ))
        printf "\r  ${spin[$i]} En attente de Claude... %ds" "$elapsed"
        i=$(( (i + 1) % ${#spin[@]} ))
        sleep 0.1
    done
    wait "$claude_pid" || true
    local elapsed=$(( SECONDS - start_time ))

    RESPONSE=$(cat "$resp_file")
    rm -f "$resp_file"

    if [ -z "$RESPONSE" ]; then
        printf "\r  Erreur après %ds.                          \n" "$elapsed"
        if [ -s "$CLAUDE_ERR" ]; then
            echo "  Détails:"
            cat "$CLAUDE_ERR"
        fi
        rm -f "$CLAUDE_ERR"
        return 1
    fi

    rm -f "$CLAUDE_ERR"
    local resp_size=${#RESPONSE}
    local mode
    mode=$(echo "$RESPONSE" | head -1 | tr -d '[:space:]')
    printf "\r  Réponse reçue en %ds (%d caractères, mode: %s)\n" "$elapsed" "$resp_size" "$mode"
    return 0
}

# --- Passe 1: Résolution ou questions ---
PROMPT="Tu es un expert en résolution de conflits Git.

$CONTEXT

### Fichiers en conflit:
$FILES_CONTENT

### Instructions:

Analyse le contexte (commits, PR) pour comprendre l'intention des changements de chaque côté.
Résous les conflits de manière intelligente en te basant sur ce contexte.

Si tu peux résoudre tous les conflits avec confiance, réponds avec le format suivant:
- Première ligne: MODE:RESOLVE
- Pour chaque fichier, utilise exactement ce format:
===FILE:chemin/du/fichier===
(contenu résolu complet du fichier)
===END_FILE===

Si tu as besoin de clarifications pour résoudre correctement certains conflits, réponds avec:
- Première ligne: MODE:QUESTIONS
- Liste tes questions numérotées (1., 2., etc.)

IMPORTANT: Pas de backticks, pas de markdown autour du contenu des fichiers. Le contenu entre les marqueurs ===FILE=== et ===END_FILE=== doit être le contenu EXACT du fichier résolu, prêt à écrire sur disque."

if ! call_claude "Passe 1 - Analyse" "$PROMPT"; then
    echo "Erreur: Claude n'a pas pu analyser les conflits."
    exit 1
fi

MODE=$(echo "$RESPONSE" | head -1 | tr -d '[:space:]')

if [ "$MODE" = "MODE:QUESTIONS" ]; then
    QUESTIONS=$(echo "$RESPONSE" | tail -n +2)

    echo ""
    echo "Claude a des questions avant de résoudre les conflits:"
    echo "======================================================"
    echo "$QUESTIONS"
    echo "======================================================"
    echo ""
    read -p "Voulez-vous répondre aux questions ? [y/n] : " -n 1 -r < /dev/tty
    echo ""

    ANSWERS=""
    if [[ "$REPLY" =~ ^[yY]$ ]]; then
        while IFS= read -r line; do
            if [[ "$line" =~ ^[0-9]+\. ]]; then
                echo ""
                echo "$line"
                read -rp "Réponse: " answer < /dev/tty
                ANSWERS="$ANSWERS
$line
Réponse: $answer"
            fi
        done <<< "$QUESTIONS"
    fi

    PROMPT2="Tu es un expert en résolution de conflits Git.

$CONTEXT

### Fichiers en conflit:
$FILES_CONTENT

### Questions et réponses:
${ANSWERS:-L'utilisateur n'a pas souhaité répondre aux questions. Résous au mieux avec le contexte disponible.}

### Instructions:
Résous maintenant tous les conflits. Utilise exactement ce format:
- Première ligne: MODE:RESOLVE
- Pour chaque fichier:
===FILE:chemin/du/fichier===
(contenu résolu complet du fichier)
===END_FILE===

IMPORTANT: Pas de backticks, pas de markdown autour du contenu des fichiers. Le contenu entre les marqueurs doit être le contenu EXACT du fichier résolu."

    if ! call_claude "Passe 2 - Résolution" "$PROMPT2"; then
        echo "Erreur: Claude n'a pas pu résoudre les conflits."
        exit 1
    fi
fi

# --- Vérification du mode de la réponse finale ---
FINAL_MODE=$(echo "$RESPONSE" | head -1 | tr -d '[:space:]')

if [ "$FINAL_MODE" != "MODE:RESOLVE" ]; then
    echo "Erreur: Claude n'a pas renvoyé une résolution valide (reçu: $FINAL_MODE)."
    echo "Résolution manuelle requise."
    exit 1
fi

# --- Extraction des fichiers résolus dans des fichiers temporaires ---
echo ""
echo "Extraction des résolutions..."

CONTENT=$(echo "$RESPONSE" | tail -n +2)

current_file=""
tmpfile=""
RESOLVED_FILES=()

while IFS= read -r line; do
    if [[ "$line" =~ ^===FILE:(.+)===$ ]]; then
        current_file="${BASH_REMATCH[1]}"

        # Vérifier que le fichier fait partie des conflits connus
        file_valid=false
        for conflict in "${CONFLICTS[@]}"; do
            if [ "$conflict" = "$current_file" ]; then
                file_valid=true
                break
            fi
        done

        if [ "$file_valid" = true ]; then
            tmpfile=$(mktemp)
        else
            echo "⚠ Chemin ignoré (pas dans la liste des conflits): $current_file"
            current_file=""
            tmpfile=""
        fi
    elif [[ "$line" == "===END_FILE===" ]]; then
        if [ -n "$current_file" ] && [ -n "$tmpfile" ] && [ -f "$tmpfile" ]; then
            RESOLVED_FILES+=("$current_file:$tmpfile")
            echo "  $current_file"
        fi
        current_file=""
        tmpfile=""
    elif [ -n "$current_file" ] && [ -n "$tmpfile" ]; then
        printf '%s\n' "$line" >> "$tmpfile"
    fi
done <<< "$CONTENT"

# Nettoyage en cas de fichier temporaire orphelin
[ -n "${tmpfile:-}" ] && [ -f "$tmpfile" ] && rm -f "$tmpfile"

if [ ${#RESOLVED_FILES[@]} -eq 0 ]; then
    echo "Erreur: Aucun fichier résolu extrait de la réponse de Claude."
    exit 1
fi

# --- Confirmation avant d'appliquer ---
echo ""
echo "${#RESOLVED_FILES[@]} fichier(s) résolu(s). Appliquer les résolutions ? [y/n]"
read -n 1 -r < /dev/tty
echo ""

if [[ ! "$REPLY" =~ ^[yY]$ ]]; then
    echo "Résolutions annulées."
    # Nettoyage des fichiers temporaires
    for entry in "${RESOLVED_FILES[@]}"; do
        resolved_tmp="${entry#*:}"
        rm -f "$resolved_tmp"
    done
    exit 1
fi

# --- Application des résolutions ---
echo "Application des résolutions..."

for entry in "${RESOLVED_FILES[@]}"; do
    resolved_file="${entry%%:*}"
    resolved_tmp="${entry#*:}"
    if [ -f "$resolved_tmp" ]; then
        cp "$resolved_tmp" "$resolved_file"
        rm -f "$resolved_tmp"
        echo "✓ $resolved_file résolu"
    fi
done

# Git add uniquement les fichiers effectivement résolus
for entry in "${RESOLVED_FILES[@]}"; do
    resolved_file="${entry%%:*}"
    if [ -f "$resolved_file" ]; then
        git add "$resolved_file"
    fi
done

# Vérification finale
REMAINING=$(git diff --name-only --diff-filter=U 2>/dev/null)

if [ -z "$REMAINING" ]; then
    MERGE_IN_PROGRESS=false
    echo ""
    echo "Tous les conflits ont été résolus et stagés."
    echo "Prêt à commiter."
else
    echo ""
    echo "Conflits restants:"
    echo "$REMAINING"
    exit 1
fi
