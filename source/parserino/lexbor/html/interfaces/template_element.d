module parserino.lexbor.html.interfaces.template_element;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interfaces.document_fragment;
public import parserino.lexbor.html.interface_;
public import parserino.lexbor.html.interfaces.element;
import parserino.lexbor.html.interfaces.document;

extern(C) @nogc nothrow:
__gshared:

// ---- template_element.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_html_template_element {
    lxb_html_element_t element;

    lxb_dom_document_fragment_t* content;
}



// ---- template_element.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_html_template_element_t* lxb_html_template_element_interface_create(lxb_html_document_t* document)
{
    lxb_html_template_element_t* element = void;

    element = cast(lxb_html_template_element*) lexbor_mraw_calloc(document.dom_document.mraw,
                                 lxb_html_template_element_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_html_document_original_ref(document);
    node.type = LXB_DOM_NODE_TYPE_ELEMENT;

    element.content = lxb_dom_document_fragment_interface_create(node.owner_document);
    if (element.content == null) {
        return lxb_html_template_element_interface_destroy(element);
    }

    element.content.node.ns = LXB_NS_HTML;
    element.content.host = (cast(lxb_dom_element_t*) (element));

    return element;
}

lxb_html_template_element_t* lxb_html_template_element_interface_destroy(lxb_html_template_element_t* template_element)
{
    cast(void) lxb_dom_document_fragment_interface_destroy(template_element.content);
    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (template_element)));

    return null;
}
