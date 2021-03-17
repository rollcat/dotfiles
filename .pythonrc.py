# Define things commonly found useful in an interactive context
import base64
import collections
import contextlib
import datetime
import decimal
import errno
import functools
import getopt
import glob
import hashlib
import itertools
import json
import logging
import math
import operator
import os
import pprint
import random
import re
import socket
import struct
import subprocess
import sys
import tempfile
import time
import types
import typing as t
import urllib
import uuid


# Enable readline and tab completion
try:
    import readline
    import rlcompleter
    readline.parse_and_bind("tab: complete")
except ImportError:
    pass


# SI constants: decimal
kd = 1000
md = kd ** 2
gd = kd ** 3
td = kd ** 4
pd = kd ** 5
# Binary
kb = 1024
mb = kb ** 2
gb = kb ** 3
tb = kb ** 4
pb = kb ** 5

# Unit conversions
inch = 2.54  # cm
mile = 1.609  # km
lbs = pound = 0.453592  # kg


def group_by(xs, func):
    """Group elements in xs by key (from func).

    """
    tmp = {}
    for x in xs:
        key = func(x)
        tmp.setdefault(key, [])
        tmp[key].append(x)
    return tmp


def aspect_ratio(width: int, height: int) -> t.Tuple[int, int]:
    """Determine the aspect ratio for a pair of integers (a rectange).
    """
    gcd = math.gcd(width, height)
    return (width // gcd, height // gcd) 
