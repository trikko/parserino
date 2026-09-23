module parserino.lexbor.html.tree.insertion_mode.text;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

import parserino.lexbor.html.tree.insertion_mode;
import parserino.lexbor.html.tree.open_elements;
import parserino.lexbor.html.interfaces.style_element;

extern(C) @nogc nothrow:
__gshared:

// ---- text.c ----
/*
 * Copyright (C) 2018-2023 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

bool lxb_html_tree_insertion_mode_text(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_node_t* node = void;
    const(lxb_html_document_parse_cb_t)* pcb = void;

    switch (token.tag_id) {
        case LXB_TAG__TEXT: {
            tree.status = lxb_html_tree_insert_character(tree, token, null);
            if (tree.status != LXB_STATUS_OK) {
                return lxb_html_tree_process_abort(tree);
            }

            break;
        }

        case LXB_TAG__END_OF_FILE: {
            lxb_dom_node_t* node_c = void;

            lxb_html_tree_parse_error(tree, token,
                                      LXB_HTML_RULES_ERROR_UNENOFFI);

            node_c = lxb_html_tree_current_node(tree);

            if (lxb_html_tree_node_is(node_c, LXB_TAG_SCRIPT)) {
                /* TODO: mark the script element as "already started" */
            }

            lxb_html_tree_open_elements_pop(tree);

            tree.mode = tree.original_mode;

            return false;
        }

        /* TODO: need to implement */
        case LXB_TAG_SCRIPT:
            node = lxb_html_tree_open_elements_pop(tree);

            tree.mode = tree.original_mode;
            pcb = tree.document.parse_cb;

            if (pcb == null || pcb.script == null) {
                break;
            }

            tree.status = pcb.script(tree, node);
            if (tree.status != LXB_STATUS_OK) {
                return lxb_html_tree_process_abort(tree);
            }

            break;

        case LXB_TAG_STYLE:
            node = lxb_html_tree_open_elements_pop(tree);

            tree.mode = tree.original_mode;
            pcb = tree.document.parse_cb;

            if (pcb == null || pcb.style == null) {
                break;
            }

            tree.status = pcb.style(tree, node);
            if (tree.status != LXB_STATUS_OK) {
                return lxb_html_tree_process_abort(tree);
            }

            break;

        default:
            lxb_html_tree_open_elements_pop(tree);

            tree.mode = tree.original_mode;

            break;
    }

    return true;
}
