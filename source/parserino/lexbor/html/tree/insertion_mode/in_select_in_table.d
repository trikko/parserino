module parserino.lexbor.html.tree.insertion_mode.in_select_in_table;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

import parserino.lexbor.html.tree.insertion_mode;
import parserino.lexbor.html.tree.open_elements;

extern(C) @nogc nothrow:
__gshared:

// ---- in_select_in_table.c ----
/*
 * Copyright (C) 2018-2019 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

/*
 * "caption", "table", "tbody", "tfoot", "thead", "tr", "td", "th"
 */
 bool lxb_html_tree_insertion_mode_in_select_in_table_ct(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_html_tree_parse_error(tree, token, LXB_HTML_RULES_ERROR_UNTO);

    lxb_html_tree_open_elements_pop_until_tag_id(tree, LXB_TAG_SELECT,
                                                 LXB_NS_HTML, true);

    lxb_html_tree_reset_insertion_mode_appropriately(tree);

    return false;
}

/*
 * "caption", "table", "tbody", "tfoot", "thead", "tr", "td", "th"
 */
 bool lxb_html_tree_insertion_mode_in_select_in_table_ct_closed(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_node_t* node = void;

    lxb_html_tree_parse_error(tree, token, LXB_HTML_RULES_ERROR_UNCLTO);

    node = lxb_html_tree_element_in_scope(tree, token.tag_id, LXB_NS_HTML,
                                          LXB_HTML_TAG_CATEGORY_SCOPE_TABLE);
    if (node == null) {
        return true;
    }

    lxb_html_tree_open_elements_pop_until_tag_id(tree, LXB_TAG_SELECT,
                                                 LXB_NS_HTML, true);

    lxb_html_tree_reset_insertion_mode_appropriately(tree);

    return false;
}

 bool lxb_html_tree_insertion_mode_in_select_in_table_anything_else(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    return lxb_html_tree_insertion_mode_in_select(tree, token);
}

 bool lxb_html_tree_insertion_mode_in_select_in_table_anything_else_closed(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    return lxb_html_tree_insertion_mode_in_select_in_table_anything_else(tree,
                                                                         token);
}

bool lxb_html_tree_insertion_mode_in_select_in_table(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    if (token.tag_id >= LXB_TAG__LAST_ENTRY) {
        if (token.type & LXB_HTML_TOKEN_TYPE_CLOSE) {
            return lxb_html_tree_insertion_mode_in_select_in_table_anything_else_closed(tree,
                                                                                        token);
        }

        return lxb_html_tree_insertion_mode_in_select_in_table_anything_else(tree,
                                                                             token);
    }

    if (token.type & LXB_HTML_TOKEN_TYPE_CLOSE) {
        switch (token.tag_id) {
            case LXB_TAG_CAPTION:
            case LXB_TAG_TABLE:
            case LXB_TAG_TBODY:
            case LXB_TAG_TFOOT:
            case LXB_TAG_THEAD:
            case LXB_TAG_TR:
            case LXB_TAG_TH:
            case LXB_TAG_TD:
                return lxb_html_tree_insertion_mode_in_select_in_table_ct_closed(tree,
                                                                                 token);
            default:
                return lxb_html_tree_insertion_mode_in_select_in_table_anything_else_closed(tree,
                                                                                            token);
        }
    }

    switch (token.tag_id) {
        case LXB_TAG_CAPTION:
        case LXB_TAG_TABLE:
        case LXB_TAG_TBODY:
        case LXB_TAG_TFOOT:
        case LXB_TAG_THEAD:
        case LXB_TAG_TR:
        case LXB_TAG_TH:
        case LXB_TAG_TD:
            return lxb_html_tree_insertion_mode_in_select_in_table_ct(tree,
                                                                      token);
        default:
            return lxb_html_tree_insertion_mode_in_select_in_table_anything_else(tree,
                                                                                 token);
    }
}
