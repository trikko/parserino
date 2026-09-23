module parserino.lexbor.html.tree.insertion_mode.before_html;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

import parserino.lexbor.html.tree.insertion_mode;
import parserino.lexbor.html.tree.open_elements;
import parserino.lexbor.html.interfaces.html_element;

extern(C) @nogc nothrow:
__gshared:

// ---- before_html.c ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */





 

 

bool lxb_html_tree_insertion_mode_before_html(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    if (token.type & LXB_HTML_TOKEN_TYPE_CLOSE) {
        return lxb_html_tree_insertion_mode_before_html_closed(tree, token);{}
    }

    return lxb_html_tree_insertion_mode_before_html_open(tree, token);
}

private bool lxb_html_tree_insertion_mode_before_html_open(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_processing_instruction_t* pi = void;

    switch (token.tag_id) {
        case LXB_TAG__EM_DOCTYPE:
            lxb_html_tree_parse_error(tree, token,
                                      LXB_HTML_RULES_ERROR_DOTOINBEHTMO);
            break;

        case LXB_TAG__EM_COMMENT: {
            lxb_dom_comment_t* comment = void;

            comment = lxb_html_tree_insert_comment(tree, token,
                                        (cast(lxb_dom_node_t*) (tree.document)));
            if (comment == null) {
                return lxb_html_tree_process_abort(tree);
            }

            break;
        }

        case LXB_TAG__PROCESSINGINSTRUCTION:
            pi = lxb_html_tree_insert_processing_instruction(tree, token,
                                        (cast(lxb_dom_node_t*) (tree.document)));
            if (pi == null) {
                return lxb_html_tree_process_abort(tree);
            }

            break;

        case LXB_TAG_HTML: {
            lxb_dom_node_t* node_html = void;
            lxb_html_element_t* element = void;

            element = lxb_html_tree_create_element_for_token(tree, token,
                                            LXB_NS_HTML);
            if (element == null) {
                tree.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;

                return lxb_html_tree_process_abort(tree);
            }

            node_html = (cast(lxb_dom_node_t*) (element));

            tree.status = lxb_html_tree_insertion_mode_before_html_html(tree,
                                                                     node_html);
            if (tree.status != LXB_STATUS_OK) {
                return lxb_html_tree_process_abort(tree);
            }

            tree.mode = &lxb_html_tree_insertion_mode_before_head;

            break;
        }

        case LXB_TAG__TEXT:
            tree.status = lxb_html_token_data_skip_ws_begin(token);
            if (tree.status != LXB_STATUS_OK) {
                return lxb_html_tree_process_abort(tree);
            }

            if (token.text_start == token.text_end) {
                return true;
            }
            /* fall through */

            goto default; /* C fallthrough */
        default:
            return lxb_html_tree_insertion_mode_before_html_anything_else(tree);
    }

    return true;
}

private bool lxb_html_tree_insertion_mode_before_html_closed(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    switch (token.tag_id) {
        case LXB_TAG_HEAD:
        case LXB_TAG_BODY:
        case LXB_TAG_HTML:
        case LXB_TAG_BR:
            return lxb_html_tree_insertion_mode_before_html_anything_else(tree);

        default:
            lxb_html_tree_parse_error(tree, token,
                                      LXB_HTML_RULES_ERROR_UNCLTOINBEHTMO);
            break;
    }

    return true;
}

 bool lxb_html_tree_insertion_mode_before_html_anything_else(lxb_html_tree_t* tree)
{
    lxb_dom_node_t* node_html = void;

    node_html = lxb_html_tree_create_node(tree, LXB_TAG_HTML, LXB_NS_HTML);
    if (node_html == null) {
        tree.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        return lxb_html_tree_process_abort(tree);
    }

    tree.status = lxb_html_tree_insertion_mode_before_html_html(tree,
                                                                 node_html);
    if (tree.status != LXB_STATUS_OK) {
        return lxb_html_tree_process_abort(tree);
    }

    tree.mode = &lxb_html_tree_insertion_mode_before_head;

    return false;
}

 lxb_status_t lxb_html_tree_insertion_mode_before_html_html(lxb_html_tree_t* tree, lxb_dom_node_t* node_html)
{
    lxb_status_t status = void;

    status = lxb_html_tree_open_elements_push(tree, node_html);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    lxb_html_tree_insert_node((cast(lxb_dom_node_t*) (tree.document)),
                              node_html,
                              LXB_HTML_TREE_INSERTION_POSITION_CHILD);

    lxb_dom_document_attach_element(&tree.document.dom_document,
                                    (cast(lxb_dom_element_t*) (node_html)));

    return LXB_STATUS_OK;
}
