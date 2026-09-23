module parserino.lexbor.css.selectors.selector;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.str;
public import parserino.lexbor.css.selectors.base;
public import parserino.lexbor.css.syntax.anb;
import parserino.lexbor.core.serialize;
import parserino.lexbor.css.css;
import parserino.lexbor.css.selectors.selectors;
import parserino.lexbor.css.selectors.pseudo;
import parserino.lexbor.css.selectors.pseudo_const;
import parserino.lexbor.css.selectors.pseudo_state;
import parserino.lexbor.css.selectors.state;
import parserino.lexbor.css.selectors.pseudo_res;

extern(C) @nogc nothrow:
__gshared:

// ---- selector.h ----
/*
 * Copyright (C) 2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum lxb_css_selector_type_t {
    LXB_CSS_SELECTOR_TYPE__UNDEF = 0x00,
    LXB_CSS_SELECTOR_TYPE_ANY,
    LXB_CSS_SELECTOR_TYPE_ELEMENT, /* div, tag name <div> */
    LXB_CSS_SELECTOR_TYPE_ID, /* #hash */
    LXB_CSS_SELECTOR_TYPE_CLASS, /* .class */
    LXB_CSS_SELECTOR_TYPE_ATTRIBUTE, /* [key=val], <... key="val"> */
    LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS, /* :pseudo */
    LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS_FUNCTION, /* :function(...) */
    LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT, /* ::pseudo */
    LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT_FUNCTION, /* ::function(...) */
    LXB_CSS_SELECTOR_TYPE__LAST_ENTRY
}
alias LXB_CSS_SELECTOR_TYPE__UNDEF = lxb_css_selector_type_t.LXB_CSS_SELECTOR_TYPE__UNDEF;
alias LXB_CSS_SELECTOR_TYPE_ANY = lxb_css_selector_type_t.LXB_CSS_SELECTOR_TYPE_ANY;
alias LXB_CSS_SELECTOR_TYPE_ELEMENT = lxb_css_selector_type_t.LXB_CSS_SELECTOR_TYPE_ELEMENT;
alias LXB_CSS_SELECTOR_TYPE_ID = lxb_css_selector_type_t.LXB_CSS_SELECTOR_TYPE_ID;
alias LXB_CSS_SELECTOR_TYPE_CLASS = lxb_css_selector_type_t.LXB_CSS_SELECTOR_TYPE_CLASS;
alias LXB_CSS_SELECTOR_TYPE_ATTRIBUTE = lxb_css_selector_type_t.LXB_CSS_SELECTOR_TYPE_ATTRIBUTE;
alias LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS = lxb_css_selector_type_t.LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS;
alias LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS_FUNCTION = lxb_css_selector_type_t.LXB_CSS_SELECTOR_TYPE_PSEUDO_CLASS_FUNCTION;
alias LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT = lxb_css_selector_type_t.LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT;
alias LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT_FUNCTION = lxb_css_selector_type_t.LXB_CSS_SELECTOR_TYPE_PSEUDO_ELEMENT_FUNCTION;
alias LXB_CSS_SELECTOR_TYPE__LAST_ENTRY = lxb_css_selector_type_t.LXB_CSS_SELECTOR_TYPE__LAST_ENTRY;


enum lxb_css_selector_combinator_t {
    LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT = 0x00, /* WHITESPACE */
    LXB_CSS_SELECTOR_COMBINATOR_CLOSE, /* two compound selectors [key=val].foo */
    LXB_CSS_SELECTOR_COMBINATOR_CHILD, /* '>' */
    LXB_CSS_SELECTOR_COMBINATOR_SIBLING, /* '+' */
    LXB_CSS_SELECTOR_COMBINATOR_FOLLOWING, /* '~' */
    LXB_CSS_SELECTOR_COMBINATOR_CELL, /* '||' */
    LXB_CSS_SELECTOR_COMBINATOR__LAST_ENTRY
}
alias LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT = lxb_css_selector_combinator_t.LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT;
alias LXB_CSS_SELECTOR_COMBINATOR_CLOSE = lxb_css_selector_combinator_t.LXB_CSS_SELECTOR_COMBINATOR_CLOSE;
alias LXB_CSS_SELECTOR_COMBINATOR_CHILD = lxb_css_selector_combinator_t.LXB_CSS_SELECTOR_COMBINATOR_CHILD;
alias LXB_CSS_SELECTOR_COMBINATOR_SIBLING = lxb_css_selector_combinator_t.LXB_CSS_SELECTOR_COMBINATOR_SIBLING;
alias LXB_CSS_SELECTOR_COMBINATOR_FOLLOWING = lxb_css_selector_combinator_t.LXB_CSS_SELECTOR_COMBINATOR_FOLLOWING;
alias LXB_CSS_SELECTOR_COMBINATOR_CELL = lxb_css_selector_combinator_t.LXB_CSS_SELECTOR_COMBINATOR_CELL;
alias LXB_CSS_SELECTOR_COMBINATOR__LAST_ENTRY = lxb_css_selector_combinator_t.LXB_CSS_SELECTOR_COMBINATOR__LAST_ENTRY;


enum lxb_css_selector_match_t {
    LXB_CSS_SELECTOR_MATCH_EQUAL = 0x00, /*  = */
    LXB_CSS_SELECTOR_MATCH_INCLUDE, /* ~= */
    LXB_CSS_SELECTOR_MATCH_DASH, /* |= */
    LXB_CSS_SELECTOR_MATCH_PREFIX, /* ^= */
    LXB_CSS_SELECTOR_MATCH_SUFFIX, /* $= */
    LXB_CSS_SELECTOR_MATCH_SUBSTRING, /* *= */
    LXB_CSS_SELECTOR_MATCH__LAST_ENTRY
}
alias LXB_CSS_SELECTOR_MATCH_EQUAL = lxb_css_selector_match_t.LXB_CSS_SELECTOR_MATCH_EQUAL;
alias LXB_CSS_SELECTOR_MATCH_INCLUDE = lxb_css_selector_match_t.LXB_CSS_SELECTOR_MATCH_INCLUDE;
alias LXB_CSS_SELECTOR_MATCH_DASH = lxb_css_selector_match_t.LXB_CSS_SELECTOR_MATCH_DASH;
alias LXB_CSS_SELECTOR_MATCH_PREFIX = lxb_css_selector_match_t.LXB_CSS_SELECTOR_MATCH_PREFIX;
alias LXB_CSS_SELECTOR_MATCH_SUFFIX = lxb_css_selector_match_t.LXB_CSS_SELECTOR_MATCH_SUFFIX;
alias LXB_CSS_SELECTOR_MATCH_SUBSTRING = lxb_css_selector_match_t.LXB_CSS_SELECTOR_MATCH_SUBSTRING;
alias LXB_CSS_SELECTOR_MATCH__LAST_ENTRY = lxb_css_selector_match_t.LXB_CSS_SELECTOR_MATCH__LAST_ENTRY;


enum lxb_css_selector_modifier_t {
    LXB_CSS_SELECTOR_MODIFIER_UNSET = 0x00,
    LXB_CSS_SELECTOR_MODIFIER_I,
    LXB_CSS_SELECTOR_MODIFIER_S,
    LXB_CSS_SELECTOR_MODIFIER__LAST_ENTRY
}
alias LXB_CSS_SELECTOR_MODIFIER_UNSET = lxb_css_selector_modifier_t.LXB_CSS_SELECTOR_MODIFIER_UNSET;
alias LXB_CSS_SELECTOR_MODIFIER_I = lxb_css_selector_modifier_t.LXB_CSS_SELECTOR_MODIFIER_I;
alias LXB_CSS_SELECTOR_MODIFIER_S = lxb_css_selector_modifier_t.LXB_CSS_SELECTOR_MODIFIER_S;
alias LXB_CSS_SELECTOR_MODIFIER__LAST_ENTRY = lxb_css_selector_modifier_t.LXB_CSS_SELECTOR_MODIFIER__LAST_ENTRY;


struct lxb_css_selector_attribute_t {
    lxb_css_selector_match_t match;
    lxb_css_selector_modifier_t modifier;
    lexbor_str_t value;
}

struct lxb_css_selector_pseudo_t {
    uint type;
    void* data;
}

struct lxb_css_selector_anb_of_t {
    lxb_css_syntax_anb_t anb;
    lxb_css_selector_list_t* of;
}

struct lxb_css_selector_contains_t {
    lexbor_str_t str;
    bool insensitive;
}

struct lxb_css_selector {
    lxb_css_selector_type_t type;
    lxb_css_selector_combinator_t combinator;

    lexbor_str_t name;
    lexbor_str_t ns;

    union lxb_css_selector_u {
        lxb_css_selector_attribute_t attribute;
        lxb_css_selector_pseudo_t pseudo;
    }lxb_css_selector_u u;

    lxb_css_selector_t* next;
    lxb_css_selector_t* prev;

    lxb_css_selector_list_t* list;
}

/*
 *   I       S       A       B       C
 * 1 bit | 1 bit | 9 bit | 9 bit | 9 bit
 */
alias lxb_css_selector_specificity_t = uint;

enum LXB_CSS_SELECTOR_SPECIFICITY_MASK = (((cast(uint32_t) 1 << (32 - 9)) - 1) << (9));

/*
 * CSS Selector Specificity field accessors.
 *
 * Specificity is packed into a single uint32_t:
 *   bits [31..28] — i: !important flag (1 = declaration is !important)
 *   bit  [27]     — s: style attribute flag (1 = from element's style="...")
 *   bits [26..18] — a: count of ID selectors
 *   bits [17..9]  — b: count of class selectors, attribute selectors,
 *                       and pseudo-classes
 *   bits [8..0]   — c: count of type selectors and pseudo-elements
 *
 * Per CSS cascade order: !important > style attribute > (a, b, c).
 */

/* Extract the !important flag (bits 31..28). */

/* Extract the style attribute flag (bit 27). */

/* Extract the ID selector count — component "a" (bits 26..18). */

/* Extract the class/attribute/pseudo-class count — component "b" (bits 17..9). */

/* Extract the type/pseudo-element count — component "c" (bits 8..0). */
enum LXB_CSS_SELECTOR_SP_S_MAX = ((1 << 28) - 1);
enum LXB_CSS_SELECTOR_SP_A_MAX = ((1 << 27) - 1);
enum LXB_CSS_SELECTOR_SP_B_MAX = ((1 << 18) - 1);
enum LXB_CSS_SELECTOR_SP_C_MAX = ((1 << 9) - 1);

struct lxb_css_selector_list {
    lxb_css_selector_t* first;
    lxb_css_selector_t* last;

    lxb_css_selector_t* parent;

    lxb_css_selector_list_t* next;
    lxb_css_selector_list_t* prev;

    lxb_css_memory_t* memory;

    lxb_css_selector_specificity_t specificity;
}






















// ---- selector.c ----
/*
 * Copyright (C) 2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_css_selector_destroy_f = void function(lxb_css_selector_t* selector, lxb_css_memory_t* mem);
alias lxb_css_selector_serialize_f = lxb_status_t function(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx);





















private const(lxb_css_selector_destroy_f)[LXB_CSS_SELECTOR_TYPE__LAST_ENTRY] lxb_selector_destroy_map = [
    &lxb_css_selector_destroy_undef,
    &lxb_css_selector_destroy_any,
    &lxb_css_selector_destroy_any,
    &lxb_css_selector_destroy_id,
    &lxb_css_selector_destroy_id,
    &lxb_css_selector_destroy_attribute,
    &lxb_css_selector_destroy_pseudo,
    &lxb_css_selector_destroy_pseudo_class_function,
    &lxb_css_selector_destroy_pseudo,
    &lxb_css_selector_destroy_pseudo_element_function
];

private const(lxb_css_selector_serialize_f)[LXB_CSS_SELECTOR_TYPE__LAST_ENTRY] lxb_selector_serialize_map = [
    &lxb_css_selector_serialize_undef,
    &lxb_css_selector_serialize_any,
    &lxb_css_selector_serialize_any,
    &lxb_css_selector_serialize_id,
    &lxb_css_selector_serialize_class,
    &lxb_css_selector_serialize_attribute,
    &lxb_css_selector_serialize_pseudo_class,
    &lxb_css_selector_serialize_pseudo_class_function,
    &lxb_css_selector_serialize_pseudo_element,
    &lxb_css_selector_serialize_pseudo_element_function
];

lxb_css_selector_t* lxb_css_selector_create(lxb_css_selector_list_t* list)
{
    lxb_css_selector_t* selector = cast(lxb_css_selector*) lexbor_dobject_calloc(list.memory.objs);
    if (selector == null) {
        return null;
    }

    selector.list = list;

    return selector;
}

void lxb_css_selector_destroy(lxb_css_selector_t* selector)
{
    lxb_css_memory_t* memory = void;

    if (selector != null) {
        memory = selector.list.memory;

        lxb_selector_destroy_map[selector.type](selector, memory);
        lexbor_dobject_free(memory.objs, selector);
    }
}

void lxb_css_selector_destroy_chain(lxb_css_selector_t* selector)
{
    lxb_css_selector_t* next = void;

    while (selector != null) {
        next = selector.next;
        lxb_css_selector_destroy(selector);
        selector = next;
    }
}

void lxb_css_selector_remove(lxb_css_selector_t* selector)
{
    if (selector.next != null) {
        selector.next.prev = selector.prev;
    }

    if (selector.prev != null) {
        selector.prev.next = selector.next;
    }

    if (selector.list.first == selector) {
        selector.list.first = selector.next;
    }

    if (selector.list.last == selector) {
        selector.list.last = selector.prev;
    }
}

lxb_css_selector_list_t* lxb_css_selector_list_create(lxb_css_memory_t* mem)
{
    lxb_css_selector_list_t* list = void;

    list = cast(lxb_css_selector_list*) lexbor_dobject_calloc(mem.objs);
    if (list == null) {
        return null;
    }

    list.memory = mem;

    return list;
}

void lxb_css_selector_list_remove(lxb_css_selector_list_t* list)
{
    if (list.next != null) {
        list.next.prev = list.prev;
    }

    if (list.prev != null) {
        list.prev.next = list.next;
    }
}

void lxb_css_selector_list_selectors_remove(lxb_css_selectors_t* selectors, lxb_css_selector_list_t* list)
{
    lxb_css_selector_list_remove(list);

    if (selectors.list == list) {
        selectors.list = list.next;
    }

    if (selectors.list_last == list) {
        selectors.list_last = list.prev;
    }
}

void lxb_css_selector_list_destroy(lxb_css_selector_list_t* list)
{
    if (list != null) {
        lxb_css_selector_destroy_chain(list.first);
        lexbor_dobject_free(list.memory.objs, list);
    }
}

void lxb_css_selector_list_destroy_chain(lxb_css_selector_list_t* list)
{
    lxb_css_selector_list_t* next = void;

    while (list != null) {
        next = list.next;
        lxb_css_selector_list_destroy(list);
        list = next;
    }
}

void lxb_css_selector_list_destroy_memory(lxb_css_selector_list_t* list)
{
    if (list != null) {
        cast(void) lxb_css_memory_destroy(list.memory, true);
    }
}

private void lxb_css_selector_destroy_undef(lxb_css_selector_t* selector, lxb_css_memory_t* mem)
{
    /* Do nothing. */
}

private void lxb_css_selector_destroy_any(lxb_css_selector_t* selector, lxb_css_memory_t* mem)
{
    if (selector.ns.data != null) {
        lexbor_mraw_free(mem.mraw, selector.ns.data);
    }

    if (selector.name.data != null) {
        lexbor_mraw_free(mem.mraw, selector.name.data);
    }
}

private void lxb_css_selector_destroy_id(lxb_css_selector_t* selector, lxb_css_memory_t* mem)
{
    if (selector.name.data != null) {
        cast(void) lexbor_mraw_free(mem.mraw, selector.name.data);
    }
}

private void lxb_css_selector_destroy_attribute(lxb_css_selector_t* selector, lxb_css_memory_t* mem)
{
    if (selector.ns.data != null) {
        lexbor_mraw_free(mem.mraw, selector.ns.data);
    }

    if (selector.name.data != null) {
        lexbor_mraw_free(mem.mraw, selector.name.data);
    }

    if (selector.u.attribute.value.data != null) {
        lexbor_mraw_free(mem.mraw, selector.u.attribute.value.data);
    }
}

private void lxb_css_selector_destroy_pseudo(lxb_css_selector_t* selector, lxb_css_memory_t* mem)
{
    if (selector.name.data != null) {
        lexbor_mraw_free(mem.mraw, selector.name.data);
    }
}

private void lxb_css_selector_destroy_pseudo_class_function(lxb_css_selector_t* selector, lxb_css_memory_t* mem)
{
    lxb_css_selector_anb_of_t* anbof = void;
    lxb_css_selector_contains_t* contains = void;
    lxb_css_selector_pseudo_t* pseudo = void;

    pseudo = &selector.u.pseudo;

    switch (pseudo.type) {
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_CURRENT:
            break;
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_DIR:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_HAS:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_IS:
            lxb_css_selector_list_destroy_chain(cast(lxb_css_selector_list*) pseudo.data);
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_LANG:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NOT:
            lxb_css_selector_list_destroy_chain(cast(lxb_css_selector_list*) pseudo.data);
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_CHILD:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_COL:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_CHILD:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_COL:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_OF_TYPE:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_OF_TYPE:
            anbof = cast(lxb_css_selector_anb_of_t*) pseudo.data;

            if (anbof != null) {
                lxb_css_selector_list_destroy_chain(anbof.of);
                lexbor_mraw_free(mem.mraw, anbof);
            }
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_WHERE:
            lxb_css_selector_list_destroy_chain(cast(lxb_css_selector_list*) pseudo.data);
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_LEXBOR_CONTAINS:
            contains = cast(lxb_css_selector_contains_t*) pseudo.data;

            if (contains != null) {
                if (contains.str.data != null) {
                    lexbor_mraw_free(mem.mraw, contains.str.data);
                }

                lexbor_mraw_free(mem.mraw, contains);
            }
            break;

        default:
            break;
    }

    lxb_css_selector_destroy_pseudo(selector, mem);
}

private void lxb_css_selector_destroy_pseudo_element_function(lxb_css_selector_t* selector, lxb_css_memory_t* mem)
{
    lxb_css_selector_destroy_pseudo(selector, mem);
}

lxb_status_t lxb_css_selector_serialize(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx)
{
    return lxb_selector_serialize_map[selector.type](selector, cb, ctx);
}

lxb_status_t lxb_css_selector_serialize_chain(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx)
{
    size_t length = void;
    lxb_char_t* data = void;
    lxb_status_t status = void;

    if (selector == null) {
        return LXB_STATUS_OK;
    }

    if (selector.combinator > LXB_CSS_SELECTOR_COMBINATOR_CLOSE) {
        data = lxb_css_selector_combinator(selector, &length);
        if (data == null) {
            return LXB_STATUS_ERROR_UNEXPECTED_DATA;
        }

        do { (status) = cb(cast(lxb_char_t*) (data), (length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
        do { (status) = cb(cast(lxb_char_t*) " ".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    }

    status = lxb_css_selector_serialize(selector, cb, ctx);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    selector = selector.next;

    while (selector != null) {
        data = lxb_css_selector_combinator(selector, &length);
        if (data == null) {
            return LXB_STATUS_ERROR_UNEXPECTED_DATA;
        }

        if (length != 0) {
            do { (status) = cb(cast(lxb_char_t*) " ".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

            if (*data != ' ') {
                do { (status) = cb(cast(lxb_char_t*) (data), (length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
                do { (status) = cb(cast(lxb_char_t*) " ".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
            }
        }

        status = lxb_css_selector_serialize(selector, cb, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }

        selector = selector.next;
    }

    return LXB_STATUS_OK;
}

lxb_char_t* lxb_css_selector_serialize_chain_char(lxb_css_selector_t* selector, size_t* out_length)
{
    size_t length = 0;
    lxb_status_t status = void;
    lexbor_str_t str = void;

    status = lxb_css_selector_serialize_chain(selector, &lexbor_serialize_length_cb,
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

    status = lxb_css_selector_serialize_chain(selector, &lexbor_serialize_copy_cb,
                                              &str);
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

lxb_status_t lxb_css_selector_serialize_list(lxb_css_selector_list_t* list, lexbor_serialize_cb_f cb, void* ctx)
{
    if (list != null) {
        return lxb_css_selector_serialize_chain(list.first, cb, ctx);
    }

    return LXB_STATUS_OK;
}

lxb_char_t* lxb_css_selector_serialize_list_char(lxb_css_selector_list_t* list, size_t* out_length)
{
    size_t length = 0;
    lxb_status_t status = void;
    lexbor_str_t str = void;

    status = lxb_css_selector_serialize_list_chain(list, &lexbor_serialize_length_cb,
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

    status = lxb_css_selector_serialize_list_chain(list, &lexbor_serialize_copy_cb,
                                                   &str);
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

lxb_status_t lxb_css_selector_serialize_list_chain(lxb_css_selector_list_t* list, lexbor_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    if (list == null) {
        return LXB_STATUS_OK;
    }

    status = lxb_css_selector_serialize_chain(list.first, cb, ctx);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    list = list.next;

    while (list != null) {
        do { (status) = cb(cast(lxb_char_t*) ", ".ptr, (2), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

        status = lxb_css_selector_serialize_chain(list.first, cb, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }

        list = list.next;
    }

    return LXB_STATUS_OK;
}

lxb_char_t* lxb_css_selector_serialize_list_chain_char(lxb_css_selector_list_t* list, size_t* out_length)
{
    size_t length = 0;
    lxb_status_t status = void;
    lexbor_str_t str = void;

    status = lxb_css_selector_serialize_list_chain(list, &lexbor_serialize_length_cb,
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

    status = lxb_css_selector_serialize_list_chain(list, &lexbor_serialize_copy_cb,
                                                   &str);
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

private lxb_status_t lxb_css_selector_serialize_undef(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx)
{
    return LXB_STATUS_ERROR_UNEXPECTED_DATA;
}

private lxb_status_t lxb_css_selector_serialize_any(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    if (selector.ns.data != null) {
        do { (status) = cb(cast(lxb_char_t*) (selector.ns.data), (selector.ns.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false)
                                                             ;
        do { (status) = cb(cast(lxb_char_t*) "|".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    }

    if (selector.name.data != null) {
        return cb(selector.name.data, selector.name.length, ctx);
    }

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_css_selector_serialize_id(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    do { (status) = cb(cast(lxb_char_t*) "#".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    if (selector.name.data != null) {
        return cb(selector.name.data, selector.name.length, ctx);
    }

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_css_selector_serialize_class(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    do { (status) = cb(cast(lxb_char_t*) ".".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    if (selector.name.data != null) {
        return cb(selector.name.data, selector.name.length, ctx);
    }

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_css_selector_serialize_escape_write(lxb_char_t* p, lxb_char_t* end, lexbor_serialize_cb_f cb, void* ctx)
{
    lxb_char_t* begin = void;
    lxb_status_t status = void;

    begin = p;

    do { (status) = cb(cast(lxb_char_t*) "\"".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    while (p < end) {
        if (*p == '"') {
            if (begin < p) {
                do { (status) = cb(cast(lxb_char_t*) (begin), (p - begin), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
            }

            do { (status) = cb(cast(lxb_char_t*) "\\000022".ptr, (7), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

            begin = p + 1;
        }

        p++;
    }

    if (begin < p) {
        do { (status) = cb(cast(lxb_char_t*) (begin), (p - begin), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    }

    do { (status) = cb(cast(lxb_char_t*) "\"".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_css_selector_serialize_attribute(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx)
{
    lxb_char_t* p = void, end = void;
    lxb_status_t status = void;
    lxb_css_selector_attribute_t* attr = void;

    do { (status) = cb(cast(lxb_char_t*) "[".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    status = lxb_css_selector_serialize_any(selector, cb, ctx);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    attr = &selector.u.attribute;

    if (attr.value.data == null) {
        return cb(cast(lxb_char_t*) "]", 1, ctx);
    }

    switch (attr.match) {
        case LXB_CSS_SELECTOR_MATCH_EQUAL:
            do { (status) = cb(cast(lxb_char_t*) "=".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
            break;
        case LXB_CSS_SELECTOR_MATCH_INCLUDE:
            do { (status) = cb(cast(lxb_char_t*) "~=".ptr, (2), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
            break;
        case LXB_CSS_SELECTOR_MATCH_DASH:
            do { (status) = cb(cast(lxb_char_t*) "|=".ptr, (2), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
            break;
        case LXB_CSS_SELECTOR_MATCH_PREFIX:
            do { (status) = cb(cast(lxb_char_t*) "^=".ptr, (2), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
            break;
        case LXB_CSS_SELECTOR_MATCH_SUFFIX:
            do { (status) = cb(cast(lxb_char_t*) "$=".ptr, (2), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
            break;
        case LXB_CSS_SELECTOR_MATCH_SUBSTRING:
            do { (status) = cb(cast(lxb_char_t*) "*=".ptr, (2), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
            break;

        default:
            return LXB_STATUS_ERROR_UNEXPECTED_DATA;
    }

    p = attr.value.data;
    end = attr.value.data + attr.value.length;

    status = lxb_css_selector_serialize_escape_write(p, end, cb, ctx);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    if (attr.modifier != LXB_CSS_SELECTOR_MODIFIER_UNSET) {
        switch (attr.modifier) {
            case LXB_CSS_SELECTOR_MODIFIER_I:
                do { (status) = cb(cast(lxb_char_t*) "i".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
                break;

            case LXB_CSS_SELECTOR_MODIFIER_S:
                do { (status) = cb(cast(lxb_char_t*) "s".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
                break;

            default:
                return LXB_STATUS_ERROR_UNEXPECTED_DATA;
        }
    }

    return cb(cast(lxb_char_t*) "]", 1, ctx);
}

private lxb_status_t lxb_css_selector_serialize_pseudo_class(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx)
{
    return lxb_css_selector_serialize_pseudo_single(selector, cb, ctx, true);
}

private lxb_status_t lxb_css_selector_serialize_pseudo_class_function(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;
    lxb_char_t* p = void, end = void;
    lxb_css_selector_pseudo_t* pseudo = void;
    lxb_css_selector_contains_t* contains = void;
    const(lxb_css_selectors_pseudo_data_func_t)* pfunc = void;

    pseudo = &selector.u.pseudo;

    pfunc = &lxb_css_selectors_pseudo_data_pseudo_class_function[pseudo.type];

    do { (status) = cb(cast(lxb_char_t*) ":".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    do { (status) = cb(cast(lxb_char_t*) (pfunc.name), (pfunc.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    do { (status) = cb(cast(lxb_char_t*) "(".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    switch (pseudo.type) {
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_CURRENT:
            break;
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_DIR:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_HAS:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_IS:
            status = lxb_css_selector_serialize_list_chain(cast(lxb_css_selector_list*) pseudo.data,
                                                           cb, ctx);
            break;
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_LANG:
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NOT:
            status = lxb_css_selector_serialize_list_chain(cast(lxb_css_selector_list*) pseudo.data,
                                                           cb, ctx);
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_CHILD:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_COL:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_CHILD:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_COL:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_LAST_OF_TYPE:
        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_NTH_OF_TYPE:
            status = LXB_STATUS_OK;

            if (pseudo.data != null) {
                status = lxb_css_selector_serialize_anb_of(cast(lxb_css_selector_anb_of_t*) pseudo.data,
                                                           cb, ctx);
            }
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_WHERE:
            status = lxb_css_selector_serialize_list_chain(cast(lxb_css_selector_list*) pseudo.data,
                                                           cb, ctx);
            break;

        case LXB_CSS_SELECTOR_PSEUDO_CLASS_FUNCTION_LEXBOR_CONTAINS:
            contains = cast(lxb_css_selector_contains_t*) pseudo.data;
            p = contains.str.data;
            end = p + contains.str.length;

            status = lxb_css_selector_serialize_escape_write(p, end, cb, ctx);
            if (status != LXB_STATUS_OK) {
                return status;
            }

            if (contains.insensitive) {
                do { (status) = cb(cast(lxb_char_t*) " i".ptr, (2), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
            }

            break;

        default:
            status = LXB_STATUS_OK;
            break;
    }

    if (status != LXB_STATUS_OK) {
        return status;
    }

    do { (status) = cb(cast(lxb_char_t*) ")".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    return LXB_STATUS_OK;
}

private lxb_status_t lxb_css_selector_serialize_pseudo_element(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx)
{
    return lxb_css_selector_serialize_pseudo_single(selector, cb, ctx, false);
}

private lxb_status_t lxb_css_selector_serialize_pseudo_element_function(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx)
{
    return LXB_STATUS_OK;
}

private lxb_status_t lxb_css_selector_serialize_pseudo_single(lxb_css_selector_t* selector, lexbor_serialize_cb_f cb, void* ctx, bool is_class)
{
    lxb_status_t status = void;
    lxb_css_selector_pseudo_t* pseudo = void;
    const(lxb_css_selectors_pseudo_data_t)* pclass = void;

    pseudo = &selector.u.pseudo;

    if (is_class) {
        pclass = &lxb_css_selectors_pseudo_data_pseudo_class[pseudo.type];
        do { (status) = cb(cast(lxb_char_t*) ":".ptr, (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    }
    else {
        pclass = &lxb_css_selectors_pseudo_data_pseudo_element[pseudo.type];
        do { (status) = cb(cast(lxb_char_t*) "::".ptr, (2), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    }

    do { (status) = cb(cast(lxb_char_t*) (pclass.name), (pclass.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    return LXB_STATUS_OK;
}

lxb_status_t lxb_css_selector_serialize_anb_of(lxb_css_selector_anb_of_t* anbof, lexbor_serialize_cb_f cb, void* ctx)
{
    lxb_status_t status = void;

    static const(lxb_char_t)[5] of = lexbor_carray!" of ";

    status = lxb_css_syntax_anb_serialize(&anbof.anb, cb, ctx);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    if (anbof.of != null) {
        do { (status) = cb(cast(lxb_char_t*) (of), (of.sizeof - 1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

        return lxb_css_selector_serialize_list_chain(anbof.of, cb, ctx);
    }

    return LXB_STATUS_OK;
}

lxb_char_t* lxb_css_selector_combinator(lxb_css_selector_t* selector, size_t* out_length)
{
    switch (selector.combinator) {
        case LXB_CSS_SELECTOR_COMBINATOR_DESCENDANT:
            if (out_length != null) {*out_length = 1;}
            return cast(lxb_char_t*) " ";

        case LXB_CSS_SELECTOR_COMBINATOR_CLOSE:
            if (out_length != null) {*out_length = 0;}
            return cast(lxb_char_t*) "";

        case LXB_CSS_SELECTOR_COMBINATOR_CHILD:
            if (out_length != null) {*out_length = 1;}
            return cast(lxb_char_t*) ">";

        case LXB_CSS_SELECTOR_COMBINATOR_SIBLING:
            if (out_length != null) {*out_length = 1;}
            return cast(lxb_char_t*) "+";

        case LXB_CSS_SELECTOR_COMBINATOR_FOLLOWING:
            if (out_length != null) {*out_length = 1;}
            return cast(lxb_char_t*) "~";

        case LXB_CSS_SELECTOR_COMBINATOR_CELL:
            if (out_length != null) {*out_length = 2;}
            return cast(lxb_char_t*) "||";

        default:
            if (out_length != null) {*out_length = 0;}
            return null;
    }
}

void lxb_css_selector_list_append(lxb_css_selector_list_t* list, lxb_css_selector_t* selector)
{
    selector.prev = list.last;

    if (list.last != null) {
        list.last.next = selector;
    }
    else {
        list.first = selector;
    }

    list.last = selector;
}

void lxb_css_selector_append_next(lxb_css_selector_t* dist, lxb_css_selector_t* src)
{
    if (dist.next != null) {
        dist.next.prev = src;
    }

    src.prev = dist;
    src.next = dist.next;

    dist.next = src;
}

void lxb_css_selector_list_append_next(lxb_css_selector_list_t* dist, lxb_css_selector_list_t* src)
{
    if (dist.next != null) {
        dist.next.prev = src;
    }

    src.prev = dist;
    src.next = dist.next;

    dist.next = src;
}
