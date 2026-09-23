module parserino.lexbor.dom.interfaces.node;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interface_;
public import parserino.lexbor.dom.collection;
public import parserino.lexbor.dom.exception;
public import parserino.lexbor.dom.interfaces.event_target;
import parserino.lexbor.dom.interfaces.attr;
import parserino.lexbor.dom.interfaces.document;
import parserino.lexbor.dom.interfaces.document_type;
import parserino.lexbor.dom.interfaces.element;
import parserino.lexbor.dom.interfaces.processing_instruction;
import parserino.lexbor.dom.interfaces.shadow_root;

extern(C) @nogc nothrow:
__gshared:

// ---- node.h ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_dom_node_simple_walker_f = lexbor_action_t function(lxb_dom_node_t* node, void* ctx);

alias lxb_dom_node_descendants_f = lxb_status_t function(lxb_dom_node_t* node, void* ctx);

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
alias lxb_dom_node_cb_insertion_f = lxb_status_t function(lxb_dom_node_t* inserted_node);

alias lxb_dom_node_cb_removing_f = lxb_status_t function(lxb_dom_node_t* removed_node, lxb_dom_node_t* old_parent);

alias lxb_dom_node_cb_moving_f = lxb_status_t function(lxb_dom_node_t* moved_node, lxb_dom_node_t* old_parent);

alias lxb_dom_node_cb_destroy_f = lxb_status_t function(lxb_dom_node_t* node);

alias lxb_dom_node_cb_children_changed_f = lxb_status_t function(lxb_dom_node_t* parent);

alias lxb_dom_node_cb_post_connection_f = lxb_status_t function(lxb_dom_node_t* connected_node);

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
    LXB_DOM_NODE_TYPE_CHARACTER_DATA,
    LXB_DOM_NODE_TYPE_SHADOW_ROOT,
    LXB_DOM_NODE_TYPE_LAST_ENTRY
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
alias LXB_DOM_NODE_TYPE_CHARACTER_DATA = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_CHARACTER_DATA;
alias LXB_DOM_NODE_TYPE_SHADOW_ROOT = lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_SHADOW_ROOT;
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
 * Add a node as a child.
 *
 * Function according to specification. Node.appendChild(node).
 *
 * The function not only adds a node as a child, but also validates
 * the possibility of adding it.
 * For example, the lxb_dom_node_insert_child() function does not perform
 * any validation.
 *
 * @param[in] lxb_dom_node_t *. Where to add. Not NULL.
 * @param[in] lxb_dom_node_t *. Who to add. Not NULL.
 *
 * @return LXB_DOM_EXCEPTION_OK if successful, otherwise an error exception code.
 */

/*
 * Insert before child.
 *
 * Function according to specification. Node.insertBefore(node, child).
 *
 * The function not only insert a node as a child, but also validates
 * the possibility of adding it.
 * For example, the lxb_dom_node_insert_before() function does not perform
 * any validation.
 *
 * @param[in] lxb_dom_node_t *. Where to add. Not NULL.
 * @param[in] lxb_dom_node_t *. Who to add. Not NULL.
 * @param[in] lxb_dom_node_t *. The child before need to insert. Not NULL.
 *
 * @return LXB_DOM_EXCEPTION_OK if successful, otherwise an error exception code.
 */




/*
 * Removing a node.
 *
 * Function according to specification. Node.removeChild(node).
 *
 * The function not only removing a node, but also validates the possibility
 * of adding it.
 * For example, the lxb_dom_node_remove() function does not perform
 * any validation.
 *
 * @param[in] lxb_dom_node_t *. Where remove. Not NULL.
 * @param[in] lxb_dom_node_t *. Who remove. Not NULL.
 *
 * @return LXB_DOM_EXCEPTION_OK if successful, otherwise an error exception code.
 */

/*
 * The function replaces the child with a node.
 *
 * Function according to specification. Node.replaceChild(node, child).
 *
 * The function not only replace a node, but also validates the possibility
 * of adding it.
 * For example, the lxb_dom_node_replace_all() function does not perform
 * any validation.
 *
 * @param[in] lxb_dom_node_t *. Where replace. Not NULL.
 * @param[in] lxb_dom_node_t *. Who replace. Not NULL.
 * @param[in] lxb_dom_node_t *. Replaceable child. Not NULL.
 *
 * @return LXB_DOM_EXCEPTION_OK if successful, otherwise an error exception code.
 */






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

 lxb_dom_node_type_t lxb_dom_node_type(lxb_dom_node_t* node)
{
    return node.type;
}

/*
 * No inline functions for ABI.
 */







// ---- node.c ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
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

struct lxb_dom_node_id_cb_ctx_t {
    lxb_dom_node_t* node;
    const(lxb_char_t)* value;
    size_t length;
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
    lxb_dom_document_t* doc = node.owner_document;

    lxb_dom_node_insert_child_wo_events(to, node);

    if (!(lxb_dom_document_opt(doc) & LXB_DOM_DOCUMENT_OPT_WO_EVENTS)
        && doc.mutation.inserted != null)
    {
        cast(void) lxb_dom_node_shadow_including_descendants(node,
                                   &lxb_dom_node_shadow_including_walker, doc);
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
    lxb_dom_document_t* doc = node.owner_document;

    lxb_dom_node_insert_before_wo_events(to, node);

    if (!(lxb_dom_document_opt(doc) & LXB_DOM_DOCUMENT_OPT_WO_EVENTS)
        && doc.mutation.inserted != null)
    {
        cast(void) lxb_dom_node_shadow_including_descendants(node,
                                    &lxb_dom_node_shadow_including_walker, doc);
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
    lxb_dom_document_t* doc = node.owner_document;

    lxb_dom_node_insert_after_wo_events(to, node);

    if (!(lxb_dom_document_opt(doc) & LXB_DOM_DOCUMENT_OPT_WO_EVENTS)
        && doc.mutation.inserted != null) {
        cast(void) lxb_dom_node_shadow_including_descendants(node,
                                    &lxb_dom_node_shadow_including_walker, doc);
    }
}

lxb_dom_exception_code_t lxb_dom_node_pre_insert_validity(lxb_dom_node_t* parent, lxb_dom_node_t* node, lxb_dom_node_t* child)
{
    size_t count = void;
    lxb_dom_node_t* tmp = void;

    /*
     * If parent is not a Document, DocumentFragment, or Element node, then
     * throw a "HierarchyRequestError" DOMException.
     */
    if (parent == null) {
        return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
    }

    switch (parent.type) {
        case LXB_DOM_NODE_TYPE_ELEMENT:
        case LXB_DOM_NODE_TYPE_DOCUMENT:
        case LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT:
            break;

        default:
            return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
    }

    if (lxb_dom_node_host_including_inclusive_ancestor(node, parent)) {
        return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
    }

    /*
     * If child is non-null and its parent is not parent,
     * then throw a "NotFoundError" DOMException.
     */
    if (child != null && parent != child.parent) {
        return LXB_DOM_EXCEPTION_NOT_FOUND_ERR;
    }

    /*
     * If node is not a DocumentFragment, DocumentType, Element,
     * or CharacterData node, then throw a "HierarchyRequestError" DOMException.
     */
    if (node == null) {
        return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
    }

    switch (parent.type) {
        case LXB_DOM_NODE_TYPE_ELEMENT:
        case LXB_DOM_NODE_TYPE_DOCUMENT:
        case LXB_DOM_NODE_TYPE_DOCUMENT_TYPE:
        case LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT:
        case LXB_DOM_NODE_TYPE_CHARACTER_DATA:
        case LXB_DOM_NODE_TYPE_TEXT:
            break;

        default:
            return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
    }

    /*
     * If either node is a Text node and parent is a document, or node is
     * a doctype and parent is not a document, then throw
     * a "HierarchyRequestError" DOMException.
     */
    if ((node.type == LXB_DOM_NODE_TYPE_TEXT
        && parent.type == LXB_DOM_NODE_TYPE_DOCUMENT)
        || (node.type == LXB_DOM_NODE_TYPE_DOCUMENT_TYPE
            && parent.type != LXB_DOM_NODE_TYPE_DOCUMENT))
    {
        return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
    }

    if (parent.type != LXB_DOM_NODE_TYPE_DOCUMENT) {
        return LXB_DOM_EXCEPTION_OK;
    }

    switch (node.type) {
        case LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT:
            tmp = node.first_child;

            if (tmp == null) {
                return LXB_DOM_EXCEPTION_OK;
            }

            count = 0;

            do {
                if (tmp.type == LXB_DOM_NODE_TYPE_TEXT) {
                    return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
                }
                else if (tmp.type == LXB_DOM_NODE_TYPE_ELEMENT) {
                    count += 1;

                    if (count > 1) {
                        return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
                    }
                }

                tmp = tmp.next;
            }
            while (tmp != null);

            if (count != 1) {
                return LXB_DOM_EXCEPTION_OK;
            }

            /* Fall Through. */

            goto case; /* C fallthrough */
        case LXB_DOM_NODE_TYPE_ELEMENT:
            tmp = parent.first_child;

            while (tmp != null) {
                if (tmp.type == LXB_DOM_NODE_TYPE_ELEMENT) {
                    return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
                }

                tmp = tmp.next;
            }

            if (child == null) {
                return LXB_DOM_EXCEPTION_OK;
            }

            if (child.type == LXB_DOM_NODE_TYPE_DOCUMENT_TYPE) {
                return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
            }

            tmp = child.next;

            while (tmp != null) {
                if (tmp.type == LXB_DOM_NODE_TYPE_DOCUMENT_TYPE) {
                    return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
                }

                tmp = tmp.next;
            }

            break;

        case LXB_DOM_NODE_TYPE_DOCUMENT_TYPE:
            tmp = parent.first_child;

            while (tmp != null) {
                if (tmp.type == LXB_DOM_NODE_TYPE_DOCUMENT_TYPE) {
                    return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
                }
                else if (tmp.type == LXB_DOM_NODE_TYPE_ELEMENT
                         && child == null)
                {
                    return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
                }

                tmp = tmp.next;
            }

            if (child == null) {
                return LXB_DOM_EXCEPTION_OK;
            }

            tmp = child.prev;

            while (tmp != null) {
                if (tmp.type == LXB_DOM_NODE_TYPE_ELEMENT) {
                    return LXB_DOM_EXCEPTION_HIERARCHY_REQUEST_ERR;
                }

                tmp = tmp.prev;
            }

            break;

        default:
            break;
    }

    return LXB_DOM_EXCEPTION_OK;
}

lxb_dom_exception_code_t lxb_dom_node_pre_insert(lxb_dom_node_t* parent, lxb_dom_node_t* node, lxb_dom_node_t* child)
{
    lxb_dom_exception_code_t ex_code = void;

    ex_code = lxb_dom_node_pre_insert_validity(parent, node, child);
    if (ex_code != LXB_DOM_EXCEPTION_OK) {
        return ex_code;
    }

    if (child == node) {
        child = node.next;
    }

    return lxb_dom_node_insert(parent, node, child, false);
}

 lxb_dom_exception_code_t lxb_dom_node_insert_node(lxb_dom_node_t* parent, lxb_dom_node_t* node, lxb_dom_node_t* child, bool suppress_observers)
{
    lxb_status_t status = void;
    lxb_dom_exception_code_t code = void;
    lxb_dom_document_t* doc = node.owner_document;

    code = lxb_dom_node_adopt(node);
    if (code != LXB_DOM_EXCEPTION_OK) {
        return code;
    }

    if (child == null) {
        lxb_dom_node_insert_child(parent, node);
    }
    else {
        lxb_dom_node_insert_before(child, node);
    }

    if (!(lxb_dom_document_opt(doc) & LXB_DOM_DOCUMENT_OPT_WO_EVENTS)
        && doc.mutation.inserted != null)
    {
        status = lxb_dom_node_shadow_including_descendants(node,
                                    &lxb_dom_node_shadow_including_walker, doc);
        return (status == LXB_STATUS_OK)
                    ? LXB_DOM_EXCEPTION_OK
                    : LXB_DOM_EXCEPTION_ERR;
    }

    return LXB_DOM_EXCEPTION_OK;
}

lxb_dom_exception_code_t lxb_dom_node_insert(lxb_dom_node_t* parent, lxb_dom_node_t* node, lxb_dom_node_t* child, bool suppress_observers)
{
    lxb_dom_node_t* tmp = void, next = void;
    lxb_dom_exception_code_t code = void;

    if (node.type == LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT) {
        if (node.first_child == null) {
            return LXB_DOM_EXCEPTION_OK;
        }
    }

    /* TODO: live range. */

    if (node.type != LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT) {
        return lxb_dom_node_insert_node(parent, node, child,
                                        suppress_observers);
    }

    tmp = node.first_child;

    while (tmp != null) {
        next = tmp.next;

        code = lxb_dom_node_insert_node(parent, tmp, child,
                                        suppress_observers);
        if (code != LXB_DOM_EXCEPTION_OK) {
            return code;
        }

        tmp = next;
    }

    /* TODO: Shadow and queue a tree mutation record. */

    return LXB_DOM_EXCEPTION_OK;
}

private lxb_status_t lxb_dom_node_shadow_including_walker(lxb_dom_node_t* node, void* ctx)
{
    lxb_dom_document_t* doc = cast(lxb_dom_document*) ctx;

    return doc.mutation.inserted(node);
}

lxb_dom_exception_code_t lxb_dom_node_insert_before_spec(lxb_dom_node_t* dst, lxb_dom_node_t* node, lxb_dom_node_t* child)
{
    return lxb_dom_node_pre_insert(dst, node, child);
}

lxb_dom_exception_code_t lxb_dom_node_append_child(lxb_dom_node_t* parent, lxb_dom_node_t* node)
{
    return lxb_dom_node_pre_insert(parent, node, null);
}

lxb_dom_exception_code_t lxb_dom_node_remove_child(lxb_dom_node_t* parent, lxb_dom_node_t* child)
{
    if (parent != child.parent) {
        return LXB_DOM_EXCEPTION_NOT_FOUND_ERR;
    }

    return lxb_dom_node_remove_spec(child, false);
}

lxb_dom_exception_code_t lxb_dom_node_replace_child(lxb_dom_node_t* parent, lxb_dom_node_t* node, lxb_dom_node_t* child)
{
    lxb_dom_node_t* tmp = void, next = void;
    lxb_dom_node_t* before = void;
    lxb_dom_exception_code_t code = void;

    code = lxb_dom_node_pre_insert_validity(parent, node, child);
    if (code != LXB_DOM_EXCEPTION_OK) {
        return code;
    }

    before = child.prev;
    if (before == null) {
        before = child.next;
    }

    if (child.parent != null) {
        code = lxb_dom_node_remove_spec(child, true);
        if (code != LXB_DOM_EXCEPTION_OK) {
            return code;
        }
    }

    if (node.type != LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT) {
        return lxb_dom_node_insert_node(parent, node, before, true);
    }

    tmp = node.first_child;

    while (tmp != null) {
        next = tmp.next;

        code = lxb_dom_node_insert_node(parent, tmp, before, true);
        if (code != LXB_DOM_EXCEPTION_OK) {
            return code;
        }

        tmp = next;
    }

    return LXB_DOM_EXCEPTION_OK;
}

lxb_dom_exception_code_t lxb_dom_node_replace_all_spec(lxb_dom_node_t* parent, lxb_dom_node_t* node)
{
    lxb_dom_node_t* child = void, next = void;
    lxb_dom_exception_code_t code = void;

    child = parent.first_child;

    while (child != null) {
        next = child.next;

        code = lxb_dom_node_remove_spec(child, true);
        if (code != LXB_DOM_EXCEPTION_OK) {
            return code;
        }

        child = next;
    }

    return lxb_dom_node_append_child(parent, node);
}

lxb_dom_exception_code_t lxb_dom_node_remove_spec(lxb_dom_node_t* node, bool suppress_observers)
{
    if (node.parent == null) {
        return LXB_DOM_EXCEPTION_OK;
    }

    /* TODO: 3. Run the live range pre-remove steps, given node. */

    /*
     * TODO: For each NodeIterator object iterator whose root’s node document
     * is node’s node document, run the NodeIterator pre-remove steps given
     * node and iterator.
     */

    lxb_dom_node_remove(node);

    /* TODO: finish everything else. */

    return LXB_DOM_EXCEPTION_OK;
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
    lxb_dom_node_t* parent = node.parent;
    lxb_dom_document_t* doc = node.owner_document;

    lxb_dom_node_remove_wo_events(node);

    if (!(lxb_dom_document_opt(doc) & LXB_DOM_DOCUMENT_OPT_WO_EVENTS)
        && doc.mutation.removed != null)
    {
        doc.mutation.removed(node, parent);
    }
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

lxb_dom_node_t* lxb_dom_node_by_id(lxb_dom_node_t* root, const(lxb_char_t)* qualified_name, size_t len)
{
    lxb_dom_node_id_cb_ctx_t ctx = void;

    ctx.node = null;
    ctx.value = qualified_name;
    ctx.length = len;

    lxb_dom_node_simple_walk(root, &lxb_dom_node_by_id_cb, &ctx);

    return ctx.node;
}

private lexbor_action_t lxb_dom_node_by_id_cb(lxb_dom_node_t* node, void* ctx)
{
    lxb_dom_node_id_cb_ctx_t* context = void;
    const(lxb_dom_attr_t)* attr_id = void;

    if (node.type != LXB_DOM_NODE_TYPE_ELEMENT) {
        return LEXBOR_ACTION_OK;
    }

    context = cast(lxb_dom_node_id_cb_ctx_t*) ctx;
    attr_id = (cast(lxb_dom_element_t*) (node)).attr_id;

    if (attr_id == null
        || attr_id.value == null
        || attr_id.value.length != context.length)
    {
        return LEXBOR_ACTION_OK;
    }

    const(lxb_char_t)* data = attr_id.value.data;
    size_t length = attr_id.value.length;

    if (lexbor_str_data_ncmp(context.value, data, length)) {
        context.node = node;
        return LEXBOR_ACTION_STOP;
    }

    return LEXBOR_ACTION_OK;
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

bool lxb_dom_node_host_including_inclusive_ancestor(const(lxb_dom_node_t)* node, const(lxb_dom_node_t)* parent)
{
    const(lxb_dom_shadow_root_t)* root = void;

    while (parent != null) {
        if (parent == node) {
            return true;
        }

        if (parent.type == LXB_DOM_NODE_TYPE_SHADOW_ROOT) {
            root = cast(const(lxb_dom_shadow_root_t)*) (cast(lxb_dom_shadow_root_t*) (parent));
            parent = &root.host.node;

            continue;
        }

        parent = parent.parent;
    }

    return false;
}

/*
 * https://dom.spec.whatwg.org/#concept-shadow-including-inclusive-descendant
 * This function in not complite implementation of the algorithm, but it is
 * enough for our needs. It is used to call mutation callback for all nodes
 * in subtree their descendants.
 *
 * TODO: implement shadow root.
 */
lxb_status_t lxb_dom_node_shadow_including_descendants(lxb_dom_node_t* root, lxb_dom_node_descendants_f walker, void* ctx)
{
    lxb_status_t status = void;
    lxb_dom_node_t* node = root;

    while (node != null) {
        status = walker(node, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }

        if (node.first_child != null && status != LXB_STATUS_NEXT) {
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

lxb_dom_exception_code_t lxb_dom_node_adopt(lxb_dom_node_t* node)
{
    lxb_dom_exception_code_t code = void;

    if (node.parent != null) {
        code = lxb_dom_node_remove_spec(node, false);
        if (code != LXB_DOM_EXCEPTION_OK) {
            return code;
        }
    }

    /* TODO: If document is not oldDocument steps. */

    return LXB_DOM_EXCEPTION_OK;
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

lxb_dom_node_type_t lxb_dom_node_type_noi(lxb_dom_node_t* node)
{
    return lxb_dom_node_type(node);
}
