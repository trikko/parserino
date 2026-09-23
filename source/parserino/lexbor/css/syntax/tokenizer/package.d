module parserino.lexbor.css.syntax.tokenizer;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.array_obj;
public import parserino.lexbor.css.syntax.base;
public import parserino.lexbor.css.syntax.token;
import parserino.lexbor.css.syntax.tokenizer.error;
import parserino.lexbor.css.syntax.state;
import parserino.lexbor.css.syntax.state_res;
import parserino.lexbor.core.array;
import parserino.lexbor.core.str_res;

extern(C) @nogc nothrow:
__gshared:

// ---- tokenizer.h ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
/* State */
alias lxb_css_syntax_tokenizer_state_f = const(lxb_char_t)* function(lxb_css_syntax_tokenizer_t* tkz, lxb_css_syntax_token_t* token, const(lxb_char_t)* data, const(lxb_char_t)* end);

enum lxb_css_syntax_tokenizer_opt {
    LXB_CSS_SYNTAX_TOKENIZER_OPT_UNDEF = 0x00,
}
alias LXB_CSS_SYNTAX_TOKENIZER_OPT_UNDEF = lxb_css_syntax_tokenizer_opt.LXB_CSS_SYNTAX_TOKENIZER_OPT_UNDEF;


struct lxb_css_syntax_tokenizer {
    lexbor_dobject_t* tokens;
    lexbor_array_obj_t* parse_errors;
    lexbor_mraw_t* mraw;

    lxb_css_syntax_token_t* first;
    lxb_css_syntax_token_t* last;

    const(lxb_char_t)* in_begin;
    const(lxb_char_t)* in_end;
    const(lxb_char_t)* in_p;

    /* Temp */
    lxb_char_t* start;
    lxb_char_t* pos;
    const(lxb_char_t)* end;

    size_t offset;

    /* Process */
    uint opt; /* bitmap */
    lxb_status_t status;
    bool with_comment;
    bool with_unicode_range;
}





 lxb_status_t lxb_css_syntax_tokenizer_next_chunk(lxb_css_syntax_tokenizer_t* tkz, const(lxb_char_t)** data, const(lxb_char_t)** end);




/*
 * Inline functions
 */
 lxb_status_t lxb_css_syntax_tokenizer_status(lxb_css_syntax_tokenizer_t* tkz)
{
    return tkz.status;
}

 void lxb_css_syntax_tokenizer_buffer_set(lxb_css_syntax_tokenizer_t* tkz, const(lxb_char_t)* data, size_t size)
{
    tkz.in_begin = data;
    tkz.in_p = data;
    tkz.in_end = data + size;
}

 void lxb_css_syntax_tokenizer_with_unicode_range(lxb_css_syntax_tokenizer_t* tkz, bool with_range)
{
    tkz.with_unicode_range = with_range;
}

/*
 * No inline functions for ABI.
 */

// ---- tokenizer.c ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

private const(lxb_char_t)[10] lxb_css_syntax_tokenizer_important = lexbor_carray!"important";





lxb_css_syntax_tokenizer_t* lxb_css_syntax_tokenizer_create()
{
    return cast(lxb_css_syntax_tokenizer*) lexbor_calloc(1, lxb_css_syntax_tokenizer_t.sizeof);
}

lxb_status_t lxb_css_syntax_tokenizer_init(lxb_css_syntax_tokenizer_t* tkz)
{
    lxb_status_t status = void;
    static const(uint) tmp_size = 1024;

    if (tkz == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    /* Tokens. */

    tkz.tokens = lexbor_dobject_create();
    status = lexbor_dobject_init(tkz.tokens, 128,
                                 lxb_css_syntax_token_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    /* Memory for text. */

    tkz.mraw = lexbor_mraw_create();
    status = lexbor_mraw_init(tkz.mraw, 4096);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    /* Temp */
    tkz.start = cast(ubyte*) lexbor_malloc(tmp_size);
    if (tkz.start == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    tkz.pos = tkz.start;
    tkz.end = tkz.start + tmp_size;

    /* Parse errors */
    tkz.parse_errors = lexbor_array_obj_create();
    status = lexbor_array_obj_init(tkz.parse_errors, 16,
                                   lxb_css_syntax_tokenizer_error_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    tkz.first = null;
    tkz.last = null;

    tkz.offset = 0;

    tkz.with_comment = false;
    tkz.with_unicode_range = false;
    tkz.status = LXB_STATUS_OK;
    tkz.opt = LXB_CSS_SYNTAX_TOKENIZER_OPT_UNDEF;

    return LXB_STATUS_OK;
}

lxb_status_t lxb_css_syntax_tokenizer_clean(lxb_css_syntax_tokenizer_t* tkz)
{
    lexbor_mraw_clean(tkz.mraw);
    lexbor_array_obj_clean(tkz.parse_errors);
    lexbor_dobject_clean(tkz.tokens);

    tkz.in_begin = null;
    tkz.in_p = null;
    tkz.in_end = null;
    tkz.first = null;
    tkz.last = null;
    tkz.pos = tkz.start;
    tkz.offset = 0;
    tkz.status = LXB_STATUS_OK;

    return LXB_STATUS_OK;
}

lxb_css_syntax_tokenizer_t* lxb_css_syntax_tokenizer_destroy(lxb_css_syntax_tokenizer_t* tkz)
{
    if (tkz == null) {
        return null;
    }

    if (tkz.tokens != null) {
        tkz.tokens = lexbor_dobject_destroy(tkz.tokens, true);
    }

    tkz.mraw = lexbor_mraw_destroy(tkz.mraw, true);
    tkz.parse_errors = lexbor_array_obj_destroy(tkz.parse_errors, true);

    if (tkz.start != null) {
        tkz.start = cast(ubyte*) lexbor_free(tkz.start);
    }

    return cast(lxb_css_syntax_tokenizer*) lexbor_free(tkz);
}

lxb_css_syntax_token_t* lxb_css_syntax_tokenizer_token(lxb_css_syntax_tokenizer_t* tkz)
{
    lxb_status_t status = void;
    lxb_css_syntax_token_t* token = void;
    const(lxb_char_t)* begin = void, end = void;

    begin = tkz.in_p;
    end = tkz.in_end;

    token = cast(lxb_css_syntax_token_*) lexbor_dobject_calloc(tkz.tokens);
    if (token == null) {
        tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        return null;
    }

    if (tkz.first == null) {
        tkz.first = token;
    }

    if (tkz.last != null) {
        status = lxb_css_syntax_token_string_make(tkz, tkz.last);
        if (status != LXB_STATUS_OK) {
            return null;
        }

        tkz.last.next = token;
    }

    tkz.last = token;

again:

    (cast(lxb_css_syntax_token_base_t*) (token)).begin = begin;

    if (begin < end) {
        begin = lxb_css_syntax_state_res_map[*begin](tkz, token, begin, end);
        if (begin == null) {
            return null;
        }
    }
    else {
        token.type = LXB_CSS_SYNTAX_TOKEN__EOF;
    }

    token.offset = tkz.offset;
    (cast(lxb_css_syntax_token_base_t*) (token)).length = begin - tkz.in_p;
    tkz.offset += (cast(lxb_css_syntax_token_base_t*) (token)).length;

    tkz.in_p = begin;

    if (token.type == LXB_CSS_SYNTAX_TOKEN_COMMENT && !tkz.with_comment) {
        goto again;
    }

    return token;
}

bool lxb_css_syntax_tokenizer_lookup_colon(lxb_css_syntax_tokenizer_t* tkz)
{
    const(lxb_char_t)* p = void, end = void;
    lxb_css_syntax_token_t* token = void;

    if (tkz.first != null && tkz.first.next != null) {
        token = tkz.first.next;

        if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
            if (token.next != null) {
                return token.next.type == LXB_CSS_SYNTAX_TOKEN_COLON;
            }
        }
        else if (token.type == LXB_CSS_SYNTAX_TOKEN_COLON) {
            return true;
        }

        return false;
    }

    p = tkz.in_p;
    end = tkz.in_end;

    while (p < end) {
        switch (*p) {
            case 0x3A:
                return true;

            case 0x0D:
            case 0x0C:
            case 0x09:
            case 0x20:
            case 0x0A:
                p += 1;
                break;

            default:
                return false;
        }
    }

    return false;
}

bool lxb_css_syntax_tokenizer_lookup_important(lxb_css_syntax_tokenizer_t* tkz, lxb_css_syntax_token_type_t stop, const(lxb_char_t) stop_ch)
{
    const(lxb_char_t)* p = void, end = void;
    lxb_css_syntax_token_t* token = void;

    static const(size_t) length = lxb_css_syntax_tokenizer_important.sizeof - 1;

    p = tkz.in_p;
    end = tkz.in_end;

    if (tkz.first != null && tkz.first.next != null) {
        token = tkz.first.next;

        if (token.type != LXB_CSS_SYNTAX_TOKEN_IDENT) {
            return false;
        }

        if (!((cast(lxb_css_syntax_token_ident_t*) (token)).length == length
              && lexbor_str_data_ncasecmp((cast(lxb_css_syntax_token_ident_t*) (token)).data,
                                          lxb_css_syntax_tokenizer_important.ptr,
                                          length)))
        {
            return false;
        }

        if (token.next != null) {
            token = token.next;

            if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
                if (token.next == null) {
                    return lxb_css_syntax_tokenizer_lookup_important_end(tkz,
                                                              p, end, stop_ch);
                }

                token = token.next;
            }

            return (token.type == LXB_CSS_SYNTAX_TOKEN_SEMICOLON
                    || token.type == stop
                    || token.type == LXB_CSS_SYNTAX_TOKEN__EOF);
        }

        return lxb_css_syntax_tokenizer_lookup_important_end(tkz, p, end,
                                                             stop_ch);
    }

    return lxb_css_syntax_tokenizer_lookup_important_ch(tkz, p, end, stop_ch);
}

private bool lxb_css_syntax_tokenizer_lookup_important_ch(lxb_css_syntax_tokenizer_t* tkz, const(lxb_char_t)* p, const(lxb_char_t)* end, const(lxb_char_t) stop_ch)
{
    static const(size_t) length = lxb_css_syntax_tokenizer_important.sizeof - 1;

    if (!(end - p >= length
           && lexbor_str_data_ncasecmp(p, lxb_css_syntax_tokenizer_important.ptr,
                                       length)))
    {
        return false;
    }

    return lxb_css_syntax_tokenizer_lookup_important_end(tkz, p + length,
                                                         end, stop_ch);
}

private bool lxb_css_syntax_tokenizer_lookup_important_end(lxb_css_syntax_tokenizer_t* tkz, const(lxb_char_t)* p, const(lxb_char_t)* end, const(lxb_char_t) stop_ch)
{
    while (p < end) {
        switch (*p) {
            case 0x3B:
                return true;

            case 0x0D:
            case 0x0C:
            case 0x09:
            case 0x20:
            case 0x0A:
                p += 1;
                break;

            default:
                return (stop_ch != 0x00 && stop_ch == *p);
        }
    }

    /* EOF */
    return true;
}

bool lxb_css_syntax_tokenizer_lookup_declaration_ws_end(lxb_css_syntax_tokenizer_t* tkz, lxb_css_syntax_token_type_t stop, const(lxb_char_t) stop_ch)
{
    lxb_css_syntax_token_t* token = void;
    const(lxb_char_t)* p = void, end = void;

    if (tkz.first != null && tkz.first.next) {
        token = tkz.first.next;

        switch (token.type) {
            case LXB_CSS_SYNTAX_TOKEN_DELIM:
                if ((cast(lxb_css_syntax_token_delim_t*) (token)).character != '!') {
                    return lxb_css_syntax_tokenizer_lookup_important(tkz, stop,
                                                                     stop_ch);
                }

                return false;

            case LXB_CSS_SYNTAX_TOKEN_SEMICOLON:
                return true;

            default:
                return token.type == stop_ch ||
                       token.type == LXB_CSS_SYNTAX_TOKEN__EOF;
        }
    }

    p = tkz.in_p;
    end = tkz.in_end;

    while (p < end) {
        switch (*p) {
            case 0x3B:
                return true;

            case 0x21:
                p += 1;
                return lxb_css_syntax_tokenizer_lookup_important_ch(tkz, p, end,
                                                                    stop_ch);

            default:
                return (stop_ch != 0x00 && stop_ch == *p);
        }
    }

    return false;
}

/*
 * No inline functions for ABI.
 */
lxb_status_t lxb_css_syntax_tokenizer_status_noi(lxb_css_syntax_tokenizer_t* tkz)
{
    return lxb_css_syntax_tokenizer_status(tkz);
}
