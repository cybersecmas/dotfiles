# Prompt: Generate a Production-Ready Dotfiles Repository

## Role

Act as a **senior DevOps engineer** designing a clean, production-ready terminal environment repository.

---

# Goal

Create a **minimal and maintainable dotfiles repository** for a developer terminal setup.

The repository must:

* be easy to understand
* be safe to run on multiple machines
* install the full environment in **under 5 minutes**

Expected usage:

```bash
git clone <repo>
cd dotfiles
./bootstrap.sh
```

---

# Environment

Primary machine:

* OS: macOS
* Terminal: iTerm2
* Shell: zsh
* Prompt: Starship
* Font: JetBrains Mono Nerd Font
* Theme: Catppuccin Mocha

The setup should also work on:

* Linux workstations
* remote Linux servers over SSH

---

# Design Principles

Follow these principles:

* minimal configuration
* fast shell startup (<100ms preferred)
* modular structure
* reproducible setup
* easy to understand
* safe for version control

Avoid heavy frameworks such as:

* Oh My Zsh
* large plugin managers

Prefer simple and explicit configuration.

---

# Simplicity Rule

Prefer the **simplest solution that satisfies the requirements**.

Avoid:

* unnecessary abstractions
* excessive file splitting
* complex shell tricks

Favor solutions that:

* use fewer files
* minimize shell complexity
* are easy to maintain

---

# Automation Requirements

All automation scripts must be:

* **idempotent** (safe to run multiple times)
* safe on existing systems
* resilient to partial installs
* backup existing dotfiles before overwriting

Scripts should check system state before applying changes.

---

# Dotfile Backup Strategy

Before creating symlinks, the install script must:

* check if the target file already exists
* if it exists and is **not** already a symlink pointing to the dotfiles repo, rename it to `<filename>.backup`
* never silently overwrite existing files

Example:

```
~/.zshrc      → backed up to ~/.zshrc.backup
~/.gitconfig  → backed up to ~/.gitconfig.backup
~/.tmux.conf  → backed up to ~/.tmux.conf.backup
```

Example logic:

```bash
link_file() {
  local src=$1 dst=$2
  if [ -f "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "${dst}.backup"
    echo "Backed up $dst to ${dst}.backup"
  fi
  ln -sf "$src" "$dst"
}
```

This ensures existing user configuration is never lost.

---

# Architecture Step (Important)

Before generating files:

1. Briefly explain the repository architecture.
2. Justify key design decisions.
3. Identify possible failure scenarios.
4. Then generate the files.

Keep the explanation concise.

---

# Repository Structure

Generate the repository using this structure:

```
dotfiles/
├── CLAUDE.md
├── bootstrap.sh
├── install.sh
├── update.sh
├── README.md
│
├── shell/
│   ├── .zshrc
│   ├── aliases.zsh
│   ├── exports.zsh
│   └── functions.zsh
│
├── starship/
│   └── starship.toml
│
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
│
├── tmux/
│   └── .tmux.conf
│
├── mac/
│   └── brew-packages.txt
│
└── linux/
    └── apt-packages.txt
```

---

# Script Responsibilities

## bootstrap.sh

Responsibilities:

* detect operating system
* install package manager if missing (Homebrew on macOS)
* call install.sh
* prepare the environment for first-time setup

---

## install.sh

Responsibilities:

* install required packages
* backup existing dotfiles before creating symlinks
* create symlinks safely
* configure shell
* configure Starship prompt
* configure git and tmux

The script must be **idempotent**.

---

## update.sh

Used after pulling repository updates.

Example:

```bash
git pull
./update.sh
```

Responsibilities:

* refresh symlinks
* install missing packages
* update configuration safely

---

# Package Management

## macOS

Use Homebrew.

Example packages:

* starship
* tmux
* git
* fzf
* ripgrep
* fd
* bat

These should be listed in:

```
mac/brew-packages.txt
```

---

## Linux

Use apt with equivalent packages:

* zsh
* tmux
* ripgrep
* fd-find
* fzf
* git
* bat

These should be listed in:

```
linux/apt-packages.txt
```

---

# Shell Configuration

`.zshrc` should:

* load modular config files
* initialize Starship
* remain minimal and readable
* avoid unnecessary plugins

Example:

```bash
source ~/dotfiles/shell/aliases.zsh
source ~/dotfiles/shell/exports.zsh
source ~/dotfiles/shell/functions.zsh

eval "$(starship init zsh)"
```

---

# CLAUDE.md Requirements

The CLAUDE.md file is read automatically by Claude Code when working in this repo.

It must include:

* purpose of the repository
* repository structure overview
* coding conventions (shell style, naming)
* what NOT to do (e.g. do not use Oh My Zsh, do not add heavy plugins)
* how to test changes (run bootstrap.sh, verify symlinks)
* how symlinks work in this repo

---

# README Requirements

The README should include:

1. repository overview
2. installation instructions
3. explanation of the repository structure
4. instructions for setting up a new Mac
5. instructions for using the same config on Linux servers via SSH
6. how to update the environment
7. how to customize the configuration

---

# Output Format (Strict)

Return results strictly in this order:

## File: bootstrap.sh

```bash
...
```

## File: install.sh

```bash
...
```

## File: update.sh

```bash
...
```

## File: shell/.zshrc

```bash
...
```

## File: shell/aliases.zsh

```bash
...
```

## File: shell/exports.zsh

```bash
...
```

## File: shell/functions.zsh

```bash
...
```

## File: starship/starship.toml

```toml
...
```

## File: git/.gitconfig

```ini
...
```

## File: git/.gitignore_global

```text
...
```

## File: tmux/.tmux.conf

```tmux
...
```

## File: mac/brew-packages.txt

```text
...
```

## File: linux/apt-packages.txt

```text
...
```

## File: README.md

```markdown
...
```

## File: CLAUDE.md

```markdown
...
```

---

# Security Requirements

Scripts and configuration must follow these security rules:

## No Secrets in Version Control

* Do **not** hardcode personal information (name, email) in committed files
* Git user identity must be stored in `~/.gitconfig.local` (gitignored)
* `git/.gitconfig` must use `[include] path = ~/.gitconfig.local`
* Provide `git/.gitconfig.local.example` as a template; `install.sh` copies it on first run
* SSH config (`~/.ssh/config`) must remain local — not symlinked from dotfiles

## Safe Remote Script Execution

* Do **not** pipe `curl` directly to `sh` (`curl | sh`)
* Download installer scripts to a temp file first, then execute:

```bash
script="$(mktemp)"
curl -fsSL https://example.com/install.sh -o "$script" || error "Download failed"
sh "$script" --yes
rm -f "$script"
```

## Shell Script Safety

* Always quote variables — avoid unquoted `$()` command substitution
* Use `xargs` for passing file-based lists to commands (e.g. package installs)
* Wrap commands that may fail in non-critical contexts (e.g. `chsh`) in `if` blocks and use `warn()` instead of crashing
* Use `set -e` in all scripts

## Local Override Pattern

* Files matching `*.local` are gitignored — safe for personal/machine-specific config
* `install.sh` must create local config files from `.example` templates on first run, with a `warn()` prompting the user to update them

---

# Constraints

* keep configuration minimal
* prioritize performance and clarity
* avoid unnecessary plugins
* ensure compatibility with macOS and Linux
* maintain clean and readable scripts
* never commit personal information or secrets

---

# Success Criteria

A developer should be able to run:

```bash
git clone <repo>
cd dotfiles
./bootstrap.sh
```

and have a **fully working terminal environment within 5 minutes**.

The repository should feel like a **clean, well-maintained open-source project**.
