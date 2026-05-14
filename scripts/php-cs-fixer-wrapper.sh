#!/usr/bin/env bash
# Format PHP via php-cs-fixer for use as Zed external formatter.
#
# Usage: php-cs-fixer-wrapper [--stdin-filepath PATH] < input > output
#
# Walks up from --stdin-filepath (or PWD) looking for cs-fixer config in:
#   tools/cs-fixer/cs-fixer-config.php, .php-cs-fixer.php, .php-cs-fixer.dist.php
# Uses the vendored binary next to the config when available, else php-cs-fixer in PATH.

set -u

START_DIR="$PWD"

while [ $# -gt 0 ]; do
    case "$1" in
        --stdin-filepath)
            if [ -n "${2:-}" ]; then
                START_DIR=$(dirname "$2")
                shift
            fi
            ;;
    esac
    shift
done

find_config() {
    local dir="$1"
    while [ -n "$dir" ] && [ "$dir" != "/" ]; do
        for candidate in \
            "$dir/tools/cs-fixer/cs-fixer-config.php" \
            "$dir/.php-cs-fixer.php" \
            "$dir/.php-cs-fixer.dist.php"; do
            if [ -f "$candidate" ]; then
                printf '%s\n' "$candidate"
                return 0
            fi
        done
        dir=$(dirname "$dir")
    done
    return 1
}

CONFIG_PATH=$(find_config "$START_DIR" || true)
CONFIG_ARG=()
PHP_CS_FIXER_BIN="php-cs-fixer"

if [ -n "$CONFIG_PATH" ]; then
    CONFIG_ARG=("--config=$CONFIG_PATH")
    config_dir=$(dirname "$CONFIG_PATH")
    if [ -x "$config_dir/vendor/bin/php-cs-fixer" ]; then
        PHP_CS_FIXER_BIN="$config_dir/vendor/bin/php-cs-fixer"
    fi
fi

TMPFILE=$(mktemp /tmp/php-cs-fixer.XXXXXX.php)
cleanup() {
    rm -f "$TMPFILE"
    return 0
}
trap cleanup EXIT

cat > "$TMPFILE"
"$PHP_CS_FIXER_BIN" fix "${CONFIG_ARG[@]}" --quiet --no-interaction "$TMPFILE" 2>/dev/null || true
cat "$TMPFILE"
