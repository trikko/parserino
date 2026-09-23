module parserino.lexbor.html.tree.error;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.core.array_obj;
public import parserino.lexbor.html.token;

extern(C) @nogc nothrow:
__gshared:

// ---- error.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
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
alias LXB_HTML_RULES_ERROR_LAST_ENTRY = lxb_html_tree_error_id_t.LXB_HTML_RULES_ERROR_LAST_ENTRY;


struct lxb_html_tree_error_t {
    lxb_html_tree_error_id_t id;
    const(lxb_char_t)* begin;
    const(lxb_char_t)* end;
}


// ---- error.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
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
