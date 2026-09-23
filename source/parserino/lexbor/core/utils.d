module parserino.lexbor.core.utils;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- utils.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
 size_t lexbor_utils_power(size_t t, size_t k);

 size_t lexbor_utils_hash_hash(const(lxb_char_t)* key, size_t key_size);

// D port: implementation not needed by parserino, not ported.
