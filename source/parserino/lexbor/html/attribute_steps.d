module parserino.lexbor.html.attribute_steps;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interfaces.attr;
import parserino.lexbor.html.interfaces.option_element;
import parserino.lexbor.dom.interfaces.document;
import parserino.lexbor.dom.interfaces.element;
import parserino.lexbor.tag.const_;
import parserino.lexbor.ns.const_;
import parserino.lexbor.html.attribute_steps_res;

extern(C) @nogc nothrow:
__gshared:

// ---- attribute_steps.h ----
/*
 * Copyright (C) 2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */




// ---- attribute_steps.c ----
/*
 * Copyright (C) 2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_status_t lxb_html_attribute_steps_change(lxb_dom_element_t* element, lxb_dom_attr_id_t name, const(lxb_char_t)* old_value, size_t old_len, const(lxb_char_t)* value, size_t value_len, lxb_ns_id_t ns)
{
    lxb_tag_id_t tag_id = void;
    lxb_dom_node_t* node = void;
    lxb_dom_element_attr_change_f change = void;

    node = (cast(lxb_dom_node_t*) (element));
    tag_id = node.local_name;

    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (tag_id == LXB_TAG__LAST_ENTRY) {
            return LXB_STATUS_OK;
        }

        return lxb_html_element_attr_change(element, name, old_value,
                                            old_len, value, value_len, ns);
    }

    if (tag_id < LXB_TAG__BEGIN) {
        return LXB_STATUS_OK;
    }

    change = lxb_html_attribute_steps_res_default[element.node.local_name].change;

    if (change != null) {
        return change(element, name, old_value, old_len, value, value_len, ns);
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_attribute_steps_append(lxb_dom_element_t* element, lxb_dom_attr_id_t name, const(lxb_char_t)* old_value, size_t old_len, const(lxb_char_t)* value, size_t value_len, lxb_ns_id_t ns)
{
    lxb_tag_id_t tag_id = void;
    lxb_dom_node_t* node = void;
    lxb_dom_element_attr_change_f append = void;

    node = (cast(lxb_dom_node_t*) (element));
    tag_id = node.local_name;

    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (tag_id == LXB_TAG__LAST_ENTRY) {
            return LXB_STATUS_OK;
        }

        return lxb_html_element_attr_append(element, name, old_value,
                                            old_len, value, value_len, ns);
    }

    if (tag_id < LXB_TAG__BEGIN) {
        return LXB_STATUS_OK;
    }

    append = lxb_html_attribute_steps_res_default[element.node.local_name].append;

    if (append != null) {
        return append(element, name, old_value, old_len, value, value_len, ns);
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_attribute_steps_remove(lxb_dom_element_t* element, lxb_dom_attr_id_t name, const(lxb_char_t)* old_value, size_t old_len, const(lxb_char_t)* value, size_t value_len, lxb_ns_id_t ns)
{
    lxb_tag_id_t tag_id = void;
    lxb_dom_node_t* node = void;
    lxb_dom_element_attr_change_f remove = void;

    node = (cast(lxb_dom_node_t*) (element));
    tag_id = node.local_name;

    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (tag_id == LXB_TAG__LAST_ENTRY) {
            return LXB_STATUS_OK;
        }

        return lxb_html_element_attr_remove(element, name, old_value,
                                            old_len, value, value_len, ns);
    }

    if (tag_id < LXB_TAG__BEGIN) {
        return LXB_STATUS_OK;
    }

    remove = lxb_html_attribute_steps_res_default[element.node.local_name].remove;

    if (remove != null) {
        return remove(element, name, old_value, old_len, value, value_len, ns);
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_attribute_steps_replace(lxb_dom_element_t* element, lxb_dom_attr_id_t name, const(lxb_char_t)* old_value, size_t old_len, const(lxb_char_t)* value, size_t value_len, lxb_ns_id_t ns)
{
    lxb_tag_id_t tag_id = void;
    lxb_dom_node_t* node = void;
    lxb_dom_element_attr_change_f replace = void;

    node = (cast(lxb_dom_node_t*) (element));
    tag_id = node.local_name;

    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (tag_id == LXB_TAG__LAST_ENTRY) {
            return LXB_STATUS_OK;
        }

        return lxb_html_element_attr_replace(element, name, old_value,
                                             old_len, value, value_len, ns);
    }

    if (tag_id < LXB_TAG__BEGIN) {
        return LXB_STATUS_OK;
    }

    replace = lxb_html_attribute_steps_res_default[element.node.local_name].remove;

    if (replace != null) {
        return replace(element, name, old_value, old_len, value, value_len, ns);
    }

    return LXB_STATUS_OK;
}
