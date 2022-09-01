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

# Custom complete functions
set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM -USR1 -USR2
set -A complete_pkill_1 -- -9 -HUP -INFO -KILL -TERM -USR1 -USR2
set -A complete_tmux_1 -- attach detach has $(tmux list-commands | awk '{print $1}')
# TODO: command aliases for tmux
set -A complete_chmod_1 -- +r +w +x -r -w -x
set -A complete_chown_1 -- $(getent passwd | cut -d: -f1)
set -A complete_chgrp_1 -- $(getent group | cut -d: -f1)
set -A complete_getent_1 -- ethers group hosts passwd protocols rpc services shells
set -A complete_eject_1 -- $(ls -d /dev/rcd?c /dev/rst? | sed -e 's#/dev/r##g')
set -A complete_pkg_info -- $(ls -1 /var/db/pkg)
set -A complete_ifconfig_1 -- $(ifconfig | grep ^[a-z] | cut -d: -f1)

set -A complete_gpg2_1 -- --armor --clearsign --decrypt --detach-sig \
  --list-key --receive-keys --refresh --sign --verify

set -A complete_doas_1 -- $(echo $PATH | tr : '\n' | xargs ls -1 2>/dev/null)

set -A complete_id -- -c -G -g -p -R -u -n -r $(getent passwd | cut -d: -f1)
