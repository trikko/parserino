#!/usr/bin/env python3
"""Translate the needed subset of lexbor (C) into D modules.

Pipeline for every unit (X.h and/or X.c):
  1. strip #include lines (recorded, become D imports)
  2. hide object-like #defines with a body (they become D enums via ctod)
  3. run the C preprocessor with -imacros funcmacros.h so that function-like
     macros (many contain return/goto) are expanded in place
  4. restore the hidden #defines, run ctod
  5. merge header + source into one D module, fix module/imports
"""
import os, re, subprocess, sys, shutil

ROOT = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(ROOT, os.environ.get('LXB_SRC', 'pruned'))
WORK = os.path.join(ROOT, os.environ.get('LXB_WORK', 'work'))
OUT = os.path.join(ROOT, os.environ.get('LXB_OUT', 'dout'))
CTOD = os.path.expanduser('~/.dub/packages/ctod/1.0.5/ctod/build/ctod')

KEYWORDS = {'const', 'interface', 'in', 'module', 'import', 'version', 'debug',
            'function', 'delegate', 'alias', 'body', 'shared', 'unittest'}

SYS_IMPORTS = {
    'string.h': 'core.stdc.string', 'stdlib.h': 'core.stdc.stdlib',
    'stdio.h': 'core.stdc.stdio', 'stdarg.h': 'core.stdc.stdarg',
    'math.h': 'core.stdc.math', 'float.h': 'core.stdc.float_',
    'stdint.h': 'core.stdc.stdint', 'stddef.h': 'core.stdc.stddef',
    'limits.h': 'core.stdc.limits', 'ctype.h': 'core.stdc.ctype',
    'stdbool.h': None, 'memory.h': 'core.stdc.string', 'sanitizer/asan_interface.h': None, 'inttypes.h': 'core.stdc.inttypes',
}

units = [l.strip() for l in open(os.path.join(ROOT, 'units.txt')) if l.strip()]
unitset = set(units)
# units that are also a directory prefix of another unit -> package.d
packages = {u for u in units if any(v.startswith(u + '/') for v in units)}


def src_path(unit, ext):
    if unit == 'core/memory' and ext == '.c':
        return os.path.join(SRC, 'ports/posix/lexbor/core/memory.c')
    return os.path.join(SRC, unit + ext)


def dname(part):
    return part + '_' if part in KEYWORDS else part


def module_name(unit):
    return 'parserino.lexbor.' + '.'.join(dname(p) for p in unit.split('/'))


def out_file(unit):
    parts = [dname(p) for p in unit.split('/')]
    if unit in packages:
        return os.path.join(OUT, 'parserino', 'lexbor', *parts, 'package.d')
    return os.path.join(OUT, 'parserino', 'lexbor', *parts) + '.d'


# flags that select sections of the shared *_res.h tables: enable them all
RES_FLAGS = set()
for u in units:
    p = src_path(u, '.h')
    if os.path.exists(p):
        txt = open(p).read()
        for m in re.finditer(r'#ifdef\s+(\w+)\s*\n\s*#ifndef\s+\1_ENABLED', txt):
            RES_FLAGS.add(m.group(1))


def join_continuations(text):
    return re.sub(r'\\\n', ' ', text)


def preprocess(unit, ext):
    text = open(src_path(unit, ext)).read()
    includes, sysincludes = [], []

    def inc(m):
        includes.append(m.group(1))
        return ''

    def sysinc(m):
        sysincludes.append(m.group(1))
        return ''

    text = re.sub(r'^\s*#\s*include\s+"lexbor/([^"]+)\.h"\s*$', inc, text, flags=re.M)
    text = re.sub(r'^\s*#\s*include\s+<([^>]+)>\s*$', sysinc, text, flags=re.M)
    text = re.sub(r'^\s*#\s*error.*$', '', text, flags=re.M)

    # join continuation lines only inside preprocessor directives
    lines = text.split('\n')
    out, buf = [], None
    for line in lines:
        if buf is not None:
            buf += ' ' + line.rstrip('\\')
            if not line.endswith('\\'):
                out.append(buf); buf = None
            continue
        if line.lstrip().startswith('#') and line.endswith('\\'):
            buf = line.rstrip('\\')
            continue
        out.append(line)
    lines = out

    guard = None
    m = re.search(r'^\s*#\s*ifndef\s+(\w+_H)\s*$', text, re.M)
    if m and ext == '.h':
        guard = m.group(1)

    res = []
    for line in lines:
        m = re.match(r'^\s*#\s*define\s+(\w+)(.*)$', line)
        if m and not m.group(2).startswith('('):
            name, body = m.group(1), m.group(2).strip()
            if name == guard or name.endswith('_ENABLED') or re.match(r'LXB_\w+_CONST_VERSION_[0-9A-F]+$', name):
                res.append(line)
                continue
            if name in ('LXB_API', 'LXB_EXTERN', 'lxb_inline'):
                continue
            if body == '':
                res.append(line)
                continue
            res.append('%%define ' + name + ' ' + body)
            continue
        res.append(line)
    text = '\n'.join(res)

    os.makedirs(os.path.join(WORK, os.path.dirname(unit)), exist_ok=True)
    tmp_in = os.path.join(WORK, unit + ext + '.in')
    open(tmp_in, 'w').write(text)
    args = ['gcc', '-E', '-C', '-nostdinc', '-x', 'c', '-DLEXBOR_STATIC',
            '-imacros', os.path.join(ROOT, 'funcmacros.h')]
    args += ['-D' + f for f in sorted(RES_FLAGS)]
    args += [tmp_in]
    r = subprocess.run(args, capture_output=True, text=True)
    if r.returncode != 0:
        print('CPP FAIL', unit, ext, r.stderr[:2000], file=sys.stderr)
    pre = r.stdout.replace('%%define', '#define')
    pre = re.sub(r'^# \d+ .*$\n?', '', pre, flags=re.M)
    pre = re.sub(r'\n{3,}', '\n\n', pre)
    # C++ guard leftovers
    dst = os.path.join(WORK, unit + ext)
    open(dst, 'w').write(pre)
    return dst, includes, sysincludes


def run_ctod(path):
    r = subprocess.run([CTOD, path], capture_output=True, text=True)
    d = path[:-2] + '.d'
    if not os.path.exists(d):
        print('CTOD FAIL', path, r.stdout, r.stderr, file=sys.stderr)
        return ''
    body = open(d).read()
    os.remove(d)
    return body


HEADER_RE = re.compile(r'^module [^;]+;\s*\n(@nogc nothrow:\s*\n)?(extern\(C\): __gshared:\s*\n)?')


def strip_ctod_header(body):
    body = HEADER_RE.sub('', body, count=1)
    # ctod emits imports for includes: we removed includes, but it may still
    # emit core.stdc ones; drop all imports and regenerate them
    body = re.sub(r'^\s*(public )?import [^;]+;\s*$\n?', '', body, flags=re.M)
    return body


def imports_for(includes, sysincludes, public, self_unit):
    lines = []
    seen = set()
    for s in sysincludes:
        mod = SYS_IMPORTS.get(s, 'MISSING_' + s)
        if mod and mod not in seen:
            seen.add(mod)
            lines.append(('public ' if public else '') + 'import ' + mod + ';')
    for inc in includes:
        if inc == self_unit or inc in seen:
            continue
        seen.add(inc)
        if inc not in unitset:
            lines.append('// import ' + inc + ' (not ported)')
            continue
        lines.append(('public ' if public else '') + 'import ' + module_name(inc) + ';')
    return lines


def convert(unit):
    parts = []
    imports = []
    for ext in ('.h', '.c'):
        if not os.path.exists(src_path(unit, ext)):
            continue
        path, incs, sysincs = preprocess(unit, ext)
        body = run_ctod(path)
        imports += imports_for(incs, sysincs, ext == '.h', unit)
        parts.append('\n// ---- ' + os.path.basename(unit) + ext + ' ----\n' + strip_ctod_header(body))
    dedup = []
    for i in imports:
        if i not in dedup and ('public ' + i) not in dedup:
            dedup.append(i)
    hdr = ['module ' + module_name(unit) + ';', '',
           '// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.',
           '// Original author: Alexander Borisov <borisov@lexbor.com>', '']
    hdr += dedup
    hdr += ['', 'extern(C) @nogc nothrow:', '__gshared:', '']
    dst = out_file(unit)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    open(dst, 'w').write('\n'.join(hdr) + ''.join(parts))


if __name__ == '__main__':
    sel = sys.argv[1:] or units
    shutil.rmtree(WORK, ignore_errors=True)
    if not sys.argv[1:]:
        shutil.rmtree(OUT, ignore_errors=True)
    for u in sel:
        convert(u)
    print('converted', len(sel), 'units; res flags:', ' '.join(sorted(RES_FLAGS)))
