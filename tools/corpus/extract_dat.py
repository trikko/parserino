#!/usr/bin/env python3
"""Write the #data section of each test of the tree construction .dat files as a separate file.

Usage: extract_dat.py <dir with .dat files> <output dir>
Only document tests are written (fragment tests need a context element).
"""
import os
import sys


HEADERS = {b"#errors", b"#new-errors", b"#document-fragment", b"#script-on", b"#script-off", b"#document"}


def tests(path):
    """The (data, is_fragment) of each test in a .dat file."""
    with open(path, "rb") as f:
        lines = f.read().split(b"\n")

    data, section, fragment = None, None, False
    for line in lines + [b"#data"]:
        if line == b"#data":
            if data is not None:
                yield b"\n".join(data), fragment
            data, section, fragment = [], "data", False
        elif line in HEADERS and section is not None:
            section = line[1:].decode()
            if section == "document-fragment":
                fragment = True
        elif section == "data":
            data.append(line)


def main():
    src, dst = sys.argv[1], sys.argv[2]
    count = 0
    for name in sorted(os.listdir(src)):
        if not name.endswith(".dat"):
            continue
        for i, (data, fragment) in enumerate(tests(os.path.join(src, name))):
            if fragment:
                continue
            out = os.path.join(dst, "h5_%s_%04d.html" % (name[:-4], i))
            with open(out, "wb") as f:
                f.write(data)
            count += 1
    print("%d tests extracted" % count)


if __name__ == "__main__":
    main()
