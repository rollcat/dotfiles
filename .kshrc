# -*- mode: shell-script -*-
# Initialization for interactive shells.

# This helps Emacs' TRAMP mode.
if [[ $TERM == "dumb" ]]; then
    PS1='$ '
    return
fi

# Source .profile, which has things common to all shells.
. ~/.profile

# prompt
PS1='$(prompt)'

# fallback #! interpreter
EXECSHELL=/bin/false

# history
HISTFILE=$HOME/.ksh_history
HISTSIZE=10000

# oh-my-ksh
OHMYKSH_DIR=${HOME}/src/github.com/qbit/ohmyksh
if [ -d "$OHMYKSH_DIR" ]
then
    . ${OHMYKSH_DIR}/ohmy.ksh
    set -A my_paths -- $(_mkpath)
    paths "${my_paths[@]}"
    # load_extension fonts
    # load_extension k
    # load_extension nocolor
    if [ "$_os" = "OpenBSD" ]; then
        load_extension openbsd
        load_completion rc
    fi
    load_completion ssh
    load_completion vmd
    # load_completion gopass
    load_completion git
    # load_completion man  # slow
fi
