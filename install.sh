#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()    { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }
warn()    { echo "[WARN]  $*"; }

# Backup existing file and create symlink
link_file() {
  local src=$1 dst=$2

  # Create parent directory if needed
  mkdir -p "$(dirname "$dst")"

  if [ -f "$dst" ] && [ ! -L "$dst" ]; then
    warn "Backing up $dst -> ${dst}.backup"
    mv "$dst" "${dst}.backup"
  fi

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    success "Already linked: $dst"
    return
  fi

  ln -sf "$src" "$dst"
  success "Linked: $dst -> $src"
}

# Install packages
install_packages() {
  case "$(uname -s)" in
    Darwin)
      info "Installing Homebrew packages..."
      grep -v '^#' "$DOTFILES_DIR/mac/brew-packages.txt" | xargs brew install
      ;;
    Linux)
      info "Installing apt packages..."
      sudo apt-get update -qq
      grep -v '^#' "$DOTFILES_DIR/linux/apt-packages.txt" | xargs sudo apt-get install -y
      # Install starship on Linux
      if ! command -v starship &>/dev/null; then
        info "Installing Starship..."
        local install_script
        install_script="$(mktemp)"
        curl -fsSL https://starship.rs/install.sh -o "$install_script" \
          || error "Failed to download Starship installer"
        sh "$install_script" --yes
        rm -f "$install_script"
      fi
      ;;
  esac
}

# Create symlinks
link_dotfiles() {
  link_file "$DOTFILES_DIR/shell/.zshrc"         "$HOME/.zshrc"
  link_file "$DOTFILES_DIR/git/.gitconfig"        "$HOME/.gitconfig"
  link_file "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"
  link_file "$DOTFILES_DIR/tmux/.tmux.conf"       "$HOME/.tmux.conf"
  link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

  if [ ! -f "$HOME/.gitconfig.local" ]; then
    cp "$DOTFILES_DIR/git/.gitconfig.local.example" "$HOME/.gitconfig.local"
    warn "Created ~/.gitconfig.local — update your name and email inside!"
  fi
}

# Set zsh as default shell if needed
set_default_shell() {
  if [ "$SHELL" != "$(command -v zsh)" ]; then
    info "Setting zsh as default shell..."
    if chsh -s "$(command -v zsh)"; then
      success "Default shell set to zsh"
    else
      warn "Could not set zsh as default shell. Run manually: chsh -s $(command -v zsh)"
    fi
  else
    success "zsh is already the default shell"
  fi
}

# Install Nerd Font (macOS only)
install_nerd_font() {
  if [ "$(uname -s)" != "Darwin" ]; then return; fi
  if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
    success "Nerd Font already installed"
  else
    info "Installing JetBrainsMono Nerd Font..."
    brew install --cask font-jetbrains-mono-nerd-font
    success "Nerd Font installed"
  fi
}

install_packages
link_dotfiles
set_default_shell
install_nerd_font

success "Done. Restart your terminal or run: source ~/.zshrc"
