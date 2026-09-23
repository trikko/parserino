module parserino.lexbor.core.sbst;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import core.stdc.string;
public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- sbst.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lexbor_sbst_entry_static_t {
    lxb_char_t key;

    void* value;
    size_t value_len;

    size_t left;
    size_t right;
    size_t next;
}

/*
 * Inline functions
 */
 const(lexbor_sbst_entry_static_t)* lexbor_sbst_entry_static_find(const(lexbor_sbst_entry_static_t)* strt, const(lexbor_sbst_entry_static_t)* root, const(lxb_char_t) key)
{
    while (root != strt) {
        if (root.key == key) {
            return root;
        }
        else if (key > root.key) {
            root = &strt[root.right];
        }
        else {
            root = &strt[root.left];
        }
    }

    return null;
}
