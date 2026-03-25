DOTFILES_DIR="$HOME/dotfiles"

source "$DOTFILES_DIR/shell/exports.zsh"
source "$DOTFILES_DIR/shell/aliases.zsh"
source "$DOTFILES_DIR/shell/functions.zsh"

# fzf key bindings
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(starship init zsh)"

. ~/.zshrc.local