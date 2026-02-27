#!/bin/sh

# Sync NixOS configuration files from current directory to /etc/nixos/
# Usage: ./copy-to-nixos.sh

SOURCE_DIR="$(pwd)"
DEST_DIR="/etc/nixos"

if [ ! -d "$DEST_DIR" ]; then
    echo "Error: $DEST_DIR does not exist"
    exit 1
fi

echo "Copying files to $DEST_DIR..."

# Fichiers nix
sudo cp "$SOURCE_DIR/configuration.nix" "$DEST_DIR/"
sudo cp "$SOURCE_DIR/flake.nix" "$DEST_DIR/"
sudo cp "$SOURCE_DIR/flake.lock" "$DEST_DIR/"

# Répertoires
sudo cp -r "$SOURCE_DIR/home-manager" "$DEST_DIR/"
sudo cp -r "$SOURCE_DIR/modules" "$DEST_DIR/"
sudo cp -r "$SOURCE_DIR/images" "$DEST_DIR/"
sudo cp -r "$SOURCE_DIR/scripts" "$DEST_DIR/"
sudo cp -r "$SOURCE_DIR/config" "$DEST_DIR/"

echo "Done."
