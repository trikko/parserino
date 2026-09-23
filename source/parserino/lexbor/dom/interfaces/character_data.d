module parserino.lexbor.dom.interfaces.character_data;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.str;
public import parserino.lexbor.dom.interfaces.document;
public import parserino.lexbor.dom.interfaces.node;

extern(C) @nogc nothrow:
__gshared:

// ---- character_data.h ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_dom_character_data {
    lxb_dom_node_t node;

    lexbor_str_t data;
}






// ---- character_data.c ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_dom_character_data_t* lxb_dom_character_data_interface_create(lxb_dom_document_t* document)
{
    lxb_dom_character_data_t* element = void;

    element = cast(lxb_dom_character_data*) lexbor_mraw_calloc(document.mraw,
                                 lxb_dom_character_data_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_dom_document_owner(document);
    node.type = LXB_DOM_NODE_TYPE_CHARACTER_DATA;

    return element;
}

lxb_dom_character_data_t* lxb_dom_character_data_interface_clone(lxb_dom_document_t* document, const(lxb_dom_character_data_t)* ch_data)
{
    lxb_dom_character_data_t* new_ = void;

    new_ = lxb_dom_character_data_interface_create(document);
    if (new_ == null) {
        return null;
    }

    if (lxb_dom_character_data_interface_copy(new_, ch_data) != LXB_STATUS_OK) {
        return lxb_dom_character_data_interface_destroy(new_);
    }

    return new_;
}

lxb_dom_character_data_t* lxb_dom_character_data_interface_destroy(lxb_dom_character_data_t* character_data)
{
    lxb_dom_node_t* node = void;
    lxb_dom_document_t* doc = void;
    lexbor_str_t data = void;

    data = character_data.data;
    node = (cast(lxb_dom_node_t*) (character_data));
    doc = node.owner_document;

    cast(void) lxb_dom_node_interface_destroy(node);

    lexbor_str_destroy(&data, doc.text, false);

    return null;
}

lxb_status_t lxb_dom_character_data_interface_copy(lxb_dom_character_data_t* dst, const(lxb_dom_character_data_t)* src)
{
    lxb_status_t status = void;

    status = lxb_dom_node_interface_copy(&dst.node, &src.node, false);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    dst.data.length = 0;

    if (lexbor_str_copy(&dst.data, &src.data,
                        (cast(lxb_dom_node_t*) (dst)).owner_document.text) == null)
    {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    return LXB_STATUS_OK;
}

/* TODO: oh, need to... https://dom.spec.whatwg.org/#concept-cd-replace */
lxb_status_t lxb_dom_character_data_replace(lxb_dom_character_data_t* ch_data, const(lxb_char_t)* data, size_t len, size_t offset, size_t count)
{
    if (ch_data.data.data == null) {
        lexbor_str_init(&ch_data.data, ch_data.node.owner_document.text, len);
        if (ch_data.data.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }
    else if (lexbor_str_size(&ch_data.data) <= len) {
        const(lxb_char_t)* data_r = void;

        data_r = lexbor_str_realloc(&ch_data.data,
                                  ch_data.node.owner_document.text, (len + 1));
        if (data_r == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    memcpy(ch_data.data.data, data, lxb_char_t.sizeof * len);

    ch_data.data.data[len] = 0x00;
    ch_data.data.length = len;

    return LXB_STATUS_OK;
}
