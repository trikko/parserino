module parserino.lexbor.html.tokenizer.error;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.core.array_obj;
public import parserino.lexbor.html.tokenizer;
import parserino.lexbor.core.str;

extern(C) @nogc nothrow:
__gshared:

// ---- error.h ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum lxb_html_tokenizer_error_id_t {
    /* abrupt-closing-of-empty-comment */
    LXB_HTML_TOKENIZER_ERROR_ABCLOFEMCO = 0x0000,
    /* abrupt-doctype-public-identifier */
    LXB_HTML_TOKENIZER_ERROR_ABDOPUID,
    /* abrupt-doctype-system-identifier */
    LXB_HTML_TOKENIZER_ERROR_ABDOSYID,
    /* absence-of-digits-in-numeric-character-reference */
    LXB_HTML_TOKENIZER_ERROR_ABOFDIINNUCHRE,
    /* cdata-in-html-content */
    LXB_HTML_TOKENIZER_ERROR_CDINHTCO,
    /* character-reference-outside-unicode-range */
    LXB_HTML_TOKENIZER_ERROR_CHREOUUNRA,
    /* control-character-in-input-stream */
    LXB_HTML_TOKENIZER_ERROR_COCHININST,
    /* control-character-reference */
    LXB_HTML_TOKENIZER_ERROR_COCHRE,
    /* end-tag-with-attributes */
    LXB_HTML_TOKENIZER_ERROR_ENTAWIAT,
    /* duplicate-attribute */
    LXB_HTML_TOKENIZER_ERROR_DUAT,
    /* end-tag-with-trailing-solidus */
    LXB_HTML_TOKENIZER_ERROR_ENTAWITRSO,
    /* eof-before-tag-name */
    LXB_HTML_TOKENIZER_ERROR_EOBETANA,
    /* eof-in-cdata */
    LXB_HTML_TOKENIZER_ERROR_EOINCD,
    /* eof-in-comment */
    LXB_HTML_TOKENIZER_ERROR_EOINCO,
    /* eof-in-doctype */
    LXB_HTML_TOKENIZER_ERROR_EOINDO,
    /* eof-in-script-html-comment-like-text */
    LXB_HTML_TOKENIZER_ERROR_EOINSCHTCOLITE,
    /* eof-in-tag */
    LXB_HTML_TOKENIZER_ERROR_EOINTA,
    /* incorrectly-closed-comment */
    LXB_HTML_TOKENIZER_ERROR_INCLCO,
    /* incorrectly-opened-comment */
    LXB_HTML_TOKENIZER_ERROR_INOPCO,
    /* invalid-character-sequence-after-doctype-name */
    LXB_HTML_TOKENIZER_ERROR_INCHSEAFDONA,
    /* invalid-first-character-of-tag-name */
    LXB_HTML_TOKENIZER_ERROR_INFICHOFTANA,
    /* missing-attribute-value */
    LXB_HTML_TOKENIZER_ERROR_MIATVA,
    /* missing-doctype-name */
    LXB_HTML_TOKENIZER_ERROR_MIDONA,
    /* missing-doctype-public-identifier */
    LXB_HTML_TOKENIZER_ERROR_MIDOPUID,
    /* missing-doctype-system-identifier */
    LXB_HTML_TOKENIZER_ERROR_MIDOSYID,
    /* missing-end-tag-name */
    LXB_HTML_TOKENIZER_ERROR_MIENTANA,
    /* missing-quote-before-doctype-public-identifier */
    LXB_HTML_TOKENIZER_ERROR_MIQUBEDOPUID,
    /* missing-quote-before-doctype-system-identifier */
    LXB_HTML_TOKENIZER_ERROR_MIQUBEDOSYID,
    /* missing-semicolon-after-character-reference */
    LXB_HTML_TOKENIZER_ERROR_MISEAFCHRE,
    /* missing-whitespace-after-doctype-public-keyword */
    LXB_HTML_TOKENIZER_ERROR_MIWHAFDOPUKE,
    /* missing-whitespace-after-doctype-system-keyword */
    LXB_HTML_TOKENIZER_ERROR_MIWHAFDOSYKE,
    /* missing-whitespace-before-doctype-name */
    LXB_HTML_TOKENIZER_ERROR_MIWHBEDONA,
    /* missing-whitespace-between-attributes */
    LXB_HTML_TOKENIZER_ERROR_MIWHBEAT,
    /* missing-whitespace-between-doctype-public-and-system-identifiers */
    LXB_HTML_TOKENIZER_ERROR_MIWHBEDOPUANSYID,
    /* nested-comment */
    LXB_HTML_TOKENIZER_ERROR_NECO,
    /* noncharacter-character-reference */
    LXB_HTML_TOKENIZER_ERROR_NOCHRE,
    /* noncharacter-in-input-stream */
    LXB_HTML_TOKENIZER_ERROR_NOININST,
    /* non-void-html-element-start-tag-with-trailing-solidus */
    LXB_HTML_TOKENIZER_ERROR_NOVOHTELSTTAWITRSO,
    /* null-character-reference */
    LXB_HTML_TOKENIZER_ERROR_NUCHRE,
    /* surrogate-character-reference */
    LXB_HTML_TOKENIZER_ERROR_SUCHRE,
    /* surrogate-in-input-stream */
    LXB_HTML_TOKENIZER_ERROR_SUININST,
    /* unexpected-character-after-doctype-system-identifier */
    LXB_HTML_TOKENIZER_ERROR_UNCHAFDOSYID,
    /* unexpected-character-in-attribute-name */
    LXB_HTML_TOKENIZER_ERROR_UNCHINATNA,
    /* unexpected-character-in-unquoted-attribute-value */
    LXB_HTML_TOKENIZER_ERROR_UNCHINUNATVA,
    /* unexpected-equals-sign-before-attribute-name */
    LXB_HTML_TOKENIZER_ERROR_UNEQSIBEATNA,
    /* unexpected-null-character */
    LXB_HTML_TOKENIZER_ERROR_UNNUCH,
    /* unexpected-question-mark-instead-of-tag-name */
    LXB_HTML_TOKENIZER_ERROR_UNQUMAINOFTANA,
    /* unexpected-solidus-in-tag */
    LXB_HTML_TOKENIZER_ERROR_UNSOINTA,
    /* unknown-named-character-reference */
    LXB_HTML_TOKENIZER_ERROR_UNNACHRE,
    /* eof-in-processing-instruction */
    LXB_HTML_TOKENIZER_ERROR_EOINPRIN,
    /* invalid-first-character-of-processing-instruction-target */
    LXB_HTML_TOKENIZER_ERROR_INFICHOFPRINTA,
    /* disallowed-processing-instruction-target */
    LXB_HTML_TOKENIZER_ERROR_DIPRINTA,
    /* invalid-processing-instruction-target */
    LXB_HTML_TOKENIZER_ERROR_INPRINTA,

    LXB_HTML_TOKENIZER_ERROR_LAST_ENTRY
}
alias LXB_HTML_TOKENIZER_ERROR_ABCLOFEMCO = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_ABCLOFEMCO;
alias LXB_HTML_TOKENIZER_ERROR_ABDOPUID = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_ABDOPUID;
alias LXB_HTML_TOKENIZER_ERROR_ABDOSYID = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_ABDOSYID;
alias LXB_HTML_TOKENIZER_ERROR_ABOFDIINNUCHRE = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_ABOFDIINNUCHRE;
alias LXB_HTML_TOKENIZER_ERROR_CDINHTCO = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_CDINHTCO;
alias LXB_HTML_TOKENIZER_ERROR_CHREOUUNRA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_CHREOUUNRA;
alias LXB_HTML_TOKENIZER_ERROR_COCHININST = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_COCHININST;
alias LXB_HTML_TOKENIZER_ERROR_COCHRE = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_COCHRE;
alias LXB_HTML_TOKENIZER_ERROR_ENTAWIAT = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_ENTAWIAT;
alias LXB_HTML_TOKENIZER_ERROR_DUAT = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_DUAT;
alias LXB_HTML_TOKENIZER_ERROR_ENTAWITRSO = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_ENTAWITRSO;
alias LXB_HTML_TOKENIZER_ERROR_EOBETANA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_EOBETANA;
alias LXB_HTML_TOKENIZER_ERROR_EOINCD = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_EOINCD;
alias LXB_HTML_TOKENIZER_ERROR_EOINCO = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_EOINCO;
alias LXB_HTML_TOKENIZER_ERROR_EOINDO = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_EOINDO;
alias LXB_HTML_TOKENIZER_ERROR_EOINSCHTCOLITE = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_EOINSCHTCOLITE;
alias LXB_HTML_TOKENIZER_ERROR_EOINTA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_EOINTA;
alias LXB_HTML_TOKENIZER_ERROR_INCLCO = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_INCLCO;
alias LXB_HTML_TOKENIZER_ERROR_INOPCO = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_INOPCO;
alias LXB_HTML_TOKENIZER_ERROR_INCHSEAFDONA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_INCHSEAFDONA;
alias LXB_HTML_TOKENIZER_ERROR_INFICHOFTANA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_INFICHOFTANA;
alias LXB_HTML_TOKENIZER_ERROR_MIATVA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIATVA;
alias LXB_HTML_TOKENIZER_ERROR_MIDONA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIDONA;
alias LXB_HTML_TOKENIZER_ERROR_MIDOPUID = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIDOPUID;
alias LXB_HTML_TOKENIZER_ERROR_MIDOSYID = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIDOSYID;
alias LXB_HTML_TOKENIZER_ERROR_MIENTANA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIENTANA;
alias LXB_HTML_TOKENIZER_ERROR_MIQUBEDOPUID = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIQUBEDOPUID;
alias LXB_HTML_TOKENIZER_ERROR_MIQUBEDOSYID = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIQUBEDOSYID;
alias LXB_HTML_TOKENIZER_ERROR_MISEAFCHRE = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MISEAFCHRE;
alias LXB_HTML_TOKENIZER_ERROR_MIWHAFDOPUKE = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIWHAFDOPUKE;
alias LXB_HTML_TOKENIZER_ERROR_MIWHAFDOSYKE = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIWHAFDOSYKE;
alias LXB_HTML_TOKENIZER_ERROR_MIWHBEDONA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIWHBEDONA;
alias LXB_HTML_TOKENIZER_ERROR_MIWHBEAT = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIWHBEAT;
alias LXB_HTML_TOKENIZER_ERROR_MIWHBEDOPUANSYID = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_MIWHBEDOPUANSYID;
alias LXB_HTML_TOKENIZER_ERROR_NECO = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_NECO;
alias LXB_HTML_TOKENIZER_ERROR_NOCHRE = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_NOCHRE;
alias LXB_HTML_TOKENIZER_ERROR_NOININST = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_NOININST;
alias LXB_HTML_TOKENIZER_ERROR_NOVOHTELSTTAWITRSO = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_NOVOHTELSTTAWITRSO;
alias LXB_HTML_TOKENIZER_ERROR_NUCHRE = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_NUCHRE;
alias LXB_HTML_TOKENIZER_ERROR_SUCHRE = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_SUCHRE;
alias LXB_HTML_TOKENIZER_ERROR_SUININST = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_SUININST;
alias LXB_HTML_TOKENIZER_ERROR_UNCHAFDOSYID = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_UNCHAFDOSYID;
alias LXB_HTML_TOKENIZER_ERROR_UNCHINATNA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_UNCHINATNA;
alias LXB_HTML_TOKENIZER_ERROR_UNCHINUNATVA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_UNCHINUNATVA;
alias LXB_HTML_TOKENIZER_ERROR_UNEQSIBEATNA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_UNEQSIBEATNA;
alias LXB_HTML_TOKENIZER_ERROR_UNNUCH = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_UNNUCH;
alias LXB_HTML_TOKENIZER_ERROR_UNQUMAINOFTANA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_UNQUMAINOFTANA;
alias LXB_HTML_TOKENIZER_ERROR_UNSOINTA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_UNSOINTA;
alias LXB_HTML_TOKENIZER_ERROR_UNNACHRE = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_UNNACHRE;
alias LXB_HTML_TOKENIZER_ERROR_EOINPRIN = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_EOINPRIN;
alias LXB_HTML_TOKENIZER_ERROR_INFICHOFPRINTA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_INFICHOFPRINTA;
alias LXB_HTML_TOKENIZER_ERROR_DIPRINTA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_DIPRINTA;
alias LXB_HTML_TOKENIZER_ERROR_INPRINTA = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_INPRINTA;
alias LXB_HTML_TOKENIZER_ERROR_LAST_ENTRY = lxb_html_tokenizer_error_id_t.LXB_HTML_TOKENIZER_ERROR_LAST_ENTRY;


struct lxb_html_tokenizer_error_t {
    const(lxb_char_t)* pos;
    lxb_html_tokenizer_error_id_t id;
}



// ---- error.c ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_html_tokenizer_error_t* lxb_html_tokenizer_error_add(lexbor_array_obj_t* parse_errors, const(lxb_char_t)* pos, lxb_html_tokenizer_error_id_t id)
{
    if (parse_errors == null) {
        return null;
    }

    lxb_html_tokenizer_error_t* entry = cast(lxb_html_tokenizer_error_t*) lexbor_array_obj_push(parse_errors);
    if (entry == null) {
        return null;
    }

    entry.id = id;
    entry.pos = pos;

    return entry;
}

const(lxb_char_t)* lxb_html_tokenizer_error_to_string(lxb_html_tokenizer_error_id_t id, size_t* len)
{
    static const(lexbor_str_t) unknown = {data: cast(lxb_char_t*) "unknown error".ptr, "unknown error".length};

    static const(lexbor_str_t)[LXB_HTML_TOKENIZER_ERROR_LAST_ENTRY] errors = [
        {data: cast(lxb_char_t*) "abrupt closing of empty comment".ptr, "abrupt closing of empty comment".length},
        {data: cast(lxb_char_t*) "abrupt doctype public identifier".ptr, "abrupt doctype public identifier".length},
        {data: cast(lxb_char_t*) "abrupt doctype system identifier".ptr, "abrupt doctype system identifier".length},
        {data: cast(lxb_char_t*) "absence of digits in numeric character reference".ptr, "absence of digits in numeric character reference".length},
        {data: cast(lxb_char_t*) "cdata in html content".ptr, "cdata in html content".length},
        {data: cast(lxb_char_t*) "character reference outside unicode range".ptr, "character reference outside unicode range".length},
        {data: cast(lxb_char_t*) "control character in input stream".ptr, "control character in input stream".length},
        {data: cast(lxb_char_t*) "control character reference".ptr, "control character reference".length},
        {data: cast(lxb_char_t*) "end tag with attributes".ptr, "end tag with attributes".length},
        {data: cast(lxb_char_t*) "duplicate attribute".ptr, "duplicate attribute".length},
        {data: cast(lxb_char_t*) "end tag with trailing solidus".ptr, "end tag with trailing solidus".length},
        {data: cast(lxb_char_t*) "eof before tag name".ptr, "eof before tag name".length},
        {data: cast(lxb_char_t*) "eof in cdata".ptr, "eof in cdata".length},
        {data: cast(lxb_char_t*) "eof in comment".ptr, "eof in comment".length},
        {data: cast(lxb_char_t*) "eof in doctype".ptr, "eof in doctype".length},
        {data: cast(lxb_char_t*) "eof in script html comment like text".ptr, "eof in script html comment like text".length},
        {data: cast(lxb_char_t*) "eof in tag".ptr, "eof in tag".length},
        {data: cast(lxb_char_t*) "incorrectly closed comment".ptr, "incorrectly closed comment".length},
        {data: cast(lxb_char_t*) "incorrectly opened comment".ptr, "incorrectly opened comment".length},
        {data: cast(lxb_char_t*) "invalid character sequence after doctype name".ptr, "invalid character sequence after doctype name".length},
        {data: cast(lxb_char_t*) "invalid first character of tag name".ptr, "invalid first character of tag name".length},
        {data: cast(lxb_char_t*) "missing attribute value".ptr, "missing attribute value".length},
        {data: cast(lxb_char_t*) "missing doctype name".ptr, "missing doctype name".length},
        {data: cast(lxb_char_t*) "missing doctype public identifier".ptr, "missing doctype public identifier".length},
        {data: cast(lxb_char_t*) "missing doctype system identifier".ptr, "missing doctype system identifier".length},
        {data: cast(lxb_char_t*) "missing end tag name".ptr, "missing end tag name".length},
        {data: cast(lxb_char_t*) "missing quote before doctype public identifier".ptr, "missing quote before doctype public identifier".length},
        {data: cast(lxb_char_t*) "missing quote before doctype system identifier".ptr, "missing quote before doctype system identifier".length},
        {data: cast(lxb_char_t*) "missing semicolon after character reference".ptr, "missing semicolon after character reference".length},
        {data: cast(lxb_char_t*) "missing whitespace after doctype public keyword".ptr, "missing whitespace after doctype public keyword".length},
        {data: cast(lxb_char_t*) "missing whitespace after doctype system keyword".ptr, "missing whitespace after doctype system keyword".length},
        {data: cast(lxb_char_t*) "missing whitespace before doctype name".ptr, "missing whitespace before doctype name".length},
        {data: cast(lxb_char_t*) "missing whitespace between attributes".ptr, "missing whitespace between attributes".length},
        {data: cast(lxb_char_t*) "missing whitespace between doctype public and system identifiers".ptr, "missing whitespace between doctype public and system identifiers".length},
        {data: cast(lxb_char_t*) "nested comment".ptr, "nested comment".length},
        {data: cast(lxb_char_t*) "noncharacter character reference".ptr, "noncharacter character reference".length},
        {data: cast(lxb_char_t*) "noncharacter in input stream".ptr, "noncharacter in input stream".length},
        {data: cast(lxb_char_t*) "non void html element start tag with trailing solidus".ptr, "non void html element start tag with trailing solidus".length},
        {data: cast(lxb_char_t*) "null character reference".ptr, "null character reference".length},
        {data: cast(lxb_char_t*) "surrogate character reference".ptr, "surrogate character reference".length},
        {data: cast(lxb_char_t*) "surrogate in input stream".ptr, "surrogate in input stream".length},
        {data: cast(lxb_char_t*) "unexpected character after doctype system identifier".ptr, "unexpected character after doctype system identifier".length},
        {data: cast(lxb_char_t*) "unexpected character in attribute name".ptr, "unexpected character in attribute name".length},
        {data: cast(lxb_char_t*) "unexpected character in unquoted attribute value".ptr, "unexpected character in unquoted attribute value".length},
        {data: cast(lxb_char_t*) "unexpected equals sign before attribute name".ptr, "unexpected equals sign before attribute name".length},
        {data: cast(lxb_char_t*) "unexpected null character".ptr, "unexpected null character".length},
        {data: cast(lxb_char_t*) "unexpected question mark instead of tag name".ptr, "unexpected question mark instead of tag name".length},
        {data: cast(lxb_char_t*) "unexpected solidus in tag".ptr, "unexpected solidus in tag".length},
        {data: cast(lxb_char_t*) "unknown named character reference".ptr, "unknown named character reference".length},
        {data: cast(lxb_char_t*) "eof in processing instruction".ptr, "eof in processing instruction".length},
        {data: cast(lxb_char_t*) "invalid first character of processing instruction target".ptr, "invalid first character of processing instruction target".length},
        {data: cast(lxb_char_t*) "disallowed processing instruction target".ptr, "disallowed processing instruction target".length},
        {data: cast(lxb_char_t*) "invalid processing instruction target".ptr, "invalid processing instruction target".length}
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
