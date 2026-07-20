# ============================================================
# Oh My Zsh
# ============================================================

export ZSH="$HOME/.oh-my-zsh"

# The prompt is defined directly in this file.
ZSH_THEME=""

# Disable automatic update prompts. Update manually with: omz update
zstyle ':omz:update' mode disabled

# Prevent Python venv and Conda from adding another environment prefix.
export VIRTUAL_ENV_DISABLE_PROMPT=1
export CONDA_CHANGEPS1=false

# Autosuggestion settings.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Make the normal Tab completion widget accept a visible suggestion first.
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(expand-or-complete)

# Keep zsh-syntax-highlighting last.
plugins=(
  git
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"


# ============================================================
# Prompt
# ============================================================

setopt PROMPT_SUBST

# Environment: white
prompt_environment() {
  local environment_name=""

  if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    environment_name="${VIRTUAL_ENV:t}"
  elif [[ -n "${CONDA_DEFAULT_ENV:-}" ]]; then
    environment_name="$CONDA_DEFAULT_ENV"
  fi

  if [[ -n "$environment_name" ]]; then
    print -nr -- "%F{white}(${environment_name})%f "
  fi
}

# Git branch: blue; Git status uses separate colors.
prompt_git() {
  # Only display information inside a Git working tree.
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

  local branch
  local markers=""

  # Normal branch name; use the short commit ID in detached HEAD state.
  branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null)" ||
    branch="$(command git rev-parse --short HEAD 2>/dev/null)" ||
    return

  # Staged changes.
  command git diff --cached --quiet --ignore-submodules -- 2>/dev/null ||
    markers+="%F{green}+%f"

  # Modified tracked files.
  command git diff --quiet --ignore-submodules -- 2>/dev/null ||
    markers+="%F{yellow}*%f"

  # Untracked files.
  if [[ -n "$(command git ls-files --others --exclude-standard 2>/dev/null | head -n 1)" ]]; then
    markers+="%F{yellow}?%f"
  fi

  print -nr -- "%F{blue}[${branch}%f${markers}%F{blue}]%f"
}

# Environment white; username green; hostname cyan;
# current directory yellow; Git branch blue.
PROMPT='$(prompt_environment)%F{green}%n%f@%F{cyan}%m%f:%F{yellow}%~%f $(prompt_git) %# '


# ============================================================
# History and key bindings
# ============================================================

HISTFILE="$HOME/.zsh_history"
HISTSIZE=20000
SAVEHIST=20000

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Up/Down search history using the text already typed.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

[[ -n "${terminfo[kcuu1]:-}" ]] &&
  bindkey -- "${terminfo[kcuu1]}" history-substring-search-up

[[ -n "${terminfo[kcud1]:-}" ]] &&
  bindkey -- "${terminfo[kcud1]}" history-substring-search-down

# Tab uses the normal completion widget. zsh-autosuggestions wraps this
# widget so that a visible suggestion is accepted first.
bindkey '^I' expand-or-complete


# ============================================================
# Colors and aliases
# ============================================================

if [[ "$OSTYPE" == darwin* ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'


# ============================================================
# Local machine settings
# ============================================================

# Put private proxies, CUDA paths, host-specific aliases, and other
# machine-specific settings in ~/.zshrc.local. Do not commit that file.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# User-local environment created by tools such as uv or Cargo.
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"