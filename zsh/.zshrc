# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)

# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

source /Users/hlappa/.asdf/installs/gcloud/422.0.0/path.zsh.inc
source /Users/hlappa/.asdf/installs/gcloud/422.0.0/completion.zsh.inc

# Path to your oh-my-zsh installation.
export ZSH="/Users/hlappa/.oh-my-zsh"

ZSH_THEME="agnoster"

# Auto-update behavior
zstyle ':omz:update' mode auto      # update automatically without asking

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 7

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git docker docker-compose aws gcloud ruby terraform sudo npm yarn web-search zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

. $HOME/.asdf/asdf.sh

PATH=$PATH:$HOME/.local/bin:$HOME/go/bin

# Aliases
alias n="nvim"
alias zshconfig="n ~/.zshrc"
alias ohmyzsh="n ~/.oh-my-zsh"
alias ls="exa --long --icons --no-permissions --no-user --git --time-style long-iso --time=modified --group-directories-first -a"
alias tree="exa --tree"
alias shd="shutdown -h now"
alias up="docker-compose up"
alias build="docker-compose build"
alias down="docker-compose down"
alias google="web_search google"
alias sus="systemctl suspend"
alias lock="loginctl lock-session"
alias kb="setxkbmap -layout us,fi -option grp:shifts_toggle"
alias pic="picom -b -f --experimental-backends"
alias bat="upower --dump"
alias eb="cd ~/git/epicbrief"
alias main="git checkout main"

eval "$(starship init zsh)"

tmux -l
