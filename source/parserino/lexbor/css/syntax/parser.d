module parserino.lexbor.css.syntax.parser;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.base;
public import parserino.lexbor.css.at_rule;
import parserino.lexbor.css.css;
import parserino.lexbor.css.state;
import parserino.lexbor.css.syntax.syntax;
import parserino.lexbor.css.at_rule.state;

extern(C) @nogc nothrow:
__gshared:

// ---- parser.h ----
/*
 * Copyright (C) 2020-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */














// ---- parser.c ----
/*
 * Copyright (C) 2020-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

private const(lxb_css_syntax_token_t) lxb_css_syntax_token_terminated = {
    types: {terminated: {begin: null, length: 0, user_id: 0}},
    type: LXB_CSS_SYNTAX_TOKEN__END,
    offset: 0,
    cloned: false
};




















 const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_failed(lxb_css_parser_t* parser, lxb_status_t status)
{
    parser.status = status;
    return null;
}

lxb_status_t lxb_css_syntax_parser_run(lxb_css_parser_t* parser)
{
    const(lxb_css_syntax_token_t)* token = void;

    parser.loop = true;

    do {
        token = lxb_css_syntax_parser_token(parser);
        if (token == null) {
            if (parser.fake_null) {
                parser.fake_null = false;
                continue;
            }

            return parser.status;
        }

        while (parser.rules.state(parser, token,
                                    parser.rules.context) == false) {}{}
    }
    while (parser.loop);

    return parser.status;
}

const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_token(lxb_css_parser_t* parser)
{
    lxb_css_syntax_token_t* token = void;
    lxb_css_syntax_rule_t* rule = parser.rules;

    token = lxb_css_syntax_token(parser.tkz);
    if (token == null) {
        return lxb_css_syntax_parser_failed(parser, parser.tkz.status);
    }

    return rule.phase(parser, token, rule);
}

const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_token_wo_ws(lxb_css_parser_t* parser)
{
    const(lxb_css_syntax_token_t)* token = void;

    token = lxb_css_syntax_parser_token(parser);

    if (token != null && token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
        lxb_css_syntax_parser_consume(parser);
        return lxb_css_syntax_parser_token(parser);
    }

    return token;
}

void lxb_css_syntax_parser_consume(lxb_css_parser_t* parser)
{
    if (!parser.rules.skip_consume) {
        lxb_css_syntax_token_consume(parser.tkz);
    }
}

lxb_css_syntax_rule_t* lxb_css_syntax_parser_list_rules_push(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_parser_state_f state_back, const(lxb_css_syntax_cb_list_rules_t)* cb_rules, void* ctx, bool top_level, lxb_css_syntax_token_type_t stop)
{
    lxb_status_t status = void;
    lxb_css_syntax_rule_t* rule = void;

    lxb_css_parser_offset_set(parser, token);

    status = lxb_css_syntax_stack_expand(parser, 1);
    if (status != LXB_STATUS_OK) {
        parser.status = status;
        return null;
    }

    parser.rules.state = &lxb_css_state_success;

    rule = ++parser.rules;

    memset(rule, 0x00, lxb_css_syntax_rule_t.sizeof);

    rule.phase = &lxb_css_syntax_parser_list_rules;
    rule.state = cb_rules.cb.state;
    rule.state_back = state_back;
    rule.back = &lxb_css_syntax_parser_list_rules;
    rule.cbx.list_rules = cb_rules;
    rule.context = ctx;
    rule.block_end = stop;
    rule.top_level = top_level;

    if (token != null) {
        rule.u.list_rules.begin = token.offset;
    }

    parser.context = null;

    return rule;
}

lxb_css_syntax_rule_t* lxb_css_syntax_parser_at_rule_push(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_parser_state_f state_back, const(lxb_css_syntax_cb_at_rule_t)* at_rule, void* ctx, lxb_css_syntax_token_type_t stop)
{
    lxb_status_t status = void;
    lxb_css_syntax_at_rule_offset_t* at = void;
    lxb_css_syntax_rule_t* rule = void;

    lxb_css_parser_offset_set(parser, token);

    status = lxb_css_syntax_stack_expand(parser, 1);
    if (status != LXB_STATUS_OK) {
        parser.status = status;
        return null;
    }

    parser.rules.state = &lxb_css_state_success;

    rule = ++parser.rules;

    memset(rule, 0x00, lxb_css_syntax_rule_t.sizeof);

    rule.phase = &lxb_css_syntax_parser_at_rule;
    rule.state = at_rule.state;
    rule.state_back = state_back;
    rule.back = &lxb_css_syntax_parser_at_rule;
    rule.cbx.at_rule = at_rule;
    rule.context = ctx;
    rule.block_end = stop;

    if (token != null) {
        at = &rule.u.at_rule;

        at.name = token.offset;
        at.prelude = token.offset + (cast(lxb_css_syntax_token_base_t*) (token)).length;
    }

    parser.context = null;

    return rule;
}

lxb_css_syntax_rule_t* lxb_css_syntax_parser_qualified_push(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_parser_state_f state_back, const(lxb_css_syntax_cb_qualified_rule_t)* qualified, void* ctx, lxb_css_syntax_token_type_t stop)
{
    lxb_status_t status = void;
    lxb_css_syntax_rule_t* rule = void;

    lxb_css_parser_offset_set(parser, token);

    status = lxb_css_syntax_stack_expand(parser, 1);
    if (status != LXB_STATUS_OK) {
        parser.status = status;
        return null;
    }

    parser.rules.state = &lxb_css_state_success;

    rule = ++parser.rules;

    memset(rule, 0x00, lxb_css_syntax_rule_t.sizeof);

    rule.phase = &lxb_css_syntax_parser_qualified_rule;
    rule.state = qualified.state;
    rule.state_back = state_back;
    rule.back = &lxb_css_syntax_parser_qualified_rule;
    rule.cbx.qualified_rule = qualified;
    rule.context = ctx;
    rule.block_end = stop;

    if (token != null) {
        rule.u.qualified.prelude = token.offset;
    }

    parser.context = null;

    return rule;
}

lxb_css_syntax_rule_t* lxb_css_syntax_parser_declarations_push(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_parser_state_f state_back, const(lxb_css_syntax_cb_declarations_t)* declarations, void* ctx, lxb_css_syntax_token_type_t stop)
{
    lxb_status_t status = void;
    lxb_css_syntax_rule_t* rule = void;

    lxb_css_parser_offset_set(parser, token);

    status = lxb_css_syntax_stack_expand(parser, 1);
    if (status != LXB_STATUS_OK) {
        parser.status = status;
        return null;
    }

    parser.rules.state = &lxb_css_state_success;

    rule = ++parser.rules;

    memset(rule, 0x00, lxb_css_syntax_rule_t.sizeof);

    rule.phase = &lxb_css_syntax_parser_declarations;
    rule.state = declarations.cb.state;
    rule.state_back = state_back;
    rule.back = &lxb_css_syntax_parser_declarations;
    rule.cbx.declarations = declarations;
    rule.context = ctx;
    rule.block_end = stop;

    if (token != null) {
        rule.u.declarations.begin = token.offset;
    }

    parser.context = null;

    return rule;
}

lxb_css_syntax_rule_t* lxb_css_syntax_parser_components_push(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_parser_state_f state_back, const(lxb_css_syntax_cb_components_t)* comp, void* ctx, lxb_css_syntax_token_type_t stop)
{
    lxb_status_t status = void;
    lxb_css_syntax_rule_t* rule = void;

    lxb_css_parser_offset_set(parser, token);

    status = lxb_css_syntax_stack_expand(parser, 1);
    if (status != LXB_STATUS_OK) {
        parser.status = status;
        return null;
    }

    parser.rules.state = &lxb_css_state_success;

    rule = ++parser.rules;

    memset(rule, 0x00, lxb_css_syntax_rule_t.sizeof);

    rule.phase = &lxb_css_syntax_parser_components;
    rule.state = comp.state;
    rule.state_back = state_back;
    rule.back = &lxb_css_syntax_parser_components;
    rule.cbx.components = comp;
    rule.context = ctx;
    rule.block_end = stop;

    parser.context = null;

    return rule;
}

lxb_css_syntax_rule_t* lxb_css_syntax_parser_function_push(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_parser_state_f state_back, const(lxb_css_syntax_cb_function_t)* func, void* ctx)
{
    lxb_status_t status = void;
    lxb_css_syntax_rule_t* rule = void;

    if (token == null || token.type != LXB_CSS_SYNTAX_TOKEN_FUNCTION) {
        parser.status = LXB_STATUS_ERROR_WRONG_ARGS;
        return null;
    }

    if (parser.rules > parser.rules_begin) {
        rule = parser.rules;

        if (rule.deep != 0
            && parser.types_pos[-1] == LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS)
        {
            rule.deep--;
            parser.types_pos--;
        }
    }

    parser.rules.state = &lxb_css_state_success;

    lxb_css_parser_offset_set(parser, token);

    status = lxb_css_syntax_stack_expand(parser, 1);
    if (status != LXB_STATUS_OK) {
        parser.status = status;
        return null;
    }

    rule = ++parser.rules;

    memset(rule, 0x00, lxb_css_syntax_rule_t.sizeof);

    rule.phase = &lxb_css_syntax_parser_function;
    rule.state = func.state;
    rule.state_back = state_back;
    rule.back = &lxb_css_syntax_parser_function;
    rule.cbx.func = func;
    rule.context = ctx;

    parser.context = null;

    return rule;
}

lxb_css_syntax_rule_t* lxb_css_syntax_parser_block_push(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_parser_state_f state_back, const(lxb_css_syntax_cb_block_t)* block, void* ctx)
{
    lxb_status_t status = void;
    lxb_css_syntax_rule_t* rule = void;
    lxb_css_syntax_token_type_t block_end = void;

    if (token == null) {
        parser.status = LXB_STATUS_ERROR_WRONG_ARGS;
        return null;
    }

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            block_end = LXB_CSS_SYNTAX_TOKEN_RS_BRACKET;
            break;

        case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
        case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
            block_end = LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS;
            break;

        case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
            block_end = LXB_CSS_SYNTAX_TOKEN_RC_BRACKET;
            break;

        default:
            parser.status = LXB_STATUS_ERROR_WRONG_ARGS;
            return null;
    }

    if (parser.rules > parser.rules_begin) {
        rule = parser.rules;

        if (rule.deep != 0 && parser.types_pos[-1] == block_end) {
            rule.deep--;
            parser.types_pos--;
        }
    }

    parser.rules.state = &lxb_css_state_success;

    lxb_css_parser_offset_set(parser, token);

    status = lxb_css_syntax_stack_expand(parser, 1);
    if (status != LXB_STATUS_OK) {
        parser.status = status;
        return null;
    }

    rule = ++parser.rules;

    memset(rule, 0x00, lxb_css_syntax_rule_t.sizeof);

    rule.phase = &lxb_css_syntax_parser_block;
    rule.state = block.state;
    rule.state_back = state_back;
    rule.back = &lxb_css_syntax_parser_block;
    rule.cbx.block = block;
    rule.context = ctx;
    rule.block_end = block_end;

    parser.context = null;

    return rule;
}

lxb_css_syntax_rule_t* lxb_css_syntax_parser_pipe_push(lxb_css_parser_t* parser, lxb_css_parser_state_f state_back, const(lxb_css_syntax_cb_pipe_t)* pipe, void* ctx, lxb_css_syntax_token_type_t stop)
{
    lxb_status_t status = void;
    lxb_css_syntax_rule_t* rule = void;

    status = lxb_css_syntax_stack_expand(parser, 1);
    if (status != LXB_STATUS_OK) {
        parser.status = status;
        return null;
    }

    parser.rules.state = &lxb_css_state_success;

    rule = ++parser.rules;

    memset(rule, 0x00, lxb_css_syntax_rule_t.sizeof);

    rule.phase = &lxb_css_syntax_parser_pipe;
    rule.state = pipe.state;
    rule.state_back = state_back;
    rule.back = &lxb_css_syntax_parser_pipe;
    rule.cbx.pipe = pipe;
    rule.context = ctx;
    rule.block_end = stop;

    parser.context = null;

    return rule;
}

lxb_css_syntax_rule_t* lxb_css_syntax_parser_stack_pop(lxb_css_parser_t* parser)
{
    return parser.rules--;
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_list_rules(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    if (rule.offset > token.offset) {
        return token;
    }

begin:

    rule.offset = token.offset + (cast(lxb_css_syntax_token_base_t*) (token)).length;

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            lxb_css_syntax_token_consume(parser.tkz);

            token = lxb_css_syntax_token(parser.tkz);
            if (token == null) {
                return lxb_css_syntax_parser_failed(parser,
                                                    parser.tkz.status);
            }

            goto begin;

        case LXB_CSS_SYNTAX_TOKEN_AT_KEYWORD:
            rule.phase = &lxb_css_syntax_parser_list_rules_at;
            break;

        case LXB_CSS_SYNTAX_TOKEN__EOF:
            goto done;

        case LXB_CSS_SYNTAX_TOKEN_CDC:
        case LXB_CSS_SYNTAX_TOKEN_CDO:
            if (rule.top_level) {
                lxb_css_syntax_token_consume(parser.tkz);

                token = lxb_css_syntax_token(parser.tkz);
                if (token == null) {
                    return lxb_css_syntax_parser_failed(parser,
                                                        parser.tkz.status);
                }

                goto begin;
            }

            /* fall through */

            goto default; /* C fallthrough */
        default:
            if (rule.block_end == token.type && rule.deep == 0) {
                goto done;
            }

            rule.phase = &lxb_css_syntax_parser_list_rules_qualified;
            break;
    }

    return token;

done:

    rule.phase = &lxb_css_syntax_parser_end;
    rule.skip_consume = true;

    rule.u.list_rules.end = token.offset;

    return &lxb_css_syntax_token_terminated;
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_list_rules_at(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    if (rule.state != &lxb_css_state_success) {
        return token;
    }

    rule = lxb_css_syntax_parser_at_rule_push(parser, token,
                                              &lxb_css_syntax_parser_list_rules_back,
                                              rule.cbx.list_rules.at_rule,
                                              rule.context, rule.block_end);
    if (rule == null) {
        return null;
    }

    parser.fake_null = true;

    return null;
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_list_rules_qualified(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    if (rule.state != &lxb_css_state_success) {
        return token;
    }

    rule = lxb_css_syntax_parser_qualified_push(parser, token,
                                                &lxb_css_syntax_parser_list_rules_back,
                                                rule.cbx.list_rules.qualified_rule,
                                                rule.context, rule.block_end);
    if (rule == null) {
        return null;
    }

    parser.fake_null = true;

    return null;
}

private bool lxb_css_syntax_parser_list_rules_back(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_syntax_rule_t* rule = void;

    if (token.type == LXB_CSS_SYNTAX_TOKEN__END) {
        return lxb_css_parser_success(parser);
    }

    rule = parser.rules;
    rule.state = rule.cbx.list_rules.next;

    return false;
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_at_rule(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    lxb_status_t status = void;

    if (rule.offset > token.offset) {
        return token;
    }

    rule.offset = token.offset + (cast(lxb_css_syntax_token_base_t*) (token)).length;

    if (rule.block_end == token.type && rule.deep == 0) {
        rule.skip_ending = true;
        goto done;
    }

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RS_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
        case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS);
            break;

        case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
            if (rule.deep == 0) {
                rule.phase = &lxb_css_syntax_parser_start_block;

                rule.u.at_rule.prelude_end = token.offset;
                rule.u.at_rule.block = token.offset
                    + (cast(lxb_css_syntax_token_base_t*) (token)).length;

                rule.skip_consume = true;

                parser.block = rule.cbx.cb.block;

                lxb_css_syntax_token_consume(parser.tkz);

                token = lxb_css_syntax_token(parser.tkz);
                if (token == null) {
                    return lxb_css_syntax_parser_failed(parser,
                                                        parser.tkz.status);
                }

                token = &lxb_css_syntax_token_terminated;
            }

            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RC_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_RC_BRACKET:
            if (rule.deep != 0 && parser.types_pos[-1] == token.type) {
                if (rule.deep == 1) {
                    goto done;
                }

                parser.types_pos--;
                rule.deep--;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN_RS_BRACKET:
        case LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS:
            if (rule.deep != 0 && parser.types_pos[-1] == token.type) {
                parser.types_pos--;
                rule.deep--;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN_SEMICOLON:
            if (rule.deep == 0) {
                goto done;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN__EOF:
            goto done;

        default:
            return token;
    }

    if (status != LXB_STATUS_OK) {
        return lxb_css_syntax_parser_failed(parser, status);
    }

    rule.deep++;

    return token;

done:

    rule.phase = &lxb_css_syntax_parser_end;
    rule.skip_consume = true;

    if (rule.u.at_rule.prelude_end != 0) {
        rule.u.at_rule.block_end = token.offset;
    }
    else {
        rule.u.at_rule.prelude_end = token.offset;
    }

    return &lxb_css_syntax_token_terminated;
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_qualified_rule(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    lxb_status_t status = void;

    /* It is necessary to avoid re-entry of the token into the phase. */

    if (rule.offset > token.offset) {
        return token;
    }

    rule.offset = token.offset + (cast(lxb_css_syntax_token_base_t*) (token)).length;

    if (rule.block_end == token.type && rule.deep == 0) {
        rule.skip_ending = true;
        goto done;
    }

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RS_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
        case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS);
            break;

        case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
            if (rule.deep == 0) {
                rule.phase = &lxb_css_syntax_parser_start_block;

                rule.u.qualified.prelude_end = token.offset;
                rule.u.qualified.block = token.offset
                                    + (cast(lxb_css_syntax_token_base_t*) (token)).length;

                rule.skip_consume = true;

                parser.block = rule.cbx.cb.block;

                lxb_css_syntax_token_consume(parser.tkz);

                token = lxb_css_syntax_token(parser.tkz);
                if (token == null) {
                    return lxb_css_syntax_parser_failed(parser,
                                                        parser.tkz.status);
                }

                token = &lxb_css_syntax_token_terminated;
            }

            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RC_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_RC_BRACKET:
            if (rule.deep != 0 && parser.types_pos[-1] == token.type) {
                if (rule.deep == 1) {
                    goto done;
                }

                parser.types_pos--;
                rule.deep--;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN_RS_BRACKET:
        case LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS:
            if (rule.deep != 0 && parser.types_pos[-1] == token.type) {
                parser.types_pos--;
                rule.deep--;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN__EOF:
            goto done;

        default:
            return token;
    }

    if (status != LXB_STATUS_OK) {
        return lxb_css_syntax_parser_failed(parser, status);
    }

    rule.deep++;

    return token;

done:

    rule.phase = &lxb_css_syntax_parser_end;
    rule.skip_consume = true;

    if (rule.u.qualified.block != 0) {
        rule.u.qualified.block_end = token.offset;
    }
    else {
        rule.u.qualified.prelude_end = token.offset;
    }

    return &lxb_css_syntax_token_terminated;
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_declarations(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    if (rule.offset > token.offset) {
        return token;
    }

begin:

    rule.offset = token.offset + (cast(lxb_css_syntax_token_base_t*) (token)).length;

    if (rule.block_end == token.type && rule.deep == 0) {
        rule.skip_ending = true;
        goto done;
    }

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_SEMICOLON:
        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            lxb_css_syntax_token_consume(parser.tkz);

            token = lxb_css_syntax_token(parser.tkz);
            if (token == null) {
                return lxb_css_syntax_parser_failed(parser,
                                                    parser.tkz.status);
            }

            goto begin;

        case LXB_CSS_SYNTAX_TOKEN_IDENT:
            rule.u.declarations.name_begin = token.offset;

            if (lxb_css_syntax_tokenizer_lookup_colon(parser.tkz)) {
                rule.phase = &lxb_css_syntax_parser_declarations_name;
                parser.block = rule.cbx.cb.block;

                return token;
            }

            rule.state = rule.cbx.cb.failed;
            rule.phase = &lxb_css_syntax_parser_declarations_drop;
            rule.failed = true;

            break;

        case LXB_CSS_SYNTAX_TOKEN_AT_KEYWORD:
            rule.u.declarations.name_begin = 0;

            rule = lxb_css_syntax_parser_at_rule_push(parser, token,
                             &lxb_css_syntax_parser_declarations_back,
                             rule.cbx.declarations.at_rule, rule.context,
                             rule.block_end);
            if (rule != null) {
                parser.fake_null = true;
            }

            return null;

        case LXB_CSS_SYNTAX_TOKEN__EOF:
            goto done;

        default:
            rule.state = rule.cbx.cb.failed;
            rule.phase = &lxb_css_syntax_parser_declarations_drop;
            rule.failed = true;

            rule.u.declarations.name_begin = token.offset;
            break;
    }

    parser.fake_null = true;

    return null;

done:

    rule.phase = &lxb_css_syntax_parser_end;
    rule.state = &lxb_css_state_success;
    rule.skip_consume = true;

    rule.u.declarations.name_begin = 0;
    rule.u.declarations.end = token.offset;

    parser.fake_null = true;

    return null;
}

private bool lxb_css_syntax_parser_declarations_back(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, void* ctx)
{
    lxb_css_syntax_rule_t* rules = parser.rules;

    rules.state = rules.cbx.declarations.cb.state;

    return rules.state(parser, token, ctx);
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_declarations_name(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    if (rule.offset > token.offset) {
        return token;
    }

    if (rule.state != &lxb_css_state_success) {
        rule.skip_consume = true;

        return &lxb_css_syntax_token_terminated;
    }

    rule.skip_consume = false;

    /* 1. */

    if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
        lxb_css_syntax_token_consume(parser.tkz);

        token = lxb_css_syntax_token(parser.tkz);
        if (token == null) {
            return lxb_css_syntax_parser_failed(parser, parser.tkz.status);
        }
    }

    /* 2. */

    if (token.type != LXB_CSS_SYNTAX_TOKEN_COLON) {
        /* Parse error. */

        /*
         * It can't be.
         *
         * Before entering the lxb_css_syntax_parser_declarations_name()
         * function, data validation takes place. In fact, these checks are not
         * needed here.
         */

        /*
         * But it's good for validation, if we come here it means we're
         * doing badly.
         */

        return null;
    }

    rule.u.declarations.name_end = token.offset;

    lxb_css_syntax_token_consume(parser.tkz);

    token = lxb_css_syntax_token(parser.tkz);
    if (token == null) {
        return lxb_css_syntax_parser_failed(parser, parser.tkz.status);
    }

    /* 3. */

    if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
        lxb_css_syntax_token_consume(parser.tkz);

        token = lxb_css_syntax_token(parser.tkz);
        if (token == null) {
            return lxb_css_syntax_parser_failed(parser, parser.tkz.status);
        }
    }

    rule.u.declarations.value_begin = token.offset;

    /* 4. */

    rule.phase = &lxb_css_syntax_parser_declarations_value;
    rule.state = parser.block;

    return lxb_css_syntax_parser_declarations_value(parser, token, rule);
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_declarations_value(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    bool imp = void;
    uintptr_t before_important = void;
    lxb_status_t status = void;

    if (rule.offset > token.offset) {
        return token;
    }

again:

    rule.offset = token.offset + (cast(lxb_css_syntax_token_base_t*) (token)).length;

    if (rule.block_end == token.type && rule.deep == 0) {
        rule.skip_ending = true;
        goto done;
    }

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_WHITESPACE:
            if (rule.deep != 0) {
                return token;
            }

            imp = lxb_css_syntax_tokenizer_lookup_declaration_ws_end(parser.tkz,
            rule.block_end,
            (rule.block_end == LXB_CSS_SYNTAX_TOKEN_RC_BRACKET) ? 0x7D : 0x00);

            if (!imp) {
                return token;
            }

            before_important = token.offset;

            lxb_css_syntax_token_consume(parser.tkz);

            token = lxb_css_syntax_token(parser.tkz);
            if (token == null) {
                return lxb_css_syntax_parser_failed(parser, parser.tkz.status);
            }

            /* Have !important? */

            if (token.type == LXB_CSS_SYNTAX_TOKEN_DELIM) {
                rule.important = true;
                rule.u.declarations.before_important = before_important;

                lxb_css_syntax_token_consume(parser.tkz);

                /* Skip important */

                token = lxb_css_syntax_token(parser.tkz);
                if (token == null) {
                    return lxb_css_syntax_parser_failed(parser, parser.tkz.status);
                }
                lxb_css_syntax_token_consume(parser.tkz);

                token = lxb_css_syntax_token(parser.tkz);
                if (token == null) {
                    return lxb_css_syntax_parser_failed(parser, parser.tkz.status);
                }

                if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
                    lxb_css_syntax_token_consume(parser.tkz);

                    token = lxb_css_syntax_token(parser.tkz);
                    if (token == null) {
                        return lxb_css_syntax_parser_failed(parser,
                                                            parser.tkz.status);
                    }
                }
            }

            goto again;

        case LXB_CSS_SYNTAX_TOKEN_SEMICOLON:
            if (rule.deep == 0) {
                rule.phase = &lxb_css_syntax_parser_declarations_next;

                rule.u.declarations.value_end = token.offset;

                lxb_css_syntax_token_consume(parser.tkz);

                token = lxb_css_syntax_token(parser.tkz);
                if (token == null) {
                    return lxb_css_syntax_parser_failed(parser,
                                                        parser.tkz.status);
                }

                return &lxb_css_syntax_token_terminated;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN_DELIM:
            if ((cast(lxb_css_syntax_token_delim_t*) (token)).character != '!') {
                return token;
            }

            imp = lxb_css_syntax_tokenizer_lookup_important(parser.tkz,
            rule.block_end,
            (rule.block_end == LXB_CSS_SYNTAX_TOKEN_RC_BRACKET) ? 0x7D : 0x00);

            if (!imp) {
                return token;
            }

            rule.u.declarations.before_important = token.offset;
            rule.important = true;

            lxb_css_syntax_token_consume(parser.tkz);

            token = lxb_css_syntax_token(parser.tkz);
            if (token == null) {
                return lxb_css_syntax_parser_failed(parser, parser.tkz.status);
            }

            lxb_css_syntax_token_consume(parser.tkz);

            token = lxb_css_syntax_token(parser.tkz);
            if (token == null) {
                return lxb_css_syntax_parser_failed(parser, parser.tkz.status);
            }

            if (token.type == LXB_CSS_SYNTAX_TOKEN_WHITESPACE) {
                lxb_css_syntax_token_consume(parser.tkz);

                token = lxb_css_syntax_token(parser.tkz);
                if (token == null) {
                    return lxb_css_syntax_parser_failed(parser,
                                                        parser.tkz.status);
                }
            }

            goto again;

        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RS_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
        case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS);
            break;

        case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RC_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_RC_BRACKET:
        case LXB_CSS_SYNTAX_TOKEN_RS_BRACKET:
        case LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS:
            if (rule.deep != 0 && parser.types_pos[-1] == token.type) {
                parser.types_pos--;
                rule.deep--;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN__EOF:
            goto done;

        default:
            return token;
    }

    if (status != LXB_STATUS_OK) {
        return lxb_css_syntax_parser_failed(parser, status);
    }

    rule.deep++;

    return token;

done:

    rule.phase = &lxb_css_syntax_parser_declarations_end;
    rule.skip_consume = true;

    rule.u.declarations.value_end = token.offset;
    rule.u.declarations.end = token.offset;

    return &lxb_css_syntax_token_terminated;
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_declarations_next(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    lxb_status_t status = void;
    lxb_css_syntax_declarations_offset_t* decl = void;

    if (rule.state != &lxb_css_state_success) {
        rule.skip_consume = true;

        return &lxb_css_syntax_token_terminated;
    }

    status = rule.cbx.declarations.declaration_end(parser, rule.context,
                                                     rule.important,
                                                     rule.failed);
    if (status != LXB_STATUS_OK) {
        return lxb_css_syntax_parser_failed(parser, status);
    }

    rule.phase = &lxb_css_syntax_parser_declarations;
    rule.state = rule.cbx.cb.state;

    rule.skip_consume = false;
    rule.important = false;
    rule.failed = false;

    decl = &rule.u.declarations;

    decl.name_begin = 0;
    decl.name_end = 0;
    decl.value_begin = 0;
    decl.before_important = 0;
    decl.value_end = 0;

    return lxb_css_syntax_parser_declarations(parser, token, rule);
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_declarations_drop(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    lxb_status_t status = void;

    /* It is necessary to avoid re-entry of the token into the phase. */

    if (rule.offset > token.offset) {
        return token;
    }

    rule.offset = token.offset + (cast(lxb_css_syntax_token_base_t*) (token)).length;

    if (rule.block_end == token.type && rule.deep == 0) {
        rule.skip_ending = true;
        goto done;
    }

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_SEMICOLON:
            if (rule.deep == 0) {
                rule.phase = &lxb_css_syntax_parser_declarations_next;

                rule.u.declarations.name_end = token.offset;

                lxb_css_syntax_token_consume(parser.tkz);

                token = lxb_css_syntax_token(parser.tkz);
                if (token == null) {
                    return lxb_css_syntax_parser_failed(parser,
                                                        parser.tkz.status);
                }

                rule.skip_consume = true;

                return &lxb_css_syntax_token_terminated;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RS_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
        case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS);
            break;

        case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RC_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_RC_BRACKET:
        case LXB_CSS_SYNTAX_TOKEN_RS_BRACKET:
        case LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS:
            if (rule.deep != 0 && parser.types_pos[-1] == token.type) {
                parser.types_pos--;
                rule.deep--;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN__EOF:
            goto done;

        default:
            return token;
    }

    if (status != LXB_STATUS_OK) {
        return lxb_css_syntax_parser_failed(parser, status);
    }

    rule.deep++;

    return token;

done:

    rule.phase = &lxb_css_syntax_parser_declarations_end;
    rule.skip_consume = true;

    rule.u.declarations.name_end = token.offset;
    rule.u.declarations.end = token.offset;

    return &lxb_css_syntax_token_terminated;
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_declarations_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    lxb_status_t status = void;
    lxb_css_syntax_rule_t* rules = void;

    if (rule.state != &lxb_css_state_success) {
        rule.skip_consume = true;

        return &lxb_css_syntax_token_terminated;
    }

    status = rule.cbx.declarations.declaration_end(parser, rule.context,
                                                     rule.important,
                                                     rule.failed);
    if (status != LXB_STATUS_OK) {
        return lxb_css_syntax_parser_failed(parser, status);
    }

    /* This code will be called exclusively from the lxb_css_parser_run(...). */

    status = rule.cbx.cb.end(parser, token, rule.context, false);
    if (status != LXB_STATUS_OK) {
        return lxb_css_syntax_parser_failed(parser, status);
    }

    if (!rule.skip_ending) {
        lxb_css_syntax_token_consume(parser.tkz);

        token = lxb_css_syntax_token(parser.tkz);
        if (token == null) {
            return lxb_css_syntax_parser_failed(parser,
                                                parser.tkz.status);
        }
    }

    cast(void) lxb_css_syntax_parser_stack_pop(parser);

    rules = parser.rules;

    if (parser.rules <= parser.rules_begin) {
        rules.state = &lxb_css_state_stop;
        return token;
    }

    rules.phase = rules.back;

    return rules.phase(parser, token, rules);
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_components(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    lxb_status_t status = void;

    if (rule.offset > token.offset) {
        return token;
    }

    rule.offset = token.offset + (cast(lxb_css_syntax_token_base_t*) (token)).length;

    if (rule.block_end == token.type && rule.deep == 0) {
        rule.skip_ending = true;
        goto done;
    }

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RS_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
        case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS);
            break;

        case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RC_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_RC_BRACKET:
        case LXB_CSS_SYNTAX_TOKEN_RS_BRACKET:
        case LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS:
            if (rule.deep != 0 && parser.types_pos[-1] == token.type) {
                parser.types_pos--;
                rule.deep--;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN__EOF:
            goto done;

        default:
            return token;
    }

    if (status != LXB_STATUS_OK) {
        return lxb_css_syntax_parser_failed(parser, status);
    }

    rule.deep++;

    return token;

done:

    rule.phase = &lxb_css_syntax_parser_end;
    rule.skip_consume = true;

    return &lxb_css_syntax_token_terminated;
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_function(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    lxb_status_t status = void;

    if (rule.offset > token.offset) {
        return token;
    }

    rule.offset = token.offset + (cast(lxb_css_syntax_token_base_t*) (token)).length;

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RS_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
        case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS);
            break;

        case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RC_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS:
            if (rule.deep != 0) {
                if (parser.types_pos[-1] == token.type) {
                    parser.types_pos--;
                    rule.deep--;
                }
            }
            else {
                goto done;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN_RC_BRACKET:
        case LXB_CSS_SYNTAX_TOKEN_RS_BRACKET:
            if (rule.deep != 0 && parser.types_pos[-1] == token.type) {
                parser.types_pos--;
                rule.deep--;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN__EOF:
            goto done;

        default:
            return token;
    }

    if (status != LXB_STATUS_OK) {
        return lxb_css_syntax_parser_failed(parser, status);
    }

    rule.deep++;

    return token;

done:

    rule.phase = &lxb_css_syntax_parser_end;
    rule.skip_consume = true;

    return &lxb_css_syntax_token_terminated;
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_block(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    lxb_status_t status = void;

    if (rule.offset > token.offset) {
        return token;
    }

    rule.offset = token.offset + (cast(lxb_css_syntax_token_base_t*) (token)).length;

    if (rule.block_end == token.type && rule.deep == 0) {
        goto done;
    }

    switch (token.type) {
        case LXB_CSS_SYNTAX_TOKEN_LS_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RS_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_FUNCTION:
        case LXB_CSS_SYNTAX_TOKEN_L_PARENTHESIS:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS);
            break;

        case LXB_CSS_SYNTAX_TOKEN_LC_BRACKET:
            status = lxb_css_parser_types_push(parser,
                                               LXB_CSS_SYNTAX_TOKEN_RC_BRACKET);
            break;

        case LXB_CSS_SYNTAX_TOKEN_R_PARENTHESIS:
        case LXB_CSS_SYNTAX_TOKEN_RS_BRACKET:
        case LXB_CSS_SYNTAX_TOKEN_RC_BRACKET:
            if (rule.deep != 0 && parser.types_pos[-1] == token.type) {
                parser.types_pos--;
                rule.deep--;
            }

            return token;

        case LXB_CSS_SYNTAX_TOKEN__EOF:
            goto done;

        default:
            return token;
    }

    if (status != LXB_STATUS_OK) {
        return lxb_css_syntax_parser_failed(parser, status);
    }

    rule.deep++;

    return token;

done:

    rule.phase = &lxb_css_syntax_parser_end;
    rule.skip_consume = true;

    return &lxb_css_syntax_token_terminated;
}

private const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_pipe(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    if ((rule.block_end == token.type && rule.deep == 0)
        || token.type == LXB_CSS_SYNTAX_TOKEN__EOF)
    {
        rule.phase = &lxb_css_syntax_parser_end;
        rule.skip_consume = true;

        return &lxb_css_syntax_token_terminated;
    }

    return token;
}

const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_start_block(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    if (rule.state != &lxb_css_state_success) {
        rule.skip_consume = true;

        return &lxb_css_syntax_token_terminated;
    }

    /* This code will be called exclusively from the lxb_css_parser_run(...). */

    rule.skip_consume = false;

    rule.phase = rule.back;
    rule.state = parser.block;

    return rule.back(parser, token, rule);
}

const(lxb_css_syntax_token_t)* lxb_css_syntax_parser_end(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token, lxb_css_syntax_rule_t* rule)
{
    lxb_status_t status = void;
    lxb_css_syntax_rule_t* rules = void;
    lxb_css_syntax_cb_base_t* base = void;

    if (rule.state != &lxb_css_state_success) {
        rule.skip_consume = true;

        return &lxb_css_syntax_token_terminated;
    }

    /* This code will be called exclusively from the lxb_css_parser_run(...). */

    base = cast(lxb_css_syntax_cb_base_t*) rule.cbx.user;

    status = base.end(parser, token, rule.context, rule.failed);
    if (status != LXB_STATUS_OK) {
        return lxb_css_syntax_parser_failed(parser, status);
    }

    if (!rule.skip_ending) {
        lxb_css_syntax_token_consume(parser.tkz);

        token = lxb_css_syntax_token(parser.tkz);
        if (token == null) {
            return lxb_css_syntax_parser_failed(parser,
                                                parser.tkz.status);
        }
    }

    cast(void) lxb_css_syntax_parser_stack_pop(parser);

    rules = parser.rules;

    if (parser.rules <= parser.rules_begin) {
        rules.state = &lxb_css_state_stop;
        return token;
    }

    rules.phase = rules.back;
    rules.state = rule.state_back;

    return rules.phase(parser, token, rules);
}
