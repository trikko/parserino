#!/usr/bin/env python3
"""Generic source-level fixes applied to the raw ctod output (before
fixconflicts.py). Run from the directory that contains `parserino/lexbor`.

Every rule here comes from an error class found while porting; one-off fixes
that are specific to a single function live in `manual.py`.
"""
import glob, os, re, sys

ROOT = 'parserino/lexbor'
USED_C = sys.argv[1] if len(sys.argv) > 1 else None   # list of ported .c files


def files():
    return glob.glob(ROOT + '/**/*.d', recursive=True)


def edit(path, fn):
    s = open(path).read()
    n = fn(s)
    if n != s:
        open(path, 'w').write(n)


def all_files(fn):
    for f in files():
        edit(f, fn)


# ---------------------------------------------------------------- per file
def fix_core_base(s):
    s = s.replace('public import core.stdc.limits;',
                  'public import core.stdc.limits;\npublic import core.stdc.config;\npublic import core.stdc.stdint;', 1)
    return s


def fix_version_strings(s):
    # enum X_VERSION_STRING = LEXBOR_STRINGIZE(X_MAJOR) "." ... -> literal
    def repl(m):
        name, pfx = m.group(1), m.group(2)
        vals = []
        for part in ('MAJOR', 'MINOR', 'PATCH'):
            v = re.search(r'enum ' + pfx + '_' + part + r' = (\d+);', s)
            vals.append(v.group(1) if v else '0')
        return 'enum ' + name + ' = "' + '.'.join(vals) + '";'
    return re.sub(r'enum ((\w+)_VERSION_STRING) = LEXBOR_STRINGIZE.*;', repl, s)


def fix_print(s):
    s = s.replace('va_arg(va, const char_ *)', 'va_arg!(const(char)*)(va)')
    s = s.replace('va_arg(va, lexbor_str_t *)', 'va_arg!(lexbor_str_t*)(va)')
    s = re.sub(r'^enum LXB_PRINT_ERROR = .*$', 'enum size_t LXB_PRINT_ERROR = cast(size_t) -1;', s, flags=re.M)
    return s


def fix_swar(s):
    s = re.sub(r'^enum LEXBOR_SWAR_ONES = .*$', 'enum size_t LEXBOR_SWAR_ONES = (~(cast(size_t) 0) / 0xFF);', s, flags=re.M)
    s = re.sub(r'^enum LEXBOR_SWAR_IS_LITTLE_ENDIAN = .*$',
               'version (LittleEndian) enum LEXBOR_SWAR_IS_LITTLE_ENDIAN = true; else enum LEXBOR_SWAR_IS_LITTLE_ENDIAN = false;', s, flags=re.M)
    return s


def fix_def(s):
    return s.replace('enum LEXBOR_MEM_ALIGN_STEP = sizeof(void *);', 'enum LEXBOR_MEM_ALIGN_STEP = (void*).sizeof;')


def fix_hash(s):
    if 'lexbor_hash_short_str' in s:
        return s
    return s.replace('struct lexbor_hash {', '''/* D port: CTFE helper for static tables using the inline short string. */
extern(D) lxb_char_t[LEXBOR_HASH_SHORT_SIZE + 1] lexbor_hash_short_str(string s) pure
{
    typeof(return) r = 0;
    foreach (i, c; s) r[i] = c;
    return r;
}

struct lexbor_hash {''', 1)


def fix_types(s):
    if 'lexbor_carray' in s:
        return s
    return s + '''
/* D port: C char array initialised from a string literal (NUL terminated). */
extern(D) enum lxb_char_t[s.length + 1] lexbor_carray(string s) = () {
    lxb_char_t[s.length + 1] r = 0;
    foreach (i, c; s) r[i] = c;
    return r;
}();
'''


PER_FILE = {
    'core/base.d': [fix_core_base],
    'core/print.d': [fix_print],
    'core/swar.d': [fix_swar],
    'core/def.d': [fix_def],
    'core/hash.d': [fix_hash],
    'core/types.d': [fix_types],
}


# ------------------------------------------------------------ all files
def generic(s):
    # union designated initializers in the generated tables
    s = re.sub(r'\{u:short_str: ("[^"]*"),', r'{u: {short_str: lexbor_hash_short_str(\1)},', s)
    s = re.sub(r'\{u:long_str: (cast\(lxb_char_t\*\) "[^"]*"),', r'{u: {long_str: \1},', s)
    # nested designated initializer `a:b: {..}` -> `a: {b: {..}}`
    s = re.sub(r'^(\s*)(\w+):(\w+): (\{[^{}]*\}),', r'\1\2: {\3: \4},', s, flags=re.M)
    # string literal stored in a `void *` table field
    s = re.sub(r'\{(0x[0-9a-f]+), ("(?:\\x[0-9a-f]{2}|[^"\\])*")', r'{\1, cast(void*) \2.ptr', s)
    # macro artefacts: `(cb)(...)` and `(end) &&` look like C casts to ctod
    s = s.replace('cast(cb)(', 'cb(')
    s = re.sub(r'< cast\((\w+)\) &&', r'< (\1) &&', s)
    # C casts left inside #define bodies
    s = re.sub(r'(?<!cast)\((uint32_t|size_t|uint64_t|int)\) (\d)', r'cast(\1) \2', s)
    # `out` is a D keyword
    s = re.sub(r'\bgoto out;', 'goto out_;', s)
    s = re.sub(r'^(\s*)out:', r'\1out_:', s, flags=re.M)
    # sizeof in expanded macros
    s = re.sub(r'sizeof\(("(?:\\.|[^"\\])*")\) - 1', r'\1.length', s)
    s = re.sub(r'cast\(lxb_char_t\*\) \(("(?:\\.|[^"\\])*")\)', r'cast(lxb_char_t*) \1.ptr', s)
    s = s.replace('sizeofcast(size_t)', 'size_t.sizeof')
    s = re.sub(r'\bsizeof\(([A-Za-z_]\w*)\)', r'\1.sizeof', s)
    s = re.sub(r'\bsizeof\(([A-Za-z_]\w*) ?\*\)', r'(\1*).sizeof', s)
    s = re.sub(r'\bsizeof\(\*([A-Za-z_][\w.>-]*)\)', r'(*\1).sizeof', s)
    s = s.replace('.sizeof.ptr', '.sizeof')
    # C char arrays initialised from string literals
    s = re.sub(r'^(\s*(?:static |private )?const\(lxb_char_t\)\[[0-9]+\] \w+ = )("[^"]*");', r'\1lexbor_carray!\2;', s, flags=re.M)
    # `T x = {0};` zero initialisation
    s = re.sub(r'^(\s*)(lxb_\w+_t|lexbor_\w+_t) (\w+) = \{0\};', r'\1\2 \3; // C: = {0}', s, flags=re.M)
    return s


def unprivate_res(s):
    # tables from the C *_res.h headers are shared between modules
    s = re.sub(r'^private ((static )?const)', r'\1', s, flags=re.M)
    s = re.sub(r'^private (lxb_|lexbor_)', r'\1', s, flags=re.M)
    s = re.sub(r'^private (\w+\[)', r'\1', s, flags=re.M)
    return s


def strip_unused_impl(used):
    """Drop the .c part of modules whose implementation parserino doesn't need."""
    for f in files():
        s = open(f).read()
        m = re.search(r'\n// ---- (\w+)\.c ----\n', s)
        if not m:
            continue
        unit = os.path.relpath(f, ROOT)[:-2]
        if unit.endswith('/package'):
            unit = unit[:-8]
        unit = unit.replace('const_', 'const').replace('interface_', 'interface')
        if unit not in used:
            s = s[:m.start()] + '\n// D port: implementation not needed by parserino, not ported.\n'
            open(f, 'w').write(s)


def main():
    for rel, fns in PER_FILE.items():
        p = os.path.join(ROOT, rel)
        if os.path.exists(p):
            for fn in fns:
                edit(p, fn)
    all_files(lambda s: fix_version_strings(generic(s)))
    for f in files():
        if 'res' in os.path.basename(f):
            edit(f, unprivate_res)
    if USED_C:
        used = {l.strip()[:-2] for l in open(USED_C) if l.strip()}
        used = {('core/memory' if u.startswith('ports/') else u) for u in used}
        strip_unused_impl(used)


main()
