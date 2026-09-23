module parserino.lexbor.css.syntax.syntax;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.syntax.tokenizer;
import parserino.lexbor.core.serialize;
import parserino.lexbor.css.parser;
import parserino.lexbor.core.str;
import parserino.lexbor.core.str_res;
import parserino.lexbor.css.syntax.res;

extern(C) @nogc nothrow:
__gshared:

// ---- syntax.h ----
/*
 * Copyright (C) 2022 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_css_syntax_rule_t = lxb_css_syntax_rule;

alias lxb_css_syntax_state_f = const(lxb_css_syntax_token_t)* function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule);

alias lxb_css_syntax_declaration_end_f = lxb_status_t function(lxb_css_parser_t* parser, void* ctx, bool important, bool failed);

alias lxb_css_syntax_cb_done_f = lxb_status_t function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed);

struct lxb_css_syntax_list_rules_offset_t {
    uintptr_t begin;
    uintptr_t end;
}

struct lxb_css_syntax_at_rule_offset_t {
    uintptr_t name;
    uintptr_t prelude;
    uintptr_t prelude_end;
    uintptr_t block;
    uintptr_t block_end;
}

struct lxb_css_syntax_qualified_offset_t {
    uintptr_t prelude;
    uintptr_t prelude_end;
    uintptr_t block;
    uintptr_t block_end;
}

struct lxb_css_syntax_declarations_offset_t {
    uintptr_t begin;
    uintptr_t end;
    uintptr_t name_begin;
    uintptr_t name_end;
    uintptr_t value_begin;
    uintptr_t before_important;
    uintptr_t value_end;
}

struct lxb_css_syntax_cb_base_t {
    lxb_css_parser_state_f state;
    lxb_css_parser_state_f block;
    lxb_css_parser_state_f failed;
    lxb_css_syntax_cb_done_f end;
}

alias lxb_css_syntax_cb_pipe_t = lxb_css_syntax_cb_base_t;
alias lxb_css_syntax_cb_block_t = lxb_css_syntax_cb_base_t;
alias lxb_css_syntax_cb_function_t = lxb_css_syntax_cb_base_t;
alias lxb_css_syntax_cb_components_t = lxb_css_syntax_cb_base_t;
alias lxb_css_syntax_cb_at_rule_t = lxb_css_syntax_cb_base_t;
alias lxb_css_syntax_cb_qualified_rule_t = lxb_css_syntax_cb_base_t;

struct lxb_css_syntax_cb_declarations_t {
    lxb_css_syntax_cb_base_t cb;
    lxb_css_syntax_declaration_end_f declaration_end;
    const(lxb_css_syntax_cb_at_rule_t)* at_rule;
}

struct lxb_css_syntax_cb_list_rules_t {
    lxb_css_syntax_cb_base_t cb;
    lxb_css_parser_state_f next;
    const(lxb_css_syntax_cb_at_rule_t)* at_rule;
    const(lxb_css_syntax_cb_qualified_rule_t)* qualified_rule;
}

struct lxb_css_syntax_rule {
    lxb_css_syntax_state_f phase;
    lxb_css_parser_state_f state;
    lxb_css_parser_state_f state_back;
    lxb_css_syntax_state_f back;

    union _Cbx {
        const(lxb_css_syntax_cb_base_t)* cb;
        const(lxb_css_syntax_cb_list_rules_t)* list_rules;
        const(lxb_css_syntax_cb_at_rule_t)* at_rule;
        const(lxb_css_syntax_cb_qualified_rule_t)* qualified_rule;
        const(lxb_css_syntax_cb_declarations_t)* declarations;
        const(lxb_css_syntax_cb_components_t)* components;
        const(lxb_css_syntax_cb_function_t)* func;
        const(lxb_css_syntax_cb_block_t)* block;
        const(lxb_css_syntax_cb_pipe_t)* pipe;
        void* user;
    }_Cbx cbx;

    void* context;

    uintptr_t offset;
    size_t deep;
    lxb_css_syntax_token_type_t block_end;
    bool skip_ending;
    bool skip_consume;
    bool important;
    bool failed;
    bool top_level;

    union _U {
        lxb_css_syntax_list_rules_offset_t list_rules;
        lxb_css_syntax_at_rule_offset_t at_rule;
        lxb_css_syntax_qualified_offset_t qualified;
        lxb_css_syntax_declarations_offset_t declarations;
        void* user;
    }_U u;
}







// ---- syntax.c ----
/*
 * Copyright (C) 2018-2023 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
private const(lexbor_str_t) lxb_str_ws = {data: cast(lxb_char_t*) " ".ptr, " ".length};

lxb_status_t lxb_css_syntax_parse_list_rules(lxb_css_parser_t* parser, const(lxb_css_syntax_cb_list_rules_t)* cb, const(lxb_char_t)* data, size_t length, void* ctx, bool top_level)
{
    lxb_status_t status = void;
    lxb_css_syntax_rule_t* rule = void;

    if (lxb_css_parser_is_running(parser)) {
        parser.status = LXB_STATUS_ERROR_WRONG_STAGE;
        return parser.status;
    }

    lxb_css_parser_clean(parser);

    lxb_css_parser_buffer_set(parser, data, length);

    rule = lxb_css_syntax_parser_list_rules_push(parser, null, null, cb,
                                                 ctx, top_level,
                                                 LXB_CSS_SYNTAX_TOKEN_UNDEF);
    if (rule == null) {
        status = parser.status;
        goto end;
    }

    parser.tkz.with_comment = false;
    parser.stage = LXB_CSS_PARSER_RUN;

    status = lxb_css_syntax_parser_run(parser);
    if (status != LXB_STATUS_OK) {
        /* Destroy StyleSheet. */
    }

end:

    parser.stage = LXB_CSS_PARSER_END;

    return status;
}

lxb_status_t lxb_css_syntax_stack_expand(lxb_css_parser_t* parser, size_t count)
{
    size_t length = void, cur_len = void, size = void;
    lxb_css_syntax_rule_t* p = void;

    if ((parser.rules + count) >= parser.rules_end) {
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
    }

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
                do { (status) = cb(cast(lxb_char_t*) (lxb_str_ws.data), (lxb_str_ws.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false)
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
                        do { (status) = cb(cast(lxb_char_t*) (lxb_str_ws.data), (lxb_str_ws.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false)
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
