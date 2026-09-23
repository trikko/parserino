module parserino.lexbor.css.at_rule;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.base;
public import parserino.lexbor.css.syntax.syntax;
public import parserino.lexbor.css.at_rule.const_;
import parserino.lexbor.css.css;
import parserino.lexbor.css.parser;
// import css/stylesheet (not ported)
import parserino.lexbor.css.at_rule.state;
// import css/at_rule/types (not ported)
// import css/at_rule/res (not ported)
import parserino.lexbor.core.serialize;

extern(C) @nogc nothrow:
__gshared:

// ---- at_rule.h ----
/*
 * Copyright (C) 2021-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_css_at_rule__undef_t {
    lxb_css_at_rule_type_t type;
    lexbor_str_t prelude;
    lxb_css_rule_list_t* block;
}

struct lxb_css_at_rule__custom_t {
    lexbor_str_t name;
    lexbor_str_t prelude;
    lxb_css_rule_list_t* block;
}

struct lxb_css_at_rule_media_t {
    lxb_css_rule_list_t* block;
}

struct lxb_css_at_rule_namespace_t {
    uintptr_t reserved;
}

struct lxb_css_at_rule_font_face_t {
    lxb_css_rule_list_t* block;
}

 const(lxb_css_entry_at_rule_data_t)* lxb_css_at_rule_by_name(const(lxb_char_t)* name, size_t length);

 const(lxb_css_entry_at_rule_data_t)* lxb_css_at_rule_by_id(uintptr_t id);

 lxb_css_rule_at_t* lxb_css_at_rule_create(lxb_css_parser_t* parser, const(lxb_char_t)* name, size_t length, const(lxb_css_entry_at_rule_data_t)** out_entry);

 void* lxb_css_at_rule_destroy(lxb_css_memory_t* memory, void* value, lxb_css_at_rule_type_t type, bool self_destroy);

 lxb_status_t lxb_css_at_rule_convert_to_undef(lxb_css_parser_t* parser, lxb_css_rule_at_t* at);

 lxb_status_t lxb_css_at_rule_serialize(const(void)* style, lxb_css_at_rule_type_t type, lexbor_serialize_cb_f cb, void* ctx);
 lxb_status_t lxb_css_at_rule_serialize_str(const(void)* style, lxb_css_at_rule_type_t type, lexbor_mraw_t* mraw, lexbor_str_t* str);
 lxb_status_t lxb_css_at_rule_serialize_name(const(void)* style, lxb_css_at_rule_type_t type, lexbor_serialize_cb_f cb, void* ctx);
 lxb_status_t lxb_css_at_rule_serialize_name_str(const(void)* style, lxb_css_at_rule_type_t type, lexbor_mraw_t* mraw, lexbor_str_t* str);

/* _undef. */

 void* lxb_css_at_rule__undef_create(lxb_css_memory_t* memory);

 void* lxb_css_at_rule__undef_destroy(lxb_css_memory_t* memory, void* style, bool self_destroy);
 lxb_status_t lxb_css_at_rule__undef_serialize(const(void)* style, lexbor_serialize_cb_f cb, void* ctx);
 lxb_status_t lxb_css_at_rule__undef_serialize_name(const(void)* at, lexbor_serialize_cb_f cb, void* ctx);

/* _custom. */

 void* lxb_css_at_rule__custom_create(lxb_css_memory_t* memory);

 void* lxb_css_at_rule__custom_destroy(lxb_css_memory_t* memory, void* style, bool self_destroy);
 lxb_status_t lxb_css_at_rule__custom_serialize(const(void)* style, lexbor_serialize_cb_f cb, void* ctx);
 lxb_status_t lxb_css_at_rule__custom_serialize_name(const(void)* at, lexbor_serialize_cb_f cb, void* ctx);

/* Media. */

 void* lxb_css_at_rule_media_create(lxb_css_memory_t* memory);

 void* lxb_css_at_rule_media_destroy(lxb_css_memory_t* memory, void* style, bool self_destroy);
 lxb_status_t lxb_css_at_rule_media_serialize(const(void)* style, lexbor_serialize_cb_f cb, void* ctx);

/* Namespace. */

 void* lxb_css_at_rule_namespace_create(lxb_css_memory_t* memory);

 void* lxb_css_at_rule_namespace_destroy(lxb_css_memory_t* memory, void* style, bool self_destroy);
 lxb_status_t lxb_css_at_rule_namespace_serialize(const(void)* style, lexbor_serialize_cb_f cb, void* ctx);

/* Font-face. */

 void* lxb_css_at_rule_font_face_create(lxb_css_memory_t* memory);

 void* lxb_css_at_rule_font_face_destroy(lxb_css_memory_t* memory, void* style, bool self_destroy);

 lxb_status_t lxb_css_at_rule_font_face_serialize(const(void)* style, lexbor_serialize_cb_f cb, void* ctx);

// D port: implementation not needed by parserino, not ported.
