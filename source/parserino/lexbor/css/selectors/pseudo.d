module parserino.lexbor.css.selectors.pseudo;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.base;
public import parserino.lexbor.css.syntax.parser;
public import parserino.lexbor.css.selectors.base;
import parserino.lexbor.css.css;
import parserino.lexbor.css.selectors.state;
import parserino.lexbor.css.selectors.pseudo_state;
import parserino.lexbor.css.selectors.pseudo_res;

extern(C) @nogc nothrow:
__gshared:

// ---- pseudo.h ----
/*
 * Copyright (C) 2020-2022 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_css_selectors_pseudo_data_func_t {
    lxb_char_t* name;
    size_t length;
    uint id;
    bool empty;
    lxb_css_selector_combinator_t combinator;
    const(lxb_css_syntax_cb_function_t) cb;
    bool forgiving;
    bool comma;
}

struct lxb_css_selectors_pseudo_data_t {
    lxb_char_t* name;
    size_t length;
    uint id;
}









// ---- pseudo.c ----
/*
 * Copyright (C) 2020-2022 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

const(lxb_css_selectors_pseudo_data_t)* lxb_css_selector_pseudo_class_by_name(const(lxb_char_t)* name, size_t length)
{
    const(lexbor_shs_entry_t)* entry = void;

    entry = lexbor_shs_entry_get_lower_static(lxb_css_selectors_pseudo_class_shs.ptr,
                                              name, length);
    if (entry == null) {
        return null;
    }

    return cast(const(lxb_css_selectors_pseudo_data_t)*) (entry.value);
}

const(lxb_css_selectors_pseudo_data_func_t)* lxb_css_selector_pseudo_class_function_by_name(const(lxb_char_t)* name, size_t length)
{
    const(lexbor_shs_entry_t)* entry = void;

    entry = lexbor_shs_entry_get_lower_static(lxb_css_selectors_pseudo_class_function_shs.ptr,
                                              name, length);
    if (entry == null) {
        return null;
    }

    return cast(const(lxb_css_selectors_pseudo_data_func_t)*) (entry.value);
}

const(lxb_css_selectors_pseudo_data_func_t)* lxb_css_selector_pseudo_class_function_by_id(uint id)
{
    return &lxb_css_selectors_pseudo_data_pseudo_class_function[id];
}

const(lxb_css_selectors_pseudo_data_t)* lxb_css_selector_pseudo_element_by_name(const(lxb_char_t)* name, size_t length)
{
    const(lexbor_shs_entry_t)* entry = void;

    entry = lexbor_shs_entry_get_lower_static(lxb_css_selectors_pseudo_element_shs.ptr,
                                              name, length);
    if (entry == null) {
        return null;
    }

    return cast(const(lxb_css_selectors_pseudo_data_t)*) (entry.value);
}

const(lxb_css_selectors_pseudo_data_func_t)* lxb_css_selector_pseudo_element_function_by_name(const(lxb_char_t)* name, size_t length)
{
    const(lexbor_shs_entry_t)* entry = void;

    entry = lexbor_shs_entry_get_lower_static(lxb_css_selectors_pseudo_element_function_shs.ptr,
                                              name, length);
    if (entry == null) {
        return null;
    }

    return cast(const(lxb_css_selectors_pseudo_data_func_t)*) (entry.value);
}

const(lxb_css_selectors_pseudo_data_func_t)* lxb_css_selector_pseudo_element_function_by_id(uint id)
{
    return &lxb_css_selectors_pseudo_data_pseudo_element_function[id];
}

const(lxb_css_selectors_pseudo_data_func_t)* lxb_css_selector_pseudo_function_by_id(uint id, bool is_class)
{
    if (is_class) {
        return &lxb_css_selectors_pseudo_data_pseudo_class_function[id];
    }

    return &lxb_css_selectors_pseudo_data_pseudo_element_function[id];
}

bool lxb_css_selector_pseudo_function_can_empty(uint id, bool is_class)
{
    if (is_class) {
        return lxb_css_selectors_pseudo_data_pseudo_class_function[id].empty;
    }

    return lxb_css_selectors_pseudo_data_pseudo_element_function[id].empty;
}
