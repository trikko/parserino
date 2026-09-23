module parserino.lexbor.dom.interfaces.shadow_root;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interfaces.document;
public import parserino.lexbor.dom.interfaces.element;
public import parserino.lexbor.dom.interfaces.document_fragment;

extern(C) @nogc nothrow:
__gshared:

// ---- shadow_root.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum lxb_dom_shadow_root_mode_t {
    LXB_DOM_SHADOW_ROOT_MODE_OPEN = 0x00,
    LXB_DOM_SHADOW_ROOT_MODE_CLOSED = 0x01
}
alias LXB_DOM_SHADOW_ROOT_MODE_OPEN = lxb_dom_shadow_root_mode_t.LXB_DOM_SHADOW_ROOT_MODE_OPEN;
alias LXB_DOM_SHADOW_ROOT_MODE_CLOSED = lxb_dom_shadow_root_mode_t.LXB_DOM_SHADOW_ROOT_MODE_CLOSED;


struct lxb_dom_shadow_root {
    lxb_dom_document_fragment_t document_fragment;

    lxb_dom_shadow_root_mode_t mode;
    lxb_dom_element_t* host;
}

 lxb_dom_shadow_root_t* lxb_dom_shadow_root_interface_create(lxb_dom_document_t* document);

 lxb_dom_shadow_root_t* lxb_dom_shadow_root_interface_destroy(lxb_dom_shadow_root_t* shadow_root);

// D port: implementation not needed by parserino, not ported.
