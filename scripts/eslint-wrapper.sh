#!/usr/bin/env bash
# Wrapper eslint_d qui trouve automatiquement la config eslint
# Usage: eslint-wrapper --stdin-filename <path>

FILENAME=""
for arg in "$@"; do
  case "$arg" in
    --stdin-filename=*)
      FILENAME="${arg#--stdin-filename=}"
      ;;
  esac
done

# Si pas de filename, utiliser le dernier argument
if [ -z "$FILENAME" ]; then
  for arg in "$@"; do
    case "$arg" in
      --stdin-filename)
        shift_next=1
        ;;
      *)
        if [ "$shift_next" = "1" ]; then
          FILENAME="$arg"
          shift_next=0
        fi
        ;;
    esac
  done
fi

# Convertir en chemin absolu
if [ -n "$FILENAME" ] && [ "${FILENAME:0:1}" != "/" ]; then
  FILENAME="$(pwd)/$FILENAME"
fi

# Chercher la config eslint en remontant l'arborescence
find_eslint_root() {
  local dir="$1"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/eslint.config.js" ] || \
       [ -f "$dir/eslint.config.mjs" ] || \
       [ -f "$dir/eslint.config.cjs" ] || \
       [ -f "$dir/.eslintrc.js" ] || \
       [ -f "$dir/.eslintrc.cjs" ] || \
       [ -f "$dir/.eslintrc.json" ] || \
       [ -f "$dir/.eslintrc.yml" ] || \
       [ -f "$dir/.eslintrc.yaml" ] || \
       [ -f "$dir/.eslintrc" ]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

# Trouver le répertoire racine eslint
if [ -n "$FILENAME" ]; then
  ESLINT_ROOT=$(find_eslint_root "$(dirname "$FILENAME")")
fi

# Si trouvé, changer de répertoire et exécuter
if [ -n "$ESLINT_ROOT" ]; then
  cd "$ESLINT_ROOT"
fi

exec eslint_d --fix-to-stdout --stdin "$@"
