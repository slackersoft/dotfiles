. $HOME/workspace/dotfiles/zshprompt
export PATH=$PATH:$HOME/.local/bin
fpath=($fpath ./.zsh_complete ./.zsh_completions)

if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

alias ag="ag --skip-vcs-ignore"


alias k=kubectl
alias kc=kubectl
alias tf=terraform
alias vim=nvim

autoload -Uz compinit
compinit

# Customizations that shouldn't be shared between machines go in .zshrc.local
# E.g if you prefer vim over nano, set both EDITOR and VISUAL to vim
# in .zshrc.local, not here.
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"

source "$(/opt/homebrew/bin/brew --prefix)/opt/asdf/libexec/asdf.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"

ulimit -n 2048

