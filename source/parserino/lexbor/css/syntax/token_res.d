module parserino.lexbor.css.syntax.token_res;

import parserino.lexbor.css.syntax.token;
import parserino.lexbor.core.shs;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>


extern(C) @nogc nothrow:
__gshared:

// ---- token_res.h ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

const(lexbor_shs_entry_t)[136] lxb_css_syntax_token_res_name_shs_map = [
    {null, null, 135, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"colon", cast(void*) LXB_CSS_SYNTAX_TOKEN_COLON, 5, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"undefined", cast(void*) LXB_CSS_SYNTAX_TOKEN_UNDEF, 9, 0}, {"right-curly-bracket", cast(void*) LXB_CSS_SYNTAX_TOKEN_RC_BRACKET, 19, 0},
    {"right-square-bracket", cast(void*) LXB_CSS_SYNTAX_TOKEN_RS_BRACKET, 20, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"delim", cast(void*) LXB_CSS_SYNTAX_TOKEN_DELIM, 5, 0}, {"left-parenthesis", cast(void*) LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS, 16, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"dimension", cast(void*) LXB_CSS_SYNTAX_TOKEN_DIMENSION, 9, 0}, {"url", cast(void*) LXB_CSS_SYNTAX_TOKEN_URL, 3, 0},
    {"string", cast(void*) LXB_CSS_SYNTAX_TOKEN_STRING, 6, 0}, {"comma", cast(void*) LXB_CSS_SYNTAX_TOKEN_COMMA, 5, 0},
    {null, null, 0, 0}, {"bad-url", cast(void*) LXB_CSS_SYNTAX_TOKEN_BAD_URL, 7, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {"hash", cast(void*) LXB_CSS_SYNTAX_TOKEN_HASH, 4, 0},
    {null, null, 0, 0}, {"ident", cast(void*) LXB_CSS_SYNTAX_TOKEN_IDENT, 5, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"function", cast(void*) LXB_CSS_SYNTAX_TOKEN_FUNCTION, 8, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"cdc", cast(void*) LXB_CSS_SYNTAX_TOKEN_CDC, 3, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"unicode-range", cast(void*) LXB_CSS_SYNTAX_TOKEN_UNICODE_RANGE, 13, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {"left-curly-bracket", cast(void*) LXB_CSS_SYNTAX_TOKEN_LC_BRACKET, 18, 0},
    {"left-square-bracket", cast(void*) LXB_CSS_SYNTAX_TOKEN_LS_BRACKET, 19, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"bad-string", cast(void*) LXB_CSS_SYNTAX_TOKEN_BAD_STRING, 10, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"whitespace", cast(void*) LXB_CSS_SYNTAX_TOKEN_WHITESPACE, 10, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {"cdo", cast(void*) LXB_CSS_SYNTAX_TOKEN_CDO, 3, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {"comment", cast(void*) LXB_CSS_SYNTAX_TOKEN_COMMENT, 7, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"at-keyword", cast(void*) LXB_CSS_SYNTAX_TOKEN_AT_KEYWORD, 10, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"right-parenthesis", cast(void*) LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS, 17, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"number", cast(void*) LXB_CSS_SYNTAX_TOKEN_NUMBER, 6, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {"percentage", cast(void*) LXB_CSS_SYNTAX_TOKEN_PERCENTAGE, 10, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {"end-of-file", cast(void*) LXB_CSS_SYNTAX_TOKEN__EOF, 11, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {null, null, 0, 0},
    {null, null, 0, 0}, {"semicolon", cast(void*) LXB_CSS_SYNTAX_TOKEN_SEMICOLON, 9, 0}
];
