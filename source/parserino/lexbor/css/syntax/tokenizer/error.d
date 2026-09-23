module parserino.lexbor.css.syntax.tokenizer.error;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.core.array_obj;

extern(C) @nogc nothrow:
__gshared:

// ---- error.h ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum lxb_css_syntax_tokenizer_error_id_t {
    /* unexpected-eof */
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_UNEOF = 0x0000,
    /* eof-in-comment */
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINCO,
    /* eof-in-string */
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINST,
    /* eof-in-url */
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINUR,
    /* eof-in-escaped */
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINES,
    /* qo-in-url */
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_QOINUR,
    /* wrong-escape-in-url */
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_WRESINUR,
    /* newline-in-string */
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_NEINST,
    /* bad-char */
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_BACH,
    /* bad-code-point */
    LXB_CSS_SYNTAX_TOKENIZER_ERROR_BACOPO,
}
alias LXB_CSS_SYNTAX_TOKENIZER_ERROR_UNEOF = lxb_css_syntax_tokenizer_error_id_t.LXB_CSS_SYNTAX_TOKENIZER_ERROR_UNEOF;
alias LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINCO = lxb_css_syntax_tokenizer_error_id_t.LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINCO;
alias LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINST = lxb_css_syntax_tokenizer_error_id_t.LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINST;
alias LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINUR = lxb_css_syntax_tokenizer_error_id_t.LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINUR;
alias LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINES = lxb_css_syntax_tokenizer_error_id_t.LXB_CSS_SYNTAX_TOKENIZER_ERROR_EOINES;
alias LXB_CSS_SYNTAX_TOKENIZER_ERROR_QOINUR = lxb_css_syntax_tokenizer_error_id_t.LXB_CSS_SYNTAX_TOKENIZER_ERROR_QOINUR;
alias LXB_CSS_SYNTAX_TOKENIZER_ERROR_WRESINUR = lxb_css_syntax_tokenizer_error_id_t.LXB_CSS_SYNTAX_TOKENIZER_ERROR_WRESINUR;
alias LXB_CSS_SYNTAX_TOKENIZER_ERROR_NEINST = lxb_css_syntax_tokenizer_error_id_t.LXB_CSS_SYNTAX_TOKENIZER_ERROR_NEINST;
alias LXB_CSS_SYNTAX_TOKENIZER_ERROR_BACH = lxb_css_syntax_tokenizer_error_id_t.LXB_CSS_SYNTAX_TOKENIZER_ERROR_BACH;
alias LXB_CSS_SYNTAX_TOKENIZER_ERROR_BACOPO = lxb_css_syntax_tokenizer_error_id_t.LXB_CSS_SYNTAX_TOKENIZER_ERROR_BACOPO;


struct lxb_css_syntax_tokenizer_error_t {
    const(lxb_char_t)* pos;
    lxb_css_syntax_tokenizer_error_id_t id;
}


// ---- error.c ----
/*
 * Copyright (C) 2018-2019 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_css_syntax_tokenizer_error_t* lxb_css_syntax_tokenizer_error_add(lexbor_array_obj_t* parse_errors, const(lxb_char_t)* pos, lxb_css_syntax_tokenizer_error_id_t id)
{
    if (parse_errors == null) {
        return null;
    }

    lxb_css_syntax_tokenizer_error_t* entry = void;

    entry = cast(lxb_css_syntax_tokenizer_error_t*) lexbor_array_obj_push(parse_errors);
    if (entry == null) {
        return null;
    }

    entry.id = id;
    entry.pos = pos;

    return entry;
}
