module parserino.lexbor.html.interfaces.select_element;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.interface_;
public import parserino.lexbor.html.interfaces.element;
import parserino.lexbor.html.interfaces.option_element;
import parserino.lexbor.html.interfaces.document;
import parserino.lexbor.html.interfaces.selectedcontent_element;
import parserino.lexbor.html.common;
import parserino.lexbor.dom.exception;

extern(C) @nogc nothrow:
__gshared:

// ---- select_element.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_html_select_options_cb_f = lxb_status_t function(lxb_html_select_element_t* el, lxb_html_option_element_t* option, void* ctx);

struct lxb_html_select_element {
    lxb_html_element_t element;
}







// ---- select_element.c ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

struct lxb_html_select_selectedness_ctx_t {
    lxb_html_option_element_t* first;
    lxb_html_option_element_t* last;
    size_t selected;
}





lxb_html_select_element_t* lxb_html_select_element_interface_create(lxb_html_document_t* document)
{
    lxb_html_select_element_t* element = void;

    element = cast(lxb_html_select_element*) lexbor_mraw_calloc(document.dom_document.mraw,
                                 lxb_html_select_element_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_html_document_original_ref(document);
    node.type = LXB_DOM_NODE_TYPE_ELEMENT;

    return element;
}

lxb_html_select_element_t* lxb_html_select_element_interface_destroy(lxb_html_select_element_t* select_element)
{
    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (select_element)));
    return null;
}

size_t lxb_html_select_selectedness_display_size(lxb_html_select_element_t* el)
{
    long len = void;
    lexbor_str_t* value = void;
    lxb_status_t status = void;
    lxb_dom_attr_t* size = void, multiple = void;

    size = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (el)),
                                      LXB_DOM_ATTR_SIZE);
    if (size == null) {
        goto default_size;
    }

    value = size.value;

    if (value == null) {
        goto default_size;
    }

    status = lxb_html_common_parsing_nonneg_integer(value.data, value.length,
                                                    &len);
    if (status != LXB_STATUS_OK || len < 0) {
        goto default_size;
    }

    return cast(size_t) len;

default_size:

    multiple = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (el)),
                                          LXB_DOM_ATTR_MULTIPLE);
    if (multiple == null) {
        return 1;
    }

    return 4;
}

lxb_dom_exception_code_t lxb_html_select_selectedness_setting_algorithm(lxb_html_select_element_t* el)
{
    lxb_status_t status = void;
    size_t display_size = void;
    lxb_dom_attr_t* multiple = void;
    lxb_html_select_selectedness_ctx_t snctx = void;

    multiple = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (el)),
                                           LXB_DOM_ATTR_MULTIPLE);
    if (multiple != null) {
        return LXB_DOM_EXCEPTION_OK;
    }

    /*
     * Step 1. If the element's multiple attribute is absent, and the element's
     * display size is 1, and no option elements in the element's list of
     * options have their selectedness set to true, then set the selectedness
     * of the first option element in the list of options in tree order that is
     * not disabled, if any, to true and return.
     */

    display_size = lxb_html_select_selectedness_display_size(el);

    if (display_size == 1) {
        snctx.first = null;
        snctx.last = null;
        snctx.selected = 0;

        status = lxb_html_select_list_of_options(el,
                                                 &lxb_html_select_selectedness_one_cb,
                                                 &snctx);
        if (status != LXB_STATUS_OK) {
            return LXB_DOM_EXCEPTION_ERR;
        }

        if (snctx.selected == 0) {
            if (snctx.first != null) {
                snctx.first.selectedness = true;
            }

            return LXB_DOM_EXCEPTION_OK;
        }
    }

    /*
     * Step 2. If the element's multiple attribute is absent, and two or more
     * option elements in the element's list of options have their selectedness
     * set to true, then set the selectedness of all but the last option element
     * with its selectedness set to true in the list of options in tree order
     * to false.
     */

    if (snctx.selected >= 2) {
        status = lxb_html_select_list_of_options(el,
                                                 &lxb_html_select_selectedness_two_cb,
                                                 &snctx);
        if (status != LXB_STATUS_OK) {
            return LXB_DOM_EXCEPTION_ERR;
        }
    }

    return LXB_DOM_EXCEPTION_OK;
}

private lxb_status_t lxb_html_select_selectedness_one_cb(lxb_html_select_element_t* el, lxb_html_option_element_t* option, void* ctx)
{
    lxb_html_select_selectedness_ctx_t* snctx = cast(lxb_html_select_selectedness_ctx_t*) ctx;

    if (option.selectedness) {
        snctx.selected += 1;
        snctx.last = option;
    }

    if (snctx.first == null
        && !lxb_html_option_is_disabled(option))
    {
        snctx.first = option;
    }

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_select_selectedness_two_cb(lxb_html_select_element_t* el, lxb_html_option_element_t* option, void* ctx)
{
    lxb_html_select_selectedness_ctx_t* snctx = cast(lxb_html_select_selectedness_ctx_t*) ctx;

    if (option.selectedness && option != snctx.last) {
        option.selectedness = false;
    }

    return LXB_STATUS_OK;
}

lxb_html_selectedcontent_element_t* lxb_html_select_get_enabled_selectedcontent(lxb_html_select_element_t* el)
{
    lxb_dom_attr_t* multiple = void;
    lxb_dom_node_t* selectedcontent = void, node = void;
    lxb_html_selectedcontent_element_t* sc = void;

    multiple = lxb_dom_element_attr_by_id((cast(lxb_dom_element_t*) (el)),
                                          LXB_DOM_ATTR_MULTIPLE);
    if (multiple != null) {
        return null;
    }

    selectedcontent = null;
    node = (cast(lxb_dom_node_t*) (el));

    lxb_dom_node_simple_walk(node, &lxb_html_select_find_selectedcontent_cb,
                             &selectedcontent);
    if (selectedcontent == null) {
        return null;
    }

    sc = (cast(lxb_html_selectedcontent_element_t*) selectedcontent);

    return sc.disabled ? null : sc;
}

private lexbor_action_t lxb_html_select_find_selectedcontent_cb(lxb_dom_node_t* node, void* ctx)
{
    lxb_dom_node_t** selectedcontent = void;

    if (node.local_name == LXB_TAG_SELECTEDCONTENT
        && node.ns == LXB_NS_HTML)
    {
        selectedcontent = cast(lxb_dom_node**) ctx;
        *selectedcontent = node;

        return LEXBOR_ACTION_STOP;
    }

    return LEXBOR_ACTION_OK;
}

lxb_status_t lxb_html_select_element_insert_steps(lxb_dom_node_t* inserted_node)
{
    lxb_html_select_element_t* select = (cast(lxb_html_select_element_t*) (inserted_node));

    cast(void) lxb_html_select_selectedness_setting_algorithm(select);

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_select_list_of_options(lxb_html_select_element_t* el, lxb_html_select_options_cb_f walker_cb, void* ctx)
{
    bool skip = void;
    lxb_status_t status = void;
    lxb_dom_node_t* node = void, root = void, optgroup = void;

    root = (cast(lxb_dom_node_t*) (el));
    node = root.first_child;

    while (node != null) {
        if (node.local_name == LXB_TAG_OPTION && node.ns == LXB_NS_HTML) {
            status = walker_cb(el, (cast(lxb_html_option_element_t*) (node)), ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }
        }

        skip = false;

        if (node.ns == LXB_NS_HTML) {
            switch (node.local_name) {
                case LXB_TAG_SELECT:
                case LXB_TAG_DATALIST:
                case LXB_TAG_HR:
                case LXB_TAG_OPTION:
                    skip = true;
                    break;

                case LXB_TAG_OPTGROUP:
                    optgroup = node.parent;

                    while (optgroup != root) {
                        if (optgroup.local_name != LXB_TAG_OPTGROUP
                            && optgroup.ns == LXB_NS_HTML)
                        {
                            skip = true;
                            break;
                        }

                        optgroup = optgroup.parent;
                    }

                    break;

                default:
                    break;
            }
        }

        if (node.first_child != null && skip) {
            node = node.first_child;
        }
        else {
            while(node != root && node.next == null) {
                node = node.parent;
            }

            if (node == root) {
                break;
            }

            node = node.next;
        }
    }

    return LXB_STATUS_OK;
}
