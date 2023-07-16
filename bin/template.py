#!/usr/bin/env python3
import getopt
import sys
import typing as t


def err(
    *args: object,
    sep: t.Optional[str] = None,
    end: t.Optional[str] = None,
) -> None:
    print(*args, file=sys.stderr, sep=sep, end=end)


def show_usage() -> None:
    err(f"Usage: {sys.argv[0]} [-h]")


def show_help() -> None:
    show_usage()
    err("CHANGEME: This is a template for a Python script.")
    err("Options:")
    err("    -h, --help  Show this help and exit")


def main() -> None:
    try:
        opts, args = getopt.getopt(sys.argv[1:], "h", ["help"])
    except getopt.GetoptError as e:
        err(e)
        show_usage()
        exit(2)
    for flag, opt in opts:
        if flag in ("-h", "--help"):
            show_help()
            exit()
        else:
            raise RuntimeError(flag)

    # Your script goes here.

    return


if __name__ == "__main__":
    main()
