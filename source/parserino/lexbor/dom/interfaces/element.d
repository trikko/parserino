module parserino.lexbor.dom.interfaces.element;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.str;
public import parserino.lexbor.core.avl;
public import parserino.lexbor.dom.interfaces.node;
public import parserino.lexbor.dom.collection;
public import parserino.lexbor.dom.interfaces.attr;
public import parserino.lexbor.tag.tag;
import parserino.lexbor.dom.interfaces.document;
import parserino.lexbor.ns.ns;
import parserino.lexbor.core.utils;
import parserino.lexbor.core.hash;

extern(C) @nogc nothrow:
__gshared:

// ---- element.h ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum lxb_dom_element_custom_state_t {
    LXB_DOM_ELEMENT_CUSTOM_STATE_UNDEFINED = 0x00,
    LXB_DOM_ELEMENT_CUSTOM_STATE_FAILED = 0x01,
    LXB_DOM_ELEMENT_CUSTOM_STATE_UNCUSTOMIZED = 0x02,
    LXB_DOM_ELEMENT_CUSTOM_STATE_CUSTOM = 0x03
}
alias LXB_DOM_ELEMENT_CUSTOM_STATE_UNDEFINED = lxb_dom_element_custom_state_t.LXB_DOM_ELEMENT_CUSTOM_STATE_UNDEFINED;
alias LXB_DOM_ELEMENT_CUSTOM_STATE_FAILED = lxb_dom_element_custom_state_t.LXB_DOM_ELEMENT_CUSTOM_STATE_FAILED;
alias LXB_DOM_ELEMENT_CUSTOM_STATE_UNCUSTOMIZED = lxb_dom_element_custom_state_t.LXB_DOM_ELEMENT_CUSTOM_STATE_UNCUSTOMIZED;
alias LXB_DOM_ELEMENT_CUSTOM_STATE_CUSTOM = lxb_dom_element_custom_state_t.LXB_DOM_ELEMENT_CUSTOM_STATE_CUSTOM;


/*
 * Element condition flags for lazy style cleanup.
 *
 * DIRTY_STYLE: set on an element (and all its descendants) when it is removed
 * from the DOM tree. Instead of immediately walking the style AVL tree and
 * freeing every stylesheet-originated declaration, we just mark the element
 * dirty and defer cleanup. When styles are later accessed or a new stylesheet
 * is applied, the dirty flag tells the code to discard stale stylesheet entries
 * lazily, keeping only inline style="..." declarations (sp_s == 1).
 */
enum lxb_dom_element_condition_t {
    LXB_DOM_ELEMENT_CONDITION_OK = 0x00,
    LXB_DOM_ELEMENT_CONDITION_DIRTY_STYLE = 1 << 0
}
alias LXB_DOM_ELEMENT_CONDITION_OK = lxb_dom_element_condition_t.LXB_DOM_ELEMENT_CONDITION_OK;
alias LXB_DOM_ELEMENT_CONDITION_DIRTY_STYLE = lxb_dom_element_condition_t.LXB_DOM_ELEMENT_CONDITION_DIRTY_STYLE;


alias lxb_dom_element_attr_change_f = lxb_status_t function(lxb_dom_element_t* element, lxb_dom_attr_id_t local_name, const(lxb_char_t)* old_value, size_t old_len, const(lxb_char_t)* value, size_t value_len, lxb_ns_id_t ns);

struct lxb_dom_element {
    lxb_dom_node_t node;

    /* For example: <LalAla:DiV Fix:Me="value"> */

    /* uppercase, with prefix: LALALA:DIV */
    lxb_dom_attr_id_t upper_name;

    /* original, with prefix: LalAla:DiV */
    lxb_dom_attr_id_t qualified_name;

    lexbor_str_t* is_value;

    lxb_dom_attr_t* first_attr;
    lxb_dom_attr_t* last_attr;

    lxb_dom_attr_t* attr_id;
    lxb_dom_attr_t* attr_class;

    lexbor_avl_node_t* style;
    void* list; /* lxb_css_rule_declaration_list_t */

    lxb_dom_element_condition_t condition;
    lxb_dom_element_custom_state_t custom_state;
}


















 lxb_dom_attr_t* lxb_dom_element_attr_by_data(lxb_dom_element_t* element, const(lxb_dom_attr_data_t)* data);
















/*
 * Inline functions
 */
 const(lxb_char_t)* lxb_dom_element_id(lxb_dom_element_t* element, size_t* len)
{
    if (element.attr_id == null) {
        if (len != null) {
            *len = 0;
        }

        return null;
    }

    return lxb_dom_attr_value(element.attr_id, len);
}

 const(lxb_char_t)* lxb_dom_element_class(lxb_dom_element_t* element, size_t* len)
{
    if (element.attr_class == null) {
        if (len != null) {
            *len = 0;
        }

        return null;
    }

    return lxb_dom_attr_value(element.attr_class, len);
}

 bool lxb_dom_element_is_custom(lxb_dom_element_t* element)
{
    return cast(bool) (element.custom_state & LXB_DOM_ELEMENT_CUSTOM_STATE_CUSTOM);
}

 bool lxb_dom_element_custom_is_defined(lxb_dom_element_t* element)
{
    return element.custom_state & LXB_DOM_ELEMENT_CUSTOM_STATE_CUSTOM
        || element.custom_state & LXB_DOM_ELEMENT_CUSTOM_STATE_UNCUSTOMIZED;
}

 lxb_dom_attr_t* lxb_dom_element_first_attribute(lxb_dom_element_t* element)
{
    return element.first_attr;
}

 lxb_dom_attr_t* lxb_dom_element_next_attribute(lxb_dom_attr_t* attr)
{
    return attr.next;
}

 lxb_dom_attr_t* lxb_dom_element_prev_attribute(lxb_dom_attr_t* attr)
{
    return attr.prev;
}

 lxb_dom_attr_t* lxb_dom_element_last_attribute(lxb_dom_element_t* element)
{
    return element.last_attr;
}

 lxb_dom_attr_t* lxb_dom_element_id_attribute(lxb_dom_element_t* element)
{
    return element.attr_id;
}

 lxb_dom_attr_t* lxb_dom_element_class_attribute(lxb_dom_element_t* element)
{
    return element.attr_class;
}

 lxb_tag_id_t lxb_dom_element_tag_id(lxb_dom_element_t* element)
{
    return (cast(lxb_dom_node_t*) (element)).local_name;
}

 lxb_ns_id_t lxb_dom_element_ns_id(lxb_dom_element_t* element)
{
    return (cast(lxb_dom_node_t*) (element)).ns;
}

 lxb_dom_document_t* lxb_dom_element_document(const(lxb_dom_element_t)* element)
{
    return (cast(lxb_dom_node_t*) (element)).owner_document;
}

/*
 * No inline functions for ABI.
 */










// ---- element.c ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */


const(lxb_tag_data_t)* lxb_tag_append(lexbor_hash_t* hash, lxb_tag_id_t tag_id, const(lxb_char_t)* name, size_t length);

const(lxb_tag_data_t)* lxb_tag_append_lower(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length);

const(lxb_ns_data_t)* lxb_ns_append(lexbor_hash_t* hash, const(lxb_char_t)* link, size_t length);

lxb_dom_element_t* lxb_dom_element_interface_create(lxb_dom_document_t* document)
{
    lxb_dom_element_t* element = void;

    element = cast(lxb_dom_element*) lexbor_mraw_calloc(document.mraw,
                                 lxb_dom_element_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_dom_document_owner(document);
    node.type = LXB_DOM_NODE_TYPE_ELEMENT;

    return element;
}

lxb_dom_element_t* lxb_dom_element_interface_clone(lxb_dom_document_t* document, const(lxb_dom_element_t)* element)
{
    lxb_dom_element_t* new_ = void;

    new_ = lxb_dom_element_interface_create(document);
    if (new_ == null) {
        return null;
    }

    if (lxb_dom_element_interface_copy(new_, element) != LXB_STATUS_OK) {
        return lxb_dom_element_interface_destroy(new_);
    }

    return new_;
}

lxb_dom_element_t* lxb_dom_element_interface_destroy(lxb_dom_element_t* element)
{
    lxb_dom_attr_t* attr_next = void;
    lxb_dom_attr_t* attr = element.first_attr;

    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (element)));

    while (attr != null) {
        attr_next = attr.next;

        lxb_dom_attr_interface_destroy(attr);

        attr = attr_next;
    }

    return null;
}

lxb_status_t lxb_dom_element_interface_copy(lxb_dom_element_t* dst, const(lxb_dom_element_t)* src)
{
    lxb_status_t status = void;
    lxb_dom_document_t* document = void;
    lxb_dom_attr_t* attr = void, clone = void;

    status = lxb_dom_node_interface_copy(&dst.node, &src.node, false);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    document = (cast(lxb_dom_node_t*) (dst)).owner_document;
    attr = cast(lxb_dom_attr*) src.first_attr;

    while (attr != null) {
        clone = lxb_dom_attr_interface_clone(document, attr);
        if (clone == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        cast(void) lxb_dom_element_attr_append(dst, clone);

        attr = attr.next;
    }

    return LXB_STATUS_OK;
}

 lxb_status_t lxb_dom_element_qualified_name_set(lxb_dom_element_t* element, const(lxb_char_t)* prefix, size_t prefix_len, const(lxb_char_t)* lname, size_t lname_len)
{
    lxb_char_t* key = cast(lxb_char_t*) lname;
    const(lxb_tag_data_t)* tag_data = void;

    if (prefix != null && prefix_len != 0) {
        key = cast(ubyte*) lexbor_malloc(prefix_len + lname_len + 2);
        if (key == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        memcpy(key, prefix, prefix_len);
        memcpy(&key[prefix_len + 1], lname, lname_len);

        lname_len = prefix_len + lname_len + 1;

        key[prefix_len] = ':';
        key[lname_len] = '\0';
    }

    tag_data = lxb_tag_append(element.node.owner_document.tags,
                              element.node.local_name, key, lname_len);

    if (key != lname) {
        lexbor_free(key);
    }

    if (tag_data == null) {
        return LXB_STATUS_ERROR;
    }

    element.qualified_name = cast(lxb_tag_id_t) tag_data;

    return LXB_STATUS_OK;
}

lxb_dom_element_t* lxb_dom_element_create(lxb_dom_document_t* document, const(lxb_char_t)* local_name, size_t lname_len, const(lxb_char_t)* ns_link, size_t ns_len, const(lxb_char_t)* prefix, size_t prefix_len, const(lxb_char_t)* is_, size_t is_len, bool sync_custom)
{
    lxb_status_t status = void;
    const(lxb_ns_data_t)* ns_data = void;
    const(lxb_tag_data_t)* tag_data = void;
    const(lxb_ns_prefix_data_t)* ns_prefix = void;
    lxb_dom_element_t* element = void;

    /* TODO: Must implement custom elements */

    /* 7. Otherwise */

    ns_data = null;
    tag_data = null;
    ns_prefix = null;

    tag_data = lxb_tag_append_lower(document.tags, local_name, lname_len);
    if (tag_data == null) {
        return null;
    }

    if (ns_link != null) {
        ns_data = lxb_ns_append(document.ns, ns_link, ns_len);
    }
    else {
        ns_data = lxb_ns_data_by_id(document.ns, LXB_NS__UNDEF);
    }

    if (ns_data == null) {
        return null;
    }

    element = cast(lxb_dom_element*) lxb_dom_document_create_interface(document, tag_data.tag_id,
                                                ns_data.ns_id);
    if (element == null) {
        return null;
    }

    if (prefix != null) {
        ns_prefix = lxb_ns_prefix_append(document.prefix, prefix, prefix_len);
        if (ns_prefix == null) {
            return cast(typeof(return)) lxb_dom_document_destroy_interface(element);
        }

        element.node.prefix = ns_prefix.prefix_id;

        status = lxb_dom_element_qualified_name_set(element, prefix, prefix_len,
                                                    local_name, lname_len);
        if (status != LXB_STATUS_OK) {
            return cast(typeof(return)) lxb_dom_document_destroy_interface(element);
        }
    }

    if (is_len != 0) {
        status = lxb_dom_element_is_set(element, is_, is_len);
        if (status != LXB_STATUS_OK) {
            return cast(typeof(return)) lxb_dom_document_destroy_interface(element);
        }
    }

    element.node.local_name = tag_data.tag_id;
    element.node.ns = ns_data.ns_id;

    if (ns_data.ns_id == LXB_NS_HTML && is_len != 0) {
        element.custom_state = LXB_DOM_ELEMENT_CUSTOM_STATE_UNDEFINED;
    }
    else {
        element.custom_state = LXB_DOM_ELEMENT_CUSTOM_STATE_UNCUSTOMIZED;
    }

    return element;
}

lxb_dom_element_t* lxb_dom_element_destroy(lxb_dom_element_t* element)
{
    return cast(typeof(return)) lxb_dom_document_destroy_interface(element);
}

bool lxb_dom_element_has_attributes(lxb_dom_element_t* element)
{
    return element.first_attr != null;
}

lxb_dom_attr_t* lxb_dom_element_set_attribute(lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len, const(lxb_char_t)* value, size_t value_len)
{
    lxb_status_t status = void;
    lxb_dom_attr_t* attr = void;

    attr = lxb_dom_element_attr_is_exist(element, qualified_name, qn_len);

    if (attr != null) {
        status = lxb_dom_attr_set_value(attr, value, value_len);
        if (status != LXB_STATUS_OK) {
            return lxb_dom_attr_interface_destroy(attr);
        }

        return attr;
    }

    attr = lxb_dom_attr_interface_create(element.node.owner_document);
    if (attr == null) {
        return null;
    }

    attr.node.ns = element.node.ns;

    if (element.node.ns == LXB_NS_HTML
        && element.node.owner_document.type == LXB_DOM_DOCUMENT_DTYPE_HTML)
    {
        status = lxb_dom_attr_set_name(attr, qualified_name, qn_len, true);
    }
    else {
        status = lxb_dom_attr_set_name(attr, qualified_name, qn_len, false);
    }

    if (status != LXB_STATUS_OK) {
        return lxb_dom_attr_interface_destroy(attr);
    }

    status = lxb_dom_attr_set_value(attr, value, value_len);
    if (status != LXB_STATUS_OK) {
        return lxb_dom_attr_interface_destroy(attr);
    }

    status = lxb_dom_element_attr_append(element, attr);
    if (status != LXB_STATUS_OK) {
        return lxb_dom_attr_interface_destroy(attr);
    }

    return attr;
}

const(lxb_char_t)* lxb_dom_element_get_attribute(lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len, size_t* value_len)
{
    lxb_dom_attr_t* attr = void;

    attr = lxb_dom_element_attr_by_name(element, qualified_name, qn_len);
    if (attr == null) {
        if (value_len != null) {
            *value_len = 0;
        }

        return null;
    }

    return lxb_dom_attr_value(attr, value_len);
}

lxb_status_t lxb_dom_element_remove_attribute(lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len)
{
    lxb_status_t status = void;
    lxb_dom_attr_t* attr = void;

    attr = lxb_dom_element_attr_by_name(element, qualified_name, qn_len);
    if (attr == null) {
        return LXB_STATUS_OK;
    }

    status = lxb_dom_element_attr_remove(element, attr);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    lxb_dom_attr_interface_destroy(attr);

    return LXB_STATUS_OK;
}

bool lxb_dom_element_has_attribute(lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len)
{
    return lxb_dom_element_attr_by_name(element, qualified_name, qn_len) != null;
}

lxb_status_t lxb_dom_element_attr_append(lxb_dom_element_t* element, lxb_dom_attr_t* attr)
{
    size_t value_len = void;
    const(lxb_char_t)* value = void;
    lxb_dom_attr_t* exist = void;
    lxb_dom_document_t* doc = (cast(lxb_dom_node_t*) (element)).owner_document;

    if (attr.node.local_name == LXB_DOM_ATTR_ID) {
        exist = element.attr_id;

        if (exist != null) {
            lxb_dom_element_attr_remove(element, exist);
            lxb_dom_attr_interface_destroy(exist);
        }

        element.attr_id = attr;
    }
    else if (attr.node.local_name == LXB_DOM_ATTR_CLASS) {
        exist = element.attr_class;

        if (exist != null) {
            lxb_dom_element_attr_remove(element, exist);
            lxb_dom_attr_interface_destroy(exist);
        }

        element.attr_class = attr;
    }

    if (element.first_attr == null) {
        element.first_attr = attr;
        element.last_attr = attr;

        goto done;
    }

    attr.prev = element.last_attr;

    element.last_attr.next = attr;
    element.last_attr = attr;

done:

    attr.owner = element;

    if (!(lxb_dom_document_opt(doc) & LXB_DOM_DOCUMENT_OPT_WO_EVENTS)
        && doc.attr_mutation.append != null)
    {
        value = null;
        value_len = 0;

        if (attr.value != null && attr.value.data != null) {
            value = attr.value.data;
            value_len = attr.value.length;
        }

        return doc.attr_mutation.append(element, attr.node.local_name,
                                          null, 0, value, value_len,
                                          LXB_NS__UNDEF);
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_dom_element_attr_remove(lxb_dom_element_t* element, lxb_dom_attr_t* attr)
{
    cast(void) element;

    lxb_dom_attr_remove(attr);

    return LXB_STATUS_OK;
}

lxb_dom_attr_t* lxb_dom_element_attr_by_name(lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t length)
{
    const(lxb_dom_attr_data_t)* data = void;
    lexbor_hash_t* attrs = element.node.owner_document.attrs;
    lxb_dom_attr_t* attr = element.first_attr;

    if (element.node.ns == LXB_NS_HTML
        && element.node.owner_document.type == LXB_DOM_DOCUMENT_DTYPE_HTML)
    {
        data = lxb_dom_attr_data_by_local_name(attrs, qualified_name, length);
    }
    else {
        data = lxb_dom_attr_data_by_qualified_name(attrs, qualified_name,
                                                   length);
    }

    if (data == null) {
        return null;
    }

    while (attr != null) {
        if (attr.node.local_name == data.attr_id
            || attr.qualified_name == data.attr_id)
        {
            return attr;
        }

        attr = attr.next;
    }

    return null;
}

lxb_dom_attr_t* lxb_dom_element_attr_by_local_name_data(lxb_dom_element_t* element, const(lxb_dom_attr_data_t)* data)
{
    lxb_dom_attr_t* attr = element.first_attr;

    while (attr != null) {
        if (attr.node.local_name == data.attr_id
            || attr.qualified_name == data.attr_id)
        {
            return attr;
        }

        attr = attr.next;
    }

    return null;
}

lxb_dom_attr_t* lxb_dom_element_attr_by_local_name_ns_data(lxb_dom_element_t* element, const(lxb_dom_attr_data_t)* data, lxb_ns_id_t ns)
{
    lxb_dom_attr_t* attr = element.first_attr;

    while (attr != null) {
        if ((attr.node.local_name == data.attr_id
             && attr.node.ns == ns)
            || attr.qualified_name == data.attr_id)
        {
            return attr;
        }

        attr = attr.next;
    }

    return null;
}

lxb_dom_attr_t* lxb_dom_element_attr_by_id(lxb_dom_element_t* element, lxb_dom_attr_id_t attr_id)
{
    lxb_dom_attr_t* attr = element.first_attr;

    while (attr != null) {
        if (attr.node.local_name == attr_id) {
            return attr;
        }

        attr = attr.next;
    }

    return null;
}

bool lxb_dom_element_compare(lxb_dom_element_t* first, lxb_dom_element_t* second)
{
    lxb_dom_attr_t* f_attr = first.first_attr;
    lxb_dom_attr_t* s_attr = second.first_attr;

    if (first.node.local_name != second.node.local_name
        || first.node.ns != second.node.ns
        || first.qualified_name != second.qualified_name)
    {
        return false;
    }

    /* Compare attr counts */
    while (f_attr != null && s_attr != null) {
        f_attr = f_attr.next;
        s_attr = s_attr.next;
    }

    if (f_attr != null || s_attr != null) {
        return false;
    }

    /* Compare attr */
    f_attr = first.first_attr;

    while (f_attr != null) {
        s_attr = second.first_attr;

        while (s_attr != null) {
            if (lxb_dom_attr_compare(f_attr, s_attr)) {
                break;
            }

            s_attr = s_attr.next;
        }

        if (s_attr == null) {
            return false;
        }

        f_attr = f_attr.next;
    }

    return true;
}

lxb_dom_attr_t* lxb_dom_element_attr_is_exist(const(lxb_dom_element_t)* element, const(lxb_char_t)* qualified_name, size_t length)
{
    const(lxb_dom_attr_data_t)* data = void;
    lxb_dom_attr_t* attr = cast(lxb_dom_attr*) element.first_attr;

    data = lxb_dom_attr_data_by_local_name(cast(lexbor_hash_t*) element.node.owner_document.attrs,
                                           qualified_name, length);
    if (data == null) {
        return null;
    }

    while (attr != null) {
        if (attr.node.local_name == data.attr_id
            || attr.qualified_name == data.attr_id)
        {
            return attr;
        }

        attr = attr.next;
    }

    return null;
}

lxb_status_t lxb_dom_element_is_set(lxb_dom_element_t* element, const(lxb_char_t)* is_, size_t is_len)
{
    if (element.is_value == null) {
        element.is_value = cast(lexbor_str_t*) lexbor_mraw_calloc(element.node.owner_document.mraw,
                                               lexbor_str_t.sizeof);
        if (element.is_value == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    if (element.is_value.data == null) {
        lexbor_str_init(element.is_value,
                        element.node.owner_document.text, is_len);

        if (element.is_value.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    if (element.is_value.length != 0) {
        element.is_value.length = 0;
    }

    lxb_char_t* data = lexbor_str_append(element.is_value,
                                         element.node.owner_document.text,
                                         is_, is_len);
    if (data == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    return LXB_STATUS_OK;
}

lxb_dom_element_t* lxb_dom_element_by_id(lxb_dom_element_t* root, const(lxb_char_t)* qualified_name, size_t len)
{
    lxb_dom_node_t* node = void;

    node = lxb_dom_node_by_id((cast(lxb_dom_node_t*) (root)),
                              qualified_name, len);

    return (cast(lxb_dom_element_t*) (node));
}

lxb_status_t lxb_dom_elements_by_tag_name(lxb_dom_element_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* qname, size_t len)
{
    return lxb_dom_node_by_tag_name((cast(lxb_dom_node_t*) (root)),
                                    collection, qname, len);
}

lxb_status_t lxb_dom_elements_by_class_name(lxb_dom_element_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* class_name, size_t len)
{
    return lxb_dom_node_by_class_name((cast(lxb_dom_node_t*) (root)),
                                      collection, class_name, len);
}

lxb_status_t lxb_dom_elements_by_attr(lxb_dom_element_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* qname, size_t qname_len, const(lxb_char_t)* value, size_t value_len, bool case_insensitive)
{
    return lxb_dom_node_by_attr((cast(lxb_dom_node_t*) (root)),
                                collection, qname, qname_len,
                                value, value_len, case_insensitive);
}

lxb_status_t lxb_dom_elements_by_attr_begin(lxb_dom_element_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* qname, size_t qname_len, const(lxb_char_t)* value, size_t value_len, bool case_insensitive)
{
    return lxb_dom_node_by_attr_begin((cast(lxb_dom_node_t*) (root)),
                                      collection, qname, qname_len,
                                      value, value_len, case_insensitive);
}

lxb_status_t lxb_dom_elements_by_attr_end(lxb_dom_element_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* qname, size_t qname_len, const(lxb_char_t)* value, size_t value_len, bool case_insensitive)
{
    return lxb_dom_node_by_attr_end((cast(lxb_dom_node_t*) (root)),
                                    collection, qname, qname_len,
                                    value, value_len, case_insensitive);
}

lxb_status_t lxb_dom_elements_by_attr_contain(lxb_dom_element_t* root, lxb_dom_collection_t* collection, const(lxb_char_t)* qname, size_t qname_len, const(lxb_char_t)* value, size_t value_len, bool case_insensitive)
{
    return lxb_dom_node_by_attr_contain((cast(lxb_dom_node_t*) (root)),
                                        collection, qname, qname_len,
                                        value, value_len, case_insensitive);
}

const(lxb_char_t)* lxb_dom_element_qualified_name(const(lxb_dom_element_t)* element, size_t* len)
{
    const(lxb_tag_data_t)* data = void;

    if (element.qualified_name != 0) {
        data = lxb_tag_data_by_id(element.qualified_name);
    }
    else {
        data = lxb_tag_data_by_id(element.node.local_name);
    }

    if (len != null) {
        *len = data.entry.length;
    }

    return lexbor_hash_entry_str(&data.entry);
}

const(lxb_char_t)* lxb_dom_element_qualified_name_upper(lxb_dom_element_t* element, size_t* len)
{
    lxb_tag_data_t* data = void;

    if (element.upper_name == LXB_TAG__UNDEF) {
        return lxb_dom_element_upper_update(element, len);
    }

    data = cast(lxb_tag_data_t*) element.upper_name;

    if (len != null) {
        *len = data.entry.length;
    }

    return lexbor_hash_entry_str(&data.entry);
}

private const(lxb_char_t)* lxb_dom_element_upper_update(lxb_dom_element_t* element, size_t* len)
{
    size_t length = void;
    lxb_tag_data_t* data = void;
    const(lxb_char_t)* name = void;

    if (element.upper_name != LXB_TAG__UNDEF) {
        /* TODO: release current tag data if ref_count == 0. */
        /* data = (lxb_tag_data_t *) element->upper_name; */
    }

    name = lxb_dom_element_qualified_name(element, &length);
    if (name == null) {
        return null;
    }

    data = cast(lxb_tag_data_t*) lexbor_hash_insert(element.node.owner_document.tags,
                              lexbor_hash_insert_upper, name, length);
    if (data == null) {
        return null;
    }

    data.tag_id = element.node.local_name;

    if (len != null) {
        *len = length;
    }

    element.upper_name = cast(lxb_tag_id_t) data;

    return lexbor_hash_entry_str(&data.entry);
}

const(lxb_char_t)* lxb_dom_element_local_name(lxb_dom_element_t* element, size_t* len)
{
    const(lxb_tag_data_t)* data = void;

    data = lxb_tag_data_by_id(element.node.local_name);
    if (data == null) {
        if (len != null) {
            *len = 0;
        }

        return null;
    }

    if (len != null) {
        *len = data.entry.length;
    }

    return lexbor_hash_entry_str(&data.entry);
}

const(lxb_char_t)* lxb_dom_element_prefix(lxb_dom_element_t* element, size_t* len)
{
    const(lxb_ns_prefix_data_t)* data = void;

    if (element.node.prefix == LXB_NS__UNDEF) {
        goto empty;
    }

    data = lxb_ns_prefix_data_by_id(element.node.owner_document.tags,
                                    element.node.prefix);
    if (data == null) {
        goto empty;
    }

    return lexbor_hash_entry_str(&data.entry);

empty:

    if (len != null) {
        *len = 0;
    }

    return null;
}

const(lxb_char_t)* lxb_dom_element_tag_name(lxb_dom_element_t* element, size_t* len)
{
    lxb_dom_document_t* doc = (cast(lxb_dom_node_t*) (element)).owner_document;

    if (element.node.ns != LXB_NS_HTML
        || doc.type != LXB_DOM_DOCUMENT_DTYPE_HTML)
    {
        return lxb_dom_element_qualified_name(element, len);
    }

    return lxb_dom_element_qualified_name_upper(element, len);
}

/*
 * No inline functions for ABI.
 */
const(lxb_char_t)* lxb_dom_element_id_noi(lxb_dom_element_t* element, size_t* len)
{
    return lxb_dom_element_id(element, len);
}

const(lxb_char_t)* lxb_dom_element_class_noi(lxb_dom_element_t* element, size_t* len)
{
    return lxb_dom_element_class(element, len);
}

bool lxb_dom_element_is_custom_noi(lxb_dom_element_t* element)
{
    return lxb_dom_element_is_custom(element);
}

bool lxb_dom_element_custom_is_defined_noi(lxb_dom_element_t* element)
{
    return lxb_dom_element_custom_is_defined(element);
}

lxb_dom_attr_t* lxb_dom_element_first_attribute_noi(lxb_dom_element_t* element)
{
    return lxb_dom_element_first_attribute(element);
}

lxb_dom_attr_t* lxb_dom_element_next_attribute_noi(lxb_dom_attr_t* attr)
{
    return lxb_dom_element_next_attribute(attr);
}

lxb_dom_attr_t* lxb_dom_element_prev_attribute_noi(lxb_dom_attr_t* attr)
{
    return lxb_dom_element_prev_attribute(attr);
}

lxb_dom_attr_t* lxb_dom_element_last_attribute_noi(lxb_dom_element_t* element)
{
    return lxb_dom_element_last_attribute(element);
}

lxb_dom_attr_t* lxb_dom_element_id_attribute_noi(lxb_dom_element_t* element)
{
    return lxb_dom_element_id_attribute(element);
}

lxb_dom_attr_t* lxb_dom_element_class_attribute_noi(lxb_dom_element_t* element)
{
    return lxb_dom_element_class_attribute(element);
}
