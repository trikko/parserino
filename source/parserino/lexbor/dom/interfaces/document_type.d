module parserino.lexbor.dom.interfaces.document_type;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.str;
public import parserino.lexbor.dom.interfaces.document;
public import parserino.lexbor.dom.interfaces.node;
public import parserino.lexbor.dom.interfaces.attr;

extern(C) @nogc nothrow:
__gshared:

// ---- document_type.h ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_dom_document_type {
    lxb_dom_node_t node;

    lxb_dom_attr_id_t name;
    lexbor_str_t public_id;
    lexbor_str_t system_id;
}




/*
 * Create DocumentType by specification.
 *
 * https://dom.spec.whatwg.org/#dom-domimplementation-createdocumenttype
 *
 * @param[in] lxb_dom_document_t *. Not NULL.
 * @param[in] const lxb_char_t *. Name. May be NULL, but then the return value
 *            will be NULL and an exception code will be recorded.
 * @param[in] size_t. Length of name. May be 0, but then the return value
 *            will be NULL and an exception code will be recorded.
 * @param[in] const lxb_char_t *. PublicID. Can be NULL.
 * @param[in] size_t. Length of PublicID. Can be 0.
 * @param[in] const lxb_char_t *. SystemID. Can be NULL.
 * @param[in] size_t. Length of SystemID. Can be 0.
 * @param[out] lxb_dom_exception_code_t. Can be NULL. If the variable is passed,
 *             the code will definitely be assigned. LXB_DOM_EXCEPTION_OK
 *             if successful.
 *
 * @return lxb_dom_document_type_t * if successful, otherwise NULL.
 */

/*
 * Inline functions
 */
 const(lxb_char_t)* lxb_dom_document_type_name(const(lxb_dom_document_type_t)* doc_type, size_t* len)
{
    const(lxb_dom_attr_data_t)* data = void;

    static const(lxb_char_t)[1] lxb_empty = lexbor_carray!"";

    data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) doc_type.node.owner_document.attrs,
                                   doc_type.name);
    if (data == null || doc_type.name == LXB_DOM_ATTR__UNDEF) {
        if (len != null) {
            *len = 0;
        }

        return lxb_empty.ptr;
    }

    if (len != null) {
        *len = data.entry.length;
    }

    return lexbor_hash_entry_str(&data.entry);
}

 const(lxb_char_t)* lxb_dom_document_type_public_id(lxb_dom_document_type_t* doc_type, size_t* len)
{
    if (len != null) {
        *len = doc_type.public_id.length;
    }

    return doc_type.public_id.data;
}

 const(lxb_char_t)* lxb_dom_document_type_system_id(lxb_dom_document_type_t* doc_type, size_t* len)
{
    if (len != null) {
        *len = doc_type.system_id.length;
    }

    return doc_type.system_id.data;
}

/*
 * No inline functions for ABI.
 */



// ---- document_type.c ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

 lxb_dom_attr_data_t* lxb_dom_attr_qualified_name_append(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length);

 lxb_dom_attr_data_t* lxb_dom_attr_local_name_append(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length);

lxb_dom_document_type_t* lxb_dom_document_type_interface_create(lxb_dom_document_t* document)
{
    lxb_dom_document_type_t* element = void;

    element = cast(lxb_dom_document_type*) lexbor_mraw_calloc(document.mraw,
                                 lxb_dom_document_type_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_dom_document_owner(document);
    node.type = LXB_DOM_NODE_TYPE_DOCUMENT_TYPE;

    element.name = LXB_DOM_ATTR_HTML;

    return element;
}

lxb_dom_document_type_t* lxb_dom_document_type_interface_clone(lxb_dom_document_t* document, const(lxb_dom_document_type_t)* dtype)
{
    lxb_status_t status = void;
    lxb_dom_document_type_t* new_ = void;
    const(lxb_dom_attr_data_t)* data = void;

    new_ = lxb_dom_document_type_interface_create(document);
    if (new_ == null) {
        return null;
    }

    status = lxb_dom_node_interface_copy(&new_.node, &dtype.node, false);
    if (status != LXB_STATUS_OK) {
        return lxb_dom_document_type_interface_destroy(new_);
    }

    if (document == dtype.node.owner_document) {
        new_.name = dtype.name;
    }
    else {
        data = lxb_dom_attr_data_by_id(cast(lexbor_hash_t*) dtype.node.owner_document.attrs,
                                       dtype.name);
        if (data == null) {
            return lxb_dom_document_type_interface_destroy(new_);
        }

        data = lxb_dom_attr_qualified_name_append(document.attrs,
                                                  lexbor_hash_entry_str(&data.entry),
                                                  data.entry.length);
        if (data == null) {
            return lxb_dom_document_type_interface_destroy(new_);
        }

        new_.name = cast(lxb_dom_attr_id_t) data;
    }

    if (lexbor_str_copy(&new_.public_id,
                        &dtype.public_id, document.text) == null)
    {
        return lxb_dom_document_type_interface_destroy(new_);
    }

    if (lexbor_str_copy(&new_.system_id,
                        &dtype.system_id, document.text) == null)
    {
        return lxb_dom_document_type_interface_destroy(new_);
    }

    return new_;
}

lxb_dom_document_type_t* lxb_dom_document_type_interface_destroy(lxb_dom_document_type_t* document_type)
{
    lexbor_mraw_t* text = void;
    lexbor_str_t public_id = void;
    lexbor_str_t system_id = void;

    text = (cast(lxb_dom_node_t*) (document_type)).owner_document.text;
    public_id = document_type.public_id;
    system_id = document_type.system_id;

    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (document_type)));

    cast(void) lexbor_str_destroy(&public_id, text, false);
    cast(void) lexbor_str_destroy(&system_id, text, false);

    return null;
}

lxb_dom_document_type_t* lxb_dom_document_type_create(lxb_dom_document_t* document, const(lxb_char_t)* name, size_t name_len, const(lxb_char_t)* pub, size_t pub_len, const(lxb_char_t)* sys, size_t sys_len, lxb_dom_exception_code_t* code)
{
    lxb_dom_attr_data_t* data = void;
    lxb_dom_document_type_t* doctype = void;

    if (!lxb_dom_document_type_valid_name(name, name_len)) {
        if (code != null) {
            *code = LXB_DOM_EXCEPTION_INVALID_CHARACTER_ERR;
        }

        return null;
    }

    doctype = lxb_dom_document_type_interface_create(document);
    if (doctype == null) {
        goto failed;
    }

    data = lxb_dom_attr_local_name_append(document.attrs, name, name_len);
    if (data == null) {
        goto failed;
    }

    doctype.name = data.attr_id;

    if (pub != null && pub_len != 0) {
        doctype.public_id.data = lxb_dom_document_create_text(document,
                                                               pub_len + 1);
        if (doctype.public_id.data == null) {
            goto failed;
        }

        cast(void) lexbor_str_copy_to_with_null(&doctype.public_id, pub, pub_len);
    }

    if (sys != null && sys_len != 0) {
        doctype.system_id.data = lxb_dom_document_create_text(document,
                                                               sys_len + 1);
        if (doctype.system_id.data == null) {
            goto failed;
        }

        cast(void) lexbor_str_copy_to_with_null(&doctype.system_id, sys, sys_len);
    }

    if (code != null) {
        *code = LXB_DOM_EXCEPTION_OK;
    }

    return doctype;

failed:

    if (doctype != null && doctype.public_id.data != null) {
        lxb_dom_document_destroy_text(document, doctype.public_id.data);
    }

    if (code != null) {
        *code = LXB_DOM_EXCEPTION_ERR;
    }

    return null;
}

bool lxb_dom_document_type_valid_name(const(lxb_char_t)* name, size_t length)
{
    lxb_char_t c = void;
    const(lxb_char_t)* end = void;

    if (name == null || length == 0) {
        return false;
    }

    end = name + length;

    while (name < end) {
        c = *name++;
        /*
         * U+0009 TAB, U+000A LF, U+000C FF, U+000D CR, or U+0020 SPACE,
         * or U+0000 NULL, or U+003E (>)
         */
        if (c == 0x09 || c == 0x0A || c == 0x0C || c == 0x0D || c == 0x20
            || c == 0x00 || c == 0x3E)
        {
            return false;
        }
    }

    return true;
}

/*
 * No inline functions for ABI.
 */
const(lxb_char_t)* lxb_dom_document_type_name_noi(lxb_dom_document_type_t* doc_type, size_t* len)
{
    return lxb_dom_document_type_name(doc_type, len);
}

const(lxb_char_t)* lxb_dom_document_type_public_id_noi(lxb_dom_document_type_t* doc_type, size_t* len)
{
    return lxb_dom_document_type_public_id(doc_type, len);
}

const(lxb_char_t)* lxb_dom_document_type_system_id_noi(lxb_dom_document_type_t* doc_type, size_t* len)
{
    return lxb_dom_document_type_system_id(doc_type, len);
}
