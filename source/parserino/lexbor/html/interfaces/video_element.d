module parserino.lexbor.html.interfaces.video_element;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.interface_;
public import parserino.lexbor.html.interfaces.media_element;
import parserino.lexbor.html.interfaces.document;

extern(C) @nogc nothrow:
__gshared:

// ---- video_element.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_html_video_element {
    lxb_html_media_element_t media_element;
}



// ---- video_element.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_html_video_element_t* lxb_html_video_element_interface_create(lxb_html_document_t* document)
{
    lxb_html_video_element_t* element = void;

    element = cast(lxb_html_video_element*) lexbor_mraw_calloc(document.dom_document.mraw,
                                 lxb_html_video_element_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_html_document_original_ref(document);
    node.type = LXB_DOM_NODE_TYPE_ELEMENT;

    return element;
}

lxb_html_video_element_t* lxb_html_video_element_interface_destroy(lxb_html_video_element_t* video_element)
{
    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (video_element)));
    return null;
}
