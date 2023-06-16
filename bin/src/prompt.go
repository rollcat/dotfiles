package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/user"
	"path"
	"strings"
)

type Color string

var rich = false
var prompt = "$"
var userColor = Color("green")
var hostColor = Color("green")
var reset = Color("reset")

var cwd = "."
var u *user.User = nil
var gitRoot = ""

func init() {
	var err error
	u, err = user.Current()
	if err != nil {
		u = &user.User{Username: "?", HomeDir: ""}
	}
	cwd, err = os.Getwd()
	gitRoot = getGitRoot()
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

func abbrevHome(s string) string {
	if strings.HasPrefix(s, u.HomeDir) {
		s = "~" + strings.TrimPrefix(s, u.HomeDir)
	}
	return s
}

func pythonVirtualEnv() string {
	venv := path.Base(path.Dir(path.Clean(os.Getenv("VIRTUAL_ENV"))))
	if venv == "." {
		return ""
	}
	return venv
}

func getGitRoot() string {
	r := cwd
	for r != "/" && r != "." {
		_, err := os.Stat(path.Join(r, ".git"))
		if err == nil {
			return r
		}
		r = path.Dir(r)
	}
	return ""
}

func gitBranch() string {
	if gitRoot == "" {
		return ""
	}
	data, err := ioutil.ReadFile(path.Join(gitRoot, ".git/HEAD"))
	if err != nil {
		return ""
	}
	s := string(data)
	s = strings.TrimSuffix(s, "\n")
	if strings.HasPrefix(s, "ref: refs/heads/") {
		s = strings.TrimPrefix(s, "ref: refs/heads/")
	}
	return s
}

func nixShell() string {
	return os.Getenv("IN_NIX_SHELL")
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
	host, err := os.Hostname()
	if err != nil {
		host = "?"
	}
	if os.Getenv("SSH_CLIENT") != "" {
		hostColor = "red"
	}
	venv := pythonVirtualEnv()
	if venv != "" {
		venv = fmt.Sprintf("[venv=%s] ", venv)
	}
	gitb := gitBranch()
	if gitb != "" {
		gitb = fmt.Sprintf("[git=%s] ", gitb)
	}
	nix := nixShell()
	if nix != "" {
		nix = fmt.Sprintf("[nix=%s] ", nix)
	}

	fmt.Printf(
		": %s%s%s@%s%s%s %s%s%s%s\n%s ",
		userColor.ansi(),
		u.Username,
		reset.ansi(),
		hostColor.ansi(),
		host,
		reset.ansi(),
		gitb,
		nix,
		venv,
		abbrevHome(cwd),
		prompt,
	)
}
