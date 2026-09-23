module parserino.lexbor.html.tokenizer.state_comment;

import parserino.lexbor.core.str_res;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.tokenizer;
import parserino.lexbor.html.tokenizer.state;

extern(C) @nogc nothrow:
__gshared:

// ---- state_comment.h ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

// ---- state_comment.c ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

// D port (C extern, imported instead): extern const(lxb_char_t)[4] lexbor_str_res_ansi_replacement_character;











/*
 * Helper function. No in the specification. For 12.2.5.43
 */
const(lxb_char_t)* lxb_html_tokenizer_state_comment_before_start(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    if (tkz.is_eof == false) {
        do { tkz.pos = tkz.start; tkz.token.begin = data; } while (0);
        (tkz.token.end = data);
    }

    tkz.token.tag_id = LXB_TAG__EM_COMMENT;

    return lxb_html_tokenizer_state_comment_start(tkz, data, end);
}

/*
 * 12.2.5.43 Comment start state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_comment_start(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    /* U+002D HYPHEN-MINUS (-) */
    if (*data == 0x2D) {
        data++;
        tkz.state = &lxb_html_tokenizer_state_comment_start_dash;
    }
    /* U+003E GREATER-THAN SIGN (>) */
    else if (*data == 0x3E) {
        tkz.state = &lxb_html_tokenizer_state_data_before;

        lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                     LXB_HTML_TOKENIZER_ERROR_ABCLOFEMCO);

        do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
        do { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

        data++;
    }
    else {
        tkz.state = &lxb_html_tokenizer_state_comment;
    }

    return data;
}

/*
 * 12.2.5.44 Comment start dash state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_comment_start_dash(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    /* U+002D HYPHEN-MINUS (-) */
    if (*data == 0x2D) {
        tkz.state = &lxb_html_tokenizer_state_comment_end;

        return (data + 1);
    }
    /* U+003E GREATER-THAN SIGN (>) */
    else if (*data == 0x3E) {
        tkz.state = &lxb_html_tokenizer_state_data_before;

        lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                     LXB_HTML_TOKENIZER_ERROR_ABCLOFEMCO);

        do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
        do { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

        return (data + 1);
    }
    /* EOF */
    else if (*data == 0x00) {
        if (tkz.is_eof) {
            lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                         LXB_HTML_TOKENIZER_ERROR_EOINCO);

            do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
            do { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

            return end;
        }
    }

    do { if (lxb_html_tokenizer_temp_append(tkz, cast(const(lxb_char_t)*) ("-"), (1))) { return end; } } while (0);

    tkz.state = &lxb_html_tokenizer_state_comment;

    return data;
}

/*
 * 12.2.5.45 Comment state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_comment(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    (tkz.begin = data);

    while (data != end) {
        switch (*data) {
            /* U+003C LESS-THAN SIGN (<) */
            case 0x3C:
                data++;

                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

                tkz.state = &lxb_html_tokenizer_state_comment_less_than_sign;

                return data;

            /* U+002D HYPHEN-MINUS (-) */
            case 0x2D:
                (tkz.token.end = data - 1);
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

                tkz.state = &lxb_html_tokenizer_state_comment_end_dash;

                return (data + 1);

            /* U+000D CARRIAGE RETURN (CR) */
            case 0x0D:
                if (++data >= end) {
                    do { if (lxb_html_tokenizer_temp_append_data(tkz, data - 1)) { return end; } } while (0);

                    tkz.state = &lxb_html_tokenizer_state_cr;
                    tkz.state_return = &lxb_html_tokenizer_state_comment;

                    return data;
                }

                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                tkz.pos[-1] = 0x0A;

                (tkz.begin = data + 1);

                if (*data != 0x0A) {
                    (tkz.begin = data);
                    data--;
                }

                break;

            /*
             * EOF
             * U+0000 NULL
             */
            case 0x00:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

                if (tkz.is_eof) {
                    if (tkz.token.begin != null) {
                        (tkz.token.end = tkz.last);
                    }

                    lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.token.end,
                                                 LXB_HTML_TOKENIZER_ERROR_EOINCO);

                    do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
                    do { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                    return end;
                }

                (tkz.begin = data + 1);
                do { if (lxb_html_tokenizer_temp_append(tkz, lexbor_str_res_ansi_replacement_character.ptr, lexbor_str_res_ansi_replacement_character.sizeof - 1)) { return end; } } while (0);

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_UNNUCH);
                break;

            default:
                break;
        }

        data++;
    }

    do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

    return data;
}

/*
 * 12.2.5.46 Comment less-than sign state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_comment_less_than_sign(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    /* U+0021 EXCLAMATION MARK (!) */
    if (*data == 0x21) {
        do { if (lxb_html_tokenizer_temp_append(tkz, cast(const(lxb_char_t)*) (data), (1))) { return end; } } while (0);

        tkz.state = &lxb_html_tokenizer_state_comment_less_than_sign_bang;

        return (data + 1);
    }
    /* U+003C LESS-THAN SIGN (<) */
    else if (*data == 0x3C) {
        do { if (lxb_html_tokenizer_temp_append(tkz, cast(const(lxb_char_t)*) (data), (1))) { return end; } } while (0);

        return (data + 1);
    }

    tkz.state = &lxb_html_tokenizer_state_comment;

    return data;
}

/*
 * 12.2.5.47 Comment less-than sign bang state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_comment_less_than_sign_bang(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    /* U+002D HYPHEN-MINUS (-) */
    if (*data == 0x2D) {
        tkz.state = &lxb_html_tokenizer_state_comment_less_than_sign_bang_dash;

        return (data + 1);
    }

    tkz.state = &lxb_html_tokenizer_state_comment;

    return data;
}

/*
 * 12.2.5.48 Comment less-than sign bang dash state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_comment_less_than_sign_bang_dash(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    /* U+002D HYPHEN-MINUS (-) */
    if (*data == 0x2D) {
        tkz.state =
            &lxb_html_tokenizer_state_comment_less_than_sign_bang_dash_dash;

        return (data + 1);
    }

    tkz.state = &lxb_html_tokenizer_state_comment_end_dash;

    return data;
}

/*
 * 12.2.5.49 Comment less-than sign bang dash dash state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_comment_less_than_sign_bang_dash_dash(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    /* U+003E GREATER-THAN SIGN (>) */
    if (*data == 0x3E) {
        tkz.state = &lxb_html_tokenizer_state_comment_end;

        return data;
    }
    /* EOF */
    else if (*data == 0x00) {
        if (tkz.is_eof) {
            tkz.state = &lxb_html_tokenizer_state_comment_end;

            return data;
        }
    }

    lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                 LXB_HTML_TOKENIZER_ERROR_NECO);

    tkz.state = &lxb_html_tokenizer_state_comment_end;

    return data;
}

/*
 * 12.2.5.50 Comment end dash state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_comment_end_dash(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    /* U+002D HYPHEN-MINUS (-) */
    if (*data == 0x2D) {
        tkz.state = &lxb_html_tokenizer_state_comment_end;

        return (data + 1);
    }
    /* EOF */
    else if (*data == 0x00) {
        if (tkz.is_eof) {
            lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                         LXB_HTML_TOKENIZER_ERROR_EOINCO);

            do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
            do { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

            return end;
        }
    }

    do { if (lxb_html_tokenizer_temp_append(tkz, cast(const(lxb_char_t)*) ("-"), (1))) { return end; } } while (0);

    tkz.state = &lxb_html_tokenizer_state_comment;

    return data;
}

/*
 * 12.2.5.51 Comment end state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_comment_end(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    /* U+003E GREATER-THAN SIGN (>) */
    if (*data == 0x3E) {
        /* Skip two '-' characters in comment tag end "-->"
         * For <!----> or <!-----> ...
         */
        tkz.state = &lxb_html_tokenizer_state_data_before;

        do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
        do { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

        return (data + 1);
    }
    /* U+0021 EXCLAMATION MARK (!) */
    else if (*data == 0x21) {
        tkz.state = &lxb_html_tokenizer_state_comment_end_bang;

        return (data + 1);
    }
    /* U+002D HYPHEN-MINUS (-) */
    else if (*data == 0x2D) {
        do { if (lxb_html_tokenizer_temp_append(tkz, cast(const(lxb_char_t)*) (data), (1))) { return end; } } while (0);

        return (data + 1);
    }
    /* EOF */
    else if (*data == 0x00) {
        if (tkz.is_eof) {
            lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                         LXB_HTML_TOKENIZER_ERROR_EOINCO);

            do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
            do { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

            return end;
        }
    }

    do { if (lxb_html_tokenizer_temp_append(tkz, cast(const(lxb_char_t)*) ("--"), (2))) { return end; } } while (0);

    tkz.state = &lxb_html_tokenizer_state_comment;

    return data;
}

/*
 * 12.2.5.52 Comment end bang state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_comment_end_bang(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    static const(lexbor_str_t) two = {data: cast(lxb_char_t*) "--!".ptr, "--!".length};

    /* U+002D HYPHEN-MINUS (-) */
    if (*data == 0x2D) {
        do { if (lxb_html_tokenizer_temp_append(tkz, cast(const(lxb_char_t)*) (two.data), (two.length))) { return end; } } while (0);

        tkz.state = &lxb_html_tokenizer_state_comment_end_dash;

        return (data + 1);
    }
    /* U+003E GREATER-THAN SIGN (>) */
    else if (*data == 0x3E) {
        tkz.state = &lxb_html_tokenizer_state_data_before;

        lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                     LXB_HTML_TOKENIZER_ERROR_INCLCO);

        do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
        do { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

        return (data + 1);
    }
    /* EOF */
    else if (*data == 0x00) {
        if (tkz.is_eof) {
            lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                         LXB_HTML_TOKENIZER_ERROR_EOINCO);

            do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
            do { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

            return end;
        }

        do { if (lxb_html_tokenizer_temp_append(tkz, cast(const(lxb_char_t)*) (two.data), (two.length))) { return end; } } while (0);
    }
    else {
        do { if (lxb_html_tokenizer_temp_append(tkz, cast(const(lxb_char_t)*) (two.data), (two.length))) { return end; } } while (0);
    }

    tkz.state = &lxb_html_tokenizer_state_comment;

    return data;
}
