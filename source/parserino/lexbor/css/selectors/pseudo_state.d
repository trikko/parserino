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
 * Copyright (C) 2020-2022 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */








private const(lxb_css_syntax_cb_components_t) lxb_css_selectors_comp = {
    state: &lxb_css_selectors_state_complex_list,
    block: null,
    failed: &lxb_css_state_failed,
    end: &lxb_css_selectors_state_pseudo_of_end
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

            rule = lxb_css_syntax_parser_components_push(parser, token,
                                                         &lxb_css_selectors_state_pseudo_of_back,
                                                         &lxb_css_selectors_comp, list,
                                                         LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS);
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
