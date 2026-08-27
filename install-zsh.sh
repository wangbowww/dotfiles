#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_ZSHRC="$DOTFILES_DIR/.zshrc"
TARGET_ZSHRC="$HOME/.zshrc"

OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_CUSTOM_DIR="$OMZ_DIR/custom"

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

command -v git >/dev/null 2>&1 || fail "git is required."
command -v zsh >/dev/null 2>&1 || fail "zsh is required."

[[ -f "$SOURCE_ZSHRC" ]] ||
  fail "Missing repository file: $SOURCE_ZSHRC"


install_oh_my_zsh() {
  if [[ -f "$OMZ_DIR/oh-my-zsh.sh" ]]; then
    printf 'Oh My Zsh already installed: %s\n' "$OMZ_DIR"
    return
  fi

  if [[ -e "$OMZ_DIR" ]]; then
    fail "$OMZ_DIR exists but is not a valid Oh My Zsh installation."
  fi

  printf 'Installing Oh My Zsh...\n'

  git -c http.version=HTTP/1.1 \
    clone --depth=1 \
    https://github.com/ohmyzsh/ohmyzsh.git \
    "$OMZ_DIR"
}


install_plugin() {
  local name="$1"
  local url="$2"
  local target="$OMZ_CUSTOM_DIR/plugins/$name"

  if [[ -d "$target/.git" ]]; then
    printf 'Plugin already installed: %s\n' "$name"
    return
  fi

  if [[ -e "$target" ]]; then
    fail "$target exists but is not a valid Git checkout."
  fi

  printf 'Installing plugin: %s\n' "$name"

  git -c http.version=HTTP/1.1 \
    clone --depth=1 "$url" "$target"
}


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


create_local_config() {
  if [[ -e "$HOME/.zshrc.local" ]]; then
    printf 'Keeping existing local configuration: %s\n' \
      "$HOME/.zshrc.local"
    return
  fi

  cat > "$HOME/.zshrc.local" <<'EOF'
# Machine-specific Zsh settings.
# Put proxy variables, CUDA paths, private environment variables,
# and host-specific aliases in this file.
EOF

  chmod 600 "$HOME/.zshrc.local"

  printf 'Created %s\n' "$HOME/.zshrc.local"
}


install_oh_my_zsh

mkdir -p "$OMZ_CUSTOM_DIR/plugins"

install_plugin \
  "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions.git"

install_plugin \
  "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git"

zsh -n "$SOURCE_ZSHRC"
install_file_with_backup "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
create_local_config

printf '\nZsh installation complete.\n'
printf 'Reload the current shell with:\n'
printf '  exec zsh\n'
printf '\nOptionally set Zsh as the default login shell:\n'
printf '  chsh -s "$(command -v zsh)"\n'
