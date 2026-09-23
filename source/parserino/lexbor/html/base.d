module parserino.lexbor.html.base;

import parserino.lexbor.html.tree;
import parserino.lexbor.html.tokenizer;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- base.h ----
/*
 * Copyright (C) 2018-2024 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum LXB_HTML_VERSION_MAJOR = 2;
enum LXB_HTML_VERSION_MINOR = 6;
enum LXB_HTML_VERSION_PATCH = 0;

enum LXB_HTML_VERSION_STRING = "2.6.0";

alias lxb_html_tokenizer_t = lxb_html_tokenizer;
alias lxb_html_tokenizer_opt_t = uint;
alias lxb_html_tree_t = lxb_html_tree;

/*
 * Please, see lexbor/base.h lexbor_status_t
 */
enum lxb_html_status_t {
    LXB_HTML_STATUS_OK = 0x0000,
}
alias LXB_HTML_STATUS_OK = lxb_html_status_t.LXB_HTML_STATUS_OK;

