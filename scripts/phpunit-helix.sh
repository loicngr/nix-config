#!/usr/bin/env bash
set -e

ACTION="$1"
FILE="$2"
LINE="$3"

# Convertir en chemin absolu
if [[ "$FILE" != /* ]]; then
  FILE="$(pwd)/$FILE"
fi

# Détection du projet
if [[ "$FILE" == *"/back/"* ]]; then
  WORKSPACE_ROOT="${FILE%%/back/*}"
  PROJECT_ROOT="$WORKSPACE_ROOT/back"
  RELATIVE_FILE="${FILE#*back/}"
else
  WORKSPACE_ROOT="$(pwd)"
  PROJECT_ROOT="$WORKSPACE_ROOT"
  RELATIVE_FILE="$FILE"
fi

# Charger .env
[ -f "$WORKSPACE_ROOT/.env" ] && { set -a; source "$WORKSPACE_ROOT/.env"; set +a; }

PHPUNIT="./vendor/phpunit/phpunit/phpunit"
CONFIG="phpunit.xml.dist"

cd "$PROJECT_ROOT"

[ ! -f "$PHPUNIT" ] && echo "PHPUnit non trouvé" && exit 1

case "$ACTION" in
  method)
    METHOD=$(head -n "$LINE" "$FILE" | tac | grep -m1 -oP 'function\s+\Ktest\w+' || echo "")

    if [ -z "$METHOD" ]; then
      echo "Aucune méthode test trouvée"
      exit 1
    fi

    echo "▶ Test: $METHOD"
    echo "▶ File: $RELATIVE_FILE"
    echo "▶ Command: $PHPUNIT --configuration $CONFIG $RELATIVE_FILE --filter $METHOD"
    echo ""
    exec php -d memory_limit=1G $PHPUNIT --configuration $CONFIG "$RELATIVE_FILE" --filter "$METHOD"
    ;;

  file)
    echo "▶ File: $RELATIVE_FILE"
    echo ""
    exec php -d memory_limit=1G $PHPUNIT --configuration $CONFIG "$RELATIVE_FILE"
    ;;
esac
