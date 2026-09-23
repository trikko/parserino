module parserino.lexbor.css.at_rule.state;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.base;
import parserino.lexbor.css.css;
import parserino.lexbor.css.at_rule;
import parserino.lexbor.css.parser;
// import css/rule (not ported)
// import css/blank (not ported)

extern(C) @nogc nothrow:
__gshared:

// ---- state.h ----
/*
 * Copyright (C) 2021-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
 bool lxb_css_at_rule__undef_prelude(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx);
 lxb_status_t lxb_css_at_rule__undef_prelude_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

 const(lxb_css_syntax_cb_block_t)* lxb_css_at_rule__undef_block(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, void** out_rule);
 bool lxb_css_at_rule__undef_prelude_failed(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx);
 lxb_status_t lxb_css_at_rule__undef_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

 bool lxb_css_at_rule__custom_prelude(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx);
 lxb_status_t lxb_css_at_rule__custom_prelude_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

 const(lxb_css_syntax_cb_block_t)* lxb_css_at_rule__custom_block(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, void** out_rule);
 bool lxb_css_at_rule__custom_prelude_failed(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx);
 lxb_status_t lxb_css_at_rule__custom_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

 bool lxb_css_at_rule_namespace_prelude(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx);
 lxb_status_t lxb_css_at_rule_namespace_prelude_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

 const(lxb_css_syntax_cb_block_t)* lxb_css_at_rule_namespace_block(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, void** out_rule);
 bool lxb_css_at_rule_namespace_prelude_failed(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx);
 lxb_status_t lxb_css_at_rule_namespace_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

 bool lxb_css_at_rule_media_prelude(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx);
 lxb_status_t lxb_css_at_rule_media_prelude_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

 const(lxb_css_syntax_cb_block_t)* lxb_css_at_rule_media_block(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, void** out_rule);
 bool lxb_css_at_rule_media_prelude_failed(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx);
 lxb_status_t lxb_css_at_rule_media_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

 bool lxb_css_at_rule_font_face_prelude(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx);
 lxb_status_t lxb_css_at_rule_font_face_prelude_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

 const(lxb_css_syntax_cb_block_t)* lxb_css_at_rule_font_face_block(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, void** out_rule);
 bool lxb_css_at_rule_font_face_prelude_failed(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx);
 lxb_status_t lxb_css_at_rule_font_face_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

// D port: implementation not needed by parserino, not ported.
