module parserino.lexbor.core.types;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import core.stdc.stdint;

extern(C) @nogc nothrow:
__gshared:

// ---- types.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
/* Inline */

/* Simple types */
alias lxb_codepoint_t = uint;
alias lxb_char_t = ubyte;
alias lxb_status_t = uint;

/* Callbacks */
alias lexbor_callback_f = lxb_status_t function(const(lxb_char_t)* buffer, size_t size, void* ctx);

/* D port: C char array initialised from a string literal (NUL terminated). */
extern(D) enum lxb_char_t[s.length + 1] lexbor_carray(string s) = () {
    lxb_char_t[s.length + 1] r = 0;
    foreach (i, c; s) r[i] = c;
    return r;
}();
