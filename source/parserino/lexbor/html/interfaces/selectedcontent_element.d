module parserino.lexbor.html.interfaces.selectedcontent_element;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.interface_;
public import parserino.lexbor.html.interfaces.element;
import parserino.lexbor.dom.interfaces.document_fragment;
import parserino.lexbor.html.interfaces.select_element;
import parserino.lexbor.html.interfaces.option_element;
import parserino.lexbor.html.interfaces.document;

extern(C) @nogc nothrow:
__gshared:

// ---- selectedcontent_element.h ----
/*
 * Copyright (C) 2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_html_selectedcontent_element {
    lxb_html_element_t element;
    bool disabled;
}






// ---- selectedcontent_element.c ----
/*
 * Copyright (C) 2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_html_selectedcontent_element_t* lxb_html_selectedcontent_element_interface_create(lxb_html_document_t* document)
{
    lxb_html_selectedcontent_element_t* element = void;

    element = cast(lxb_html_selectedcontent_element*) lexbor_mraw_calloc(document.dom_document.mraw,
                                 lxb_html_selectedcontent_element_t.sizeof);
    if (element == null) {
        return null;
    }

    /* disabled default is false. */

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_html_document_original_ref(document);
    node.type = LXB_DOM_NODE_TYPE_ELEMENT;

    return element;
}

lxb_html_selectedcontent_element_t* lxb_html_selectedcontent_element_interface_destroy(lxb_html_selectedcontent_element_t* selectedcontent_element)
{
    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (selectedcontent_element)));
    return null;
}

lxb_dom_exception_code_t lxb_html_selectedcontent_clone_option(lxb_html_selectedcontent_element_t* sc, lxb_html_option_element_t* option)
{
    lxb_dom_node_t* node = void, child = void, opt_node = void;
    lxb_dom_document_fragment_t fragment = void;

    memset(&fragment, 0x00, lxb_dom_document_fragment_t.sizeof);

    opt_node = (cast(lxb_dom_node_t*) (option));

    fragment.node.type = LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT;
    fragment.node.owner_document = opt_node.owner_document;

    node = opt_node.first_child;

    while (node != null) {
        child = lxb_dom_node_clone(node, true);
        if (child == null) {
            return LXB_DOM_EXCEPTION_ERR;
        }

        lxb_dom_node_insert_child_wo_events((cast(lxb_dom_node_t*) (&fragment)),
                                            child);
        node = node.next;
    }

    return lxb_dom_node_replace_all_spec((cast(lxb_dom_node_t*) (sc)),
                                         (cast(lxb_dom_node_t*) (&fragment)));
}

lxb_status_t lxb_html_selectedcontent_insert_steps(lxb_dom_node_t* inserted_node)
{
    lxb_html_selectedcontent_element_t* sc = void;
    lxb_html_select_element_t* select = void;

    sc = (cast(lxb_html_selectedcontent_element_t*) inserted_node);

    /* Check if parent is a <select> element without `multiple` attribute. */

    if (inserted_node.parent == null
        || inserted_node.parent.local_name != LXB_TAG_SELECT
        || inserted_node.parent.ns != LXB_NS_HTML)
    {
        sc.disabled = true;
        return LXB_STATUS_OK;
    }

    select = (cast(lxb_html_select_element_t*) (inserted_node.parent));

    sc.disabled = false;

    cast(void) lxb_html_select_selectedness_setting_algorithm(select);

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_selectedcontent_remove_steps(lxb_dom_node_t* removed_node, lxb_dom_node_t* old_parent)
{
    lxb_html_selectedcontent_element_t* sc = void;

    sc = (cast(lxb_html_selectedcontent_element_t*) removed_node);
    sc.disabled = true;

    return LXB_STATUS_OK;
}
