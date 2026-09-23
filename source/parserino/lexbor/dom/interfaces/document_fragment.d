module parserino.lexbor.dom.interfaces.document_fragment;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interfaces.document;
public import parserino.lexbor.dom.interfaces.node;

extern(C) @nogc nothrow:
__gshared:

// ---- document_fragment.h ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_dom_document_fragment {
    lxb_dom_node_t node;

    lxb_dom_element_t* host;
}



// ---- document_fragment.c ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_dom_document_fragment_t* lxb_dom_document_fragment_interface_create(lxb_dom_document_t* document)
{
    lxb_dom_document_fragment_t* element = void;

    element = cast(lxb_dom_document_fragment*) lexbor_mraw_calloc(document.mraw,
                                 lxb_dom_document_fragment_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_dom_document_owner(document);
    node.type = LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT;

    return element;
}

lxb_dom_document_fragment_t* lxb_dom_document_fragment_interface_destroy(lxb_dom_document_fragment_t* document_fragment)
{
    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (document_fragment)));

    return null;
}
