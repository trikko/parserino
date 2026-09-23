module parserino.lexbor.css.syntax.syntax;

import parserino.lexbor.css.syntax.res;
import parserino.lexbor.core.str_res;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.syntax.tokenizer;
import parserino.lexbor.core.serialize;
import parserino.lexbor.css.parser;
import parserino.lexbor.core.str;

extern(C) @nogc nothrow:
__gshared:

// ---- syntax.h ----
/*
 * Copyright (C) 2022-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_css_syntax_rule_t = lxb_css_syntax_rule;

alias lxb_css_syntax_state_f = const(lxb_css_syntax_token_t)* function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule);

alias lxb_css_syntax_cb_base_t = lxb_css_syntax_cb_base;
alias lxb_css_syntax_cb_list_rules_t = lxb_css_syntax_cb_list_rules;
alias lxb_css_syntax_cb_at_rule_t = lxb_css_syntax_cb_at_rule;
alias lxb_css_syntax_cb_qualified_rule_t = lxb_css_syntax_cb_qualified_rule;
alias lxb_css_syntax_cb_block_t = lxb_css_syntax_cb_block;
alias lxb_css_syntax_cb_declarations_t = lxb_css_syntax_cb_declarations;
alias lxb_css_syntax_cb_function_t = lxb_css_syntax_cb_function;
alias lxb_css_syntax_cb_components_t = lxb_css_syntax_cb_components;
alias lxb_css_syntax_cb_pipe_t = lxb_css_syntax_cb_pipe;

alias lxb_css_syntax_declaration_offset_t = lxb_css_syntax_declaration_offset;

alias lxb_css_syntax_cb_done_f = lxb_status_t function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

alias lxb_css_syntax_begin_at_rule_f = const(lxb_css_syntax_cb_at_rule_t)* function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, void** out_rule);

alias lxb_css_syntax_begin_qualified_rule_f = const(lxb_css_syntax_cb_qualified_rule_t)* function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, void** out_rule);

alias lxb_css_syntax_begin_block_f = const(lxb_css_syntax_cb_block_t)* function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, void** out_rule);

alias lxb_css_syntax_begin_declarations_f = const(lxb_css_syntax_cb_declarations_t)* function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, void** out_rule);
alias lxb_css_syntax_declaration_name_f = lxb_css_parser_state_f function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, void** out_rule);
alias lxb_css_syntax_declaration_end_f = lxb_status_t function(lxb_css_parser_t* parser, void* declaration, void* ctx, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_declaration_offset_t* offset, bool important, bool failed);

struct lxb_css_syntax_cb_base {
    lxb_css_parser_state_f failed;
    lxb_css_syntax_cb_done_f end;
}

struct lxb_css_syntax_cb_list_rules {
    lxb_css_syntax_cb_base_t cb;
    lxb_css_parser_state_f next;
    lxb_css_syntax_begin_at_rule_f at_rule;
    lxb_css_syntax_begin_qualified_rule_f qualified_rule;
}

struct lxb_css_syntax_cb_at_rule {
    lxb_css_syntax_cb_base_t cb;
    lxb_css_parser_state_f prelude;
    lxb_css_syntax_cb_done_f prelude_end;
    lxb_css_syntax_begin_block_f block;
}

struct lxb_css_syntax_cb_qualified_rule {
    lxb_css_syntax_cb_base_t cb;
    lxb_css_parser_state_f prelude;
    lxb_css_syntax_cb_done_f prelude_end;
    lxb_css_syntax_begin_block_f block;
}

struct lxb_css_syntax_cb_block {
    lxb_css_syntax_cb_base_t cb;
    lxb_css_parser_state_f next;
    lxb_css_syntax_begin_at_rule_f at_rule;
    lxb_css_syntax_begin_declarations_f declarations;
    lxb_css_syntax_begin_qualified_rule_f qualified_rule;
}

struct lxb_css_syntax_cb_declarations {
    lxb_css_syntax_cb_base_t cb;
    lxb_css_syntax_declaration_name_f name;
    lxb_css_syntax_declaration_end_f end;
}

struct lxb_css_syntax_cb_function {
    lxb_css_syntax_cb_base_t cb;
    lxb_css_parser_state_f value;
}

struct lxb_css_syntax_cb_components {
    lxb_css_syntax_cb_base_t cb;
    lxb_css_parser_state_f prelude;
}

struct lxb_css_syntax_cb_pipe {
    lxb_css_syntax_cb_base_t cb;
    lxb_css_parser_state_f prelude;
}

struct lxb_css_syntax_declaration_offset {
    size_t value_begin;
    size_t value_end;
    size_t important_begin;
    size_t important_end;
    size_t end;
}

struct lxb_css_syntax_rule {
    lxb_css_syntax_state_f phase;
    lxb_css_parser_state_f state;

    /*
     * This callback will be called before rule->state is called.
     * Exclusively from the lxb_css_parser_run(...).
     */
    lxb_css_syntax_state_f back;
    lxb_css_parser_state_f back_state;
    void* context;
    void* context_old;
    void* returned;

    union _Cbx {
        const(lxb_css_syntax_cb_base_t)* cb;
        const(lxb_css_syntax_cb_list_rules_t)* list_rules;
        const(lxb_css_syntax_cb_at_rule_t)* at_rule;
        const(lxb_css_syntax_cb_qualified_rule_t)* qualified_rule;
        const(lxb_css_syntax_cb_components_t)* components;
        const(lxb_css_syntax_cb_declarations_t)* declarations;
        const(lxb_css_syntax_cb_function_t)* func;
        const(lxb_css_syntax_cb_block_t)* block;
        const(lxb_css_syntax_cb_pipe_t)* pipe;
        void* user;
    }_Cbx cbx;

    size_t offset;
    size_t deep;
    size_t begin;
    lxb_css_syntax_token_type_t block_end;
    bool nested;
    bool skip_consume;
    bool important;
    bool failed;
}

 lxb_css_rule_list_t* lxb_css_syntax_parse_list_rules(lxb_css_parser_t* parser, const(lxb_css_syntax_cb_list_rules_t)* cb, const(lxb_char_t)* data, size_t length);

 lxb_css_rule_declaration_list_t* lxb_css_syntax_parse_declarations(lxb_css_parser_t* parser, const(lxb_css_syntax_cb_declarations_t)* cb, const(lxb_char_t)* data, size_t length);













// ---- syntax.c ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

    // D port (C extern, imported instead): extern const(lxb_char_t)[4] lexbor_str_res_ansi_replacement_character;
    // D port (C extern, imported instead): extern const(lxb_char_t)[256] lexbor_str_res_map_hex;
    // D port (C extern, imported instead): extern const(lxb_char_t)[17] lexbor_str_res_map_hex_to_char_lowercase;
    // D port (C extern, imported instead): extern const(char)*[257] lexbor_str_res_char_to_two_hex_value_lowercase;
    // D port (C extern, imported instead): extern const(lxb_char_t)[256] lxb_css_syntax_res_name_map;

private const(lexbor_str_t) lxb_css_syntax_str_ws = {data: cast(lxb_char_t*) " ".ptr, " ".length};

/* parserino: lxb_css_syntax_parse_list_rules() removed (needs CSS rules) */

/* parserino: lxb_css_syntax_parse_declarations() removed (needs CSS rules) */

lxb_css_syntax_rule_t* lxb_css_syntax_consume_list_rules(lxb_css_parser_t* parser, const(lxb_css_syntax_cb_list_rules_t)* list_rules, lxb_css_parser_state_f back, void* ctx, lxb_css_syntax_token_type_t stop)
{
    return lxb_css_syntax_parser_list_rules_push(parser, list_rules, back,
                                                 ctx, stop);
}

lxb_css_syntax_rule_t* lxb_css_syntax_consume_at_rule(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, const(lxb_css_syntax_cb_at_rule_t)* at_rule, lxb_css_parser_state_f back, void* ctx, lxb_css_syntax_token_type_t stop)
{
    if (token.type != LXB_CSS_SYNTAX_TOKEN_AT_KEYWORD) {
        return null;
    }

    if (parser.rules > parser.rules_begin && parser.rules.deep != 0
        && parser.types_pos[-1] == LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS)
    {
        parser.types_pos -= 1;
        parser.rules.deep -= 1;
    }

    lxb_css_syntax_parser_consume(parser);

    return lxb_css_syntax_parser_at_rule_push(parser, at_rule, back, ctx,
                                              stop, false);
}

lxb_css_syntax_rule_t* lxb_css_syntax_consume_qualified_rule(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, const(lxb_css_syntax_cb_qualified_rule_t)* qualified, lxb_css_parser_state_f back, void* ctx, lxb_css_syntax_token_type_t stop)
{
    lxb_css_syntax_token_type_t type = void;

    if (parser.rules > parser.rules_begin && parser.rules.deep != 0) {
        switch (token.type) {
            case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
                type = LXB_CSS_SYNTAX_TOKEN_RS_BRACKET;
                break;

            case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
            case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
                type = LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS;
                break;

            case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
                type = LXB_CSS_SYNTAX_TOKEN_RC_BRACKET;
                break;

            default:
                type = LXB_CSS_SYNTAX_TOKEN_UNDEF;
                break;
        }

        if (parser.types_pos[-1] == type) {
            parser.types_pos -= 1;
            parser.rules.deep -= 1;
        }
    }

    return lxb_css_syntax_parser_qualified_push(parser, qualified, back,
                                                ctx, stop, false);
}

lxb_css_syntax_rule_t* lxb_css_syntax_consume_block(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, const(lxb_css_syntax_cb_block_t)* block, lxb_css_parser_state_f back, void* ctx)
{
    if (token.type != LXB_CSS_SYNTAX_TOKEN_LC_BRACKET) {
        return null;
    }

    if (parser.rules > parser.rules_begin && parser.rules.deep != 0
        && parser.types_pos[-1] == LXB_CSS_SYNTAX_TOKEN_RC_BRACKET)
    {
        parser.types_pos -= 1;
        parser.rules.deep -= 1;
    }

    lxb_css_syntax_parser_consume(parser);

    return lxb_css_syntax_parser_block_push(parser, block, back, ctx);
}

lxb_css_syntax_rule_t* lxb_css_syntax_consume_declarations(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, const(lxb_css_syntax_cb_declarations_t)* declr, lxb_css_parser_state_f back, void* ctx, lxb_css_syntax_token_type_t stop)
{
    lxb_css_syntax_token_type_t type = void;

    if (parser.rules > parser.rules_begin && parser.rules.deep != 0) {
        switch (token.type) {
            case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
                type = LXB_CSS_SYNTAX_TOKEN_RS_BRACKET;
                break;

            case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
            case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
                type = LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS;
                break;

            case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
                type = LXB_CSS_SYNTAX_TOKEN_RC_BRACKET;
                break;

            default:
                type = LXB_CSS_SYNTAX_TOKEN_UNDEF;
                break;
        }

        if (parser.types_pos[-1] == type) {
            parser.types_pos -= 1;
            parser.rules.deep -= 1;
        }
    }

    return lxb_css_syntax_parser_declarations_push(parser, declr, back,
                                                   ctx, stop, true, false);
}

lxb_css_syntax_rule_t* lxb_css_syntax_consume_components(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, const(lxb_css_syntax_cb_components_t)* comp, lxb_css_parser_state_f back, void* ctx, lxb_css_syntax_token_type_t stop)
{
    lxb_css_syntax_token_type_t type = void;

    if (parser.rules > parser.rules_begin && parser.rules.deep != 0) {
        switch (token.type) {
            case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
                type = LXB_CSS_SYNTAX_TOKEN_RS_BRACKET;
                break;

            case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
            case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
                type = LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS;
                break;

            case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
                type = LXB_CSS_SYNTAX_TOKEN_RC_BRACKET;
                break;

            default:
                type = LXB_CSS_SYNTAX_TOKEN_UNDEF;
                break;
        }

        if (parser.types_pos[-1] == type) {
            parser.types_pos -= 1;
            parser.rules.deep -= 1;
        }
    }

    return lxb_css_syntax_parser_components_push(parser, comp, back, ctx, stop);
}

lxb_css_syntax_rule_t* lxb_css_syntax_consume_function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, const(lxb_css_syntax_cb_function_t)* func, lxb_css_parser_state_f back, void* ctx)
{
    if (token.type != LXB_CSS_SYNTAX_TOKEN_FUNCTION) {
        return null;
    }

    if (parser.rules > parser.rules_begin && parser.rules.deep != 0
        && parser.types_pos[-1] == LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS)
    {
        parser.types_pos -= 1;
        parser.rules.deep -= 1;
    }

    lxb_css_syntax_parser_consume(parser);

    return lxb_css_syntax_parser_function_push(parser, func, back, ctx);
}

lxb_status_t lxb_css_syntax_stack_expand(lxb_css_parser_t* parser, size_t count)
{
    size_t length = void, cur_len = void, size = void;
    lxb_css_syntax_rule_t* p = void;

    cur_len = parser.rules - parser.rules_begin;

    length = cur_len + count + 1024;
    size = length * lxb_css_syntax_rule_t.sizeof;

    p = cast(lxb_css_syntax_rule*) lexbor_realloc(parser.rules_begin, size);
    if (p == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    parser.rules_begin = p;
    parser.rules_end = p + length;
    parser.rules = p + cur_len;

    return LXB_STATUS_OK;
}

void lxb_css_syntax_codepoint_to_ascii(lxb_css_syntax_tokenizer_t* tkz, lxb_codepoint_t cp)
{
    /*
     * Zero, or is for a surrogate, or is greater than
     * the maximum allowed code point (tkz->num > 0x10FFFF).
     */
    if (cp == 0 || cp > 0x10FFFF || (cp >= 0xD800 && cp <= 0xDFFF)) {
        memcpy(tkz.pos, lexbor_str_res_ansi_replacement_character.ptr, 3);

        tkz.pos += 3;
        *tkz.pos = '\0';

        return;
    }

    lxb_char_t* data = tkz.pos;

    if (cp <= 0x0000007F) {
        /* 0xxxxxxx */
        data[0] = cast(lxb_char_t) cp;

        tkz.pos += 1;
    }
    else if (cp <= 0x000007FF) {
        /* 110xxxxx 10xxxxxx */
        data[0] = cast(char)(0xC0 | (cp >> 6 ));
        data[1] = cast(char)(0x80 | (cp & 0x3F));

        tkz.pos += 2;
    }
    else if (cp <= 0x0000FFFF) {
        /* 1110xxxx 10xxxxxx 10xxxxxx */
        data[0] = cast(char)(0xE0 | ((cp >> 12)));
        data[1] = cast(char)(0x80 | ((cp >> 6 ) & 0x3F));
        data[2] = cast(char)(0x80 | ( cp & 0x3F));

        tkz.pos += 3;
    }
    else if (cp <= 0x001FFFFF) {
        /* 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx */
        data[0] = cast(char)(0xF0 | ( cp >> 18));
        data[1] = cast(char)(0x80 | ((cp >> 12) & 0x3F));
        data[2] = cast(char)(0x80 | ((cp >> 6 ) & 0x3F));
        data[3] = cast(char)(0x80 | ( cp & 0x3F));

        tkz.pos += 4;
    }

    *tkz.pos = '\0';
}

lxb_status_t lxb_css_syntax_ident_serialize(const(lxb_char_t)* data, size_t length, lexbor_serialize_cb_f cb, void* ctx)
{
    lxb_char_t ch = void;
    lxb_status_t status = void;
    const(char)** hex_map = void;
    const(lxb_char_t)* p = data, end = void;

    static const(lexbor_str_t) str_s = {data: cast(lxb_char_t*) "\\".ptr, "\\".length};

    end = data + length;
    hex_map = lexbor_str_res_char_to_two_hex_value_lowercase.ptr;

    while (p < end) {
        ch = *p;

        if (lxb_css_syntax_res_name_map[ch] == 0x00) {
            do { (status) = cb(cast(lxb_char_t*) (data), (p - data), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
            do { (status) = cb(cast(lxb_char_t*) (str_s.data), (str_s.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
            do { (status) = cb(cast(lxb_char_t*) (hex_map[ch]), (2), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

            data = ++p;

            if (p < end && lexbor_str_res_map_hex[*p] != 0xff) {
                do { (status) = cb(cast(lxb_char_t*) (lxb_css_syntax_str_ws.data), (lxb_css_syntax_str_ws.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false)

                                                   ;
            }

            continue;
        }

        p++;
    }

    if (data < p) {
        do { (status) = cb(cast(lxb_char_t*) (data), (p - data), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    }

    return LXB_STATUS_OK;
}

lxb_status_t lxb_css_syntax_string_serialize(const(lxb_char_t)* data, size_t length, lexbor_serialize_cb_f cb, void* ctx)
{
    lxb_char_t ch = void;
    lxb_status_t status = void;
    const(char)** hex_map = void;
    const(lxb_char_t)* p = void, end = void;

    static const(lexbor_str_t) str_s = {data: cast(lxb_char_t*) "\\".ptr, "\\".length};
    static const(lexbor_str_t) str_dk = {data: cast(lxb_char_t*) "\"".ptr, "\"".length};
    static const(lexbor_str_t) str_ds = {data: cast(lxb_char_t*) "\\\\".ptr, "\\\\".length};
    static const(lexbor_str_t) str_dks = {data: cast(lxb_char_t*) "\\\"".ptr, "\\\"".length};

    p = data;
    end = data + length;
    hex_map = lexbor_str_res_char_to_two_hex_value_lowercase.ptr;

    do { (status) = cb(cast(lxb_char_t*) (str_dk.data), (str_dk.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    while (p < end) {
        ch = *p;

        if (lxb_css_syntax_res_name_map[ch] == 0x00) {
            switch (ch) {
                case '\\':
                    do { (status) = cb(cast(lxb_char_t*) (data), (p - data), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
                    do { (status) = cb(cast(lxb_char_t*) (str_ds.data), (str_ds.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false)
                                                       ;
                    break;

                case '"':
                    do { (status) = cb(cast(lxb_char_t*) (data), (p - data), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
                    do { (status) = cb(cast(lxb_char_t*) (str_dks.data), (str_dks.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false)
                                                       ;
                    break;

                case '\n':
                case '\t':
                case '\r':
                    do { (status) = cb(cast(lxb_char_t*) (data), (p - data), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
                    do { (status) = cb(cast(lxb_char_t*) (str_s.data), (str_s.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false)
                                                       ;
                    do { (status) = cb(cast(lxb_char_t*) (hex_map[ch]), (2), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

                    p++;

                    if (p < end && lexbor_str_res_map_hex[*p] != 0xff) {
                        do { (status) = cb(cast(lxb_char_t*) (lxb_css_syntax_str_ws.data), (lxb_css_syntax_str_ws.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false)

                                                           ;
                    }

                    data = p;
                    continue;

                default:
                    p++;
                    continue;
            }

            data = ++p;
            continue;
        }

        p++;
    }

    if (data < p) {
        do { (status) = cb(cast(lxb_char_t*) (data), (p - data), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    }

    do { (status) = cb(cast(lxb_char_t*) (str_dk.data), (str_dk.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    return LXB_STATUS_OK;
}

lxb_status_t lxb_css_syntax_ident_or_string_serialize(const(lxb_char_t)* data, size_t length, lexbor_serialize_cb_f cb, void* ctx)
{
    const(lxb_char_t)* p = void, end = void;

    p = data;
    end = data + length;

    while (p < end) {
        if (lxb_css_syntax_res_name_map[*p++] == 0x00) {
            return lxb_css_syntax_string_serialize(data, length, cb, ctx);
        }
    }

    return cb(data, length, ctx);
}
