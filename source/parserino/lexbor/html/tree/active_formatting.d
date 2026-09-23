module parserino.lexbor.html.tree.active_formatting;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.array;
public import parserino.lexbor.html.tree;
import parserino.lexbor.dom.interfaces.node;
import parserino.lexbor.html.tree.open_elements;
import parserino.lexbor.html.interfaces.element;

extern(C) @nogc nothrow:
__gshared:

// ---- active_formatting.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */








/*
 * Inline functions
 */
 lxb_dom_node_t* lxb_html_tree_active_formatting_current_node(lxb_html_tree_t* tree)
{
    if (tree.active_formatting.length == 0) {
        return null;
    }

    return cast(lxb_dom_node_t*) tree.active_formatting.list
        [ (tree.active_formatting.length - 1) ];
}

 lxb_dom_node_t* lxb_html_tree_active_formatting_first(lxb_html_tree_t* tree)
{
    return cast(lxb_dom_node_t*) lexbor_array_get(tree.active_formatting, 0);
}

 lxb_dom_node_t* lxb_html_tree_active_formatting_get(lxb_html_tree_t* tree, size_t idx)
{
    return cast(lxb_dom_node_t*) lexbor_array_get(tree.active_formatting, idx);
}

 lxb_status_t lxb_html_tree_active_formatting_push(lxb_html_tree_t* tree, lxb_dom_node_t* node)
{
    return lexbor_array_push(tree.active_formatting, node);
}

 lxb_dom_node_t* lxb_html_tree_active_formatting_pop(lxb_html_tree_t* tree)
{
    return cast(lxb_dom_node_t*) lexbor_array_pop(tree.active_formatting);
}

 lxb_status_t lxb_html_tree_active_formatting_push_marker(lxb_html_tree_t* tree)
{
    return lexbor_array_push(tree.active_formatting,
                             lxb_html_tree_active_formatting_marker());
}

 lxb_status_t lxb_html_tree_active_formatting_insert(lxb_html_tree_t* tree, lxb_dom_node_t* node, size_t idx)
{
    return lexbor_array_insert(tree.active_formatting, idx, node);
}

 void lxb_html_tree_active_formatting_remove(lxb_html_tree_t* tree, size_t idx)
{
    lexbor_array_delete(tree.active_formatting, idx, 1);
}

// ---- active_formatting.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

private lxb_html_element_t lxb_html_tree_active_formatting_marker_static;

// D port: address computed at run time (not allowed in a static initializer)
pragma(inline, true) private lxb_dom_node_t* lxb_html_tree_active_formatting_marker_node_static() { return cast(lxb_dom_node_t*) &lxb_html_tree_active_formatting_marker_static; }

lxb_html_element_t* lxb_html_tree_active_formatting_marker()
{
    return &lxb_html_tree_active_formatting_marker_static;
}

void lxb_html_tree_active_formatting_up_to_last_marker(lxb_html_tree_t* tree)
{
    void** list = tree.active_formatting.list;

    while (tree.active_formatting.length != 0) {
        tree.active_formatting.length--;

        if (list[tree.active_formatting.length]
            == &lxb_html_tree_active_formatting_marker_static)
        {
            break;
        }
    }
}

void lxb_html_tree_active_formatting_remove_by_node(lxb_html_tree_t* tree, lxb_dom_node_t* node)
{
    size_t delta = void;
    void** list = tree.active_formatting.list;
    size_t idx = tree.active_formatting.length;

    while (idx != 0) {
        idx--;

        if (list[idx] == node) {
            delta = tree.active_formatting.length - idx - 1;

            memmove(list + idx, list + idx + 1, (void*).sizeof * delta);

            tree.active_formatting.length--;

            break;
        }
    }
}

bool lxb_html_tree_active_formatting_find_by_node(lxb_html_tree_t* tree, lxb_dom_node_t* node, size_t* return_pos)
{
    void** list = tree.active_formatting.list;

    for (size_t i = 0; i < tree.active_formatting.length; i++) {
        if (list[i] == node) {
            if (return_pos) {
                *return_pos = i;
            }

            return true;
        }
    }

    if (return_pos) {
        *return_pos = 0;
    }

    return false;
}

bool lxb_html_tree_active_formatting_find_by_node_reverse(lxb_html_tree_t* tree, lxb_dom_node_t* node, size_t* return_pos)
{
    void** list = tree.active_formatting.list;
    size_t len = tree.active_formatting.length;

    while (len != 0) {
        len--;

        if (list[len] == node) {
            if (return_pos) {
                *return_pos = len;
            }

            return true;
        }
    }

    if (return_pos) {
        *return_pos = 0;
    }

    return false;
}

lxb_status_t lxb_html_tree_active_formatting_reconstruct_elements(lxb_html_tree_t* tree)
{
    /* Step 1 */
    if (tree.active_formatting.length == 0) {
        return LXB_STATUS_OK;
    }

    lexbor_array_t* af = tree.active_formatting;
    void** list = af.list;

    /* Step 2-3 */
    size_t af_idx = af.length - 1;

    if(list[af_idx] == &lxb_html_tree_active_formatting_marker_static
       || lxb_html_tree_open_elements_find_by_node_reverse(tree, cast(lxb_dom_node*) list[af_idx],
                                                           null))
    {
        return LXB_STATUS_OK;
    }

    /*
     * Step 4-6
     * Rewind
     */
    while (af_idx != 0) {
        af_idx--;

        if(list[af_idx] == &lxb_html_tree_active_formatting_marker_static ||
           lxb_html_tree_open_elements_find_by_node_reverse(tree, cast(lxb_dom_node*) list[af_idx],
                                                            null))
        {
            /* Step 7 */
            af_idx++;

            break;
        }
    }

    /*
     * Step 8-10
     * Create
     */
    lxb_dom_node_t* node = void;
    lxb_html_element_t* element = void;
    lxb_html_token_t fake_token; // C: = {0}

    while (af_idx < af.length) {
        node = cast(lxb_dom_node*) list[af_idx];

        fake_token.tag_id = node.local_name;
        fake_token.base_element = node;

        element = lxb_html_tree_insert_html_element(tree, &fake_token);
        if (element == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        /* Step 9 */
        list[af_idx] = (cast(lxb_dom_node_t*) (element));

        /* Step 10 */
        af_idx++;
    }

    return LXB_STATUS_OK;
}

lxb_dom_node_t* lxb_html_tree_active_formatting_between_last_marker(lxb_html_tree_t* tree, lxb_tag_id_t tag_idx, size_t* return_idx)
{
    lxb_dom_node_t** list = cast(lxb_dom_node_t**) tree.active_formatting.list;
    size_t idx = tree.active_formatting.length;

    while (idx) {
        idx--;

        if (list[idx] == lxb_html_tree_active_formatting_marker_node_static) {
            return null;
        }

        if (list[idx].local_name == tag_idx && list[idx].ns == LXB_NS_HTML) {
            if (return_idx) {
                *return_idx = idx;
            }

            return list[idx];
        }
    }

    return null;
}

void lxb_html_tree_active_formatting_push_with_check_dupl(lxb_html_tree_t* tree, lxb_dom_node_t* node)
{
    lxb_dom_node_t** list = cast(lxb_dom_node_t**) tree.active_formatting.list;
    size_t idx = tree.active_formatting.length;
    size_t earliest_idx = (idx ? (idx - 1) : 0);
    size_t count = 0;

    while (idx) {
        idx--;

        if (list[idx] == lxb_html_tree_active_formatting_marker_node_static) {
            break;
        }

        if(list[idx].local_name == node.local_name && list[idx].ns == node.ns
            && lxb_dom_element_compare((cast(lxb_dom_element_t*) (list[idx])),
                                       (cast(lxb_dom_element_t*) (node))))
        {
            count++;
            earliest_idx = idx;
        }
    }

    if(count >= 3) {
        lxb_html_tree_active_formatting_remove(tree, earliest_idx);
    }

    lxb_html_tree_active_formatting_push(tree, node);
}
