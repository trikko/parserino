module parserino.lexbor.html.serialize;

import parserino.lexbor.core.str_res;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.str;
public import parserino.lexbor.dom.interfaces.element;
public import parserino.lexbor.html.base;
import parserino.lexbor.dom.interfaces.text;
import parserino.lexbor.dom.interfaces.comment;
import parserino.lexbor.dom.interfaces.processing_instruction;
import parserino.lexbor.dom.interfaces.document_type;
import parserino.lexbor.html.tree;
import parserino.lexbor.ns.ns;
import parserino.lexbor.html.interfaces.template_element;

extern(C) @nogc nothrow:
__gshared:

// ---- serialize.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_html_serialize_opt_t = int;

enum lxb_html_serialize_opt {
    LXB_HTML_SERIALIZE_OPT_UNDEF = 0x00,
    LXB_HTML_SERIALIZE_OPT_SKIP_WS_NODES = 0x01,
    LXB_HTML_SERIALIZE_OPT_SKIP_COMMENT = 0x02,
    LXB_HTML_SERIALIZE_OPT_RAW = 0x04,
    LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING = 0x08,
    LXB_HTML_SERIALIZE_OPT_TAG_WITH_NS = 0x10,
    LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT = 0x20,
    LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE = 0x40,
    LXB_HTML_SERIALIZE_OPT_HTML5TEST = 0x80
}
alias LXB_HTML_SERIALIZE_OPT_UNDEF = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_UNDEF;
alias LXB_HTML_SERIALIZE_OPT_SKIP_WS_NODES = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_SKIP_WS_NODES;
alias LXB_HTML_SERIALIZE_OPT_SKIP_COMMENT = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_SKIP_COMMENT;
alias LXB_HTML_SERIALIZE_OPT_RAW = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_RAW;
alias LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING;
alias LXB_HTML_SERIALIZE_OPT_TAG_WITH_NS = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_TAG_WITH_NS;
alias LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT;
alias LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE;
alias LXB_HTML_SERIALIZE_OPT_HTML5TEST = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_HTML5TEST;


alias lxb_html_serialize_cb_f = lxb_status_t function(const(lxb_char_t)* data, size_t len, void* ctx);













// ---- serialize.c ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
    // D port (C extern, imported instead): extern const(ubyte)[256] lexbor_tokenizer_chars_map;

struct lxb_html_serialize_ctx_t {
    lexbor_str_t* str;
    lexbor_mraw_t* mraw;
}

struct lxb_html_serialize_attr_entry_t {
    lxb_dom_attr_t* attr;
    size_t offset;
    size_t length;
}





















































lxb_status_t lxb_html_serialize_cb(lxb_dom_node_t* node, lxb_html_serialize_cb_f cb, void* ctx)
{
    switch (node.type) {
        case LXB_DOM_NODE_TYPE_ELEMENT:
            return lxb_html_serialize_element_cb((cast(lxb_dom_element_t*) (node)),
                                                 cb, ctx);

        case LXB_DOM_NODE_TYPE_TEXT:
            return lxb_html_serialize_text_cb((cast(lxb_dom_text_t*) (node)),
                                              cb, ctx);

        case LXB_DOM_NODE_TYPE_COMMENT:
            return lxb_html_serialize_comment_cb((cast(lxb_dom_comment_t*) (node)),
                                                 cb, ctx);

        case LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION:
            return lxb_html_serialize_processing_instruction_cb((cast(lxb_dom_processing_instruction_t*) (node)),
                                                                cb, ctx);

        case LXB_DOM_NODE_TYPE_DOCUMENT_TYPE:
            return lxb_html_serialize_document_type_cb((cast(lxb_dom_document_type_t*) (node)),
                                                       cb, ctx);

        case LXB_DOM_NODE_TYPE_DOCUMENT:
            return lxb_html_serialize_document_cb((cast(lxb_dom_document_t*) (node)),
                                                  cb, ctx);

        default:
            break;
    }

    return LXB_STATUS_ERROR;
}

lxb_status_t lxb_html_serialize_str(lxb_dom_node_t* node, lexbor_str_t* str)
{
    lxb_html_serialize_ctx_t ctx = void;

    if (str.data == null) {
        lexbor_str_init(str, node.owner_document.text, 1024);

        if (str.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    ctx.str = str;
    ctx.mraw = node.owner_document.text;

    return lxb_html_serialize_cb(node, &lxb_html_serialize_str_callback, &ctx);
}

private lxb_status_t lxb_html_serialize_str_callback(const(lxb_char_t)* data, size_t len, void* ctx)
{
    lxb_char_t* ret = void;
    lxb_html_serialize_ctx_t* s_ctx = cast(lxb_html_serialize_ctx_t*) ctx;

    ret = lexbor_str_append(s_ctx.str, s_ctx.mraw, data, len);
    if (ret == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_serialize_deep_cb(lxb_dom_node_t* node, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    node = node.first_child;

    while (node != null) {
        status = lxb_html_serialize_node_cb(node, cb, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }

        node = node.next;
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_serialize_deep_str(lxb_dom_node_t* node, lexbor_str_t* str)
{
    lxb_html_serialize_ctx_t ctx = void;

    if (str.data == null) {
        lexbor_str_init(str, node.owner_document.text, 1024);

        if (str.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    ctx.str = str;
    ctx.mraw = node.owner_document.text;

    return lxb_html_serialize_deep_cb(node,
                                      &lxb_html_serialize_str_callback, &ctx);
}

private lxb_status_t lxb_html_serialize_node_cb(lxb_dom_node_t* node, lxb_html_serialize_cb_f cb, void* ctx)
{
    bool skip_it = void;
    lxb_status_t status = void;
    lxb_dom_node_t* root = node;

    while (node != null) {
        status = lxb_html_serialize_cb(node, cb, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }

        if (lxb_html_tree_node_is(node, LXB_TAG_TEMPLATE)) {
            lxb_html_template_element_t* temp = void;

            temp = (cast(lxb_html_template_element_t*) (node));

            if (temp.content != null) {
                if (temp.content.node.first_child != null)
                {
                    status = lxb_html_serialize_deep_cb(&temp.content.node,
                                                        cb, ctx);
                    if (status != LXB_STATUS_OK) {
                        return status;
                    }
                }
            }
        }

        skip_it = lxb_html_node_is_void(node);

        if (skip_it == false && node.first_child != null) {
            node = node.first_child;
        }
        else {
            while(node != root && node.next == null)
            {
                if (node.type == LXB_DOM_NODE_TYPE_ELEMENT
                    && lxb_html_node_is_void(node) == false)
                {
                    status = lxb_html_serialize_element_closed_cb((cast(lxb_dom_element_t*) (node)),
                                                                  cb, ctx);
                    if (status != LXB_STATUS_OK) {
                        return status;
                    }
                }

                node = node.parent;
            }

            if (node.type == LXB_DOM_NODE_TYPE_ELEMENT
                && lxb_html_node_is_void(node) == false)
            {
                status = lxb_html_serialize_element_closed_cb((cast(lxb_dom_element_t*) (node)),
                                                              cb, ctx);
                if (status != LXB_STATUS_OK) {
                    return status;
                }
            }

            if (node == root) {
                break;
            }

            node = node.next;
        }
    }

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_element_cb(lxb_dom_element_t* element, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;
    const(lxb_char_t)* tag_name = void;
    size_t len = 0;

    lxb_dom_attr_t* attr = void;

    tag_name = lxb_dom_element_qualified_name(element, &len);
    if (tag_name == null) {
        return LXB_STATUS_ERROR;
    }

    do { status = cb(cast(const(lxb_char_t)*) "<", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) tag_name, len, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    if (element.is_value != null && element.is_value.data != null) {
        attr = lxb_dom_element_attr_is_exist(element,
                                             cast(const(lxb_char_t)*) "is", 2);
        if (attr == null) {
            do { status = cb(cast(const(lxb_char_t)*) " is=\"", 5, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

            status = lxb_html_serialize_send_escaping_attribute_string(element.is_value.data,
                                                                       element.is_value.length,
                                                                       cb, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        }
    }

    attr = element.first_attr;

    while (attr != null) {
        do { status = cb(cast(const(lxb_char_t)*) " ", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

        status = lxb_html_serialize_attribute_cb(attr, cb, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }

        attr = attr.next;
    }

    do { status = cb(cast(const(lxb_char_t)*) ">", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_element_closed_cb(lxb_dom_element_t* element, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;
    const(lxb_char_t)* tag_name = void;
    size_t len = 0;

    tag_name = lxb_dom_element_qualified_name(element, &len);
    if (tag_name == null) {
        return LXB_STATUS_ERROR;
    }

    do { status = cb(cast(const(lxb_char_t)*) "</", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) tag_name, len, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) ">", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_text_cb(lxb_dom_text_t* text, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (text));
    lxb_dom_document_t* doc = node.owner_document;
    lexbor_str_t* data = &text.char_data.data;

    if (node.parent != null) {
        switch (node.parent.local_name) {
            case LXB_TAG_STYLE:
            case LXB_TAG_SCRIPT:
            case LXB_TAG_XMP:
            case LXB_TAG_IFRAME:
            case LXB_TAG_NOEMBED:
            case LXB_TAG_NOFRAMES:
            case LXB_TAG_PLAINTEXT:
                do { status = cb(cast(const(lxb_char_t)*) data.data, data.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                return LXB_STATUS_OK;

            case LXB_TAG_NOSCRIPT:
                if (doc.scripting) {
                    do { status = cb(cast(const(lxb_char_t)*) data.data, data.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                    return LXB_STATUS_OK;
                }

                break;

            default:
                break;
        }
    }

    return lxb_html_serialize_send_escaping_string(data.data, data.length,
                                                   cb, ctx);
}

private lxb_status_t lxb_html_serialize_comment_cb(lxb_dom_comment_t* comment, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;
    lexbor_str_t* data = &comment.char_data.data;

    do { status = cb(cast(const(lxb_char_t)*) "<!--", 4, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) data.data, data.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) "-->", 3, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_processing_instruction_cb(lxb_dom_processing_instruction_t* pi, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;
    lexbor_str_t* data = &pi.char_data.data;

    do { status = cb(cast(const(lxb_char_t)*) "<?", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) pi.target.data, pi.target.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) " ", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) data.data, data.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) "?>", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_document_type_cb(lxb_dom_document_type_t* doctype, lxb_html_serialize_cb_f cb, void* ctx)
{
    size_t length = void;
    const(lxb_char_t)* name = void;
    lxb_status_t status = void;

    do { status = cb(cast(const(lxb_char_t)*) "<!DOCTYPE", 9, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) " ", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    name = lxb_dom_document_type_name(doctype, &length);

    if (length != 0) {
        do { status = cb(cast(const(lxb_char_t)*) name, length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    }

    do { status = cb(cast(const(lxb_char_t)*) ">", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_document_type_full_cb(lxb_dom_document_type_t* doctype, lxb_html_serialize_opt_t opt, lxb_html_serialize_cb_f cb, void* ctx)
{
    bool have_pub = void, have_sys = void;
    size_t length = void;
    const(lxb_char_t)* name = void;
    lxb_status_t status = void;

    do { status = cb(cast(const(lxb_char_t)*) "<!DOCTYPE", 9, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) " ", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    name = lxb_dom_document_type_name(doctype, &length);

    if (length != 0) {
        do { status = cb(cast(const(lxb_char_t)*) name, length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    }

    have_pub = doctype.public_id.length != 0;
    have_sys = doctype.system_id.length != 0;

    if (opt & LXB_HTML_SERIALIZE_OPT_HTML5TEST) {
        /*
         * html5lib-tests format: when either PUBLIC or SYSTEM identifier
         * is present, emit both slots. A missing identifier is shown as "".
         */
        if (have_pub || have_sys) {
            do { status = cb(cast(const(lxb_char_t)*) " \"", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

            if (have_pub) {
                do { status = cb(cast(const(lxb_char_t)*) doctype.public_id.data, doctype.public_id.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                                       ;
            }

            do { status = cb(cast(const(lxb_char_t)*) "\" \"", 3, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

            if (have_sys) {
                do { status = cb(cast(const(lxb_char_t)*) doctype.system_id.data, doctype.system_id.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                                       ;
            }

            do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        }
    }
    else {
        if (have_pub) {
            do { status = cb(cast(const(lxb_char_t)*) " PUBLIC \"", 9, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

            do { status = cb(cast(const(lxb_char_t)*) doctype.public_id.data, doctype.public_id.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                                   ;

            do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        }

        if (have_sys) {
            if (!have_pub) {
                do { status = cb(cast(const(lxb_char_t)*) " SYSTEM", 7, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
            }

            do { status = cb(cast(const(lxb_char_t)*) " \"", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

            do { status = cb(cast(const(lxb_char_t)*) doctype.system_id.data, doctype.system_id.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                                   ;

            do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        }
    }

    do { status = cb(cast(const(lxb_char_t)*) ">", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_document_cb(lxb_dom_document_t* document, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    do { status = cb(cast(const(lxb_char_t)*) "<#document>", 11, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_send_escaping_attribute_string(const(lxb_char_t)* data, size_t len, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;
    const(lxb_char_t)* pos = data;
    const(lxb_char_t)* end = data + len;

    while (data != end) {
        switch (*data) {
            /* U+0026 AMPERSAND (&) */
            case 0x26:
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&amp;", 5, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data++;
                pos = data;

                break;

            /* {0xC2, 0xA0} NO-BREAK SPACE */
            case 0xC2:
                data += 1;
                if (data == end) {
                    break;
                }

                if (*data != 0xA0) {
                    continue;
                }

                data -= 1;

                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&nbsp;", 6, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data += 2;
                pos = data;

                break;

            /* U+003C LESS-THAN SIGN (<) */
            case 0x3C:
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&lt;", 4, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data++;
                pos = data;

                break;

            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&gt;", 4, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data++;
                pos = data;

                break;

            /* U+0022 QUOTATION MARK (") */
            case 0x22:
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&quot;", 6, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data++;
                pos = data;

                break;

            default:
                data++;

                break;
        }
    }

    if (pos != data) {
        do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    }

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_send_escaping_string(const(lxb_char_t)* data, size_t len, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;
    const(lxb_char_t)* pos = data;
    const(lxb_char_t)* end = data + len;

    while (data != end) {
        switch (*data) {
            /* U+0026 AMPERSAND (&) */
            case 0x26:
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&amp;", 5, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data++;
                pos = data;

                break;

            /* {0xC2, 0xA0} NO-BREAK SPACE */
            case 0xC2:
                data += 1;
                if (data == end) {
                    break;
                }

                if (*data != 0xA0) {
                    continue;
                }

                data -= 1;

                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&nbsp;", 6, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data += 2;
                pos = data;

                break;

            /* U+003C LESS-THAN SIGN (<) */
            case 0x3C:
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&lt;", 4, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data++;
                pos = data;

                break;

            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&gt;", 4, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data++;
                pos = data;

                break;

            default:
                data++;

                break;
        }
    }

    if (pos != data) {
        do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    }

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_attribute_cb(lxb_dom_attr_t* attr, lxb_html_serialize_cb_f cb, void* ctx)
{
    size_t length = void;
    lxb_status_t status = void;
    const(lxb_char_t)* str = void;
    const(lxb_dom_attr_data_t)* data = void;

    data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) attr.node.owner_document.attrs,
                                   attr.node.local_name);
    if (data == null) {
        return LXB_STATUS_ERROR;
    }

    if (attr.node.ns == LXB_NS__UNDEF) {
        do { status = cb(cast(const(lxb_char_t)*) lexbor_hash_entry_str(&data.entry), data.entry.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                        ;
        goto value;
    }

    if (attr.node.ns == LXB_NS_XML) {
        do { status = cb(cast(const(lxb_char_t)*) cast(const(lxb_char_t)*) "xml:", 4, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        do { status = cb(cast(const(lxb_char_t)*) lexbor_hash_entry_str(&data.entry), data.entry.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                        ;

        goto value;
    }

    if (attr.node.ns == LXB_NS_XMLNS)
    {
        if (data.entry.length == 5
            && lexbor_str_data_cmp(lexbor_hash_entry_str(&data.entry),
                                   cast(const(lxb_char_t)*) "xmlns"))
        {
            do { status = cb(cast(const(lxb_char_t)*) cast(const(lxb_char_t)*) "xmlns", 5, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        }
        else {
            do { status = cb(cast(const(lxb_char_t)*) cast(const(lxb_char_t)*) "xmlns:", 6, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
            do { status = cb(cast(const(lxb_char_t)*) lexbor_hash_entry_str(&data.entry), data.entry.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                            ;
        }

        goto value;
    }

    if (attr.node.ns == LXB_NS_XLINK) {
        do { status = cb(cast(const(lxb_char_t)*) cast(const(lxb_char_t)*) "xlink:", 6, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        do { status = cb(cast(const(lxb_char_t)*) lexbor_hash_entry_str(&data.entry), data.entry.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                        ;

        goto value;
    }

    str = lxb_dom_attr_qualified_name(attr, &length);
    if (str == null) {
        return LXB_STATUS_ERROR;
    }

    do { status = cb(cast(const(lxb_char_t)*) str, length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

value:

    if (attr.value == null) {
        do { status = cb(cast(const(lxb_char_t)*) "=\"\"", 3, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        return LXB_STATUS_OK;
    }

    do { status = cb(cast(const(lxb_char_t)*) "=\"", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    status = lxb_html_serialize_send_escaping_attribute_string(attr.value.data,
                                                               attr.value.length,
                                                               cb, ctx);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_serialize_pretty_cb(lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    if (opt & LXB_HTML_SERIALIZE_OPT_HTML5TEST) {
        opt |= LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING
               | LXB_HTML_SERIALIZE_OPT_TAG_WITH_NS
               | LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT
               | LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE
               | LXB_HTML_SERIALIZE_OPT_RAW;
    }

    switch (node.type) {
        case LXB_DOM_NODE_TYPE_ELEMENT:
            do { for (size_t i = 0; i < indent; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);

            status = lxb_html_serialize_pretty_element_cb((cast(lxb_dom_element_t*) (node)),
                                                          opt, indent, cb, ctx);

            break;

        case LXB_DOM_NODE_TYPE_TEXT:
            return lxb_html_serialize_pretty_text_cb((cast(lxb_dom_text_t*) (node)),
                                                     opt, indent, cb, ctx);

        case LXB_DOM_NODE_TYPE_COMMENT: {
            bool with_indent = void;

            if (opt & LXB_HTML_SERIALIZE_OPT_SKIP_COMMENT) {
                return LXB_STATUS_OK;
            }

            with_indent = (opt & LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT) == 0;

            status = lxb_html_serialize_pretty_comment_cb((cast(lxb_dom_comment_t*) (node)),
                                                          indent, with_indent, cb, ctx);

            break;
        }

        case LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION:
            do { for (size_t i = 0; i < indent; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);

            status = lxb_html_serialize_processing_instruction_cb((cast(lxb_dom_processing_instruction_t*) (node)),
                                                                  cb, ctx);

            break;

        case LXB_DOM_NODE_TYPE_DOCUMENT_TYPE:
            do { for (size_t i = 0; i < indent; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);

            if (opt & LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE) {
                status = lxb_html_serialize_document_type_full_cb((cast(lxb_dom_document_type_t*) (node)),
                                                                  opt, cb, ctx);
            }
            else {
                status = lxb_html_serialize_document_type_cb((cast(lxb_dom_document_type_t*) (node)),
                                                             cb, ctx);
            }

            break;

        case LXB_DOM_NODE_TYPE_DOCUMENT:
            do { for (size_t i = 0; i < indent; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);

            status = lxb_html_serialize_pretty_document_cb((cast(lxb_dom_document_t*) (node)),
                                                           cb, ctx);

            break;

        default:
            return LXB_STATUS_ERROR;
    }

    if (status != LXB_STATUS_OK) {
        return status;
    }

    do { status = cb(cast(const(lxb_char_t)*) "\n", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_serialize_pretty_str(lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lexbor_str_t* str)
{
    lxb_html_serialize_ctx_t ctx = void;

    if (str.data == null) {
        lexbor_str_init(str, node.owner_document.text, 1024);

        if (str.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    ctx.str = str;
    ctx.mraw = node.owner_document.text;

    return lxb_html_serialize_pretty_cb(node, opt, indent,
                                        &lxb_html_serialize_str_callback, &ctx);
}

lxb_status_t lxb_html_serialize_pretty_deep_cb(lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    if (opt & LXB_HTML_SERIALIZE_OPT_HTML5TEST) {
        opt |= LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING
               | LXB_HTML_SERIALIZE_OPT_TAG_WITH_NS
               | LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT
               | LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE
               | LXB_HTML_SERIALIZE_OPT_RAW;
    }

    node = node.first_child;

    while (node != null) {
        status = lxb_html_serialize_pretty_node_cb(node, opt, indent, cb, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }

        node = node.next;
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_serialize_pretty_deep_str(lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lexbor_str_t* str)
{
    lxb_html_serialize_ctx_t ctx = void;

    if (str.data == null) {
        lexbor_str_init(str, node.owner_document.text, 1024);

        if (str.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    ctx.str = str;
    ctx.mraw = node.owner_document.text;

    return lxb_html_serialize_pretty_deep_cb(node, opt, indent,
                                             &lxb_html_serialize_str_callback,
                                             &ctx);
}

private lxb_status_t lxb_html_serialize_pretty_node_cb(lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t deep, lxb_html_serialize_cb_f cb, void* ctx)
{
    bool skip_it = void;
    lxb_status_t status = void;
    lxb_dom_node_t* root = node;

    while (node != null) {
        status = lxb_html_serialize_pretty_cb(node, opt, deep, cb, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }

        if (lxb_html_tree_node_is(node, LXB_TAG_TEMPLATE)) {
            lxb_html_template_element_t* temp = void;

            temp = (cast(lxb_html_template_element_t*) (node));

            if (opt & LXB_HTML_SERIALIZE_OPT_HTML5TEST) {
                do { for (size_t i = 0; i < (deep + 1); i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);
                do { status = cb(cast(const(lxb_char_t)*) "content", 7, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                do { status = cb(cast(const(lxb_char_t)*) "\n", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
            }

            if (temp.content != null) {
                if (temp.content.node.first_child != null)
                {
                    if ((opt & LXB_HTML_SERIALIZE_OPT_HTML5TEST) == 0) {
                        do { for (size_t i = 0; i < (deep + 1); i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);
                        do { status = cb(cast(const(lxb_char_t)*) "#document-fragment", 18, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                        do { status = cb(cast(const(lxb_char_t)*) "\n", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                    }

                    status = lxb_html_serialize_pretty_deep_cb(&temp.content.node,
                                                               opt, (deep + 2),
                                                               cb, ctx);
                    if (status != LXB_STATUS_OK) {
                        return status;
                    }
                }
            }
        }

        skip_it = lxb_html_node_is_void(node);

        if (skip_it == false && node.first_child != null) {
            deep++;

            node = node.first_child;
        }
        else {
            while(node != root && node.next == null)
            {
                if (node.type == LXB_DOM_NODE_TYPE_ELEMENT
                    && lxb_html_node_is_void(node) == false)
                {
                    if ((opt & LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING) == 0) {
                        do { for (size_t i = 0; i < deep; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);

                        status = lxb_html_serialize_element_closed_cb((cast(lxb_dom_element_t*) (node)),
                                                                      cb, ctx);
                        if (status != LXB_STATUS_OK) {
                            return status;
                        }

                        do { status = cb(cast(const(lxb_char_t)*) "\n", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                    }
                }

                deep--;

                node = node.parent;
            }

            if (node.type == LXB_DOM_NODE_TYPE_ELEMENT
                && lxb_html_node_is_void(node) == false)
            {
                if ((opt & LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING) == 0) {
                    do { for (size_t i = 0; i < deep; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);

                    status = lxb_html_serialize_element_closed_cb((cast(lxb_dom_element_t*) (node)),
                                                                  cb, ctx);
                    if (status != LXB_STATUS_OK) {
                        return status;
                    }

                    do { status = cb(cast(const(lxb_char_t)*) "\n", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }
            }

            if (node == root) {
                break;
            }

            node = node.next;
        }
    }

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_pretty_element_cb(lxb_dom_element_t* element, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;
    const(lxb_char_t)* tag_name = void;
    size_t len = 0;

    lxb_dom_attr_t* attr = void;
    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    tag_name = lxb_dom_element_qualified_name(element, &len);
    if (tag_name == null) {
        return LXB_STATUS_ERROR;
    }

    do { status = cb(cast(const(lxb_char_t)*) "<", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    if (element.node.ns != LXB_NS_HTML
        && opt & LXB_HTML_SERIALIZE_OPT_TAG_WITH_NS)
    {
        const(lxb_ns_prefix_data_t)* data = null;

        if (element.node.prefix != LXB_NS__UNDEF) {
            data = lxb_ns_prefix_data_by_id(node.owner_document.prefix,
                                            element.node.prefix);
        }
        else if (element.node.ns < LXB_NS__LAST_ENTRY) {
            data = lxb_ns_prefix_data_by_id(node.owner_document.prefix,
                                             element.node.ns);
        }

        if (data != null) {
            do { status = cb(cast(const(lxb_char_t)*) lexbor_hash_entry_str(&data.entry), data.entry.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                            ;

            if (opt & LXB_HTML_SERIALIZE_OPT_HTML5TEST) {
                do { status = cb(cast(const(lxb_char_t)*) " ", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
            }
            else {
                do { status = cb(cast(const(lxb_char_t)*) ":", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
            }
        }
    }

    do { status = cb(cast(const(lxb_char_t)*) tag_name, len, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    if (element.is_value != null && element.is_value.data != null) {
        attr = lxb_dom_element_attr_is_exist(element,
                                             cast(const(lxb_char_t)*) "is", 2);
        if (attr == null) {
            do { status = cb(cast(const(lxb_char_t)*) " is=\"", 5, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

            if (opt & LXB_HTML_SERIALIZE_OPT_RAW) {
                do { status = cb(cast(const(lxb_char_t)*) element.is_value.data, element.is_value.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                                       ;
            }
            else {
                status = lxb_html_serialize_send_escaping_attribute_string(element.is_value.data,
                                                                           element.is_value.length,
                                                                           cb, ctx);
                if (status != LXB_STATUS_OK) {
                    return status;
                }
            }

            do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        }
    }

    if (opt & LXB_HTML_SERIALIZE_OPT_HTML5TEST) {
        do { status = cb(cast(const(lxb_char_t)*) ">", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

        status = lxb_html_serialize_pretty_attributes_sorted(element, opt,
                                                             indent, cb, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }
    }
    else {
        attr = element.first_attr;

        while (attr != null) {
            do { status = cb(cast(const(lxb_char_t)*) " ", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

            status = lxb_html_serialize_pretty_attribute_cb(attr, opt,
                                                            cast(bool) (opt & LXB_HTML_SERIALIZE_OPT_RAW),
                                                            cb, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            attr = attr.next;
        }

        do { status = cb(cast(const(lxb_char_t)*) ">", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    }

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_pretty_attribute_cb(lxb_dom_attr_t* attr, lxb_html_serialize_opt_t opt, bool has_raw, lxb_html_serialize_cb_f cb, void* ctx)
{
    size_t length = void;
    lxb_status_t status = void;
    const(lxb_char_t)* str = void;
    const(lxb_dom_attr_data_t)* data = void;
    lxb_char_t spliter = void;

    if (opt & LXB_HTML_SERIALIZE_OPT_HTML5TEST) {
        spliter = ' ';
    }
    else {
        spliter = ':';
    }

    data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) attr.node.owner_document.attrs,
                                   attr.node.local_name);
    if (data == null) {
        return LXB_STATUS_ERROR;
    }

    if (attr.node.ns == LXB_NS__UNDEF) {
        do { status = cb(cast(const(lxb_char_t)*) lexbor_hash_entry_str(&data.entry), data.entry.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                        ;
        goto value;
    }

    if (attr.node.ns == LXB_NS_XML) {
        do { status = cb(cast(const(lxb_char_t)*) cast(const(lxb_char_t)*) "xml", 3, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        do { status = cb(cast(const(lxb_char_t)*) &spliter, 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        do { status = cb(cast(const(lxb_char_t)*) lexbor_hash_entry_str(&data.entry), data.entry.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                        ;

        goto value;
    }

    if (attr.node.ns == LXB_NS_XMLNS)
    {
        if (data.entry.length == 5
            && lexbor_str_data_cmp(lexbor_hash_entry_str(&data.entry),
                                   cast(const(lxb_char_t)*) "xmlns"))
        {
            do { status = cb(cast(const(lxb_char_t)*) cast(const(lxb_char_t)*) "xmlns", 5, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        }
        else {
            do { status = cb(cast(const(lxb_char_t)*) cast(const(lxb_char_t)*) "xmlns", 5, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
            do { status = cb(cast(const(lxb_char_t)*) &spliter, 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
            do { status = cb(cast(const(lxb_char_t)*) lexbor_hash_entry_str(&data.entry), data.entry.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                            ;
        }

        goto value;
    }

    if (attr.node.ns == LXB_NS_XLINK) {
        do { status = cb(cast(const(lxb_char_t)*) cast(const(lxb_char_t)*) "xlink", 5, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        do { status = cb(cast(const(lxb_char_t)*) &spliter, 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        do { status = cb(cast(const(lxb_char_t)*) lexbor_hash_entry_str(&data.entry), data.entry.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                        ;

        goto value;
    }

    str = lxb_dom_attr_qualified_name(attr, &length);
    if (str == null) {
        return LXB_STATUS_ERROR;
    }

    do { status = cb(cast(const(lxb_char_t)*) str, length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

value:

    if (attr.value == null) {
        do { status = cb(cast(const(lxb_char_t)*) "=\"\"", 3, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        return LXB_STATUS_OK;
    }

    do { status = cb(cast(const(lxb_char_t)*) "=\"", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    if (has_raw) {
        do { status = cb(cast(const(lxb_char_t)*) attr.value.data, attr.value.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    }
    else {
        status = lxb_html_serialize_send_escaping_attribute_string(attr.value.data,
                                                                   attr.value.length,
                                                                   cb, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }
    }

    do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

private size_t lxb_html_serialize_attr_name_build(const(lxb_dom_attr_t)* attr, lxb_char_t* buf, size_t cap)
{
    size_t length = void, xmlns_len = void, pos = void;
    const(lxb_char_t)* str = void;
    const(lexbor_str_t)* ns = void;
    const(lxb_dom_attr_data_t)* data = void;

    static const(lexbor_str_t) str_xml = {data: cast(lxb_char_t*) "xml ".ptr, "xml ".length};
    static const(lexbor_str_t) str_xmlns = {data: cast(lxb_char_t*) "xmlns ".ptr, "xmlns ".length};
    static const(lexbor_str_t) str_xlink = {data: cast(lxb_char_t*) "xlink ".ptr, "xlink ".length};

    data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) attr.node.owner_document.attrs,
                                   attr.node.local_name);
    if (data == null) {
        return 0;
    }

    pos = 0;
    str = lexbor_hash_entry_str(&data.entry);
    length = data.entry.length;

    switch (attr.node.ns) {
        case LXB_NS_XML:
            if (str_xml.length + length > cap) {
                return 0;
            }

            ns = &str_xml;
            goto done;

        case LXB_NS_XMLNS:
            xmlns_len = str_xmlns.length - 1;

            if (length == xmlns_len
                && lexbor_str_data_ncmp(str, str_xmlns.data, xmlns_len))
            {
                if (xmlns_len > cap) {
                    return 0;
                }

                memcpy(buf, str_xmlns.data, xmlns_len);
                return xmlns_len;
            }

            if (str_xmlns.length + length > cap) {
                return 0;
            }

            ns = &str_xmlns;
            goto done;

        case LXB_NS_XLINK:
            if (str_xlink.length + length > cap) {
                return 0;
            }

            ns = &str_xlink;
            goto done;

        case LXB_NS__UNDEF:
            if (length > cap) {
                return 0;
            }

            memcpy(buf, str, length);
            return length;

        default:
            if (attr.qualified_name != 0) {
                data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) attr.node.owner_document.attrs,
                                               attr.qualified_name);
                if (data == null) {
                    return 0;
                }

                str = lexbor_hash_entry_str(&data.entry);
                length = data.entry.length;
            }

            if (length > cap) {
                return 0;
            }

            memcpy(buf, str, length);
            return length;
    }

done:

    memcpy(buf, ns.data, ns.length);
    pos = ns.length;

    memcpy(buf + pos, str, length);
    pos += length;

    return pos;
}

private size_t lxb_html_serialize_attr_name_size(const(lxb_dom_attr_t)* attr)
{
    size_t length = void;
    const(lxb_dom_attr_data_t)* data = void;

    static const(lexbor_str_t) str_xml = {data: cast(lxb_char_t*) "xml ".ptr, "xml ".length};
    static const(lexbor_str_t) str_xmlns = {data: cast(lxb_char_t*) "xmlns ".ptr, "xmlns ".length};
    static const(lexbor_str_t) str_xlink = {data: cast(lxb_char_t*) "xlink ".ptr, "xlink ".length};

    data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) attr.node.owner_document.attrs,
                                   attr.node.local_name);
    if (data == null) {
        return 0;
    }

    length = data.entry.length;

    switch (attr.node.ns) {
        case LXB_NS_XML:
            return str_xml.length + length;

        case LXB_NS_XMLNS:
            if (length == str_xmlns.length - 1
                && lexbor_str_data_ncmp(lexbor_hash_entry_str(&data.entry),
                                        str_xmlns.data, str_xmlns.length - 1))
            {
                return str_xmlns.length - 1;
            }

            return str_xmlns.length + length;

        case LXB_NS_XLINK:
            return str_xlink.length + length;

        case LXB_NS__UNDEF:
            return length;

        default:
            if (attr.qualified_name != 0) {
                data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) attr.node.owner_document.attrs,
                                               attr.qualified_name);
                if (data == null) {
                    return 0;
                }

                length = data.entry.length;
            }

            return length;
    }
}

private int lxb_html_serialize_attr_entry_cmp(const(lxb_html_serialize_attr_entry_t)* a, const(lxb_html_serialize_attr_entry_t)* b, const(lxb_char_t)* names)
{
    int c = void;
    size_t min = void;

    min = (a.length < b.length) ? a.length : b.length;

    c = memcmp(names + a.offset, names + b.offset, min);
    if (c != 0) {
        return c;
    }

    if (a.length < b.length) return -1;
    if (a.length > b.length) return 1;
    return 0;
}

private void lxb_html_serialize_attr_sort(lxb_html_serialize_attr_entry_t* entries, size_t n, const(lxb_char_t)* names)
{
    size_t i = void, j = void;
    lxb_html_serialize_attr_entry_t cur = void;

    for (i = 1; i < n; i++) {
        cur = entries[i];
        j = i;

        while (j > 0
               && lxb_html_serialize_attr_entry_cmp(&entries[j - 1], &cur,
                                                    names) > 0)
        {
            entries[j] = entries[j - 1];
            j--;
        }

        entries[j] = cur;
    }
}

private lxb_status_t lxb_html_serialize_pretty_attributes_sorted(lxb_dom_element_t* element, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx)
{
    size_t i = void, k = void, off = void, len = void, count = void, total = void;
    lxb_status_t status = void;
    lxb_dom_attr_t* attr = void;
    lxb_html_serialize_attr_entry_t* entries = void;
    lxb_char_t* names = void;
    lxb_char_t[256] stack_names = void;
    lxb_html_serialize_attr_entry_t[16] stack_entries = void;

    count = 0;
    total = 0;
    entries = stack_entries.ptr;
    names = stack_names.ptr;

    for (attr = element.first_attr; attr != null; attr = attr.next) {
        count += 1;
        total += lxb_html_serialize_attr_name_size(attr);
    }

    if (count == 0) {
        return LXB_STATUS_OK;
    }

    if (count > stack_entries.sizeof / typeof(stack_entries[0]).sizeof) {
        entries = cast(lxb_html_serialize_attr_entry_t*) lexbor_malloc(count * lxb_html_serialize_attr_entry_t.sizeof);
        if (entries == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    if (total > stack_names.sizeof) {
        names = cast(ubyte*) lexbor_malloc(total);
        if (names == null) {
            if (entries != stack_entries.ptr) {
                lexbor_free(entries);
            }

            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    i = 0;
    off = 0;
    for (attr = element.first_attr; attr != null; attr = attr.next) {
        len = lxb_html_serialize_attr_name_build(attr, names + off,
                                                 total - off);
        entries[i].attr = attr;
        entries[i].offset = off;
        entries[i].length = len;

        off += len;
        i += 1;
    }

    lxb_html_serialize_attr_sort(entries, count, names);

    status = LXB_STATUS_OK;

    for (i = 0; i < count; i++) {
        status = cb(cast(const(lxb_char_t)*) "\n", 1, ctx);
        if (status != LXB_STATUS_OK) {
            goto done;
        }

        for (k = 0; k < indent + 1; k++) {
            status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx);
            if (status != LXB_STATUS_OK) {
                goto done;
            }
        }

        status = lxb_html_serialize_pretty_attribute_cb(entries[i].attr, opt,
                                            cast(bool) (opt & LXB_HTML_SERIALIZE_OPT_RAW),
                                            cb, ctx);
        if (status != LXB_STATUS_OK) {
            goto done;
        }
    }

done:

    if (names != stack_names.ptr) {
        lexbor_free(names);
    }

    if (entries != stack_entries.ptr) {
        lexbor_free(entries);
    }

    return status;
}

private lxb_status_t lxb_html_serialize_pretty_text_cb(lxb_dom_text_t* text, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;
    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (text));
    lxb_dom_document_t* doc = node.owner_document;
    lexbor_str_t* data = &text.char_data.data;

    bool with_indent = (opt & LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT) == 0;

    if (opt & LXB_HTML_SERIALIZE_OPT_SKIP_WS_NODES) {
        const(lxb_char_t)* pos = data.data;
        const(lxb_char_t)* end = pos + data.length;

        while (pos != end) {
            if (lexbor_tokenizer_chars_map[ *pos ]
                != LEXBOR_STR_RES_MAP_CHAR_WHITESPACE)
            {
                break;
            }

            pos++;
        }

        if (pos >= end) {
            return LXB_STATUS_OK;
        }
    }

    if (node.parent != null) {
        switch (node.parent.local_name) {
            case LXB_TAG_STYLE:
            case LXB_TAG_SCRIPT:
            case LXB_TAG_XMP:
            case LXB_TAG_IFRAME:
            case LXB_TAG_NOEMBED:
            case LXB_TAG_NOFRAMES:
            case LXB_TAG_PLAINTEXT:
                status = lxb_html_serialize_pretty_send_string(data.data,
                                                               data.length,
                                                               indent,
                                                               with_indent,
                                                               cb, ctx);
                goto end;

            case LXB_TAG_NOSCRIPT:
                if (doc.scripting) {
                    status = lxb_html_serialize_pretty_send_string(data.data,
                                                                   data.length,
                                                                   indent,
                                                                   with_indent,
                                                                   cb, ctx);
                    goto end;
                }

                break;

            default:
                break;
        }
    }

    if (opt & LXB_HTML_SERIALIZE_OPT_RAW) {
        status = lxb_html_serialize_pretty_send_string(data.data, data.length,
                                                       indent, with_indent,
                                                       cb, ctx);
    }
    else {
        status = lxb_html_serialize_pretty_send_escaping_string(data.data,
                                                                data.length,
                                                                indent,
                                                                with_indent,
                                                                cb, ctx);
    }

end:

    if (status != LXB_STATUS_OK) {
        return status;
    }

    do { status = cb(cast(const(lxb_char_t)*) "\n", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_pretty_comment_cb(lxb_dom_comment_t* comment, size_t indent, bool with_indent, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    do { for (size_t i = 0; i < indent; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) "<!-- ", 5, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    if (with_indent) {
        const(lxb_char_t)* data = comment.char_data.data.data;
        const(lxb_char_t)* pos = data;
        const(lxb_char_t)* end = pos + comment.char_data.data.length;

        while (data != end) {
            /*
             * U+000A LINE FEED (LF)
             * U+000D CARRIAGE RETURN (CR)
             */
            if (*data == 0x0A || *data == 0x0D) {
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) data, 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                do { for (size_t i = 0; i < indent; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);

                data++;
                pos = data;
            }
            else {
                data++;
            }
        }

        if (pos != data) {
            do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        }
    }
    else {
        do { status = cb(cast(const(lxb_char_t)*) comment.char_data.data.data, comment.char_data.data.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                                    ;
    }

    do { status = cb(cast(const(lxb_char_t)*) " -->", 4, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_pretty_document_cb(lxb_dom_document_t* document, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    do { status = cb(cast(const(lxb_char_t)*) "#document", 9, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_serialize_tree_cb(lxb_dom_node_t* node, lxb_html_serialize_cb_f cb, void* ctx)
{
    /* For a document we must serialize all children without document node. */
    if (node.local_name == LXB_TAG__DOCUMENT) {
        node = node.first_child;

        while (node != null) {
            lxb_status_t status = lxb_html_serialize_node_cb(node, cb, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            node = node.next;
        }

        return LXB_STATUS_OK;
    }

    return lxb_html_serialize_node_cb(node, cb, ctx);
}

lxb_status_t lxb_html_serialize_tree_str(lxb_dom_node_t* node, lexbor_str_t* str)
{
    lxb_html_serialize_ctx_t ctx = void;

    if (str.data == null) {
        lexbor_str_init(str, node.owner_document.text, 1024);

        if (str.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    ctx.str = str;
    ctx.mraw = node.owner_document.text;

    return lxb_html_serialize_tree_cb(node, &lxb_html_serialize_str_callback, &ctx);
}

lxb_status_t lxb_html_serialize_pretty_tree_cb(lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx)
{
    if (opt & LXB_HTML_SERIALIZE_OPT_HTML5TEST) {
        opt |= LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING
               | LXB_HTML_SERIALIZE_OPT_TAG_WITH_NS
               | LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT
               | LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE
               | LXB_HTML_SERIALIZE_OPT_RAW;
    }

    /* For a document we must serialize all children without document node. */
    if (node.local_name == LXB_TAG__DOCUMENT) {
        node = node.first_child;

        while (node != null) {
            lxb_status_t status = lxb_html_serialize_pretty_node_cb(node, opt,
                                                               indent, cb, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            node = node.next;
        }

        return LXB_STATUS_OK;
    }

    return lxb_html_serialize_pretty_node_cb(node, opt, indent, cb, ctx);
}

lxb_status_t lxb_html_serialize_pretty_tree_str(lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lexbor_str_t* str)
{
    lxb_html_serialize_ctx_t ctx = void;

    if (str.data == null) {
        lexbor_str_init(str, node.owner_document.text, 1024);

        if (str.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    ctx.str = str;
    ctx.mraw = node.owner_document.text;

    return lxb_html_serialize_pretty_tree_cb(node, opt, indent,
                                             &lxb_html_serialize_str_callback,
                                             &ctx);
}

private lxb_status_t lxb_html_serialize_pretty_send_escaping_string(const(lxb_char_t)* data, size_t len, size_t indent, bool with_indent, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;
    const(lxb_char_t)* pos = data;
    const(lxb_char_t)* end = data + len;

    do { for (size_t i = 0; i < indent; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    while (data != end) {
        switch (*data) {
            /* U+0026 AMPERSAND (&) */
            case 0x26:
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&amp;", 5, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data++;
                pos = data;

                break;

            /* {0xC2, 0xA0} NO-BREAK SPACE */
            case 0xC2:
                data += 1;
                if (data == end) {
                    break;
                }

                if (*data != 0xA0) {
                    continue;
                }

                data -= 1;

                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&nbsp;", 6, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data += 2;
                pos = data;

                break;

            /* U+003C LESS-THAN SIGN (<) */
            case 0x3C:
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&lt;", 4, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data++;
                pos = data;

                break;

            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) "&gt;", 4, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

                data++;
                pos = data;

                break;

            /*
             * U+000A LINE FEED (LF)
             * U+000D CARRIAGE RETURN (CR)
             */
            case 0x0A:
            case 0x0D:
                if (with_indent) {
                    if (pos != data) {
                        do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                    }

                    do { status = cb(cast(const(lxb_char_t)*) "\n", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                    do { for (size_t i = 0; i < indent; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);

                    data++;
                    pos = data;

                    break;
                }
                /* fall through */

                goto default; /* C fallthrough */
            default:
                data++;

                break;
        }
    }

    if (pos != data) {
        do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    }

    do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_html_serialize_pretty_send_string(const(lxb_char_t)* data, size_t len, size_t indent, bool with_indent, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    do { for (size_t i = 0; i < indent; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);
    do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    if (with_indent) {
        const(lxb_char_t)* pos = data;
        const(lxb_char_t)* end = data + len;

        while (data != end) {
            /*
             * U+000A LINE FEED (LF)
             * U+000D CARRIAGE RETURN (CR)
             */
            if (*data == 0x0A || *data == 0x0D) {
                if (pos != data) {
                    do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                }

                do { status = cb(cast(const(lxb_char_t)*) data, 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                do { for (size_t i = 0; i < indent; i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);

                data++;
                pos = data;
            }
            else {
                data++;
            }
        }

        if (pos != data) {
            do { status = cb(cast(const(lxb_char_t)*) pos, (data - pos), ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        }
    }
    else {
        do { status = cb(cast(const(lxb_char_t)*) data, len, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    }

    do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
}
