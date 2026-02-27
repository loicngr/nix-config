#!/bin/sh

# Sync NixOS configuration files from /etc/nixos/ to current directory
# Usage: ./copy-from-nixos.sh

SOURCE_DIR="/etc/nixos"
DEST_DIR="$(pwd)"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: $SOURCE_DIR does not exist"
    exit 1
fi

echo "Copying files from $SOURCE_DIR..."

# Fichiers nix
cp "$SOURCE_DIR/configuration.nix" "$DEST_DIR/"
cp "$SOURCE_DIR/flake.nix" "$DEST_DIR/"
cp "$SOURCE_DIR/flake.lock" "$DEST_DIR/"

# Répertoires
cp -r "$SOURCE_DIR/home-manager" "$DEST_DIR/"
cp -r "$SOURCE_DIR/modules" "$DEST_DIR/"
cp -r "$SOURCE_DIR/images" "$DEST_DIR/"
cp -r "$SOURCE_DIR/scripts" "$DEST_DIR/"
cp -r "$SOURCE_DIR/config" "$DEST_DIR/"

echo "Done."
