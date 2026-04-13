#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()    { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }
warn()    { echo "[WARN]  $*"; }
error()   { echo "[ERROR] $*" >&2; exit 1; }

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
      # Install gh (GitHub CLI) on Linux — not in default apt repos
      if ! command -v gh &>/dev/null; then
        info "Installing GitHub CLI (gh)..."
        local gpg_tmp
        gpg_tmp="$(mktemp)"
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o "$gpg_tmp" \
          || error "Failed to download gh keyring"
        sudo install -m 644 "$gpg_tmp" /usr/share/keyrings/githubcli-archive-keyring.gpg
        rm -f "$gpg_tmp"
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
          | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update -qq
        sudo apt-get install -y gh
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

# Install uv (Python package manager)
install_uv() {
  if command -v uv > /dev/null 2>&1; then
    success "uv already installed, skipping"
    return
  fi

  info "Installing uv..."
  local script
  script="$(mktemp)"
  curl -fsSL https://astral.sh/uv/install.sh -o "$script" \
    || error "Failed to download uv installer"
  sh "$script"
  rm -f "$script"
  success "uv installed"
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

# Enforce secure permissions on local directories
secure_permissions() {
  info "Applying secure permissions..."
  
  mkdir -p "$HOME/.local/bin"
  chmod 755 "$HOME/.local/bin"
  
  if [ -d "$HOME/.ssh" ]; then
    chmod 700 "$HOME/.ssh"
    # Set 600 for private keys (files starting with id_ but without .pub)
    find "$HOME/.ssh" -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} + 2>/dev/null || true
    # Set 644 for public keys
    find "$HOME/.ssh" -type f -name "*.pub" -exec chmod 644 {} + 2>/dev/null || true
  fi
}

install_packages
install_uv
link_dotfiles
secure_permissions
set_default_shell
install_nerd_font

success "Done. Restart your terminal or run: source ~/.zshrc"
