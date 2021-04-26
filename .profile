# Set up the environment for any POSIX-compliant interactive shell.
umask 022

has() {
    which $@ 2>/dev/null >/dev/null
}

# Paths
export GOPATH=~/gocode

# Get os & arch. Arch is OS-specific, e.g.:
# Linux aarch64, Darwin x86_64, OpenBSD amd64
_os=$(uname -s)
_arch=$(uname -m)

# Detect paths which should be added to $PATH
_mkpath() {
    # Put our own ~/bin first.
    # Also pick a subdirectory with precompiled executables for our arch.
    echo ~/bin/${_os}-${_arch}
    echo ~/bin
    echo ~/.local/bin
    echo ~/.cargo/bin
    echo ~/.poetry/bin
    echo $GOPATH/bin

    if [ -d ~/.gem/ruby ]
    then find ~/.gem/ruby -maxdepth 2 -type d -name bin
    fi

    if [ -d /Applications ]
    then find /Applications -type d -name bin -maxdepth 3
    fi

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
    -ksh)
        export ENV=$HOME/.kshrc
        ;;
    mksh)
        export ENV=$HOME/.mkshrc
        ;;
esac

# urxvt's termcap may be unavailable on this system
case $TERM in
    rxvt-unicode-256color)
        export TERM=xterm-256color
        ;;
    rxvt*)
        export TERM=xterm
        ;;
esac

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
export PKG_CONFIG_PATH=~/.local/lib/pkgconfig
export PYTHONSTARTUP=~/.pythonrc.py
# NOTE: GOPATH belongs here, but we also need it for $PATH

# pyenv, rbenv, etc
export PYENV_ROOT="$HOME/.pyenv"
if has pyenv; then
    eval "$(pyenv init -)"
    if has pyenv-virtualenv-init; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi
if has rbenv; then
      eval "$(rbenv init -)"
fi

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_SCAN_SUGGEST=false

# Disable Microsoft's telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=1

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
p=$(which i3 dwm awesome cwm x-window-manager xterm 2>/dev/null | head -1)
[[ -n $p ]] && export WM=$p
unset p

# Aliases for interactive use
alias py=python3
alias ipy='python3 -m IPython'
alias tf=terraform
