module parserino.lexbor.css.syntax.token;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.str;
public import parserino.lexbor.css.log;
public import parserino.lexbor.css.syntax.base;
import parserino.lexbor.core.shs;
import parserino.lexbor.core.conv;
import parserino.lexbor.core.serialize;
import parserino.lexbor.core.print;
import parserino.lexbor.css.parser;
import parserino.lexbor.css.syntax.state;
import parserino.lexbor.css.syntax.state_res;
import parserino.lexbor.css.syntax.token_res;
import parserino.lexbor.core.str_res;

extern(C) @nogc nothrow:
__gshared:

// ---- token.h ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_css_syntax_token_data_t = lxb_css_syntax_token_data;

alias lxb_css_syntax_token_data_cb_f = const(lxb_char_t)* function(const(lxb_char_t)* begin, const(lxb_char_t)* end, lexbor_str_t* str, lexbor_mraw_t* mraw, lxb_css_syntax_token_data_t* td);

alias lxb_css_syntax_token_cb_f = lxb_status_t function(const(lxb_char_t)* data, size_t len, void* ctx);

struct lxb_css_syntax_token_data {
    lxb_css_syntax_token_data_cb_f cb;
    lxb_status_t status;
    int count;
    uint num;
    bool is_last;
}

enum lxb_css_syntax_token_type_t {
    LXB_CSS_SYNTAX_TOKEN_UNDEF = 0x00,

    /* String tokens. */
    LXB_CSS_SYNTAX_TOKEN_IDENT,
    LXB_CSS_SYNTAX_TOKEN_FUNCTION,
    LXB_CSS_SYNTAX_TOKEN_AT_KEYWORD,
    LXB_CSS_SYNTAX_TOKEN_HASH,
    LXB_CSS_SYNTAX_TOKEN_STRING,
    LXB_CSS_SYNTAX_TOKEN_BAD_STRING,
    LXB_CSS_SYNTAX_TOKEN_URL,
    LXB_CSS_SYNTAX_TOKEN_BAD_URL,
    LXB_CSS_SYNTAX_TOKEN_COMMENT, /* not in specification */
    LXB_CSS_SYNTAX_TOKEN_WHITESPACE,

    /* Has a string. */
    LXB_CSS_SYNTAX_TOKEN_DIMENSION,

    /* Other tokens. */
    LXB_CSS_SYNTAX_TOKEN_DELIM,
    LXB_CSS_SYNTAX_TOKEN_UNICODE_RANGE,
    LXB_CSS_SYNTAX_TOKEN_NUMBER,
    LXB_CSS_SYNTAX_TOKEN_PERCENTAGE,
    LXB_CSS_SYNTAX_TOKEN_CDO,
    LXB_CSS_SYNTAX_TOKEN_CDC,
    LXB_CSS_SYNTAX_TOKEN_COLON,
    LXB_CSS_SYNTAX_TOKEN_SEMICOLON,
    LXB_CSS_SYNTAX_TOKEN_COMMA,
    LXB_CSS_SYNTAX_TOKEN_LS_BRACKET, /* U+005B LEFT SQUARE BRACKET ([) */
    LXB_CSS_SYNTAX_TOKEN_RS_BRACKET, /* U+005D RIGHT SQUARE BRACKET (]) */
    LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS, /* U+0028 LEFT PARENTHESIS (() */
    LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS, /* U+0029 RIGHT PARENTHESIS ()) */
    LXB_CSS_SYNTAX_TOKEN_LC_BRACKET, /* U+007B LEFT CURLY BRACKET ({) */
    LXB_CSS_SYNTAX_TOKEN_RC_BRACKET, /* U+007D RIGHT CURLY BRACKET (}) */
    LXB_CSS_SYNTAX_TOKEN__EOF,
    LXB_CSS_SYNTAX_TOKEN__TERMINATED, /* Deprecated, use LXB_CSS_SYNTAX_TOKEN__END. */
    LXB_CSS_SYNTAX_TOKEN__END = LXB_CSS_SYNTAX_TOKEN__TERMINATED,
    LXB_CSS_SYNTAX_TOKEN__LAST_ENTRY
}
alias LXB_CSS_SYNTAX_TOKEN_UNDEF = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_UNDEF;
alias LXB_CSS_SYNTAX_TOKEN_IDENT = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_IDENT;
alias LXB_CSS_SYNTAX_TOKEN_FUNCTION = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_FUNCTION;
alias LXB_CSS_SYNTAX_TOKEN_AT_KEYWORD = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_AT_KEYWORD;
alias LXB_CSS_SYNTAX_TOKEN_HASH = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_HASH;
alias LXB_CSS_SYNTAX_TOKEN_STRING = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_STRING;
alias LXB_CSS_SYNTAX_TOKEN_BAD_STRING = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_BAD_STRING;
alias LXB_CSS_SYNTAX_TOKEN_URL = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_URL;
alias LXB_CSS_SYNTAX_TOKEN_BAD_URL = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_BAD_URL;
alias LXB_CSS_SYNTAX_TOKEN_COMMENT = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_COMMENT;
alias LXB_CSS_SYNTAX_TOKEN_WHITESPACE = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_WHITESPACE;
alias LXB_CSS_SYNTAX_TOKEN_DIMENSION = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_DIMENSION;
alias LXB_CSS_SYNTAX_TOKEN_DELIM = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_DELIM;
alias LXB_CSS_SYNTAX_TOKEN_UNICODE_RANGE = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_UNICODE_RANGE;
alias LXB_CSS_SYNTAX_TOKEN_NUMBER = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_NUMBER;
alias LXB_CSS_SYNTAX_TOKEN_PERCENTAGE = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_PERCENTAGE;
alias LXB_CSS_SYNTAX_TOKEN_CDO = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_CDO;
alias LXB_CSS_SYNTAX_TOKEN_CDC = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_CDC;
alias LXB_CSS_SYNTAX_TOKEN_COLON = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_COLON;
alias LXB_CSS_SYNTAX_TOKEN_SEMICOLON = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_SEMICOLON;
alias LXB_CSS_SYNTAX_TOKEN_COMMA = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_COMMA;
alias LXB_CSS_SYNTAX_TOKEN_LS_BRACKET = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_LS_BRACKET;
alias LXB_CSS_SYNTAX_TOKEN_RS_BRACKET = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_RS_BRACKET;
alias LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS;
alias LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS;
alias LXB_CSS_SYNTAX_TOKEN_LC_BRACKET = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_LC_BRACKET;
alias LXB_CSS_SYNTAX_TOKEN_RC_BRACKET = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN_RC_BRACKET;
alias LXB_CSS_SYNTAX_TOKEN__EOF = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN__EOF;
alias LXB_CSS_SYNTAX_TOKEN__TERMINATED = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN__TERMINATED;
alias LXB_CSS_SYNTAX_TOKEN__END = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN__END;
alias LXB_CSS_SYNTAX_TOKEN__LAST_ENTRY = lxb_css_syntax_token_type_t.LXB_CSS_SYNTAX_TOKEN__LAST_ENTRY;


struct lxb_css_syntax_token_base_t {
    const(lxb_char_t)* begin;
    size_t length;

    uintptr_t user_id;
}

struct lxb_css_syntax_token_number_t {
    lxb_css_syntax_token_base_t base;

    double num = 0;
    bool is_float;
    bool have_sign;
}

struct lxb_css_syntax_token_string_t {
    lxb_css_syntax_token_base_t base;

    const(lxb_char_t)* data;
    size_t length;
}

struct lxb_css_syntax_token_dimension_t {
    lxb_css_syntax_token_number_t num;
    lxb_css_syntax_token_string_t str;
}

struct lxb_css_syntax_token_delim_t {
    lxb_css_syntax_token_base_t base;
    lxb_codepoint_t character;
}

struct lxb_css_syntax_token_unicode_range_t {
    lxb_css_syntax_token_base_t base;
    lxb_codepoint_t start;
    lxb_codepoint_t end;
}

alias lxb_css_syntax_token_ident_t = lxb_css_syntax_token_string_t;
alias lxb_css_syntax_token_function_t = lxb_css_syntax_token_string_t;
alias lxb_css_syntax_token_at_keyword_t = lxb_css_syntax_token_string_t;
alias lxb_css_syntax_token_hash_t = lxb_css_syntax_token_string_t;
alias lxb_css_syntax_token_bad_string_t = lxb_css_syntax_token_string_t;
alias lxb_css_syntax_token_url_t = lxb_css_syntax_token_string_t;
alias lxb_css_syntax_token_bad_url_t = lxb_css_syntax_token_string_t;
alias lxb_css_syntax_token_percentage_t = lxb_css_syntax_token_number_t;
alias lxb_css_syntax_token_whitespace_t = lxb_css_syntax_token_string_t;
alias lxb_css_syntax_token_cdo_t = lxb_css_syntax_token_base_t;
alias lxb_css_syntax_token_cdc_t = lxb_css_syntax_token_base_t;
alias lxb_css_syntax_token_colon_t = lxb_css_syntax_token_base_t;
alias lxb_css_syntax_token_semicolon_t = lxb_css_syntax_token_base_t;
alias lxb_css_syntax_token_comma_t = lxb_css_syntax_token_base_t;
alias lxb_css_syntax_token_ls_bracket_t = lxb_css_syntax_token_base_t;
alias lxb_css_syntax_token_rs_bracket_t = lxb_css_syntax_token_base_t;
alias lxb_css_syntax_token_l_parenthesis_t = lxb_css_syntax_token_base_t;
alias lxb_css_syntax_token_r_parenthesis_t = lxb_css_syntax_token_base_t;
alias lxb_css_syntax_token_lc_bracket_t = lxb_css_syntax_token_base_t;
alias lxb_css_syntax_token_rc_bracket_t = lxb_css_syntax_token_base_t;
alias lxb_css_syntax_token_comment_t = lxb_css_syntax_token_string_t;
alias lxb_css_syntax_token_terminated_t = lxb_css_syntax_token_base_t;

struct lxb_css_syntax_token_ {
    union lxb_css_syntax_token_u {
        lxb_css_syntax_token_base_t base;
        lxb_css_syntax_token_comment_t comment;
        lxb_css_syntax_token_number_t number;
        lxb_css_syntax_token_dimension_t dimension;
        lxb_css_syntax_token_percentage_t percentage;
        lxb_css_syntax_token_hash_t hash;
        lxb_css_syntax_token_string_t string;
        lxb_css_syntax_token_bad_string_t bad_string;
        lxb_css_syntax_token_delim_t delim;
        lxb_css_syntax_token_unicode_range_t unicode_range;
        lxb_css_syntax_token_l_parenthesis_t lparenthesis;
        lxb_css_syntax_token_r_parenthesis_t rparenthesis;
        lxb_css_syntax_token_cdc_t cdc;
        lxb_css_syntax_token_function_t function_;
        lxb_css_syntax_token_ident_t ident;
        lxb_css_syntax_token_url_t url;
        lxb_css_syntax_token_bad_url_t bad_url;
        lxb_css_syntax_token_at_keyword_t at_keyword;
        lxb_css_syntax_token_whitespace_t whitespace;
        lxb_css_syntax_token_terminated_t terminated;
    }lxb_css_syntax_token_u types;

    lxb_css_syntax_token_type_t type;
    uintptr_t offset;
    bool cloned;

    lxb_css_syntax_token_t* next;
}














/*
 * Inline functions
 */
 lxb_css_syntax_token_t* lxb_css_syntax_token_create(lexbor_dobject_t* dobj)
{
    return cast(lxb_css_syntax_token_t*) lexbor_dobject_calloc(dobj);
}

 void lxb_css_syntax_token_clean(lxb_css_syntax_token_t* token)
{
    memset(token, 0, lxb_css_syntax_token_t.sizeof);
}

 lxb_css_syntax_token_t* lxb_css_syntax_token_destroy(lxb_css_syntax_token_t* token, lexbor_dobject_t* dobj)
{
    return cast(lxb_css_syntax_token_t*) lexbor_dobject_free(dobj, token);
}

 const(lxb_char_t)* lxb_css_syntax_token_type_name(const(lxb_css_syntax_token_t)* token)
{
    return lxb_css_syntax_token_type_name_by_id(token.type);
}

 lxb_css_syntax_token_type_t lxb_css_syntax_token_type(const(lxb_css_syntax_token_t)* token)
{
    return token.type;
}

 lxb_css_syntax_token_t* lxb_css_syntax_token_wo_ws(lxb_css_syntax_tokenizer_t* tkz)
{
    lxb_css_syntax_token_t* token = void;

    token = lxb_css_syntax_token(tkz);
    if (token == null) {
        return null;
    }

    if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
        lxb_css_syntax_token_consume(tkz);
        token = lxb_css_syntax_token(tkz);
    }

    return token;
}

/*
 * No inline functions for ABI.
 */





// ---- token.c ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
lxb_css_syntax_token_t* lxb_css_syntax_tokenizer_token(lxb_css_syntax_tokenizer_t* tkz);

struct lxb_css_syntax_token_ctx_t {
    lexbor_str_t* str;
    lexbor_mraw_t* mraw;
}





lxb_css_syntax_token_t* lxb_css_syntax_token(lxb_css_syntax_tokenizer_t* tkz)
{
    if (tkz.first != null) {
        return tkz.first;
    }

    return lxb_css_syntax_tokenizer_token(tkz);
}

lxb_css_syntax_token_t* lxb_css_syntax_token_next(lxb_css_syntax_tokenizer_t* tkz)
{
    return lxb_css_syntax_tokenizer_token(tkz);
}

void lxb_css_syntax_token_consume(lxb_css_syntax_tokenizer_t* tkz)
{
    lxb_css_syntax_token_t* token = void;

    if (tkz.first) {
        token = tkz.first;
        tkz.first = token.next;

        if (tkz.last == token) {
            tkz.last = null;
        }

        lxb_css_syntax_token_string_free(tkz, token);
        lexbor_dobject_free(tkz.tokens, token);
    }
}

void lxb_css_syntax_token_consume_n(lxb_css_syntax_tokenizer_t* tkz, uint count)
{
    while (count != 0) {
        count--;
        lxb_css_syntax_token_consume(tkz);
    }
}

lxb_status_t lxb_css_syntax_token_string_dup(lxb_css_syntax_token_string_t* token, lexbor_str_t* str, lexbor_mraw_t* mraw)
{
    size_t length = void;

    length = token.length + 1;

    if (length > str.length) {
        if (str.data == null) {
            str.data = cast(ubyte*) lexbor_mraw_alloc(mraw, length);
            if (str.data == null) {
                return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            }

            str.length = 0;
        }
        else {
            if (lexbor_str_realloc(str, mraw, length) == null) {
                return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            }
        }
    }

    /* + 1 = '\0' */
    memcpy(str.data, token.data, length);

    str.length = token.length;

    return LXB_STATUS_OK;
}

lxb_status_t lxb_css_syntax_token_string_make(lxb_css_syntax_tokenizer_t* tkz, lxb_css_syntax_token_t* token)
{
    lxb_char_t* data = void;
    lxb_css_syntax_token_string_t* token_string = void;

    if (token.type >= LXB_CSS_SYNTAX_TOKEN_IDENT
        && token.type <= LXB_CSS_SYNTAX_TOKEN_WHITESPACE)
    {
        token_string = (cast(lxb_css_syntax_token_string_t*) (token));
        goto copy;
    }
    else if (token.type == LXB_CSS_SYNTAX_TOKEN_DIMENSION) {
        token_string = (&(cast(lxb_css_syntax_token_dimension_t*) (token)).str);
        goto copy;
    }

    return LXB_STATUS_OK;

copy:

    data = cast(ubyte*) lexbor_mraw_alloc(tkz.mraw, token_string.length + 1);
    if (data == null) {
        tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        return tkz.status;
    }

    /* + 1 = '\0' */
    memcpy(data, token_string.data, token_string.length + 1);

    token_string.data = data;
    token.cloned = true;

    return LXB_STATUS_OK;
}

void lxb_css_syntax_token_string_free(lxb_css_syntax_tokenizer_t* tkz, lxb_css_syntax_token_t* token)
{
    lxb_css_syntax_token_string_t* token_string = void;

    if (token.cloned) {
        if (token.type == LXB_CSS_SYNTAX_TOKEN_DIMENSION) {
            token_string = (&(cast(lxb_css_syntax_token_dimension_t*) (token)).str);
        }
        else {
            token_string = (cast(lxb_css_syntax_token_string_t*) (token));
        }

        lexbor_mraw_free(tkz.mraw, cast(lxb_char_t*) token_string.data);
    }
}

const(lxb_char_t)* lxb_css_syntax_token_type_name_by_id(lxb_css_syntax_token_type_t type)
{
    switch (type) {
        case LXB_CSS_SYNTAX_TOKEN_IDENT:
            return cast(lxb_char_t*) "ident";
        case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
            return cast(lxb_char_t*) "function";
        case LXB_CSS_SYNTAX_TOKEN_AT_KEYWORD:
            return cast(lxb_char_t*) "at-keyword";
        case LXB_CSS_SYNTAX_TOKEN_HASH:
            return cast(lxb_char_t*) "hash";
        case LXB_CSS_SYNTAX_TOKEN_STRING:
            return cast(lxb_char_t*) "string";
        case LXB_CSS_SYNTAX_TOKEN_BAD_STRING:
            return cast(lxb_char_t*) "bad-string";
        case LXB_CSS_SYNTAX_TOKEN_URL:
            return cast(lxb_char_t*) "url";
        case LXB_CSS_SYNTAX_TOKEN_BAD_URL:
            return cast(lxb_char_t*) "bad-url";
        case LXB_CSS_SYNTAX_TOKEN_DELIM:
            return cast(lxb_char_t*) "delim";
        case LXB_CSS_SYNTAX_TOKEN_UNICODE_RANGE:
            return cast(lxb_char_t*) "unicode-range";
        case LXB_CSS_SYNTAX_TOKEN_NUMBER:
            return cast(lxb_char_t*) "number";
        case LXB_CSS_SYNTAX_TOKEN_PERCENTAGE:
            return cast(lxb_char_t*) "percentage";
        case LXB_CSS_SYNTAX_TOKEN_DIMENSION:
            return cast(lxb_char_t*) "dimension";
        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            return cast(lxb_char_t*) "whitespace";
        case LXB_CSS_SYNTAX_TOKEN_CDO:
            return cast(lxb_char_t*) "CDO";
        case LXB_CSS_SYNTAX_TOKEN_CDC:
            return cast(lxb_char_t*) "CDC";
        case LXB_CSS_SYNTAX_TOKEN_COLON:
            return cast(lxb_char_t*) "colon";
        case LXB_CSS_SYNTAX_TOKEN_SEMICOLON:
            return cast(lxb_char_t*) "semicolon";
        case LXB_CSS_SYNTAX_TOKEN_COMMA:
            return cast(lxb_char_t*) "comma";
        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            return cast(lxb_char_t*) "left-square-bracket";
        case LXB_CSS_SYNTAX_TOKEN_RS_BRACKET:
            return cast(lxb_char_t*) "right-square-bracket";
        case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
            return cast(lxb_char_t*) "left-parenthesis";
        case LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS:
            return cast(lxb_char_t*) "right-parenthesis";
        case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
            return cast(lxb_char_t*) "left-curly-bracket";
        case LXB_CSS_SYNTAX_TOKEN_RC_BRACKET:
            return cast(lxb_char_t*) "right-curly-bracket";
        case LXB_CSS_SYNTAX_TOKEN_COMMENT:
            return cast(lxb_char_t*) "comment";
        case LXB_CSS_SYNTAX_TOKEN__EOF:
            return cast(lxb_char_t*) "end-of-file";
        case LXB_CSS_SYNTAX_TOKEN__END:
            return cast(lxb_char_t*) "end";
        default:
            return cast(lxb_char_t*) "undefined";
    }
}

lxb_css_syntax_token_type_t lxb_css_syntax_token_type_id_by_name(const(lxb_char_t)* type_name, size_t len)
{
    const(lexbor_shs_entry_t)* entry = void;

    entry = lexbor_shs_entry_get_lower_static(lxb_css_syntax_token_res_name_shs_map.ptr,
                                              type_name, len);
    if (entry == null) {
        return LXB_CSS_SYNTAX_TOKEN_UNDEF;
    }

    return cast(lxb_css_syntax_token_type_t) cast(uintptr_t) entry.value;
}

lxb_status_t lxb_css_syntax_token_serialize(const(lxb_css_syntax_token_t)* token, lxb_css_syntax_token_cb_f cb, void* ctx)
{
    size_t len = void;
    lxb_status_t status = void;
    lxb_char_t[128] buf = void;
    const(lxb_css_syntax_token_string_t)* str = void;
    const(lxb_css_syntax_token_dimension_t)* dim = void;

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_DELIM:
            len = lxb_css_syntax_token_encode_utf_8(buf.ptr,
                                                    token.types.delim.character);
            buf[len] = 0x00;

            return cb(buf.ptr, len, ctx);

        case LXB_CSS_SYNTAX_TOKEN_UNICODE_RANGE:
            /* Start */
            buf[0] = 'U';
            buf[1] = '+';
            len = 2;
            len += lexbor_conv_dec_to_hex(token.types.unicode_range.start,
                                          &buf[len], (buf.sizeof - 1) - len,
                                          true);

            /* End */
            buf[len] = '-';
            len += 1;
            len += lexbor_conv_dec_to_hex(token.types.unicode_range.end,
                                          &buf[len], (buf.sizeof - 1) - len,
                                          true);
            buf[len] = 0x00;

            return cb(buf.ptr, len, ctx);

        case LXB_CSS_SYNTAX_TOKEN_NUMBER:
            len = lexbor_conv_float_to_data(token.types.number.num,
                                            buf.ptr, (buf.sizeof - 1));

            buf[len] = 0x00;

            return cb(buf.ptr, len, ctx);

        case LXB_CSS_SYNTAX_TOKEN_PERCENTAGE:
            len = lexbor_conv_float_to_data(token.types.number.num,
                                            buf.ptr, (buf.sizeof - 1));

            buf[len] = 0x00;

            status = cb(buf.ptr, len, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            return cb(cast(lxb_char_t*) "%", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_CDO:
            return cb(cast(lxb_char_t*) "<!--", 4, ctx);

        case LXB_CSS_SYNTAX_TOKEN_CDC:
            return cb(cast(lxb_char_t*) "-->", 3, ctx);

        case LXB_CSS_SYNTAX_TOKEN_COLON:
            return cb(cast(lxb_char_t*) ":", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_SEMICOLON:
            return cb(cast(lxb_char_t*) ";", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_COMMA:
            return cb(cast(lxb_char_t*) ",", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            return cb(cast(lxb_char_t*) "[", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_RS_BRACKET:
            return cb(cast(lxb_char_t*) "]", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
            return cb(cast(lxb_char_t*) "(", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS:
            return cb(cast(lxb_char_t*) ")", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
            return cb(cast(lxb_char_t*) "{", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_RC_BRACKET:
            return cb(cast(lxb_char_t*) "}", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_HASH:
            status = cb(cast(lxb_char_t*) "#", 1, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            str = &token.types.string;

            return cb(str.data, str.length, ctx);

        case LXB_CSS_SYNTAX_TOKEN_AT_KEYWORD:
            status = cb(cast(lxb_char_t*) "@", 1, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            str = &token.types.string;

            return cb(str.data, str.length, ctx);

        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
        case LXB_CSS_SYNTAX_TOKEN_IDENT:
            str = &token.types.string;

            return cb(str.data, str.length, ctx);

        case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
            str = &token.types.string;

            status = cb(str.data, str.length, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            return cb(cast(lxb_char_t*) "(", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_STRING:
        case LXB_CSS_SYNTAX_TOKEN_BAD_STRING: {
            status = cb(cast(lxb_char_t*) "\"", 1, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            const(lxb_char_t)* begin = token.types.string.data;
            const(lxb_char_t)* end = begin + token.types.string.length;

            const(lxb_char_t)* ptr = begin;

            for (; begin < end; begin++) {
                /* 0x5C; '\'; Inverse/backward slash */
                if (*begin == 0x5C) {
                    begin += 1;

                    status = cb(ptr, (begin - ptr), ctx);
                    if (status != LXB_STATUS_OK) {
                        return status;
                    }

                    if (begin == end) {
                        status = cb(cast(const(lxb_char_t)*) "\\", 1, ctx);
                        if (status != LXB_STATUS_OK) {
                            return status;
                        }

                        ptr = begin;

                        break;
                    }

                    begin -= 1;
                    ptr = begin;
                }
                /* 0x22; '"'; Only quotes above */
                else if (*begin == 0x22) {
                    if (ptr != begin) {
                        status = cb(ptr, (begin - ptr), ctx);
                        if (status != LXB_STATUS_OK) {
                            return status;
                        }
                    }

                    status = cb(cast(const(lxb_char_t)*) "\\", 1, ctx);
                    if (status != LXB_STATUS_OK) {
                        return status;
                    }

                    ptr = begin;
                }
            }

            if (ptr != begin) {
                status = cb(ptr, (begin - ptr), ctx);
                if (status != LXB_STATUS_OK) {
                    return status;
                }
            }

            return cb(cast(const(lxb_char_t)*) "\"", 1, ctx);
        }

        case LXB_CSS_SYNTAX_TOKEN_URL:
        case LXB_CSS_SYNTAX_TOKEN_BAD_URL:
            status = cb(cast(lxb_char_t*) "url(", 4, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            str = &token.types.string;

            status = cb(str.data, str.length, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            return cb(cast(lxb_char_t*) ")", 1, ctx);

        case LXB_CSS_SYNTAX_TOKEN_COMMENT:
            status = cb(cast(lxb_char_t*) "/*", 2, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            str = &token.types.string;

            status = cb(str.data, str.length, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            return cb(cast(lxb_char_t*) "*/", 2, ctx);

        case LXB_CSS_SYNTAX_TOKEN_DIMENSION:
            len = lexbor_conv_float_to_data(token.types.number.num,
                                            buf.ptr, (buf.sizeof - 1));

            buf[len] = 0x00;

            status = cb(buf.ptr, len, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            dim = &token.types.dimension;

            return cb(dim.str.data, dim.str.length, ctx);

        case LXB_CSS_SYNTAX_TOKEN__EOF:
            return cb(cast(lxb_char_t*) "END-OF-FILE", 11, ctx);

        case LXB_CSS_SYNTAX_TOKEN__END:
            return cb(cast(lxb_char_t*) "END", 3, ctx);

        default:
            return LXB_STATUS_ERROR;
    }
}

lxb_status_t lxb_css_syntax_token_serialize_str(const(lxb_css_syntax_token_t)* token, lexbor_str_t* str, lexbor_mraw_t* mraw)
{
    lxb_css_syntax_token_ctx_t ctx = void;

    ctx.str = str;
    ctx.mraw = mraw;

    if (str.data == null) {
        lexbor_str_init(str, mraw, 1);
        if (str.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    return lxb_css_syntax_token_serialize(token, &lxb_css_syntax_token_str_cb,
                                          &ctx);
}

private lxb_status_t lxb_css_syntax_token_str_cb(const(lxb_char_t)* data, size_t len, void* cb_ctx)
{
    lxb_char_t* ptr = void;
    lxb_css_syntax_token_ctx_t* ctx = cast(lxb_css_syntax_token_ctx_t*) cb_ctx;

    ptr = lexbor_str_append(ctx.str, ctx.mraw, data, len);
    if (ptr == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    return LXB_STATUS_OK;
}

lxb_char_t* lxb_css_syntax_token_serialize_char(const(lxb_css_syntax_token_t)* token, size_t* out_length)
{
    size_t length = 0;
    lxb_status_t status = void;
    lexbor_str_t str = void;

    status = lxb_css_syntax_token_serialize(token, &lexbor_serialize_length_cb,
                                            &length);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    /* + 1 == '\0' */
    str.data = cast(ubyte*) lexbor_malloc(length + 1);
    if (str.data == null) {
        goto failed;
    }

    str.length = 0;

    status = lxb_css_syntax_token_serialize(token, &lexbor_serialize_copy_cb,
                                            &str);
    if (status != LXB_STATUS_OK) {
        lexbor_free(str.data);
        goto failed;
    }

    str.data[str.length] = '\0';

    if (out_length != null) {
        *out_length = str.length;
    }

    return str.data;

failed:

    if (out_length != null) {
        *out_length = 0;
    }

    return null;
}

lxb_css_log_message_t* lxb_css_syntax_token_error(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, const(char)* module_name)
{
    lxb_char_t* name = void;
    lxb_css_log_message_t* msg = void;

    static const(char)[25] unexpected = "%s. Unexpected token: %s";

    name = lxb_css_syntax_token_serialize_char(token, null);
    if (name == null) {
        return null;
    }

    msg = lxb_css_log_format(parser.log, LXB_CSS_LOG_SYNTAX_ERROR, unexpected.ptr,
                             module_name, name);

    lexbor_free(name);

    return msg;
}

private byte lxb_css_syntax_token_encode_utf_8(lxb_char_t* data, lxb_codepoint_t cp)
{
    if (cp < 0x80) {
        /* 0xxxxxxx */
        *data = cast(lxb_char_t) cp;

        return 1;
    }

    if (cp < 0x800) {
        /* 110xxxxx 10xxxxxx */
        *data++ = cast(lxb_char_t) (0xC0 | (cp >> 6 ));
        *data = cast(lxb_char_t) (0x80 | (cp & 0x3F));

        return 2;
    }

    if (cp < 0x10000) {
        /* 1110xxxx 10xxxxxx 10xxxxxx */
        *data++ = cast(lxb_char_t) (0xE0 | ((cp >> 12)));
        *data++ = cast(lxb_char_t) (0x80 | ((cp >> 6 ) & 0x3F));
        *data = cast(lxb_char_t) (0x80 | ( cp & 0x3F));

        return 3;
    }

    if (cp < 0x110000) {
        /* 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx */
        *data++ = cast(lxb_char_t) (0xF0 | ( cp >> 18));
        *data++ = cast(lxb_char_t) (0x80 | ((cp >> 12) & 0x3F));
        *data++ = cast(lxb_char_t) (0x80 | ((cp >> 6 ) & 0x3F));
        *data = cast(lxb_char_t) (0x80 | ( cp & 0x3F));

        return 4;
    }

    return 0;
}

/*
 * No inline functions for ABI.
 */
lxb_css_syntax_token_t* lxb_css_syntax_token_create_noi(lexbor_dobject_t* dobj)
{
    return lxb_css_syntax_token_create(dobj);
}

void lxb_css_syntax_token_clean_noi(lxb_css_syntax_token_t* token)
{
    lxb_css_syntax_token_clean(token);
}

lxb_css_syntax_token_t* lxb_css_syntax_token_destroy_noi(lxb_css_syntax_token_t* token, lexbor_dobject_t* dobj)
{
    return lxb_css_syntax_token_destroy(token, dobj);
}

const(lxb_char_t)* lxb_css_syntax_token_type_name_noi(lxb_css_syntax_token_t* token)
{
    return lxb_css_syntax_token_type_name(token);
}

lxb_css_syntax_token_type_t lxb_css_syntax_token_type_noi(lxb_css_syntax_token_t* token)
{
    return lxb_css_syntax_token_type(token);
}
