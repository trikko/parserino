module parserino.lexbor.dom.interfaces.cdata_section;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interfaces.document;
public import parserino.lexbor.dom.interfaces.text;

extern(C) @nogc nothrow:
__gshared:

// ---- cdata_section.h ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_dom_cdata_section {
    lxb_dom_text_t text;
}




// ---- cdata_section.c ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_dom_cdata_section_t* lxb_dom_cdata_section_interface_create(lxb_dom_document_t* document)
{
    lxb_dom_cdata_section_t* element = void;

    element = cast(lxb_dom_cdata_section*) lexbor_mraw_calloc(document.mraw,
                                 lxb_dom_cdata_section_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_dom_document_owner(document);
    node.type = LXB_DOM_NODE_TYPE_CDATA_SECTION;

    return element;
}

lxb_dom_cdata_section_t* lxb_dom_cdata_section_interface_clone(lxb_dom_document_t* document, const(lxb_dom_cdata_section_t)* cdata)
{
    lxb_status_t status = void;
    lxb_dom_cdata_section_t* new_ = void;

    new_ = lxb_dom_cdata_section_interface_create(document);
    if (new_ == null) {
        return null;
    }

    status = lxb_dom_text_interface_copy(&new_.text, &cdata.text);
    if (status != LXB_STATUS_OK) {
        return lxb_dom_cdata_section_interface_destroy(new_);
    }

    return new_;
}

lxb_dom_cdata_section_t* lxb_dom_cdata_section_interface_destroy(lxb_dom_cdata_section_t* cdata_section)
{
    cast(void) lxb_dom_text_interface_destroy((cast(lxb_dom_text_t*) (cdata_section)));
    return null;
}
