# -*- mode: shell-script -*-
# Initialization for interactive shells.

# This helps Emacs' TRAMP mode.
if [[ $TERM == "dumb" ]]; then
    unsetopt zle
    PS1='$ '
    return
fi

# Source .profile, which has things common to all shells.
. ~/.profile

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

zstyle ':completion:*:sudo:*' command-path /usr/local/sbin \
                                           /usr/local/bin  \
                                           /usr/sbin       \
                                           /usr/bin        \
                                           /sbin           \
                                           /bin

# more completions
if which op > /dev/null
then eval "$(op completion zsh)"
fi

# autocd
setopt autocd

# Word breaking
local WORDCHARS='*?_[]~=&;!#$%^(){}<>'

# Terminal window title
termtitle() {
    printf '\e]2;%s\a' "$@"
}
default_termtitle() {
    termtitle "$USER:$HOST:$PWD"
}

# prompt
# TODO: highlight non-zero exit status
PS1="%# "
precmd() {
    default_termtitle
    # send a bell to mark window urgent
    echo -n '\a'
    PS1="$(prompt)"
}
preexec() {
    termtitle "$2"
}

# history
setopt histignorealldups sharehistory
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# After changing to a new directory, list it
chpwd() {
    ls
}

# Plugins
mkdir -p ~/.zsh.d
for fname in $(find ~/.zsh.d -type f -name "*.plugin.zsh"); do
    source "$fname"
done

# Reset to default terminal title
default_termtitle
