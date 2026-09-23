module parserino.lexbor.dom.interfaces.event_target;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interface_;
import parserino.lexbor.dom.interfaces.document;

extern(C) @nogc nothrow:
__gshared:

// ---- event_target.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_dom_event_target {
    void* events;
}

 lxb_dom_event_target_t* lxb_dom_event_target_create(lxb_dom_document_t* document);

 lxb_dom_event_target_t* lxb_dom_event_target_destroy(lxb_dom_event_target_t* event_target, lxb_dom_document_t* document);

// D port: implementation not needed by parserino, not ported.
