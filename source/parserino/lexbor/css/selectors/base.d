module parserino.lexbor.css.selectors.base;

import parserino.lexbor.css.selectors.selector;
import parserino.lexbor.css.selectors.selectors;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- base.h ----
/*
 * Copyright (C) 2021-2024 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum LXB_CSS_SELECTORS_VERSION_MAJOR = 1;
enum LXB_CSS_SELECTORS_VERSION_MINOR = 1;
enum LXB_CSS_SELECTORS_VERSION_PATCH = 0;

enum LXB_CSS_SELECTORS_VERSION_STRING = "1.1.0";

alias lxb_css_selectors_t = lxb_css_selectors;
alias lxb_css_selector_t = lxb_css_selector;
alias lxb_css_selector_list_t = lxb_css_selector_list;
