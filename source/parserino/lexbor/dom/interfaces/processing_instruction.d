module parserino.lexbor.dom.interfaces.processing_instruction;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interfaces.document;
public import parserino.lexbor.dom.interfaces.text;

extern(C) @nogc nothrow:
__gshared:

// ---- processing_instruction.h ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_dom_processing_instruction {
    lxb_dom_character_data_t char_data;

    lexbor_str_t target;
}





/*
 * Inline functions
 */
 const(lxb_char_t)* lxb_dom_processing_instruction_target(lxb_dom_processing_instruction_t* pi, size_t* len)
{
    if (len != null) {
        *len = pi.target.length;
    }

    return pi.target.data;
}

/*
 * No inline functions for ABI.
 */

// ---- processing_instruction.c ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_dom_processing_instruction_t* lxb_dom_processing_instruction_interface_create(lxb_dom_document_t* document)
{
    lxb_dom_processing_instruction_t* element = void;

    element = cast(lxb_dom_processing_instruction*) lexbor_mraw_calloc(document.mraw,
                                 lxb_dom_processing_instruction_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_dom_document_owner(document);
    node.type = LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION;

    return element;
}

lxb_dom_processing_instruction_t* lxb_dom_processing_instruction_interface_clone(lxb_dom_document_t* document, const(lxb_dom_processing_instruction_t)* pinstr)
{
    lxb_status_t status = void;
    lxb_dom_processing_instruction_t* new_ = void;

    new_ = lxb_dom_processing_instruction_interface_create(document);
    if (new_ == null) {
        return null;
    }

    status = lxb_dom_processing_instruction_copy(new_, pinstr);
    if (status != LXB_STATUS_OK) {
        return lxb_dom_processing_instruction_interface_destroy(new_);
    }

    return new_;
}

lxb_dom_processing_instruction_t* lxb_dom_processing_instruction_interface_destroy(lxb_dom_processing_instruction_t* processing_instruction)
{
    lexbor_mraw_t* text = void;
    lexbor_str_t target = void;

    text = (cast(lxb_dom_node_t*) (processing_instruction)).owner_document.text;
    target = processing_instruction.target;

    cast(void) lxb_dom_character_data_interface_destroy(
                      (cast(lxb_dom_character_data_t*) (processing_instruction)));

    cast(void) lexbor_str_destroy(&target, text, false);

    return null;
}

lxb_status_t lxb_dom_processing_instruction_copy(lxb_dom_processing_instruction_t* dst, const(lxb_dom_processing_instruction_t)* src)
{
    dst.target.length = 0;

    if (lexbor_str_copy(&dst.target, &src.target,
                        (cast(lxb_dom_node_t*) (dst)).owner_document.text) == null)
    {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    return lxb_dom_character_data_interface_copy(&dst.char_data,
                                                 &src.char_data);
}

/*
 * No inline functions for ABI.
 */
const(lxb_char_t)* lxb_dom_processing_instruction_target_noi(lxb_dom_processing_instruction_t* pi, size_t* len)
{
    return lxb_dom_processing_instruction_target(pi, len);
}
