module parserino.lexbor.css.selectors.selectors;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.dobject;
public import parserino.lexbor.css.base;
public import parserino.lexbor.css.syntax.parser;
public import parserino.lexbor.css.syntax.syntax;
public import parserino.lexbor.css.selectors.base;
public import parserino.lexbor.css.selectors.selector;
public import parserino.lexbor.css.selectors.pseudo_const;
import parserino.lexbor.core.print;
import parserino.lexbor.css.css;

extern(C) @nogc nothrow:
__gshared:

// ---- selectors.h ----
/*
 * Copyright (C) 2020-2022 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_css_selectors {
    lxb_css_selector_list_t* list;
    lxb_css_selector_list_t* list_last;

    lxb_css_selector_t* parent;

    lxb_css_selector_combinator_t combinator;
    lxb_css_selector_combinator_t comb_default;

    uintptr_t error;
    bool status;
    bool err_in_function;
    bool failed;
}














/*
 * Inline functions
 */
 void lxb_css_selectors_append_next(lxb_css_selectors_t* selectors, lxb_css_selector_t* selector)
{
    if (selectors.list_last.last != null) {
        lxb_css_selector_append_next(selectors.list_last.last, selector);
    }
    else {
        selectors.list_last.first = selector;
    }

    selectors.list_last.last = selector;
}

 void lxb_css_selectors_list_append_next(lxb_css_selectors_t* selectors, lxb_css_selector_list_t* list)
{
    if (selectors.list_last != null) {
        lxb_css_selector_list_append_next(selectors.list_last, list);
    }
    else {
        selectors.list = list;
    }

    selectors.list_last = list;
}

// ---- selectors.c ----
/*
 * Copyright (C) 2020-2022 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */




private const(lxb_css_syntax_cb_components_t) lxb_css_selectors_complex_list_cb = {
    state: &lxb_css_selectors_state_complex_list,
    block: null,
    failed: &lxb_css_state_failed,
    end: &lxb_css_selectors_components_end
};

private const(lxb_css_syntax_cb_components_t) lxb_css_selectors_compound_list_cb = {
    state: &lxb_css_selectors_state_compound_list,
    block: null,
    failed: &lxb_css_state_failed,
    end: &lxb_css_selectors_components_end
};

private const(lxb_css_syntax_cb_components_t) lxb_css_selectors_simple_list_cb = {
    state: &lxb_css_selectors_state_simple_list,
    block: null,
    failed: &lxb_css_state_failed,
    end: &lxb_css_selectors_components_end
};

private const(lxb_css_syntax_cb_components_t) lxb_css_selectors_relative_list_cb = {
    state: &lxb_css_selectors_state_relative_list,
    block: null,
    failed: &lxb_css_state_failed,
    end: &lxb_css_selectors_components_end
};

private const(lxb_css_syntax_cb_components_t) lxb_css_selectors_complex_cb = {
    state: &lxb_css_selectors_state_complex,
    block: null,
    failed: &lxb_css_state_failed,
    end: &lxb_css_selectors_components_end
};

private const(lxb_css_syntax_cb_components_t) lxb_css_selectors_compound_cb = {
    state: &lxb_css_selectors_state_compound,
    block: null,
    failed: &lxb_css_state_failed,
    end: &lxb_css_selectors_components_end
};

private const(lxb_css_syntax_cb_components_t) lxb_css_selectors_simple_cb = {
    state: &lxb_css_selectors_state_simple,
    block: null,
    failed: &lxb_css_state_failed,
    end: &lxb_css_selectors_components_end
};

private const(lxb_css_syntax_cb_components_t) lxb_css_selectors_relative_cb = {
    state: &lxb_css_selectors_state_relative,
    block: null,
    failed: &lxb_css_state_failed,
    end: &lxb_css_selectors_components_end
};

lxb_css_selectors_t* lxb_css_selectors_create()
{
    return cast(lxb_css_selectors*) lexbor_calloc(1, lxb_css_selectors_t.sizeof);
}

lxb_status_t lxb_css_selectors_init(lxb_css_selectors_t* selectors)
{
    if (selectors == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    selectors.list = null;
    selectors.list_last = null;
    selectors.parent = null;
    selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT;
    selectors.comb_default = LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT;
    selectors.error = 0;
    selectors.err_in_function = false;
    selectors.failed = false;

    return LXB_STATUS_OK;
}

void lxb_css_selectors_clean(lxb_css_selectors_t* selectors)
{
    if (selectors != null) {
        selectors.list = null;
        selectors.list_last = null;
        selectors.parent = null;
        selectors.combinator = LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT;
        selectors.comb_default = LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT;
        selectors.error = 0;
        selectors.err_in_function = false;
        selectors.failed = false;
    }
}

lxb_css_selectors_t* lxb_css_selectors_destroy(lxb_css_selectors_t* selectors, bool self_destroy)
{
    if (selectors == null) {
        return null;
    }

    if (self_destroy) {
        return cast(lxb_css_selectors*) lexbor_free(selectors);
    }

    return selectors;
}

lxb_css_selector_list_t* lxb_css_selectors_parse(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    return lxb_css_selectors_parse_complex_list(parser, data, length);
}

lxb_css_selector_list_t* lxb_css_selectors_parse_complex_list(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    return lxb_css_selectors_parse_list(parser, &lxb_css_selectors_complex_list_cb,
                                        data, length);
}

lxb_css_selector_list_t* lxb_css_selectors_parse_compound_list(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    return lxb_css_selectors_parse_list(parser, &lxb_css_selectors_compound_list_cb,
                                        data, length);
}

lxb_css_selector_list_t* lxb_css_selectors_parse_simple_list(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    return lxb_css_selectors_parse_list(parser, &lxb_css_selectors_simple_list_cb,
                                        data, length);
}

lxb_css_selector_list_t* lxb_css_selectors_parse_relative_list(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    return lxb_css_selectors_parse_list(parser, &lxb_css_selectors_relative_list_cb,
                                        data, length);
}

private lxb_status_t lxb_css_selectors_parse_prepare(lxb_css_parser_t* parser, lxb_css_memory_t* memory, lxb_css_selectors_t* selectors)
{
    if (parser.stage != LXB_CSS_PARSER_CLEAN) {
        if (parser.stage == LXB_CSS_PARSER_RUN) {
            return LXB_STATUS_ERROR_WRONG_ARGS;
        }

        lxb_css_parser_clean(parser);
    }

    parser.tkz.with_comment = false;
    parser.stage = LXB_CSS_PARSER_RUN;

    parser.old_memory = parser.memory;
    parser.old_selectors = parser.selectors;

    parser.memory = memory;
    parser.selectors = selectors;

    return LXB_STATUS_OK;
}

private lxb_css_selector_list_t* lxb_css_selectors_parse_process(lxb_css_parser_t* parser, const(lxb_css_syntax_cb_components_t)* components, const(lxb_char_t)* data, size_t length)
{
    lxb_css_syntax_rule_t* rule = void;

    lxb_css_parser_buffer_set(parser, data, length);

    rule = lxb_css_syntax_parser_components_push(parser, null, null,
                                                 components, null,
                                                 LXB_CSS_SYNTAX_TOKEN_UNDEF);
    if (rule == null) {
        return null;
    }

    parser.status = lxb_css_syntax_parser_run(parser);
    if (parser.status != LXB_STATUS_OK) {
        return null;
    }

    return parser.selectors.list;
}

private void lxb_css_selectors_parse_finish(lxb_css_parser_t* parser)
{
    parser.stage = LXB_CSS_PARSER_END;

    parser.memory = parser.old_memory;
    parser.selectors = parser.old_selectors;
}

private lxb_css_selector_list_t* lxb_css_selectors_parse_list(lxb_css_parser_t* parser, const(lxb_css_syntax_cb_components_t)* components, const(lxb_char_t)* data, size_t length)
{
    lxb_css_memory_t* memory = void;
    lxb_css_selectors_t* selectors = void;
    lxb_css_selector_list_t* list = void;

    memory = parser.memory;
    selectors = parser.selectors;

    if (selectors == null) {
        selectors = lxb_css_selectors_create();
        parser.status = lxb_css_selectors_init(selectors);

        if (parser.status != LXB_STATUS_OK) {
            cast(void) lxb_css_selectors_destroy(selectors, true);
            return null;
        }
    }
    else {
        lxb_css_selectors_clean(selectors);
    }

    if (memory == null) {
        memory = lxb_css_memory_create();
        parser.status = lxb_css_memory_init(memory, 256);

        if (parser.status != LXB_STATUS_OK) {
            if (selectors != parser.selectors) {
                cast(void) lxb_css_selectors_destroy(selectors, true);
            }

            cast(void) lxb_css_memory_destroy(memory, true);
            return null;
        }
    }

    parser.status = lxb_css_selectors_parse_prepare(parser, memory, selectors);
    if (parser.status != LXB_STATUS_OK) {
        list = null;
        goto end;
    }

    list = lxb_css_selectors_parse_process(parser, components, data, length);

    lxb_css_selectors_parse_finish(parser);

end:

    if (list == null && memory != parser.memory) {
        cast(void) lxb_css_memory_destroy(memory, true);
    }

    if (selectors != parser.selectors) {
        cast(void) lxb_css_selectors_destroy(selectors, true);
    }

    return list;
}

private lxb_status_t lxb_css_selectors_components_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx, bool failed)
{
    lxb_css_selector_list_t* list = void;
    lxb_css_selectors_t* selectors = parser.selectors;

    if (failed) {
        list = selectors.list_last;

        if (list != null) {
            lxb_css_selector_list_selectors_remove(selectors, list);
            lxb_css_selector_list_destroy(list);
        }
    }

    return LXB_STATUS_OK;
}

lxb_css_selector_list_t* lxb_css_selectors_parse_complex(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    return lxb_css_selectors_parse_list(parser, &lxb_css_selectors_complex_cb,
                                        data, length);
}

lxb_css_selector_list_t* lxb_css_selectors_parse_compound(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    return lxb_css_selectors_parse_list(parser, &lxb_css_selectors_compound_cb,
                                        data, length);
}

lxb_css_selector_list_t* lxb_css_selectors_parse_simple(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    return lxb_css_selectors_parse_list(parser, &lxb_css_selectors_simple_cb,
                                        data, length);
}

lxb_css_selector_list_t* lxb_css_selectors_parse_relative(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    return lxb_css_selectors_parse_list(parser, &lxb_css_selectors_relative_cb,
                                        data, length);
}
