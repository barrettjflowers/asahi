# ~/.zshrc
# prompt
prompt=$'%F{250}%B%F{250}%~ › %F{250}$(git_branch_name) \n%F{250}➞%b%f '

##### a bunch of random functions i frequent #####

# find and set branch name var if in git repository
function git_branch_name()
{
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ $branch == "" ]];
  then
    :
  else
    echo ''$branch''
  fi
}

# open remote url
function git_remote_url() {
  local url=$(git remote get-url origin \
    | sed -E 's#(git@|https://)#https://#; s#github.com:#github.com/#; s#\.git$##')
  xdg-open "$url"
}

# history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# ls colors
export CLICOLOR=1
export LSCOLORS="GxExCxDxBxagacad"
alias ls='ls --color=auto'

# substitution
setopt prompt_subst
source /usr/share/fzf/shell/key-bindings.zsh
source ~/.fzf-tab/fzf-tab.plugin.zsh

# syntax highlighting
#source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

###### aliases #######
alias vim='nvim'
alias gl='git log --all --oneline --graph'
alias gurl=git_remote_url
alias gf='git pull --ff-only'
alias vimconf='nvim $NVIM_CONFIG'
alias hypr='nvim ~/.config/hypr/hyprland.lua'
alias wlc='wl-copy'
alias open='xdg-open'
alias ascii='/home/barrettjflowers/Dev/ascii-view/ascii-view'
alias claude='cd ~/Dev/AgentRoot/Indyhost/ && git pull --ff-only && claude'

# notes
alias ob='cd /home/barrettjflowers/Documents/Vault/barrettjflowers'
alias daily='/home/barrettjflowers/Documents/Vault/barrettjflowers/daily-note.sh'

# dotfile scripts
alias ntfy="~/.scripts/ntfy.sh"
alias dict='~/.scripts/rofi-dict.sh'

# fzf
alias fman='bash -c '\''compgen -c | fzf --height 20 --no-preview | xargs man'\'
alias fd='cd "$(find . -maxdepth 3 -type d -not -name ".Trash" 2>/dev/null | fzf --height 20 --no-preview)"'
alias falias='alias | awk -F= '\''{print $1}'\'' | fzf --height 20 --no-preview | xargs -I{} zsh -ic {}'
alias fh='history 100 | fzf --height 20 --no-preview'

# pomodoro! thanks bashbunni
alias work="timer 10s && terminal-notifier -message 'Pomodoro'\
        -title 'Work Timer is up! Take a Break. '\
        -sound Crystal"
        
alias rest="timer 10m && terminal-notifier -message 'Pomodoro'\
        -title 'Break is over! Get back to work ☕'\
        -sound Crystal"

# vi-mode
bindkey -v '^?' backward-delete-char

# autocomplete
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'l:|=* r:|=*'
autoload -Uz compinit; compinit
autoload -Uz bashcompinit; bashcompinit

autoload -Uz bashcompinit && bashcompinit
source <(/home/barrettjflowers/.opencode/bin/opencode completion)

_complete_ssh_hosts ()
{
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        comp_ssh_hosts=`
            awk '/^Host/ && $2 !~ /[*]/ {print $2}' ~/.ssh/config ;
            `
        COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
        return 0
}

complete -F _complete_ssh_hosts ssh
export PATH="/Users/barrettjflowers/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="/Users/barrettjflowers/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
export CARGO="/home/barrettjflowers/.cargo/bin"

export PATH="$PATH:/Users/barrettjflowers/.local/bin"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias swifter=/Users/barrettjflowers/Dev/swifter/.build/debug/Swifter
export PATH="$HOME/.opencode/bin:$PATH"
export QT_QPA_PLATFORMTHEME=qt6ct
export PATH="$HOME/.local/bin:$PATH"
