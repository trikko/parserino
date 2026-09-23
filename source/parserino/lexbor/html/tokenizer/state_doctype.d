module parserino.lexbor.html.tokenizer.state_doctype;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.tokenizer;
import parserino.lexbor.html.tokenizer.state;
import parserino.lexbor.core.str_res;

extern(C) @nogc nothrow:
__gshared:

// ---- state_doctype.h ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

// ---- state_doctype.c ----
/*
 * Copyright (C) 2018-2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_dom_attr_data_t* lxb_dom_attr_local_name_append(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length);



















/*
 * Helper function. No in the specification. For 12.2.5.53
 */
const(lxb_char_t)* lxb_html_tokenizer_state_doctype_before(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    if (tkz.is_eof == false) {
        (tkz.token.end = data);
    }
    else {
        (tkz.token.end = tkz.last);
    }

    tkz.token.tag_id = LXB_TAG__EM_DOCTYPE;

    return lxb_html_tokenizer_state_doctype(tkz, data, end);
}

/*
 * 12.2.5.53 DOCTYPE state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
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
            data++;
            break;

        /* U+003E GREATER-THAN SIGN (>) */
        case 0x3E:
            break;

        /* EOF */
        case 0x00:
            if (tkz.is_eof) {
                lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                             LXB_HTML_TOKENIZER_ERROR_EOINDO);

                tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return end;
            }
            /* fall through */

            goto default; /* C fallthrough */
        default:
            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIWHBEDONA);
            break;
    }

    tkz.state = &lxb_html_tokenizer_state_doctype_before_name;

    return data;
}

/*
 * 12.2.5.54 Before DOCTYPE name state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_before_name(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    lxb_html_token_attr_t* attr = void;

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
                break;

            /*
             * U+0000 NULL
             * EOF
             */
            case 0x00:
                if (tkz.is_eof) {
                    lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                               LXB_HTML_TOKENIZER_ERROR_EOINDO);

                    tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                    do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                    return end;
                }

                do { attr = lxb_html_token_attr_append(tkz.token, tkz.dobj_token_attr); if (attr == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } } while (0);
                do { tkz.pos = tkz.start; tkz.token.attr_last.name_begin = data; } while (0);
                do { if (lxb_html_tokenizer_temp_append(tkz, lexbor_str_res_ansi_replacement_character.ptr, lexbor_str_res_ansi_replacement_character.sizeof - 1)) { return end; } } while (0);

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_UNNUCH);

                tkz.token.attr_last.type
                    |= LXB_HTML_TOKEN_ATTR_TYPE_NAME_NULL;

                tkz.state = &lxb_html_tokenizer_state_doctype_name;

                return (data + 1);

            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
                tkz.state = &lxb_html_tokenizer_state_data_before;

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_MIDONA);

                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return (data + 1);

            /*
             * ASCII upper alpha
             * Anything else
             */
            default:
                do { attr = lxb_html_token_attr_append(tkz.token, tkz.dobj_token_attr); if (attr == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } } while (0);
                do { tkz.pos = tkz.start; tkz.token.attr_last.name_begin = data; } while (0);

                tkz.state = &lxb_html_tokenizer_state_doctype_name;

                return data;
        }

        data++;
    }

    return data;
}

/*
 * 12.2.5.55 DOCTYPE name state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_name(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
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
                do { lxb_dom_attr_data_t* data_m = void; data_m = lxb_dom_attr_local_name_append(tkz.attrs, tkz.start, tkz.pos - tkz.start); if (data_m == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } tkz.token.attr_last.name = data_m; } while (0);
                (tkz.token.attr_last.name_end = data);

                tkz.state = &lxb_html_tokenizer_state_doctype_after_name;

                return (data + 1);

            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                tkz.state = &lxb_html_tokenizer_state_data_before;

                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { lxb_dom_attr_data_t* data_m = void; data_m = lxb_dom_attr_local_name_append(tkz.attrs, tkz.start, tkz.pos - tkz.start); if (data_m == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } tkz.token.attr_last.name = data_m; } while (0);
                (tkz.token.attr_last.name_end = data);
                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return (data + 1);

            /*
             * U+0000 NULL
             * EOF
             */
            case 0x00:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

                if (tkz.is_eof) {
                    (tkz.token.attr_last.name_end = tkz.last);

                    lxb_html_tokenizer_error_add(tkz.parse_errors,
                                               tkz.token.attr_last.name_end,
                                               LXB_HTML_TOKENIZER_ERROR_EOINDO);

                    tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                    do { lxb_dom_attr_data_t* data_m = void; data_m = lxb_dom_attr_local_name_append(tkz.attrs, tkz.start, tkz.pos - tkz.start); if (data_m == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } tkz.token.attr_last.name = data_m; } while (0);
                    do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                    return end;
                }

                (tkz.begin = data + 1);
                do { if (lxb_html_tokenizer_temp_append(tkz, lexbor_str_res_ansi_replacement_character.ptr, lexbor_str_res_ansi_replacement_character.sizeof - 1)) { return end; } } while (0);

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_UNNUCH);

                tkz.token.attr_last.type
                    |= LXB_HTML_TOKEN_ATTR_TYPE_NAME_NULL;

                break;

            /* Anything else */
            default:
                break;
        }

        data++;
    }

    do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

    return data;
}

/*
 * 12.2.5.56 After DOCTYPE name state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_after_name(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    lxb_html_token_attr_t* attr = void;
    const(lxb_dom_attr_data_t)* attr_data = void;

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
                break;

            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                tkz.state = &lxb_html_tokenizer_state_data_before;

                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return (data + 1);

            /* EOF */
            case 0x00:
                if (tkz.is_eof) {
                    lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                               LXB_HTML_TOKENIZER_ERROR_EOINDO);

                    tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                    do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                    return end;
                }
                /* fall through */

            /* Anything else */
                goto default; /* C fallthrough */
            default:
                do { attr = lxb_html_token_attr_append(tkz.token, tkz.dobj_token_attr); if (attr == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } } while (0);
                do { tkz.pos = tkz.start; tkz.token.attr_last.name_begin = data; } while (0);

                if ((data + 6) > end) {
                    /*
                     * ASCII case-insensitive match for the word "PUBLIC"
                     * U+0044 character (P) or U+0050 character (p)
                     */
                    if (*data == 0x50 || *data == 0x70) {
                        tkz.markup = cast(lxb_char_t*) "PUBLIC";

                        tkz.state =
                            &lxb_html_tokenizer_state_doctype_after_name_public;

                        return data;
                    }

                    /*
                     * ASCII case-insensitive match for the word "SYSTEM"
                     * U+0044 character (S) or U+0053 character (s)
                     */
                    if (*data == 0x53 || *data == 0x73) {
                        tkz.markup = cast(lxb_char_t*) "SYSTEM";

                        tkz.state =
                            &lxb_html_tokenizer_state_doctype_after_name_system;

                        return data;
                    }
                }
                else if (lexbor_str_data_ncasecmp(cast(lxb_char_t*) "PUBLIC",
                                                  data, 6))
                {
                    (tkz.token.attr_last.name_end = (data + 6))
                                                                               ;

                    attr_data = lxb_dom_attr_data_by_id(tkz.attrs,
                                                        LXB_DOM_ATTR_PUBLIC);
                    if (attr_data == null) {
                        tkz.status = LXB_STATUS_ERROR;
                        return end;
                    }

                    tkz.token.attr_last.name = attr_data;

                    tkz.state =
                        &lxb_html_tokenizer_state_doctype_after_public_keyword;

                    return (data + 6);
                }
                else if (lexbor_str_data_ncasecmp(cast(lxb_char_t*) "SYSTEM",
                                                  data, 6))
                {
                    (tkz.token.attr_last.name_end = (data + 6))
                                                                               ;

                    attr_data = lxb_dom_attr_data_by_id(tkz.attrs,
                                                        LXB_DOM_ATTR_SYSTEM);
                    if (attr_data == null) {
                        tkz.status = LXB_STATUS_ERROR;
                        return end;
                    }

                    tkz.token.attr_last.name = attr_data;

                    tkz.state =
                        &lxb_html_tokenizer_state_doctype_after_system_keyword;

                    return (data + 6);
                }

                lxb_html_token_attr_delete(tkz.token, attr,
                                           tkz.dobj_token_attr);

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_INCHSEAFDONA);

                tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
                tkz.state = &lxb_html_tokenizer_state_doctype_bogus;

                return data;
        }

        data++;
    }

    return data;
}

/*
 * Helper function. No in the specification. For 12.2.5.56
 * For doctype PUBLIC
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_after_name_public(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    const(lxb_char_t)* pos = void;
    const(lxb_dom_attr_data_t)* attr_data = void;

    pos = lexbor_str_data_ncasecmp_first(tkz.markup, data, (end - data));

    if (pos == null) {
        lxb_html_token_attr_delete(tkz.token, tkz.token.attr_last,
                                   tkz.dobj_token_attr);

        lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                     LXB_HTML_TOKENIZER_ERROR_INCHSEAFDONA);

        tkz.state = &lxb_html_tokenizer_state_doctype_bogus;

        return data;
    }

    if (*pos == '\0') {
        pos = data + (pos - tkz.markup);

        (tkz.token.attr_last.name_end = pos);

        attr_data = lxb_dom_attr_data_by_id(tkz.attrs,
                                            LXB_DOM_ATTR_PUBLIC);
        if (attr_data == null) {
            tkz.status = LXB_STATUS_ERROR;
            return end;
        }

        tkz.token.attr_last.name = attr_data;

        tkz.state = &lxb_html_tokenizer_state_doctype_after_public_keyword;

        return (pos + 1);
    }

    tkz.markup = pos;

    return end;
}

/*
 * Helper function. No in the specification. For 12.2.5.56
 * For doctype SYSTEM
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_after_name_system(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    const(lxb_char_t)* pos = void;
    const(lxb_dom_attr_data_t)* attr_data = void;

    pos = lexbor_str_data_ncasecmp_first(tkz.markup, data, (end - data));

    if (pos == null) {
        lxb_html_token_attr_delete(tkz.token, tkz.token.attr_last,
                                   tkz.dobj_token_attr);

        lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                     LXB_HTML_TOKENIZER_ERROR_INCHSEAFDONA);

        tkz.state = &lxb_html_tokenizer_state_doctype_bogus;

        return data;
    }

    if (*pos == '\0') {
        pos = data + (pos - tkz.markup);

        (tkz.token.attr_last.name_end = pos);

        attr_data = lxb_dom_attr_data_by_id(tkz.attrs,
                                            LXB_DOM_ATTR_SYSTEM);
        if (attr_data == null) {
            tkz.status = LXB_STATUS_ERROR;
            return end;
        }

        tkz.token.attr_last.name = attr_data;

        tkz.state = &lxb_html_tokenizer_state_doctype_after_system_keyword;

        return (pos + 1);
    }

    tkz.markup = pos;

    return end;
}

/*
 * 12.2.5.57 After DOCTYPE public keyword state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_after_public_keyword(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
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
            tkz.state =
                &lxb_html_tokenizer_state_doctype_before_public_identifier;

            return (data + 1);

        /* U+0022 QUOTATION MARK (") */
        case 0x22:
            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIWHAFDOPUKE);

            tkz.state =
               &lxb_html_tokenizer_state_doctype_public_identifier_double_quoted;

            return (data + 1);

        /* U+0027 APOSTROPHE (') */
        case 0x27:
            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIWHAFDOPUKE);

            tkz.state =
               &lxb_html_tokenizer_state_doctype_public_identifier_single_quoted;

            return (data + 1);

        /* U+003E GREATER-THAN SIGN (>) */
        case 0x3E:
            tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
            tkz.state = &lxb_html_tokenizer_state_data_before;

            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIDOPUID);

            do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

            return (data + 1);

        /* EOF */
        case 0x00:
            if (tkz.is_eof) {
                tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                             LXB_HTML_TOKENIZER_ERROR_EOINDO);

                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return end;
            }
            /* fall through */

            goto default; /* C fallthrough */
        default:
            tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
            tkz.state = &lxb_html_tokenizer_state_doctype_bogus;

            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIQUBEDOPUID);

            return data;
    }

    return data;
}

/*
 * 12.2.5.58 Before DOCTYPE public identifier state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_before_public_identifier(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
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
            break;

        /* U+0022 QUOTATION MARK (") */
        case 0x22:
            tkz.state =
               &lxb_html_tokenizer_state_doctype_public_identifier_double_quoted;

            break;

        /* U+0027 APOSTROPHE (') */
        case 0x27:
            tkz.state =
               &lxb_html_tokenizer_state_doctype_public_identifier_single_quoted;

            break;

        /* U+003E GREATER-THAN SIGN (>) */
        case 0x3E:
            tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
            tkz.state = &lxb_html_tokenizer_state_data_before;

            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIDOPUID);

            do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

            break;

        /* EOF */
        case 0x00:
            if (tkz.is_eof) {
                lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                             LXB_HTML_TOKENIZER_ERROR_EOINDO);

                tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return end;
            }
            /* fall through */

            goto default; /* C fallthrough */
        default:
            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIQUBEDOPUID);

            tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
            tkz.state = &lxb_html_tokenizer_state_doctype_bogus;

            return data;
    }

    return (data + 1);
}

/*
 * 12.2.5.59 DOCTYPE public identifier (double-quoted) state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_public_identifier_double_quoted(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    if (tkz.token.attr_last.value_begin == null && tkz.is_eof == false) {
        do { tkz.pos = tkz.start; tkz.token.attr_last.value_begin = data; } while (0);
    }

    (tkz.begin = data);

    while (data != end) {
        switch (*data) {
            /* U+0022 QUOTATION MARK (") */
            case 0x22:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                (tkz.token.attr_last.value_end = data);

                tkz.state =
                    &lxb_html_tokenizer_state_doctype_after_public_identifier;

                return (data + 1);

            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                tkz.state = &lxb_html_tokenizer_state_data_before;

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_ABDOPUID);

                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                (tkz.token.attr_last.value_end = data);
                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return (data + 1);

            /* U+000D CARRIAGE RETURN (CR) */
            case 0x0D:
                if (++data >= end) {
                    do { if (lxb_html_tokenizer_temp_append_data(tkz, data - 1)) { return end; } } while (0);

                    tkz.state = &lxb_html_tokenizer_state_cr;
                    tkz.state_return = &lxb_html_tokenizer_state_doctype_public_identifier_double_quoted;

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
                    (tkz.token.attr_last.value_end = tkz.last);

                    if (tkz.token.attr_last.value_begin == null) {
                        do { tkz.pos = tkz.start; tkz.token.attr_last.value_begin = tkz.token.attr_last.value_end; } while (0)
                                                                             ;
                    }

                    lxb_html_tokenizer_error_add(tkz.parse_errors,
                                               tkz.token.attr_last.value_end,
                                               LXB_HTML_TOKENIZER_ERROR_EOINDO);

                    tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                    do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                    do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                    return end;
                }

                (tkz.begin = data + 1);
                do { if (lxb_html_tokenizer_temp_append(tkz, lexbor_str_res_ansi_replacement_character.ptr, lexbor_str_res_ansi_replacement_character.sizeof - 1)) { return end; } } while (0);

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_UNNUCH);

                tkz.token.attr_last.type
                    |= LXB_HTML_TOKEN_ATTR_TYPE_VALUE_NULL;

                break;

            /* Anything else */
            default:
                break;
        }

        data++;
    }

    do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

    return data;
}

/*
 * 12.2.5.60 DOCTYPE public identifier (single-quoted) state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_public_identifier_single_quoted(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    if (tkz.token.attr_last.value_begin == null && tkz.is_eof == false) {
        do { tkz.pos = tkz.start; tkz.token.attr_last.value_begin = data; } while (0);
    }

    (tkz.begin = data);

    while (data != end) {
        switch (*data) {
            /* U+0027 APOSTROPHE (') */
            case 0x27:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                (tkz.token.attr_last.value_end = data);

                tkz.state =
                    &lxb_html_tokenizer_state_doctype_after_public_identifier;

                return (data + 1);

            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                tkz.state = &lxb_html_tokenizer_state_data_before;

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_ABDOPUID);

                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                (tkz.token.attr_last.value_end = data);
                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return (data + 1);

            /* U+000D CARRIAGE RETURN (CR) */
            case 0x0D:
                if (++data >= end) {
                    do { if (lxb_html_tokenizer_temp_append_data(tkz, data - 1)) { return end; } } while (0);

                    tkz.state = &lxb_html_tokenizer_state_cr;
                    tkz.state_return = &lxb_html_tokenizer_state_doctype_public_identifier_single_quoted;

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
                    (tkz.token.attr_last.value_end = tkz.last);

                    if (tkz.token.attr_last.value_begin == null) {
                        do { tkz.pos = tkz.start; tkz.token.attr_last.value_begin = tkz.token.attr_last.value_end; } while (0)
                                                                               ;
                    }

                    lxb_html_tokenizer_error_add(tkz.parse_errors,
                                               tkz.token.attr_last.value_end,
                                               LXB_HTML_TOKENIZER_ERROR_EOINDO);

                    tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                    do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                    do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                    return end;
                }

                (tkz.begin = data + 1);
                do { if (lxb_html_tokenizer_temp_append(tkz, lexbor_str_res_ansi_replacement_character.ptr, lexbor_str_res_ansi_replacement_character.sizeof - 1)) { return end; } } while (0);

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_UNNUCH);

                tkz.token.attr_last.type
                    |= LXB_HTML_TOKEN_ATTR_TYPE_VALUE_NULL;

                break;

            /* Anything else */
            default:
                break;
        }

        data++;
    }

    do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

    return data;
}

/*
 * 12.2.5.61 After DOCTYPE public identifier state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_after_public_identifier(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    lxb_html_token_attr_t* attr = void;

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
            tkz.state =
         &lxb_html_tokenizer_state_doctype_between_public_and_system_identifiers;

            return (data + 1);

        /* U+003E GREATER-THAN SIGN (>) */
        case 0x3E:
            tkz.state = &lxb_html_tokenizer_state_data_before;

            do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

            return (data + 1);

        /* U+0022 QUOTATION MARK (") */
        case 0x22:
            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                     LXB_HTML_TOKENIZER_ERROR_MIWHBEDOPUANSYID);

            do { attr = lxb_html_token_attr_append(tkz.token, tkz.dobj_token_attr); if (attr == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } } while (0);

            tkz.state =
               &lxb_html_tokenizer_state_doctype_system_identifier_double_quoted;

            return (data + 1);

        /* U+0027 APOSTROPHE (') */
        case 0x27:
            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                     LXB_HTML_TOKENIZER_ERROR_MIWHBEDOPUANSYID);

            do { attr = lxb_html_token_attr_append(tkz.token, tkz.dobj_token_attr); if (attr == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } } while (0);

            tkz.state =
               &lxb_html_tokenizer_state_doctype_system_identifier_single_quoted;

            return (data + 1);

        /* EOF */
        case 0x00:
            if (tkz.is_eof) {
                lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                             LXB_HTML_TOKENIZER_ERROR_EOINDO);

                tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return end;
            }
            /* fall through */

            goto default; /* C fallthrough */
        default:
            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIQUBEDOSYID);

            tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
            tkz.state = &lxb_html_tokenizer_state_doctype_bogus;

            return data;
    }

    return data;
}

/*
 * 12.2.5.62 Between DOCTYPE public and system identifiers state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_between_public_and_system_identifiers(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    lxb_html_token_attr_t* attr = void;

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
            return (data + 1);

        /* U+003E GREATER-THAN SIGN (>) */
        case 0x3E:
            tkz.state = &lxb_html_tokenizer_state_data_before;

            do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

            return (data + 1);

        /* U+0022 QUOTATION MARK (") */
        case 0x22:
            do { attr = lxb_html_token_attr_append(tkz.token, tkz.dobj_token_attr); if (attr == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } } while (0);

            tkz.state =
               &lxb_html_tokenizer_state_doctype_system_identifier_double_quoted;

            return (data + 1);

        /* U+0027 APOSTROPHE (') */
        case 0x27:
            do { attr = lxb_html_token_attr_append(tkz.token, tkz.dobj_token_attr); if (attr == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } } while (0);

            tkz.state =
               &lxb_html_tokenizer_state_doctype_system_identifier_single_quoted;

            return (data + 1);

        /* EOF */
        case 0x00:
            if (tkz.is_eof) {
                lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                             LXB_HTML_TOKENIZER_ERROR_EOINDO);

                tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return end;
            }
            /* fall through */

            goto default; /* C fallthrough */
        default:
            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIQUBEDOSYID);

            tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
            tkz.state = &lxb_html_tokenizer_state_doctype_bogus;

            return data;
    }

    return data;
}

/*
 * 12.2.5.63 After DOCTYPE system keyword state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_after_system_keyword(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
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
            tkz.state =
                &lxb_html_tokenizer_state_doctype_before_system_identifier;

            return (data + 1);

        /* U+0022 QUOTATION MARK (") */
        case 0x22:
            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIWHAFDOSYKE);

            tkz.state =
               &lxb_html_tokenizer_state_doctype_system_identifier_double_quoted;

            return (data + 1);

        /* U+0027 APOSTROPHE (') */
        case 0x27:
            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIWHAFDOSYKE);

            tkz.state =
               &lxb_html_tokenizer_state_doctype_system_identifier_single_quoted;

            return (data + 1);

        /* U+003E GREATER-THAN SIGN (>) */
        case 0x3E:
            tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
            tkz.state = &lxb_html_tokenizer_state_data_before;

            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIDOSYID);

            do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

            return (data + 1);

        /* EOF */
        case 0x00:
            if (tkz.is_eof) {
                lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                             LXB_HTML_TOKENIZER_ERROR_EOINDO);

                tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return end;
            }
            /* fall through */

            goto default; /* C fallthrough */
        default:
            tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
            tkz.state = &lxb_html_tokenizer_state_doctype_bogus;

            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIQUBEDOSYID);

            return data;
    }

    return data;
}

/*
 * 12.2.5.64 Before DOCTYPE system identifier state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_before_system_identifier(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
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
            return (data + 1);

        /* U+0022 QUOTATION MARK (") */
        case 0x22:
            tkz.state =
               &lxb_html_tokenizer_state_doctype_system_identifier_double_quoted;

            return (data + 1);

        /* U+0027 APOSTROPHE (') */
        case 0x27:
            tkz.state =
               &lxb_html_tokenizer_state_doctype_system_identifier_single_quoted;

            return (data + 1);

        /* U+003E GREATER-THAN SIGN (>) */
        case 0x3E:
            tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
            tkz.state = &lxb_html_tokenizer_state_data_before;

            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIDOSYID);

            do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

            return (data + 1);

        /* EOF */
        case 0x00:
            if (tkz.is_eof) {
                lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                             LXB_HTML_TOKENIZER_ERROR_EOINDO);

                tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return end;
            }
            /* fall through */

            goto default; /* C fallthrough */
        default:
            tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;
            tkz.state = &lxb_html_tokenizer_state_doctype_bogus;

            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_MIQUBEDOSYID);

            return data;
    }

    return data;
}

/*
 * 12.2.5.65 DOCTYPE system identifier (double-quoted) state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_system_identifier_double_quoted(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    if (tkz.token.attr_last.value_begin == null && tkz.is_eof == false) {
        do { tkz.pos = tkz.start; tkz.token.attr_last.value_begin = data; } while (0);
    }

    (tkz.begin = data);

    while (data != end) {
        switch (*data) {
            /* U+0022 QUOTATION MARK (") */
            case 0x22:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                (tkz.token.attr_last.value_end = data);

                tkz.state =
                    &lxb_html_tokenizer_state_doctype_after_system_identifier;

                return (data + 1);

            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                tkz.state = &lxb_html_tokenizer_state_data_before;

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_ABDOSYID);

                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                (tkz.token.attr_last.value_end = data);
                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return (data + 1);

            /* U+000D CARRIAGE RETURN (CR) */
            case 0x0D:
                if (++data >= end) {
                    do { if (lxb_html_tokenizer_temp_append_data(tkz, data - 1)) { return end; } } while (0);

                    tkz.state = &lxb_html_tokenizer_state_cr;
                    tkz.state_return = &lxb_html_tokenizer_state_doctype_system_identifier_double_quoted;

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
                    (tkz.token.attr_last.value_end = tkz.last);

                    if (tkz.token.attr_last.value_begin == null) {
                        do { tkz.pos = tkz.start; tkz.token.attr_last.value_begin = tkz.token.attr_last.value_end; } while (0)
                                                                               ;
                    }

                    lxb_html_tokenizer_error_add(tkz.parse_errors,
                                               tkz.token.attr_last.value_end,
                                               LXB_HTML_TOKENIZER_ERROR_EOINDO);

                    tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                    do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                    do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                    return end;
                }

                (tkz.begin = data + 1);
                do { if (lxb_html_tokenizer_temp_append(tkz, lexbor_str_res_ansi_replacement_character.ptr, lexbor_str_res_ansi_replacement_character.sizeof - 1)) { return end; } } while (0);

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_UNNUCH);

                tkz.token.attr_last.type
                    |= LXB_HTML_TOKEN_ATTR_TYPE_VALUE_NULL;

                break;

            /* Anything else */
            default:
                break;
        }

        data++;
    }

    do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

    return data;
}

/*
 * 12.2.5.66 DOCTYPE system identifier (single-quoted) state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_system_identifier_single_quoted(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    if (tkz.token.attr_last.value_begin == null && tkz.is_eof == false) {
        do { tkz.pos = tkz.start; tkz.token.attr_last.value_begin = data; } while (0);
    }

    (tkz.begin = data);

    while (data != end) {
        switch (*data) {
            /* U+0027 APOSTROPHE (') */
            case 0x27:
                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                (tkz.token.attr_last.value_end = data);

                tkz.state =
                    &lxb_html_tokenizer_state_doctype_after_system_identifier;

                return (data + 1);

            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                tkz.state = &lxb_html_tokenizer_state_data_before;

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_ABDOSYID);

                do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);
                do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                (tkz.token.attr_last.value_end = data);
                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return (data + 1);

            /* U+000D CARRIAGE RETURN (CR) */
            case 0x0D:
                if (++data >= end) {
                    do { if (lxb_html_tokenizer_temp_append_data(tkz, data - 1)) { return end; } } while (0);

                    tkz.state = &lxb_html_tokenizer_state_cr;
                    tkz.state_return = &lxb_html_tokenizer_state_doctype_system_identifier_single_quoted;

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
                    (tkz.token.attr_last.value_end = tkz.last);

                    if (tkz.token.attr_last.value_begin == null) {
                        do { tkz.pos = tkz.start; tkz.token.attr_last.value_begin = tkz.token.attr_last.value_end; } while (0)
                                                                               ;
                    }

                    lxb_html_tokenizer_error_add(tkz.parse_errors,
                                               tkz.token.attr_last.value_end,
                                               LXB_HTML_TOKENIZER_ERROR_EOINDO);

                    tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                    do { lxb_html_token_attr_t* attr = tkz.token.attr_last; attr.value_size = cast(size_t) (tkz.pos - tkz.start); attr.value = cast(ubyte*) lexbor_mraw_alloc(tkz.attrs_mraw, attr.value_size + 1); if (attr.value == null) { tkz.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION; return end; } memcpy(attr.value, tkz.start, attr.value_size); attr.value[attr.value_size] = 0x00; } while (0);
                    do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                    return end;
                }

                (tkz.begin = data + 1);
                do { if (lxb_html_tokenizer_temp_append(tkz, lexbor_str_res_ansi_replacement_character.ptr, lexbor_str_res_ansi_replacement_character.sizeof - 1)) { return end; } } while (0);

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_UNNUCH);

                tkz.token.attr_last.type
                    |= LXB_HTML_TOKEN_ATTR_TYPE_VALUE_NULL;

                break;

            /* Anything else */
            default:
                break;
        }

        data++;
    }

    do { if (lxb_html_tokenizer_temp_append_data(tkz, data)) { return end; } } while (0);

    return data;
}

/*
 * 12.2.5.67 After DOCTYPE system identifier state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_after_system_identifier(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
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
            return (data + 1);

        /* U+003E GREATER-THAN SIGN (>) */
        case 0x3E:
            tkz.state = &lxb_html_tokenizer_state_data_before;

            do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

            return (data + 1);

        /* EOF */
        case 0x00:
            if (tkz.is_eof) {
                lxb_html_tokenizer_error_add(tkz.parse_errors, tkz.last,
                                             LXB_HTML_TOKENIZER_ERROR_EOINDO);

                tkz.token.type |= LXB_HTML_TOKEN_TYPE_FORCE_QUIRKS;

                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return end;
            }
            /* fall through */

            goto default; /* C fallthrough */
        default:
            lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                         LXB_HTML_TOKENIZER_ERROR_UNCHAFDOSYID);

            tkz.state = &lxb_html_tokenizer_state_doctype_bogus;

            return data;
    }

    return data;
}

/*
 * 12.2.5.68 Bogus DOCTYPE state
 */
private const(lxb_char_t)* lxb_html_tokenizer_state_doctype_bogus(lxb_html_tokenizer_t* tkz, const(lxb_char_t)* data, const(lxb_char_t)* end)
{
    while (data != end) {
        switch (*data) {
            /* U+003E GREATER-THAN SIGN (>) */
            case 0x3E:
                tkz.state = &lxb_html_tokenizer_state_data_before;

                do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                return (data + 1);

            /*
             * U+0000 NULL
             * EOF
             */
            case 0x00:
                if (tkz.is_eof) {
                    do { if (tkz.token.begin != tkz.token.end) { tkz.token = tkz.callback_token_done(tkz, tkz.token, tkz.callback_token_ctx); if (tkz.token == null) { if (tkz.status == LXB_STATUS_OK) { tkz.status = LXB_STATUS_ERROR; } return end; } } lxb_html_token_clean(tkz.token); tkz.pos = tkz.start; } while (0);

                    return end;
                }

                lxb_html_tokenizer_error_add(tkz.parse_errors, data,
                                             LXB_HTML_TOKENIZER_ERROR_UNNUCH);

                break;

            /* Anything else */
            default:
                break;
        }

        data++;
    }

    return data;
}
