module parserino.lexbor.html.tree.insertion_mode.initial;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

import parserino.lexbor.html.tree.insertion_mode;
import parserino.lexbor.dom.interfaces.document_type;

extern(C) @nogc nothrow:
__gshared:

// ---- initial.c ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

struct lxb_html_tree_insertion_mode_initial_str_t {
    const(char)* data;
    size_t len;
}

private lxb_html_tree_insertion_mode_initial_str_t[3] lxb_html_tree_insertion_mode_initial_doctype_public_is = [
    {"-//W3O//DTD W3 HTML Strict 3.0//EN//", 36},
    {"-/W3C/DTD HTML 4.0 Transitional/EN", 34},
    {"HTML", 4}
];

private lxb_html_tree_insertion_mode_initial_str_t[1] lxb_html_tree_insertion_mode_initial_doctype_system_is = [
    {"http://www.ibm.com/data/dtd/v11/ibmxhtml1-transitional.dtd", 58}
];

private lxb_html_tree_insertion_mode_initial_str_t[55] lxb_html_tree_insertion_mode_initial_doctype_public_start = [
    {"+//Silmaril//dtd html Pro v0r11 19970101//", 42},
    {"-//AS//DTD HTML 3.0 asWedit + extensions//", 42},
    {"-//AdvaSoft Ltd//DTD HTML 3.0 asWedit + extensions//", 52},
    {"-//IETF//DTD HTML 2.0 Level 1//", 31},
    {"-//IETF//DTD HTML 2.0 Level 2//", 31},
    {"-//IETF//DTD HTML 2.0 Strict Level 1//", 38},
    {"-//IETF//DTD HTML 2.0 Strict Level 2//", 38},
    {"-//IETF//DTD HTML 2.0 Strict//", 30},
    {"-//IETF//DTD HTML 2.0//", 23},
    {"-//IETF//DTD HTML 2.1E//", 24},
    {"-//IETF//DTD HTML 3.0//", 23},
    {"-//IETF//DTD HTML 3.2 Final//", 29},
    {"-//IETF//DTD HTML 3.2//", 23},
    {"-//IETF//DTD HTML 3//", 21},
    {"-//IETF//DTD HTML Level 0//", 27},
    {"-//IETF//DTD HTML Level 1//", 27},
    {"-//IETF//DTD HTML Level 2//", 27},
    {"-//IETF//DTD HTML Level 3//", 27},
    {"-//IETF//DTD HTML Strict Level 0//", 34},
    {"-//IETF//DTD HTML Strict Level 1//", 34},
    {"-//IETF//DTD HTML Strict Level 2//", 34},
    {"-//IETF//DTD HTML Strict Level 3//", 34},
    {"-//IETF//DTD HTML Strict//", 26},
    {"-//IETF//DTD HTML//", 19},
    {"-//Metrius//DTD Metrius Presentational//", 40},
    {"-//Microsoft//DTD Internet Explorer 2.0 HTML Strict//", 53},
    {"-//Microsoft//DTD Internet Explorer 2.0 HTML//", 46},
    {"-//Microsoft//DTD Internet Explorer 2.0 Tables//", 48},
    {"-//Microsoft//DTD Internet Explorer 3.0 HTML Strict//", 53},
    {"-//Microsoft//DTD Internet Explorer 3.0 HTML//", 46},
    {"-//Microsoft//DTD Internet Explorer 3.0 Tables//", 48},
    {"-//Netscape Comm. Corp.//DTD HTML//", 35},
    {"-//Netscape Comm. Corp.//DTD Strict HTML//", 42},
    {"-//O'Reilly and Associates//DTD HTML 2.0//", 42},
    {"-//O'Reilly and Associates//DTD HTML Extended 1.0//", 51},
    {"-//O'Reilly and Associates//DTD HTML Extended Relaxed 1.0//", 59},
    {"-//SQ//DTD HTML 2.0 HoTMetaL + extensions//", 43},
    {"-//SoftQuad Software//DTD HoTMetaL PRO 6.0::19990601::extensions to HTML 4.0//", 78},
    {"-//SoftQuad//DTD HoTMetaL PRO 4.0::19971010::extensions to HTML 4.0//", 69},
    {"-//Spyglass//DTD HTML 2.0 Extended//", 36},
    {"-//Sun Microsystems Corp.//DTD HotJava HTML//", 45},
    {"-//Sun Microsystems Corp.//DTD HotJava Strict HTML//", 52},
    {"-//W3C//DTD HTML 3 1995-03-24//", 31},
    {"-//W3C//DTD HTML 3.2 Draft//", 28},
    {"-//W3C//DTD HTML 3.2 Final//", 28},
    {"-//W3C//DTD HTML 3.2//", 22},
    {"-//W3C//DTD HTML 3.2S Draft//", 29},
    {"-//W3C//DTD HTML 4.0 Frameset//", 31},
    {"-//W3C//DTD HTML 4.0 Transitional//", 35},
    {"-//W3C//DTD HTML Experimental 19960712//", 40},
    {"-//W3C//DTD HTML Experimental 970421//", 38},
    {"-//W3C//DTD W3 HTML//", 21},
    {"-//W3O//DTD W3 HTML 3.0//", 25},
    {"-//WebTechs//DTD Mozilla HTML 2.0//", 35},
    {"-//WebTechs//DTD Mozilla HTML//", 31}
];

private lxb_html_tree_insertion_mode_initial_str_t[2] lxb_html_tree_insertion_mode_initial_doctype_sys_pub_start = [
    {"-//W3C//DTD HTML 4.01 Frameset//", 32},
    {"-//W3C//DTD HTML 4.01 Transitional//", 36}
];

private lxb_html_tree_insertion_mode_initial_str_t[2] lxb_html_tree_insertion_mode_initial_doctype_lim_pub_start = [
    {"-//W3C//DTD XHTML 1.0 Frameset//", 32},
    {"-//W3C//DTD XHTML 1.0 Transitional//", 36}
];













bool lxb_html_tree_insertion_mode_initial(lxb_html_tree_t* tree, lxb_html_token_t* token)
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
            tree.mode = &lxb_html_tree_insertion_mode_before_html;

            return lxb_html_tree_insertion_mode_initial_doctype(tree, token);

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
        default: {
            lxb_dom_document_t* document = &tree.document.dom_document;

            if (tree.document.iframe_srcdoc == null) {
                lxb_html_tree_parse_error(tree, token,
                                          LXB_HTML_RULES_ERROR_UNTOININMO);

                document.compat_mode = LXB_DOM_DOCUMENT_CMODE_QUIRKS;
            }

            tree.mode = &lxb_html_tree_insertion_mode_before_html;

            return false;
        }
    }

    return true;
}

private bool lxb_html_tree_insertion_mode_initial_doctype(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_document_type_t* doc_type = void;

    /* Create */
    doc_type = lxb_html_tree_create_document_type_from_token(tree, token);
    if (doc_type == null) {
        tree.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;

        return lxb_html_tree_process_abort(tree);
    }

    /* Check */
    bool is_html = (doc_type.name == LXB_DOM_ATTR_HTML);

    if (is_html == false
        || doc_type.public_id.length != 0
        || (doc_type.system_id.length == 19
            && strncmp("about:legacy-compat",
                       cast(const(char)*) doc_type.system_id.data, 19) != 0)
        )
    {
        lxb_html_tree_parse_error(tree, token,
                                  LXB_HTML_RULES_ERROR_BADOTOININMO);
    }

    lxb_html_tree_insertion_mode_initial_doctype_ckeck(tree, doc_type,
                                                       token, is_html);

    lxb_dom_node_insert_child_wo_events(&tree.document.dom_document.node,
                                        (cast(lxb_dom_node_t*) (doc_type)));

    lxb_dom_document_attach_doctype(&tree.document.dom_document, doc_type);

    return true;
}

private void lxb_html_tree_insertion_mode_initial_doctype_ckeck(lxb_html_tree_t* tree, lxb_dom_document_type_t* doc_type, lxb_html_token_t* token, bool is_html)
{
    if (tree.document.iframe_srcdoc != null) {
        return;
    }

    bool quirks = void;
    lxb_dom_document_t* document = &tree.document.dom_document;

    if (token.type & LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS) {
        goto set_quirks;
    }

    if (is_html == false) {
        goto set_quirks;
    }

    if (doc_type.public_id.length != 0) {
        quirks =
            lxb_html_tree_insertion_mode_initial_doctype_ckeck_public(doc_type);

        if (quirks) {
            goto set_quirks;
        }
    }

    if (doc_type.system_id.length != 0) {
        quirks =
            lxb_html_tree_insertion_mode_initial_doctype_ckeck_system(doc_type);

        if (quirks) {
            goto set_quirks;
        }
    }

    if (doc_type.public_id.length != 0 && doc_type.system_id.length == 0) {
        quirks =
            lxb_html_tree_insertion_mode_initial_doctype_ckeck_pubsys(doc_type);

        if (quirks) {
            goto set_quirks;
        }
    }

    if (doc_type.public_id.length != 0) {
        quirks =
            lxb_html_tree_insertion_mode_initial_doctype_check_limq(doc_type);

        if (quirks) {
            document.compat_mode = LXB_DOM_DOCUMENT_CMODE_LIMITED_QUIRKS;
            return;
        }
    }

    return;

set_quirks:

    document.compat_mode = LXB_DOM_DOCUMENT_CMODE_QUIRKS;
}

private bool lxb_html_tree_insertion_mode_initial_doctype_ckeck_public(lxb_dom_document_type_t* doc_type)
{
    size_t size = void, i = void;
    lxb_html_tree_insertion_mode_initial_str_t* str = void;

    /* The public identifier is set to */
    size = lxb_html_tree_insertion_mode_initial_doctype_public_is.sizeof
        / lxb_html_tree_insertion_mode_initial_str_t.sizeof;

    for (i = 0; i < size; i++) {
        str = &lxb_html_tree_insertion_mode_initial_doctype_public_is[i];

        if (str.len == doc_type.public_id.length
            && lexbor_str_data_casecmp(cast(const(lxb_char_t)*) str.data,
                                       doc_type.public_id.data))
        {
            return true;
        }
    }

    /* The public identifier starts with */
    size = lxb_html_tree_insertion_mode_initial_doctype_public_start.sizeof
        / lxb_html_tree_insertion_mode_initial_str_t.sizeof;

    for (i = 0; i < size; i++) {
        str = &lxb_html_tree_insertion_mode_initial_doctype_public_start[i];

        if (str.len <= doc_type.public_id.length
            && lexbor_str_data_ncasecmp(cast(const(lxb_char_t)*) str.data,
                                        doc_type.public_id.data, str.len))
        {
            return true;
        }
    }

    return false;
}

private bool lxb_html_tree_insertion_mode_initial_doctype_ckeck_system(lxb_dom_document_type_t* doc_type)
{
    size_t size = void;
    lxb_html_tree_insertion_mode_initial_str_t* str = void;

    /* The system identifier is set to */
    size = lxb_html_tree_insertion_mode_initial_doctype_system_is.sizeof
        / lxb_html_tree_insertion_mode_initial_str_t.sizeof;

    for (size_t i = 0; i < size; i++) {
        str = &lxb_html_tree_insertion_mode_initial_doctype_system_is[i];

        if (str.len == doc_type.system_id.length
            && lexbor_str_data_casecmp(cast(const(lxb_char_t)*) str.data,
                                       doc_type.system_id.data))
        {
            return true;
        }
    }

    return false;
}

private bool lxb_html_tree_insertion_mode_initial_doctype_ckeck_pubsys(lxb_dom_document_type_t* doc_type)
{
    size_t size = void;
    lxb_html_tree_insertion_mode_initial_str_t* str = void;

    /* The system identifier is missing and the public identifier starts with */
    size = lxb_html_tree_insertion_mode_initial_doctype_sys_pub_start.sizeof
        / lxb_html_tree_insertion_mode_initial_str_t.sizeof;

    for (size_t i = 0; i < size; i++) {
        str = &lxb_html_tree_insertion_mode_initial_doctype_sys_pub_start[i];

        if (str.len <= doc_type.public_id.length
            && lexbor_str_data_ncasecmp(cast(const(lxb_char_t)*) str.data,
                                        doc_type.public_id.data, str.len))
        {
            return true;
        }
    }

    return false;
}

private bool lxb_html_tree_insertion_mode_initial_doctype_check_limq(lxb_dom_document_type_t* doc_type)
{
    bool quirks = void;
    size_t size = void;
    lxb_html_tree_insertion_mode_initial_str_t* str = void;

    if (doc_type.system_id.length != 0) {
        quirks =
            lxb_html_tree_insertion_mode_initial_doctype_ckeck_pubsys(doc_type);

        if (quirks) {
            return true;
        }
    }

    /* The public identifier starts with */
    size = lxb_html_tree_insertion_mode_initial_doctype_lim_pub_start.sizeof
        / lxb_html_tree_insertion_mode_initial_str_t.sizeof;

    for (size_t i = 0; i < size; i++) {
        str = &lxb_html_tree_insertion_mode_initial_doctype_lim_pub_start[i];

        if (str.len <= doc_type.public_id.length
            && lexbor_str_data_ncasecmp(cast(const(lxb_char_t)*) str.data,
                                        doc_type.public_id.data, str.len))
        {
            return true;
        }
    }

    return false;
}
