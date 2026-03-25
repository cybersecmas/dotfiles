# dotfiles

Minimal, reproducible terminal environment for macOS and Linux.

**Stack:** zsh · Starship · tmux · Catppuccin Mocha · JetBrains Mono Nerd Font

---

## Install

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

That's it. Takes under 5 minutes on a new machine.

---

## Structure

```
dotfiles/
├── CLAUDE.md               # Claude Code guidance
├── bootstrap.sh            # Entry point: detect OS, install brew, run install.sh
├── install.sh              # Install packages, backup existing dotfiles, create symlinks
├── update.sh               # Pull latest + re-run install
│
├── shell/
│   ├── .zshrc              # Minimal shell config
│   ├── aliases.zsh         # Shell aliases
│   ├── exports.zsh         # Environment variables
│   └── functions.zsh       # Shell functions
│
├── starship/
│   └── starship.toml       # Catppuccin Mocha prompt theme
│
├── git/
│   ├── .gitconfig          # Git config (update name/email)
│   └── .gitignore_global   # Global gitignore
│
├── tmux/
│   └── .tmux.conf          # tmux config with Catppuccin Mocha
│
├── mac/
│   └── brew-packages.txt   # Homebrew packages
│
└── linux/
    └── apt-packages.txt    # apt packages
```

---

## Setting Up a New Mac

1. Install Xcode CLI tools: `xcode-select --install`
2. Clone and run bootstrap:
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ./bootstrap.sh
   ```
3. Install JetBrains Mono Nerd Font from [nerdfonts.com](https://www.nerdfonts.com)
4. Set font in iTerm2: Preferences → Profiles → Text → JetBrains Mono NF
5. Update `git/.gitconfig` with your name and email

---

## Using on a Linux Server (SSH)

On a remote Linux server:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

Starship will be installed via the official install script if not available through apt.

For SSH sessions without installing, you can source just the shell modules:

```bash
source ~/dotfiles/shell/aliases.zsh
source ~/dotfiles/shell/exports.zsh
```

---

## Updating

```bash
cd ~/dotfiles
./update.sh
```

Or manually:

```bash
git pull
./install.sh
```

---

## Customizing

| What | Where |
|---|---|
| Aliases | `shell/aliases.zsh` |
| Environment variables | `shell/exports.zsh` |
| Shell functions | `shell/functions.zsh` |
| Prompt appearance | `starship/starship.toml` |
| Git settings | `git/.gitconfig` |
| tmux keybindings | `tmux/.tmux.conf` |
| Mac packages | `mac/brew-packages.txt` |
| Linux packages | `linux/apt-packages.txt` |

After editing any file, run `source ~/.zshrc` or restart your terminal.
