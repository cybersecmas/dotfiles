# Editor
export EDITOR="vim"
export VISUAL="vim"

# Language
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Path
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# History
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoredups:erasedups

# fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
