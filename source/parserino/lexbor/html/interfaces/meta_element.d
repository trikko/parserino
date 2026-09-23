module parserino.lexbor.html.interfaces.meta_element;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.interface_;
public import parserino.lexbor.html.interfaces.element;
import parserino.lexbor.html.interfaces.document;

extern(C) @nogc nothrow:
__gshared:

// ---- meta_element.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_html_meta_element {
    lxb_html_element_t element;
}



// ---- meta_element.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_html_meta_element_t* lxb_html_meta_element_interface_create(lxb_html_document_t* document)
{
    lxb_html_meta_element_t* element = void;

    element = cast(lxb_html_meta_element*) lexbor_mraw_calloc(document.dom_document.mraw,
                                 lxb_html_meta_element_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_html_document_original_ref(document);
    node.type = LXB_DOM_NODE_TYPE_ELEMENT;

    return element;
}

lxb_html_meta_element_t* lxb_html_meta_element_interface_destroy(lxb_html_meta_element_t* meta_element)
{
    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (meta_element)));
    return null;
}
