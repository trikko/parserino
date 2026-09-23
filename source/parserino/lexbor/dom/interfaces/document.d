module parserino.lexbor.dom.interfaces.document;

import parserino.lexbor.dom.interfaces.document_type;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.mraw;
public import parserino.lexbor.core.hash;
public import parserino.lexbor.dom.interface_;
public import parserino.lexbor.dom.interfaces.node;
public import parserino.lexbor.dom.interfaces.element;
import parserino.lexbor.dom.interfaces.text;
import parserino.lexbor.dom.interfaces.document_fragment;
import parserino.lexbor.dom.interfaces.comment;
import parserino.lexbor.dom.interfaces.cdata_section;
import parserino.lexbor.dom.interfaces.processing_instruction;

extern(C) @nogc nothrow:
__gshared:

// ---- document.h ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum lxb_dom_document_cmode_t {
    LXB_DOM_DOCUMENT_CMODE_NO_QUIRKS = 0x00,
    LXB_DOM_DOCUMENT_CMODE_QUIRKS = 0x01,
    LXB_DOM_DOCUMENT_CMODE_LIMITED_QUIRKS = 0x02
}
alias LXB_DOM_DOCUMENT_CMODE_NO_QUIRKS = lxb_dom_document_cmode_t.LXB_DOM_DOCUMENT_CMODE_NO_QUIRKS;
alias LXB_DOM_DOCUMENT_CMODE_QUIRKS = lxb_dom_document_cmode_t.LXB_DOM_DOCUMENT_CMODE_QUIRKS;
alias LXB_DOM_DOCUMENT_CMODE_LIMITED_QUIRKS = lxb_dom_document_cmode_t.LXB_DOM_DOCUMENT_CMODE_LIMITED_QUIRKS;


enum lxb_dom_document_dtype_t {
    LXB_DOM_DOCUMENT_DTYPE_UNDEF = 0x00,
    LXB_DOM_DOCUMENT_DTYPE_HTML = 0x01,
    LXB_DOM_DOCUMENT_DTYPE_XML = 0x02
}
alias LXB_DOM_DOCUMENT_DTYPE_UNDEF = lxb_dom_document_dtype_t.LXB_DOM_DOCUMENT_DTYPE_UNDEF;
alias LXB_DOM_DOCUMENT_DTYPE_HTML = lxb_dom_document_dtype_t.LXB_DOM_DOCUMENT_DTYPE_HTML;
alias LXB_DOM_DOCUMENT_DTYPE_XML = lxb_dom_document_dtype_t.LXB_DOM_DOCUMENT_DTYPE_XML;


alias lxb_dom_document_opt_t = uint;

enum lxb_dom_document_opt_ {
    LXB_DOM_DOCUMENT_OPT_UNDEF = 0x00,
    LXB_DOM_DOCUMENT_OPT_WO_EVENTS = 1 << 0
}
alias LXB_DOM_DOCUMENT_OPT_UNDEF = lxb_dom_document_opt_.LXB_DOM_DOCUMENT_OPT_UNDEF;
alias LXB_DOM_DOCUMENT_OPT_WO_EVENTS = lxb_dom_document_opt_.LXB_DOM_DOCUMENT_OPT_WO_EVENTS;


struct lxb_dom_document_css; // D port: opaque
alias lxb_dom_document_css_t = lxb_dom_document_css;

/* 4.2.3. Mutation algorithms. */
struct lxb_dom_document_mutation_cb_t {
    lxb_dom_node_cb_insertion_f inserted;
    lxb_dom_node_cb_removing_f removed;
    lxb_dom_node_cb_moving_f moved;
    lxb_dom_node_cb_destroy_f destroy;
    lxb_dom_node_cb_children_changed_f children_changed;
    lxb_dom_node_cb_post_connection_f connected;
}

struct lxb_dom_document_attr_mutation_cb_t {
    lxb_dom_element_attr_change_f change;
    lxb_dom_element_attr_change_f append;
    lxb_dom_element_attr_change_f remove;
    lxb_dom_element_attr_change_f replace;
}

struct lxb_dom_document {
    lxb_dom_node_t node;

    lxb_dom_document_cmode_t compat_mode;
    lxb_dom_document_dtype_t type;

    lxb_dom_document_type_t* doctype;
    lxb_dom_element_t* element;

    lxb_dom_interface_create_f create_interface;
    lxb_dom_interface_clone_f clone_interface;
    lxb_dom_interface_destroy_f destroy_interface;

    const(lxb_dom_document_mutation_cb_t)* mutation;
    const(lxb_dom_document_attr_mutation_cb_t)* attr_mutation;

    lexbor_mraw_t* mraw;
    lexbor_mraw_t* text;
    lexbor_hash_t* tags;
    lexbor_hash_t* attrs;
    lexbor_hash_t* prefix;
    lexbor_hash_t* ns;
    void* parser;
    void* user;

    lxb_dom_document_css_t* css;

    lxb_dom_document_opt_t options;

    bool tags_inherited;
    bool ns_inherited;

    bool scripting;
}




/*
 * Creating a document.
 *
 * The function creates and returns a zeroed document.
 * If another document is passed as an argument, its memory pool will be used
 * to conscious the new one.
 *
 * @param[in] lxb_dom_document_t *. Owner document, can be NULL.
 *
 * @return lxb_dom_document_t *. if successful, otherwise returns a NULL value.
 */

/*
 * Document Initialization.
 *
 * The function expects the document to be zeroed.
 *
 * @param[in] lxb_dom_document_t *. If NULL, LXB_STATUS_ERROR_OBJECT_IS_NULL is returned.
 * @param[in] lxb_dom_document_t *. Owner document, can be NULL.
 * @param[in] lxb_dom_interface_create_f. Required. Callback for creating interfaces.
 * @param[in] lxb_dom_interface_clone_f. Required. Callback for cloning interfaces.
 * @param[in] lxb_dom_interface_destroy_f. Required. Callback for destroying interfaces.
 * @param[in] lxb_dom_document_dtype_t. Document Type. Currently HTML or XML.
 * @param[in] unsigned int. Document Namespace. See lexbor/ns.
 *
 * @return LXB_STATUS_OK if successful, otherwise an error status value.
 */

















/*
 * Inline functions
 */
 lxb_dom_interface_t* lxb_dom_document_create_interface(lxb_dom_document_t* document, lxb_tag_id_t tag_id, lxb_ns_id_t ns)
{
    return document.create_interface(document, tag_id, ns);
}

 lxb_dom_interface_t* lxb_dom_document_destroy_interface(lxb_dom_interface_t* intrfc)
{
    return (cast(lxb_dom_node_t*) (intrfc)).owner_document.destroy_interface(intrfc);
}

 void* lxb_dom_document_create_struct(lxb_dom_document_t* document, size_t struct_size)
{
    return lexbor_mraw_calloc(document.mraw, struct_size);
}

 void* lxb_dom_document_destroy_struct(lxb_dom_document_t* document, void* structure)
{
    return lexbor_mraw_free(document.mraw, structure);
}

 lxb_char_t* lxb_dom_document_create_text(lxb_dom_document_t* document, size_t len)
{
    return cast(lxb_char_t*) lexbor_mraw_alloc(document.text,
                                            lxb_char_t.sizeof * len);
}

 void* lxb_dom_document_destroy_text(lxb_dom_document_t* document, lxb_char_t* text)
{
    return lexbor_mraw_free(document.text, text);
}

 lxb_dom_element_t* lxb_dom_document_element(lxb_dom_document_t* document)
{
    return document.element;
}

 bool lxb_dom_document_scripting(lxb_dom_document_t* document)
{
    return document.scripting;
}

 void lxb_dom_document_scripting_set(lxb_dom_document_t* document, bool scripting)
{
    document.scripting = scripting;
}

 lxb_dom_document_t* lxb_dom_document_owner(lxb_dom_document_t* document)
{
    return (cast(lxb_dom_node_t*) (document)).owner_document;
}

 bool lxb_dom_document_is_original(lxb_dom_document_t* document)
{
    return (cast(lxb_dom_node_t*) (document)).owner_document == document;
}

 void lxb_dom_document_opt_set(lxb_dom_document_t* document, lxb_dom_document_opt_t opt)
{
    document.options = opt;
}

 lxb_dom_document_opt_t lxb_dom_document_opt(lxb_dom_document_t* document)
{
    return document.options;
}

/*
 * No inline functions for ABI.
 */











// ---- document.c ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
private const(lxb_dom_document_mutation_cb_t) lxb_dom_document_mutation_cbs = {
    inserted: null, removed: null, moved: null,destroy: null,
    children_changed: null, connected: null
};

private const(lxb_dom_document_attr_mutation_cb_t) lxb_dom_document_attr_mutation_cbs = {
    change: null,
    append: null,
    remove: null,
    replace: null
};

lxb_dom_document_t* lxb_dom_document_interface_create(lxb_dom_document_t* document)
{
    lxb_dom_document_t* doc = void;

    doc = cast(lxb_dom_document*) lexbor_mraw_calloc(document.mraw, lxb_dom_document_t.sizeof);
    if (doc == null) {
        return null;
    }

    cast(void) lxb_dom_document_init(doc, document, &lxb_dom_interface_create,
                                 &lxb_dom_interface_clone, &lxb_dom_interface_destroy,
                                 LXB_DOM_DOCUMENT_DTYPE_UNDEF, 0);

    return doc;
}

lxb_dom_document_t* lxb_dom_document_interface_clone(lxb_dom_document_t* document, const(lxb_dom_document_t)* doc)
{
    lxb_dom_document_t* new_ = void;

    new_ = lxb_dom_document_interface_create(document);
    if (new_ == null) {
        return null;
    }

    new_.doctype = cast(lxb_dom_document_type*) doc.doctype;
    new_.compat_mode = doc.compat_mode;
    new_.type = doc.type;
    new_.user = cast(void*) doc.user;

    return new_;
}

lxb_dom_document_t* lxb_dom_document_interface_destroy(lxb_dom_document_t* document)
{
    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (document)));

    return null;
}

lxb_dom_document_t* lxb_dom_document_create(lxb_dom_document_t* owner)
{
    if (owner != null) {
        return cast(lxb_dom_document*) lexbor_mraw_calloc(owner.mraw, lxb_dom_document_t.sizeof);
    }

    return cast(lxb_dom_document*) lexbor_calloc(1, lxb_dom_document_t.sizeof);
}

lxb_status_t lxb_dom_document_init(lxb_dom_document_t* document, lxb_dom_document_t* owner, lxb_dom_interface_create_f create_interface, lxb_dom_interface_clone_f clone_interface, lxb_dom_interface_destroy_f destroy_interface, lxb_dom_document_dtype_t type, uint ns)
{
    lxb_status_t status = void;
    lxb_dom_node_t* node = void;

    if (document == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    document.type = type;
    document.create_interface = create_interface;
    document.clone_interface = clone_interface;
    document.destroy_interface = destroy_interface;

    node = (cast(lxb_dom_node_t*) (document));

    node.type = LXB_DOM_NODE_TYPE_DOCUMENT;
    node.local_name = LXB_TAG__DOCUMENT;
    node.ns = ns;

    if (owner != null) {
        document.mraw = owner.mraw;
        document.text = owner.text;
        document.tags = owner.tags;
        document.ns = owner.ns;
        document.prefix = owner.prefix;
        document.attrs = owner.attrs;
        document.parser = owner.parser;
        document.user = owner.user;
        document.scripting = owner.scripting;
        document.compat_mode = owner.compat_mode;
        document.css = owner.css;
        document.mutation = owner.mutation;
        document.attr_mutation = owner.attr_mutation;
        document.options = owner.options;

        document.tags_inherited = true;
        document.ns_inherited = true;

        node.owner_document = owner;

        return LXB_STATUS_OK;
    }

    document.css = null;
    document.mutation = &lxb_dom_document_mutation_cbs;
    document.attr_mutation = &lxb_dom_document_attr_mutation_cbs;
    document.options = LXB_DOM_DOCUMENT_OPT_UNDEF;

    /* For nodes */
    document.mraw = lexbor_mraw_create();
    status = lexbor_mraw_init(document.mraw, (4096 * 8));

    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    /* For text */
    document.text = lexbor_mraw_create();
    status = lexbor_mraw_init(document.text, (4096 * 12));

    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    document.tags = lexbor_hash_create();
    status = lexbor_hash_init(document.tags, 128, lxb_tag_data_t.sizeof);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    document.ns = lexbor_hash_create();
    status = lexbor_hash_init(document.ns, 128, lxb_ns_data_t.sizeof);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    document.prefix = lexbor_hash_create();
    status = lexbor_hash_init(document.prefix, 128,
                              lxb_dom_attr_data_t.sizeof);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    document.attrs = lexbor_hash_create();
    status = lexbor_hash_init(document.attrs, 128,
                              lxb_dom_attr_data_t.sizeof);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    node.owner_document = document;

    return LXB_STATUS_OK;

failed:

    lexbor_mraw_destroy(document.mraw, true);
    lexbor_mraw_destroy(document.text, true);
    lexbor_hash_destroy(document.tags, true);
    lexbor_hash_destroy(document.ns, true);
    lexbor_hash_destroy(document.attrs, true);
    lexbor_hash_destroy(document.prefix, true);

    return LXB_STATUS_ERROR;
}

lxb_status_t lxb_dom_document_clean(lxb_dom_document_t* document)
{
    if ((cast(lxb_dom_node_t*) (document)).owner_document == document) {
        lexbor_mraw_clean(document.mraw);
        lexbor_mraw_clean(document.text);
        lexbor_hash_clean(document.tags);
        lexbor_hash_clean(document.ns);
        lexbor_hash_clean(document.attrs);
        lexbor_hash_clean(document.prefix);
    }

    document.node.first_child = null;
    document.node.last_child = null;
    document.element = null;
    document.doctype = null;

    return LXB_STATUS_OK;
}

lxb_dom_document_t* lxb_dom_document_destroy(lxb_dom_document_t* document)
{
    if (document == null) {
        return null;
    }

    if ((cast(lxb_dom_node_t*) (document)).owner_document != document) {
        lxb_dom_document_t* owner = void;

        owner = (cast(lxb_dom_node_t*) (document)).owner_document;

        return cast(lxb_dom_document*) lexbor_mraw_free(owner.mraw, document);
    }

    lexbor_mraw_destroy(document.text, true);
    lexbor_mraw_destroy(document.mraw, true);
    lexbor_hash_destroy(document.tags, true);
    lexbor_hash_destroy(document.ns, true);
    lexbor_hash_destroy(document.attrs, true);
    lexbor_hash_destroy(document.prefix, true);

    return cast(lxb_dom_document*) lexbor_free(document);
}

void lxb_dom_document_mutation_init(lxb_dom_document_t* document)
{
    document.mutation = &lxb_dom_document_mutation_cbs;
    document.attr_mutation = &lxb_dom_document_attr_mutation_cbs;
}

void lxb_dom_document_mutation_erase(lxb_dom_document_t* document)
{
    document.mutation = &lxb_dom_document_mutation_cbs;
    document.attr_mutation = &lxb_dom_document_attr_mutation_cbs;
}

void lxb_dom_document_attach_doctype(lxb_dom_document_t* document, lxb_dom_document_type_t* doctype)
{
    document.doctype = doctype;
}

void lxb_dom_document_attach_element(lxb_dom_document_t* document, lxb_dom_element_t* element)
{
    document.element = element;
}

lxb_dom_element_t* lxb_dom_document_create_element(lxb_dom_document_t* document, const(lxb_char_t)* local_name, size_t lname_len, void* reserved_for_opt)
{
    /* TODO: If localName does not match the Name production... */

    const(lxb_char_t)* ns_link = void;
    size_t ns_len = void;

    if (document.type == LXB_DOM_DOCUMENT_DTYPE_HTML) {
        ns_link = cast(const(lxb_char_t)*) "http://www.w3.org/1999/xhtml";

        /* FIXME: he will get len at the compilation stage?!? */
        ns_len = strlen(cast(const(char)*) ns_link);
    }
    else {
        ns_link = null;
        ns_len = 0;
    }

    return lxb_dom_element_create(document, local_name, lname_len,
                                  ns_link, ns_len, null, 0, null, 0, true);
}

lxb_dom_element_t* lxb_dom_document_destroy_element(lxb_dom_element_t* element)
{
    return lxb_dom_element_destroy(element);
}

lxb_dom_document_fragment_t* lxb_dom_document_create_document_fragment(lxb_dom_document_t* document)
{
    return lxb_dom_document_fragment_interface_create(document);
}

lxb_dom_text_t* lxb_dom_document_create_text_node(lxb_dom_document_t* document, const(lxb_char_t)* data, size_t len)
{
    lxb_dom_text_t* text = void;

    text = cast(lxb_dom_text*) lxb_dom_document_create_interface(document,
                                             LXB_TAG__TEXT, LXB_NS_HTML);
    if (text == null) {
        return null;
    }

    lexbor_str_init(&text.char_data.data, document.text, len);
    if (text.char_data.data.data == null) {
        return cast(typeof(return)) lxb_dom_document_destroy_interface(text);
    }

    lexbor_str_append(&text.char_data.data, document.text, data, len);

    return text;
}

lxb_dom_cdata_section_t* lxb_dom_document_create_cdata_section(lxb_dom_document_t* document, const(lxb_char_t)* data, size_t len)
{
    if (document.type != LXB_DOM_DOCUMENT_DTYPE_HTML) {
        return null;
    }

    const(lxb_char_t)* end = data + len;
    const(lxb_char_t)* ch = cast(const(ubyte)*) memchr(data, ']', lxb_char_t.sizeof * len);

    while (ch != null) {
        if ((end - ch) < 3) {
            break;
        }

        if(memcmp(ch, "]]>".ptr, 3) == 0) {
            return null;
        }

        ch++;
        ch = cast(const(ubyte)*) memchr(ch, ']', lxb_char_t.sizeof * (end - ch));
    }

    lxb_dom_cdata_section_t* cdata = void;

    cdata = lxb_dom_cdata_section_interface_create(document);
    if (cdata == null) {
        return null;
    }

    lexbor_str_init(&cdata.text.char_data.data, document.text, len);
    if (cdata.text.char_data.data.data == null) {
        return lxb_dom_cdata_section_interface_destroy(cdata);
    }

    lexbor_str_append(&cdata.text.char_data.data, document.text, data, len);

    return cdata;
}

lxb_dom_processing_instruction_t* lxb_dom_document_create_processing_instruction(lxb_dom_document_t* document, const(lxb_char_t)* target, size_t target_len, const(lxb_char_t)* data, size_t data_len)
{
    /*
     * TODO: If target does not match the Name production,
     * then throw an "InvalidCharacterError" DOMException.
     */

    const(lxb_char_t)* end = data + data_len;
    const(lxb_char_t)* ch = cast(const(ubyte)*) memchr(data, '?', lxb_char_t.sizeof * data_len);

    while (ch != null) {
        if ((end - ch) < 2) {
            break;
        }

        if(memcmp(ch, "?>".ptr, 2) == 0) {
            return null;
        }

        ch++;
        ch = cast(const(ubyte)*) memchr(ch, '?', lxb_char_t.sizeof * (end - ch));
    }

    lxb_dom_processing_instruction_t* pi = void;

    pi = lxb_dom_processing_instruction_interface_create(document);
    if (pi == null) {
        return null;
    }

    lexbor_str_init(&pi.char_data.data, document.text, data_len);
    if (pi.char_data.data.data == null) {
        return lxb_dom_processing_instruction_interface_destroy(pi);
    }

    lexbor_str_init(&pi.target, document.text, target_len);
    if (pi.target.data == null) {
        lexbor_str_destroy(&pi.char_data.data, document.text, false);

        return lxb_dom_processing_instruction_interface_destroy(pi);
    }

    lexbor_str_append(&pi.char_data.data, document.text, data, data_len);
    lexbor_str_append(&pi.target, document.text, target, target_len);

    return pi;
}

lxb_dom_comment_t* lxb_dom_document_create_comment(lxb_dom_document_t* document, const(lxb_char_t)* data, size_t len)
{
    lxb_dom_comment_t* comment = void;

    comment = cast(lxb_dom_comment*) lxb_dom_document_create_interface(document, LXB_TAG__EM_COMMENT,
                                                LXB_NS_HTML);
    if (comment == null) {
        return null;
    }

    lexbor_str_init(&comment.char_data.data, document.text, len);
    if (comment.char_data.data.data == null) {
        return cast(typeof(return)) lxb_dom_document_destroy_interface(comment);
    }

    lexbor_str_append(&comment.char_data.data, document.text, data, len);

    return comment;
}

lxb_dom_node_t* lxb_dom_document_root(lxb_dom_document_t* document)
{
    lxb_dom_node_t* node = void;

    if (document.type == LXB_DOM_DOCUMENT_DTYPE_HTML) {
        node = document.node.first_child;

        while (node != null) {
            if (node.local_name == LXB_TAG_HTML) {
                return node;
            }

            node = node.next;
        }
    }

    return document.node.first_child;
}

lxb_dom_node_t* lxb_dom_document_import_node(lxb_dom_document_t* doc, lxb_dom_node_t* node, bool deep)
{
    lxb_dom_node_t* new_ = void, curr = void, cnode = void, root = void;

    new_ = cast(lxb_dom_node*) doc.clone_interface(doc, node);
    if (new_ == null) {
        return null;
    }

    if (!deep) {
        return new_;
    }

    curr = new_;
    root = node;
    node = node.first_child;

    while (node != null) {
        cnode = cast(lxb_dom_node*) doc.clone_interface(doc, node);
        if (cnode == null) {
            return null;
        }

        lxb_dom_node_insert_child(curr, cnode);

        if (node.first_child != null) {
            node = node.first_child;
            curr = cnode;
        }
        else {
            while (node.next == null && node != root) {
                node = node.parent;
                curr = curr.parent;
            }

            if (node == root) {
                break;
            }

            node = node.next;
        }
    }

    return new_;
}

void lxb_dom_document_set_default_node_cb(lxb_dom_document_t* document)
{
    document.mutation = &lxb_dom_document_mutation_cbs;
}

/*
 * No inline functions for ABI.
 */
lxb_dom_interface_t* lxb_dom_document_create_interface_noi(lxb_dom_document_t* document, lxb_tag_id_t tag_id, lxb_ns_id_t ns)
{
    return lxb_dom_document_create_interface(document, tag_id, ns);
}

lxb_dom_interface_t* lxb_dom_document_destroy_interface_noi(lxb_dom_interface_t* intrfc)
{
    return cast(typeof(return)) lxb_dom_document_destroy_interface(intrfc);
}

void* lxb_dom_document_create_struct_noi(lxb_dom_document_t* document, size_t struct_size)
{
    return lxb_dom_document_create_struct(document, struct_size);
}

void* lxb_dom_document_destroy_struct_noi(lxb_dom_document_t* document, void* structure)
{
    return lxb_dom_document_destroy_struct(document, structure);
}

lxb_char_t* lxb_dom_document_create_text_noi(lxb_dom_document_t* document, size_t len)
{
    return lxb_dom_document_create_text(document, len);
}

void* lxb_dom_document_destroy_text_noi(lxb_dom_document_t* document, lxb_char_t* text)
{
    return lxb_dom_document_destroy_text(document, text);
}

lxb_dom_element_t* lxb_dom_document_element_noi(lxb_dom_document_t* document)
{
    return lxb_dom_document_element(document);
}

bool lxb_dom_document_scripting_noi(lxb_dom_document_t* document)
{
    return lxb_dom_document_scripting(document);
}

void lxb_dom_document_scripting_set_noi(lxb_dom_document_t* document, bool scripting)
{
    lxb_dom_document_scripting_set(document, scripting);
}

void lxb_dom_document_opt_set_noi(lxb_dom_document_t* document, lxb_dom_document_opt_t opt)
{
    lxb_dom_document_opt_set(document, opt);
}

lxb_dom_document_opt_t lxb_dom_document_opt_noi(lxb_dom_document_t* document)
{
    return lxb_dom_document_opt(document);
}
