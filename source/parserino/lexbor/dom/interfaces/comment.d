module parserino.lexbor.dom.interfaces.comment;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interfaces.document;
public import parserino.lexbor.dom.interfaces.character_data;

extern(C) @nogc nothrow:
__gshared:

// ---- comment.h ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_dom_comment {
    lxb_dom_character_data_t char_data;
}




// ---- comment.c ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_dom_comment_t* lxb_dom_comment_interface_create(lxb_dom_document_t* document)
{
    lxb_dom_comment_t* element = void;

    element = cast(lxb_dom_comment*) lexbor_mraw_calloc(document.mraw,
                                 lxb_dom_comment_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_dom_document_owner(document);
    node.type = LXB_DOM_NODE_TYPE_COMMENT;

    return element;
}

lxb_dom_comment_t* lxb_dom_comment_interface_clone(lxb_dom_document_t* document, const(lxb_dom_comment_t)* text)
{
    lxb_status_t status = void;
    lxb_dom_comment_t* new_ = void;

    new_ = lxb_dom_comment_interface_create(document);
    if (new_ == null) {
        return null;
    }

    status = lxb_dom_comment_interface_copy(new_, text);
    if (status != LXB_STATUS_OK) {
        return lxb_dom_comment_interface_destroy(new_);
    }

    return new_;
}

lxb_dom_comment_t* lxb_dom_comment_interface_destroy(lxb_dom_comment_t* comment)
{
    cast(void) lxb_dom_character_data_interface_destroy(
                                     (cast(lxb_dom_character_data_t*) (comment)));
    return null;
}

lxb_status_t lxb_dom_comment_interface_copy(lxb_dom_comment_t* dst, const(lxb_dom_comment_t)* src)
{
    return lxb_dom_character_data_interface_copy(&dst.char_data,
                                                 &src.char_data);
}
