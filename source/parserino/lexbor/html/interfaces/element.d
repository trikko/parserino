module parserino.lexbor.html.interfaces.element;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.interface_;
public import parserino.lexbor.dom.interfaces.element;
import parserino.lexbor.html.interfaces.document;

extern(C) @nogc nothrow:
__gshared:

// ---- element.h ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_html_element {
    lxb_dom_element_t element;
}




/*
 * Unknown Element steps.
 */








/*
 * Inline functions
 */
 lxb_tag_id_t lxb_html_element_tag_id(lxb_html_element_t* element)
{
    return (cast(lxb_dom_node_t*) (element)).local_name;
}

 lxb_ns_id_t lxb_html_element_ns_id(lxb_html_element_t* element)
{
    return (cast(lxb_dom_node_t*) (element)).ns;
}

 void lxb_html_element_insert_before(lxb_html_element_t* dst, lxb_html_element_t* src)
{
    lxb_dom_node_insert_before((cast(lxb_dom_node_t*) (dst)),
                               (cast(lxb_dom_node_t*) (src)));
}

 void lxb_html_element_insert_after(lxb_html_element_t* dst, lxb_html_element_t* src)
{
    lxb_dom_node_insert_after((cast(lxb_dom_node_t*) (dst)),
                              (cast(lxb_dom_node_t*) (src)));
}

 void lxb_html_element_insert_child(lxb_html_element_t* dst, lxb_html_element_t* src)
{
    lxb_dom_node_insert_child((cast(lxb_dom_node_t*) (dst)),
                              (cast(lxb_dom_node_t*) (src)));
}

 void lxb_html_element_remove(lxb_html_element_t* element)
{
    lxb_dom_node_remove((cast(lxb_dom_node_t*) (element)));
}

 lxb_html_document_t* lxb_html_element_document(lxb_html_element_t* element)
{
    return (cast(lxb_html_document_t*) ((cast(lxb_dom_node_t*) (element)).owner_document));
}

// ---- element.c ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_html_element_t* lxb_html_element_interface_create(lxb_html_document_t* document)
{
    lxb_html_element_t* element = void;

    element = cast(lxb_html_element*) lexbor_mraw_calloc(document.dom_document.mraw,
                                 lxb_html_element_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_html_document_original_ref(document);
    node.type = LXB_DOM_NODE_TYPE_ELEMENT;

    return element;
}

lxb_html_element_t* lxb_html_element_interface_destroy(lxb_html_element_t* element)
{
    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (element)));
    return null;
}

lxb_html_element_t* lxb_html_element_inner_html_set(lxb_html_element_t* element, const(lxb_char_t)* html, size_t size)
{
    lxb_dom_node_t* node = void, child = void;
    lxb_dom_node_t* root = (cast(lxb_dom_node_t*) (element));
    lxb_html_document_t* doc = (cast(lxb_html_document_t*) (root.owner_document));

    node = lxb_html_document_parse_fragment(doc, &element.element, html, size);
    if (node == null) {
        return null;
    }

    while (root.first_child != null) {
        lxb_dom_node_destroy_deep(root.first_child);
    }

    while (node.first_child != null) {
        child = node.first_child;

        lxb_dom_node_remove(child);
        lxb_dom_node_insert_child(root, child);
    }

    lxb_dom_node_destroy(node);

    return (cast(lxb_html_element_t*) (root));
}

/*
 * Unknown Element steps.
 */
lxb_status_t lxb_html_element_inserted_unknown_steps(lxb_dom_node_t* inserted_node)
{
    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_removed_unknown_steps(lxb_dom_node_t* removed_node, lxb_dom_node_t* old_parent)
{
    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_moved_unknown_steps(lxb_dom_node_t* moved_node, lxb_dom_node_t* old_parent)
{
    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_destroy_unknown_steps(lxb_dom_node_t* node)
{
    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_children_changed_unknown_steps(lxb_dom_node_t* parent)
{
    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_connected_unknown_steps(lxb_dom_node_t* connected_node)
{
    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_attr_change(lxb_dom_element_t* element, lxb_dom_attr_id_t local_name, const(lxb_char_t)* old_value, size_t old_len, const(lxb_char_t)* value, size_t value_len, lxb_ns_id_t ns)
{
    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_attr_append(lxb_dom_element_t* element, lxb_dom_attr_id_t local_name, const(lxb_char_t)* old_value, size_t old_len, const(lxb_char_t)* value, size_t value_len, lxb_ns_id_t ns)
{
    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_attr_remove(lxb_dom_element_t* element, lxb_dom_attr_id_t local_name, const(lxb_char_t)* old_value, size_t old_len, const(lxb_char_t)* value, size_t value_len, lxb_ns_id_t ns)
{
    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_attr_replace(lxb_dom_element_t* element, lxb_dom_attr_id_t local_name, const(lxb_char_t)* old_value, size_t old_len, const(lxb_char_t)* value, size_t value_len, lxb_ns_id_t ns)
{
    return LXB_STATUS_OK;
}
