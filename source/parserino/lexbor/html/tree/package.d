module parserino.lexbor.html.tree;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interfaces.node;
public import parserino.lexbor.dom.interfaces.attr;
public import parserino.lexbor.html.base;
public import parserino.lexbor.html.node;
public import parserino.lexbor.html.tokenizer;
public import parserino.lexbor.html.interfaces.document;
public import parserino.lexbor.html.tag;
public import parserino.lexbor.html.tree.error;
import parserino.lexbor.dom.interfaces.document_fragment;
import parserino.lexbor.dom.interfaces.document_type;
import parserino.lexbor.dom.interfaces.comment;
import parserino.lexbor.dom.interfaces.text;
import parserino.lexbor.html.tree_res;
import parserino.lexbor.html.tree.insertion_mode;
import parserino.lexbor.html.tree.open_elements;
import parserino.lexbor.html.tree.active_formatting;
import parserino.lexbor.html.tree.template_insertion;
import parserino.lexbor.html.interface_;
import parserino.lexbor.html.interfaces.template_element;
import parserino.lexbor.html.interfaces.unknown_element;
import parserino.lexbor.html.tokenizer.state_rawtext;
import parserino.lexbor.html.tokenizer.state_rcdata;
import parserino.lexbor.html.serialize;

extern(C) @nogc nothrow:
__gshared:

// ---- tree.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_html_tree_insertion_mode_f = bool function(lxb_html_tree_t* tree, lxb_html_token_t* token);

alias lxb_html_tree_append_attr_f = lxb_status_t function(lxb_html_tree_t* tree, lxb_dom_attr_t* attr, void* ctx);

struct lxb_html_tree_pending_table_t {
    lexbor_array_obj_t* text_list;
    bool have_non_ws;
}

struct lxb_html_tree {
    lxb_html_tokenizer_t* tkz_ref;

    lxb_html_document_t* document;
    lxb_dom_node_t* fragment;

    lxb_html_form_element_t* form;

    lexbor_array_t* open_elements;
    lexbor_array_t* active_formatting;
    lexbor_array_obj_t* template_insertion_modes;

    lxb_html_tree_pending_table_t pending_table;

    lexbor_array_obj_t* parse_errors;

    bool foster_parenting;
    bool frameset_ok;
    bool scripting;

    lxb_html_tree_insertion_mode_f mode;
    lxb_html_tree_insertion_mode_f original_mode;
    lxb_html_tree_append_attr_f before_append_attr;

    lxb_status_t status;

    size_t ref_count;
}

enum lxb_html_tree_insertion_position_t {
    LXB_HTML_TREE_INSERTION_POSITION_CHILD = 0x00,
    LXB_HTML_TREE_INSERTION_POSITION_BEFORE = 0x01
}
alias LXB_HTML_TREE_INSERTION_POSITION_CHILD = lxb_html_tree_insertion_position_t.LXB_HTML_TREE_INSERTION_POSITION_CHILD;
alias LXB_HTML_TREE_INSERTION_POSITION_BEFORE = lxb_html_tree_insertion_position_t.LXB_HTML_TREE_INSERTION_POSITION_BEFORE;









































/*
 * Inline functions
 */
 lxb_status_t lxb_html_tree_begin(lxb_html_tree_t* tree, lxb_html_document_t* document)
{
    tree.document = document;

    return lxb_html_tokenizer_begin(tree.tkz_ref);
}

 lxb_status_t lxb_html_tree_chunk(lxb_html_tree_t* tree, const(lxb_char_t)* html, size_t size)
{
    return lxb_html_tokenizer_chunk(tree.tkz_ref, html, size);
}

 lxb_status_t lxb_html_tree_end(lxb_html_tree_t* tree)
{
    if (tree.document.done != null) {
        tree.document.done(tree.document);
    }

    return lxb_html_tokenizer_end(tree.tkz_ref);
}

 lxb_status_t lxb_html_tree_build(lxb_html_tree_t* tree, lxb_html_document_t* document, const(lxb_char_t)* html, size_t size)
{
    tree.status = lxb_html_tree_begin(tree, document);
    if (tree.status != LXB_STATUS_OK) {
        return tree.status;
    }

    tree.status = lxb_html_tree_chunk(tree, html, size);
    if (tree.status != LXB_STATUS_OK) {
        return tree.status;
    }

    return lxb_html_tree_end(tree);
}

 lxb_dom_node_t* lxb_html_tree_create_node(lxb_html_tree_t* tree, lxb_tag_id_t tag_id, lxb_ns_id_t ns)
{
    return cast(lxb_dom_node_t*) lxb_html_interface_create(tree.document,
                                                        tag_id, ns);
}

 bool lxb_html_tree_node_is(const(lxb_dom_node_t)* node, lxb_tag_id_t tag_id)
{
    return node.local_name == tag_id && node.ns == LXB_NS_HTML;
}

 lxb_dom_node_t* lxb_html_tree_current_node(lxb_html_tree_t* tree)
{
    if (tree.open_elements.length == 0) {
        return null;
    }

    return cast(lxb_dom_node_t*)
        tree.open_elements.list[ (tree.open_elements.length - 1) ];
}

 lxb_dom_node_t* lxb_html_tree_adjusted_current_node(lxb_html_tree_t* tree)
{
    if(tree.fragment != null && tree.open_elements.length == 1) {
        return (cast(lxb_dom_node_t*) (tree.fragment));
    }

    return lxb_html_tree_current_node(tree);
}

 lxb_html_element_t* lxb_html_tree_insert_html_element(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    return lxb_html_tree_insert_foreign_element(tree, token, LXB_NS_HTML);
}

 void lxb_html_tree_insert_node(lxb_dom_node_t* to, lxb_dom_node_t* node, lxb_html_tree_insertion_position_t ipos)
{
    if (ipos == LXB_HTML_TREE_INSERTION_POSITION_BEFORE) {
        lxb_dom_node_insert_before_wo_events(to, node);
        return;
    }

    lxb_dom_node_insert_child_wo_events(to, node);
}

/* TODO: if we not need to save parse errors?! */
 void lxb_html_tree_acknowledge_token_self_closing(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    if ((token.type & LXB_HTML_TOKEN_TYPE_CLOSE_SELF) == 0) {
        return;
    }

    bool is_void = lxb_html_tag_is_void(token.tag_id);

    if (!is_void) {
        lxb_html_tree_parse_error(tree, token,
                                  LXB_HTML_RULES_ERROR_NOVOHTELSTTAWITRSO);
    }
}

 bool lxb_html_tree_mathml_text_integration_point(lxb_dom_node_t* node)
{
    if (node.ns == LXB_NS_MATH) {
        switch (node.local_name) {
            case LXB_TAG_MI:
            case LXB_TAG_MO:
            case LXB_TAG_MN:
            case LXB_TAG_MS:
            case LXB_TAG_MTEXT:
                return true;
        default: break;}
    }

    return false;
}

 bool lxb_html_tree_scripting(lxb_html_tree_t* tree)
{
    return tree.scripting;
}

 void lxb_html_tree_scripting_set(lxb_html_tree_t* tree, bool scripting)
{
    tree.scripting = scripting;
}

 void lxb_html_tree_attach_document(lxb_html_tree_t* tree, lxb_html_document_t* doc)
{
    tree.document = doc;
}

// ---- tree.c ----
/*
 * Copyright (C) 2018-2022 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
lxb_dom_attr_data_t* lxb_dom_attr_local_name_append(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length);

lxb_dom_attr_data_t* lxb_dom_attr_qualified_name_append(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length);

const(lxb_tag_data_t)* lxb_tag_append_lower(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length);




lxb_html_tree_t* lxb_html_tree_create()
{
    return cast(lxb_html_tree*) lexbor_calloc(1, lxb_html_tree_t.sizeof);
}

lxb_status_t lxb_html_tree_init(lxb_html_tree_t* tree, lxb_html_tokenizer_t* tkz)
{
    if (tree == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    if (tkz == null) {
        return LXB_STATUS_ERROR_WRONG_ARGS;
    }

    lxb_status_t status = void;

    /* Stack of open elements */
    tree.open_elements = lexbor_array_create();
    status = lexbor_array_init(tree.open_elements, 128);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    /* Stack of active formatting */
    tree.active_formatting = lexbor_array_create();
    status = lexbor_array_init(tree.active_formatting, 128);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    /* Stack of template insertion modes */
    tree.template_insertion_modes = lexbor_array_obj_create();
    status = lexbor_array_obj_init(tree.template_insertion_modes, 64,
                                   lxb_html_tree_template_insertion_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    /* Stack of pending table character tokens */
    tree.pending_table.text_list = lexbor_array_obj_create();
    status = lexbor_array_obj_init(tree.pending_table.text_list, 16,
                                   lexbor_str_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    /* Parse errors */
    tree.parse_errors = lexbor_array_obj_create();
    status = lexbor_array_obj_init(tree.parse_errors, 16,
                                                lxb_html_tree_error_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    tree.tkz_ref = lxb_html_tokenizer_ref(tkz);

    tree.document = null;
    tree.fragment = null;

    tree.form = null;

    tree.foster_parenting = false;
    tree.frameset_ok = true;

    tree.mode = &lxb_html_tree_insertion_mode_initial;
    tree.before_append_attr = null;

    tree.status = LXB_STATUS_OK;

    tree.ref_count = 1;

    lxb_html_tokenizer_callback_token_done_set(tkz,
                                               &lxb_html_tree_token_callback,
                                               tree);

    return LXB_STATUS_OK;
}

lxb_html_tree_t* lxb_html_tree_ref(lxb_html_tree_t* tree)
{
    if (tree == null) {
        return null;
    }

    tree.ref_count++;

    return tree;
}

lxb_html_tree_t* lxb_html_tree_unref(lxb_html_tree_t* tree)
{
    if (tree == null || tree.ref_count == 0) {
        return null;
    }

    tree.ref_count--;

    if (tree.ref_count == 0) {
        lxb_html_tree_destroy(tree);
    }

    return null;
}

void lxb_html_tree_clean(lxb_html_tree_t* tree)
{
    lexbor_array_clean(tree.open_elements);
    lexbor_array_clean(tree.active_formatting);
    lexbor_array_obj_clean(tree.template_insertion_modes);
    lexbor_array_obj_clean(tree.pending_table.text_list);
    lexbor_array_obj_clean(tree.parse_errors);

    tree.document = null;
    tree.fragment = null;

    tree.form = null;

    tree.foster_parenting = false;
    tree.frameset_ok = true;

    tree.mode = &lxb_html_tree_insertion_mode_initial;
    tree.before_append_attr = null;

    tree.status = LXB_STATUS_OK;
}

lxb_html_tree_t* lxb_html_tree_destroy(lxb_html_tree_t* tree)
{
    if (tree == null) {
        return null;
    }

    tree.open_elements = lexbor_array_destroy(tree.open_elements, true);
    tree.active_formatting = lexbor_array_destroy(tree.active_formatting,
                                                   true);
    tree.template_insertion_modes = lexbor_array_obj_destroy(tree.template_insertion_modes,
                                                              true);
    tree.pending_table.text_list = lexbor_array_obj_destroy(tree.pending_table.text_list,
                                                             true);

    tree.parse_errors = lexbor_array_obj_destroy(tree.parse_errors, true);
    tree.tkz_ref = lxb_html_tokenizer_unref(tree.tkz_ref);

    return cast(lxb_html_tree*) lexbor_free(tree);
}

private lxb_html_token_t* lxb_html_tree_token_callback(lxb_html_tokenizer_t* tkz, lxb_html_token_t* token, void* ctx)
{
    lxb_status_t status = void;

    status = lxb_html_tree_insertion_mode(cast(lxb_html_tree*) ctx, token);
    if (status != LXB_STATUS_OK) {
        tkz.status = status;
        return null;
    }

    return token;
}

/* TODO: not complete!!! */
lxb_status_t lxb_html_tree_stop_parsing(lxb_html_tree_t* tree)
{
    tree.document.ready_state = LXB_HTML_DOCUMENT_READY_STATE_COMPLETE;

    return LXB_STATUS_OK;
}

bool lxb_html_tree_process_abort(lxb_html_tree_t* tree)
{
    if (tree.status == LXB_STATUS_OK) {
        tree.status = LXB_STATUS_ABORTED;
    }

    tree.open_elements.length = 0;
    tree.document.ready_state = LXB_HTML_DOCUMENT_READY_STATE_COMPLETE;

    return true;
}

void lxb_html_tree_parse_error(lxb_html_tree_t* tree, lxb_html_token_t* token, lxb_html_tree_error_id_t id)
{
    lxb_html_tree_error_add(tree.parse_errors, token, id);
}

bool lxb_html_tree_construction_dispatcher(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_dom_node_t* adjusted = void;

    adjusted = lxb_html_tree_adjusted_current_node(tree);

    if (adjusted == null || adjusted.ns == LXB_NS_HTML) {
        return tree.mode(tree, token);
    }

    if (lxb_html_tree_mathml_text_integration_point(adjusted))
    {
        if ((token.type & LXB_HTML_TOKEN_TYPE_CLOSE) == 0
            && token.tag_id != LXB_TAG_MGLYPH
            && token.tag_id != LXB_TAG_MALIGNMARK)
        {
            return tree.mode(tree, token);
        }

        if (token.tag_id == LXB_TAG__TEXT) {
            return tree.mode(tree, token);
        }
    }

    if (adjusted.local_name == LXB_TAG_ANNOTATION_XML
        && adjusted.ns == LXB_NS_MATH
        && (token.type & LXB_HTML_TOKEN_TYPE_CLOSE) == 0
        && token.tag_id == LXB_TAG_SVG)
    {
        return tree.mode(tree, token);
    }

    if (lxb_html_tree_html_integration_point(adjusted)) {
        if ((token.type & LXB_HTML_TOKEN_TYPE_CLOSE) == 0
            || token.tag_id == LXB_TAG__TEXT)
        {
            return tree.mode(tree, token);
        }
    }

    if (token.tag_id == LXB_TAG__END_OF_FILE) {
        return tree.mode(tree, token);
    }

    return lxb_html_tree_insertion_mode_foreign_content(tree, token);
}

private lxb_status_t lxb_html_tree_insertion_mode(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    while (lxb_html_tree_construction_dispatcher(tree, token) == false) {}

    return tree.status;
}

/*
 * Action
 */
lxb_dom_node_t* lxb_html_tree_appropriate_place_inserting_node(lxb_html_tree_t* tree, lxb_dom_node_t* override_target, lxb_html_tree_insertion_position_t* ipos)
{
    lxb_dom_node_t* target = void, adjusted_location = null;

    *ipos = LXB_HTML_TREE_INSERTION_POSITION_CHILD;

    if (override_target != null) {
        target = override_target;
    }
    else {
        target = lxb_html_tree_current_node(tree);
    }

    if (tree.foster_parenting && target.ns == LXB_NS_HTML
           && (target.local_name == LXB_TAG_TABLE
            || target.local_name == LXB_TAG_TBODY
            || target.local_name == LXB_TAG_TFOOT
            || target.local_name == LXB_TAG_THEAD
            || target.local_name == LXB_TAG_TR))
    {
        lxb_dom_node_t* last_temp = void, last_table = void;
        size_t last_temp_idx = void, last_table_idx = void;

        last_temp = lxb_html_tree_open_elements_find_reverse(tree,
                                                          LXB_TAG_TEMPLATE,
                                                          LXB_NS_HTML,
                                                          &last_temp_idx);

        last_table = lxb_html_tree_open_elements_find_reverse(tree,
                                                             LXB_TAG_TABLE,
                                                             LXB_NS_HTML,
                                                             &last_table_idx);

        if(last_temp != null && (last_table == null
                         || last_temp_idx > last_table_idx))
        {
            lxb_dom_document_fragment_t* doc_fragment = void;

            doc_fragment = (cast(lxb_html_template_element_t*) (last_temp)).content;

            return (cast(lxb_dom_node_t*) (doc_fragment));
        }
        else if (last_table == null) {
            adjusted_location = lxb_html_tree_open_elements_first(tree);

            {}
            {}
        }
        else if (last_table.parent != null) {
            adjusted_location = last_table;

            *ipos = LXB_HTML_TREE_INSERTION_POSITION_BEFORE;
        }
        else {
            {}

            adjusted_location = lxb_html_tree_open_elements_get(tree,
                                                            last_table_idx - 1);
        }
    }
    else {
        adjusted_location = target;
    }

    if (adjusted_location == null) {
        return null;
    }

    /*
     * In Spec it is not entirely clear what is meant:
     *
     * If the adjusted insertion location is inside a template element,
     * let it instead be inside the template element's template contents,
     * after its last child (if any).
     */
    if (lxb_html_tree_node_is(adjusted_location, LXB_TAG_TEMPLATE)) {
        lxb_dom_document_fragment_t* df = void;

        df = (cast(lxb_html_template_element_t*) (adjusted_location)).content;
        adjusted_location = (cast(lxb_dom_node_t*) (df));
    }

    return adjusted_location;
}

lxb_html_element_t* lxb_html_tree_insert_foreign_element(lxb_html_tree_t* tree, lxb_html_token_t* token, lxb_ns_id_t ns)
{
    lxb_status_t status = void;
    lxb_dom_node_t* pos = void;
    lxb_html_element_t* element = void;
    lxb_html_tree_insertion_position_t ipos = void;

    pos = lxb_html_tree_appropriate_place_inserting_node(tree, null, &ipos);
    if (pos == null) {
        return null;
    }

    element = lxb_html_tree_create_element_for_token(tree, token, ns);
    if (element == null) {
        return null;
    }

    lxb_html_tree_insert_node(pos, (cast(lxb_dom_node_t*) (element)), ipos);

    status = lxb_html_tree_open_elements_push(tree,
                                              (cast(lxb_dom_node_t*) (element)));
    if (status != LXB_HTML_STATUS_OK) {
        return cast(typeof(return)) lxb_html_interface_destroy(element);
    }

    return element;
}

lxb_html_element_t* lxb_html_tree_create_element_for_token(lxb_html_tree_t* tree, lxb_html_token_t* token, lxb_ns_id_t ns)
{
    lxb_dom_node_t* node = lxb_html_tree_create_node(tree, token.tag_id, ns);
    if (node == null) {
        return null;
    }

    lxb_status_t status = void;
    lxb_dom_element_t* element = (cast(lxb_dom_element_t*) (node));

    if (token.base_element == null) {
        status = lxb_html_tree_append_attributes(tree, element, token, ns);
    }
    else {
        status = lxb_html_tree_append_attributes_from_element(tree, element,
                                                       cast(lxb_dom_element*) token.base_element, ns);
    }

    if (status != LXB_HTML_STATUS_OK) {
        return cast(typeof(return)) lxb_html_interface_destroy(element);
    }

    return (cast(lxb_html_element_t*) (node));
}

lxb_status_t lxb_html_tree_append_attributes(lxb_html_tree_t* tree, lxb_dom_element_t* element, lxb_html_token_t* token, lxb_ns_id_t ns)
{
    lxb_status_t status = void;
    lxb_dom_attr_t* attr = void;
    lxb_html_document_t* doc = void;
    lxb_html_token_attr_t* token_attr = token.attr_first;

    doc = (cast(lxb_html_document_t*) (element.node.owner_document));

    while (token_attr != null) {
        attr = lxb_dom_element_attr_by_local_name_data(element,
                                                       token_attr.name);
        if (attr != null) {
            token_attr = token_attr.next;
            continue;
        }

        attr = lxb_dom_attr_interface_create((cast(lxb_dom_document_t*) (doc)));
        if (attr == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        if (token_attr.value_begin != null) {
            status = lxb_dom_attr_set_value_wo_copy(attr, token_attr.value,
                                                    token_attr.value_size);
            if (status != LXB_HTML_STATUS_OK) {
                return status;
            }
        }

        attr.node.local_name = token_attr.name.attr_id;
        attr.node.ns = ns;

        /* Fix for adjust MathML/SVG attributes */
        if (tree.before_append_attr != null) {
            status = tree.before_append_attr(tree, attr, null);
            if (status != LXB_STATUS_OK) {
                return status;
            }
        }

        lxb_dom_element_attr_append(element, attr);

        token_attr = token_attr.next;
    }

    return LXB_HTML_STATUS_OK;
}

lxb_status_t lxb_html_tree_append_attributes_from_element(lxb_html_tree_t* tree, lxb_dom_element_t* element, lxb_dom_element_t* from, lxb_ns_id_t ns)
{
    lxb_status_t status = void;
    lxb_dom_attr_t* attr = from.first_attr;
    lxb_dom_attr_t* new_attr = void;

    while (attr != null) {
        new_attr = lxb_dom_attr_interface_create(element.node.owner_document);
        if (new_attr == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        status = lxb_dom_attr_clone_name_value(attr, new_attr);
        if (status != LXB_HTML_STATUS_OK) {
            return status;
        }

        new_attr.node.ns = attr.node.ns;

        /* Fix for  adjust MathML/SVG attributes */
        if (tree.before_append_attr != null) {
            status = tree.before_append_attr(tree, new_attr, null);
            if (status != LXB_STATUS_OK) {
                return status;
            }
        }

        lxb_dom_element_attr_append(element, new_attr);

        attr = attr.next;
    }

    return LXB_HTML_STATUS_OK;
}

lxb_status_t lxb_html_tree_adjust_mathml_attributes(lxb_html_tree_t* tree, lxb_dom_attr_t* attr, void* ctx)
{
    lexbor_hash_t* attrs = void;
    const(lxb_dom_attr_data_t)* data = void;

    attrs = attr.node.owner_document.attrs;
    data = lxb_dom_attr_data_by_id(attrs, attr.node.local_name);

    if (data.entry.length == 13
        && lexbor_str_data_cmp(lexbor_hash_entry_str(&data.entry),
                               cast(const(lxb_char_t)*) "definitionurl"))
    {
        data = lxb_dom_attr_qualified_name_append(attrs,
                                      cast(const(lxb_char_t)*) "definitionURL", 13);
        if (data == null) {
            return LXB_STATUS_ERROR;
        }

        attr.qualified_name = data.attr_id;
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_tree_adjust_svg_attributes(lxb_html_tree_t* tree, lxb_dom_attr_t* attr, void* ctx)
{
    lexbor_hash_t* attrs = void;
    const(lxb_dom_attr_data_t)* data = void;
    const(lxb_html_tree_res_attr_adjust_t)* adjust = void;

    size_t len = lxb_html_tree_res_attr_adjust_svg_map.sizeof
        / lxb_html_tree_res_attr_adjust_t.sizeof;

    attrs = attr.node.owner_document.attrs;

    data = lxb_dom_attr_data_by_id(attrs, attr.node.local_name);

    for (size_t i = 0; i < len; i++) {
        adjust = &lxb_html_tree_res_attr_adjust_svg_map[i];

        if (data.entry.length == adjust.len
            && lexbor_str_data_cmp(lexbor_hash_entry_str(&data.entry),
                                   cast(const(lxb_char_t)*) adjust.from))
        {
            data = lxb_dom_attr_qualified_name_append(attrs,
                                cast(const(lxb_char_t)*) adjust.to, adjust.len);
            if (data == null) {
                return LXB_STATUS_ERROR;
            }

            attr.qualified_name = data.attr_id;

            return LXB_STATUS_OK;
        }
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_tree_adjust_foreign_attributes(lxb_html_tree_t* tree, lxb_dom_attr_t* attr, void* ctx)
{
    size_t lname_length = void;
    lexbor_hash_t* attrs = void, prefix = void;
    const(lxb_dom_attr_data_t)* attr_data = void;
    const(lxb_ns_prefix_data_t)* prefix_data = void;
    const(lxb_dom_attr_data_t)* data = void;
    const(lxb_html_tree_res_attr_adjust_foreign_t)* adjust = void;

    size_t len = lxb_html_tree_res_attr_adjust_foreign_map.sizeof
        / lxb_html_tree_res_attr_adjust_foreign_t.sizeof;

    attrs = attr.node.owner_document.attrs;
    prefix = attr.node.owner_document.prefix;

    data = lxb_dom_attr_data_by_id(attrs, attr.node.local_name);

    for (size_t i = 0; i < len; i++) {
        adjust = &lxb_html_tree_res_attr_adjust_foreign_map[i];

        if (data.entry.length == adjust.name_len
            && lexbor_str_data_cmp(lexbor_hash_entry_str(&data.entry),
                                   cast(const(lxb_char_t)*) adjust.name))
        {
            if (adjust.prefix_len != 0) {
                data = lxb_dom_attr_qualified_name_append(attrs,
                           cast(const(lxb_char_t)*) adjust.name, adjust.name_len);
                if (data == null) {
                    return LXB_STATUS_ERROR;
                }

                attr.qualified_name = data.attr_id;

                lname_length = adjust.name_len - adjust.prefix_len - 1;

                attr_data = lxb_dom_attr_local_name_append(attrs,
                         cast(const(lxb_char_t)*) adjust.local_name, lname_length);
                if (attr_data == null) {
                    return LXB_STATUS_ERROR;
                }

                attr.node.local_name = attr_data.attr_id;

                prefix_data = lxb_ns_prefix_append(prefix,
                       cast(const(lxb_char_t)*) adjust.prefix, adjust.prefix_len);
                if (prefix_data == null) {
                    return LXB_STATUS_ERROR;
                }

                attr.node.prefix = prefix_data.prefix_id;
            }

            attr.node.ns = adjust.ns;

            return LXB_STATUS_OK;
        }
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_tree_insert_character(lxb_html_tree_t* tree, lxb_html_token_t* token, lxb_dom_node_t** ret_node)
{
    size_t size = void;
    lxb_status_t status = void;
    lexbor_str_t str; // C: = {0}

    size = token.text_end - token.text_start;

    lexbor_str_init(&str, tree.document.dom_document.text, size + 1);
    if (str.data == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    memcpy(str.data, token.text_start, size);

    str.data[size] = 0x00;
    str.length = size;

    status = lxb_html_tree_insert_character_for_data(tree, &str, ret_node);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_html_tree_insert_character_for_data(lxb_html_tree_t* tree, lexbor_str_t* str, lxb_dom_node_t** ret_node)
{
    const(lxb_char_t)* data = void;
    lxb_dom_node_t* pos = void;
    lxb_dom_character_data_t* chrs = null;
    lxb_html_tree_insertion_position_t ipos = void;
    lxb_dom_node_t* text = void; /* D port: hoisted, goto may not skip it */

    if (ret_node != null) {
        *ret_node = null;
    }

    pos = lxb_html_tree_appropriate_place_inserting_node(tree, null, &ipos);
    if (pos == null) {
        return LXB_STATUS_ERROR;
    }

    if (lxb_html_tree_node_is(pos, LXB_TAG__DOCUMENT)) {
        goto destroy_str;
    }

    if (ipos == LXB_HTML_TREE_INSERTION_POSITION_BEFORE) {
        /* No need check namespace */
        if (pos.prev != null && pos.prev.local_name == LXB_TAG__TEXT) {
            chrs = (cast(lxb_dom_character_data_t*) (pos.prev));

            if (ret_node != null) {
                *ret_node = pos.prev;
            }
        }
    }
    else {
        /* No need check namespace */
        if (pos.last_child != null
            && pos.last_child.local_name == LXB_TAG__TEXT)
        {
            chrs = (cast(lxb_dom_character_data_t*) (pos.last_child));

            if (ret_node != null) {
                *ret_node = pos.last_child;
            }
        }
    }

    if (chrs != null) {
        /* This is error. This can not happen, but... */
        if (chrs.data.data == null) {
            data = lexbor_str_init(&chrs.data, tree.document.dom_document.text,
                                   str.length);
            if (data == null) {
                return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            }
        }

        data = lexbor_str_append(&chrs.data, tree.document.dom_document.text,
                                 str.data, str.length);
        if (data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        goto destroy_str;
    }

    text = lxb_html_tree_create_node(tree, LXB_TAG__TEXT,
                                                     LXB_NS_HTML);
    if (text == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    (cast(lxb_dom_text_t*) (text)).char_data.data = *str;

    if (ret_node != null) {
        *ret_node = text;
    }

    lxb_html_tree_insert_node(pos, text, ipos);

    return LXB_STATUS_OK;

destroy_str:

    lexbor_str_destroy(str, tree.document.dom_document.text, false);

    return LXB_STATUS_OK;
}

lxb_dom_comment_t* lxb_html_tree_insert_comment(lxb_html_tree_t* tree, lxb_html_token_t* token, lxb_dom_node_t* pos)
{
    lxb_dom_node_t* node = void;
    lxb_dom_comment_t* comment = void;
    lxb_html_tree_insertion_position_t ipos = void;

    if (pos == null) {
        pos = lxb_html_tree_appropriate_place_inserting_node(tree, null, &ipos);
    }
    else {
        ipos = LXB_HTML_TREE_INSERTION_POSITION_CHILD;
    }

    {}

    node = lxb_html_tree_create_node(tree, token.tag_id, pos.ns);
    comment = (cast(lxb_dom_comment_t*) (node));

    if (comment == null) {
        return null;
    }

    tree.status = lxb_html_token_make_text(token, &comment.char_data.data,
                                            tree.document.dom_document.text);
    if (tree.status != LXB_STATUS_OK) {
        return null;
    }

    lxb_html_tree_insert_node(pos, node, ipos);

    return comment;
}

lxb_dom_document_type_t* lxb_html_tree_create_document_type_from_token(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_status_t status = void;
    lxb_dom_node_t* doctype_node = void;
    lxb_dom_document_type_t* doc_type = void;

    /* Create */
    doctype_node = lxb_html_tree_create_node(tree, token.tag_id, LXB_NS_HTML);
    if (doctype_node == null) {
        return null;
    }

    doc_type = (cast(lxb_dom_document_type_t*) (doctype_node));

    /* Parse */
    status = lxb_html_token_doctype_parse(token, doc_type);
    if (status != LXB_STATUS_OK) {
        return lxb_dom_document_type_interface_destroy(doc_type);
    }

    return doc_type;
}

/*
 * TODO: need use ref and unref for nodes (ref counter)
 * Not implemented until the end. It is necessary to finish it.
 */
void lxb_html_tree_node_delete_deep(lxb_html_tree_t* tree, lxb_dom_node_t* node)
{
    lxb_dom_node_remove(node);
}

lxb_html_element_t* lxb_html_tree_generic_rawtext_parsing(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_html_element_t* element = void;

    element = lxb_html_tree_insert_html_element(tree, token);
    if (element == null) {
        return null;
    }

    /*
     * Need for tokenizer state RAWTEXT
     * See description for 'lxb_html_tokenizer_state_rawtext_before' function
     */
    lxb_html_tokenizer_tmp_tag_id_set(tree.tkz_ref, token.tag_id);
    lxb_html_tokenizer_state_set(tree.tkz_ref,
                                 &lxb_html_tokenizer_state_rawtext_before);

    tree.original_mode = tree.mode;
    tree.mode = &lxb_html_tree_insertion_mode_text;

    return element;
}

/* Magic of CopyPast power! */
lxb_html_element_t* lxb_html_tree_generic_rcdata_parsing(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_html_element_t* element = void;

    element = lxb_html_tree_insert_html_element(tree, token);
    if (element == null) {
        return null;
    }

    /*
     * Need for tokenizer state RCDATA
     * See description for 'lxb_html_tokenizer_state_rcdata_before' function
     */
    lxb_html_tokenizer_tmp_tag_id_set(tree.tkz_ref, token.tag_id);
    lxb_html_tokenizer_state_set(tree.tkz_ref,
                                 &lxb_html_tokenizer_state_rcdata_before);

    tree.original_mode = tree.mode;
    tree.mode = &lxb_html_tree_insertion_mode_text;

    return element;
}

void lxb_html_tree_generate_implied_end_tags(lxb_html_tree_t* tree, lxb_tag_id_t ex_tag, lxb_ns_id_t ex_ns)
{
    lxb_dom_node_t* node = void;

    {}

    while (lexbor_array_length(tree.open_elements) != 0) {
        node = lxb_html_tree_current_node(tree);

        {}

        switch (node.local_name) {
            case LXB_TAG_DD:
            case LXB_TAG_DT:
            case LXB_TAG_LI:
            case LXB_TAG_OPTGROUP:
            case LXB_TAG_OPTION:
            case LXB_TAG_P:
            case LXB_TAG_RB:
            case LXB_TAG_RP:
            case LXB_TAG_RT:
            case LXB_TAG_RTC:
                if(node.local_name == ex_tag && node.ns == ex_ns) {
                    return;
                }

                lxb_html_tree_open_elements_pop(tree);

                break;

            default:
                return;
        }
    }
}

void lxb_html_tree_generate_all_implied_end_tags_thoroughly(lxb_html_tree_t* tree, lxb_tag_id_t ex_tag, lxb_ns_id_t ex_ns)
{
    lxb_dom_node_t* node = void;

    {}

    while (lexbor_array_length(tree.open_elements) != 0) {
        node = lxb_html_tree_current_node(tree);

        {}

        switch (node.local_name) {
            case LXB_TAG_CAPTION:
            case LXB_TAG_COLGROUP:
            case LXB_TAG_DD:
            case LXB_TAG_DT:
            case LXB_TAG_LI:
            case LXB_TAG_OPTGROUP:
            case LXB_TAG_OPTION:
            case LXB_TAG_P:
            case LXB_TAG_RB:
            case LXB_TAG_RP:
            case LXB_TAG_RT:
            case LXB_TAG_RTC:
            case LXB_TAG_TBODY:
            case LXB_TAG_TD:
            case LXB_TAG_TFOOT:
            case LXB_TAG_TH:
            case LXB_TAG_THEAD:
            case LXB_TAG_TR:
                if(node.local_name == ex_tag && node.ns == ex_ns) {
                    return;
                }

                lxb_html_tree_open_elements_pop(tree);

                break;

            default:
                return;
        }
    }
}

void lxb_html_tree_reset_insertion_mode_appropriately(lxb_html_tree_t* tree)
{
    lxb_dom_node_t* node = void;
    size_t idx = tree.open_elements.length;

    /* Step 1 */
    bool last = false;
    void** list = tree.open_elements.list;

    /* Step 3 */
    while (idx != 0) {
        idx--;

        /* Step 2 */
        node = cast(lxb_dom_node*) list[idx];

        /* Step 3 */
        if (idx == 0) {
            last = true;

            if (tree.fragment != null) {
                node = tree.fragment;
            }
        }

        {}

        /* Step 16 */
        if (node.ns != LXB_NS_HTML) {
            if (last) {
                tree.mode = &lxb_html_tree_insertion_mode_in_body;
                return;
            }

            continue;
        }

        /* Step 4 */
        if (node.local_name == LXB_TAG_SELECT) {
            /* Step 4.1 */
            if (last) {
                tree.mode = &lxb_html_tree_insertion_mode_in_select;
                return;
            }

            /* Step 4.2 */
            size_t ancestor = idx;

            for (;;) {
                /* Step 4.3 */
                if (ancestor == 0) {
                    tree.mode = &lxb_html_tree_insertion_mode_in_select;
                    return;
                }

                /* Step 4.4 */
                ancestor--;

                /* Step 4.5 */
                lxb_dom_node_t* ancestor_node = cast(lxb_dom_node*) list[ancestor];

                if(lxb_html_tree_node_is(ancestor_node, LXB_TAG_TEMPLATE)) {
                    tree.mode = &lxb_html_tree_insertion_mode_in_select;
                    return;
                }

                /* Step 4.6 */
                else if(lxb_html_tree_node_is(ancestor_node, LXB_TAG_TABLE)) {
                    tree.mode = &lxb_html_tree_insertion_mode_in_select_in_table;
                    return;
                }
            }
        }

        /* Step 5-15 */
        switch (node.local_name) {
            case LXB_TAG_TD:
            case LXB_TAG_TH:
                if (last == false) {
                    tree.mode = &lxb_html_tree_insertion_mode_in_cell;
                    return;
                }

                break;

            case LXB_TAG_TR:
                tree.mode = &lxb_html_tree_insertion_mode_in_row;
                return;

            case LXB_TAG_TBODY:
            case LXB_TAG_TFOOT:
            case LXB_TAG_THEAD:
                tree.mode = &lxb_html_tree_insertion_mode_in_table_body;
                return;

            case LXB_TAG_CAPTION:
                tree.mode = &lxb_html_tree_insertion_mode_in_caption;
                return;

            case LXB_TAG_COLGROUP:
                tree.mode = &lxb_html_tree_insertion_mode_in_column_group;
                return;

            case LXB_TAG_TABLE:
                tree.mode = &lxb_html_tree_insertion_mode_in_table;
                return;

            case LXB_TAG_TEMPLATE:
                tree.mode = lxb_html_tree_template_insertion_current(tree);

                {}

                return;

            case LXB_TAG_HEAD:
                if (last == false) {
                    tree.mode = &lxb_html_tree_insertion_mode_in_head;
                    return;
                }

                break;

            case LXB_TAG_BODY:
                tree.mode = &lxb_html_tree_insertion_mode_in_body;
                return;

            case LXB_TAG_FRAMESET:
                tree.mode = &lxb_html_tree_insertion_mode_in_frameset;
                return;

            case LXB_TAG_HTML: {
                if (tree.document.head == null) {
                    tree.mode = &lxb_html_tree_insertion_mode_before_head;
                    return;
                }

                tree.mode = &lxb_html_tree_insertion_mode_after_head;
                return;
            }

            default:
                break;
        }

        /* Step 16 */
        if (last) {
            tree.mode = &lxb_html_tree_insertion_mode_in_body;
            return;
        }
    }
}

lxb_dom_node_t* lxb_html_tree_element_in_scope(lxb_html_tree_t* tree, lxb_tag_id_t tag_id, lxb_ns_id_t ns, lxb_html_tag_category_t ct)
{
    lxb_dom_node_t* node = void;

    size_t idx = tree.open_elements.length;
    void** list = tree.open_elements.list;

    while (idx != 0) {
        idx--;
        node = cast(lxb_dom_node*) list[idx];

        if (node.local_name == tag_id && node.ns == ns) {
            return node;
        }

        if (lxb_html_tag_is_category(node.local_name, node.ns, ct)) {
            return null;
        }
    }

    return null;
}

lxb_dom_node_t* lxb_html_tree_element_in_scope_by_node(lxb_html_tree_t* tree, lxb_dom_node_t* by_node, lxb_html_tag_category_t ct)
{
    lxb_dom_node_t* node = void;

    size_t idx = tree.open_elements.length;
    void** list = tree.open_elements.list;

    while (idx != 0) {
        idx--;
        node = cast(lxb_dom_node*) list[idx];

        if (node == by_node) {
            return node;
        }

        if (lxb_html_tag_is_category(node.local_name, node.ns, ct)) {
            return null;
        }
    }

    return null;
}

lxb_dom_node_t* lxb_html_tree_element_in_scope_h123456(lxb_html_tree_t* tree)
{
    lxb_dom_node_t* node = void;

    size_t idx = tree.open_elements.length;
    void** list = tree.open_elements.list;

    while (idx != 0) {
        idx--;
        node = cast(lxb_dom_node*) list[idx];

        switch (node.local_name) {
            case LXB_TAG_H1:
            case LXB_TAG_H2:
            case LXB_TAG_H3:
            case LXB_TAG_H4:
            case LXB_TAG_H5:
            case LXB_TAG_H6:
                if (node.ns == LXB_NS_HTML) {
                    return node;
                }

                break;

            default:
                break;
        }

        if (lxb_html_tag_is_category(node.local_name, LXB_NS_HTML,
                                     LXB_HTML_TAG_CATEGORY_SCOPE))
        {
            return null;
        }
    }

    return null;
}

lxb_dom_node_t* lxb_html_tree_element_in_scope_tbody_thead_tfoot(lxb_html_tree_t* tree)
{
    lxb_dom_node_t* node = void;

    size_t idx = tree.open_elements.length;
    void** list = tree.open_elements.list;

    while (idx != 0) {
        idx--;
        node = cast(lxb_dom_node*) list[idx];

        switch (node.local_name) {
            case LXB_TAG_TBODY:
            case LXB_TAG_THEAD:
            case LXB_TAG_TFOOT:
                if (node.ns == LXB_NS_HTML) {
                    return node;
                }

                break;

            default:
                break;
        }

        if (lxb_html_tag_is_category(node.local_name, LXB_NS_HTML,
                                     LXB_HTML_TAG_CATEGORY_SCOPE_TABLE))
        {
            return null;
        }
    }

    return null;
}

lxb_dom_node_t* lxb_html_tree_element_in_scope_td_th(lxb_html_tree_t* tree)
{
    lxb_dom_node_t* node = void;

    size_t idx = tree.open_elements.length;
    void** list = tree.open_elements.list;

    while (idx != 0) {
        idx--;
        node = cast(lxb_dom_node*) list[idx];

        switch (node.local_name) {
            case LXB_TAG_TD:
            case LXB_TAG_TH:
                if (node.ns == LXB_NS_HTML) {
                    return node;
                }

                break;

            default:
                break;
        }

        if (lxb_html_tag_is_category(node.local_name, LXB_NS_HTML,
                                     LXB_HTML_TAG_CATEGORY_SCOPE_TABLE))
        {
            return null;
        }
    }

    return null;
}

bool lxb_html_tree_check_scope_element(lxb_html_tree_t* tree)
{
    lxb_dom_node_t* node = void;

    for (size_t i = 0; i < tree.open_elements.length; i++) {
        node = cast(lxb_dom_node*) tree.open_elements.list[i];

        switch (node.local_name) {
            case LXB_TAG_DD:
            case LXB_TAG_DT:
            case LXB_TAG_LI:
            case LXB_TAG_OPTGROUP:
            case LXB_TAG_OPTION:
            case LXB_TAG_P:
            case LXB_TAG_RB:
            case LXB_TAG_RP:
            case LXB_TAG_RT:
            case LXB_TAG_RTC:
            case LXB_TAG_TBODY:
            case LXB_TAG_TD:
            case LXB_TAG_TFOOT:
            case LXB_TAG_TH:
            case LXB_TAG_THEAD:
            case LXB_TAG_TR:
            case LXB_TAG_BODY:
            case LXB_TAG_HTML:
                return true;

            default:
                break;
        }
    }

    return false;
}

void lxb_html_tree_close_p_element(lxb_html_tree_t* tree, lxb_html_token_t* token)
{
    lxb_html_tree_generate_implied_end_tags(tree, LXB_TAG_P, LXB_NS_HTML);

    lxb_dom_node_t* node = lxb_html_tree_current_node(tree);

    if (lxb_html_tree_node_is(node, LXB_TAG_P) == false) {
        lxb_html_tree_parse_error(tree, token,
                                  LXB_HTML_RULES_ERROR_UNELINOPELST);
    }

    lxb_html_tree_open_elements_pop_until_tag_id(tree, LXB_TAG_P, LXB_NS_HTML,
                                                 true);
}

bool lxb_html_tree_adoption_agency_algorithm(lxb_html_tree_t* tree, lxb_html_token_t* token, lxb_status_t* status)
{
    {}

    /* State 1 */
    bool is_ = void;
    short outer_loop = void;
    lxb_html_element_t* element = void;
    lxb_dom_node_t* node = void, marker = void; lxb_dom_node_t** oel_list = void, afe_list = void;

    lxb_tag_id_t subject = token.tag_id;

    oel_list = cast(lxb_dom_node_t**) tree.open_elements.list;
    afe_list = cast(lxb_dom_node_t**) tree.active_formatting.list;
    marker = cast(lxb_dom_node_t*) lxb_html_tree_active_formatting_marker();

    *status = LXB_STATUS_OK;

    /* State 2 */
    node = lxb_html_tree_current_node(tree);
    {}

    if (lxb_html_tree_node_is(node, subject)) {
        is_ = lxb_html_tree_active_formatting_find_by_node_reverse(tree, node,
                                                                  null);
        if (is_ == false) {
            lxb_html_tree_open_elements_pop(tree);

            return false;
        }
    }

    /* State 3 */
    outer_loop = 0;

    /* State 4 */
    while (outer_loop < 8) {
        /* State 5 */
        outer_loop++;

        /* State 6 */
        size_t formatting_index = 0;
        size_t idx = tree.active_formatting.length;
        lxb_dom_node_t* formatting_element = null;

        while (idx) {
            idx--;

            if (afe_list[idx] == marker) {
                    return true;
            }
            else if (afe_list[idx].local_name == subject) {
                formatting_index = idx;
                formatting_element = afe_list[idx];

                break;
            }
        }

        if (formatting_element == null) {
            return true;
        }

        /* State 7 */
        size_t oel_formatting_idx = void;
        is_ = lxb_html_tree_open_elements_find_by_node_reverse(tree,
                                                              formatting_element,
                                                              &oel_formatting_idx);
        if (is_ == false) {
            lxb_html_tree_parse_error(tree, token,
                                      LXB_HTML_RULES_ERROR_MIELINOPELST);

            lxb_html_tree_active_formatting_remove_by_node(tree,
                                                           formatting_element);

            return false;
        }

        /* State 8 */
        node = lxb_html_tree_element_in_scope_by_node(tree, formatting_element,
                                                      LXB_HTML_TAG_CATEGORY_SCOPE);
        if (node == null) {
            lxb_html_tree_parse_error(tree, token,
                                      LXB_HTML_RULES_ERROR_MIELINSC);
            return false;
        }

        /* State 9 */
        node = lxb_html_tree_current_node(tree);

        if (formatting_element != node) {
            lxb_html_tree_parse_error(tree, token,
                                      LXB_HTML_RULES_ERROR_UNELINOPELST);
        }

        /* State 10 */
        lxb_dom_node_t* furthest_block = null;
        size_t furthest_block_idx = 0;
        size_t oel_idx = tree.open_elements.length;

        for (furthest_block_idx = oel_formatting_idx;
             furthest_block_idx < oel_idx;
             furthest_block_idx++)
        {
            is_ = lxb_html_tag_is_category(oel_list[furthest_block_idx].local_name,
                                          oel_list[furthest_block_idx].ns,
                                          LXB_HTML_TAG_CATEGORY_SPECIAL);
            if (is_) {
                furthest_block = oel_list[furthest_block_idx];

                break;
            }
        }

        /* State 11 */
        if (furthest_block == null) {
            lxb_html_tree_open_elements_pop_until_node(tree, formatting_element,
                                                       true);

            lxb_html_tree_active_formatting_remove_by_node(tree,
                                                           formatting_element);

            return false;
        }

        {}

        /* State 12 */
        lxb_dom_node_t* common_ancestor = oel_list[oel_formatting_idx - 1];

        /* State 13 */
        size_t bookmark = formatting_index;

        /* State 14 */
        lxb_dom_node_t* node_s14 = void;
        lxb_dom_node_t* last = furthest_block;
        size_t node_idx = furthest_block_idx;

        /* State 14.1 */
        size_t inner_loop_counter = 0;

        /* State 14.2 */
        while (1) {
            inner_loop_counter++;

            /* State 14.3 */
            {}

            if (node_idx == 0) {
                return false;
            }

            node_idx--;
            node_s14 = oel_list[node_idx];

            /* State 14.4 */
            if (node_s14 == formatting_element) {
                break;
            }

            /* State 14.5 */
            size_t afe_node_idx = void;
            is_ = lxb_html_tree_active_formatting_find_by_node_reverse(tree,
                                                                      node_s14,
                                                                      &afe_node_idx);
            /* State 14.5 */
            if (inner_loop_counter > 3 && is_) {
                lxb_html_tree_active_formatting_remove_by_node(tree, node_s14);

                continue;
            }

            /* State 14.6 */
            if (is_ == false) {
                lxb_html_tree_open_elements_remove_by_node(tree, node_s14);

                continue;
            }

            /* State 14.7 */
            lxb_html_token_t fake_token; // C: = {0}

            fake_token.tag_id = node_s14.local_name;
            fake_token.base_element = node_s14;

            element = lxb_html_tree_create_element_for_token(tree, &fake_token,
                                                             LXB_NS_HTML);
            if (element == null) {
                *status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;

                return false;
            }

            node_s14 = (cast(lxb_dom_node_t*) (element));

            afe_list[afe_node_idx] = node_s14;
            oel_list[node_idx] = node_s14;

            /* State 14.8 */
            if (last == furthest_block) {
                bookmark = afe_node_idx + 1;

                {}
            }

            /* State 14.9 */
            if (last.parent != null) {
                lxb_dom_node_remove_wo_events(last);
            }

            lxb_dom_node_insert_child_wo_events(node_s14, last);

            /* State 14.10 */
            last = node_s14;
        }

        if (last.parent != null) {
            lxb_dom_node_remove_wo_events(last);
        }

        /* State 15 */
        lxb_dom_node_t* pos = void;
        lxb_html_tree_insertion_position_t ipos = void;

        pos = lxb_html_tree_appropriate_place_inserting_node(tree,
                                                             common_ancestor,
                                                             &ipos);
        if (pos == null) {
            return false;
        }

        lxb_html_tree_insert_node(pos, last, ipos);

        /* State 16 */
        lxb_html_token_t fake_token; // C: = {0}

        fake_token.tag_id = formatting_element.local_name;
        fake_token.base_element = formatting_element;

        element = lxb_html_tree_create_element_for_token(tree, &fake_token,
                                                         LXB_NS_HTML);
        if (element == null) {
            *status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;

            return false;
        }

        /* State 17 */
        lxb_dom_node_t* next = void;
        node_s14 = furthest_block.first_child;

        while (node_s14 != null) {
            next = node_s14.next;

            lxb_dom_node_remove_wo_events(node_s14);
            lxb_dom_node_insert_child_wo_events((cast(lxb_dom_node_t*) (element)),
                                                node_s14);
            node_s14 = next;
        }

        node_s14 = (cast(lxb_dom_node_t*) (element));

        /* State 18 */
        lxb_dom_node_insert_child_wo_events(furthest_block, node_s14);

        /* State 19 */
        lxb_html_tree_active_formatting_remove(tree, formatting_index);

        if (bookmark > tree.active_formatting.length) {
            bookmark = tree.active_formatting.length;
        }

        *status = lxb_html_tree_active_formatting_insert(tree, node_s14, bookmark);
        if (*status != LXB_STATUS_OK) {
            return false;
        }

        /* State 20 */
        lxb_html_tree_open_elements_remove_by_node(tree, formatting_element);

        lxb_html_tree_open_elements_find_by_node(tree, furthest_block,
                                                 &furthest_block_idx);

        *status = lxb_html_tree_open_elements_insert_after(tree, node_s14,
                                                           furthest_block_idx);
        if (*status != LXB_STATUS_OK) {
            return false;
        }
    }

    return false;
}

bool lxb_html_tree_html_integration_point(lxb_dom_node_t* node)
{
    if (node.ns == LXB_NS_MATH
        && node.local_name == LXB_TAG_ANNOTATION_XML)
    {
        lxb_dom_attr_t* attr = void;
        attr = lxb_dom_element_attr_is_exist((cast(lxb_dom_element_t*) (node)),
                                             cast(const(lxb_char_t)*) "encoding",
                                             8);
        if (attr == null || attr.value == null) {
            return false;
        }

        if (attr.value.length == 9
            && lexbor_str_data_casecmp(attr.value.data,
                                       cast(const(lxb_char_t)*) "text/html"))
        {
            return true;
        }

        if (attr.value.length == 21
            && lexbor_str_data_casecmp(attr.value.data,
                                       cast(const(lxb_char_t)*) "application/xhtml+xml"))
        {
            return true;
        }

        return false;
    }

    if (node.ns == LXB_NS_SVG
        && (node.local_name == LXB_TAG_FOREIGNOBJECT
            || node.local_name == LXB_TAG_DESC
            || node.local_name == LXB_TAG_TITLE))
    {
        return true;
    }

    return false;
}

lxb_status_t lxb_html_tree_adjust_attributes_mathml(lxb_html_tree_t* tree, lxb_dom_attr_t* attr, void* ctx)
{
    lxb_status_t status = void;

    status = lxb_html_tree_adjust_mathml_attributes(tree, attr, ctx);
    if (status !=LXB_STATUS_OK) {
        return status;
    }

    return lxb_html_tree_adjust_foreign_attributes(tree, attr, ctx);
}

lxb_status_t lxb_html_tree_adjust_attributes_svg(lxb_html_tree_t* tree, lxb_dom_attr_t* attr, void* ctx)
{
    lxb_status_t status = void;

    status = lxb_html_tree_adjust_svg_attributes(tree, attr, ctx);
    if (status !=LXB_STATUS_OK) {
        return status;
    }

    return lxb_html_tree_adjust_foreign_attributes(tree, attr, ctx);
}
