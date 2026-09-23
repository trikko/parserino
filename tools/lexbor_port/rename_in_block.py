#!/usr/bin/env python3
"""rename_in_block.py FILE LINE NAME NEW: rename NAME to NEW from LINE to the
end of the enclosing { } block (used to fix C block-scope shadowing)."""
import re, sys
f, ln, name, new = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
lines = open(f).read().split('\n')
depth = 0
for i in range(ln - 1, len(lines)):
    s = lines[i]
    out = re.sub(r'(?<![\w.])' + name + r'\b', new, s)
    for ch in s:
        if ch == '{': depth += 1
        elif ch == '}': depth -= 1
    if depth < 0:
        # the closing line of the block: rename only before the brace
        idx = s.rfind('}')
        out = re.sub(r'(?<![\w.])' + name + r'\b', new, s[:idx]) + s[idx:]
        lines[i] = out
        break
    lines[i] = out
open(f, 'w').write('\n'.join(lines))
