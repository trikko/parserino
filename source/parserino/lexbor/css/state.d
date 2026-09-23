module parserino.lexbor.css.state;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.base;
import parserino.lexbor.css.css;
import parserino.lexbor.css.at_rule.state;

extern(C) @nogc nothrow:
__gshared:

// ---- state.h ----
/*
 * Copyright (C) 2021-2022 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */



// ---- state.c ----
/*
 * Copyright (C) 2021-2022 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

bool lxb_css_state_success(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            lxb_css_syntax_parser_consume(parser);
            return true;

        case LXB_CSS_SYNTAX_TOKEN__END:
            return true;

        default:
            break;
    }

    return lxb_css_parser_failed(parser);
}

bool lxb_css_state_failed(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    if (token.type == LXB_CSS_SYNTAX_TOKEN__END) {
        return lxb_css_parser_success(parser);
    }

    /* The lxb_css_syntax_parser_consume(...) locked in this state. */

    lxb_css_syntax_token_consume(parser.tkz);

    return true;
}

bool lxb_css_state_stop(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    return lxb_css_parser_stop(parser);
}
