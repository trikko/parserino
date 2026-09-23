module parserino.lexbor.html.element_steps;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interfaces.node;
public import parserino.lexbor.dom.interfaces.document;
public import parserino.lexbor.tag.tag;
import parserino.lexbor.tag.const_;
import parserino.lexbor.ns.const_;
import parserino.lexbor.html.interfaces.option_element;
import parserino.lexbor.html.interfaces.select_element;
import parserino.lexbor.html.interfaces.selectedcontent_element;
import parserino.lexbor.html.element_steps_res;

extern(C) @nogc nothrow:
__gshared:

// ---- element_steps.h ----
/*
 * Copyright (C) 2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
/*
 * Element steps.
 */






// ---- element_steps.c ----
/*
 * Copyright (C) 2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

/*
 * Element steps.
 */
lxb_status_t lxb_html_element_steps_insertion(lxb_dom_node_t* inserted_node)
{
    lxb_tag_id_t tag_id = void;
    lxb_dom_node_cb_insertion_f inserted = void;

    if (inserted_node.ns != LXB_NS_HTML) {
        return LXB_STATUS_OK;
    }

    tag_id = inserted_node.local_name;

    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (tag_id == LXB_TAG__LAST_ENTRY) {
            return LXB_STATUS_OK;
        }

        return lxb_html_element_inserted_unknown_steps(inserted_node);
    }

    if (tag_id < LXB_TAG__BEGIN) {
        return LXB_STATUS_OK;
    }

    inserted = lxb_html_element_steps_res_default[inserted_node.local_name].inserted;

    if (inserted != null) {
        return inserted(inserted_node);
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_steps_removing(lxb_dom_node_t* removed_node, lxb_dom_node_t* old_parent)
{
    lxb_tag_id_t tag_id = void;
    lxb_dom_node_cb_removing_f removed = void;

    if (removed_node.ns != LXB_NS_HTML) {
        return LXB_STATUS_OK;
    }

    tag_id = removed_node.local_name;

    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (tag_id == LXB_TAG__LAST_ENTRY) {
            return LXB_STATUS_OK;
        }

        return lxb_html_element_removed_unknown_steps(removed_node, old_parent);
    }

    if (tag_id < LXB_TAG__BEGIN) {
        return LXB_STATUS_OK;
    }

    removed = lxb_html_element_steps_res_default[removed_node.local_name].removed;

    if (removed != null) {
        return removed(removed_node, old_parent);
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_steps_moving(lxb_dom_node_t* moved_node, lxb_dom_node_t* old_parent)
{
    lxb_tag_id_t tag_id = void;
    lxb_dom_node_cb_moving_f moved = void;

    if (moved_node.ns != LXB_NS_HTML) {
        return LXB_STATUS_OK;
    }

    tag_id = moved_node.local_name;

    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (tag_id == LXB_TAG__LAST_ENTRY) {
            return LXB_STATUS_OK;
        }

        return lxb_html_element_moved_unknown_steps(moved_node, old_parent);
    }

    if (tag_id < LXB_TAG__BEGIN) {
        return LXB_STATUS_OK;
    }

    moved = lxb_html_element_steps_res_default[moved_node.local_name].moved;

    if (moved != null) {
        return moved(moved_node, old_parent);
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_steps_destroy(lxb_dom_node_t* node)
{
    lxb_tag_id_t tag_id = void;
    lxb_dom_node_cb_destroy_f destroy = void;

    if (node.ns != LXB_NS_HTML) {
        return LXB_STATUS_OK;
    }

    tag_id = node.local_name;

    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (tag_id == LXB_TAG__LAST_ENTRY) {
            return LXB_STATUS_OK;
        }

        return lxb_html_element_destroy_unknown_steps(node);
    }

    if (tag_id < LXB_TAG__BEGIN) {
        return LXB_STATUS_OK;
    }

    destroy = lxb_html_element_steps_res_default[node.local_name].destroy;

    if (destroy != null) {
        return destroy(node);
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_steps_children_changed(lxb_dom_node_t* parent)
{
    lxb_tag_id_t tag_id = void;
    lxb_dom_node_cb_children_changed_f children_changed = void;

    if (parent.ns != LXB_NS_HTML) {
        return LXB_STATUS_OK;
    }

    tag_id = parent.local_name;

    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (tag_id == LXB_TAG__LAST_ENTRY) {
            return LXB_STATUS_OK;
        }

        return lxb_html_element_children_changed_unknown_steps(parent);
    }

    if (tag_id < LXB_TAG__BEGIN) {
        return LXB_STATUS_OK;
    }

    children_changed = lxb_html_element_steps_res_default[parent.local_name].children_changed;

    if (children_changed != null) {
        return children_changed(parent);
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_element_steps_post_connection(lxb_dom_node_t* connected_node)
{
    lxb_tag_id_t tag_id = void;
    lxb_dom_node_cb_post_connection_f connected = void;

    if (connected_node.ns != LXB_NS_HTML) {
        return LXB_STATUS_OK;
    }

    tag_id = connected_node.local_name;

    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (tag_id == LXB_TAG__LAST_ENTRY) {
            return LXB_STATUS_OK;
        }

        return lxb_html_element_connected_unknown_steps(connected_node);
    }

    if (tag_id < LXB_TAG__BEGIN) {
        return LXB_STATUS_OK;
    }

    connected = lxb_html_element_steps_res_default[connected_node.local_name].connected;

    if (connected != null) {
        return connected(connected_node);
    }

    return LXB_STATUS_OK;
}
