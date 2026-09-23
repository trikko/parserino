module parserino.lexbor.html.tree.error;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.core.array_obj;
public import parserino.lexbor.html.token;
import parserino.lexbor.core.str;

extern(C) @nogc nothrow:
__gshared:

// ---- error.h ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum lxb_html_tree_error_id_t {
    /* unexpected-token */
    LXB_HTML_RULES_ERROR_UNTO = 0x0000,
    /* unexpected-closed-token */
    LXB_HTML_RULES_ERROR_UNCLTO,
    /* null-character */
    LXB_HTML_RULES_ERROR_NUCH,
    /* unexpected-character-token */
    LXB_HTML_RULES_ERROR_UNCHTO,
    /* unexpected-token-in-initial-mode */
    LXB_HTML_RULES_ERROR_UNTOININMO,
    /* bad-doctype-token-in-initial-mode */
    LXB_HTML_RULES_ERROR_BADOTOININMO,
    /* doctype-token-in-before-html-mode */
    LXB_HTML_RULES_ERROR_DOTOINBEHTMO,
    /* unexpected-closed-token-in-before-html-mode */
    LXB_HTML_RULES_ERROR_UNCLTOINBEHTMO,
    /* doctype-token-in-before-head-mode */
    LXB_HTML_RULES_ERROR_DOTOINBEHEMO,
    /* unexpected-closed_token-in-before-head-mode */
    LXB_HTML_RULES_ERROR_UNCLTOINBEHEMO,
    /* doctype-token-in-head-mode */
    LXB_HTML_RULES_ERROR_DOTOINHEMO,
    /* non-void-html-element-start-tag-with-trailing-solidus */
    LXB_HTML_RULES_ERROR_NOVOHTELSTTAWITRSO,
    /* head-token-in-head-mode */
    LXB_HTML_RULES_ERROR_HETOINHEMO,
    /* unexpected-closed-token-in-head-mode */
    LXB_HTML_RULES_ERROR_UNCLTOINHEMO,
    /* template-closed-token-without-opening-in-head-mode */
    LXB_HTML_RULES_ERROR_TECLTOWIOPINHEMO,
    /* template-element-is-not-current-in-head-mode */
    LXB_HTML_RULES_ERROR_TEELISNOCUINHEMO,
    /* doctype-token-in-head-noscript-mode */
    LXB_HTML_RULES_ERROR_DOTOINHENOMO,
    /* doctype-token-after-head-mode */
    LXB_HTML_RULES_ERROR_DOTOAFHEMO,
    /* head-token-after-head-mode */
    LXB_HTML_RULES_ERROR_HETOAFHEMO,
    /* doctype-token-in-body-mode */
    LXB_HTML_RULES_ERROR_DOTOINBOMO,
    /* bad-ending-open-elements-is-wrong */
    LXB_HTML_RULES_ERROR_BAENOPELISWR,
    /* open-elements-is-wrong */
    LXB_HTML_RULES_ERROR_OPELISWR,
    /* unexpected-element-in-open-elements-stack */
    LXB_HTML_RULES_ERROR_UNELINOPELST,
    /* missing-element-in-open-elements-stack */
    LXB_HTML_RULES_ERROR_MIELINOPELST,
    /* no-body-element-in-scope */
    LXB_HTML_RULES_ERROR_NOBOELINSC,
    /* missing-element-in-scope */
    LXB_HTML_RULES_ERROR_MIELINSC,
    /* unexpected-element-in-scope */
    LXB_HTML_RULES_ERROR_UNELINSC,
    /* unexpected-element-in-active-formatting-stack */
    LXB_HTML_RULES_ERROR_UNELINACFOST,
    /* unexpected-end-of-file */
    LXB_HTML_RULES_ERROR_UNENOFFI,
    /* characters-in-table-text */
    LXB_HTML_RULES_ERROR_CHINTATE,
    /* doctype-token-in-table-mode */
    LXB_HTML_RULES_ERROR_DOTOINTAMO,
    /* doctype-token-in-select-mode */
    LXB_HTML_RULES_ERROR_DOTOINSEMO,
    /* doctype-token-after-body-mode */
    LXB_HTML_RULES_ERROR_DOTOAFBOMO,
    /* doctype-token-in-frameset-mode */
    LXB_HTML_RULES_ERROR_DOTOINFRMO,
    /* doctype-token-after-frameset-mode */
    LXB_HTML_RULES_ERROR_DOTOAFFRMO,
    /* doctype-token-foreign-content-mode */
    LXB_HTML_RULES_ERROR_DOTOFOCOMO,
    /* select-in-scope */
    LXB_HTML_RULES_ERROR_SEINSC,
    /* fragment-parsing-select-in-context-parse-input */
    LXB_HTML_RULES_ERROR_FRPASEINCOPAIN,
    /* fragment-parsing-select-in-context-parse-select */
    LXB_HTML_RULES_ERROR_FRPASEINCOPASE,
    /* hr-parsing-select-option-optgroup-in-scope */
    LXB_HTML_RULES_ERROR_HRPASEOPOPINSC,
    /* option-parsing-option-in-scope */
    LXB_HTML_RULES_ERROR_OPPAOPINSC,
    /* optgroup-parsing-option-optgroup-in-scope */
    LXB_HTML_RULES_ERROR_OPPAOPOPINSC,

    LXB_HTML_RULES_ERROR_LAST_ENTRY
}
alias LXB_HTML_RULES_ERROR_UNTO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_UNTO;
alias LXB_HTML_RULES_ERROR_UNCLTO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_UNCLTO;
alias LXB_HTML_RULES_ERROR_NUCH = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_NUCH;
alias LXB_HTML_RULES_ERROR_UNCHTO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_UNCHTO;
alias LXB_HTML_RULES_ERROR_UNTOININMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_UNTOININMO;
alias LXB_HTML_RULES_ERROR_BADOTOININMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_BADOTOININMO;
alias LXB_HTML_RULES_ERROR_DOTOINBEHTMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOINBEHTMO;
alias LXB_HTML_RULES_ERROR_UNCLTOINBEHTMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_UNCLTOINBEHTMO;
alias LXB_HTML_RULES_ERROR_DOTOINBEHEMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOINBEHEMO;
alias LXB_HTML_RULES_ERROR_UNCLTOINBEHEMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_UNCLTOINBEHEMO;
alias LXB_HTML_RULES_ERROR_DOTOINHEMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOINHEMO;
alias LXB_HTML_RULES_ERROR_NOVOHTELSTTAWITRSO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_NOVOHTELSTTAWITRSO;
alias LXB_HTML_RULES_ERROR_HETOINHEMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_HETOINHEMO;
alias LXB_HTML_RULES_ERROR_UNCLTOINHEMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_UNCLTOINHEMO;
alias LXB_HTML_RULES_ERROR_TECLTOWIOPINHEMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_TECLTOWIOPINHEMO;
alias LXB_HTML_RULES_ERROR_TEELISNOCUINHEMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_TEELISNOCUINHEMO;
alias LXB_HTML_RULES_ERROR_DOTOINHENOMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOINHENOMO;
alias LXB_HTML_RULES_ERROR_DOTOAFHEMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOAFHEMO;
alias LXB_HTML_RULES_ERROR_HETOAFHEMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_HETOAFHEMO;
alias LXB_HTML_RULES_ERROR_DOTOINBOMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOINBOMO;
alias LXB_HTML_RULES_ERROR_BAENOPELISWR = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_BAENOPELISWR;
alias LXB_HTML_RULES_ERROR_OPELISWR = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_OPELISWR;
alias LXB_HTML_RULES_ERROR_UNELINOPELST = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_UNELINOPELST;
alias LXB_HTML_RULES_ERROR_MIELINOPELST = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_MIELINOPELST;
alias LXB_HTML_RULES_ERROR_NOBOELINSC = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_NOBOELINSC;
alias LXB_HTML_RULES_ERROR_MIELINSC = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_MIELINSC;
alias LXB_HTML_RULES_ERROR_UNELINSC = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_UNELINSC;
alias LXB_HTML_RULES_ERROR_UNELINACFOST = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_UNELINACFOST;
alias LXB_HTML_RULES_ERROR_UNENOFFI = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_UNENOFFI;
alias LXB_HTML_RULES_ERROR_CHINTATE = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_CHINTATE;
alias LXB_HTML_RULES_ERROR_DOTOINTAMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOINTAMO;
alias LXB_HTML_RULES_ERROR_DOTOINSEMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOINSEMO;
alias LXB_HTML_RULES_ERROR_DOTOAFBOMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOAFBOMO;
alias LXB_HTML_RULES_ERROR_DOTOINFRMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOINFRMO;
alias LXB_HTML_RULES_ERROR_DOTOAFFRMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOAFFRMO;
alias LXB_HTML_RULES_ERROR_DOTOFOCOMO = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_DOTOFOCOMO;
alias LXB_HTML_RULES_ERROR_SEINSC = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_SEINSC;
alias LXB_HTML_RULES_ERROR_FRPASEINCOPAIN = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_FRPASEINCOPAIN;
alias LXB_HTML_RULES_ERROR_FRPASEINCOPASE = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_FRPASEINCOPASE;
alias LXB_HTML_RULES_ERROR_HRPASEOPOPINSC = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_HRPASEOPOPINSC;
alias LXB_HTML_RULES_ERROR_OPPAOPINSC = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_OPPAOPINSC;
alias LXB_HTML_RULES_ERROR_OPPAOPOPINSC = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_OPPAOPOPINSC;
alias LXB_HTML_RULES_ERROR_LAST_ENTRY = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_LAST_ENTRY;


struct lxb_html_tree_error_t {
    lxb_html_tree_error_id_t id;
    const(lxb_char_t)* begin;
    const(lxb_char_t)* end;
}



// ---- error.c ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_html_tree_error_t* lxb_html_tree_error_add(lexbor_array_obj_t* parse_errors, lxb_html_token_t* token, lxb_html_tree_error_id_t id)
{
    if (parse_errors == null) {
        return null;
    }

    lxb_html_tree_error_t* entry = cast(lxb_html_tree_error_t*) lexbor_array_obj_push(parse_errors);
    if (entry == null) {
        return null;
    }

    entry.id = id;
    entry.begin = token.begin;
    entry.end = token.end;

    return entry;
}

const(lxb_char_t)* lxb_html_tree_error_to_string(lxb_html_tree_error_id_t id, size_t* len)
{
    static const(lexbor_str_t) unknown = {data: cast(lxb_char_t*) "unknown error".ptr, "unknown error".length};

    static const(lexbor_str_t)[LXB_HTML_RULES_ERROR_LAST_ENTRY] errors = [
        {data: cast(lxb_char_t*) "unexpected token".ptr, "unexpected token".length},
        {data: cast(lxb_char_t*) "unexpected closed token".ptr, "unexpected closed token".length},
        {data: cast(lxb_char_t*) "null character".ptr, "null character".length},
        {data: cast(lxb_char_t*) "unexpected character token".ptr, "unexpected character token".length},
        {data: cast(lxb_char_t*) "unexpected token in initial mode".ptr, "unexpected token in initial mode".length},
        {data: cast(lxb_char_t*) "bad doctype token in initial mode".ptr, "bad doctype token in initial mode".length},
        {data: cast(lxb_char_t*) "doctype token in before html mode".ptr, "doctype token in before html mode".length},
        {data: cast(lxb_char_t*) "unexpected closed token in before html mode".ptr, "unexpected closed token in before html mode".length},
        {data: cast(lxb_char_t*) "doctype token in before head mode".ptr, "doctype token in before head mode".length},
        {data: cast(lxb_char_t*) "unexpected closed token in before head mode".ptr, "unexpected closed token in before head mode".length},
        {data: cast(lxb_char_t*) "doctype token in head mode".ptr, "doctype token in head mode".length},
        {data: cast(lxb_char_t*) "non void html element start tag with trailing solidus".ptr, "non void html element start tag with trailing solidus".length},
        {data: cast(lxb_char_t*) "head token in head mode".ptr, "head token in head mode".length},
        {data: cast(lxb_char_t*) "unexpected closed token in head mode".ptr, "unexpected closed token in head mode".length},
        {data: cast(lxb_char_t*) "template closed token without opening in head mode".ptr, "template closed token without opening in head mode".length},
        {data: cast(lxb_char_t*) "template element is not current in head mode".ptr, "template element is not current in head mode".length},
        {data: cast(lxb_char_t*) "doctype token in head noscript mode".ptr, "doctype token in head noscript mode".length},
        {data: cast(lxb_char_t*) "doctype token after head mode".ptr, "doctype token after head mode".length},
        {data: cast(lxb_char_t*) "head token after head mode".ptr, "head token after head mode".length},
        {data: cast(lxb_char_t*) "doctype token in body mode".ptr, "doctype token in body mode".length},
        {data: cast(lxb_char_t*) "bad ending open elements is wrong".ptr, "bad ending open elements is wrong".length},
        {data: cast(lxb_char_t*) "open elements is wrong".ptr, "open elements is wrong".length},
        {data: cast(lxb_char_t*) "unexpected element in open elements stack".ptr, "unexpected element in open elements stack".length},
        {data: cast(lxb_char_t*) "missing element in open elements stack".ptr, "missing element in open elements stack".length},
        {data: cast(lxb_char_t*) "no body element in scope".ptr, "no body element in scope".length},
        {data: cast(lxb_char_t*) "missing element in scope".ptr, "missing element in scope".length},
        {data: cast(lxb_char_t*) "unexpected element in scope".ptr, "unexpected element in scope".length},
        {data: cast(lxb_char_t*) "unexpected element in active formatting stack".ptr, "unexpected element in active formatting stack".length},
        {data: cast(lxb_char_t*) "unexpected end of file".ptr, "unexpected end of file".length},
        {data: cast(lxb_char_t*) "characters in table text".ptr, "characters in table text".length},
        {data: cast(lxb_char_t*) "doctype token in table mode".ptr, "doctype token in table mode".length},
        {data: cast(lxb_char_t*) "doctype token in select mode".ptr, "doctype token in select mode".length},
        {data: cast(lxb_char_t*) "doctype token after body mode".ptr, "doctype token after body mode".length},
        {data: cast(lxb_char_t*) "doctype token in frameset mode".ptr, "doctype token in frameset mode".length},
        {data: cast(lxb_char_t*) "doctype token after frameset mode".ptr, "doctype token after frameset mode".length},
        {data: cast(lxb_char_t*) "doctype token foreign content mode".ptr, "doctype token foreign content mode".length},
        {data: cast(lxb_char_t*) "select in scope".ptr, "select in scope".length},
        {data: cast(lxb_char_t*) "fragment parsing select in context parse input".ptr, "fragment parsing select in context parse input".length},
        {data: cast(lxb_char_t*) "fragment parsing select in context parse select".ptr, "fragment parsing select in context parse select".length},
        {data: cast(lxb_char_t*) "hr parsing select option optgroup in scope".ptr, "hr parsing select option optgroup in scope".length},
        {data: cast(lxb_char_t*) "option parsing option in scope".ptr, "option parsing option in scope".length},
        {data: cast(lxb_char_t*) "optgroup parsing option optgroup in scope".ptr, "optgroup parsing option optgroup in scope".length}
    ];

    if (id >= (errors.sizeof / lexbor_str_t.sizeof)) {
        if (len != null) {
            *len = unknown.length;
        }

        return unknown.data;
    }

    if (len != null) {
        *len = errors[id].length;
    }

    return errors[id].data;
}
