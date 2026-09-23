module parserino.lexbor.html.interfaces.window;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.interface_;
public import parserino.lexbor.dom.interfaces.event_target;
import parserino.lexbor.html.interfaces.document;

extern(C) @nogc nothrow:
__gshared:

// ---- window.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_html_window {
    lxb_dom_event_target_t event_target;
}



// D port: implementation not needed by parserino, not ported.
