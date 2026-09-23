module parserino.lexbor.html.tokenizer;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.sbst;
public import parserino.lexbor.core.array_obj;
public import parserino.lexbor.html.base;
public import parserino.lexbor.html.token;
public import parserino.lexbor.tag.tag;
public import parserino.lexbor.ns.ns;
public import parserino.lexbor.html.tokenizer.error;
import parserino.lexbor.html.tokenizer.state;
import parserino.lexbor.html.tokenizer.state_rcdata;
import parserino.lexbor.html.tokenizer.state_rawtext;
import parserino.lexbor.html.tokenizer.state_script;
import parserino.lexbor.html.tree;
import parserino.lexbor.html.tag_res;

extern(C) @nogc nothrow:
__gshared:

// ---- tokenizer.h ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
/* State */
alias lxb_html_tokenizer_state_f = const(lxb_char_t)* function(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end);

alias lxb_html_tokenizer_token_f = lxb_html_token_t* function(lxb_html_tokenizer_t* tkz, lxb_html_token_t* token, void* ctx);

struct lxb_html_tokenizer {
    lxb_html_tokenizer_state_f state;
    lxb_html_tokenizer_state_f state_return;

    lxb_html_tokenizer_token_f callback_token_done;
    void* callback_token_ctx;

    lexbor_hash_t* tags;
    lexbor_hash_t* attrs;
    lexbor_mraw_t* attrs_mraw;

    /* For a temp strings and other templary data */
    lexbor_mraw_t* mraw;

    /* Current process token */
    lxb_html_token_t* token;

    /* Memory for token and attr */
    lexbor_dobject_t* dobj_token;
    lexbor_dobject_t* dobj_token_attr;

    /* Parse error */
    lexbor_array_obj_t* parse_errors;

    /*
     * Leak abstractions.
     * The only place where the specification causes mixing Tree Builder
     * and Tokenizer. We kill all beauty.
     * Current Tree parser. This is not ref (not ref count).
     */
    lxb_html_tree_t* tree;

    /* Temp */
    const(lxb_char_t)* markup;
    const(lxb_char_t)* temp;
    lxb_tag_id_t tmp_tag_id;

    lxb_char_t* start;
    lxb_char_t* pos;
    const(lxb_char_t)* end;
    const(lxb_char_t)* begin;
    const(lxb_char_t)* last;

    /* Entities */
    const(lexbor_sbst_entry_static_t)* entity;
    const(lexbor_sbst_entry_static_t)* entity_match;
    uintptr_t entity_start;
    uintptr_t entity_end;
    uint entity_length;
    uint entity_number;
    bool is_attribute;

    /* Process */
    lxb_html_tokenizer_opt_t opt;
    lxb_status_t status;
    bool is_eof;

    lxb_html_tokenizer_t* base;
    size_t ref_count;
}

// extern const(lxb_char_t)* lxb_html_tokenizer_eof;















 const(lxb_char_t)* lxb_html_tokenizer_change_incoming(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* pos);



/*
 * Inline functions
 */
 void lxb_html_tokenizer_status_set(lxb_html_tokenizer_t* tkz, lxb_status_t status)
{
    tkz.status = status;
}

 void lxb_html_tokenizer_tags_set(lxb_html_tokenizer_t* tkz, lexbor_hash_t* tags)
{
    tkz.tags = tags;
}

 lexbor_hash_t* lxb_html_tokenizer_tags(lxb_html_tokenizer_t* tkz)
{
    return tkz.tags;
}

 void lxb_html_tokenizer_attrs_set(lxb_html_tokenizer_t* tkz, lexbor_hash_t* attrs)
{
    tkz.attrs = attrs;
}

 lexbor_hash_t* lxb_html_tokenizer_attrs(lxb_html_tokenizer_t* tkz)
{
    return tkz.attrs;
}

 void lxb_html_tokenizer_attrs_mraw_set(lxb_html_tokenizer_t* tkz, lexbor_mraw_t* mraw)
{
    tkz.attrs_mraw = mraw;
}

 lexbor_mraw_t* lxb_html_tokenizer_attrs_mraw(lxb_html_tokenizer_t* tkz)
{
    return tkz.attrs_mraw;
}

 void lxb_html_tokenizer_callback_token_done_set(lxb_html_tokenizer_t* tkz, lxb_html_tokenizer_token_f call_func, void* ctx)
{
    tkz.callback_token_done = call_func;
    tkz.callback_token_ctx = ctx;
}

 void* lxb_html_tokenizer_callback_token_done_ctx(lxb_html_tokenizer_t* tkz)
{
    return tkz.callback_token_ctx;
}

 void lxb_html_tokenizer_state_set(lxb_html_tokenizer_t* tkz, lxb_html_tokenizer_state_f state)
{
    tkz.state = state;
}

 void lxb_html_tokenizer_tmp_tag_id_set(lxb_html_tokenizer_t* tkz, lxb_tag_id_t tag_id)
{
    tkz.tmp_tag_id = tag_id;
}

 lxb_html_tree_t* lxb_html_tokenizer_tree(lxb_html_tokenizer_t* tkz)
{
    return tkz.tree;
}

 void lxb_html_tokenizer_tree_set(lxb_html_tokenizer_t* tkz, lxb_html_tree_t* tree)
{
    tkz.tree = tree;
}

 lexbor_mraw_t* lxb_html_tokenizer_mraw(lxb_html_tokenizer_t* tkz)
{
    return tkz.mraw;
}

 lxb_status_t lxb_html_tokenizer_temp_realloc(lxb_html_tokenizer_t* tkz, size_t size)
{
    size_t length = tkz.pos - tkz.start;
    size_t new_size = (tkz.end - tkz.start) + size + 4096;

    tkz.start = cast(lxb_char_t*)lexbor_realloc(tkz.start, new_size);
    if (tkz.start == null) {
        tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        return tkz.status;
    }

    tkz.pos = tkz.start + length;
    tkz.end = tkz.start + new_size;

    return LXB_STATUS_OK;
}

 lxb_status_t lxb_html_tokenizer_temp_append_data(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data)
{
    size_t size = data - tkz.begin;

    if ((tkz.pos + size) > tkz.end) {
        if(lxb_html_tokenizer_temp_realloc(tkz, size)) {
            return tkz.status;
        }
    }

    tkz.pos = cast(lxb_char_t*) memcpy(tkz.pos, tkz.begin, size) + size;

    return LXB_STATUS_OK;
}

 lxb_status_t lxb_html_tokenizer_temp_append(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, size_t size)
{
    if ((tkz.pos + size) > tkz.end) {
        if(lxb_html_tokenizer_temp_realloc(tkz, size)) {
            return tkz.status;
        }
    }

    tkz.pos = cast(lxb_char_t*) memcpy(tkz.pos, data, size) + size;

    return LXB_STATUS_OK;
}

/*
 * No inline functions for ABI.
 */









// ---- tokenizer.c ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum LXB_HTML_TKZ_TEMP_SIZE = (4096 * 4);

enum {
    LXB_HTML_TOKENIZER_OPT_UNDEF = 0x00,
    LXB_HTML_TOKENIZER_OPT_TAGS_SELF = 0x01,
    LXB_HTML_TOKENIZER_OPT_ATTRS_SELF = 0x02,
    LXB_HTML_TOKENIZER_OPT_ATTRS_MRAW_SELF = 0x04
}

const(lxb_char_t)* lxb_html_tokenizer_eof = cast(const(lxb_char_t)*) "\x00";


lxb_html_tokenizer_t* lxb_html_tokenizer_create()
{
    return cast(lxb_html_tokenizer*) lexbor_calloc(1, lxb_html_tokenizer_t.sizeof);
}

lxb_status_t lxb_html_tokenizer_init(lxb_html_tokenizer_t* tkz)
{
    lxb_status_t status = void;

    if (tkz == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    /* mraw for templary strings or structures */
    tkz.mraw = lexbor_mraw_create();
    status = lexbor_mraw_init(tkz.mraw, 1024);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    /* Init Token */
    tkz.token = null;

    tkz.dobj_token = lexbor_dobject_create();
    status = lexbor_dobject_init(tkz.dobj_token,
                                 4096, lxb_html_token_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    /* Init Token Attributes */
    tkz.dobj_token_attr = lexbor_dobject_create();
    status = lexbor_dobject_init(tkz.dobj_token_attr, 4096,
                                 lxb_html_token_attr_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    /* Parse errors */
    tkz.parse_errors = lexbor_array_obj_create();
    status = lexbor_array_obj_init(tkz.parse_errors, 16,
                                   lxb_html_tokenizer_error_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    /* Temporary memory for tag name and attributes. */
    tkz.start = cast(ubyte*) lexbor_malloc(LXB_HTML_TKZ_TEMP_SIZE * lxb_char_t.sizeof);
    if (tkz.start == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    tkz.pos = tkz.start;
    tkz.end = tkz.start + LXB_HTML_TKZ_TEMP_SIZE;

    tkz.tree = null;
    tkz.tags = null;
    tkz.attrs = null;
    tkz.attrs_mraw = null;

    tkz.state = &lxb_html_tokenizer_state_data_before;
    tkz.state_return = null;

    tkz.callback_token_done = &lxb_html_tokenizer_token_done;
    tkz.callback_token_ctx = null;

    tkz.is_eof = false;
    tkz.status = LXB_STATUS_OK;

    tkz.base = null;
    tkz.ref_count = 1;

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_tokenizer_inherit(lxb_html_tokenizer_t* tkz_to, lxb_html_tokenizer_t* tkz_from)
{
    lxb_status_t status = void;

    tkz_to.tags = tkz_from.tags;
    tkz_to.attrs = tkz_from.attrs;
    tkz_to.attrs_mraw = tkz_from.attrs_mraw;
    tkz_to.mraw = tkz_from.mraw;

    /* Token and Attributes */
    tkz_to.token = null;

    tkz_to.dobj_token = tkz_from.dobj_token;
    tkz_to.dobj_token_attr = tkz_from.dobj_token_attr;

    /* Parse errors */
    tkz_to.parse_errors = lexbor_array_obj_create();
    status = lexbor_array_obj_init(tkz_to.parse_errors, 16,
                                   lxb_html_tokenizer_error_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    tkz_to.state = &lxb_html_tokenizer_state_data_before;
    tkz_to.state_return = null;

    tkz_to.callback_token_done = &lxb_html_tokenizer_token_done;
    tkz_to.callback_token_ctx = null;

    tkz_to.is_eof = false;
    tkz_to.status = LXB_STATUS_OK;

    tkz_to.base = tkz_from;
    tkz_to.ref_count = 1;

    tkz_to.start = tkz_from.start;
    tkz_to.end = tkz_from.end;
    tkz_to.pos = tkz_to.start;

    return LXB_STATUS_OK;
}

lxb_html_tokenizer_t* lxb_html_tokenizer_ref(lxb_html_tokenizer_t* tkz)
{
    if (tkz == null) {
        return null;
    }

    if (tkz.base != null) {
        return lxb_html_tokenizer_ref(tkz.base);
    }

    tkz.ref_count++;

    return tkz;
}

lxb_html_tokenizer_t* lxb_html_tokenizer_unref(lxb_html_tokenizer_t* tkz)
{
    if (tkz == null || tkz.ref_count == 0) {
        return null;
    }

    if (tkz.base != null) {
        tkz.base = lxb_html_tokenizer_unref(tkz.base);
    }

    tkz.ref_count--;

    if (tkz.ref_count == 0) {
        lxb_html_tokenizer_destroy(tkz);
    }

    return null;
}

void lxb_html_tokenizer_clean(lxb_html_tokenizer_t* tkz)
{
    tkz.tree = null;

    tkz.state = &lxb_html_tokenizer_state_data_before;
    tkz.state_return = null;

    tkz.is_eof = false;
    tkz.status = LXB_STATUS_OK;

    tkz.pos = tkz.start;

    lexbor_mraw_clean(tkz.mraw);
    lexbor_dobject_clean(tkz.dobj_token);
    lexbor_dobject_clean(tkz.dobj_token_attr);

    lexbor_array_obj_clean(tkz.parse_errors);
}

lxb_html_tokenizer_t* lxb_html_tokenizer_destroy(lxb_html_tokenizer_t* tkz)
{
    if (tkz == null) {
        return null;
    }

    if (tkz.base == null) {
        if (tkz.opt & LXB_HTML_TOKENIZER_OPT_TAGS_SELF) {
            lxb_html_tokenizer_tags_destroy(tkz);
        }

        if (tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTRS_SELF) {
            lxb_html_tokenizer_attrs_destroy(tkz);
        }

        lexbor_mraw_destroy(tkz.mraw, true);
        lexbor_dobject_destroy(tkz.dobj_token, true);
        lexbor_dobject_destroy(tkz.dobj_token_attr, true);
        lexbor_free(tkz.start);
    }

    tkz.parse_errors = lexbor_array_obj_destroy(tkz.parse_errors, true);

    return cast(lxb_html_tokenizer*) lexbor_free(tkz);
}

lxb_status_t lxb_html_tokenizer_tags_make(lxb_html_tokenizer_t* tkz, size_t table_size)
{
    tkz.tags = lexbor_hash_create();
    return lexbor_hash_init(tkz.tags, table_size, lxb_tag_data_t.sizeof);
}

void lxb_html_tokenizer_tags_destroy(lxb_html_tokenizer_t* tkz)
{
    tkz.tags = lexbor_hash_destroy(tkz.tags, true);
}

lxb_status_t lxb_html_tokenizer_attrs_make(lxb_html_tokenizer_t* tkz, size_t table_size)
{
    tkz.attrs = lexbor_hash_create();
    return lexbor_hash_init(tkz.attrs, table_size,
                            lxb_dom_attr_data_t.sizeof);
}

void lxb_html_tokenizer_attrs_destroy(lxb_html_tokenizer_t* tkz)
{
    tkz.attrs = lexbor_hash_destroy(tkz.attrs, true);
}

lxb_status_t lxb_html_tokenizer_begin(lxb_html_tokenizer_t* tkz)
{
    if (tkz.tags == null) {
        tkz.status = lxb_html_tokenizer_tags_make(tkz, 256);
        if (tkz.status != LXB_STATUS_OK) {
            return tkz.status;
        }

        tkz.opt |= LXB_HTML_TOKENIZER_OPT_TAGS_SELF;
    }

    if (tkz.attrs == null) {
        tkz.status = lxb_html_tokenizer_attrs_make(tkz, 256);
        if (tkz.status != LXB_STATUS_OK) {
            return tkz.status;
        }

        tkz.opt |= LXB_HTML_TOKENIZER_OPT_ATTRS_SELF;
    }

    if (tkz.attrs_mraw == null) {
        tkz.attrs_mraw = tkz.mraw;

        tkz.opt |= LXB_HTML_TOKENIZER_OPT_ATTRS_MRAW_SELF;
    }

    tkz.token = lxb_html_token_create(tkz.dobj_token);
    if (tkz.token == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_tokenizer_chunk(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, size_t size)
{
    const(lxb_char_t)* end = data + size;

    tkz.is_eof = false;
    tkz.status = LXB_STATUS_OK;
    tkz.last = end;

    while (data < end) {
        data = tkz.state(tkz, data, end);
    }

    return tkz.status;
}

lxb_status_t lxb_html_tokenizer_end(lxb_html_tokenizer_t* tkz)
{
    const(lxb_char_t)* data = void, end = void;

    tkz.status = LXB_STATUS_OK;

    /* Send a fake EOF data. */
    data = lxb_html_tokenizer_eof;
    end = lxb_html_tokenizer_eof + 1UL;

    tkz.is_eof = true;

    while (tkz.state(tkz, data, end) < end) {
        /* empty loop */
    }

    tkz.is_eof = false;

    if (tkz.status != LXB_STATUS_OK) {
        return tkz.status;
    }

    /* Emit fake token: END OF FILE */
    lxb_html_token_clean(tkz.token);

    tkz.token.tag_id = LXB_TAG__END_OF_FILE;

    tkz.token = tkz.callback_token_done(tkz, tkz.token,
                                          tkz.callback_token_ctx);

    if (tkz.token == null && tkz.status == LXB_STATUS_OK) {
        tkz.status = LXB_STATUS_ERROR;
    }

    return tkz.status;
}

private lxb_html_token_t* lxb_html_tokenizer_token_done(lxb_html_tokenizer_t* tkz, lxb_html_token_t* token, void* ctx)
{
    return token;
}

lxb_ns_id_t lxb_html_tokenizer_current_namespace(lxb_html_tokenizer_t* tkz)
{
    if (tkz.tree == null) {
        return LXB_NS__UNDEF;
    }

    lxb_dom_node_t* node = lxb_html_tree_adjusted_current_node(tkz.tree);

    if (node == null) {
        return LXB_NS__UNDEF;
    }

    return node.ns;
}

void lxb_html_tokenizer_set_state_by_tag(lxb_html_tokenizer_t* tkz, bool scripting, lxb_tag_id_t tag_id, lxb_ns_id_t ns)
{
    if (ns != LXB_NS_HTML) {
        tkz.state = &lxb_html_tokenizer_state_data_before;

        return;
    }

    switch (tag_id) {
        case LXB_TAG_TITLE:
        case LXB_TAG_TEXTAREA:
            tkz.tmp_tag_id = tag_id;
            tkz.state = &lxb_html_tokenizer_state_rcdata_before;

            break;

        case LXB_TAG_STYLE:
        case LXB_TAG_XMP:
        case LXB_TAG_IFRAME:
        case LXB_TAG_NOEMBED:
        case LXB_TAG_NOFRAMES:
            tkz.tmp_tag_id = tag_id;
            tkz.state = &lxb_html_tokenizer_state_rawtext_before;

            break;

        case LXB_TAG_SCRIPT:
            tkz.tmp_tag_id = tag_id;
            tkz.state = &lxb_html_tokenizer_state_script_data_before;

            break;

        case LXB_TAG_NOSCRIPT:
            if (scripting) {
                tkz.tmp_tag_id = tag_id;
                tkz.state = &lxb_html_tokenizer_state_rawtext_before;

                return;
            }

            tkz.state = &lxb_html_tokenizer_state_data_before;

            break;

        case LXB_TAG_PLAINTEXT:
            tkz.state = &lxb_html_tokenizer_state_plaintext_before;

            break;

        default:
            break;
    }
}

/*
 * No inline functions for ABI.
 */
void lxb_html_tokenizer_status_set_noi(lxb_html_tokenizer_t* tkz, lxb_status_t status)
{
    lxb_html_tokenizer_status_set(tkz, status);
}

void lxb_html_tokenizer_callback_token_done_set_noi(lxb_html_tokenizer_t* tkz, lxb_html_tokenizer_token_f call_func, void* ctx)
{
    lxb_html_tokenizer_callback_token_done_set(tkz, call_func, ctx);
}

void* lxb_html_tokenizer_callback_token_done_ctx_noi(lxb_html_tokenizer_t* tkz)
{
    return lxb_html_tokenizer_callback_token_done_ctx(tkz);
}

void lxb_html_tokenizer_state_set_noi(lxb_html_tokenizer_t* tkz, lxb_html_tokenizer_state_f state)
{
    lxb_html_tokenizer_state_set(tkz, state);
}

void lxb_html_tokenizer_tmp_tag_id_set_noi(lxb_html_tokenizer_t* tkz, lxb_tag_id_t tag_id)
{
    lxb_html_tokenizer_tmp_tag_id_set(tkz, tag_id);
}

lxb_html_tree_t* lxb_html_tokenizer_tree_noi(lxb_html_tokenizer_t* tkz)
{
    return lxb_html_tokenizer_tree(tkz);
}

void lxb_html_tokenizer_tree_set_noi(lxb_html_tokenizer_t* tkz, lxb_html_tree_t* tree)
{
    lxb_html_tokenizer_tree_set(tkz, tree);
}

lexbor_mraw_t* lxb_html_tokenizer_mraw_noi(lxb_html_tokenizer_t* tkz)
{
    return lxb_html_tokenizer_mraw(tkz);
}

lexbor_hash_t* lxb_html_tokenizer_tags_noi(lxb_html_tokenizer_t* tkz)
{
    return lxb_html_tokenizer_tags(tkz);
}
