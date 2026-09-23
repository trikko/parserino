module parserino.lexbor.html.interfaces.document;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.mraw;
public import parserino.lexbor.tag.tag;
public import parserino.lexbor.ns.ns;
public import parserino.lexbor.html.interface_;
public import parserino.lexbor.dom.interfaces.attr;
public import parserino.lexbor.dom.interfaces.document;
import parserino.lexbor.core.str;
import parserino.lexbor.html.interfaces.title_element;
import parserino.lexbor.html.interfaces.style_element;
import parserino.lexbor.html.interfaces.option_element;
import parserino.lexbor.html.element_steps;
import parserino.lexbor.html.attribute_steps;
import parserino.lexbor.html.node;
import parserino.lexbor.html.parser;
import parserino.lexbor.html.tokenizer;
import parserino.lexbor.html.tree.open_elements_res;
import parserino.lexbor.dom.interfaces.text;
import parserino.lexbor.dom.interfaces.element;

extern(C) @nogc nothrow:
__gshared:

// ---- document.h ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_html_document_done_cb_f = lxb_status_t function(lxb_html_document_t* document);

alias lxb_html_document_open_elements_pop_f = lxb_status_t function(lxb_dom_node_t* node);

enum lxb_html_document_ready_state_t {
    LXB_HTML_DOCUMENT_READY_STATE_UNDEF = 0x00,
    LXB_HTML_DOCUMENT_READY_STATE_LOADING = 0x01,
    LXB_HTML_DOCUMENT_READY_STATE_INTERACTIVE = 0x02,
    LXB_HTML_DOCUMENT_READY_STATE_COMPLETE = 0x03,
}
alias LXB_HTML_DOCUMENT_READY_STATE_UNDEF = lxb_html_document_ready_state_t.LXB_HTML_DOCUMENT_READY_STATE_UNDEF;
alias LXB_HTML_DOCUMENT_READY_STATE_LOADING = lxb_html_document_ready_state_t.LXB_HTML_DOCUMENT_READY_STATE_LOADING;
alias LXB_HTML_DOCUMENT_READY_STATE_INTERACTIVE = lxb_html_document_ready_state_t.LXB_HTML_DOCUMENT_READY_STATE_INTERACTIVE;
alias LXB_HTML_DOCUMENT_READY_STATE_COMPLETE = lxb_html_document_ready_state_t.LXB_HTML_DOCUMENT_READY_STATE_COMPLETE;


alias lxb_html_document_opt_t = uint;

enum lxb_html_document_opt_ {
    LXB_HTML_DOCUMENT_OPT_UNDEF = 0x00
}
alias LXB_HTML_DOCUMENT_OPT_UNDEF = lxb_html_document_opt_.LXB_HTML_DOCUMENT_OPT_UNDEF;


struct lxb_html_document {
    lxb_dom_document_t dom_document;

    void* iframe_srcdoc;

    lxb_html_head_element_t* head;
    lxb_html_body_element_t* body;

    lxb_html_document_done_cb_f done;
    lxb_html_document_ready_state_t ready_state;

    const(lxb_html_document_open_elements_pop_f)* open_pop;

    lxb_html_document_opt_t opt;
}




















/*
 * Inline functions
 */
 lxb_html_head_element_t* lxb_html_document_head_element(lxb_html_document_t* document)
{
    return document.head;
}

 lxb_html_body_element_t* lxb_html_document_body_element(lxb_html_document_t* document)
{
    return document.body;
}

 lxb_dom_document_t* lxb_html_document_original_ref(lxb_html_document_t* document)
{
    if ((cast(lxb_dom_node_t*) (document)).owner_document
        != &document.dom_document)
    {
        return (cast(lxb_dom_node_t*) (document)).owner_document;
    }

    return (cast(lxb_dom_document_t*) (document));
}

 bool lxb_html_document_is_original(lxb_html_document_t* document)
{
    return (cast(lxb_dom_node_t*) (document)).owner_document
        == &document.dom_document;
}

 lexbor_mraw_t* lxb_html_document_mraw(lxb_html_document_t* document)
{
    return cast(lexbor_mraw_t*) (cast(lxb_dom_document_t*) (document)).mraw;
}

 lexbor_mraw_t* lxb_html_document_mraw_text(lxb_html_document_t* document)
{
    return cast(lexbor_mraw_t*) (cast(lxb_dom_document_t*) (document)).text;
}

 void lxb_html_document_opt_set(lxb_html_document_t* document, lxb_html_document_opt_t opt)
{
    document.opt = opt;
}

 lxb_html_document_opt_t lxb_html_document_opt(lxb_html_document_t* document)
{
    return document.opt;
}

 void lxb_html_document_dom_opt_set(lxb_html_document_t* document, lxb_dom_document_opt_t opt)
{
    document.dom_document.options = opt;
}

 lxb_dom_document_opt_t lxb_html_document_dom_opt(const(lxb_html_document_t)* document)
{
    return document.dom_document.options;
}

 void lxb_html_document_scripting_set(lxb_html_document_t* document, bool scripting)
{
    document.dom_document.scripting = scripting;
}

 bool lxb_html_document_scripting(lxb_html_document_t* document)
{
    return document.dom_document.scripting;
}

 lexbor_hash_t* lxb_html_document_tags(lxb_html_document_t* document)
{
    return document.dom_document.tags;
}

 void* lxb_html_document_create_struct(lxb_html_document_t* document, size_t struct_size)
{
    return lexbor_mraw_calloc((cast(lxb_dom_document_t*) (document)).mraw,
                              struct_size);
}

 void* lxb_html_document_destroy_struct(lxb_html_document_t* document, void* data)
{
    return lexbor_mraw_free((cast(lxb_dom_document_t*) (document)).mraw, data);
}

 lxb_html_element_t* lxb_html_document_create_element(lxb_html_document_t* document, const(lxb_char_t)* local_name, size_t lname_len, void* reserved_for_opt)
{
    return cast(lxb_html_element_t*) lxb_dom_document_create_element(&document.dom_document,
                                                                  local_name, lname_len,
                                                                  reserved_for_opt);
}

 lxb_dom_element_t* lxb_html_document_destroy_element(lxb_dom_element_t* element)
{
    return lxb_dom_document_destroy_element(element);
}

 lxb_html_document_done_cb_f lxb_html_document_done(lxb_html_document_t* document)
{
    return document.done;
}

 void lxb_html_document_done_set(lxb_html_document_t* document, lxb_html_document_done_cb_f done_cb)
{
    document.done = done_cb;
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
    // D port (C extern, imported instead): extern lxb_html_tag_category_t[LXB_NS__LAST_ENTRY][LXB_TAG__LAST_ENTRY] lxb_html_tag_res_cats;
    // D port (C extern, imported instead): extern lxb_html_tag_fixname_t[LXB_TAG__LAST_ENTRY] lxb_html_tag_res_fixname_svg;

private const(lxb_dom_document_mutation_cb_t) lxb_html_document_mutation = {
    inserted: &lxb_html_element_steps_insertion,
    removed: &lxb_html_element_steps_removing,
    moved: &lxb_html_element_steps_moving,
    destroy: &lxb_html_element_steps_destroy,
    children_changed: &lxb_html_element_steps_children_changed,
    connected: &lxb_html_element_steps_post_connection
};

private const(lxb_dom_document_attr_mutation_cb_t) lxb_html_document_attr_mutation = {
    change: &lxb_html_attribute_steps_change,
    append: &lxb_html_attribute_steps_append,
    remove: &lxb_html_attribute_steps_remove,
    replace: &lxb_html_attribute_steps_replace
};

lxb_status_t lxb_html_parse_chunk_prepare(lxb_html_parser_t* parser, lxb_html_document_t* document);

 



 lxb_dom_interface_t* lxb_html_document_interface_create_handler(lxb_dom_document_t* document, lxb_tag_id_t tag_id, lxb_ns_id_t ns)
{
    return lxb_html_interface_create((cast(lxb_html_document_t*) (document)),
                                     tag_id, ns);
}

lxb_html_document_t* lxb_html_document_interface_create(lxb_html_document_t* document)
{
    lxb_status_t status = void;
    lxb_dom_document_t* doc = void;

    if (document != null) {
        doc = cast(lxb_dom_document*) lexbor_mraw_calloc(lxb_html_document_mraw(document),
                                 lxb_html_document_t.sizeof);
    }
    else {
        doc = cast(lxb_dom_document*) lexbor_calloc(1, lxb_html_document_t.sizeof);
    }

    if (doc == null) {
        return null;
    }

    status = lxb_dom_document_init(doc, (cast(lxb_dom_document_t*) (document)),
                                   &lxb_html_document_interface_create_handler,
                                   &lxb_html_interface_clone,
                                   &lxb_html_interface_destroy,
                                   LXB_DOM_DOCUMENT_DTYPE_HTML, LXB_NS_HTML);
    if (status != LXB_STATUS_OK) {
        cast(void) lxb_dom_document_destroy(doc);
        return null;
    }

    lxb_html_document_mutation_init((cast(lxb_html_document_t*) (doc)));

    return (cast(lxb_html_document_t*) (doc));
}

lxb_html_document_t* lxb_html_document_interface_destroy(lxb_html_document_t* document)
{
    lxb_dom_document_t* doc = void;

    if (document == null) {
        return null;
    }

    doc = (cast(lxb_dom_document_t*) (document));

    if (doc.node.owner_document == doc) {
        cast(void) lxb_html_parser_unref(cast(lxb_html_parser_t*) doc.parser);
    }

    cast(void) lxb_dom_document_destroy(doc);

    return null;
}

lxb_html_document_t* lxb_html_document_create()
{
    return lxb_html_document_interface_create(null);
}

void lxb_html_document_clean(lxb_html_document_t* document)
{
    document.body = null;
    document.head = null;
    document.iframe_srcdoc = null;
    document.ready_state = LXB_HTML_DOCUMENT_READY_STATE_UNDEF;

    lxb_dom_document_clean((cast(lxb_dom_document_t*) (document)));
}

lxb_html_document_t* lxb_html_document_destroy(lxb_html_document_t* document)
{
    return lxb_html_document_interface_destroy(document);
}

void lxb_html_document_mutation_init(lxb_html_document_t* document)
{
    document.dom_document.mutation = &lxb_html_document_mutation;
    document.dom_document.attr_mutation = &lxb_html_document_attr_mutation;
    document.open_pop = lxb_html_tree_open_elements_pop_res.ptr;
}

void lxb_html_document_mutation_erase(lxb_html_document_t* document)
{
    lxb_dom_document_mutation_init(&document.dom_document);
    document.open_pop = null;
}

lxb_status_t lxb_html_document_parse(lxb_html_document_t* document, const(lxb_char_t)* html, size_t size)
{
    lxb_status_t status = void;
    lxb_dom_document_t* doc = void;
    lxb_html_document_opt_t opt = void;

    if (document.ready_state != LXB_HTML_DOCUMENT_READY_STATE_UNDEF
        && document.ready_state != LXB_HTML_DOCUMENT_READY_STATE_LOADING)
    {
        lxb_html_document_clean(document);
    }

    opt = document.opt;
    doc = (cast(lxb_dom_document_t*) (document));

    status = lxb_html_document_parser_prepare(document);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    status = lxb_html_parse_chunk_prepare(cast(lxb_html_parser_t*) doc.parser, document);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    status = lxb_html_parse_chunk_process(cast(lxb_html_parser_t*) doc.parser, html, size);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    document.opt = opt;

    return lxb_html_parse_chunk_end(cast(lxb_html_parser_t*) doc.parser);

failed:

    document.opt = opt;

    return status;
}

lxb_status_t lxb_html_document_parse_chunk_begin(lxb_html_document_t* document)
{
    if (document.ready_state != LXB_HTML_DOCUMENT_READY_STATE_UNDEF
        && document.ready_state != LXB_HTML_DOCUMENT_READY_STATE_LOADING)
    {
        lxb_html_document_clean(document);
    }

    lxb_status_t status = lxb_html_document_parser_prepare(document);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    return lxb_html_parse_chunk_prepare(cast(lxb_html_parser_t*) document.dom_document.parser,
                                        document);
}

lxb_status_t lxb_html_document_parse_chunk(lxb_html_document_t* document, const(lxb_char_t)* html, size_t size)
{
    return lxb_html_parse_chunk_process(cast(lxb_html_parser_t*) document.dom_document.parser,
                                        html, size);
}

lxb_status_t lxb_html_document_parse_chunk_end(lxb_html_document_t* document)
{
    return lxb_html_parse_chunk_end(cast(lxb_html_parser_t*) document.dom_document.parser);
}

lxb_dom_node_t* lxb_html_document_parse_fragment(lxb_html_document_t* document, lxb_dom_element_t* element, const(lxb_char_t)* html, size_t size)
{
    lxb_status_t status = void;
    lxb_html_parser_t* parser = void;
    lxb_html_document_opt_t opt = document.opt;

    status = lxb_html_document_parser_prepare(document);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    parser = cast(lxb_html_parser_t*) document.dom_document.parser;

    status = lxb_html_parse_fragment_chunk_begin(parser, document,
                                                 element.node.local_name,
                                                 element.node.ns);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    status = lxb_html_parse_fragment_chunk_process(parser, html, size);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    document.opt = opt;

    return lxb_html_parse_fragment_chunk_end(parser);

failed:

    document.opt = opt;

    return null;
}

lxb_status_t lxb_html_document_parse_fragment_chunk_begin(lxb_html_document_t* document, lxb_dom_element_t* element)
{
    lxb_status_t status = void;
    lxb_html_parser_t* parser = void;

    status = lxb_html_document_parser_prepare(document);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    parser = cast(lxb_html_parser_t*) document.dom_document.parser;

    return lxb_html_parse_fragment_chunk_begin(parser, document,
                                               element.node.local_name,
                                               element.node.ns);
}

lxb_status_t lxb_html_document_parse_fragment_chunk(lxb_html_document_t* document, const(lxb_char_t)* html, size_t size)
{
    return lxb_html_parse_fragment_chunk_process(cast(lxb_html_parser_t*) document.dom_document.parser,
                                                 html, size);
}

lxb_dom_node_t* lxb_html_document_parse_fragment_chunk_end(lxb_html_document_t* document)
{
    return lxb_html_parse_fragment_chunk_end(cast(lxb_html_parser_t*) document.dom_document.parser);
}

 lxb_status_t lxb_html_document_parser_prepare(lxb_html_document_t* document)
{
    lxb_status_t status = void;
    lxb_dom_document_t* doc = void;
    lxb_html_parser_t* parser = void;

    doc = (cast(lxb_dom_document_t*) (document));

    if (doc.parser == null) {
        doc.parser = lxb_html_parser_create();
        status = lxb_html_parser_init(cast(lxb_html_parser_t*) doc.parser);

        if (status != LXB_STATUS_OK) {
            lxb_html_parser_destroy(cast(lxb_html_parser_t*) doc.parser);
            return status;
        }

        parser = cast(lxb_html_parser_t*) doc.parser;

        lxb_html_tokenizer_keep_duplicate_set(parser.tkz, true);
    }
    else if (lxb_html_parser_state(cast(lxb_html_parser_t*) doc.parser) != LXB_HTML_PARSER_STATE_BEGIN) {
        lxb_html_parser_clean(cast(lxb_html_parser_t*) doc.parser);
    }

    return LXB_STATUS_OK;
}

const(lxb_char_t)* lxb_html_document_title(lxb_html_document_t* document, size_t* len)
{
    lxb_html_title_element_t* title = null;

    lxb_dom_node_simple_walk((cast(lxb_dom_node_t*) (document)),
                             &lxb_html_document_title_walker, &title);
    if (title == null) {
        return null;
    }

    return lxb_html_title_element_strict_text(title, len);
}

lxb_status_t lxb_html_document_title_set(lxb_html_document_t* document, const(lxb_char_t)* title, size_t len)
{
    lxb_status_t status = void;

    /* TODO: If the document element is an SVG svg element */

    /* If the document element is in the HTML namespace */
    if (document.head == null) {
        return LXB_STATUS_OK;
    }

    lxb_html_title_element_t* el_title = null;

    lxb_dom_node_simple_walk((cast(lxb_dom_node_t*) (document)),
                             &lxb_html_document_title_walker, &el_title);
    if (el_title == null) {
        el_title = cast(lxb_html_title_element_t*) (cast(void*) lxb_html_document_create_element(document,
                                         cast(const(lxb_char_t)*) "title", 5, null));
        if (el_title == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        lxb_dom_node_insert_child((cast(lxb_dom_node_t*) (document.head)),
                                  (cast(lxb_dom_node_t*) (el_title)));
    }

    status = lxb_dom_node_text_content_set((cast(lxb_dom_node_t*) (el_title)),
                                           title, len);
    if (status != LXB_STATUS_OK) {
        lxb_html_document_destroy_element(&el_title.element.element);

        return status;
    }

    return LXB_STATUS_OK;
}

const(lxb_char_t)* lxb_html_document_title_raw(lxb_html_document_t* document, size_t* len)
{
    lxb_html_title_element_t* title = null;

    lxb_dom_node_simple_walk((cast(lxb_dom_node_t*) (document)),
                             &lxb_html_document_title_walker, &title);
    if (title == null) {
        return null;
    }

    return lxb_html_title_element_text(title, len);
}

private lexbor_action_t lxb_html_document_title_walker(lxb_dom_node_t* node, void* ctx)
{
    if (node.local_name == LXB_TAG_TITLE && node.ns == LXB_NS_HTML) {
        *(cast(void**) ctx) = node;

        return LEXBOR_ACTION_STOP;
    }

    return LEXBOR_ACTION_OK;
}

lxb_dom_node_t* lxb_html_document_import_node(lxb_html_document_t* doc, lxb_dom_node_t* node, bool deep)
{
    return lxb_dom_document_import_node(&doc.dom_document, node, deep);
}

/*
 * No inline functions for ABI.
 */
lxb_html_head_element_t* lxb_html_document_head_element_noi(lxb_html_document_t* document)
{
    return lxb_html_document_head_element(document);
}

lxb_html_body_element_t* lxb_html_document_body_element_noi(lxb_html_document_t* document)
{
    return lxb_html_document_body_element(document);
}

lxb_dom_document_t* lxb_html_document_original_ref_noi(lxb_html_document_t* document)
{
    return lxb_html_document_original_ref(document);
}

bool lxb_html_document_is_original_noi(lxb_html_document_t* document)
{
    return lxb_html_document_is_original(document);
}

lexbor_mraw_t* lxb_html_document_mraw_noi(lxb_html_document_t* document)
{
    return lxb_html_document_mraw(document);
}

lexbor_mraw_t* lxb_html_document_mraw_text_noi(lxb_html_document_t* document)
{
    return lxb_html_document_mraw_text(document);
}

void lxb_html_document_opt_set_noi(lxb_html_document_t* document, lxb_html_document_opt_t opt)
{
    lxb_html_document_opt_set(document, opt);
}

lxb_html_document_opt_t lxb_html_document_opt_noi(lxb_html_document_t* document)
{
    return lxb_html_document_opt(document);
}

void* lxb_html_document_create_struct_noi(lxb_html_document_t* document, size_t struct_size)
{
    return lxb_html_document_create_struct(document, struct_size);
}

void* lxb_html_document_destroy_struct_noi(lxb_html_document_t* document, void* data)
{
    return lxb_html_document_destroy_struct(document, data);
}

lxb_html_element_t* lxb_html_document_create_element_noi(lxb_html_document_t* document, const(lxb_char_t)* local_name, size_t lname_len, void* reserved_for_opt)
{
    return lxb_html_document_create_element(document, local_name, lname_len,
                                            reserved_for_opt);
}

lxb_dom_element_t* lxb_html_document_destroy_element_noi(lxb_dom_element_t* element)
{
    return lxb_html_document_destroy_element(element);
}

void lxb_html_document_dom_opt_set_noi(lxb_html_document_t* document, lxb_dom_document_opt_t opt)
{
    lxb_html_document_dom_opt_set(document, opt);
}

lxb_dom_document_opt_t lxb_html_document_dom_opt_noi(lxb_html_document_t* document)
{
    return lxb_html_document_dom_opt(document);
}
