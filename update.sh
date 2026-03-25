#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()    { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }

info "Pulling latest changes..."
git -C "$DOTFILES_DIR" pull

info "Re-running install..."
bash "$DOTFILES_DIR/install.sh"

success "Update complete."
