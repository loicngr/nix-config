#!/usr/bin/env bash
# Wrapper pour Psalm — auto-détecte psalm.xml et le binaire vendored.
#
# Cherche psalm.xml en remontant depuis $PWD, puis dans les sous-dossiers
# immédiats (layout monorepo type sekur/back/psalm.xml ouvert depuis sekur/).
# Si trouvé, cd dans son dossier et utilise vendor/bin/psalm ou
# tools/psalm/vendor/bin/psalm s'ils existent. Sinon, fallback sur `psalm` du PATH.
#
# Conçu pour être passé à Zed via `lsp.psalm.binary.path = "psalm-wrapper"`.

set -u

find_psalm_xml() {
    local dir="$PWD"
    while [ -n "$dir" ] && [ "$dir" != "/" ]; do
        for candidate in psalm.xml psalm.xml.dist; do
            if [ -f "$dir/$candidate" ]; then
                printf '%s\n' "$dir/$candidate"
                return 0
            fi
        done
        dir=$(dirname "$dir")
    done
    local match
    match=$(find "$PWD" -mindepth 2 -maxdepth 2 \( -name psalm.xml -o -name psalm.xml.dist \) -print -quit 2>/dev/null)
    if [ -n "$match" ]; then
        printf '%s\n' "$match"
        return 0
    fi
    return 1
}

PSALM_XML=$(find_psalm_xml || true)
PSALM_BIN="psalm"

if [ -n "$PSALM_XML" ]; then
    cd "$(dirname "$PSALM_XML")"
    for candidate in tools/psalm/vendor/bin/psalm vendor/bin/psalm; do
        if [ -x "$candidate" ]; then
            PSALM_BIN="$PWD/$candidate"
            break
        fi
    done
fi

exec "$PSALM_BIN" "$@"
