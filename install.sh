#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config.backup.$(date +%s)"
LOG_FILE="$REPO_DIR/install.log"

exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "=== Arch Dotfiles Sync Setup ==="
echo "Log file: $LOG_FILE"
echo "Start time: $(date)"
echo ""

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

    # Ensure yay is installed
    if ! command -v yay &>/dev/null; then
        echo "yay not found. Installing build dependencies..."
        sudo pacman -S --noconfirm base-devel git || true

        echo "Installing yay from AUR..."
        cd /tmp
        rm -rf yay 2>/dev/null || true
        if git clone https://aur.archlinux.org/yay.git && cd yay; then
            if makepkg -si --noconfirm; then
                cd "$REPO_DIR"
                echo "✓ yay installed"
            else
                echo "⚠ yay build failed, falling back to pacman"
                cd "$REPO_DIR"
                USE_PACMAN=1
            fi
        else
            echo "⚠ Failed to clone yay, falling back to pacman"
            USE_PACMAN=1
        fi
    fi

    # Extract package names (first column from pacman -Q output)
    packages=$(cut -d' ' -f1 "$REPO_DIR/packages.txt")

    # Count missing packages
    missing_list=()
    for pkg in $packages; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            missing_list+=("$pkg")
        fi
    done

    if [[ ${#missing_list[@]} -gt 0 ]]; then
        echo "Found ${#missing_list[@]} missing packages. Installing..."

        # Use yay if available, otherwise fallback to pacman
        if command -v yay &>/dev/null && [[ "${USE_PACMAN:-0}" != "1" ]]; then
            echo "Using yay for installation..."
            batch_size=50
            for ((i=0; i<${#missing_list[@]}; i+=batch_size)); do
                batch=("${missing_list[@]:$i:$batch_size}")
                yay -S --noconfirm "${batch[@]}" || echo "⚠ Some packages failed to install"
            done
        else
            echo "Using pacman for installation..."
            batch_size=50
            for ((i=0; i<${#missing_list[@]}; i+=batch_size)); do
                batch=("${missing_list[@]:$i:$batch_size}")
                sudo pacman -S --noconfirm "${batch[@]}" || echo "⚠ Some packages failed to install"
            done
        fi
        echo "✓ Package installation completed"
    else
        echo "✓ All packages already installed"
    fi
else
    echo "No packages.txt found, skipping package installation"
fi

echo ""
echo "=== Setup complete! ==="
echo "Backup saved to: $BACKUP_DIR"
echo "Log saved to: $LOG_FILE"
echo ""
echo "Next steps:"
echo "  1. Review configs in ~/.config"
echo "  2. Restart your shell: exec \$SHELL"
echo "  3. If anything broke, restore from: $BACKUP_DIR"
echo ""
echo "End time: $(date)"
