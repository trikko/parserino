#!/usr/bin/env python3
"""Remove header prototypes whose definition lives in the same D module.

After merging X.h and X.c into one module each function appears twice
(prototype + definition); D treats them as an overload set, which makes
error messages useless and is just noise. Run from `source`.
"""
import re, glob

PROTO = re.compile(r'^ ?(?:private )?(?:const\()?\w+\)?[*\s]+(\w+)\s*\([^;{}()]*(?:\([^()]*\)[^;{}()]*)*\)\s*;[ \t]*\n', re.M)
DEF = re.compile(r'^ ?(?:private )?(?:pragma\(inline[^)]*\) )?(?:const\()?\w+\)?[*\s]+(\w+)\s*\([^;{}]*\)\s*\{', re.M)

for f in glob.glob('parserino/lexbor/**/*.d', recursive=True):
    src = open(f).read()
    defined = {m.group(1) for m in DEF.finditer(src)}
    keywords = {'if', 'while', 'for', 'switch', 'return', 'foreach', 'sizeof', 'cast', 'assert'}

    def repl(m):
        name = m.group(1)
        if name in defined and name not in keywords:
            return ''
        return m.group(0)

    new = PROTO.sub(repl, src)
    if new != src:
        open(f, 'w').write(new)
