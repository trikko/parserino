# lexbor → D port tooling

These scripts produced the first version of `source/parserino/lexbor/` from
lexbor commit `7fb22cf5664a331d7c24b113489e566767c9c25a` (the subset parserino
needs: core, tag, ns, dom, html, css syntax/selectors, selectors). From now on
the D code is maintained by hand; the scripts are kept for reference.

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
