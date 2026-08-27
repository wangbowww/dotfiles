#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_VIMRC="$DOTFILES_DIR/.vimrc"
TARGET_VIMRC="$HOME/.vimrc"

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

command -v vim >/dev/null 2>&1 || fail "vim is required."

[[ -f "$SOURCE_VIMRC" ]] ||
  fail "Missing repository file: $SOURCE_VIMRC"


install_file_with_backup() {
  local source_path="$1"
  local target_path="$2"
  local backup_path=""
  local temporary_path="${target_path}.new.$$"

  if [[ -d "$target_path" && ! -L "$target_path" ]]; then
    fail "$target_path is a directory. Move it manually before installing."
  fi

  if [[ -f "$target_path" && ! -L "$target_path" ]] && \
    cmp -s "$source_path" "$target_path"; then
    printf 'Already up to date: %s\n' "$target_path"
    return
  fi

  [[ ! -e "$temporary_path" && ! -L "$temporary_path" ]] ||
    fail "Temporary path already exists: $temporary_path"

  cp "$source_path" "$temporary_path"
  chmod 644 "$temporary_path"

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    backup_path="${target_path}.backup.$(date '+%Y%m%d-%H%M%S').$$"
    [[ ! -e "$backup_path" && ! -L "$backup_path" ]] ||
      fail "Backup path already exists: $backup_path"

    mv "$target_path" "$backup_path"
    printf 'Backed up %s -> %s\n' "$target_path" "$backup_path"
  fi

  if ! mv "$temporary_path" "$target_path"; then
    if [[ -n "$backup_path" ]]; then
      mv "$backup_path" "$target_path"
    fi
    fail "Failed to install $target_path. Original file restored."
  fi

  printf 'Copied %s -> %s\n' "$source_path" "$target_path"
}


vim \
  -Nu "$SOURCE_VIMRC" \
  -n \
  -es \
  -c 'qall' \
  </dev/null

install_file_with_backup "$SOURCE_VIMRC" "$TARGET_VIMRC"

printf '\nVim installation complete.\n'
printf 'Open Vim to test the configuration:\n'
printf '  vim\n'
