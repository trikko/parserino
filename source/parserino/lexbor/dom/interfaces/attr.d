module parserino.lexbor.dom.interfaces.attr;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.hash;
public import parserino.lexbor.core.str;
public import parserino.lexbor.ns.ns;
public import parserino.lexbor.dom.interface_;
public import parserino.lexbor.dom.interfaces.node;
public import parserino.lexbor.dom.interfaces.attr_const;
public import parserino.lexbor.dom.interfaces.document;
import parserino.lexbor.dom.interfaces.attr_res;
import parserino.lexbor.dom.interfaces.element;

extern(C) @nogc nothrow:
__gshared:

// ---- attr.h ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_dom_attr_data_t {
    lexbor_hash_entry_t entry;
    lxb_dom_attr_id_t attr_id;
    size_t ref_count;
    bool read_only;
}

/* More memory to God of memory! */
struct lxb_dom_attr {
    lxb_dom_node_t node;

    /* For example: <LalAla:DiV Fix:Me="value"> */

    lxb_dom_attr_id_t upper_name; /* uppercase, with prefix: FIX:ME */
    lxb_dom_attr_id_t qualified_name; /* original, with prefix: Fix:Me */

    lexbor_str_t* value;

    lxb_dom_element_t* owner;

    lxb_dom_attr_t* next;
    lxb_dom_attr_t* prev;
}
















/*
 * Inline functions
 */
 const(lxb_char_t)* lxb_dom_attr_local_name(lxb_dom_attr_t* attr, size_t* len)
{
    const(lxb_dom_attr_data_t)* data = void;

    data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) attr.node.owner_document.attrs,
                                   attr.node.local_name);

    if (len != null) {
        *len = data.entry.length;
    }

    return lexbor_hash_entry_str(&data.entry);
}

 const(lxb_char_t)* lxb_dom_attr_value(lxb_dom_attr_t* attr, size_t* len)
{
    if (attr.value == null) {
        if (len != null) {
            *len = 0;
        }

        return null;
    }

    if (len != null) {
        *len = attr.value.length;
    }

    return attr.value.data;
}

/*
 * No inline functions for ABI.
 */


// ---- attr.c ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */



const(lxb_ns_data_t)* lxb_ns_append(lexbor_hash_t* hash, const(lxb_char_t)* link, size_t length);

lxb_dom_attr_t* lxb_dom_attr_interface_create(lxb_dom_document_t* document)
{
    lxb_dom_attr_t* attr = void;

    attr = cast(lxb_dom_attr*) lexbor_mraw_calloc(document.mraw, lxb_dom_attr_t.sizeof);
    if (attr == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (attr));

    node.owner_document = lxb_dom_document_owner(document);
    node.type = LXB_DOM_NODE_TYPE_ATTRIBUTE;

    return attr;
}

lxb_dom_attr_t* lxb_dom_attr_interface_clone(lxb_dom_document_t* document, const(lxb_dom_attr_t)* attr)
{
    lxb_dom_attr_t* new_ = void;
    const(lxb_dom_attr_data_t)* data = void;

    new_ = lxb_dom_attr_interface_create(document);
    if (new_ == null) {
        return null;
    }

    new_.node.ns = attr.node.ns;

    if (document == attr.node.owner_document) {
        new_.qualified_name = attr.qualified_name;
    }
    else {
        data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) attr.node.owner_document.attrs,
                                       attr.qualified_name);
        if (data == null) {
            goto failed;
        }

        if (data.attr_id < LXB_DOM_ATTR__LAST_ENTRY) {
            new_.qualified_name = attr.qualified_name;
        }
        else {
            data = lxb_dom_attr_qualified_name_append(document.attrs,
                                                      lexbor_hash_entry_str(&data.entry),
                                                      data.entry.length);
            if (data == null) {
                goto failed;
            }

            new_.qualified_name = cast(lxb_dom_attr_id_t) data;
        }
    }

    if (lxb_dom_node_interface_copy(&new_.node, &attr.node, true)
        != LXB_STATUS_OK)
    {
        goto failed;
    }

    if (attr.value == null) {
        return new_;
    }

    new_.value = cast(lexbor_str_t*) lexbor_mraw_calloc(document.mraw, lexbor_str_t.sizeof);
    if (new_.value == null) {
        goto failed;
    }

    if (lexbor_str_copy(new_.value, attr.value, document.text) == null) {
        goto failed;
    }

    return new_;

failed:

    return lxb_dom_attr_interface_destroy(new_);
}

lxb_dom_attr_t* lxb_dom_attr_interface_destroy(lxb_dom_attr_t* attr)
{
    lexbor_str_t* value = void;
    lxb_dom_document_t* doc = (cast(lxb_dom_node_t*) (attr)).owner_document;

    value = attr.value;

    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (attr)));

    if (value != null) {
        if (value.data != null) {
            lexbor_mraw_free(doc.text, value.data);
        }

        lexbor_mraw_free(doc.mraw, value);
    }

    return null;
}

lxb_status_t lxb_dom_attr_set_name(lxb_dom_attr_t* attr, const(lxb_char_t)* name, size_t length, bool to_lowercase)
{
    lxb_dom_attr_data_t* data = void;
    lxb_dom_document_t* doc = (cast(lxb_dom_node_t*) (attr)).owner_document;

    data = lxb_dom_attr_local_name_append(doc.attrs, name, length);
    if (data == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    attr.node.local_name = data.attr_id;

    if (to_lowercase == false) {
        data = lxb_dom_attr_qualified_name_append(doc.attrs, name, length);
        if (data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        attr.qualified_name = cast(lxb_dom_attr_id_t) data;
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_dom_attr_set_name_ns(lxb_dom_attr_t* attr, const(lxb_char_t)* link, size_t link_length, const(lxb_char_t)* name, size_t name_length, bool to_lowercase)
{
    size_t length = void;
    lxb_char_t* p = void;
    const(lxb_ns_data_t)* ns_data = void;
    lxb_dom_attr_data_t* data = void;
    lxb_dom_document_t* doc = (cast(lxb_dom_node_t*) (attr)).owner_document;

    ns_data = lxb_ns_append(doc.ns, link, link_length);
    if (ns_data == null || ns_data.ns_id == LXB_NS__UNDEF) {
        return LXB_STATUS_ERROR;
    }

    attr.node.ns = ns_data.ns_id;

    /* TODO: append check https://www.w3.org/TR/xml/#NT-Name */

    p = cast(lxb_char_t*) memchr(name, ':', name_length);
    if (p == null) {
        return lxb_dom_attr_set_name(attr, name, name_length, to_lowercase);
    }

    length = p - name;

    /* local name */
    data = lxb_dom_attr_local_name_append(doc.attrs, &name[(length + 1)],
                                          (name_length - (length + 1)));
    if (data == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    attr.node.local_name = cast(lxb_dom_attr_id_t) data;

    /* qualified name */
    data = lxb_dom_attr_qualified_name_append(doc.attrs, name, name_length);
    if (data == null) {
        return LXB_STATUS_ERROR;
    }

    attr.qualified_name = cast(lxb_dom_attr_id_t) data;

    /* prefix */
    attr.node.prefix = cast(lxb_ns_prefix_id_t) lxb_ns_prefix_append(doc.ns, name,
                                                                  length);
    if (attr.node.prefix == 0) {
        return LXB_STATUS_ERROR;
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_dom_attr_set_value(lxb_dom_attr_t* attr, const(lxb_char_t)* value, size_t value_len)
{
    lxb_status_t status = void;
    lxb_dom_document_t* doc = (cast(lxb_dom_node_t*) (attr)).owner_document;

    if (doc.node_cb.set_value != null) {
        status = doc.node_cb.set_value((cast(lxb_dom_node_t*) (attr)),
                                         value, value_len);
        if (status != LXB_STATUS_OK) {
            return status;
        }
    }

    if (attr.value == null) {
        attr.value = cast(lexbor_str_t*) lexbor_mraw_calloc(doc.mraw, lexbor_str_t.sizeof);
        if (attr.value == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    if (attr.value.data == null) {
        lexbor_str_init(attr.value, doc.text, value_len);
        if (attr.value.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }
    else {
        attr.value.length = 0;

        if (lexbor_str_size(attr.value) <= value_len) {
            const(lxb_char_t)* tmp = void;

            tmp = lexbor_str_realloc(attr.value, doc.text, (value_len + 1));
            if (tmp == null) {
                return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            }
        }
    }

    memcpy(attr.value.data, value, lxb_char_t.sizeof * value_len);

    attr.value.data[value_len] = 0x00;
    attr.value.length = value_len;

    return LXB_STATUS_OK;
}

lxb_status_t lxb_dom_attr_set_value_wo_copy(lxb_dom_attr_t* attr, lxb_char_t* value, size_t value_len)
{
    if (attr.value == null) {
        lxb_dom_document_t* doc = (cast(lxb_dom_node_t*) (attr)).owner_document;

        attr.value = cast(lexbor_str_t*) lexbor_mraw_alloc(doc.mraw, lexbor_str_t.sizeof);
        if (attr.value == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    attr.value.data = value;
    attr.value.length = value_len;

    return LXB_STATUS_OK;
}

lxb_status_t lxb_dom_attr_set_existing_value(lxb_dom_attr_t* attr, const(lxb_char_t)* value, size_t value_len)
{
    return lxb_dom_attr_set_value(attr, value, value_len);
}

lxb_status_t lxb_dom_attr_clone_name_value(lxb_dom_attr_t* attr_from, lxb_dom_attr_t* attr_to)
{
    lexbor_str_t* value = void;

    attr_to.node.local_name = attr_from.node.local_name;
    attr_to.qualified_name = attr_from.qualified_name;

    value = attr_from.value;

    if (value != null && value.data != null) {
        return lxb_dom_attr_set_value(attr_to, value.data, value.length);
    }

    return LXB_STATUS_OK;
}

bool lxb_dom_attr_compare(lxb_dom_attr_t* first, lxb_dom_attr_t* second)
{
    if (first.node.local_name == second.node.local_name
        && first.node.ns == second.node.ns
        && first.qualified_name == second.qualified_name)
    {
        if (first.value == null) {
            if (second.value == null) {
                return true;
            }

            return false;
        }

        if (second.value != null
            && first.value.length == second.value.length
            && lexbor_str_data_ncmp(first.value.data, second.value.data,
                                    first.value.length))
        {
            return true;
        }
    }

    return false;
}

void lxb_dom_attr_remove(lxb_dom_attr_t* attr)
{
    lxb_dom_element_t* element = attr.owner;
    lxb_dom_document_t* doc = (cast(lxb_dom_node_t*) (attr)).owner_document;

    if (doc.node_cb.remove != null) {
        doc.node_cb.remove((cast(lxb_dom_node_t*) (attr)));
    }

    if (element.attr_id == attr) {
        element.attr_id = null;
    }
    else if (element.attr_class == attr) {
        element.attr_class = null;
    }

    if (attr.prev != null) {
        attr.prev.next = attr.next;
    }
    else {
        element.first_attr = attr.next;
    }

    if (attr.next != null) {
        attr.next.prev = attr.prev;
    }
    else {
        element.last_attr = attr.prev;
    }

    attr.next = null;
    attr.prev = null;
    attr.owner = null;
}

lxb_dom_attr_data_t* lxb_dom_attr_local_name_append(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length)
{
    lxb_dom_attr_data_t* data = void;
    const(lexbor_shs_entry_t)* entry = void;

    if (name == null || length == 0) {
        return null;
    }

    entry = lexbor_shs_entry_get_lower_static(lxb_dom_attr_res_shs_data.ptr,
                                              name, length);
    if (entry != null) {
        return cast(lxb_dom_attr_data_t*) (entry.value);
    }

    data = cast(lxb_dom_attr_data_t*) lexbor_hash_insert(hash, lexbor_hash_insert_lower, name, length);
    if (data == null) {
        return null;
    }

    data.attr_id = cast(uintptr_t) data;

    return data;
}

lxb_dom_attr_data_t* lxb_dom_attr_qualified_name_append(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length)
{
    lxb_dom_attr_data_t* data = void;

    if (name == null || length == 0) {
        return null;
    }

    data = cast(lxb_dom_attr_data_t*) lexbor_hash_insert(hash, lexbor_hash_insert_raw, name, length);
    if (data == null) {
        return null;
    }

    data.attr_id = cast(uintptr_t) data;

    return data;
}

const(lxb_dom_attr_data_t)* lxb_dom_attr_data_undef()
{
    return &lxb_dom_attr_res_data_default[LXB_DOM_ATTR__UNDEF];
}

const(lxb_dom_attr_data_t)* lxb_dom_attr_data_by_id(lexbor_hash_t* hash, lxb_dom_attr_id_t attr_id)
{
    if (attr_id >= LXB_DOM_ATTR__LAST_ENTRY) {
        if (attr_id == LXB_DOM_ATTR__LAST_ENTRY) {
            return null;
        }

        return cast(const(lxb_dom_attr_data_t)*) attr_id;
    }

    return &lxb_dom_attr_res_data_default[attr_id];
}

const(lxb_dom_attr_data_t)* lxb_dom_attr_data_by_local_name(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length)
{
    const(lexbor_shs_entry_t)* entry = void;

    if (name == null || length == 0) {
        return null;
    }

    entry = lexbor_shs_entry_get_lower_static(lxb_dom_attr_res_shs_data.ptr,
                                              name, length);
    if (entry != null) {
        return cast(const(lxb_dom_attr_data_t)*) (entry.value);
    }

    return cast(const(lxb_dom_attr_data_t)*) lexbor_hash_search(hash, lexbor_hash_search_lower, name, length);
}

const(lxb_dom_attr_data_t)* lxb_dom_attr_data_by_qualified_name(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length)
{
    const(lexbor_shs_entry_t)* entry = void;

    if (name == null || length == 0) {
        return null;
    }

    entry = lexbor_shs_entry_get_static(lxb_dom_attr_res_shs_data.ptr,
                                        name, length);
    if (entry != null) {
        return cast(const(lxb_dom_attr_data_t)*) (entry.value);
    }

    return cast(const(lxb_dom_attr_data_t)*) lexbor_hash_search(hash, lexbor_hash_search_raw, name, length);
}

const(lxb_char_t)* lxb_dom_attr_qualified_name(lxb_dom_attr_t* attr, size_t* len)
{
    const(lxb_dom_attr_data_t)* data = void;

    if (attr.qualified_name != 0) {
        data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) attr.node.owner_document.attrs,
                                       attr.qualified_name);
    }
    else {
        data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) attr.node.owner_document.attrs,
                                       attr.node.local_name);
    }

    if (len != null) {
        *len = data.entry.length;
    }

    return lexbor_hash_entry_str(&data.entry);
}

/*
 * No inline functions for ABI.
 */
const(lxb_char_t)* lxb_dom_attr_local_name_noi(lxb_dom_attr_t* attr, size_t* len)
{
    return lxb_dom_attr_local_name(attr, len);
}

const(lxb_char_t)* lxb_dom_attr_value_noi(lxb_dom_attr_t* attr, size_t* len)
{
    return lxb_dom_attr_value(attr, len);
}
