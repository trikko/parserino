module parserino.lexbor.css.selectors.state;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.parser;
public import parserino.lexbor.css.selectors.base;
import parserino.lexbor.css.css;
import parserino.lexbor.css.selectors.selectors;
import parserino.lexbor.css.selectors.pseudo;
import parserino.lexbor.css.selectors.pseudo_const;

extern(C) @nogc nothrow:
__gshared:

// ---- state.h ----
/*
 * Copyright (C) 2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */











 bool lxb_css_selectors_state_fail(lxb_css_parser_t* parser)
{
    parser.status = LXB_STATUS_ERROR_UNEXPECTED_DATA;

    cast(void) lxb_css_parser_states_pop(parser);

    return false;
}

// ---- state.c ----
/*
 * Copyright (C) 2020-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

private const(char)[10] lxb_css_selectors_module_name = "Selectors";

































































 bool lxb_css_selectors_done(lxb_css_parser_t* parser)
{
    lxb_css_parser_states_pop(parser);

    return lxb_css_parser_states_set_back(parser);
}

 void lxb_css_selectors_state_specificity_set_b(lxb_css_selectors_t* selectors)
{
    lxb_css_selector_list_t* last = selectors.list_last;

    if (selectors.parent == null) {
        last.specificity = ((((last.specificity)) & ~(((cast(uint) 1 << 9) - 1) << (9))) | (((((last.specificity) >> 9) & ~LXB_CSS_SELECTOR_SPECIFICITY_MASK) + 1) << 9))
                                                                               ;
    }
    else if (last.specificity > LXB_CSS_SELECTOR_SP_B_MAX) {
        if (selectors.combinator == LXB_CSS_SELECTOR_COMBINATOR_CLOSE) {
            last.specificity = ((((last.specificity)) & ~(((cast(uint) 1 << 9) - 1) << (9))) | ((1) << 9));
        }
    }
    else {
        if (selectors.combinator != LXB_CSS_SELECTOR_COMBINATOR_CLOSE) {
            last.specificity = 0;
        }

        last.specificity = ((((last.specificity)) & ~(((cast(uint) 1 << 9) - 1) << (9))) | ((1) << 9));
    }
}

 void lxb_css_selectors_state_specificity_set_c(lxb_css_selectors_t* selectors)
{
    lxb_css_selector_list_t* last = selectors.list_last;

    if (selectors.parent == null) {
        last.specificity = ((((last.specificity)) & ~(((cast(uint) 1 << 9) - 1) << (0))) | (((last.specificity) & ~LXB_CSS_SELECTOR_SPECIFICITY_MASK) + 1))
                                                                               ;
    }
    else if (last.specificity > LXB_CSS_SELECTOR_SP_C_MAX) {
        if (selectors.combinator == LXB_CSS_SELECTOR_COMBINATOR_CLOSE) {
            last.specificity = ((((last.specificity)) & ~(((cast(uint) 1 << 9) - 1) << (0))) | (1));
        }
    }
    else {
        if (selectors.combinator != LXB_CSS_SELECTOR_COMBINATOR_CLOSE) {
            last.specificity = 0;
        }

        last.specificity = ((((last.specificity)) & ~(((cast(uint) 1 << 9) - 1) << (0))) | (1));
    }
}

 void lxb_css_selectors_state_func_specificity(lxb_css_selectors_t* selectors)
{
    lxb_css_selector_list_t* prev = void, last = void;

    last = selectors.list_last;
    prev = last.prev;

    if (prev.specificity > last.specificity) {
        last.specificity = prev.specificity;
    }

    prev.specificity = 0;
}

/*
 * <complex-selector-list>
 */
bool lxb_css_selectors_state_complex_list(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_t* states = void;

    states = lxb_css_parser_states_next(parser,
                                        &lxb_css_selectors_state_complex_wo_root,
                                        &lxb_css_selectors_state_complex_list_end,
                                        ctx, true);
    if (states == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    return false;
}

private bool lxb_css_selectors_state_complex_list_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_list_end(parser, token,
                                            &lxb_css_selectors_state_complex_wo_root);
}

/*
 * <relative-selector-list>
 */
bool lxb_css_selectors_state_relative_list(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_t* states = void;

    states = lxb_css_parser_states_next(parser,
                                        &lxb_css_selectors_state_relative_list_wo_root,
                                        &lxb_css_selectors_state_relative_list_end,
                                        ctx, true);
    if (states == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    return false;
}

private bool lxb_css_selectors_state_relative_list_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_list_end(parser, token,
                                            &lxb_css_selectors_state_relative_list_wo_root);
}

/*
 * <relative-selector>
 */
bool lxb_css_selectors_state_relative(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_t* states = void;

    states = lxb_css_parser_states_next(parser,
                                        &lxb_css_selectors_state_relative_wo_root,
                                        &lxb_css_selectors_state_end,
                                        ctx, true);
    if (states == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    return false;
}

private bool lxb_css_selectors_state_relative_list_wo_root(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_relative_handler(parser, token, ctx, true,
                                                    false);
}

private bool lxb_css_selectors_state_relative_wo_root(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_relative_handler(parser, token, ctx, false,
                                                    false);
}

private bool lxb_css_selectors_state_relative_handler(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool list, bool root)
{
    lxb_css_parser_state_f back = void;
    lxb_css_parser_state_t* states = void;
    lxb_css_selectors_t* selectors = parser.selectors;

    /* <combinator> */

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            lxb_css_syntax_parser_consume(parser);
            selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT;
            return true;

        case LXB_CSS_SYNTAX_TOKEN_DELIM:
            switch (((cast(lxb_css_syntax_token_delim_t*) (token)).character)) {
                case '>':
                    selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_CHILD;
                    break;

                case '+':
                    selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_SIBLING;
                    break;

                case '~':
                    selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_FOLLOWING;
                    break;

                case '|':
                    do { token = lxb_css_syntax_token_next((parser).tkz); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);

                    if (token.type == LXB_CSS_SYNTAX_TOKEN_DELIM
                        && ((cast(lxb_css_syntax_token_delim_t*) (token)).character) == '|')
                    {
                        lxb_css_syntax_parser_consume(parser);
                        selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_CELL;
                        break;
                    }

                    goto done;

                default:
                    goto done;
            }

            break;

        default:
            goto done;
    }

    lxb_css_syntax_parser_consume(parser);

done:

    back = (list) ? &lxb_css_selectors_state_complex_end
                  : &lxb_css_selectors_state_end;

    states = lxb_css_parser_states_next(parser,
                                        &lxb_css_selectors_state_compound_wo_root,
                                        back, ctx, root);
    if (states == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    return true;
}

/*
 * <complex-selector>
 */
bool lxb_css_selectors_state_complex(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_t* states = void;

    states = lxb_css_parser_states_next(parser,
                                        &lxb_css_selectors_state_complex_wo_root,
                                        &lxb_css_selectors_state_end,
                                        ctx, true);
    if (states == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    return false;
}

private bool lxb_css_selectors_state_complex_wo_root(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_complex_handler(parser, token, ctx, false);
}

private bool lxb_css_selectors_state_complex_handler(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool root)
{
    lxb_css_parser_state_t* states = void;

    states = lxb_css_parser_states_next(parser,
                                        &lxb_css_selectors_state_compound_wo_root,
                                        &lxb_css_selectors_state_complex_end,
                                        ctx, root);
    if (states == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    return false;
}

private bool lxb_css_selectors_state_complex_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_selectors_t* selectors = parser.selectors;

    /* <combinator> */

again:

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            lxb_css_syntax_parser_consume(parser);

            selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT;

            do { token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);
            goto again;

        case LXB_CSS_SYNTAX_TOKEN__END:
            return lxb_css_selectors_done(parser);

        case LXB_CSS_SYNTAX_TOKEN_DELIM:
            switch (((cast(lxb_css_syntax_token_delim_t*) (token)).character)) {
                case '>':
                    selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_CHILD;
                    break;

                case '+':
                    selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_SIBLING;
                    break;

                case '~':
                    selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_FOLLOWING;
                    break;

                case '|':
                    do { token = lxb_css_syntax_token_next((parser).tkz); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);

                    if (token.type == LXB_CSS_SYNTAX_TOKEN_DELIM
                        && ((cast(lxb_css_syntax_token_delim_t*) (token)).character) == '|')
                    {
                        lxb_css_syntax_parser_consume(parser);
                        selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_CELL;
                        break;
                    }

                    goto done;

                default:
                    if (selectors.combinator != LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT) {
                        goto unexpected;
                    }

                    goto done;
            }

            break;

        case LXB_CSS_SYNTAX_TOKEN_COMMA:
            return lxb_css_selectors_done(parser);

        default:
            if (selectors.combinator != LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT) {
                goto unexpected;
            }

            goto done;
    }

    lxb_css_syntax_parser_consume(parser);

done:

    lxb_css_parser_state_set(parser, &lxb_css_selectors_state_compound_handler);

    return true;

unexpected:

    cast(void) lxb_css_selectors_done(parser);

    return lxb_css_parser_unexpected(parser);
}

/*
 * <compound-selector-list>
 */
bool lxb_css_selectors_state_compound_list(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_t* states = void;

    states = lxb_css_parser_states_next(parser,
                                        &lxb_css_selectors_state_compound_wo_root,
                                        &lxb_css_selectors_state_compound_list_end,
                                        ctx, true);
    if (states == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    return false;
}

private bool lxb_css_selectors_state_compound_list_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_list_end(parser, token,
                                            &lxb_css_selectors_state_compound_wo_root);
}

/*
 *
 * <compound-selector>
 */
bool lxb_css_selectors_state_compound(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_t* states = void;

    states = lxb_css_parser_states_next(parser,
                                        &lxb_css_selectors_state_compound_wo_root,
                                        &lxb_css_selectors_state_end,
                                        ctx, true);
    if (states == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    return false;
}

private bool lxb_css_selectors_state_compound_wo_root(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_selector_list_t* list = void;

    do { (list) = lxb_css_selector_list_create((parser).memory); if ((list) == null) { return lxb_css_parser_memory_fail(parser); } lxb_css_selectors_list_append_next((parser.selectors), (list)); (list).parent = parser.selectors.parent; } while (false);

    lxb_css_parser_state_set(parser, &lxb_css_selectors_state_compound_handler);

    return false;
}

private bool lxb_css_selectors_state_compound_handler(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_status_t status = void;
    lxb_css_selectors_t* selectors = void;

again:

    lxb_css_parser_state_set(parser, &lxb_css_selectors_state_compound_sub);

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_HASH:
            status = lxb_css_selectors_state_hash(parser, token);
            break;

        case LXB_CSS_SYNTAX_TOKEN_DELIM:
            switch (((cast(lxb_css_syntax_token_delim_t*) (token)).character)) {
                case '.':
                    lxb_css_syntax_parser_consume(parser);
                    status = lxb_css_selectors_state_class(parser, token);
                    break;

                case '|':
                case '*':
                    status = lxb_css_selectors_state_element_ns(parser, token);
                    break;

                default:
                    goto unexpected;
            }

            break;

        case LXB_CSS_SYNTAX_TOKEN_IDENT:
            status = lxb_css_selectors_state_element(parser, token);
            break;

        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            lxb_css_syntax_parser_consume(parser);
            status = lxb_css_selectors_state_attribute(parser);
            break;

        case LXB_CSS_SYNTAX_TOKEN_COLON:
            lxb_css_syntax_parser_consume(parser);
            do { token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);

            if (token.type == LXB_CSS_SYNTAX_TOKEN_IDENT) {
                status = lxb_css_selectors_state_pseudo_class(parser, token);
                break;
            }
            else if (token.type == LXB_CSS_SYNTAX_TOKEN_COLON) {
                lxb_css_syntax_parser_consume(parser);
                do { token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);

                if (token.type == LXB_CSS_SYNTAX_TOKEN_IDENT) {
                    lxb_css_parser_state_set(parser,
                                             &lxb_css_selectors_state_compound_pseudo);
                    status = lxb_css_selectors_state_pseudo_element(parser, token);
                    break;
                }
                else if (token.type != LXB_CSS_SYNTAX_TOKEN_FUNCTION) {
                    return lxb_css_parser_unexpected(parser);
                }

                status = lxb_css_selectors_state_pseudo_element_function(parser, token,
                                               &lxb_css_selectors_state_compound_pseudo);
                break;
            }
            else if (token.type != LXB_CSS_SYNTAX_TOKEN_FUNCTION) {
                goto unexpected;
            }

            status = lxb_css_selectors_state_pseudo_class_function(parser, token,
                                            &lxb_css_selectors_state_compound_sub);
            break;

        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            lxb_css_syntax_parser_consume(parser);
            do { token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);
            goto again;

        case LXB_CSS_SYNTAX_TOKEN__END:
            selectors = parser.selectors;

            if (selectors.combinator > LXB_CSS_SELECTOR_COMBINATOR_CLOSE
                || selectors.list_last.first == null)
            {
                goto unexpected;
            }

            return lxb_css_selectors_done(parser);

        default:
            goto unexpected;
    }

    if (status == LXB_STATUS_OK) {
        return true;
    }

    if (status == LXB_STATUS_ERROR_MEMORY_ALLOCATION) {
        return lxb_css_parser_memory_fail(parser);
    }

unexpected:

    cast(void) lxb_css_parser_states_to_root(parser);
    cast(void) lxb_css_parser_states_set_back(parser);

    return lxb_css_parser_unexpected(parser);
}

private bool lxb_css_selectors_state_compound_sub(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_status_t status = void;

    /* <subclass-selector> */

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_HASH:
            status = lxb_css_selectors_state_hash(parser, token);
            break;

        case LXB_CSS_SYNTAX_TOKEN_DELIM:
            switch (((cast(lxb_css_syntax_token_delim_t*) (token)).character)) {
                case '.':
                    lxb_css_syntax_parser_consume(parser);
                    status = lxb_css_selectors_state_class(parser, token);
                    break;

                default:
                    return lxb_css_parser_states_set_back(parser);
            }

            break;

        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            lxb_css_syntax_parser_consume(parser);
            status = lxb_css_selectors_state_attribute(parser);
            break;

        case LXB_CSS_SYNTAX_TOKEN_COLON:
            lxb_css_syntax_parser_consume(parser);
            do { token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);

            if (token.type == LXB_CSS_SYNTAX_TOKEN_IDENT) {
                status = lxb_css_selectors_state_pseudo_class(parser, token);
                break;
            }
            else if (token.type == LXB_CSS_SYNTAX_TOKEN_COLON) {
                lxb_css_syntax_parser_consume(parser);
                do { token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);

                if (token.type == LXB_CSS_SYNTAX_TOKEN_IDENT) {
                    lxb_css_parser_state_set(parser,
                                      &lxb_css_selectors_state_compound_pseudo);
                    status = lxb_css_selectors_state_pseudo_element(parser,
                                                                    token);
                    break;
                }
                else if (token.type != LXB_CSS_SYNTAX_TOKEN_FUNCTION) {
                    return lxb_css_parser_unexpected(parser);
                }

                status = lxb_css_selectors_state_pseudo_element_function(parser,
                                token, &lxb_css_selectors_state_compound_pseudo);
                break;
            }
            else if (token.type != LXB_CSS_SYNTAX_TOKEN_FUNCTION) {
                return lxb_css_parser_unexpected(parser);
            }

            status = lxb_css_selectors_state_pseudo_class_function(parser, token,
                                            &lxb_css_selectors_state_compound_sub);
            break;

        default:
            return lxb_css_parser_states_set_back(parser);
    }

    if (status == LXB_STATUS_OK) {
        return true;
    }

    if (status == LXB_STATUS_ERROR_MEMORY_ALLOCATION) {
        return lxb_css_parser_memory_fail(parser);
    }

    return lxb_css_parser_unexpected(parser);
}

private bool lxb_css_selectors_state_compound_pseudo(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_status_t status = void;

    if (token.type != LXB_CSS_SYNTAX_TOKEN_COLON) {
        return lxb_css_parser_states_set_back(parser);
    }

    lxb_css_syntax_parser_consume(parser);
    do { token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);

    if (token.type == LXB_CSS_SYNTAX_TOKEN_IDENT) {
        status = lxb_css_selectors_state_pseudo_class(parser, token);
    }
    else if (token.type == LXB_CSS_SYNTAX_TOKEN_COLON) {
        lxb_css_syntax_parser_consume(parser);
        do { token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);

        if (token.type == LXB_CSS_SYNTAX_TOKEN_IDENT) {
            status = lxb_css_selectors_state_pseudo_element(parser, token);
        }
        else if (token.type == LXB_CSS_SYNTAX_TOKEN_FUNCTION) {
            status = lxb_css_selectors_state_pseudo_element_function(parser, token,
                                           &lxb_css_selectors_state_compound_pseudo);
        }
        else {
            return lxb_css_parser_unexpected(parser);
        }
    }
    else if (token.type != LXB_CSS_SYNTAX_TOKEN_FUNCTION) {
        return lxb_css_parser_unexpected(parser);
    }
    else {
        status = lxb_css_selectors_state_pseudo_class_function(parser, token,
                                       &lxb_css_selectors_state_compound_pseudo);
    }

    if (status == LXB_STATUS_OK) {
        return true;
    }

    if (status == LXB_STATUS_ERROR_MEMORY_ALLOCATION) {
        return lxb_css_parser_memory_fail(parser);
    }

    return lxb_css_parser_unexpected(parser);
}

/*
 * <simple-selector-list>
 */
bool lxb_css_selectors_state_simple_list(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_t* states = void;

    states = lxb_css_parser_states_next(parser, &lxb_css_selectors_state_simple_wo_root,
                                        &lxb_css_selectors_state_simple_list_end,
                                        ctx, true);
    if (states == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    return false;
}

private bool lxb_css_selectors_state_simple_list_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_selectors_state_list_end(parser, token,
                                            &lxb_css_selectors_state_simple_wo_root);
}

/*
 * <simple-selector>
 */
bool lxb_css_selectors_state_simple(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_t* states = void;

    states = lxb_css_parser_states_next(parser,
                                        &lxb_css_selectors_state_simple_wo_root,
                                        &lxb_css_selectors_state_end,
                                        ctx, true);
    if (states == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    return false;
}

private bool lxb_css_selectors_state_simple_wo_root(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_selector_list_t* list = void;

    do { (list) = lxb_css_selector_list_create((parser).memory); if ((list) == null) { return lxb_css_parser_memory_fail(parser); } lxb_css_selectors_list_append_next((parser.selectors), (list)); (list).parent = parser.selectors.parent; } while (false);

    lxb_css_parser_state_set(parser, &lxb_css_selectors_state_simple_handler);

    return false;
}

private bool lxb_css_selectors_state_simple_handler(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_status_t status = void;

again:

    lxb_css_parser_state_set(parser, &lxb_css_selectors_state_simple_back);

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_HASH:
            status = lxb_css_selectors_state_hash(parser, token);
            break;

        case LXB_CSS_SYNTAX_TOKEN_DELIM:
            switch (((cast(lxb_css_syntax_token_delim_t*) (token)).character)) {
                case '.':
                    lxb_css_syntax_parser_consume(parser);
                    status = lxb_css_selectors_state_class(parser, token);
                    break;

                case '|':
                case '*':
                    status = lxb_css_selectors_state_element_ns(parser, token);
                    break;

                default:
                    goto unexpected;
            }

            break;

        case LXB_CSS_SYNTAX_TOKEN_IDENT:
            status = lxb_css_selectors_state_element(parser, token);
            break;

        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            lxb_css_syntax_parser_consume(parser);
            status = lxb_css_selectors_state_attribute(parser);
            break;

        case LXB_CSS_SYNTAX_TOKEN_COLON:
            lxb_css_syntax_parser_consume(parser);
            do { token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);

            if (token.type == LXB_CSS_SYNTAX_TOKEN_IDENT) {
                status = lxb_css_selectors_state_pseudo_class(parser, token);
                break;
            }
            else if (token.type != LXB_CSS_SYNTAX_TOKEN_FUNCTION) {
                goto unexpected;
            }

            status = lxb_css_selectors_state_pseudo_class_function(parser, token,
                                           &lxb_css_selectors_state_simple_back);
            break;

        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            lxb_css_syntax_parser_consume(parser);
            do { token = lxb_css_syntax_parser_token(parser); if (token == null) { return lxb_css_parser_fail((parser), (parser).tkz.status); } } while (false);
            goto again;

        case LXB_CSS_SYNTAX_TOKEN__END:
            return lxb_css_parser_states_set_back(parser);

        default:
            goto unexpected;
    }

    if (status == LXB_STATUS_OK) {
        return true;
    }

    if (status == LXB_STATUS_ERROR_MEMORY_ALLOCATION) {
        return lxb_css_parser_memory_fail(parser);
    }

unexpected:

    cast(void) lxb_css_parser_states_set_back(parser);

    return lxb_css_parser_unexpected(parser);
}

private bool lxb_css_selectors_state_simple_back(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_parser_states_set_back(parser);
}

private lxb_status_t lxb_css_selectors_state_hash(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token)
{
    lxb_status_t status = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = void;
    lxb_css_selector_list_t* last = void;

    selectors = parser.selectors;
    last = selectors.list_last;

    if (selectors.parent == null) {
        last.specificity = ((((last.specificity)) & ~(((cast(uint) 1 << 9) - 1) << (18))) | (((((last.specificity) >> 18) & ~LXB_CSS_SELECTOR_SPECIFICITY_MASK) + 1) << 18))
                                                                               ;
    }
    else if ((((last.specificity) >> 18) & ~LXB_CSS_SELECTOR_SPECIFICITY_MASK) == 0) {
        if (selectors.combinator != LXB_CSS_SELECTOR_COMBINATOR_CLOSE) {
            last.specificity = 0;
        }

        last.specificity = ((((last.specificity)) & ~(((cast(uint) 1 << 9) - 1) << (18))) | ((1) << 18));
    }

    do { (selector) = lxb_css_selector_create((selectors).list_last); if ((selector) == null) { return lxb_css_parser_memory_fail(parser); } lxb_css_selectors_append_next((selectors), (selector)); (selector).combinator = (selectors).combinator; (selectors).combinator = LXB_CSS_SELECTOR_COMBINATOR_CLOSE; } while (false);

    selector.type = LXB_CSS_SELECTOR_TYPE_ID;

    status = lxb_css_syntax_token_string_dup((cast(lxb_css_syntax_token_string_t*) (token)),
                                             &selector.name, parser.memory.mraw);
    lxb_css_syntax_parser_consume(parser);

    return status;
}

private lxb_status_t lxb_css_selectors_state_class(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token)
{
    lxb_status_t status = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = void;

    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);

    if (token.type == LXB_CSS_SYNTAX_TOKEN_IDENT) {
        selectors = parser.selectors;

        lxb_css_selectors_state_specificity_set_b(selectors);
        do { (selector) = lxb_css_selector_create((selectors).list_last); if ((selector) == null) { return lxb_css_parser_memory_fail(parser); } lxb_css_selectors_append_next((selectors), (selector)); (selector).combinator = (selectors).combinator; (selectors).combinator = LXB_CSS_SELECTOR_COMBINATOR_CLOSE; } while (false);

        selector.type = LXB_CSS_SELECTOR_TYPE_CLASS;

        status = lxb_css_syntax_token_string_dup((cast(lxb_css_syntax_token_string_t*) (token)),
                                                 &selector.name, parser.memory.mraw);
        lxb_css_syntax_parser_consume(parser);

        return status;
    }

    return lxb_css_parser_unexpected_status(parser);
}

private lxb_status_t lxb_css_selectors_state_element_ns(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token)
{
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = void;

    selectors = parser.selectors;

    do { (selector) = lxb_css_selector_create((selectors).list_last); if ((selector) == null) { return lxb_css_parser_memory_fail(parser); } lxb_css_selectors_append_next((selectors), (selector)); (selector).combinator = (selectors).combinator; (selectors).combinator = LXB_CSS_SELECTOR_COMBINATOR_CLOSE; } while (false);

    selector.type = LXB_CSS_SELECTOR_TYPE_ANY;

    selector.name.data = cast(ubyte*) lexbor_mraw_alloc(parser.memory.mraw, 2);
    if (selector.name.data == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    selector.name.data[0] = '*';
    selector.name.data[1] = '\0';
    selector.name.length = 1;

    if (((cast(lxb_css_syntax_token_delim_t*) (token)).character) == '*') {
        lxb_css_syntax_parser_consume(parser);
        return lxb_css_selectors_state_ns(parser, selector);
    }

    selector.name.data[0] = '\0';
    selector.name.length = 0;

    lxb_css_syntax_parser_consume(parser);

    return lxb_css_selectors_state_ns_ident(parser, selector);
}

private lxb_status_t lxb_css_selectors_state_element(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token)
{
    lxb_status_t status = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = void;

    selectors = parser.selectors;

    lxb_css_selectors_state_specificity_set_c(selectors);

    do { (selector) = lxb_css_selector_create((selectors).list_last); if ((selector) == null) { return lxb_css_parser_memory_fail(parser); } lxb_css_selectors_append_next((selectors), (selector)); (selector).combinator = (selectors).combinator; (selectors).combinator = LXB_CSS_SELECTOR_COMBINATOR_CLOSE; } while (false);

    selector.type = LXB_CSS_SELECTOR_TYPE_ELEMENT;

    do { (status) = lxb_css_syntax_token_string_dup( (cast(lxb_css_syntax_token_string_t*) (token)), (&selector.name), (parser).memory.mraw); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    lxb_css_syntax_parser_consume(parser);

    return lxb_css_selectors_state_ns(parser, selector);
}

private lxb_status_t lxb_css_selectors_state_attribute(lxb_css_parser_t* parser)
{
    lxb_char_t modifier = void;
    lxb_status_t status = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = void;
    const(lxb_css_syntax_token_t)* token = void;
    lxb_css_selector_attribute_t* attribute = void;

    selectors = parser.selectors;

    do { (selector) = lxb_css_selector_create((selectors).list_last); if ((selector) == null) { return lxb_css_parser_memory_fail(parser); } lxb_css_selectors_append_next((selectors), (selector)); (selector).combinator = (selectors).combinator; (selectors).combinator = LXB_CSS_SELECTOR_COMBINATOR_CLOSE; } while (false);
    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) { lxb_css_syntax_parser_consume(parser); if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } } while (false);

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_DELIM:
            if (((cast(lxb_css_syntax_token_delim_t*) (token)).character) != '|') {
                goto failed;
            }

            lxb_css_syntax_parser_consume(parser);
            do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);

            if (token.type != LXB_CSS_SYNTAX_TOKEN_IDENT) {
                goto failed;
            }

            selector.type = LXB_CSS_SELECTOR_TYPE_ATTRIBUTE;

            selector.ns.data = cast(ubyte*) lexbor_mraw_alloc(parser.memory.mraw, 2);
            if (selector.ns.data == null) {
                return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            }

            selector.ns.data[0] = '*';
            selector.ns.data[1] = '\0';
            selector.ns.length = 1;

            do { (status) = lxb_css_syntax_token_string_dup( (cast(lxb_css_syntax_token_string_t*) (token)), (&selector.name), (parser).memory.mraw); if ((status) != LXB_STATUS_OK) { return (status); } } while (false)
                                                                 ;

            lxb_css_syntax_parser_consume(parser);
            do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) { lxb_css_syntax_parser_consume(parser); if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } } while (false);
            break;

        case LXB_CSS_SYNTAX_TOKEN_IDENT:
            selector.type = LXB_CSS_SELECTOR_TYPE_ATTRIBUTE;

            do { (status) = lxb_css_syntax_token_string_dup( (cast(lxb_css_syntax_token_string_t*) (token)), (&selector.name), (parser).memory.mraw); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

            lxb_css_syntax_parser_consume(parser);
            do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);

            if (token.type != LXB_CSS_SYNTAX_TOKEN_DELIM
                || ((cast(lxb_css_syntax_token_delim_t*) (token)).character) != '|')
            {
                if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
                    lxb_css_syntax_parser_consume(parser);
                    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);
                }

                break;
            }

            lxb_css_syntax_parser_consume(parser);
            do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);

            if (token.type != LXB_CSS_SYNTAX_TOKEN_IDENT) {
                attribute = &selector.u.attribute;
                attribute.match = LXB_CSS_SELECTOR_MATCH_DASH;

                goto assignment;
            }

            selector.ns = selector.name;
            lexbor_str_clean_all(&selector.name);

            do { (status) = lxb_css_syntax_token_string_dup( (cast(lxb_css_syntax_token_string_t*) (token)), (&selector.name), (parser).memory.mraw); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

            lxb_css_syntax_parser_consume(parser);
            do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) { lxb_css_syntax_parser_consume(parser); if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } } while (false);
            break;

        default:
            goto failed;
    }

    attribute = &selector.u.attribute;

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_RS_BRACKET:
            goto done;

        case LXB_CSS_SYNTAX_TOKEN_DELIM:
            switch (((cast(lxb_css_syntax_token_delim_t*) (token)).character)) {
                case '~':
                    attribute.match = LXB_CSS_SELECTOR_MATCH_INCLUDE;
                    break;

                case '|':
                    attribute.match = LXB_CSS_SELECTOR_MATCH_DASH;
                    break;

                case '^':
                    attribute.match = LXB_CSS_SELECTOR_MATCH_PREFIX;
                    break;

                case '$':
                    attribute.match = LXB_CSS_SELECTOR_MATCH_SUFFIX;
                    break;

                case '*':
                    attribute.match = LXB_CSS_SELECTOR_MATCH_SUBSTRING;
                    break;

                case '=':
                    attribute.match = LXB_CSS_SELECTOR_MATCH_EQUAL;

                    lxb_css_syntax_parser_consume(parser);
                    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) { lxb_css_syntax_parser_consume(parser); if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } } while (false);
                    goto string_or_ident;

                default:
                    goto failed;
            }

            lxb_css_syntax_parser_consume(parser);
            do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);

            break;

        case LXB_CSS_SYNTAX_TOKEN__END:
            goto done_eof;

        default:
            goto failed;
    }

assignment:

    if (token.type != LXB_CSS_SYNTAX_TOKEN_DELIM
        || ((cast(lxb_css_syntax_token_delim_t*) (token)).character) != '=')
    {
        goto failed;
    }

    lxb_css_syntax_parser_consume(parser);
    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) { lxb_css_syntax_parser_consume(parser); if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } } while (false);

string_or_ident:

    if (token.type != LXB_CSS_SYNTAX_TOKEN_STRING
        && token.type != LXB_CSS_SYNTAX_TOKEN_IDENT)
    {
        goto failed;
    }

    do { (status) = lxb_css_syntax_token_string_dup( (cast(lxb_css_syntax_token_string_t*) (token)), (&attribute.value), (parser).memory.mraw); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    lxb_css_syntax_parser_consume(parser);
    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) { lxb_css_syntax_parser_consume(parser); if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } } while (false);

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_RS_BRACKET:
            goto done;

        case LXB_CSS_SYNTAX_TOKEN_IDENT:
            if ((cast(lxb_css_syntax_token_string_t*) (token)).length != 1) {
                goto failed;
            }

            break;

        case LXB_CSS_SYNTAX_TOKEN__END:
            goto done_eof;

        default:
            goto failed;
    }

    modifier = *(cast(lxb_css_syntax_token_string_t*) (token)).data;

    switch (modifier) {
        case 'i':
        case 'I':
            attribute.modifier = LXB_CSS_SELECTOR_MODIFIER_I;
            break;

        case 's':
        case 'S':
            attribute.modifier = LXB_CSS_SELECTOR_MODIFIER_S;
            break;

        default:
            goto failed;
    }

    lxb_css_syntax_parser_consume(parser);
    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) { lxb_css_syntax_parser_consume(parser); if ((token = lxb_css_syntax_parser_token(parser)) == null) { return parser.tkz.status; } } } while (false);

    if (token.type != LXB_CSS_SYNTAX_TOKEN_RS_BRACKET) {
        if (token.type == LXB_CSS_SYNTAX_TOKEN__END) {
            goto done_eof;
        }

        goto failed;
    }

done:

    lxb_css_selectors_state_specificity_set_b(selectors);
    lxb_css_syntax_parser_consume(parser);

    return LXB_STATUS_OK;

done_eof:

    cast(void) lxb_css_log_format(parser.log, LXB_CSS_LOG_SYNTAX_ERROR,
                              "%s. End Of File in attribute selector",
                              lxb_css_selectors_module_name.ptr);

    lxb_css_selectors_state_specificity_set_b(selectors);

    return LXB_STATUS_OK;

failed:

    return lxb_css_parser_unexpected_status(parser);
}

private lxb_status_t lxb_css_selectors_state_ns(lxb_css_parser_t* parser, lxb_css_selector_t* selector)
{
    const(lxb_css_syntax_token_t)* token = void;

    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);

    if (token.type == LXB_CSS_SYNTAX_TOKEN_DELIM
        && ((cast(lxb_css_syntax_token_delim_t*) (token)).character) == '|')
    {
        lxb_css_syntax_parser_consume(parser);
        return lxb_css_selectors_state_ns_ident(parser, selector);
    }

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_css_selectors_state_ns_ident(lxb_css_parser_t* parser, lxb_css_selector_t* selector)
{
    lxb_status_t status = void;
    const(lxb_css_syntax_token_t)* token = void;
    lxb_css_selectors_t* selectors = void;

    do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);

    if (token.type == LXB_CSS_SYNTAX_TOKEN_IDENT) {
        selectors = parser.selectors;

        lxb_css_selectors_state_specificity_set_c(selectors);

        selector.type = LXB_CSS_SELECTOR_TYPE_ELEMENT;

        selector.ns = selector.name;
        lexbor_str_clean_all(&selector.name);

        status = lxb_css_syntax_token_string_dup((cast(lxb_css_syntax_token_string_t*) (token)),
                                           &selector.name, parser.memory.mraw);

        lxb_css_syntax_parser_consume(parser);

        return status;
    }
    else if (token.type == LXB_CSS_SYNTAX_TOKEN_DELIM
             && ((cast(lxb_css_syntax_token_delim_t*) (token)).character) == '*')
    {
        lxb_css_syntax_parser_consume(parser);

        selector.type = LXB_CSS_SELECTOR_TYPE_ANY;

        selector.ns = selector.name;

        selector.name.data = cast(ubyte*) lexbor_mraw_alloc(parser.memory.mraw, 2);
        if (selector.name.data == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        selector.name.data[0] = '*';
        selector.name.data[1] = '\0';
        selector.name.length = 1;

        return LXB_STATUS_OK;
    }

    return lxb_css_parser_unexpected_status(parser);
}

private lxb_status_t lxb_css_selectors_state_pseudo_class(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token)
{
    lxb_status_t status = void;
    lxb_css_log_message_t* msg = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = void;
    const(lxb_css_selectors_pseudo_data_t)* pseudo = void;

    selectors = parser.selectors;

    do { (selector) = lxb_css_selector_create((selectors).list_last); if ((selector) == null) { return lxb_css_parser_memory_fail(parser); } lxb_css_selectors_append_next((selectors), (selector)); (selector).combinator = (selectors).combinator; (selectors).combinator = LXB_CSS_SELECTOR_COMBINATOR_CLOSE; } while (false);
    selector.type = LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS;

    do { (status) = lxb_css_syntax_token_string_dup( (cast(lxb_css_syntax_token_string_t*) (token)), (&selector.name), (parser).memory.mraw); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    pseudo = lxb_css_selector_pseudo_class_by_name(selector.name.data,
                                                   selector.name.length);
    if (pseudo == null) {
        return lxb_css_parser_unexpected_status(parser);
    }

    switch (pseudo.id) {
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_CURRENT:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_DEFAULT:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FOCUS_VISIBLE:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FOCUS_WITHIN:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FULLSCREEN:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUTURE:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_IN_RANGE:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_INDETERMINATE:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_INVALID:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_LOCAL_LINK:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_OUT_OF_RANGE:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_PAST:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_SCOPE:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_TARGET:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_TARGET_WITHIN:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_USER_INVALID:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_VALID:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_VISITED:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_WARNING:
            msg = lxb_css_log_not_supported(parser.log,
                                            lxb_css_selectors_module_name.ptr,
                                            cast(const(char)*) selector.name.data);
            if (msg == null) {
                return lxb_css_parser_memory_fail(parser);
            }

            return lxb_css_parser_unexpected_status(parser);

        default:
            break;
    }

    selector.u.pseudo.type = pseudo.id;
    selector.u.pseudo.data = null;

    lxb_css_syntax_parser_consume(parser);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_css_selectors_state_pseudo_class_function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_parser_state_f success)
{
    lxb_status_t status = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = void;
    lxb_css_log_message_t* msg = void;
    lxb_css_syntax_rule_t* rule = void;
    const(lxb_css_selectors_pseudo_data_func_t)* func = void;

    selectors = parser.selectors;

    do { (selector) = lxb_css_selector_create((selectors).list_last); if ((selector) == null) { return lxb_css_parser_memory_fail(parser); } lxb_css_selectors_append_next((selectors), (selector)); (selector).combinator = (selectors).combinator; (selectors).combinator = LXB_CSS_SELECTOR_COMBINATOR_CLOSE; } while (false);
    selector.type = LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS_FUNCTION;

    do { (status) = lxb_css_syntax_token_string_dup( (cast(lxb_css_syntax_token_string_t*) (token)), (&selector.name), (parser).memory.mraw); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    func = lxb_css_selector_pseudo_class_function_by_name(selector.name.data,
                                                          selector.name.length);
    if (func == null) {
        return lxb_css_parser_unexpected_status(parser);
    }

    switch (func.id) {
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_DIR:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_LANG:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_COL:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_COL:
            msg = lxb_css_log_not_supported(parser.log,
                                            lxb_css_selectors_module_name.ptr,
                                            cast(const(char)*) selector.name.data);
            if (msg == null) {
                goto failed;
            }

            return lxb_css_parser_unexpected_status(parser);

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_CHILD:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_CHILD:
            lxb_css_selectors_state_specificity_set_b(selectors);
            break;

        default:
            break;
    }

    selector.u.pseudo.type = func.id;
    selector.u.pseudo.data = null;

    selectors.combinator = func.combinator;
    selectors.comb_default = func.combinator;
    selectors.parent = selector;

    rule = lxb_css_syntax_consume_function(parser, token, &func.cb,
                                           success, selectors.list_last);
    if (rule == null) {
        goto failed;
    }

    lxb_css_syntax_parser_consume(parser);

    return LXB_STATUS_OK;

failed:

    cast(void) lxb_css_parser_memory_fail(parser);

    return parser.status;
}

private lxb_status_t lxb_css_selectors_state_pseudo_element(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token)
{
    lxb_status_t status = void;
    lxb_css_log_message_t* msg = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = void;
    const(lxb_css_selectors_pseudo_data_t)* pseudo = void;

    selectors = parser.selectors;

    do { (selector) = lxb_css_selector_create((selectors).list_last); if ((selector) == null) { return lxb_css_parser_memory_fail(parser); } lxb_css_selectors_append_next((selectors), (selector)); (selector).combinator = (selectors).combinator; (selectors).combinator = LXB_CSS_SELECTOR_COMBINATOR_CLOSE; } while (false);
    selector.type = LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT;

    do { (status) = lxb_css_syntax_token_string_dup( (cast(lxb_css_syntax_token_string_t*) (token)), (&selector.name), (parser).memory.mraw); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    pseudo = lxb_css_selector_pseudo_element_by_name(selector.name.data,
                                                     selector.name.length);
    if (pseudo == null) {
        return lxb_css_parser_unexpected_status(parser);
    }

    switch (pseudo.id) {
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_AFTER:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_BACKDROP:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_BEFORE:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_FIRST_LETTER:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_FIRST_LINE:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_GRAMMAR_ERROR:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_INACTIVE_SELECTION:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_MARKER:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_PLACEHOLDER:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_SELECTION:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_SPELLING_ERROR:
        case LXB_CSS_SELECTOR_PSEUDO_ELEMENT_TARGET_TEXT:
            msg = lxb_css_log_not_supported(parser.log,
                                            lxb_css_selectors_module_name.ptr,
                                            cast(const(char)*) selector.name.data);
            if (msg == null) {
                cast(void) lxb_css_parser_memory_fail(parser);
                return parser.status;
            }

            return lxb_css_parser_unexpected_status(parser);

        default:
            break;
    }

    selector.u.pseudo.type = pseudo.id;
    selector.u.pseudo.data = null;

    lxb_css_syntax_parser_consume(parser);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_css_selectors_state_pseudo_element_function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_parser_state_f success)
{
    lxb_status_t status = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = void;
    lxb_css_syntax_rule_t* rule = void;
    const(lxb_css_selectors_pseudo_data_func_t)* func = void;

    selectors = parser.selectors;

    do { (selector) = lxb_css_selector_create((selectors).list_last); if ((selector) == null) { return lxb_css_parser_memory_fail(parser); } lxb_css_selectors_append_next((selectors), (selector)); (selector).combinator = (selectors).combinator; (selectors).combinator = LXB_CSS_SELECTOR_COMBINATOR_CLOSE; } while (false);
    selector.type = LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT_FUNCTION;

    do { (status) = lxb_css_syntax_token_string_dup( (cast(lxb_css_syntax_token_string_t*) (token)), (&selector.name), (parser).memory.mraw); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    func = lxb_css_selector_pseudo_element_function_by_name(selector.name.data,
                                                            selector.name.length);
    if (func == null) {
        return lxb_css_parser_unexpected_status(parser);
    }

    selector.u.pseudo.type = func.id;
    selector.u.pseudo.data = null;

    selectors.combinator = func.combinator;
    selectors.comb_default = func.combinator;
    selectors.parent = selector;

    rule = lxb_css_syntax_consume_function(parser, token, &func.cb,
                                           success, selectors.list_last);
    if (rule == null) {
        cast(void) lxb_css_parser_memory_fail(parser);
        return parser.status;
    }

    lxb_css_syntax_parser_consume(parser);

    return LXB_STATUS_OK;
}

 void lxb_css_selectors_state_restore_combinator(lxb_css_selectors_t* selectors)
{
    lxb_css_selector_t* parent = void;
    lxb_css_selector_combinator_t comb_default = void;
    const(lxb_css_selectors_pseudo_data_func_t)* data_func = void;

    comb_default = LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT;

    if (selectors.parent != null) {
        parent = selectors.parent;

        if (parent.type == LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS_FUNCTION) {
            data_func = lxb_css_selector_pseudo_class_function_by_id(parent.u.pseudo.type);
        }
        else {
            data_func = lxb_css_selector_pseudo_element_function_by_id(parent.u.pseudo.type);
        }

        comb_default = data_func.combinator;
    }

    selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_CLOSE;
    selectors.comb_default = comb_default;
}

lxb_status_t lxb_css_selectors_state_function_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed)
{
    bool cy = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = parser.selectors;

    if (token.type == LXB_CSS_SYNTAX_TOKEN__EOF) {
        cast(void) lxb_css_log_format(parser.log, LXB_CSS_LOG_SYNTAX_ERROR,
                                  "%s. End Of File in pseudo function",
                                  lxb_css_selectors_module_name.ptr);
    }

    if (selectors.list_last == null) {
        lxb_css_selectors_state_restore_parent(selectors, cast(lxb_css_selector_list*) ctx);
        goto empty;
    }

    lxb_css_selectors_state_restore_parent(selectors, cast(lxb_css_selector_list*) ctx);

    return LXB_STATUS_OK;

empty:

    selector = selectors.list_last.last;

    cy = selector.type == LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS_FUNCTION;
    cy = lxb_css_selector_pseudo_function_can_empty(selector.u.pseudo.type,
                                                    cy);
    if (cy) {
        lxb_css_parser_set_ok(parser);
        return LXB_STATUS_OK;
    }

    cast(void) lxb_css_log_format(parser.log, LXB_CSS_LOG_SYNTAX_ERROR,
                              "%s. Pseudo function can't be empty: %S()",
                              lxb_css_selectors_module_name.ptr, &selector.name);

    lxb_css_selector_remove(selector);
    lxb_css_selector_destroy(selector);

    lxb_css_parser_failed_set_by_id(parser, -1, true);
    selectors.err_in_function = true;

    return LXB_STATUS_OK;
}

lxb_status_t lxb_css_selectors_state_function_forgiving(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed)
{
    return lxb_css_selectors_state_forgiving_cb(parser, token, ctx,
                                                &lxb_css_selectors_state_complex_list,
                                                failed);
}

lxb_status_t lxb_css_selectors_state_function_forgiving_relative(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed)
{
    return lxb_css_selectors_state_forgiving_cb(parser, token, ctx,
                                                &lxb_css_selectors_state_relative_list,
                                                failed);
}

private lxb_status_t lxb_css_selectors_state_forgiving_cb(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, lxb_css_parser_state_f state, bool failed)
{
    bool cy = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = parser.selectors;

    lxb_css_parser_set_ok(parser);

    if (token.type == LXB_CSS_SYNTAX_TOKEN__EOF) {
        cast(void) lxb_css_log_format(parser.log, LXB_CSS_LOG_SYNTAX_ERROR,
                                  "%s. End Of File in pseudo function",
                                  lxb_css_selectors_module_name.ptr);
    }

    if (selectors.list_last == null) {
        lxb_css_selectors_state_restore_parent(selectors, cast(lxb_css_selector_list*) ctx);
        goto empty;
    }

    if (selectors.parent.u.pseudo.type
        == LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_WHERE)
    {
        selectors.list_last.specificity = 0;
    }

    lxb_css_selectors_state_restore_parent(selectors, cast(lxb_css_selector_list*) ctx);

    return LXB_STATUS_OK;

empty:

    selector = selectors.list_last.last;

    cy = selector.type == LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS_FUNCTION;
    cy = lxb_css_selector_pseudo_function_can_empty(selector.u.pseudo.type,
                                                    cy);
    if (cy) {
        return LXB_STATUS_OK;
    }

    cast(void) lxb_css_log_format(parser.log, LXB_CSS_LOG_SYNTAX_ERROR,
                              "%s. Pseudo function can't be empty: %S()",
                              lxb_css_selectors_module_name.ptr, &selector.name);

    lxb_css_selector_remove(selector);
    lxb_css_selector_destroy(selector);

    lxb_css_parser_failed_set_by_id(parser, -1, true);
    selectors.err_in_function = true;

    return LXB_STATUS_OK;
}

private void lxb_css_selectors_state_restore_parent(lxb_css_selectors_t* selectors, lxb_css_selector_list_t* last)
{
    uint src = void, dst = void;

    if (selectors.list_last != null && selectors.list_last != last) {
        dst = last.specificity;
        src = selectors.list_last.specificity;

        selectors.list_last = null;

        if (last.parent == null) {
            ((dst) = (((((dst))) & ~(((cast(uint) 1 << 9) - 1) << (18))) | (((((dst) >> 18) & ~LXB_CSS_SELECTOR_SPECIFICITY_MASK) + (((src) >> 18) & ~LXB_CSS_SELECTOR_SPECIFICITY_MASK)) << 18)));
            ((dst) = (((((dst))) & ~(((cast(uint) 1 << 9) - 1) << (9))) | (((((dst) >> 9) & ~LXB_CSS_SELECTOR_SPECIFICITY_MASK) + (((src) >> 9) & ~LXB_CSS_SELECTOR_SPECIFICITY_MASK)) << 9)));
            ((dst) = (((((dst))) & ~(((cast(uint) 1 << 9) - 1) << (0))) | (((dst) & ~LXB_CSS_SELECTOR_SPECIFICITY_MASK) + ((src) & ~LXB_CSS_SELECTOR_SPECIFICITY_MASK))));
        }
        else if (selectors.combinator == LXB_CSS_SELECTOR_COMBINATOR_CLOSE) {
            dst |= src;
        }
        else if (src > dst) {
            dst = src;
        }

        last.specificity = dst;
    }

    if (selectors.list != null) {
        last.last.u.pseudo.data = selectors.list;
    }

    selectors.list_last = last;

    /* Get first Selector in chain. */
    while (last.prev != null) {
        last = last.prev;
    }

    selectors.list = last;
    selectors.parent = last.parent;

    lxb_css_selectors_state_restore_combinator(selectors);
}

private bool lxb_css_selectors_state_list_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_parser_state_f state)
{
    lxb_css_parser_state_t* states = void;
    lxb_css_selectors_t* selectors = parser.selectors;

    if (lxb_css_parser_is_failed(parser)) {
        token = lxb_css_selectors_state_function_error(parser, token);
        if (token == null) {
            return lxb_css_parser_fail(parser,
                                       LXB_STATUS_ERROR_MEMORY_ALLOCATION);
        }
    }
    else if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
        lxb_css_syntax_parser_consume(parser);
        do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);
    }

    if (selectors.parent != null && selectors.list_last &&
        selectors.list_last.prev != null)
    {
        lxb_css_selectors_state_func_specificity(selectors);
    }

    if (token.type != LXB_CSS_SYNTAX_TOKEN_COMMA) {
        states = lxb_css_parser_states_current(parser);

        if (states.root) {
            if (token.type != LXB_CSS_SYNTAX_TOKEN__END) {
                token = lxb_css_selectors_state_function_error(parser, token);
                if (token == null) {
                    return lxb_css_parser_fail(parser,
                                               LXB_STATUS_ERROR_MEMORY_ALLOCATION);
                }
            }

            cast(void) lxb_css_parser_states_pop(parser);
            return lxb_css_parser_success(parser);
        }

        return lxb_css_selectors_done(parser);
    }

    selectors.combinator = selectors.comb_default;

    lxb_css_syntax_token_consume(parser.tkz);
    lxb_css_parser_state_set(parser, state);
    lxb_css_parser_set_ok(parser);

    return true;
}

private bool lxb_css_selectors_state_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_parser_state_t* states = void;

    if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
        lxb_css_syntax_parser_consume(parser);
        do { if ((token = lxb_css_syntax_parser_token(parser)) == null) { return cast(bool) parser.tkz.status; } } while (false);
    }

    if (lxb_css_parser_is_failed(parser)) {
        token = lxb_css_selectors_state_function_error(parser, token);
        if (token == null) {
            return lxb_css_parser_fail(parser,
                                       LXB_STATUS_ERROR_MEMORY_ALLOCATION);
        }
    }

    states = lxb_css_parser_states_current(parser);

    if (states.root) {
        if (token.type != LXB_CSS_SYNTAX_TOKEN__END) {
            token = lxb_css_selectors_state_function_error(parser, token);
            if (token == null) {
                return lxb_css_parser_fail(parser,
                                           LXB_STATUS_ERROR_MEMORY_ALLOCATION);
            }
        }

        cast(void) lxb_css_parser_states_pop(parser);
        return lxb_css_parser_success(parser);
    }

    return lxb_css_selectors_done(parser);
}

private const(lxb_css_syntax_token_t)* lxb_css_selectors_state_function_error(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token)
{
    bool cy = void, comma = void;
    lxb_css_selector_list_t* list = void;
    lxb_css_selector_t* selector = void;
    lxb_css_selectors_t* selectors = parser.selectors;
    const(lxb_css_syntax_token_t)* origin = void;
    const(lxb_css_selectors_pseudo_data_func_t)* func = void;

    cy = false;
    comma = true;
    list = selectors.list_last;
    selector = selectors.parent;

    if (selector != null) {
        cy = selector.type == LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS_FUNCTION;

        func = lxb_css_selector_pseudo_function_by_id(selector.u.pseudo.type,
                                                      cy);
        if (func == null) {
            return null;
        }

        cy = func.forgiving;
        comma = func.comma;
    }

    if (!selectors.err_in_function) {
        origin = lxb_css_syntax_token(parser.tkz);
        if (origin == null) {
            return null;
        }

        if (token.type != LXB_CSS_SYNTAX_TOKEN__END) {
            origin = token;
        }
        else if (origin.type != LXB_CSS_SYNTAX_TOKEN__EOF) {
            origin = null;
        }

        if (origin != null) {
            if (lxb_css_syntax_token_error(parser, origin,
                                           "Selectors") == null)
            {
                return null;
            }
        }
    }

    selectors.err_in_function = false;

    if (cy) {
        lxb_css_selector_list_selectors_remove(selectors, list);
        lxb_css_selector_list_destroy(list);

        while (token != null
               && token.type != LXB_CSS_SYNTAX_TOKEN__END)
        {
            if (comma == true
                && token.type == LXB_CSS_SYNTAX_TOKEN_COMMA
                && lxb_css_parser_rule_deep(parser) == 0)
            {
                break;
            }

            lxb_css_syntax_parser_consume(parser);
            token = lxb_css_syntax_parser_token(parser);
        }

        return token;
    }

    lxb_css_selector_list_destroy_chain(selectors.list);

    selectors.list = null;
    selectors.list_last = null;

    while (token != null
           && token.type != LXB_CSS_SYNTAX_TOKEN__END)
    {
        lxb_css_syntax_parser_consume(parser);
        token = lxb_css_syntax_parser_token(parser);
    }

    return token;
}
