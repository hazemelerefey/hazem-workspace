# ── Path to Oh My Zsh ──
export ZSH="$HOME/.oh-my-zsh"

# ── Theme: Powerlevel10k ──
ZSH_THEME="powerlevel10k/powerlevel10k"

# ── Plugins ──
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    docker
    docker-compose
    npm
    pip
    python
    rust
    go
    history
    alias-finder
    sudo
    command-not-found
)

source "$ZSH/oh-my-zsh.sh"

# ── Source custom files ──
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"
[[ -f "$HOME/.exports" ]] && source "$HOME/.exports"
[[ -f "$HOME/.functions" ]] && source "$HOME/.functions"

# ── Powerlevel10k instant prompt ──
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Editor ──
export EDITOR="nano"
export VISUAL="nano"

# ── Fzf ──
source <(fzf --zsh 2>/dev/null)

# ── Bun (if exists) ──
[[ -f "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
