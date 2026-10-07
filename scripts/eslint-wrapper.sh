#!/usr/bin/env bash

FILENAME=""
for arg in "$@"; do
  case "$arg" in
    --stdin-filename=*)
      FILENAME="${arg#--stdin-filename=}"
      ;;
  esac
done

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

if [ -n "$FILENAME" ] && [ "${FILENAME:0:1}" != "/" ]; then
  FILENAME="$(pwd)/$FILENAME"
fi

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

if [ -n "$FILENAME" ]; then
  ESLINT_ROOT=$(find_eslint_root "$(dirname "$FILENAME")")
fi

if [ -n "$ESLINT_ROOT" ]; then
  cd "$ESLINT_ROOT"
fi

exec eslint_d --fix-to-stdout --stdin "$@"
