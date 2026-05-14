#!/usr/bin/env bash
set -euo pipefail

# Usage: claude-commit [--commit]
#   Par défaut : génère le message et l'écrit dans .git/MERGE_MSG (pour lazygit)
#   --commit   : génère, ouvre l'ide pour éditer, puis commit directement

MODE="prefill"
if [ "${1:-}" = "--commit" ]; then
    MODE="commit"
fi

PROMPT_FILE="$HOME/.config/lazygit/commit-prompt.md"
TMPFILE=$(mktemp --suffix=.txt)
CLAUDE_ERR=$(mktemp)
CLAUDE_OUT=$(mktemp)

cleanup() { rm -f "$TMPFILE" "$CLAUDE_ERR" "$CLAUDE_OUT"; return 0; }
trap cleanup EXIT

# Vérifier que le fichier prompt existe
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Erreur: Fichier prompt introuvable: $PROMPT_FILE"
    exit 1
fi

# Gérer le detached HEAD
BRANCH=$(git branch --show-current)
if [ -z "$BRANCH" ]; then
    BRANCH=$(git rev-parse --short HEAD)
fi

DIFF=$(git diff --staged)

if [ -z "$DIFF" ]; then
    echo "Aucun changement staged pour le commit."
    exit 1
fi

echo "Génération du message de commit avec Claude..."

PROMPT="$(cat "$PROMPT_FILE")

Branche actuelle: $BRANCH

Voici les changements staged:
$DIFF"

echo "Modèle: haiku (prompt: ${#PROMPT} caractères)"

timeout 120 claude -p "$PROMPT" --model haiku > "$CLAUDE_OUT" 2>"$CLAUDE_ERR" &
CLAUDE_PID=$!

START=$SECONDS
while kill -0 "$CLAUDE_PID" 2>/dev/null; do
    ELAPSED=$((SECONDS - START))
    printf "\r  %ds..." "$ELAPSED"
    sleep 1
done

wait "$CLAUDE_PID"
CLAUDE_EXIT=$?
printf "\r  %ds\n" $((SECONDS - START))

if [ "$CLAUDE_EXIT" -eq 124 ]; then
    echo "Erreur: Claude a dépassé le délai de 120 secondes."
    exit 1
fi

MSG=$(cat "$CLAUDE_OUT")

if [ -z "$MSG" ]; then
    echo "Erreur: Claude n'a pas pu générer de message."
    if [ -s "$CLAUDE_ERR" ]; then
        echo "Détails:"
        cat "$CLAUDE_ERR"
    fi
    exit 1
fi

# Nettoyage des artefacts markdown résiduels
MSG=$(echo "$MSG" | sed '/^```/d' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ "$MODE" = "prefill" ]; then
    GIT_DIR=$(git rev-parse --git-dir)
    echo "$MSG" > "$GIT_DIR/LAZYGIT_PENDING_COMMIT"
    echo "Message généré. Appuie sur 'c' pour valider le commit."
else
    # Mode --commit : ouvre l'ide puis commit directement
    echo "$MSG" > "$TMPFILE"
    MTIME_BEFORE=$(stat -c %Y.%N "$TMPFILE")
    micro "$TMPFILE"
    MTIME_AFTER=$(stat -c %Y.%N "$TMPFILE")

    if [ "$MTIME_BEFORE" = "$MTIME_AFTER" ]; then
        echo "Commit annulé."
        exit 1
    fi

    git commit -F "$TMPFILE"
fi
