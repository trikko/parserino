module parserino.lexbor.css.base;

import parserino.lexbor.css.syntax.token;
import parserino.lexbor.css.syntax.tokenizer;
import parserino.lexbor.css.parser;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.core.mraw;
public import parserino.lexbor.core.str;

extern(C) @nogc nothrow:
__gshared:

// ---- base.h ----
/*
 * Copyright (C) 2019-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum LXB_CSS_VERSION_MAJOR = 1;
enum LXB_CSS_VERSION_MINOR = 4;
enum LXB_CSS_VERSION_PATCH = 0;

enum LXB_CSS_VERSION_STRING = "0.0.0";

struct lxb_css_memory_t {
    lexbor_dobject_t* objs;
    lexbor_mraw_t* mraw;
    lexbor_mraw_t* tree;

    size_t ref_count;
}

alias lxb_css_type_t = uint;

alias lxb_css_parser_t = lxb_css_parser;
alias lxb_css_parser_state_t = lxb_css_parser_state_;
alias lxb_css_parser_error_t = lxb_css_parser_error;

alias lxb_css_syntax_tokenizer_t = lxb_css_syntax_tokenizer;
alias lxb_css_syntax_token_t = lxb_css_syntax_token_;

/* Callbacks. */

alias lxb_css_parser_state_f = bool function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx);

alias lxb_css_style_create_f = void* function(lxb_css_memory_t* memory);

alias lxb_css_style_serialize_f = lxb_status_t function(const(void)* style, lexbor_serialize_cb_f cb, void* ctx);

alias lxb_css_style_destroy_f = void* function(lxb_css_memory_t* memory, void* style, bool self_destroy);

/* StyleSheet tree structures. */

struct lxb_css_stylesheet; // D port: not ported, opaque
alias lxb_css_stylesheet_t = lxb_css_stylesheet;
struct lxb_css_rule_list; // D port: not ported, opaque
alias lxb_css_rule_list_t = lxb_css_rule_list;
struct lxb_css_rule_style; // D port: not ported, opaque
alias lxb_css_rule_style_t = lxb_css_rule_style;
struct lxb_css_rule_bad_style; // D port: not ported, opaque
alias lxb_css_rule_bad_style_t = lxb_css_rule_bad_style;
struct lxb_css_rule_declaration_list; // D port: not ported, opaque
alias lxb_css_rule_declaration_list_t = lxb_css_rule_declaration_list;
struct lxb_css_rule_declaration; // D port: not ported, opaque
alias lxb_css_rule_declaration_t = lxb_css_rule_declaration;
struct lxb_css_rule_at; // D port: not ported, opaque
alias lxb_css_rule_at_t = lxb_css_rule_at;

struct lxb_css_entry_data_t {
    lxb_char_t* name;
    size_t length;
    uintptr_t unique;
    lxb_css_parser_state_f state;
    lxb_css_style_create_f create;
    lxb_css_style_destroy_f destroy;
    lxb_css_style_serialize_f serialize;
    void* initial;
}

struct lxb_css_entry_at_rule_data_t {
    lxb_char_t* name;
    size_t length;
    uintptr_t unique;

    /* const lxb_css_syntax_cb_at_rule_t */
    const(void)* cbs;

    lxb_css_style_create_f create;
    lxb_css_style_destroy_f destroy;
    lxb_css_style_serialize_f serialize;
    void* initial;
}

// D port: implemented in css/css.d
public import parserino.lexbor.css.css : lxb_css_memory_create, lxb_css_memory_init, lxb_css_memory_clean, lxb_css_memory_destroy, lxb_css_memory_ref_inc, lxb_css_memory_ref_dec, lxb_css_memory_ref_dec_destroy;

struct lxb_css_data_t {
    lxb_char_t* name;
    size_t length;
    uintptr_t unique;
}

