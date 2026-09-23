module parserino.lexbor.html.tree.insertion_mode.after_after_frameset;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

import parserino.lexbor.html.tree.insertion_mode;

extern(C) @nogc nothrow:
__gshared:

// ---- after_after_frameset.c ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

bool lxb_html_tree_insertion_mode_after_after_frameset(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_processing_instruction_t* pi = void;

    switch (token.tag_id) {
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

        case LXB_TAG__EM_DOCTYPE:
        case LXB_TAG_HTML:
            return lxb_html_tree_insertion_mode_in_body(tree, token);

        case LXB_TAG__END_OF_FILE:
            tree.status = lxb_html_tree_stop_parsing(tree);
            if (tree.status != LXB_STATUS_OK) {
                return lxb_html_tree_process_abort(tree);
            }

            break;

        case LXB_TAG_NOFRAMES:
            return lxb_html_tree_insertion_mode_in_head(tree, token);

        case LXB_TAG__TEXT: {
            lxb_html_token_t ws_token = *token;

            tree.status = lxb_html_token_data_skip_ws_begin(&ws_token);
            if (tree.status != LXB_STATUS_OK) {
                return lxb_html_tree_process_abort(tree);
            }

            if (ws_token.text_start == ws_token.text_end) {
                return lxb_html_tree_insertion_mode_in_body(tree, token);
            }
        }
        /* fall through */

            goto default; /* C fallthrough */
        default:
            lxb_html_tree_parse_error(tree, token, LXB_HTML_RULES_ERROR_UNTO);

            break;
    }

    return true;
}
