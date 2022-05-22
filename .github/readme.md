# rollcat's dotfiles

This is how I go about my digital life on Real Computers™.

To move in:

```shell
git init
git remote add github https://github.com/rollcat/dotfiles
git pull github master
```

Git will complain about overwriting existing files, like `.profile`.
Treat with `rm -f` and pull again.

For pushing changes, you probably want to use the SSH transport
instead:

```shell
git remote set-url github git@github.com:rollcat/dotfiles.git
```

## bin

There is a lot of small scripts in [bin](/bin).

Some are original. Some are borrowed. Some are simplistic remakes of
common utilities found on other operating systems or in third-party
packages, that I made to make my life less interesting when using very
different machines. Take what you like. (See licensing.)

There is some support for per os/arch statically compiled binaries.
Go is both wonderful, and really, really awful in this regard.

Many utilities are written in POSIX sh, or in Python 3 (3.6+), if the
shell feels inadequate.

## Supported systems and architectures

Regularly tested: macOS (arm64), OpenBSD (x86-64).

Less tested: Linux (x86-64, arm64), macOS (x86-64).

## `.profile`

Lots of environment variables are exported. Notably, `$PATH` has some
automagic detection for hidden/weird things, like `~/.gem/ruby/*/bin`,
`/Applications/**/bin`, `~/bin/$(uname -s)-$(uname -m)` etc.

## `.gitignore`

Everything is [`.gitignore`d](/.gitignore) with a `*`.
Use `git add -f` to track a file.

## License

Unless otherwise noted: <https://unlicense.org>

No attribution necessary, but if you do something cool with any of
this, drop me a line.
