#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ZSHRC="$DOTFILES_DIR/.zshrc"
TARGET_ZSHRC="$HOME/.zshrc"

OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_CUSTOM_DIR="$OMZ_DIR/custom"

BACKUP_ROOT="$HOME/.dotfiles-backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

command -v git >/dev/null 2>&1 || fail "git is required."
command -v zsh >/dev/null 2>&1 || fail "zsh is required."
[[ -f "$SOURCE_ZSHRC" ]] || fail "Missing repository file: $SOURCE_ZSHRC"

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

install_or_update_plugin() {
  local name="$1"
  local url="$2"
  local target="$OMZ_CUSTOM_DIR/plugins/$name"

  if [[ -d "$target/.git" ]]; then
    printf 'Updating plugin: %s\n' "$name"
    git -C "$target" pull --ff-only
  elif [[ -e "$target" ]]; then
    fail "$target exists but is not a Git checkout."
  else
    printf 'Installing plugin: %s\n' "$name"
    git clone --depth=1 "$url" "$target"
  fi
}

backup_existing_zshrc() {
  if [[ ! -e "$TARGET_ZSHRC" && ! -L "$TARGET_ZSHRC" ]]; then
    return
  fi

  mkdir -p "$BACKUP_DIR"

  if [[ -L "$TARGET_ZSHRC" ]]; then
    local link_target
    link_target="$(readlink "$TARGET_ZSHRC" || true)"

    printf '%s\n' "$link_target" > "$BACKUP_DIR/.zshrc.symlink-target"

    if [[ -f "$TARGET_ZSHRC" ]]; then
      cp -L "$TARGET_ZSHRC" "$BACKUP_DIR/.zshrc"
    fi
  else
    cp -p "$TARGET_ZSHRC" "$BACKUP_DIR/.zshrc"
  fi

  printf 'Previous .zshrc backed up under: %s\n' "$BACKUP_DIR"
}

install_zshrc() {
  backup_existing_zshrc

  rm -f "$TARGET_ZSHRC"
  cp "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
  chmod 644 "$TARGET_ZSHRC"

  printf 'Copied %s -> %s\n' "$SOURCE_ZSHRC" "$TARGET_ZSHRC"
}

create_local_config() {
  if [[ ! -e "$HOME/.zshrc.local" ]]; then
    cat > "$HOME/.zshrc.local" <<'EOF'
# Machine-specific Zsh settings.
# Examples: private proxy variables, CUDA paths, and host-specific aliases.
EOF

    chmod 600 "$HOME/.zshrc.local"
    printf 'Created %s\n' "$HOME/.zshrc.local"
  fi
}

install_oh_my_zsh

mkdir -p "$OMZ_CUSTOM_DIR/plugins"

install_or_update_plugin \
  "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions.git"

install_or_update_plugin \
  "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git"

install_zshrc
create_local_config

zsh -n "$TARGET_ZSHRC"

printf '\nInstallation complete.\n'
printf 'Start or reload Zsh with:\n'
printf '  exec zsh\n'
printf '\nAfter testing, optionally set Zsh as the login shell:\n'
printf '  chsh -s "$(command -v zsh)"\n'