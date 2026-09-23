# lexbor → D port tooling

These scripts produced `source/parserino/lexbor/` from lexbor master
`e6c068fc95fd2952aaf253e5a8e5beeb8b36d072` (2026-09-22), limited to the subset
parserino needs (`used_c.txt`: core, tag, ns, dom, html, css syntax/selectors,
selectors). CSS stylesheet/property code is not ported: `css/state.c` was
trimmed to the generic parser states and `lxb_css_syntax_parse_list_rules()` /
`lxb_css_syntax_parse_declarations()` were removed before translating.

The D code is now maintained by hand (phase 3 will diverge from lexbor); the
scripts are kept only as a record of how it was produced.

0. `postprocess.py`: generic textual fixes on the raw ctod output.
1. `convert.py`: C preprocessor expands only function-like macros
   (`funcmacros.h`), then [ctod](https://github.com/dkorpel/ctod) translates
   each `.h`/`.c` pair into one D module.
2. `fixconflicts.py`: iterates dmd diagnostics and fixes the mechanical
   C→D differences (struct tag namespace, `&function` in initializers,
   implicit `void*` conversions, static-array decay, missing imports).
3. `dropprotos.py`: removes prototypes duplicated by a definition in the
   same module.
4. `rename_in_block.py`: helper to fix C block-scope shadowing.

Everything else was fixed by hand (search for `D port:` comments).
