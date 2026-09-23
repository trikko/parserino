#!/usr/bin/env python3
"""Iteratively fix the typical C-namespace conflicts in the ctod output.

* `function F conflicts with struct F` / enum: C keeps struct/enum tags in a
  separate namespace. The tag is renamed to `F_` (the `_t` alias keeps working).
* `variable V conflicts with variable V at L`: the header `extern` declaration
  (merged in the same module as the definition) is removed.
Run from the `source` directory.
"""
import re, subprocess, sys, glob

CALL = re.compile(r'^(\S+\.d)\((\d+)\): Error: none of the overloads of `(\w+)` are callable using argument types `\(\)`')
CALL2 = re.compile(r'^(\S+\.d)\((\d+)\): Error: function `(?:[\w]+\.)*(\w+)(?:\(.*)?` is not callable using argument types `\(\)`')
ASTYPE = re.compile(r'^(\S+\.d)\((\d+)\): Error: function `(?:[\w]+\.)*(\w+)` is used as a type')
UNDEF = re.compile(r'^(\S+\.d)\((\d+)\): Error: undefined identifier `(\w+)`')
VOIDCONV = re.compile(r'^(\S+\.d)\((\d+)\): Error: cannot implicitly convert (?:expression `.*` of type )?`(const\()?void\)?\*` to `([^`]+)`')
VOIDRET = re.compile(r'^(\S+\.d)\((\d+)\): Error: return value `.*` of type `(const\()?void\)?\*` does not match return type `([^`]+)`')
PASSARG = re.compile(r'^(\S+\.d)\((\d+)\):\s+cannot pass argument `(.+)` of type `([^`]+)` to parameter `(.+) \w+`$')
EXPRCONV = re.compile(r'^(\S+\.d)\((\d+)\): Error: (?:cannot implicitly convert expression|return value) `(.+)` of type `([^`]+)` (?:to|does not match return type) `([^`]+)`')
PLAINCONV = re.compile(r'^(\S+\.d)\((\d+)\): Error: cannot implicitly convert `([^`]+)` to `([^`]+)`$')
ERR = re.compile(r'^(\S+\.d)\((\d+)\): Error: (\w+) `([\w.]+)` conflicts with (\w+) `([\w.]+)` at (\S+\.d)\((\d+)\)')


def compile_errors():
    files = glob.glob('parserino/lexbor/**/*.d', recursive=True)
    r = subprocess.run(['dmd', '-o-', '-verrors=0', '-I.'] + files, capture_output=True, text=True)
    return r.stderr.splitlines()


STDC = {'uintptr_t': 'core.stdc.stdint', 'intptr_t': 'core.stdc.stdint', 'uint8_t': 'core.stdc.stdint',
        'uint16_t': 'core.stdc.stdint', 'uint32_t': 'core.stdc.stdint', 'uint64_t': 'core.stdc.stdint',
        'int64_t': 'core.stdc.stdint', 'int32_t': 'core.stdc.stdint', 'SIZE_MAX': 'core.stdc.stdint',
        'memcpy': 'core.stdc.string', 'memset': 'core.stdc.string', 'memcmp': 'core.stdc.string',
        'strlen': 'core.stdc.string', 'memmove': 'core.stdc.string', 'c_long': 'core.stdc.config',
        'c_ulong': 'core.stdc.config', 'va_list': 'core.stdc.stdarg'}

DECL_RES = [re.compile(r'^\s*(?:struct|union|enum) (\w+)', re.M),
            re.compile(r'^\s*alias (\w+) =', re.M),
            re.compile(r'^\s*enum (?:\w+ )?(\w+) =', re.M),
            re.compile(r'^\s*(?:private )?(?:extern )?[\w()*\[\] ]*?[\w)*\]] \**(\w+)\s*\(', re.M),
            re.compile(r'^\s*(?:const\()?[\w]+\)?\**(?:\[[^\]]*\])? (\w+) = ', re.M)]


def module_of(path):
    m = path[:-2].replace('/', '.')
    if m.endswith('.package'):
        m = m[:-8]
    return m


def symbol_index():
    idx = {}
    for f in glob.glob('parserino/lexbor/**/*.d', recursive=True):
        src = open(f).read()
        for r in DECL_RES:
            for m in r.finditer(src):
                idx.setdefault(m.group(1), module_of(f))
    return idx


def add_import(f, mod):
    src = open(f).read()
    if re.search(r'^(public )?import ' + re.escape(mod) + ';', src, re.M) or module_of(f) == mod:
        return False
    src = re.sub(r'^(module [^;]+;\n)', r'\1\nimport ' + mod + ';', src, count=1)
    open(f, 'w').write(src)
    return True


def void_funcs():
    names = set()
    r = re.compile(r'^\s*(?:private )?(?:const\()?void\)?\* (\w+)\(', re.M)
    for f in glob.glob('parserino/lexbor/**/*.d', recursive=True):
        names.update(m.group(1) for m in r.finditer(open(f).read()))
    names.update(['memchr', 'malloc', 'calloc', 'realloc', 'memcpy', 'memmove', 'memset'])
    return names


def main():
    vf = void_funcs()
    for _ in range(50):
        changed = False
        edits = {}
        idx = None
        for line in compile_errors():
            mu = UNDEF.match(line)
            if mu:
                name = mu.group(3)
                if idx is None:
                    idx = symbol_index()
                mod = STDC.get(name) or idx.get(name)
                if mod and add_import(mu.group(1), mod):
                    changed = True
                continue
            mp = PASSARG.match(line)
            if mp:
                f, ln, arg, aty, pty = mp.groups()
                arg = re.sub(r'\(\*(\w+)\)\.', r'\1.', arg)
                pty = re.sub(r'^(return )?(scope )?', '', pty)
                if re.search(r'\[\d+\]\)?$', aty) or aty == 'string':
                    rep = arg + '.ptr'
                else:
                    rep = 'cast(' + pty + ') ' + arg
                edits.setdefault(f, set()).add(('arg', (int(ln), arg, rep)))
                continue
            me = EXPRCONV.match(line)
            if me:
                f, ln, ex, aty, bty = me.groups()
                ex = re.sub(r'\(\*(\w+)\)\.', r'\1.', ex)
                if not (aty in ('int', 'uint', 'long', 'ulong') and bty.endswith('*')) and not aty.startswith('string'):
                    if re.search(r'\[\d+\]\)?$', aty) and bty.endswith('*'):
                        rep = ex + '.ptr'
                    else:
                        rep = 'cast(' + bty + ') (' + ex + ')'
                    if len(ex) < 80 and '...' not in ex:
                        edits.setdefault(f, set()).add(('arg', (int(ln), ex, rep)))
                        continue
            mq = PLAINCONV.match(line)
            if mq:
                edits.setdefault(mq.group(1), set()).add(('assigncast', (int(mq.group(2)), mq.group(4))))
            mv = VOIDCONV.match(line) or VOIDRET.match(line)
            if mv:
                edits.setdefault(mv.group(1), set()).add(('vcast', (int(mv.group(2)), mv.group(4))))
                continue
            mt = ASTYPE.match(line)
            if mt:
                edits.setdefault(mt.group(1), set()).add(('astype', (int(mt.group(2)), mt.group(3))))
                continue
            mc = CALL.match(line) or CALL2.match(line)
            if mc:
                edits.setdefault(mc.group(1), set()).add(('addr', (int(mc.group(2)), mc.group(3))))
                continue
            m = ERR.match(line)
            if not m:
                continue
            f1, l1, k1, n1, k2, n2, f2, l2 = m.groups()
            name = n1.split('.')[-1]
            if k1 == 'function' and k2 in ('struct', 'enum', 'union'):
                edits.setdefault(f2, set()).add(('tag', name))
            elif k1 == 'variable' and k2 == 'variable':
                edits.setdefault(f2, set()).add(('extern', int(l2)))
        for f, es in edits.items():
            lines = open(f).read().split('\n')
            src = '\n'.join(lines)
            for kind, val in es:
                if kind == 'addr':
                    ln, fn = val
                    new = re.sub(r'(?<![&\w.])' + fn + r'\b(?!\s*\()', '&' + fn, lines[ln - 1])
                    if new != lines[ln - 1]:
                        lines[ln - 1] = new
                        changed = True
                if kind == 'arg':
                    ln, arg, rep = val
                    pat = r'(?<![\w.])(?<!cast\()' + re.escape(arg) + r'(?![\w(\[]|\.ptr)'
                    for k in range(ln - 1, min(ln + 6, len(lines))):
                        new = re.sub(pat, rep.replace('\\', '\\\\'), lines[k], count=1)
                        if new != lines[k]:
                            lines[k] = new
                            changed = True
                            break
                if kind == 'assigncast':
                    ln, ty = val
                    l0 = lines[ln - 1]
                    if 'cast(' + ty + ')' not in l0:
                        new = re.sub(r'(?<![=!<>+\-*/&|^%])=(?!=)\s*', '= cast(' + ty.replace('\\', '') + ') ', l0, count=1)
                        if new != l0:
                            lines[ln - 1] = new
                            changed = True
                if kind == 'vcast':
                    ln, ty = val
                    src_line = lines[ln - 1]
                    for fn in sorted(vf, key=len, reverse=True):
                        new = re.sub(r'(?<![\w.)])(?<!cast\(' + re.escape(ty) + r'\) )\b(' + fn + r'\s*\()', 'cast(' + ty + r') \1', src_line, count=1)
                        if new != src_line:
                            lines[ln - 1] = new
                            changed = True
                            break
                if kind == 'astype':
                    ln, fn = val
                    new = re.sub(r'\b' + fn + r'\b(?!\s*\()', fn + '_', lines[ln - 1])
                    if new != lines[ln - 1]:
                        lines[ln - 1] = new
                        changed = True
                if kind == 'extern':
                    ln = lines[val - 1]
                    if ln.lstrip().startswith('extern '):
                        lines[val - 1] = '// ' + ln
                        changed = True
            src = '\n'.join(lines)
            for kind, val in es:
                if kind == 'tag':
                    new = re.sub(r'\b(struct|enum|union) ' + val + r'\b', r'\1 ' + val + '_', src)
                    new = re.sub(r'(alias \w+ = )' + val + r';', r'\g<1>' + val + '_;', new)
                    new = re.sub(r'^(alias ' + val + r'_t = )' + val + ';', r'\g<1>' + val + '_;', new, flags=re.M)
                    if new != src:
                        src = new
                        changed = True
            open(f, 'w').write(src)
        if not changed:
            break
    errs = [l for l in compile_errors() if 'Error' in l]
    print(len(errs), 'errors left')


main()
