# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.7z)      7z x "$1" ;;
    *)         echo "Unknown format: $1" ;;
  esac
}

# Show top 10 most-used commands
top_commands() {
  history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10
}
