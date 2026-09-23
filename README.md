# Dotfiles

Arch Linux dotfiles and package configuration for syncing between machines.

## Usage

### On a fresh Arch install:

```bash
cd ~
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
./install.sh
```

The script will:
- Back up existing configs to `~/.config.backup.<timestamp>`
- Symlink all configs from `.config/` to `~/.config/`
- Symlink shell configs (`.bashrc`, `.zshrc`, etc.) to `~$HOME/`
- Install all packages from `packages.txt`

### Syncing from your main machine:

After making changes to your configs:

```bash
cd ~/dotfiles
# Update packages list
pacman -Q > packages.txt
# Commit and push
git add .
git commit -m "Update configs and packages"
git push
```

Then on your other machine:
```bash
cd ~/dotfiles
git pull
./install.sh  # Safe to run multiple times
```

## What's included

- `.config/` — Application configurations (neovim, Hyprland, kitty, waybar, etc.)
- `home/` — Shell configs (`.bashrc`, `.zshrc`)
- `packages.txt` — Complete list of installed packages

## Notes

- The install script is idempotent (safe to run multiple times)
- Existing configs are backed up before installation
- If something breaks, restore from the backup: `cp -r ~/.config.backup.* ~/.config`
