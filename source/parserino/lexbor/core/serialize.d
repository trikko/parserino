module parserino.lexbor.core.serialize;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
import parserino.lexbor.core.str;

extern(C) @nogc nothrow:
__gshared:

// ---- serialize.h ----
/*
 * Copyright (C) 2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */



// ---- serialize.c ----
/*
 * Copyright (C) 2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_status_t lexbor_serialize_length_cb(const(lxb_char_t)* data, size_t length, void* ctx)
{
    *(cast(size_t*) ctx) += length;
    return LXB_STATUS_OK;
}

lxb_status_t lexbor_serialize_copy_cb(const(lxb_char_t)* data, size_t length, void* ctx)
{
    lexbor_str_t* str = cast(lexbor_str_t*) ctx;

    memcpy(str.data + str.length, data, length);
    str.length += length;

    return LXB_STATUS_OK;
}
