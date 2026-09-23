module parserino.lexbor.css.at_rule;

import parserino.lexbor.core.shs;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.base;
public import parserino.lexbor.css.syntax.syntax;
public import parserino.lexbor.css.at_rule.const_;
import parserino.lexbor.css.css;
import parserino.lexbor.css.parser;
// import css/stylesheet (not ported)
import parserino.lexbor.css.at_rule.state;
// import css/at_rule/res (not ported)
import parserino.lexbor.core.serialize;

extern(C) @nogc nothrow:
__gshared:

// ---- at_rule.h ----
/*
 * Copyright (C) 2021-2022 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_css_at_rule__undef_t {
    lxb_css_at_rule_type_t type;
    lexbor_str_t prelude;
    lexbor_str_t block;
}

struct lxb_css_at_rule__custom_t {
    lexbor_str_t name;
    lexbor_str_t prelude;
    lexbor_str_t block;
}

struct lxb_css_at_rule_media_t {
    uintptr_t reserved;
}

struct lxb_css_at_rule_namespace_t {
    uintptr_t reserved;
}





/* _undef. */



/* _custom. */



/* Media. */



/* Namespace. */



// D port: implementation not needed by parserino, not ported.
