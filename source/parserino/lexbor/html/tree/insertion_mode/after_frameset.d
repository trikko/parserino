module parserino.lexbor.html.tree.insertion_mode.after_frameset;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

import parserino.lexbor.html.tree.insertion_mode;

extern(C) @nogc nothrow:
__gshared:

// ---- after_frameset.c ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

bool lxb_html_tree_insertion_mode_after_frameset(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    switch (token.tag_id) {
        case LXB_TAG__EM_COMMENT: {
            lxb_dom_comment_t* comment = void;

            comment = lxb_html_tree_insert_comment(tree, token, null);
            if (comment == null) {
                return lxb_html_tree_process_abort(tree);
            }

            break;
        }

        case LXB_TAG__EM_DOCTYPE:
            lxb_html_tree_parse_error(tree, token,
                                      LXB_HTML_RULES_ERROR_DOTOAFFRMO);
            break;

        case LXB_TAG_HTML:
            if (token.type & LXB_HTML_TOKEN_TYPE_CLOSE) {
                tree.mode = &lxb_html_tree_insertion_mode_after_after_frameset;

                return true;
            }

            return lxb_html_tree_insertion_mode_in_body(tree, token);

        case LXB_TAG_NOFRAMES:
            return lxb_html_tree_insertion_mode_in_head(tree, token);

        case LXB_TAG__END_OF_FILE: {
            tree.status = lxb_html_tree_stop_parsing(tree);
            if (tree.status != LXB_STATUS_OK) {
                return lxb_html_tree_process_abort(tree);
            }

            break;
        }

        case LXB_TAG__TEXT: {
            size_t cur_len = void;
            lexbor_str_t str = void;

            tree.status = lxb_html_token_make_text(token, &str,
                                                    tree.document.dom_document.text);
            if (tree.status != LXB_STATUS_OK) {
                return lxb_html_tree_process_abort(tree);
            }

            cur_len = str.length;

            lexbor_str_stay_only_whitespace(&str);

            if (str.length != 0) {
                tree.status = lxb_html_tree_insert_character_for_data(tree,
                                                                       &str,
                                                                       null);
                if (tree.status != LXB_STATUS_OK) {
                    return lxb_html_tree_process_abort(tree);
                }
            }

            if (str.length == cur_len) {
                return true;
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
