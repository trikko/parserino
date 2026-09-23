module parserino.lexbor.html.tree.insertion_mode.in_select;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

import parserino.lexbor.html.tree.insertion_mode;
import parserino.lexbor.html.tree.open_elements;

extern(C) @nogc nothrow:
__gshared:

// ---- in_select.c ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

 bool lxb_html_tree_insertion_mode_in_select_text(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lexbor_str_t str = void;

    if (token.null_count != 0) {
        lxb_html_tree_parse_error(tree, token,
                                  LXB_HTML_RULES_ERROR_NUCH);

        tree.status = lxb_html_token_make_text_drop_null(token, &str,
                                                          tree.document.dom_document.text);
    }
    else {
        tree.status = lxb_html_token_make_text(token, &str,
                                                tree.document.dom_document.text);
    }

    if (tree.status != LXB_STATUS_OK) {
        return lxb_html_tree_process_abort(tree);
    }

    /* Can be zero only if all NULL are gone */
    if (str.length == 0) {
        lexbor_str_destroy(&str, tree.document.dom_document.text, false);

        return true;
    }

    tree.status = lxb_html_tree_insert_character_for_data(tree, &str, null);
    if (tree.status != LXB_STATUS_OK) {
        return lxb_html_tree_process_abort(tree);
    }

    return true;
}

 bool lxb_html_tree_insertion_mode_in_select_comment(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_comment_t* comment = void;

    comment = lxb_html_tree_insert_comment(tree, token, null);
    if (comment == null) {
        tree.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;

        return lxb_html_tree_process_abort(tree);
    }

    return true;
}

 bool lxb_html_tree_insertion_mode_in_select_doctype(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_html_tree_parse_error(tree, token, LXB_HTML_RULES_ERROR_DOTOINSEMO);

    return true;
}

 bool lxb_html_tree_insertion_mode_in_select_html(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    return lxb_html_tree_insertion_mode_in_body(tree, token);
}

 bool lxb_html_tree_insertion_mode_in_select_option(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_html_element_t* element = void;
    lxb_dom_node_t* node = lxb_html_tree_current_node(tree);

    if (lxb_html_tree_node_is(node, LXB_TAG_OPTION)) {
        lxb_html_tree_open_elements_pop(tree);
    }

    element = lxb_html_tree_insert_html_element(tree, token);
    if (element == null) {
        tree.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;

        return lxb_html_tree_process_abort(tree);
    }

    return true;
}

 bool lxb_html_tree_insertion_mode_in_select_optgroup(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_html_element_t* element = void;
    lxb_dom_node_t* node = lxb_html_tree_current_node(tree);

    if (lxb_html_tree_node_is(node, LXB_TAG_OPTION)) {
        lxb_html_tree_open_elements_pop(tree);
    }

    node = lxb_html_tree_current_node(tree);

    if (lxb_html_tree_node_is(node, LXB_TAG_OPTGROUP)) {
        lxb_html_tree_open_elements_pop(tree);
    }

    element = lxb_html_tree_insert_html_element(tree, token);
    if (element == null) {
        tree.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;

        return lxb_html_tree_process_abort(tree);
    }

    return true;
}

 bool lxb_html_tree_insertion_mode_in_select_hr(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_html_element_t* element = void;
    lxb_dom_node_t* node = lxb_html_tree_current_node(tree);

    if (lxb_html_tree_node_is(node, LXB_TAG_OPTION)) {
        lxb_html_tree_open_elements_pop(tree);
    }

    node = lxb_html_tree_current_node(tree);

    if (lxb_html_tree_node_is(node, LXB_TAG_OPTGROUP)) {
        lxb_html_tree_open_elements_pop(tree);
    }

    element = lxb_html_tree_insert_html_element(tree, token);
    if (element == null) {
        tree.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;

        return lxb_html_tree_process_abort(tree);
    }

    lxb_html_tree_open_elements_pop(tree);

    lxb_html_tree_acknowledge_token_self_closing(tree, token);

    return true;
}

 bool lxb_html_tree_insertion_mode_in_select_optgroup_closed(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_node_t* node = lxb_html_tree_current_node(tree);

    if (lxb_html_tree_node_is(node, LXB_TAG_OPTION)
        && tree.open_elements.length > 1)
    {
        node = lxb_html_tree_open_elements_get(tree,
                                               tree.open_elements.length - 2);
        if (node != null && lxb_html_tree_node_is(node, LXB_TAG_OPTGROUP)) {
            lxb_html_tree_open_elements_pop(tree);
        }
    }

    node = lxb_html_tree_current_node(tree);

    if (lxb_html_tree_node_is(node, LXB_TAG_OPTGROUP) == false) {
        lxb_html_tree_parse_error(tree, token,
                                  LXB_HTML_RULES_ERROR_UNELINOPELST);
        return true;
    }

    lxb_html_tree_open_elements_pop(tree);

    return true;
}

 bool lxb_html_tree_insertion_mode_in_select_option_closed(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_node_t* node = lxb_html_tree_current_node(tree);

    if (lxb_html_tree_node_is(node, LXB_TAG_OPTION) == false) {
        lxb_html_tree_parse_error(tree, token,
                                  LXB_HTML_RULES_ERROR_UNELINOPELST);
        return true;
    }

    lxb_html_tree_open_elements_pop(tree);

    return true;
}

 bool lxb_html_tree_insertion_mode_in_select_select_closed(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_node_t* node = void;

    node = lxb_html_tree_element_in_scope(tree, LXB_TAG_SELECT, LXB_NS_HTML,
                                          LXB_HTML_TAG_CATEGORY_SCOPE_SELECT);
    if (node == null) {
        lxb_html_tree_parse_error(tree, token, LXB_HTML_RULES_ERROR_UNCLTO);

        return true;
    }

    lxb_html_tree_open_elements_pop_until_tag_id(tree, LXB_TAG_SELECT,
                                                 LXB_NS_HTML, true);

    lxb_html_tree_reset_insertion_mode_appropriately(tree);

    return true;
}

 bool lxb_html_tree_insertion_mode_in_select_select(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_node_t* node = void;

    lxb_html_tree_parse_error(tree, token, LXB_HTML_RULES_ERROR_UNTO);

    node = lxb_html_tree_element_in_scope(tree, LXB_TAG_SELECT, LXB_NS_HTML,
                                          LXB_HTML_TAG_CATEGORY_SCOPE_SELECT);
    if (node == null) {
        return true;
    }

    lxb_html_tree_open_elements_pop_until_tag_id(tree, LXB_TAG_SELECT,
                                                 LXB_NS_HTML, true);

    lxb_html_tree_reset_insertion_mode_appropriately(tree);

    return true;
}

/*
 * "input", "keygen", "textarea"
 */
 bool lxb_html_tree_insertion_mode_in_select_ikt(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_node_t* node = void;

    lxb_html_tree_parse_error(tree, token, LXB_HTML_RULES_ERROR_UNTO);

    node = lxb_html_tree_element_in_scope(tree, LXB_TAG_SELECT, LXB_NS_HTML,
                                          LXB_HTML_TAG_CATEGORY_SCOPE_SELECT);
    if (node == null) {
        return true;
    }

    lxb_html_tree_open_elements_pop_until_tag_id(tree, LXB_TAG_SELECT,
                                                 LXB_NS_HTML, true);

    lxb_html_tree_reset_insertion_mode_appropriately(tree);

    return false;
}

/*
 * A start tag whose tag name is one of: "script", "template"
 * An end tag whose tag name is "template"
 */
 bool lxb_html_tree_insertion_mode_in_select_st_open_closed(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    return lxb_html_tree_insertion_mode_in_head(tree, token);
}

 bool lxb_html_tree_insertion_mode_in_select_end_of_file(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    return lxb_html_tree_insertion_mode_in_body(tree, token);
}

 bool lxb_html_tree_insertion_mode_in_select_anything_else(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_html_tree_parse_error(tree, token, LXB_HTML_RULES_ERROR_UNTO);

    return true;
}

 bool lxb_html_tree_insertion_mode_in_select_anything_else_closed(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_html_tree_parse_error(tree, token, LXB_HTML_RULES_ERROR_UNCLTO);

    return true;
}

bool lxb_html_tree_insertion_mode_in_select(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    if (token.type & LXB_HTML_TOKEN_TYPE_CLOSE) {
        switch (token.tag_id) {
            case LXB_TAG_OPTGROUP:
                return lxb_html_tree_insertion_mode_in_select_optgroup_closed(tree,
                                                                              token);
            case LXB_TAG_OPTION:
                return lxb_html_tree_insertion_mode_in_select_option_closed(tree,
                                                                            token);
            case LXB_TAG_SELECT:
                return lxb_html_tree_insertion_mode_in_select_select_closed(tree,
                                                                            token);
            case LXB_TAG_TEMPLATE:
                return lxb_html_tree_insertion_mode_in_select_st_open_closed(tree,
                                                                             token);
            default:
                return lxb_html_tree_insertion_mode_in_select_anything_else_closed(tree,
                                                                                   token);
        }
    }

    switch (token.tag_id) {
        case LXB_TAG__TEXT:
            return lxb_html_tree_insertion_mode_in_select_text(tree, token);

        case LXB_TAG__EM_COMMENT:
            return lxb_html_tree_insertion_mode_in_select_comment(tree, token);

        case LXB_TAG__EM_DOCTYPE:
            return lxb_html_tree_insertion_mode_in_select_doctype(tree, token);

        case LXB_TAG_HTML:
            return lxb_html_tree_insertion_mode_in_select_html(tree, token);

        case LXB_TAG_OPTION:
            return lxb_html_tree_insertion_mode_in_select_option(tree, token);

        case LXB_TAG_OPTGROUP:
            return lxb_html_tree_insertion_mode_in_select_optgroup(tree, token);

        case LXB_TAG_HR:
            return lxb_html_tree_insertion_mode_in_select_hr(tree, token);

        case LXB_TAG_SELECT:
            return lxb_html_tree_insertion_mode_in_select_select(tree, token);

        case LXB_TAG_INPUT:
        case LXB_TAG_KEYGEN:
        case LXB_TAG_TEXTAREA:
            return lxb_html_tree_insertion_mode_in_select_ikt(tree, token);

        case LXB_TAG_SCRIPT:
        case LXB_TAG_TEMPLATE:
            return lxb_html_tree_insertion_mode_in_select_st_open_closed(tree,
                                                                         token);
        case LXB_TAG__END_OF_FILE:
            return lxb_html_tree_insertion_mode_in_select_end_of_file(tree,
                                                                      token);
        default:
            return lxb_html_tree_insertion_mode_in_select_anything_else(tree,
                                                                        token);
    }
}
