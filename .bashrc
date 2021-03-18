# -*- mode: shell-script -*-
# Initialization for interactive shells.

# This helps Emacs' TRAMP mode.
if [[ $TERM == "dumb" ]]; then
    PS1='$ '
    return
fi

# Source .profile, which has things common to all shells.
. ~/.profile

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
    PS1="$(prompt)"
}
PROMPT_COMMAND=precmd

# history
HISTCONTROL=ignoreboth # ignoredups and ignorespace
shopt -s histappend
HISTSIZE=10000
HISTFILESIZE=10000

# Reset to default terminal title
default_termtitle
