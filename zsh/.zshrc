# Path
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Auto-update
zstyle ':omz:update' mode auto

# Auto-correction
ENABLE_CORRECTION="true"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Terminal Greeting
fastfetch

# Starship Prompt
eval "$(starship init zsh)"

# Aliases
alias save='~/dotfiles-public/save.sh'
alias help='cat ~/help.md'
export PATH="$HOME/.local/bin:$PATH"
