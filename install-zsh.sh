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

  if command -v curl >/dev/null 2>&1; then
    sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      "" --unattended --keep-zshrc
  elif command -v wget >/dev/null 2>&1; then
    sh -c \
      "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      "" --unattended --keep-zshrc
  else
    fail "curl or wget is required."
  fi
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


install_zshrc() {
  # Check the repository configuration before overwriting ~/.zshrc.
  zsh -n "$SOURCE_ZSHRC"

  rm -f "$TARGET_ZSHRC"
  cp "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
  chmod 644 "$TARGET_ZSHRC"

  printf 'Copied %s -> %s\n' "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
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

install_zshrc
create_local_config

printf '\nZsh installation complete.\n'
printf 'Reload the current shell with:\n'
printf '  exec zsh\n'
printf '\nOptionally set Zsh as the default login shell:\n'
printf '  chsh -s "$(command -v zsh)"\n'