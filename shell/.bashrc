# ── Bash fallback config (sourced if shell is Bash) ──

# Source aliases
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"
[[ -f "$HOME/.exports" ]] && source "$HOME/.exports"
[[ -f "$HOME/.functions" ]] && source "$HOME/.functions"

# Bash completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi
