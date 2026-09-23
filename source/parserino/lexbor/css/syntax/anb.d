module parserino.lexbor.css.syntax.anb;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.syntax.token;
import parserino.lexbor.core.conv;
import parserino.lexbor.core.serialize;
import parserino.lexbor.css.css;
import parserino.lexbor.css.parser;

extern(C) @nogc nothrow:
__gshared:

// ---- anb.h ----
/*
 * Copyright (C) 2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_css_syntax_anb_t {
    c_long a;
    c_long b;
}





// ---- anb.c ----
/*
 * Copyright (C) 2021-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */










private const(lxb_css_syntax_cb_pipe_t) lxb_css_syntax_anb_pipe = {
    prelude: &lxb_css_syntax_anb_state,
    cb: {failed: &lxb_css_state_failed, end: &lxb_css_syntax_anb_end}
};

lxb_css_syntax_anb_t lxb_css_syntax_anb_parse(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    lxb_status_t status = void;
    lxb_css_syntax_anb_t anb = void;
    lxb_css_syntax_rule_t* rule = void;

    memset(&anb, 0, lxb_css_syntax_anb_t.sizeof);

    if (parser.stage != LXB_CSS_PARSER_CLEAN) {
        if (parser.stage == LXB_CSS_PARSER_RUN) {
            parser.status = LXB_STATUS_ERROR_WRONG_ARGS;
            return anb;
        }

        lxb_css_parser_clean(parser);
    }

    lxb_css_parser_buffer_set(parser, data, length);

    rule = lxb_css_syntax_parser_pipe_push(parser, &lxb_css_syntax_anb_pipe,
                                           null, &anb,
                                           LXB_CSS_SYNTAX_TOKEN_UNDEF);
    if (rule == null) {
        return anb;
    }

    parser.tkz.with_comment = false;
    parser.stage = LXB_CSS_PARSER_RUN;

    status = lxb_css_syntax_parser_run(parser);
    if (status != LXB_STATUS_OK) {
        /* Destroy. */
    }

    parser.stage = LXB_CSS_PARSER_END;

    return anb;
}

private bool lxb_css_syntax_anb_state(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    parser.status = lxb_css_syntax_anb_handler(parser, token, cast(lxb_css_syntax_anb_t*) ctx);

    token = lxb_css_syntax_parser_token(parser);
    if (token == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    if (parser.status != LXB_STATUS_OK
        || (token.type != LXB_CSS_SYNTAX_TOKEN__END))
    {
        cast(void) lxb_css_syntax_anb_fail(parser, token);
    }

    return lxb_css_parser_success(parser);
}

private lxb_status_t lxb_css_syntax_anb_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed)
{
    return LXB_STATUS_OK;
}

private lxb_css_log_message_t* lxb_css_syntax_anb_fail(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token)
{
    parser.status = LXB_STATUS_ERROR_UNEXPECTED_DATA;

    static const(char)[5] anb = "An+B";

    return lxb_css_syntax_token_error(parser, token, anb.ptr);
}

lxb_status_t lxb_css_syntax_anb_handler(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_anb_t* anb)
{
    const(lxb_char_t)* data = void, end = void;
    lxb_css_syntax_token_ident_t* ident = void;

again:

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_DIMENSION:
            if ((cast(lxb_css_syntax_token_dimension_t*) (token)).num.is_float) {
                return LXB_STATUS_ERROR_UNEXPECTED_DATA;
            }

            anb.a = lexbor_conv_double_to_long((cast(lxb_css_syntax_token_dimension_t*) (token)).num.num);

            ident = (&(cast(lxb_css_syntax_token_dimension_t*) (token)).str);

            goto ident;

        case LXB_CSS_SYNTAX_TOKEN_IDENT:
            return lxb_css_syntax_anb_state_ident(parser, token, anb);

        case LXB_CSS_SYNTAX_TOKEN_NUMBER:
            if ((cast(lxb_css_syntax_token_number_t*) (token)).is_float) {
                return LXB_STATUS_ERROR_UNEXPECTED_DATA;
            }

            anb.a = 0;
            anb.b = lexbor_conv_double_to_long((cast(lxb_css_syntax_token_number_t*) (token)).num);
            break;

        case LXB_CSS_SYNTAX_TOKEN_DELIM:
            if ((cast(lxb_css_syntax_token_delim_t*) (token)).character != '+') {
                return LXB_STATUS_ERROR_UNEXPECTED_DATA;
            }

            lxb_css_syntax_parser_consume(parser);
            do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } while (false);

            if (token.type != LXB_CSS_SYNTAX_TOKEN_IDENT) {
                return LXB_STATUS_ERROR_UNEXPECTED_DATA;
            }

            anb.a = 1;

            ident = (cast(lxb_css_syntax_token_ident_t*) (token));

            goto ident;

        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            lxb_css_syntax_parser_consume(parser);
            do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } while (false);
            goto again;

        default:
            return LXB_STATUS_ERROR_UNEXPECTED_DATA;
    }

    lxb_css_syntax_parser_consume(parser);

    return LXB_STATUS_OK;

ident:

    data = ident.data;
    end = ident.data + ident.length;

    if (*data != 'n' && *data != 'N') {
        return LXB_STATUS_ERROR_UNEXPECTED_DATA;
    }

    data++;

    return lxb_css_syntax_anb_state_ident_data(parser, anb, token, data, end);
}

private lxb_status_t lxb_css_syntax_anb_state_ident(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_anb_t* anb)
{
    size_t length = void;
    lxb_char_t c = void;
    const(lxb_char_t)* data = void, end = void;
    lxb_css_syntax_token_ident_t* ident = void;

    static const(lxb_char_t)[4] odd = lexbor_carray!"odd";
    static const(lxb_char_t)[5] even = lexbor_carray!"even";

    ident = (cast(lxb_css_syntax_token_ident_t*) (token));

    length = ident.length;
    data = ident.data;
    end = data + length;

    c = *data++;

    /* 'n' or '-n' */

    if (c == 'n' || c == 'N') {
        anb.a = 1;
    }
    else if (c == '-') {
        if (data >= end) {
            return LXB_STATUS_ERROR_UNEXPECTED_DATA;
        }

        c = *data++;

        if (c != 'n' && c != 'N') {
            return LXB_STATUS_ERROR_UNEXPECTED_DATA;
        }

        anb.a = -1;
    }
    else if (length == odd.sizeof - 1
             && lexbor_str_data_ncasecmp(ident.data, odd.ptr, odd.sizeof - 1))
    {
        anb.a = 2;
        anb.b = 1;

        lxb_css_syntax_parser_consume(parser);
        return LXB_STATUS_OK;
    }
    else if (length == even.sizeof - 1
             && lexbor_str_data_ncasecmp(ident.data, even.ptr, even.sizeof - 1))
    {
        anb.a = 2;
        anb.b = 0;

        lxb_css_syntax_parser_consume(parser);
        return LXB_STATUS_OK;
    }
    else {
        return LXB_STATUS_ERROR_UNEXPECTED_DATA;
    }

    return lxb_css_syntax_anb_state_ident_data(parser, anb, token, data, end);
}

private lxb_status_t lxb_css_syntax_anb_state_ident_data(lxb_css_parser_t* parser, lxb_css_syntax_anb_t* anb, const(lxb_css_syntax_token_t)* token, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    uint sign = void;
    lxb_char_t c = void;
    const(lxb_char_t)* p = void;

    sign = 0;

    if (data >= end) {
        lxb_css_syntax_parser_consume(parser);
        do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) { lxb_css_syntax_parser_consume(parser); if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } } while (false);

        switch (token.type) {
            case LXB_CSS_SYNTAX_TOKEN_NUMBER:
                if (!(cast(lxb_css_syntax_token_number_t*) (token)).have_sign) {
                    anb.b = 0;
                    return LXB_STATUS_OK;
                }

                break;

            case LXB_CSS_SYNTAX_TOKEN_DELIM:
                c = cast(lxb_char_t) (cast(lxb_css_syntax_token_delim_t*) (token)).character;

                switch (c) {
                    case '-':
                        sign = 1;
                        break;

                    case '+':
                        sign = 2;
                        break;

                    default:
                        anb.b = 0;
                        return LXB_STATUS_OK;
                }

                lxb_css_syntax_parser_consume(parser);
                do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) { lxb_css_syntax_parser_consume(parser); if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } } while (false);

                break;

            case LXB_CSS_SYNTAX_TOKEN__EOF:
                anb.b = 0;
                return LXB_STATUS_OK;

            default:
                anb.b = 0;
                return LXB_STATUS_OK;
        }

        goto number;
    }

    c = *data++;

    if (c != '-') {
        return LXB_STATUS_ERROR_UNEXPECTED_DATA;
    }

    if (data < end) {
        p = data;
        anb.b = -lexbor_conv_data_to_long(&data, end - data);

        if (anb.b > 0 || data == p || data < end) {
            return LXB_STATUS_ERROR_UNEXPECTED_DATA;
        }

        goto done;
    }

    sign = 1;

    lxb_css_syntax_parser_consume(parser);
    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) { lxb_css_syntax_parser_consume(parser); if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } } while (false);

number:

    if (token.type != LXB_CSS_SYNTAX_TOKEN_NUMBER) {
        return LXB_STATUS_ERROR_UNEXPECTED_DATA;
    }

    if ((cast(lxb_css_syntax_token_number_t*) (token)).is_float
        || (sign > 0 && (cast(lxb_css_syntax_token_number_t*) (token)).have_sign))
    {
        return LXB_STATUS_ERROR_UNEXPECTED_DATA;
    }

    anb.b = lexbor_conv_double_to_long((cast(lxb_css_syntax_token_number_t*) (token)).num);

    if (sign == 1) {
        anb.b = -anb.b;
    }

done:

    lxb_css_syntax_parser_consume(parser);

    return LXB_STATUS_OK;
}

lxb_status_t lxb_css_syntax_anb_serialize(lxb_css_syntax_anb_t* anb, lexbor_serialize_cb_f cb, void* ctx)
{
    lxb_char_t[128] buf = void;
    lxb_char_t* p = void, end = void;

    if (anb == null) {
        return LXB_STATUS_OK;
    }

    static const(lxb_char_t)[4] odd = lexbor_carray!"odd";
    static const(lxb_char_t)[5] even = lexbor_carray!"even";

    if (anb.a == 2) {
        if (anb.b == 1) {
            return cb(odd.ptr, odd.sizeof - 1, ctx);
        }

        if (anb.b == 0) {
            return cb(even.ptr, even.sizeof - 1, ctx);
        }
    }

    p = buf.ptr;
    end = p + buf.sizeof;

    if (anb.a == 1) {
        *p = '+';
        p++;
    }
    else if (anb.a == -1) {
        *p = '-';
        p++;
    }
    else {
        p += lexbor_conv_float_to_data(cast(double) anb.a, p, end - p);
        if (p >= end) {
            return LXB_STATUS_ERROR_SMALL_BUFFER;
        }
    }

    *p = 'n';
    p++;

    if (p >= end) {
        return cb(buf.ptr, p - buf.ptr, ctx);
    }

    if (anb.b == 0) {
        return cb(buf.ptr, p - buf.ptr, ctx);
    }

    if (anb.b > 0) {
        *p = '+';
        p++;

        if (p >= end) {
            return LXB_STATUS_ERROR_SMALL_BUFFER;
        }
    }

    p += lexbor_conv_float_to_data(cast(double) anb.b, p, end - p);

    return cb(buf.ptr, p - buf.ptr, ctx);
}

lxb_char_t* lxb_css_syntax_anb_serialize_char(lxb_css_syntax_anb_t* anb, size_t* out_length)
{
    size_t length = 0;
    lxb_status_t status = void;
    lexbor_str_t str = void;

    status = lxb_css_syntax_anb_serialize(anb, &lexbor_serialize_length_cb,
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

    status = lxb_css_syntax_anb_serialize(anb, &lexbor_serialize_copy_cb, &str);
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
