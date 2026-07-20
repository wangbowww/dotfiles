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


install_vimrc() {
  # Load the repository configuration once to detect obvious errors.
  vim \
    -Nu "$SOURCE_VIMRC" \
    -n \
    -es \
    -c 'qall' \
    </dev/null

  rm -f "$TARGET_VIMRC"
  cp "$SOURCE_VIMRC" "$TARGET_VIMRC"
  chmod 644 "$TARGET_VIMRC"

  printf 'Copied %s -> %s\n' "$SOURCE_VIMRC" "$TARGET_VIMRC"
}


install_vimrc

printf '\nVim installation complete.\n'
printf 'Open Vim to test the configuration:\n'
printf '  vim\n'