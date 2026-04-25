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

## Security Rules

- **Never hardcode personal info** (name, email) in committed files — use `~/.gitconfig.local` (excluded by `.gitignore`)
- **Never use `curl | sh`** — download to a temp file first, then execute (using `sh` or `bash` depending on the official instructions):
  ```bash
  script="$(mktemp)"
  curl -fsSL https://example.com/install.sh -o "$script"
  sh "$script" # Or bash "$script" depending on the software's guide
  rm -f "$script"
  ```
- **Always quote variables** in shell scripts — use `xargs` instead of unquoted `$()`
- **SSH config stays local** — do not add `~/.ssh/config` to dotfiles (contains machine-specific hosts)
- **Wrap `chsh` in `if`** — it can fail in restricted environments; use `warn()` instead of crashing
- File `*.local` is gitignored — safe to store personal overrides there
- **Strict File Permissions**: Bất kỳ thư mục/file nhạy cảm nào tạo ra (~/.ssh, ~/.gnupg) phải bị ép quyền 700. Private keys phải bị ép 600 và Public keys 644.

## What NOT to Do

- Do not add Oh My Zsh or Prezto
- Do not add heavy plugin managers (antigen, zinit, etc.)
- Do not source plugins that add >50ms to shell startup
- Do not hardcode paths — use `$HOME` and `$DOTFILES_DIR`
- Do not commit secrets or personal tokens
- Do not commit `~/.ssh/config` or any SSH keys

## How to Test Changes

1. Run `./bootstrap.sh` on a clean machine or VM
2. Verify symlinks: `ls -la ~ | grep dotfiles`
3. Check shell startup time: `time zsh -i -c exit`
4. Reload current shell: `source ~/.zshrc`

## Known Issues

- `starship/starship.toml`: palette section phải là `[palettes.catppuccin_mocha]` (có `s`),
  không phải `[palette.catppuccin_mocha]` — Starship sẽ báo lỗi config nếu sai

## Git Identity

Git user config (name, email) is stored in `~/.gitconfig.local`, **not committed to the repo**.

`git/.gitconfig` uses `[include] path = ~/.gitconfig.local` to load it.

`git/.gitconfig.local.example` is the template — `install.sh` copies it to `~` on first run.
Update `~/.gitconfig.local` with your real name and email after install.

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
