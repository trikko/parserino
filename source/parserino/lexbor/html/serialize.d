module parserino.lexbor.html.serialize;

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
import parserino.lexbor.core.str_res;

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
    LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE = 0x40
}
alias LXB_HTML_SERIALIZE_OPT_UNDEF = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_UNDEF;
alias LXB_HTML_SERIALIZE_OPT_SKIP_WS_NODES = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_SKIP_WS_NODES;
alias LXB_HTML_SERIALIZE_OPT_SKIP_COMMENT = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_SKIP_COMMENT;
alias LXB_HTML_SERIALIZE_OPT_RAW = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_RAW;
alias LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING;
alias LXB_HTML_SERIALIZE_OPT_TAG_WITH_NS = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_TAG_WITH_NS;
alias LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT;
alias LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE = lxb_html_serialize_opt.LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE;


alias lxb_html_serialize_cb_f = lxb_status_t function(const(lxb_char_t)* data, size_t len, void* ctx);













// ---- serialize.c ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_html_serialize_ctx_t {
    lexbor_str_t* str;
    lexbor_mraw_t* mraw;
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

        status = lxb_html_serialize_attribute_cb(attr, false, cb, ctx);
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
    do { status = cb(cast(const(lxb_char_t)*) ">", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

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

private lxb_status_t lxb_html_serialize_document_type_full_cb(lxb_dom_document_type_t* doctype, lxb_html_serialize_cb_f cb, void* ctx)
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

    if (doctype.public_id.data != null && doctype.public_id.length != 0) {
        do { status = cb(cast(const(lxb_char_t)*) " PUBLIC ", 8, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

        do { status = cb(cast(const(lxb_char_t)*) doctype.public_id.data, doctype.public_id.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                               ;

        do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
    }

    if (doctype.system_id.data != null && doctype.system_id.length != 0) {
        if (doctype.public_id.length == 0) {
            do { status = cb(cast(const(lxb_char_t)*) " SYSTEM", 7, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
        }

        do { status = cb(cast(const(lxb_char_t)*) " \"", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

        do { status = cb(cast(const(lxb_char_t)*) doctype.system_id.data, doctype.system_id.length, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0)
                                                               ;

        do { status = cb(cast(const(lxb_char_t)*) "\"", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
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

private lxb_status_t lxb_html_serialize_attribute_cb(lxb_dom_attr_t* attr, bool has_raw, lxb_html_serialize_cb_f cb, void* ctx)
{
    size_t length = void;
    lxb_status_t status = void;
    const(lxb_char_t)* str = void;
    const(lxb_dom_attr_data_t)* data = void;

    data = lxb_dom_attr_data_by_id(attr.node.owner_document.attrs,
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

lxb_status_t lxb_html_serialize_pretty_cb(lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

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
                                                             cb, ctx);
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

            if (temp.content != null) {
                if (temp.content.node.first_child != null)
                {
                    do { for (size_t i = 0; i < (deep + 1); i++) { do { status = cb(cast(const(lxb_char_t)*) "  ", 2, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0); } } while (0);
                    do { status = cb(cast(const(lxb_char_t)*) "#document-fragment", 18, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
                    do { status = cb(cast(const(lxb_char_t)*) "\n", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

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
            do { status = cb(cast(const(lxb_char_t)*) ":", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);
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

    attr = element.first_attr;

    while (attr != null) {
        do { status = cb(cast(const(lxb_char_t)*) " ", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

        status = lxb_html_serialize_attribute_cb(attr,
                                                 cast(bool) (opt & LXB_HTML_SERIALIZE_OPT_RAW),
                                                 cb, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }

        attr = attr.next;
    }

    do { status = cb(cast(const(lxb_char_t)*) ">", 1, ctx); if (status != LXB_STATUS_OK) { return status; } } while (0);

    return LXB_STATUS_OK;
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

        return LXB_STATUS_OK;
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
