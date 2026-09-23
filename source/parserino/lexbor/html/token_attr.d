module parserino.lexbor.html.token_attr;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.str;
public import parserino.lexbor.core.dobject;
public import parserino.lexbor.dom.interfaces.attr;
public import parserino.lexbor.html.base;

extern(C) @nogc nothrow:
__gshared:

// ---- token_attr.h ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_html_token_attr_t = lxb_html_token_attr;
alias lxb_html_token_attr_type_t = int;

enum lxb_html_token_attr_type {
    LXB_HTML_TOKEN_ATTR_TYPE_UNDEF = 0x0000,
    LXB_HTML_TOKEN_ATTR_TYPE_NAME_NULL = 0x0001,
    LXB_HTML_TOKEN_ATTR_TYPE_VALUE_NULL = 0x0002
}
alias LXB_HTML_TOKEN_ATTR_TYPE_UNDEF = lxb_html_token_attr_type.LXB_HTML_TOKEN_ATTR_TYPE_UNDEF;
alias LXB_HTML_TOKEN_ATTR_TYPE_NAME_NULL = lxb_html_token_attr_type.LXB_HTML_TOKEN_ATTR_TYPE_NAME_NULL;
alias LXB_HTML_TOKEN_ATTR_TYPE_VALUE_NULL = lxb_html_token_attr_type.LXB_HTML_TOKEN_ATTR_TYPE_VALUE_NULL;


struct lxb_html_token_attr {
    const(lxb_char_t)* name_begin;
    const(lxb_char_t)* name_end;

    const(lxb_char_t)* value_begin;
    const(lxb_char_t)* value_end;

    const(lxb_dom_attr_data_t)* name;
    lxb_char_t* value;
    size_t value_size;

    lxb_html_token_attr_t* next;
    lxb_html_token_attr_t* prev;

    lxb_html_token_attr_type_t type;
}





// ---- token_attr.c ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_html_token_attr_t* lxb_html_token_attr_create(lexbor_dobject_t* dobj)
{
    return cast(lxb_html_token_attr*) (lexbor_dobject_calloc(dobj));
}

void lxb_html_token_attr_clean(lxb_html_token_attr_t* attr)
{
    memset(attr, 0, lxb_html_token_attr_t.sizeof);
}

lxb_html_token_attr_t* lxb_html_token_attr_destroy(lxb_html_token_attr_t* attr, lexbor_dobject_t* dobj)
{
    return cast(lxb_html_token_attr*) lexbor_dobject_free(dobj, attr);
}

const(lxb_char_t)* lxb_html_token_attr_name(lxb_html_token_attr_t* attr, size_t* length)
{
    if (attr.name == null) {
        if (length != null) {
            *length = 0;
        }

        return null;
    }

    if (length != null) {
        *length = attr.name.entry.length;
    }

    return lexbor_hash_entry_str(&attr.name.entry);
}
