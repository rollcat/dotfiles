# Set up the environment for any POSIX-compliant interactive shell.
umask 022

has() {
    which $@ 2>/dev/null >/dev/null
}

# Get os & arch. Arch is OS-specific, e.g.:
# Linux aarch64, Darwin x86_64, OpenBSD amd64
_os=$(uname -s)
_arch=$(uname -m)

# Detect paths which should be added to $PATH
_mkpath() {
    # Put our own ~/bin first.
    # Also pick a subdirectory with precompiled executables for our arch.
    echo ~/bin/${_os}-${_arch}
    # On Darwin arm64, we can also use x86_64 binaries.
    if [ "x${_os}-${_arch}" = "xDarwin-arm64" ]
    then echo ~/bin/Darwin-x86_64
    fi
    echo ~/bin
    echo ~/.local/bin
    echo ~/.cargo/bin
    echo ~/.poetry/bin
    echo ~/.nix-profile/bin

    export GOPATH=~/go
    echo $GOPATH/bin

    export PYENV_ROOT=~/.pyenv
    echo ${PYENV_ROOT}/bin
    echo ${PYENV_ROOT}/shims

    if [ -d ~/.gem/ruby ]
    then find ~/.gem/ruby -maxdepth 2 -type d -name bin
    fi

    if [ -d ~/Library/Python ]
    then find ~/Library/Python -maxdepth 2 -type d -name bin
    fi

    if [ -d /Applications ]
    then find /Applications -type d -name bin -maxdepth 3
    fi

    # NixOS
    if [ -d /nix ]
    then
        echo /run/wrappers/bin
        echo /etc/profiles/per-user/$(id -un)/bin
        echo /nix/var/nix/profiles/default/bin
        echo /run/current-system/sw/bin
    fi

    echo /opt/homebrew/bin
    echo /usr/local/bin
    echo /usr/local/sbin
    echo /usr/X11R6/bin
    echo /usr/bin
    echo /usr/sbin
    echo /usr/games
    echo /bin
    echo /sbin
}

export PATH=$(_mkpath | tr '\n' :)

# Shell-specific configurations
case "$0" in
    -ksh|oksh)
        export ENV=$HOME/.kshrc
        ;;
    mksh)
        export ENV=$HOME/.mkshrc
        ;;
esac

# our termcap may be unavailable on this system - choose a safer bet
if ! infocmp >/dev/null
then case $TERM in
    rxvt-unicode-256color)
        export TERM=xterm-256color
        ;;
    rxvt*)
        export TERM=xterm
        ;;
    *)
        export TERM=xterm
        ;;
esac; fi

# Mail, notifications
export MAILCHECK=0
export MAIL=/var/mail/${LOGNAME:-$USER}

# GPG agent
export GPG_TTY=$(tty)

# Locale
unset LANGUAGE LC_ADDRESS LC_ALL LC_COLLATE LC_IDENTIFICATION LC_MONETARY \
      LC_NAME LC_NUMERIC LC_TELEPHONE LC_TIME
if [ "x${_os}" = xOpenBSD ]
then
    export LANG=C.UTF-8 LC_CTYPE=C.UTF-8
else
    export LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
fi

# Software development
export LD_LIBRARY_PATH=~/.local/lib
export LIBRARY_PATH=/opt/homebrew/lib
export PKG_CONFIG_PATH=~/.local/lib/pkgconfig
export PYTHONSTARTUP=~/.pythonrc.py
# NOTE: GOPATH and PYENV_ROOT belong here, but we also need them for $PATH

# https://drewdevault.com/2021/08/06/goproxy-breaks-go.html
export GOPROXY=direct

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_SCAN_SUGGEST=false
if has minikube && [ -z "${DOCKER_HOST:-}" ]
then eval $(minikube -p minikube docker-env)
fi

# Disable telemetry
export DO_NOT_TRACK=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export HOMEBREW_NO_ANALYTICS=1

# Pretty colors
if has dircolors
then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
elif has gdircolors && has gls
then
    eval "$(gdircolors -b)"
    alias ls='gls --color=auto'
fi
# jq: null false true numbers strings arrays objects
JQ_COLORS="0;39:0;39:0;39:0;39:0;32:0;39:0;39"

# mosh
export MOSH_ESCAPE_KEY='~'

if grep --version 2>&1 | grep -q GNU
then
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
if has lesspipe; then
    eval "$(SHELL=/bin/sh lesspipe)"
fi

# Choose preferred software
p=$(which less more 2>/dev/null | head -1)
[[ -n $p ]] && export PAGER=$p
p=$(which mg kak vim vi nano 2>/dev/null | head -1)
[[ -n $p ]] && export EDITOR=$p VISUAL=$p
p=$(which firefox chromium chrome surf2 surf dillo x-www-browser 2>/dev/null | head -1)
[[ -n $p ]] && export BROWSER=$p
p=$(which quartz-wm i3 dwm awesome cwm x-window-manager xterm 2>/dev/null | head -1)
[[ -n $p ]] && export WM=$p
unset p

# Aliases for interactive use
alias py=python3
alias ipy='python3 -m IPython'
alias tf=terraform

# Common tools with uncommon names
if has gnuwatch
then alias watch=gnuwatch
fi

# Change to a directory, and activate a virtualenv, if present
cde() {
    cd $1
    test -f ./.venv/bin/activate && . ./.venv/bin/activate
}
