module parserino.lexbor.dom.interfaces.node;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interface_;
public import parserino.lexbor.dom.collection;
public import parserino.lexbor.dom.interfaces.event_target;
import parserino.lexbor.dom.interfaces.attr;
import parserino.lexbor.dom.interfaces.document;
import parserino.lexbor.dom.interfaces.document_type;
import parserino.lexbor.dom.interfaces.element;
import parserino.lexbor.dom.interfaces.processing_instruction;

extern(C) @nogc nothrow:
__gshared:

// ---- node.h ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_dom_node_simple_walker_f = lexbor_action_t function(lxb_dom_node_t* node, void* ctx);

/*
 * Callbacks for node events.
 */

/*
 * insert, remove, destroy:
 *     Can be called for any node. When inserting an element, attribute,
 *     comment and so on.
 *
 * set_value:
 *     Can be called only when the attribute value is changed.
 */
alias lxb_dom_node_cb_insert_f = lxb_status_t function(lxb_dom_node_t* node);

alias lxb_dom_node_cb_remove_f = lxb_status_t function(lxb_dom_node_t* node);

alias lxb_dom_node_cb_destroy_f = lxb_status_t function(lxb_dom_node_t* node);

alias lxb_dom_node_cb_set_value_f = lxb_status_t function(lxb_dom_node_t* node, const(lxb_char_t)* value, size_t length);

enum lxb_dom_node_type_t {
    LXB_DOM_NODE_TYPE_UNDEF = 0x00,
    LXB_DOM_NODE_TYPE_ELEMENT = 0x01,
    LXB_DOM_NODE_TYPE_ATTRIBUTE = 0x02,
    LXB_DOM_NODE_TYPE_TEXT = 0x03,
    LXB_DOM_NODE_TYPE_CDATA_SECTION = 0x04,
    LXB_DOM_NODE_TYPE_ENTITY_REFERENCE = 0x05, // historical
    LXB_DOM_NODE_TYPE_ENTITY = 0x06, // historical
    LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION = 0x07,
    LXB_DOM_NODE_TYPE_COMMENT = 0x08,
    LXB_DOM_NODE_TYPE_DOCUMENT = 0x09,
    LXB_DOM_NODE_TYPE_DOCUMENT_TYPE = 0x0A,
    LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT = 0x0B,
    LXB_DOM_NODE_TYPE_NOTATION = 0x0C, // historical
    LXB_DOM_NODE_TYPE_LAST_ENTRY = 0x0D
}
alias LXB_DOM_NODE_TYPE_UNDEF = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_UNDEF;
alias LXB_DOM_NODE_TYPE_ELEMENT = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_ELEMENT;
alias LXB_DOM_NODE_TYPE_ATTRIBUTE = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_ATTRIBUTE;
alias LXB_DOM_NODE_TYPE_TEXT = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_TEXT;
alias LXB_DOM_NODE_TYPE_CDATA_SECTION = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_CDATA_SECTION;
alias LXB_DOM_NODE_TYPE_ENTITY_REFERENCE = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_ENTITY_REFERENCE;
alias LXB_DOM_NODE_TYPE_ENTITY = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_ENTITY;
alias LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION;
alias LXB_DOM_NODE_TYPE_COMMENT = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_COMMENT;
alias LXB_DOM_NODE_TYPE_DOCUMENT = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_DOCUMENT;
alias LXB_DOM_NODE_TYPE_DOCUMENT_TYPE = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_DOCUMENT_TYPE;
alias LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT;
alias LXB_DOM_NODE_TYPE_NOTATION = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_NOTATION;
alias LXB_DOM_NODE_TYPE_LAST_ENTRY = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_LAST_ENTRY;


struct lxb_dom_node {
    lxb_dom_event_target_t event_target;

    /* For example: <LalAla:DiV Fix:Me="value"> */

    uintptr_t local_name; /* , lowercase, without prefix: div */
    uintptr_t prefix; /* lowercase: lalala */
    uintptr_t ns; /* namespace */

    lxb_dom_document_t* owner_document;

    lxb_dom_node_t* next;
    lxb_dom_node_t* prev;
    lxb_dom_node_t* parent;
    lxb_dom_node_t* first_child;
    lxb_dom_node_t* last_child;
    void* user;

    lxb_dom_node_type_t type;

}




















/*
 * Memory of returns value will be freed in document destroy moment.
 * If you need to release returned resource after use, then call the
 * lxb_dom_document_destroy_text(node->owner_document, text) function.
 */



/*
 * Inline functions
 */
 lxb_tag_id_t lxb_dom_node_tag_id(lxb_dom_node_t* node)
{
    return node.local_name;
}

 lxb_dom_node_t* lxb_dom_node_next(lxb_dom_node_t* node)
{
    return node.next;
}

 lxb_dom_node_t* lxb_dom_node_prev(lxb_dom_node_t* node)
{
    return node.prev;
}

 lxb_dom_node_t* lxb_dom_node_parent(lxb_dom_node_t* node)
{
    return node.parent;
}

 lxb_dom_node_t* lxb_dom_node_first_child(lxb_dom_node_t* node)
{
    return node.first_child;
}

 lxb_dom_node_t* lxb_dom_node_last_child(lxb_dom_node_t* node)
{
    return node.last_child;
}

/*
 * No inline functions for ABI.
 */






// ---- node.c ----
/*
 * Copyright (C) 2018-2022 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

alias lxb_dom_node_cb_ctx_t = lxb_dom_node_cb_ctx;

alias lxb_dom_node_attr_cmp_f = bool function(lxb_dom_node_cb_ctx_t* ctx, lxb_dom_attr_t* attr);

struct lxb_dom_node_cb_ctx {
    lxb_dom_collection_t* col;
    lxb_status_t status;
    lxb_dom_node_attr_cmp_f cmp_func;

    lxb_dom_attr_id_t name_id;
    lxb_ns_prefix_id_t prefix_id;

    const(lxb_char_t)* value;
    size_t value_length;
}

 lxb_dom_attr_data_t* lxb_dom_attr_local_name_append(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length);

 const(lxb_tag_data_t)* lxb_tag_append(lexbor_hash_t* hash, lxb_tag_id_t tag_id, const(lxb_char_t)* name, size_t length);

 const(lxb_ns_data_t)* lxb_ns_append(lexbor_hash_t* hash, const(lxb_char_t)* link, size_t length);






















lxb_dom_node_t* lxb_dom_node_interface_create(lxb_dom_document_t* document)
{
    lxb_dom_node_t* element = void;

    element = cast(lxb_dom_node*) lexbor_mraw_calloc(document.mraw,
                                 lxb_dom_node_t.sizeof);
    if (element == null) {
        return null;
    }

    element.owner_document = lxb_dom_document_owner(document);
    element.type = LXB_DOM_NODE_TYPE_UNDEF;

    return element;
}

lxb_dom_node_t* lxb_dom_node_interface_clone(lxb_dom_document_t* document, const(lxb_dom_node_t)* node, bool is_attr)
{
    lxb_dom_node_t* new_ = void;

    new_ = lxb_dom_node_interface_create(document);
    if (new_ == null) {
        return null;
    }

    if (lxb_dom_node_interface_copy(new_, node, is_attr) != LXB_STATUS_OK) {
        return cast(typeof(return)) lxb_dom_document_destroy_interface(new_);
    }

    return new_;
}

lxb_dom_node_t* lxb_dom_node_interface_destroy(lxb_dom_node_t* node)
{
    lxb_dom_document_t* doc = node.owner_document;

    if (doc.node_cb.destroy != null) {
        doc.node_cb.destroy(node);
    }

    return cast(lxb_dom_node*) lexbor_mraw_free(doc.mraw, node);
}

lxb_status_t lxb_dom_node_interface_copy(lxb_dom_node_t* dst, const(lxb_dom_node_t)* src, bool is_attr)
{
    lxb_dom_document_t* from = void, to = void;
    const(lxb_ns_data_t)* ns = void;
    const(lxb_tag_data_t)* tag = void;
    const(lxb_ns_prefix_data_t)* prefix = void;
    const(lexbor_hash_entry_t)* entry = void;
    const(lxb_dom_attr_data_t)* data = void;

    dst.type = src.type;
    dst.user = cast(void*) src.user;

    if (dst.owner_document == src.owner_document) {
        dst.local_name = src.local_name;
        dst.ns = src.ns;
        dst.prefix = src.prefix;

        return LXB_STATUS_OK;
    }

    from = cast(lxb_dom_document*) src.owner_document;
    to = dst.owner_document;

    if (is_attr) {
        if (src.local_name < LXB_DOM_ATTR__LAST_ENTRY) {
            dst.local_name = src.local_name;
        }
        else {
            data = lxb_dom_attr_data_by_id(from.attrs, src.local_name);
            if (data == null) {
                return LXB_STATUS_ERROR_NOT_EXISTS;
            }

            entry = &data.entry;

            data = lxb_dom_attr_local_name_append(to.attrs,
                                                  lexbor_hash_entry_str(entry),
                                                  entry.length);
            if (data == null) {
                return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            }

            dst.local_name = cast(lxb_dom_attr_id_t) data;
        }
    }
    else {
        if (src.local_name < LXB_TAG__LAST_ENTRY) {
            dst.local_name = src.local_name;
        }
        else {
            tag = lxb_tag_data_by_id(src.local_name);
            if (tag == null) {
                return LXB_STATUS_ERROR_NOT_EXISTS;
            }

            entry = &tag.entry;

            tag = lxb_tag_append(to.tags, LXB_TAG__UNDEF,
                                 lexbor_hash_entry_str(entry), entry.length);
            if (tag == null) {
                return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            }

            dst.local_name = cast(lxb_dom_attr_id_t) tag;
        }
    }

    if (src.ns < LXB_NS__LAST_ENTRY) {
        dst.ns = src.ns;
    }
    else {
        ns = lxb_ns_data_by_id(from.ns, src.ns);
        if (ns == null) {
            return LXB_STATUS_ERROR_NOT_EXISTS;
        }

        entry = &ns.entry;

        ns = lxb_ns_append(to.ns, lexbor_hash_entry_str(entry),
                           entry.length);
        if (ns == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        dst.ns = cast(lxb_ns_id_t) ns;
    }

    if (src.prefix < LXB_NS__LAST_ENTRY) {
        dst.prefix = src.prefix;
    }
    else {
        prefix = lxb_ns_prefix_data_by_id(from.prefix, src.prefix);
        if (prefix == null) {
            return LXB_STATUS_ERROR_NOT_EXISTS;
        }

        entry = &prefix.entry;

        prefix = lxb_ns_prefix_append(to.prefix, lexbor_hash_entry_str(entry),
                                      entry.length);
        if (prefix == null) {
            return LXB_STATUS_ERROR;
        }

        dst.prefix = cast(lxb_ns_prefix_id_t) prefix;
    }

    return LXB_STATUS_OK;
}

lxb_dom_node_t* lxb_dom_node_destroy(lxb_dom_node_t* node)
{
    lxb_dom_node_remove(node);
    return cast(typeof(return)) lxb_dom_document_destroy_interface(node);
}

lxb_dom_node_t* lxb_dom_node_destroy_deep(lxb_dom_node_t* root)
{
    lxb_dom_node_t* tmp = void;
    lxb_dom_node_t* node = root;

    while (node != null) {
        if (node.first_child != null) {
            node = node.first_child;
        }
        else {
            while(node != root && node.next == null) {
                tmp = node.parent;

                lxb_dom_node_destroy(node);

                node = tmp;
            }

            if (node == root) {
                lxb_dom_node_destroy(node);

                break;
            }

            tmp = node.next;

            lxb_dom_node_destroy(node);

            node = tmp;
        }
    }

    return null;
}

lxb_dom_node_t* lxb_dom_node_clone(lxb_dom_node_t* node, bool deep)
{
    return lxb_dom_document_import_node(node.owner_document, node, deep);
}

const(lxb_char_t)* lxb_dom_node_name(lxb_dom_node_t* node, size_t* len)
{
    switch (node.type) {
        case LXB_DOM_NODE_TYPE_ELEMENT:
            return lxb_dom_element_tag_name((cast(lxb_dom_element_t*) (node)),
                                            len);

        case LXB_DOM_NODE_TYPE_ATTRIBUTE:
            return lxb_dom_attr_qualified_name((cast(lxb_dom_attr_t*) (node)),
                                               len);

        case LXB_DOM_NODE_TYPE_TEXT:
            if (len != null) {
                *len = "#text".length;
            }

            return cast(const(lxb_char_t)*) "#text";

        case LXB_DOM_NODE_TYPE_CDATA_SECTION:
            if (len != null) {
                *len = "#cdata-section".length;
            }

            return cast(const(lxb_char_t)*) "#cdata-section";

        case LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION:
            return lxb_dom_processing_instruction_target((cast(lxb_dom_processing_instruction_t*) (node)),
                                                         len);

        case LXB_DOM_NODE_TYPE_COMMENT:
            if (len != null) {
                *len = "#comment".length;
            }

            return cast(const(lxb_char_t)*) "#comment";

        case LXB_DOM_NODE_TYPE_DOCUMENT:
            if (len != null) {
                *len = "#document".length;
            }

            return cast(const(lxb_char_t)*) "#document";

        case LXB_DOM_NODE_TYPE_DOCUMENT_TYPE:
            return lxb_dom_document_type_name((cast(lxb_dom_document_type_t*) (node)),
                                              len);

        case LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT:
            if (len != null) {
                *len = "#document-fragment".length;
            }

            return cast(const(lxb_char_t)*) "#document-fragment";

        default:
            break;
    }

    if (len != null) {
        *len = 0;
    }

    return null;
}

void lxb_dom_node_insert_child_wo_events(lxb_dom_node_t* to, lxb_dom_node_t* node)
{
    if (to.last_child != null) {
        to.last_child.next = node;
    }
    else {
        to.first_child = node;
    }

    node.parent = to;
    node.next = null;
    node.prev = to.last_child;

    to.last_child = node;
}

void lxb_dom_node_insert_child(lxb_dom_node_t* to, lxb_dom_node_t* node)
{
    lxb_dom_node_insert_child_wo_events(to, node);

    if (node.owner_document.node_cb.insert != null) {
        node.owner_document.node_cb.insert(node);
    }
}

void lxb_dom_node_insert_before_wo_events(lxb_dom_node_t* to, lxb_dom_node_t* node)
{
    if (to.prev != null) {
        to.prev.next = node;
    }
    else {
        if (to.parent != null) {
            to.parent.first_child = node;
        }
    }

    node.parent = to.parent;
    node.next = to;
    node.prev = to.prev;

    to.prev = node;
}

void lxb_dom_node_insert_before(lxb_dom_node_t* to, lxb_dom_node_t* node)
{
    lxb_dom_node_insert_before_wo_events(to, node);

    if (node.owner_document.node_cb.insert != null) {
        node.owner_document.node_cb.insert(node);
    }
}

void lxb_dom_node_insert_after_wo_events(lxb_dom_node_t* to, lxb_dom_node_t* node)
{
    if (to.next != null) {
        to.next.prev = node;
    }
    else {
        if (to.parent != null) {
            to.parent.last_child = node;
        }
    }

    node.parent = to.parent;
    node.next = to.next;
    node.prev = to;
    to.next = node;
}

void lxb_dom_node_insert_after(lxb_dom_node_t* to, lxb_dom_node_t* node)
{
    lxb_dom_node_insert_after_wo_events(to, node);

    if (node.owner_document.node_cb.insert != null) {
        node.owner_document.node_cb.insert(node);
    }
}

void lxb_dom_node_remove_wo_events(lxb_dom_node_t* node)
{
    if (node.parent != null) {
        if (node.parent.first_child == node) {
            node.parent.first_child = node.next;
        }

        if (node.parent.last_child == node) {
            node.parent.last_child = node.prev;
        }
    }

    if (node.next != null) {
        node.next.prev = node.prev;
    }

    if (node.prev != null) {
        node.prev.next = node.next;
    }

    node.parent = null;
    node.next = null;
    node.prev = null;
}

void lxb_dom_node_remove(lxb_dom_node_t* node)
{
    if (node.owner_document.node_cb.remove != null) {
        node.owner_document.node_cb.remove(node);
    }

    lxb_dom_node_remove_wo_events(node);
}

lxb_status_t lxb_dom_node_replace_all(lxb_dom_node_t* parent, lxb_dom_node_t* node)
{
    while (parent.first_child != null) {
        lxb_dom_node_destroy_deep(parent.first_child);
    }

    lxb_dom_node_insert_child(parent, node);

    return LXB_STATUS_OK;
}

void lxb_dom_node_simple_walk(lxb_dom_node_t* root, lxb_dom_node_simple_walker_f walker_cb, void* ctx)
{
    lexbor_action_t action = void;
    lxb_dom_node_t* node = root.first_child;

    while (node != null) {
        action = walker_cb(node, ctx);
        if (action == LEXBOR_ACTION_STOP) {
            return;
        }

        if (node.first_child != null && action != LEXBOR_ACTION_NEXT) {
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
}

 lxb_status_t lxb_dom_node_prepare_by_attr(lxb_dom_document_t* document, lxb_dom_node_cb_ctx_t* cb_ctx, const(lxb_char_t)* qname, size_t qlen)
{
    size_t length = void;
    const(lxb_char_t)* prefix_end = void;
    const(lxb_dom_attr_data_t)* attr_data = void;
    const(lxb_ns_prefix_data_t)* prefix_data = void;

    cb_ctx.prefix_id = LXB_NS__UNDEF;

    prefix_end = cast(const(ubyte)*) memchr(qname, ':', qlen);

    if (prefix_end != null) {
        length = prefix_end - qname;

        if (length == 0) {
            return LXB_STATUS_ERROR_WRONG_ARGS;
        }

        prefix_data = lxb_ns_prefix_data_by_name(document.prefix, qname, qlen);
        if (prefix_data == null) {
            return LXB_STATUS_STOP;
        }

        cb_ctx.prefix_id = prefix_data.prefix_id;

        length += 1;

        if (length >= qlen) {
            return LXB_STATUS_ERROR_WRONG_ARGS;
        }

        qname += length;
        qlen -= length;
    }

    attr_data = lxb_dom_attr_data_by_local_name(document.attrs, qname, qlen);
    if (attr_data == null) {
        return LXB_STATUS_STOP;
    }

    cb_ctx.name_id = attr_data.attr_id;

    return LXB_STATUS_OK;
}

 lxb_status_t lxb_dom_node_prepare_by(lxb_dom_document_t* document, lxb_dom_node_cb_ctx_t* cb_ctx, const(lxb_char_t)* qname, size_t qlen)
{
    size_t length = void;
    const(lxb_char_t)* prefix_end = void;
    const(lxb_tag_data_t)* tag_data = void;
    const(lxb_ns_prefix_data_t)* prefix_data = void;

    cb_ctx.prefix_id = LXB_NS__UNDEF;

    prefix_end = cast(const(ubyte)*) memchr(qname, ':', qlen);

    if (prefix_end != null) {
        length = prefix_end - qname;

        if (length == 0) {
            return LXB_STATUS_ERROR_WRONG_ARGS;
        }

        prefix_data = lxb_ns_prefix_data_by_name(document.prefix, qname, qlen);
        if (prefix_data == null) {
            return LXB_STATUS_STOP;
        }

        cb_ctx.prefix_id = prefix_data.prefix_id;

        length += 1;

        if (length >= qlen) {
            return LXB_STATUS_ERROR_WRONG_ARGS;
        }

        qname += length;
        qlen -= length;
    }

    tag_data = lxb_tag_data_by_name(document.tags, qname, qlen);
    if (tag_data == null) {
        return LXB_STATUS_STOP;
    }

    cb_ctx.name_id = tag_data.tag_id;

    return LXB_STATUS_OK;
}

lxb_status_t lxb_dom_node_by_tag_name(lxb_dom_node_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* qualified_name, size_t len)
{
    lxb_status_t status = void;
    lxb_dom_node_cb_ctx_t cb_ctx; // C: = {0}

    cb_ctx.col = collection;

    /* "*" (U+002A) */
    if (len == 1 && *qualified_name == 0x2A) {
        lxb_dom_node_simple_walk(root, &lxb_dom_node_by_tag_name_cb_all,
                                 &cb_ctx);
        return cb_ctx.status;
    }

    status = lxb_dom_node_prepare_by(root.owner_document, &cb_ctx,
                                     qualified_name, len);
    if (status != LXB_STATUS_OK) {
        if (status == LXB_STATUS_STOP) {
            return LXB_STATUS_OK;
        }

        return status;
    }

    lxb_dom_node_simple_walk((cast(lxb_dom_node_t*) (root)),
                             &lxb_dom_node_by_tag_name_cb, &cb_ctx);

    return cb_ctx.status;
}

private lexbor_action_t lxb_dom_node_by_tag_name_cb_all(lxb_dom_node_t* node, void* ctx)
{
    if (node.type != LXB_DOM_NODE_TYPE_ELEMENT) {
        return LEXBOR_ACTION_OK;
    }

    lxb_dom_node_cb_ctx_t* cb_ctx = cast(lxb_dom_node_cb_ctx*) ctx;

    cb_ctx.status = lxb_dom_collection_append(cb_ctx.col, node);
    if (cb_ctx.status != LXB_STATUS_OK) {
        return LEXBOR_ACTION_STOP;
    }

    return LEXBOR_ACTION_OK;
}

private lexbor_action_t lxb_dom_node_by_tag_name_cb(lxb_dom_node_t* node, void* ctx)
{
    if (node.type != LXB_DOM_NODE_TYPE_ELEMENT) {
        return LEXBOR_ACTION_OK;
    }

    lxb_dom_node_cb_ctx_t* cb_ctx = cast(lxb_dom_node_cb_ctx*) ctx;

    if (node.local_name == cb_ctx.name_id
        && node.prefix == cb_ctx.prefix_id)
    {
        cb_ctx.status = lxb_dom_collection_append(cb_ctx.col, node);
        if (cb_ctx.status != LXB_STATUS_OK) {
            return LEXBOR_ACTION_STOP;
        }
    }

    return LEXBOR_ACTION_OK;
}

lxb_status_t lxb_dom_node_by_class_name(lxb_dom_node_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* class_name, size_t len)
{
    if (class_name == null || len == 0) {
        return LXB_STATUS_OK;
    }

    lxb_dom_node_cb_ctx_t cb_ctx; // C: = {0}

    cb_ctx.col = collection;
    cb_ctx.value = class_name;
    cb_ctx.value_length = len;

    lxb_dom_node_simple_walk((cast(lxb_dom_node_t*) (root)),
                             &lxb_dom_node_by_class_name_cb, &cb_ctx);

    return cb_ctx.status;
}

private lexbor_action_t lxb_dom_node_by_class_name_cb(lxb_dom_node_t* node, void* ctx)
{
    if (node.type != LXB_DOM_NODE_TYPE_ELEMENT) {
        return LEXBOR_ACTION_OK;
    }

    lxb_dom_node_cb_ctx_t* cb_ctx = cast(lxb_dom_node_cb_ctx*) ctx;
    lxb_dom_element_t* el = (cast(lxb_dom_element_t*) (node));

    if (el.attr_class == null
        || el.attr_class.value == null
        || el.attr_class.value.length < cb_ctx.value_length)
    {
        return LEXBOR_ACTION_OK;
    }

    const(lxb_char_t)* data = el.attr_class.value.data;
    size_t length = el.attr_class.value.length;

    bool is_it = false;
    const(lxb_char_t)* pos = data;
    const(lxb_char_t)* end = data + length;

    lxb_dom_document_t* doc = el.node.owner_document;

    for (; data < end; data++) {
        if ((*data == ' ' || *data == '\t' || *data == '\n' || *data == '\f' || *data == '\r')) {

            if (pos != data && cast(size_t) (data - pos) == cb_ctx.value_length) {
                if (doc.compat_mode == LXB_DOM_DOCUMENT_CMODE_QUIRKS) {
                    is_it = lexbor_str_data_ncasecmp(pos, cb_ctx.value,
                                                     cb_ctx.value_length);
                }
                else {
                    is_it = lexbor_str_data_ncmp(pos, cb_ctx.value,
                                                 cb_ctx.value_length);
                }

                if (is_it) {
                    cb_ctx.status = lxb_dom_collection_append(cb_ctx.col,
                                                               node);
                    if (cb_ctx.status != LXB_STATUS_OK) {
                        return LEXBOR_ACTION_STOP;
                    }

                    return LEXBOR_ACTION_OK;
                }
            }

            if (cast(size_t) (end - data) < cb_ctx.value_length) {
                return LEXBOR_ACTION_OK;
            }

            pos = data + 1;
        }
    }

    if (cast(size_t) (end - pos) == cb_ctx.value_length) {
        if (doc.compat_mode == LXB_DOM_DOCUMENT_CMODE_QUIRKS) {
            is_it = lexbor_str_data_ncasecmp(pos, cb_ctx.value,
                                             cb_ctx.value_length);
        }
        else {
            is_it = lexbor_str_data_ncmp(pos, cb_ctx.value,
                                         cb_ctx.value_length);
        }

        if (is_it) {
            cb_ctx.status = lxb_dom_collection_append(cb_ctx.col, node);
            if (cb_ctx.status != LXB_STATUS_OK) {
                return LEXBOR_ACTION_STOP;
            }
        }
    }

    return LEXBOR_ACTION_OK;
}

lxb_status_t lxb_dom_node_by_attr(lxb_dom_node_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* qualified_name, size_t qname_len, const(lxb_char_t)* value, size_t value_len, bool case_insensitive)
{
    lxb_status_t status = void;
    lxb_dom_node_cb_ctx_t cb_ctx; // C: = {0}

    cb_ctx.col = collection;
    cb_ctx.value = value;
    cb_ctx.value_length = value_len;

    status = lxb_dom_node_prepare_by_attr(root.owner_document, &cb_ctx,
                                          qualified_name, qname_len);
    if (status != LXB_STATUS_OK) {
        if (status == LXB_STATUS_STOP) {
            return LXB_STATUS_OK;
        }

        return status;
    }

    if (case_insensitive) {
        cb_ctx.cmp_func = &lxb_dom_node_by_attr_cmp_full_case;
    }
    else {
        cb_ctx.cmp_func = &lxb_dom_node_by_attr_cmp_full;
    }

    lxb_dom_node_simple_walk(root, &lxb_dom_node_by_attr_cb, &cb_ctx);

    return cb_ctx.status;
}

lxb_status_t lxb_dom_node_by_attr_begin(lxb_dom_node_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* qualified_name, size_t qname_len, const(lxb_char_t)* value, size_t value_len, bool case_insensitive)
{
    lxb_status_t status = void;
    lxb_dom_node_cb_ctx_t cb_ctx; // C: = {0}

    cb_ctx.col = collection;
    cb_ctx.value = value;
    cb_ctx.value_length = value_len;

    status = lxb_dom_node_prepare_by_attr(root.owner_document, &cb_ctx,
                                          qualified_name, qname_len);
    if (status != LXB_STATUS_OK) {
        if (status == LXB_STATUS_STOP) {
            return LXB_STATUS_OK;
        }

        return status;
    }

    if (case_insensitive) {
        cb_ctx.cmp_func = &lxb_dom_node_by_attr_cmp_begin_case;
    }
    else {
        cb_ctx.cmp_func = &lxb_dom_node_by_attr_cmp_begin;
    }

    lxb_dom_node_simple_walk((cast(lxb_dom_node_t*) (root)),
                             &lxb_dom_node_by_attr_cb, &cb_ctx);

    return cb_ctx.status;
}

lxb_status_t lxb_dom_node_by_attr_end(lxb_dom_node_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* qualified_name, size_t qname_len, const(lxb_char_t)* value, size_t value_len, bool case_insensitive)
{
    lxb_status_t status = void;
    lxb_dom_node_cb_ctx_t cb_ctx; // C: = {0}

    cb_ctx.col = collection;
    cb_ctx.value = value;
    cb_ctx.value_length = value_len;

    status = lxb_dom_node_prepare_by_attr(root.owner_document, &cb_ctx,
                                          qualified_name, qname_len);
    if (status != LXB_STATUS_OK) {
        if (status == LXB_STATUS_STOP) {
            return LXB_STATUS_OK;
        }

        return status;
    }

    if (case_insensitive) {
        cb_ctx.cmp_func = &lxb_dom_node_by_attr_cmp_end_case;
    }
    else {
        cb_ctx.cmp_func = &lxb_dom_node_by_attr_cmp_end;
    }

    lxb_dom_node_simple_walk(root, &lxb_dom_node_by_attr_cb, &cb_ctx);

    return cb_ctx.status;
}

lxb_status_t lxb_dom_node_by_attr_contain(lxb_dom_node_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* qualified_name, size_t qname_len, const(lxb_char_t)* value, size_t value_len, bool case_insensitive)
{
    lxb_status_t status = void;
    lxb_dom_node_cb_ctx_t cb_ctx; // C: = {0}

    cb_ctx.col = collection;
    cb_ctx.value = value;
    cb_ctx.value_length = value_len;

    status = lxb_dom_node_prepare_by_attr(root.owner_document, &cb_ctx,
                                          qualified_name, qname_len);
    if (status != LXB_STATUS_OK) {
        if (status == LXB_STATUS_STOP) {
            return LXB_STATUS_OK;
        }

        return status;
    }

    if (case_insensitive) {
        cb_ctx.cmp_func = &lxb_dom_node_by_attr_cmp_contain_case;
    }
    else {
        cb_ctx.cmp_func = &lxb_dom_node_by_attr_cmp_contain;
    }

    lxb_dom_node_simple_walk(root, &lxb_dom_node_by_attr_cb, &cb_ctx);

    return cb_ctx.status;
}

private lexbor_action_t lxb_dom_node_by_attr_cb(lxb_dom_node_t* node, void* ctx)
{
    if (node.type != LXB_DOM_NODE_TYPE_ELEMENT) {
        return LEXBOR_ACTION_OK;
    }

    lxb_dom_attr_t* attr = void;
    lxb_dom_node_cb_ctx_t* cb_ctx = cast(lxb_dom_node_cb_ctx*) ctx;
    lxb_dom_element_t* el = (cast(lxb_dom_element_t*) (node));

    attr = lxb_dom_element_attr_by_id(el, cb_ctx.name_id);
    if (attr == null) {
        return LEXBOR_ACTION_OK;
    }

    if ((cb_ctx.value_length == 0 && (attr.value == null || attr.value.length == 0))
        || cb_ctx.cmp_func(cb_ctx, attr))
    {
        cb_ctx.status = lxb_dom_collection_append(cb_ctx.col, node);

        if (cb_ctx.status != LXB_STATUS_OK) {
            return LEXBOR_ACTION_STOP;
        }
    }

    return LEXBOR_ACTION_OK;
}

private bool lxb_dom_node_by_attr_cmp_full(lxb_dom_node_cb_ctx_t* ctx, lxb_dom_attr_t* attr)
{
    if (attr.value != null && ctx.value_length == attr.value.length
        && lexbor_str_data_ncmp(attr.value.data, ctx.value,
                                ctx.value_length))
    {
        return true;
    }

    return attr.value == null && ctx.value_length == 0;
}

private bool lxb_dom_node_by_attr_cmp_full_case(lxb_dom_node_cb_ctx_t* ctx, lxb_dom_attr_t* attr)
{
    if (attr.value != null && ctx.value_length == attr.value.length
        && lexbor_str_data_ncasecmp(attr.value.data, ctx.value,
                                    ctx.value_length))
    {
        return true;
    }

    return attr.value == null && ctx.value_length == 0;
}

private bool lxb_dom_node_by_attr_cmp_begin(lxb_dom_node_cb_ctx_t* ctx, lxb_dom_attr_t* attr)
{
    if (attr.value != null && ctx.value_length <= attr.value.length
        && lexbor_str_data_ncmp(attr.value.data, ctx.value,
                                ctx.value_length))
    {
        return true;
    }

    return attr.value == null && ctx.value_length == 0;
}

private bool lxb_dom_node_by_attr_cmp_begin_case(lxb_dom_node_cb_ctx_t* ctx, lxb_dom_attr_t* attr)
{
    if (attr.value != null && ctx.value_length <= attr.value.length
        && lexbor_str_data_ncasecmp(attr.value.data,
                                    ctx.value, ctx.value_length))
    {
        return true;
    }

    return attr.value == null && ctx.value_length == 0;
}

private bool lxb_dom_node_by_attr_cmp_end(lxb_dom_node_cb_ctx_t* ctx, lxb_dom_attr_t* attr)
{
    if (attr.value != null && ctx.value_length <= attr.value.length) {
        size_t dif = attr.value.length - ctx.value_length;

        if (lexbor_str_data_ncmp_end(&attr.value.data[dif],
                                     ctx.value, ctx.value_length))
        {
            return true;
        }
    }

    return attr.value == null && ctx.value_length == 0;
}

private bool lxb_dom_node_by_attr_cmp_end_case(lxb_dom_node_cb_ctx_t* ctx, lxb_dom_attr_t* attr)
{
    if (attr.value != null && ctx.value_length <= attr.value.length) {
        size_t dif = attr.value.length - ctx.value_length;

        if (lexbor_str_data_ncasecmp_end(&attr.value.data[dif],
                                         ctx.value, ctx.value_length))
        {
            return true;
        }
    }

    return attr.value == null && ctx.value_length == 0;
}

private bool lxb_dom_node_by_attr_cmp_contain(lxb_dom_node_cb_ctx_t* ctx, lxb_dom_attr_t* attr)
{
    if (attr.value != null && ctx.value_length <= attr.value.length
        && lexbor_str_data_ncmp_contain(attr.value.data, attr.value.length,
                                        ctx.value, ctx.value_length))
    {
        return true;
    }

    return attr.value == null && ctx.value_length == 0;
}

private bool lxb_dom_node_by_attr_cmp_contain_case(lxb_dom_node_cb_ctx_t* ctx, lxb_dom_attr_t* attr)
{
    if (attr.value != null && ctx.value_length <= attr.value.length
        && lexbor_str_data_ncasecmp_contain(attr.value.data, attr.value.length,
                                            ctx.value, ctx.value_length))
    {
        return true;
    }

    return attr.value == null && ctx.value_length == 0;
}

lxb_char_t* lxb_dom_node_text_content(lxb_dom_node_t* node, size_t* len)
{
    lxb_char_t* text = void;
    size_t length = 0;

    switch (node.type) {
        case LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT:
        case LXB_DOM_NODE_TYPE_ELEMENT:
            lxb_dom_node_simple_walk(node, &lxb_dom_node_text_content_size,
                                     &length);

            text = lxb_dom_document_create_text(node.owner_document,
                                                (length + 1));
            if (text == null) {
                goto failed;
            }

            lxb_dom_node_simple_walk(node, &lxb_dom_node_text_content_concatenate,
                                     &text);

            text -= length;

            break;

        case LXB_DOM_NODE_TYPE_ATTRIBUTE: {
            const(lxb_char_t)* attr_text = void;

            attr_text = lxb_dom_attr_value((cast(lxb_dom_attr_t*) (node)), &length);
            if (attr_text == null) {
                goto failed;
            }

            text = lxb_dom_document_create_text(node.owner_document,
                                                (length + 1));
            if (text == null) {
                goto failed;
            }

            /* +1 == with null '\0' */
            memcpy(text, attr_text, lxb_char_t.sizeof * (length + 1));

            break;
        }

        case LXB_DOM_NODE_TYPE_TEXT:
        case LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION:
        case LXB_DOM_NODE_TYPE_COMMENT: {
            lxb_dom_character_data_t* ch_data = void;

            ch_data = (cast(lxb_dom_character_data_t*) (node));
            length = ch_data.data.length;

            text = lxb_dom_document_create_text(node.owner_document,
                                                (length + 1));
            if (text == null) {
                goto failed;
            }

            /* +1 == with null '\0' */
            memcpy(text, ch_data.data.data, lxb_char_t.sizeof * (length + 1));

            break;
        }

        default:
            goto failed;
    }

    if (len != null) {
        *len = length;
    }

    text[length] = 0x00;

    return text;

failed:

    if (len != null) {
        *len = 0;
    }

    return null;
}

private lexbor_action_t lxb_dom_node_text_content_size(lxb_dom_node_t* node, void* ctx)
{
    if (node.type == LXB_DOM_NODE_TYPE_TEXT) {
        *(cast(size_t*) ctx) += (cast(lxb_dom_text_t*) (node)).char_data.data.length;
    }

    return LEXBOR_ACTION_OK;
}

private lexbor_action_t lxb_dom_node_text_content_concatenate(lxb_dom_node_t* node, void* ctx)
{
    if (node.type != LXB_DOM_NODE_TYPE_TEXT) {
        return LEXBOR_ACTION_OK;
    }

    lxb_char_t** text = cast(lxb_char_t**) ctx;
    lxb_dom_character_data_t* ch_data = &(cast(lxb_dom_text_t*) (node)).char_data;

    memcpy(*text, ch_data.data.data, lxb_char_t.sizeof * ch_data.data.length);

    *text = *text + ch_data.data.length;

    return LEXBOR_ACTION_OK;
}

lxb_status_t lxb_dom_node_text_content_set(lxb_dom_node_t* node, const(lxb_char_t)* content, size_t len)
{
    lxb_status_t status = void;

    switch (node.type) {
        case LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT:
        case LXB_DOM_NODE_TYPE_ELEMENT: {
            lxb_dom_text_t* text = void;

            text = lxb_dom_document_create_text_node(node.owner_document,
                                                     content, len);
            if (text == null) {
                return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            }

            status = lxb_dom_node_replace_all(node, (cast(lxb_dom_node_t*) (text)));
            if (status != LXB_STATUS_OK) {
                lxb_dom_document_destroy_interface(text);

                return status;
            }

            break;
        }

        case LXB_DOM_NODE_TYPE_ATTRIBUTE:
            return lxb_dom_attr_set_existing_value((cast(lxb_dom_attr_t*) (node)),
                                                   content, len);

        case LXB_DOM_NODE_TYPE_TEXT:
        case LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION:
        case LXB_DOM_NODE_TYPE_COMMENT:
            return lxb_dom_character_data_replace((cast(lxb_dom_character_data_t*) (node)),
                                                  content, len, 0, 0);

        default:
            return LXB_STATUS_OK;
    }

    return LXB_STATUS_OK;
}

bool lxb_dom_node_is_empty(const(lxb_dom_node_t)* root)
{
    lxb_char_t chr = void;
    lexbor_str_t* str = void;
    const(lxb_char_t)* data = void, end = void;
    lxb_dom_node_t* node = cast(lxb_dom_node*) root.first_child;

    while (node != null) {
        if(node.local_name != LXB_TAG__EM_COMMENT) {
            if(node.local_name != LXB_TAG__TEXT)
                return false;

            str = &(cast(lxb_dom_text_t*) (node)).char_data.data;
            data = str.data;
            end = data + str.length;

            while (data < end) {
                chr = *data++;

                if ((chr != ' ' && chr != '\t' && chr != '\n' && chr != '\f' && chr != '\r')) {
                    return false;
                }
            }
        }

        if(node.first_child != null) {
            node = node.first_child;
        }
        else {
            while(node != root && node.next == null) {
                node = node.parent;
            }

            if(node == root) {
                break;
            }

            node = node.next;
        }
    }

    return true;
}

lxb_tag_id_t lxb_dom_node_tag_id_noi(lxb_dom_node_t* node)
{
    return lxb_dom_node_tag_id(node);
}

lxb_dom_node_t* lxb_dom_node_next_noi(lxb_dom_node_t* node)
{
    return lxb_dom_node_next(node);
}

lxb_dom_node_t* lxb_dom_node_prev_noi(lxb_dom_node_t* node)
{
    return lxb_dom_node_prev(node);
}

lxb_dom_node_t* lxb_dom_node_parent_noi(lxb_dom_node_t* node)
{
    return lxb_dom_node_parent(node);
}

lxb_dom_node_t* lxb_dom_node_first_child_noi(lxb_dom_node_t* node)
{
    return lxb_dom_node_first_child(node);
}

lxb_dom_node_t* lxb_dom_node_last_child_noi(lxb_dom_node_t* node)
{
    return lxb_dom_node_last_child(node);
}
