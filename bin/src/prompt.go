// build with:
// GOOS=darwin GOARCH=amd64 go build -o ~/bin/Darwin-x86_64/prompt ~/bin/src/prompt.go
// GOOS=darwin GOARCH=arm64 go build -o ~/bin/Darwin-arm64/prompt ~/bin/src/prompt.go
// GOOS=linux GOARCH=amd64 go build -o ~/bin/Linux-x86_64/prompt ~/bin/src/prompt.go
// GOOS=linux GOARCH=arm64 go build -o ~/bin/Linux-aarch64/prompt ~/bin/src/prompt.go
// GOOS=openbsd GOARCH=amd64 go build -o ~/bin/OpenBSD-amd64/prompt ~/bin/src/prompt.go
package main

import (
	"fmt"
	"os"
	"os/user"
	"strings"
)

type Color string

var rich = false
var prompt = "$"
var userColor = Color("green")
var hostColor = Color("green")
var reset = Color("reset")

func rescue() {
	// Do something useful when encountering an unrecoverable error
	fmt.Printf("%s ", prompt)
	os.Exit(0)
}

func (c Color) ansi() string {
	if !rich {
		return ""
	}
	switch c {
	case Color("red"):
		return "\033[31m"
	case Color("green"):
		return "\033[32m"
	case Color("reset"):
		return "\033[0m"
	default:
		return ""
	}
}

func main() {
	var isRoot = os.Getuid() == 0
	if len(os.Args) >= 2 {
		prompt = os.Args[1]
	}
	if isRoot {
		prompt = "#"
		userColor = "red"
	}
	if os.Getenv("TERM") != "dumb" {
		// TODO: isatty(3)? termcap?
		rich = true
	}
	cwd, err := os.Getwd()
	if err != nil {
		rescue()
	}
	host, err := os.Hostname()
	if err != nil {
		rescue()
	}
	u, err := user.Current()
	if err != nil {
		rescue()
	}
	home := u.HomeDir
	if strings.HasPrefix(cwd, home) {
		cwd = "~" + cwd[len(home):]
	}
	if os.Getenv("SSH_CLIENT") != "" {
		hostColor = "red"
	}
	fmt.Printf(
		": %s%s%s@%s%s%s %s\n%s ",
		userColor.ansi(),
		u.Username,
		reset.ansi(),
		hostColor.ansi(),
		host,
		reset.ansi(),
		cwd,
		prompt,
	)
}
