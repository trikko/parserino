module parserino.lexbor.css.css;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.base;
public import parserino.lexbor.css.log;
public import parserino.lexbor.core.serialize;
public import parserino.lexbor.css.parser;
public import parserino.lexbor.css.state;
public import parserino.lexbor.css.syntax.tokenizer.error;
public import parserino.lexbor.css.syntax.tokenizer;
public import parserino.lexbor.css.syntax.token;
public import parserino.lexbor.css.syntax.parser;
public import parserino.lexbor.css.syntax.anb;
public import parserino.lexbor.css.selectors.selectors;
public import parserino.lexbor.css.selectors.selector;
public import parserino.lexbor.css.selectors.state;
public import parserino.lexbor.css.selectors.pseudo;

extern(C) @nogc nothrow:
__gshared:

// ---- css.h ----
/*
 * Copyright (C) 2020-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */


// ---- css.c ----
/*
 * Copyright (C) 2021-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

struct lxb_css_str_ctx_t {
    lexbor_str_t* str;
    lexbor_mraw_t* mraw;
}



lxb_css_memory_t* lxb_css_memory_create()
{
    return cast(lxb_css_memory_t*) lexbor_calloc(1, lxb_css_memory_t.sizeof);
}

lxb_status_t lxb_css_memory_init(lxb_css_memory_t* memory, size_t prepare_count)
{
    lxb_status_t status = void;

    static const(size_t) size_mem = ((lxb_css_selector_t.sizeof) > (lxb_css_selector_list_t.sizeof) ? (lxb_css_selector_t.sizeof) : (lxb_css_selector_list_t.sizeof));

    if (memory == null) {
        return LXB_STATUS_ERROR_INCOMPLETE_OBJECT;
    }

    if (prepare_count < 64) {
        prepare_count = 64;
    }

    if (memory.objs == null) {
        memory.objs = lexbor_dobject_create();
        status = lexbor_dobject_init(memory.objs, prepare_count, size_mem);
        if (status != LXB_STATUS_OK) {
            goto failed;
        }
    }

    if (memory.tree == null) {
        prepare_count = prepare_count * 96;

        memory.tree = lexbor_mraw_create();
        status = lexbor_mraw_init(memory.tree, prepare_count);
        if (status != LXB_STATUS_OK) {
            goto failed;
        }
    }

    if (memory.mraw == null) {
        memory.mraw = lexbor_mraw_create();
        status = lexbor_mraw_init(memory.mraw, 4096);
        if (status != LXB_STATUS_OK) {
            goto failed;
        }
    }

    memory.ref_count = 1;

    return LXB_STATUS_OK;

failed:

    cast(void) lxb_css_memory_destroy(memory, false);

    return status;
}

void lxb_css_memory_clean(lxb_css_memory_t* memory)
{
    if (memory.objs != null) {
        lexbor_dobject_clean(memory.objs);
    }

    if (memory.mraw != null) {
        lexbor_mraw_clean(memory.mraw);
    }

    if (memory.tree != null) {
        lexbor_mraw_clean(memory.tree);
    }
}

lxb_css_memory_t* lxb_css_memory_destroy(lxb_css_memory_t* memory, bool self_destroy)
{
    if (memory == null) {
        return null;
    }

    if (memory.objs != null) {
        memory.objs = lexbor_dobject_destroy(memory.objs, true);
    }

    if (memory.mraw != null) {
        memory.mraw = lexbor_mraw_destroy(memory.mraw, true);
    }

    if (memory.tree != null) {
        memory.tree = lexbor_mraw_destroy(memory.tree, true);
    }

    if (self_destroy) {
        return cast(lxb_css_memory_t*) lexbor_free(memory);
    }

    return memory;
}

lxb_css_memory_t* lxb_css_memory_ref_inc(lxb_css_memory_t* memory)
{
    if (SIZE_MAX - memory.ref_count == 0) {
        return null;
    }

    memory.ref_count++;

    return memory;
}

void lxb_css_memory_ref_dec(lxb_css_memory_t* memory)
{
    if (memory.ref_count > 0) {
        memory.ref_count--;
    }
}

lxb_css_memory_t* lxb_css_memory_ref_dec_destroy(lxb_css_memory_t* memory)
{
    if (memory.ref_count > 0) {
        memory.ref_count--;
    }

    if (memory.ref_count == 0) {
        return lxb_css_memory_destroy(memory, true);
    }

    return memory;
}

lxb_status_t lxb_css_make_data(lxb_css_parser_t* parser, lexbor_str_t* str, size_t begin, size_t end)
{
    size_t length = void;
    const(lxb_char_t)* p = void;

    p = parser.tkz.in_begin;
    length = end - begin;

    if (str.data == null) {
        cast(void) lexbor_str_init(str, parser.memory.mraw, length);
        if (str.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    memcpy(str.data, p + begin, length);

    str.length = length;
    str.data[str.length] = '\0';

    return LXB_STATUS_OK;
}

lxb_char_t* lxb_css_serialize_char_handler(const(void)* style, lxb_css_style_serialize_f cb, size_t* out_length)
{
    size_t length = 0;
    lxb_status_t status = void;
    lexbor_str_t str = void;

    status = cb(style, &lexbor_serialize_length_cb, &length);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    /* + 1 == '\0' */
    str.data = cast(ubyte*) lexbor_malloc(length + 1);
    if (str.data == null) {
        goto failed;
    }

    str.length = 0;

    status = cb(style, &lexbor_serialize_copy_cb, &str);
    if (status != LXB_STATUS_OK) {
        lexbor_free(str.data);
        goto failed;
    }

    str.data[str.length] = '\0';

    if (out_length != null) {
        *out_length = str.length;
    }

    return str.data;

failed:

    if (out_length != null) {
        *out_length = 0;
    }

    return null;
}

lxb_status_t lxb_css_serialize_str_handler(const(void)* style, lexbor_str_t* str, lexbor_mraw_t* mraw, lxb_css_style_serialize_f cb)
{
    lxb_css_str_ctx_t ctx = void;

    ctx.str = str;
    ctx.mraw = mraw;

    if (str.data == null) {
        lexbor_str_init(str, mraw, 1);
        if (str.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    return cb(style, &lxb_css_str_cb, &ctx);
}

private lxb_status_t lxb_css_str_cb(const(lxb_char_t)* data, size_t len, void* cb_ctx)
{
    lxb_char_t* ptr = void;
    lxb_css_str_ctx_t* ctx = cast(lxb_css_str_ctx_t*) cb_ctx;

    ptr = lexbor_str_append(ctx.str, ctx.mraw, data, len);

    return (ptr != null) ? LXB_STATUS_OK : LXB_STATUS_ERROR_MEMORY_ALLOCATION;
}
