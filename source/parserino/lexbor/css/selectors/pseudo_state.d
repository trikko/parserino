module parserino.lexbor.css.selectors.pseudo_state;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.base;
public import parserino.lexbor.css.parser;
public import parserino.lexbor.css.syntax.parser;
public import parserino.lexbor.css.selectors.base;
import parserino.lexbor.css.css;
import parserino.lexbor.css.selectors.selectors;

extern(C) @nogc nothrow:
__gshared:

// ---- pseudo_state.h ----
/*
 * Copyright (C) 2020-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
















// ---- pseudo_state.c ----
/*
 * Copyright (C) 2020-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */








private const(lxb_css_syntax_cb_components_t) lxb_css_selectors_comp = {
    prelude: &lxb_css_selectors_state_complex_list,
    cb: {failed: &lxb_css_state_failed, end: &lxb_css_selectors_state_pseudo_of_end}
};

 bool lxb_css_selectors_state_pseudo_anb_begin(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    cast(void) lxb_css_selectors_state_pseudo_anb(parser, token, ctx);
    if (parser.status != LXB_STATUS_OK) {
        parser.selectors.list = null;
        parser.selectors.list_last = null;

        return lxb_css_parser_failed(parser);
    }

    parser.selectors.list = null;

    return lxb_css_parser_success(parser);
}

bool lxb_css_selectors_state_pseudo_class_function__undef(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_parser_fail(parser, LXB_STATUS_ERROR_UNEXPECTED_DATA);
}

bool lxb_css_selectors_state_pseudo_class_function_current(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_set(parser, &lxb_css_selectors_state_complex_list);

    parser.selectors.list = null;
    parser.selectors.list_last = null;

    return true;
}

bool lxb_css_selectors_state_pseudo_class_function_dir(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_parser_fail(parser, LXB_STATUS_ERROR_UNEXPECTED_DATA);
}

bool lxb_css_selectors_state_pseudo_class_function_has(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_set(parser, &lxb_css_selectors_state_relative_list);

    parser.selectors.list = null;
    parser.selectors.list_last = null;

    return true;
}

bool lxb_css_selectors_state_pseudo_class_function_is(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_set(parser, &lxb_css_selectors_state_complex_list);

    parser.selectors.list = null;
    parser.selectors.list_last = null;

    return true;
}

bool lxb_css_selectors_state_pseudo_class_function_lang(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_parser_fail(parser, LXB_STATUS_ERROR_UNEXPECTED_DATA);
}

bool lxb_css_selectors_state_pseudo_class_function_not(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_set(parser, &lxb_css_selectors_state_complex_list);

    parser.selectors.list = null;
    parser.selectors.list_last = null;

    return true;
}

bool lxb_css_selectors_state_pseudo_class_function_nth_child(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_pseudo_of_begin(parser, token, ctx);
}

bool lxb_css_selectors_state_pseudo_class_function_nth_col(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_pseudo_anb_begin(parser, token, ctx);
}

bool lxb_css_selectors_state_pseudo_class_function_nth_last_child(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_pseudo_of_begin(parser, token, ctx);
}

bool lxb_css_selectors_state_pseudo_class_function_nth_last_col(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_pseudo_anb_begin(parser, token, ctx);
}

bool lxb_css_selectors_state_pseudo_class_function_nth_last_of_type(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_pseudo_anb_begin(parser, token, ctx);
}

bool lxb_css_selectors_state_pseudo_class_function_nth_of_type(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_pseudo_anb_begin(parser, token, ctx);
}

bool lxb_css_selectors_state_pseudo_class_function_where(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_set(parser, &lxb_css_selectors_state_complex_list);

    parser.selectors.list = null;
    parser.selectors.list_last = null;

    return true;
}

bool lxb_css_selectors_state_pseudo_element_function__undef(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return true;
}

bool lxb_css_selectors_state_pseudo_class_function_lexbor_contains(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_selectors_t* selectors = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selector_contains_t* contains = void;
    lexbor_str_t* str = void;
    const(lxb_char_t)* data = void;
    size_t length = void;

    selectors = parser.selectors;
    selector = selectors.list_last.last;

again:

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_STRING:
            data = token.types.string.data;
            length = token.types.string.length;
            break;

        case LXB_CSS_SYNTAX_TOKEN_IDENT:
            data = token.types.ident.data;
            length = token.types.ident.length;
            break;

        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            lxb_css_syntax_parser_consume(parser);
            do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);
            goto again;

        default:
            lxb_css_parser_unexpected_data(parser, token);
            return lxb_css_parser_failed(parser);
    }

    contains = cast(lxb_css_selector_contains_t*) lexbor_mraw_alloc(parser.memory.mraw,
                            lxb_css_selector_contains_t.sizeof);
    if (contains == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    contains.insensitive = false;
    str = &contains.str;

    str.data = cast(ubyte*) lexbor_mraw_alloc(parser.memory.mraw, length + 1);
    if (str.data == null) {
        lexbor_mraw_free(parser.memory.mraw, contains);
        return lxb_css_parser_memory_fail(parser);
    }

    memcpy(str.data, data, length);

    str.length = length;
    str.data[length] = '\0';

    selector.u.pseudo.data = contains;

again_end:

    lxb_css_syntax_parser_consume(parser);
    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN__END:
            break;

        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            goto again_end;

        case LXB_CSS_SYNTAX_TOKEN_IDENT:
            data = token.types.ident.data;
            length = token.types.ident.length;

            if (length == 1 && (*data == 'i' || *data == 'I')) {
                contains.insensitive = true;

                lxb_css_syntax_parser_consume(parser);
                do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);

                if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
                    lxb_css_syntax_parser_consume(parser);
                    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);
                }

                if (token.type != LXB_CSS_SYNTAX_TOKEN__END) {
                    goto failed;
                }

                break;
            }
            /* Fall through. */

            goto default; /* C fallthrough */
        default:
            goto failed;
    }

    parser.selectors.list = null;

    return lxb_css_parser_success(parser);

failed:

    lexbor_mraw_free(parser.memory.mraw, contains.str.data);
    lexbor_mraw_free(parser.memory.mraw, contains);

    selector.u.pseudo.data = null;

    lxb_css_parser_unexpected_data(parser, token);
    return lxb_css_parser_failed(parser);
}

private bool lxb_css_selectors_state_pseudo_anb(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_selectors_t* selectors = void;
    lxb_css_selector_list_t* list = void;
    lxb_css_selector_anb_of_t* anbof = void;

    selectors = parser.selectors;

    anbof = cast(lxb_css_selector_anb_of_t*) lexbor_mraw_alloc(parser.memory.mraw,
                              lxb_css_selector_anb_of_t.sizeof);
    if (anbof == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    parser.status = lxb_css_syntax_anb_handler(parser, token, &anbof.anb);
    if (parser.status != LXB_STATUS_OK) {
        lexbor_mraw_free(parser.memory.mraw, anbof);
        return true;
    }

    list = selectors.list_last;
    list.last.u.pseudo.data = anbof;

    anbof.of = null;

    return true;
}

private bool lxb_css_selectors_state_pseudo_of_begin(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_syntax_rule_t* rule = void;
    lxb_css_selectors_t* selectors = void;
    lxb_css_selector_list_t* list = void;
    lxb_css_syntax_token_ident_t* ident = void;

    static const(lxb_char_t)[3] of = lexbor_carray!"of";

    selectors = parser.selectors;

    cast(void) lxb_css_selectors_state_pseudo_anb(parser, token, ctx);
    if (parser.status != LXB_STATUS_OK) {
        selectors.list = null;
        selectors.list_last = null;

        token = lxb_css_syntax_parser_token(parser);
        if (token == null) {
            return lxb_css_parser_memory_fail(parser);
        }

        if (token.type != LXB_CSS_SYNTAX_TOKEN__END) {
            if (lxb_css_syntax_token_error(parser, token, "Selectors") == null) {
                return lxb_css_parser_memory_fail(parser);
            }
        }

        return lxb_css_parser_failed(parser);
    }

    list = selectors.list_last;

    selectors.list = null;

    do { token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) { lxb_css_syntax_parser_consume(parser); token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } } while (false);

    if (token.type == LXB_CSS_SYNTAX_TOKEN_IDENT) {
        ident = (cast(lxb_css_syntax_token_ident_t*) (token));

        if (ident.length == of.sizeof - 1
            && lexbor_str_data_ncasecmp(ident.data, of.ptr, ident.length))
        {
            lxb_css_syntax_token_consume(parser.tkz);

            selectors.list = null;
            selectors.list_last = null;

            token = lxb_css_syntax_parser_token(parser);
            if (token == null) {
                return lxb_css_parser_memory_fail(parser);
            }

            rule = lxb_css_syntax_parser_components_push(parser,
                                                         &lxb_css_selectors_comp,
                                                         &lxb_css_selectors_state_pseudo_of_back,
                                                         list, LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS);
//            rule = lxb_css_syntax_parser_components_push(parser, token,
//                                                         lxb_css_selectors_state_pseudo_of_back,
//                                                         &lxb_css_selectors_comp, list,
//                                                         LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS);
            if (rule == null) {
                lexbor_mraw_free(parser.memory.mraw,
                                 list.last.u.pseudo.data);
                return lxb_css_parser_memory_fail(parser);
            }

            lxb_css_parser_state_set(parser,
                                     &lxb_css_selectors_state_complex_list);
            return true;
        }
    }

    return lxb_css_parser_success(parser);
}

private lxb_status_t lxb_css_selectors_state_pseudo_of_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed)
{
    lxb_css_selector_anb_of_t* anbof = void;
    lxb_css_selector_list_t* list = cast(lxb_css_selector_list*) ctx;

    anbof = cast(lxb_css_selector_anb_of_t*) list.last.u.pseudo.data;
    anbof.of = parser.selectors.list;

    parser.selectors.list = null;

    return LXB_STATUS_OK;
}

private bool lxb_css_selectors_state_pseudo_of_back(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    parser.selectors.list = null;

    return lxb_css_parser_success(parser);
}
