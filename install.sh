#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config.backup.$(date +%s)"

echo "=== Arch Dotfiles Sync Setup ==="

# Backup existing configs
if [[ -d "$HOME/.config" ]]; then
    echo "Backing up existing ~/.config to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    cp -r "$HOME/.config" "$BACKUP_DIR/" || true
fi

# Install dotfiles - symlink .config
echo "Installing dotfiles..."
mkdir -p "$HOME/.config"

for dir in "$REPO_DIR"/.config/*/; do
    dirname="$(basename "$dir")"
    target="$HOME/.config/$dirname"

    # Remove old symlink or backup the directory
    if [[ -L "$target" ]]; then
        rm "$target"
    elif [[ -d "$target" ]]; then
        echo "  Config already exists: $dirname (keeping as is, not overwriting)"
        continue
    fi

    # Create symlink
    ln -s "$dir" "$target"
    echo "  ✓ Linked $dirname"
done

# Install shell configs to home
echo "Installing shell configs..."
for file in "$REPO_DIR"/home/.*; do
    [[ -f "$file" ]] || continue
    filename="$(basename "$file")"
    target="$HOME/$filename"

    if [[ -L "$target" ]]; then
        rm "$target"
    elif [[ -f "$target" ]]; then
        echo "  ⚠ File already exists: $filename (backing up)"
        cp "$target" "$target.backup.$(date +%s)"
        rm "$target"
    fi

    ln -s "$file" "$target"
    echo "  ✓ Linked $filename"
done

# Install packages
if [[ -f "$REPO_DIR/packages.txt" ]]; then
    echo "Installing packages from packages.txt..."

    # Extract package names (first column from pacman -Q output)
    packages=$(cut -d' ' -f1 "$REPO_DIR/packages.txt")

    # Count missing packages
    missing=0
    for pkg in $packages; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            ((missing++))
        fi
    done

    if [[ $missing -gt 0 ]]; then
        echo "Found $missing missing packages. Installing..."
        # Use yay if available, otherwise pacman
        if command -v yay &>/dev/null; then
            yay -S --noconfirm $(echo "$packages" | tr '\n' ' ')
        else
            sudo pacman -S --noconfirm $(echo "$packages" | tr '\n' ' ')
        fi
        echo "✓ Packages installed"
    else
        echo "✓ All packages already installed"
    fi
else
    echo "No packages.txt found, skipping package installation"
fi

echo ""
echo "=== Setup complete! ==="
echo "Backup saved to: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "  1. Review configs in ~/.config"
echo "  2. Restart your shell: exec \$SHELL"
echo "  3. If anything broke, restore from: $BACKUP_DIR"
