module parserino.lexbor.html.tokenizer.state_rcdata;

import parserino.lexbor.core.str_res;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.tokenizer;
import parserino.lexbor.html.tokenizer.state;

extern(C) @nogc nothrow:
__gshared:

// ---- state_rcdata.h ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
/*
 * Before call function:
 * Must be initialized:
 *     tkz->tmp_tag_id
 */

// ---- state_rcdata.c ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

    // D port (C extern, imported instead): extern const(lxb_char_t)[4] lexbor_str_res_ansi_replacement_character;
    // D port (C extern, imported instead): extern const(size_t)[256] lexbor_str_res_alpha_character;

const(lxb_tag_data_t)* lxb_tag_append_lower(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length);





/*
 * Helper function. No in the specification. For 12.2.5.2 RCDATA state
 */
const(lxb_char_t)* lxb_html_tokenizer_state_rcdata_before(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    if (tkz.is_eof == false) {
        do { tkz.pos = tkz.start; tkz.token.begin = data; } while (0);
    }

    tkz.state = &lxb_html_tokenizer_state_rcdata;

    return data;
}

/*
 * 12.2.5.2 RCDATA state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_rcdata(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    (tkz.begin = data);

    while (data != end) {
        switch (*data) {
            /* U+003C LESS-THAN SIGN (<) */
            case 0x3C:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data + 1)) { return end; } } while (0);
                (tkz.token.end = data);

                tkz.state = &lxb_html_tokenizer_state_rcdata_less_than_sign;

                return (data + 1);

            /* U+0026 AMPERSAND (&) */
            case 0x26:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data + 1)) { return end; } } while (0);

                tkz.state = &lxb_html_tokenizer_state_char_ref;
                tkz.state_return = &lxb_html_tokenizer_state_rcdata;

                return data + 1;

            /* U+000D CARRIAGE RETURN (CR) */
            case 0x0D:
                if (++data >= end) {
                    do { if (lxb_html_tokenizer_temp_append_data(tkz, data - 1)) { return end; } } while (0);

                    tkz.state = &lxb_html_tokenizer_state_cr;
                    tkz.state_return = &lxb_html_tokenizer_state_rcdata;

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
             * U+0000 NULL
             * EOF
             */
            case 0x00:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

                if (tkz.is_eof) {
                    if (tkz.token.begin != null) {
                        (tkz.token.end = tkz.last);
                    }

                    tkz.token.tag_id = LXB_TAG__TEXT;

                    do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
                    do { if (tkz.token.text_start != tkz.token.text_end) { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; }{} } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

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
 * 12.2.5.9 RCDATA less-than sign state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_rcdata_less_than_sign(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    /* U+002F SOLIDUS (/) */
    if (*data == 0x2F) {
        tkz.state = &lxb_html_tokenizer_state_rcdata_end_tag_open;

        return (data + 1);
    }

    tkz.state = &lxb_html_tokenizer_state_rcdata;

    return data;
}

/*
 * 12.2.5.10 RCDATA end tag open state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_rcdata_end_tag_open(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    if (lexbor_str_res_alpha_character[*data] != LEXBOR_STR_RES_SLIP) {
        tkz.temp = data;
        tkz.entity_start = (tkz.pos - 1) - tkz.start;

        tkz.state = &lxb_html_tokenizer_state_rcdata_end_tag_name;
    }
    else {
        tkz.state = &lxb_html_tokenizer_state_rcdata;
    }

    do { if (lxb_html_tokenizer_temp_append(tkz, cast(const(lxb_char_t)*) ("/"), (1))) { return end; } } while (0);

    return data;
}

/*
 * 12.2.5.11 RCDATA end tag name state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_rcdata_end_tag_name(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    (tkz.begin = data);

    while (data != end) {
        switch (*data) {
            /*
             * U+0009 CHARACTER TABULATION (tab)
             * U+000A LINE FEED (LF)
             * U+000C FORM FEED (FF)
             * U+000D CARRIAGE RETURN (CR)
             * U+0020 SPACE
             */
            case 0x09:
            case 0x0A:
            case 0x0C:
            case 0x0D:
            case 0x20:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { const(lxb_tag_data_t)* tag = void; tag = lxb_tag_append_lower(tkz.tags, (&tkz.start[tkz.entity_start] + 2), (tkz.pos) - (&tkz.start[tkz.entity_start] + 2)); if (tag == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } tkz.token.tag_id = tag.tag_id; } while (0)
                                                            ;

                if (tkz.tmp_tag_id != tkz.token.tag_id) {
                    goto anything_else;
                }

                tkz.state = &lxb_html_tokenizer_state_before_attribute_name;
                goto done;

            /* U+002F SOLIDUS (/) */
            case 0x2F:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { const(lxb_tag_data_t)* tag = void; tag = lxb_tag_append_lower(tkz.tags, (&tkz.start[tkz.entity_start] + 2), (tkz.pos) - (&tkz.start[tkz.entity_start] + 2)); if (tag == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } tkz.token.tag_id = tag.tag_id; } while (0)
                                                            ;

                if (tkz.tmp_tag_id != tkz.token.tag_id) {
                    goto anything_else;
                }

                tkz.state = &lxb_html_tokenizer_state_self_closing_start_tag;
                goto done;

            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { const(lxb_tag_data_t)* tag = void; tag = lxb_tag_append_lower(tkz.tags, (&tkz.start[tkz.entity_start] + 2), (tkz.pos) - (&tkz.start[tkz.entity_start] + 2)); if (tag == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } tkz.token.tag_id = tag.tag_id; } while (0)
                                                            ;

                if (tkz.tmp_tag_id != tkz.token.tag_id) {
                    goto anything_else;
                }

                tkz.state = &lxb_html_tokenizer_state_data_before;

                /* Emit text token */
                tkz.token.tag_id = LXB_TAG__TEXT;
                tkz.pos = &tkz.start[tkz.entity_start];

                do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
                do { if (tkz.token.text_start != tkz.token.text_end) { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; }{} } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                /* Init close token */
                tkz.token.tag_id = tkz.tmp_tag_id;
                tkz.token.begin = tkz.temp;
                tkz.token.end = data;
                tkz.token.type |= LXB_HTML_TOKEN_TYPE_CLOSE;

                /* Emit close token */
                do { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return (data + 1);

            default:
                if (lexbor_str_res_alpha_character[*data]
                    == LEXBOR_STR_RES_SLIP)
                {
                    do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

                    goto anything_else;
                }

                break;
        }

        data++;
    }

    do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

    return data;

anything_else:

    tkz.state = &lxb_html_tokenizer_state_rcdata;

    return data;

done:

    /* Emit text token */
    tkz.token.tag_id = LXB_TAG__TEXT;
    tkz.pos = &tkz.start[tkz.entity_start];

    do { tkz.token.text_start = tkz.start; tkz.token.text_end = tkz.pos; } while (0);
    do { if (tkz.token.text_start != tkz.token.text_end) { if (!(tkz.opt & LXB_HTML_TOKENIZER_OPT_ATTR_KEEP_DUPLICATE)) { lxb_html_tokenizer_attr_last_duplicate(tkz); } if (tkz.token.type & LXB_HTML_TOKEN_TYPE_CLOSE) { lxb_html_tokenizer_validate_close_tag(tkz); } tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; }{} } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

    /* Init close token */
    tkz.token.tag_id = tkz.tmp_tag_id;
    tkz.token.end = data;
    tkz.token.type |= LXB_HTML_TOKEN_TYPE_CLOSE;

    return (data + 1);
}
