module parserino.lexbor.dom.interface_;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.tag.const_;
public import parserino.lexbor.ns.const_;
import parserino.lexbor.dom.interfaces.cdata_section;
import parserino.lexbor.dom.interfaces.character_data;
import parserino.lexbor.dom.interfaces.comment;
import parserino.lexbor.dom.interfaces.document;
import parserino.lexbor.dom.interfaces.document_fragment;
import parserino.lexbor.dom.interfaces.document_type;
import parserino.lexbor.dom.interfaces.element;
import parserino.lexbor.dom.interfaces.event_target;
import parserino.lexbor.dom.interfaces.node;
import parserino.lexbor.dom.interfaces.processing_instruction;
import parserino.lexbor.dom.interfaces.shadow_root;
import parserino.lexbor.dom.interfaces.text;

extern(C) @nogc nothrow:
__gshared:

// ---- interface.h ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_dom_event_target_t = lxb_dom_event_target;
alias lxb_dom_node_t = lxb_dom_node;
alias lxb_dom_element_t = lxb_dom_element;
alias lxb_dom_attr_t = lxb_dom_attr;
alias lxb_dom_document_t = lxb_dom_document;
alias lxb_dom_document_type_t = lxb_dom_document_type;
alias lxb_dom_document_fragment_t = lxb_dom_document_fragment;
alias lxb_dom_shadow_root_t = lxb_dom_shadow_root;
alias lxb_dom_character_data_t = lxb_dom_character_data;
alias lxb_dom_text_t = lxb_dom_text;
alias lxb_dom_cdata_section_t = lxb_dom_cdata_section;
alias lxb_dom_processing_instruction_t = lxb_dom_processing_instruction;
alias lxb_dom_comment_t = lxb_dom_comment;

alias lxb_dom_interface_t = void;

alias lxb_dom_interface_constructor_f = void* function(void* document);

alias lxb_dom_interface_destructor_f = void* function(void* intrfc);

alias lxb_dom_interface_create_f = lxb_dom_interface_t* function(lxb_dom_document_t* document, lxb_tag_id_t tag_id, lxb_ns_id_t ns);

alias lxb_dom_interface_clone_f = lxb_dom_interface_t* function(lxb_dom_document_t* document, const(lxb_dom_interface_t)* intrfc);

alias lxb_dom_interface_destroy_f = lxb_dom_interface_t* function(lxb_dom_interface_t* intrfc);




// ---- interface.c ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
lxb_dom_interface_t* lxb_dom_interface_create(lxb_dom_document_t* document, lxb_tag_id_t tag_id, lxb_ns_id_t ns)
{
    lxb_dom_element_t* domel = void;

    domel = lxb_dom_element_interface_create(document);
    if (domel == null) {
        return null;
    }

    domel.node.local_name = tag_id;
    domel.node.ns = ns;

    return domel;
}

lxb_dom_interface_t* lxb_dom_interface_clone(lxb_dom_document_t* document, const(lxb_dom_interface_t)* intrfc)
{
    const(lxb_dom_node_t)* node = cast(const(lxb_dom_node)*) intrfc;

    if (document == null) {
        document = cast(lxb_dom_document*) node.owner_document;
    }

    switch (node.type) {
        case LXB_DOM_NODE_TYPE_ELEMENT:
            return lxb_dom_element_interface_clone(document, cast(const(lxb_dom_element)*) intrfc);

        case LXB_DOM_NODE_TYPE_TEXT:
            return lxb_dom_text_interface_clone(document, cast(const(lxb_dom_text)*) intrfc);

        case LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION:
            return lxb_dom_processing_instruction_interface_clone(document,
                                                                  cast(const(lxb_dom_processing_instruction)*) intrfc);
        case LXB_DOM_NODE_TYPE_COMMENT:
            return lxb_dom_comment_interface_clone(document, cast(const(lxb_dom_comment)*) intrfc);

        case LXB_DOM_NODE_TYPE_DOCUMENT:
            return lxb_dom_document_interface_clone(document, cast(const(lxb_dom_document)*) intrfc);

        case LXB_DOM_NODE_TYPE_DOCUMENT_TYPE:
            return lxb_dom_document_type_interface_clone(document, cast(const(lxb_dom_document_type)*) intrfc);

        default:
            return lxb_dom_node_interface_clone(document, node, false);
    }
}

lxb_dom_interface_t* lxb_dom_interface_destroy(lxb_dom_interface_t* intrfc)
{
    if (intrfc == null) {
        return null;
    }

    lxb_dom_node_t* node = cast(lxb_dom_node*) intrfc;

    switch (node.type) {
        case LXB_DOM_NODE_TYPE_ELEMENT:
            return lxb_dom_element_interface_destroy(cast(lxb_dom_element*) intrfc);

        case LXB_DOM_NODE_TYPE_TEXT:
            return lxb_dom_text_interface_destroy(cast(lxb_dom_text*) intrfc);

        case LXB_DOM_NODE_TYPE_CDATA_SECTION:
            return lxb_dom_cdata_section_interface_destroy(cast(lxb_dom_cdata_section*) intrfc);

        case LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION:
            return lxb_dom_processing_instruction_interface_destroy(cast(lxb_dom_processing_instruction*) intrfc);

        case LXB_DOM_NODE_TYPE_COMMENT:
            return lxb_dom_comment_interface_destroy(cast(lxb_dom_comment*) intrfc);

        case LXB_DOM_NODE_TYPE_DOCUMENT:
            return lxb_dom_document_interface_destroy(cast(lxb_dom_document*) intrfc);

        case LXB_DOM_NODE_TYPE_DOCUMENT_TYPE:
            return lxb_dom_document_type_interface_destroy(cast(lxb_dom_document_type*) intrfc);

        case LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT:
            return lxb_dom_document_fragment_interface_destroy(cast(lxb_dom_document_fragment*) intrfc);

        default:
            return lexbor_mraw_free(node.owner_document.mraw, intrfc);
    }
}
