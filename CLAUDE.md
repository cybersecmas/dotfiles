# CLAUDE.md

This file is read automatically by Claude Code when working in this repo.

## Purpose

Minimal dotfiles repository for macOS and Linux. Provides a reproducible terminal environment using zsh, Starship, tmux, and Catppuccin Mocha theme.

## Repository Structure

```
dotfiles/
├── bootstrap.sh      # Entry point
├── install.sh        # Package install + symlinks
├── update.sh         # Pull + re-install
├── shell/            # zsh config (modular)
├── starship/         # Starship prompt config
├── git/              # Git config
├── tmux/             # tmux config
├── mac/              # macOS package list
└── linux/            # Linux package list
```

## How Symlinks Work

`install.sh` uses `link_file()` to create symlinks from `~` into this repo:

```
~/.zshrc              -> ~/dotfiles/shell/.zshrc
~/.gitconfig          -> ~/dotfiles/git/.gitconfig
~/.gitignore_global   -> ~/dotfiles/git/.gitignore_global
~/.tmux.conf          -> ~/dotfiles/tmux/.tmux.conf
~/.config/starship.toml -> ~/dotfiles/starship/starship.toml
```

Editing any file in `~/dotfiles` takes effect immediately — no copy step needed.

## Coding Conventions

- Shell scripts: `#!/usr/bin/env bash`, `set -e`
- Functions: `snake_case`
- Log helpers: use `info()`, `success()`, `warn()`, `error()` — defined in each script
- Keep scripts idempotent: always check state before making changes
- No external dependencies beyond what's in the package lists

## What NOT to Do

- Do not add Oh My Zsh or Prezto
- Do not add heavy plugin managers (antigen, zinit, etc.)
- Do not source plugins that add >50ms to shell startup
- Do not hardcode paths — use `$HOME` and `$DOTFILES_DIR`
- Do not commit secrets or personal tokens

## How to Test Changes

1. Run `./bootstrap.sh` on a clean machine or VM
2. Verify symlinks: `ls -la ~ | grep dotfiles`
3. Check shell startup time: `time zsh -i -c exit`
4. Reload current shell: `source ~/.zshrc`

## Known Issues

- `starship/starship.toml`: palette section phải là `[palettes.catppuccin_mocha]` (có `s`),
  không phải `[palette.catppuccin_mocha]` — Starship sẽ báo lỗi config nếu sai

## Local Overrides

`shell/.zshrc` sources `~/.zshrc.local` nếu file tồn tại:

```bash
. ~/.zshrc.local
```

Dùng file này cho config cá nhân (tokens, aliases máy cụ thể) không muốn commit lên GitHub.
File `*.local` đã có trong `.gitignore`.

## Spec & Documentation

`docs/requirements.md` là prompt gốc dùng để generate repo này với Claude Code.
Dùng file này làm tài liệu tham chiếu hoặc feed lại cho AI khi cần cập nhật lớn.
