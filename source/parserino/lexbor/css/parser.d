module parserino.lexbor.css.parser;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.css.log;
public import parserino.lexbor.css.syntax.parser;
public import parserino.lexbor.css.selectors.selectors;
import parserino.lexbor.css.state;
import parserino.lexbor.css.syntax.syntax;

extern(C) @nogc nothrow:
__gshared:

// ---- parser.h ----
/*
 * Copyright (C) 2021-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum {
    LXB_CSS_SYNTAX_PARSER_ERROR_UNDEF = 0x0000,
    /* eof-in-at-rule */
    LXB_CSS_SYNTAX_PARSER_ERROR_EOINATRU,
    /* eof-in-qualified-rule */
    LXB_CSS_SYNTAX_PARSER_ERROR_EOINQURU,
    /* eof-in-simple-block */
    LXB_CSS_SYNTAX_PARSER_ERROR_EOINSIBL,
    /* eof-in-function */
    LXB_CSS_SYNTAX_PARSER_ERROR_EOINFU,
    /* eof-before-parse-rule */
    LXB_CSS_SYNTAX_PARSER_ERROR_EOBEPARU,
    /* unexpected-token-after-parse-rule */
    LXB_CSS_SYNTAX_PARSER_ERROR_UNTOAFPARU,
    /* eof-before-parse-component-value */
    LXB_CSS_SYNTAX_PARSER_ERROR_EOBEPACOVA,
    /* unexpected-token-after-parse-component-value */
    LXB_CSS_SYNTAX_PARSER_ERROR_UNTOAFPACOVA,
    /* unexpected-token-in-declaration */
    LXB_CSS_SYNTAX_PARSER_ERROR_UNTOINDE,
}

enum lxb_css_parser_stage_t {
    LXB_CSS_PARSER_CLEAN = 0,
    LXB_CSS_PARSER_RUN,
    LXB_CSS_PARSER_STOP,
    LXB_CSS_PARSER_END
}
alias LXB_CSS_PARSER_CLEAN = lxb_css_parser_stage_t.LXB_CSS_PARSER_CLEAN;
alias LXB_CSS_PARSER_RUN = lxb_css_parser_stage_t.LXB_CSS_PARSER_RUN;
alias LXB_CSS_PARSER_STOP = lxb_css_parser_stage_t.LXB_CSS_PARSER_STOP;
alias LXB_CSS_PARSER_END = lxb_css_parser_stage_t.LXB_CSS_PARSER_END;


struct lxb_css_parser {
    /* Modules */
    lxb_css_syntax_tokenizer_t* tkz;
    lxb_css_selectors_t* selectors;

    /* Memory for all structures. */
    lxb_css_memory_t* memory;

    /* Syntax parse rules. */
    lxb_css_syntax_rule_t* rules_begin;
    lxb_css_syntax_rule_t* rules_end;
    lxb_css_syntax_rule_t* rules;

    /* States */
    lxb_css_parser_state_t* states_begin;
    lxb_css_parser_state_t* states_end;
    lxb_css_parser_state_t* states;

    /* Types */
    lxb_css_syntax_token_type_t* types_begin;
    lxb_css_syntax_token_type_t* types_end;
    lxb_css_syntax_token_type_t* types_pos;

    lxb_css_syntax_token_t token_end;

    lexbor_str_t str;
    size_t str_size;

    lxb_css_log_t* log;

    lxb_css_parser_stage_t stage;

    lxb_css_syntax_declaration_offset_t offset;

    bool loop;
    bool fake_null;
    bool my_tkz;

    lxb_status_t status;
}

struct lxb_css_parser_state_ {
    lxb_css_parser_state_f state;
    void* context;
    bool root;
}

struct lxb_css_parser_error {
    lexbor_str_t message;
}

/*
 * Create a new CSS parser object.
 *
 * @return lxb_css_parser_t* if successful, otherwise NULL.
 */

/*
 * Initialize the CSS parser with a tokenizer.
 *
 * @param[in] parser Required. The CSS parser object.
 *                   If NULL, the function returns
 *                   LXB_STATUS_ERROR_OBJECT_IS_NULL.
 * @param[in] tkz    Optional. The tokenizer object.
 *                   If NULL, a new tokenizer will be created and used.
 *                   (In that case the parser manages the tokenizer lifetime.)
 *
 * @return LXB_STATUS_OK if successful, otherwise an error status value.
 */

/*
 * Initialize the Selectors module in the parser.
 *
 * Note:
 *   Be sure to destroy the Selectors object you created yourself using
 *   the lxb_css_parser_selectors_destroy() function.
 *
 * @param[in] parser Required. The CSS parser object.
 *
 * @return LXB_STATUS_OK if successful, otherwise an error status value.
 */

/*
 * Destroy the selectors module in the parser.
 *
 * @param[in] parser Required. The CSS parser object.
 */

/*
 * Clean the parser object.
 *
 * This resets internal parser state, but keeps allocated memory so the parser
 * can be reused.
 *
 * @param[in] parser Required. The CSS parser object.
 */

/*
 * Erase the parser object.
 *
 * This resets internal parser state and releases internal allocations owned by
 * the parser so it can be re-initialized.
 *
 * @param[in] parser Required. The CSS parser object.
 */

/*
 * Destroy the parser object.
 *
 * @param[in] parser        Optional. The CSS parser object.
 *                          If NULL, the function returns NULL.
 * @param[in] self_destroy  Optional flag.
 *                          If true, also frees the parser object itself.
 *                          If false, only inner resources are freed and the
 *                          parser object remains valid.
 *
 * @return parser if self_destroy is false, otherwise NULL.
 */

/*
 * Stop the parser main loop.
 *
 * This is a helper for state callbacks that want to immediately stop parsing
 * without marking the current rule as failed.
 *
 * @param[in] parser Required. The CSS parser object.
 *
 * @return true (convenience return value, useful for state callbacks).
 */

/*
 * Fail the parser with a status and stop the main loop.
 *
 * This is used for hard errors (OOM, overflow, etc.). It sets parser->status
 * and stops the parser loop.
 *
 * @param[in] parser  Required. The CSS parser object.
 * @param[in] status  Required. Status code describing the failure.
 *
 * @return true (convenience return value, useful for state callbacks).
 */

/*
 * Mark the current token as unexpected.
 *
 * This is a specialized helper for the common "unexpected data" parse error.
 * It sets parser->status to LXB_STATUS_ERROR_UNEXPECTED_DATA and marks the
 * current rule as failed.
 *
 * @param[in] parser Required. The CSS parser object.
 *
 * @return true (convenience return value, useful for state callbacks).
 */

/*
 * Mark parsing of the current grammar/rule as successful.
 *
 * Why this function exists:
 * - Most callbacks in the CSS parser work as a state machine: each callback
 *   receives the current token and returns bool to decide what to do next.
 * - "Success" is not just a bool. The parser must switch to a special
 *   lxb_css_state_success state to properly handle trailing whitespace and
 *   the end-of-input token.
 * - If you don't consume all tokens up to LXB_CSS_SYNTAX_TOKEN__END in the
 *   current rule and call this function, the parser will switch to "failed"
 *   mode. This is the same as calling the lxb_css_parser_failed() function.
 *   The exception is the LXB_CSS_SYNTAX_TOKEN_WHITESPACE token. If you are
 *   sure that only this token remains, the parser will simply exclude it.
 *
 * What it does:
 * - Sets the current rule state to lxb_css_state_success.
 * - Does not stop the parser loop by itself.
 *
 * Typical usage:
 * - In css/property/state.c, after you have parsed and consumed the last token
 *   of a property value, you do:
 *   return lxb_css_parser_success(parser);
 * - That transfers control to lxb_css_state_success, which consumes any
 *   whitespace and completes on LXB_CSS_SYNTAX_TOKEN__END.
 *
 * @param[in] parser Required. The CSS parser object.
 *
 * @return true (convenience return value, useful for state callbacks).
 */

/*
 * Mark parsing of the current grammar/rule as failed.
 *
 * Why this function exists:
 * - In the state machine, failure is also not "just return false". The parser
 *   needs to switch to a rule-specific recovery state so it can safely skip
 *   input until it is allowed to stop (usually until end-of-input or a known
 *   synchronisation point).
 *
 * What it does:
 * - Sets the current rule state to the rule-specific "failed" handler
 *   (rule->cbx.cb->failed).
 * - Sets rule->failed = true.
 * - Does not directly change parser->status. Use lxb_css_parser_fail() or
 *   lxb_css_parser_unexpected() when you need a concrete status code.
 *
 * Typical usage:
 * - In css/property/state.c, if a token doesn't match the expected grammar,
 *   you do:
 *   return lxb_css_parser_failed(parser);
 * - That switches the parser into the failed handler. For properties this lets
 *   the parser consume/skip tokens until it reaches LXB_CSS_SYNTAX_TOKEN__END.
 *   (See lxb_css_state_failed(): it consumes tokens until end, then calls
 *   lxb_css_parser_success() to finish.)
 *
 * Important!
 *   The user sets the callback to "failed" and must decide what to do in this
 *   situation. If the user does not consume all tokens before
 *   LXB_CSS_SYNTAX_TOKEN__END, there will be an infinite loop.
 *
 * @param[in] parser Required. The CSS parser object.
 *
 * @return true (convenience return value, useful for state callbacks).
 */








/*
 * Push a new state to the parser.
 *
 * @param[in] parser   Required. The CSS parser object.
 * @param[in] state    Required. State callback to execute.
 * @param[in] context  Optional user pointer associated with this state.
 *                     Stored as-is; the parser doesn't own it.
 * @param[in] stop     If true, the pushed state is marked as a "stop point".
 *                     This is used by the parser to stop/return control when
 *                     this state is reached.
 *
 * @return lxb_css_parser_state_t* if successful, otherwise NULL.
 */

/*
 * Go to the next state in the parser.
 *
 * @param[in] parser  Required. The CSS parser object.
 * @param[in] next    Required. Next state callback.
 * @param[in] back    Required. State callback to return to.
 * @param[in] ctx     Optional user pointer for the next state.
 *                    Stored as-is; the parser doesn't own it.
 * @param[in] root    If true, marks this state as a "root" state. Root states
 *                    are used by helper functions (e.g. to rewind to root).
 *
 * @return lxb_css_parser_state_t* if successful, otherwise NULL.
 */

/*
 * Push a token type to the parser.
 *
 * @param[in] parser Required. The CSS parser object.
 * @param[in] type   Required. Token type to push.
 *
 * @return LXB_STATUS_OK if successful, otherwise an error status value.
 */

/*
 * Inline functions
 */
 lxb_status_t lxb_css_parser_status(lxb_css_parser_t* parser)
{
    return parser.status;
}

 lxb_css_memory_t* lxb_css_parser_memory(lxb_css_parser_t* parser)
{
    return parser.memory;
}

 void lxb_css_parser_memory_set(lxb_css_parser_t* parser, lxb_css_memory_t* memory)
{
    parser.memory = memory;
}

 lxb_css_selectors_t* lxb_css_parser_selectors(lxb_css_parser_t* parser)
{
    return parser.selectors;
}

 void lxb_css_parser_selectors_set(lxb_css_parser_t* parser, lxb_css_selectors_t* selectors)
{
    parser.selectors = selectors;
}

 bool lxb_css_parser_is_running(lxb_css_parser_t* parser)
{
    return parser.stage == LXB_CSS_PARSER_RUN;
}

 bool lxb_css_parser_status_is_unexpected_data(lxb_css_parser_t* parser)
{
    return parser.status == LXB_STATUS_ERROR_UNEXPECTED_DATA;
}

 void lxb_css_parser_failed_set(lxb_css_parser_t* parser, bool is_)
{
    parser.rules.failed = is_;
}

 void lxb_css_parser_failed_set_by_id(lxb_css_parser_t* parser, int idx, bool is_)
{
    lxb_css_syntax_rule_t* rules = parser.rules + idx;

    if (rules > parser.rules_begin && rules < parser.rules_end) {
        rules.failed = is_;
    }
}

 bool lxb_css_parser_is_failed(lxb_css_parser_t* parser)
{
    return parser.rules.failed;
}

 void lxb_css_parser_set_ok(lxb_css_parser_t* parser)
{
    parser.rules.failed = false;
    parser.status = LXB_STATUS_OK;
}

 const(lxb_char_t)* lxb_css_parser_buffer(lxb_css_parser_t* parser, size_t* length)
{
    if (length != null) {
        *length = parser.tkz.in_end - parser.tkz.in_begin;
    }

    return parser.tkz.in_begin;
}

 void lxb_css_parser_buffer_set(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    lxb_css_syntax_tokenizer_buffer_set(parser.tkz, data, length);
}

 lxb_css_parser_state_f lxb_css_parser_state(lxb_css_parser_t* parser)
{
    return parser.rules.state;
}

 void lxb_css_parser_state_set(lxb_css_parser_t* parser, lxb_css_parser_state_f state)
{
    parser.rules.state = state;
}

 lxb_css_syntax_rule_t* lxb_css_parser_current_rule(lxb_css_parser_t* parser)
{
    return parser.rules;
}

 size_t lxb_css_parser_rule_deep(lxb_css_parser_t* parser)
{
    return parser.rules.deep;
}

 lxb_css_parser_state_t* lxb_css_parser_states_pop(lxb_css_parser_t* parser)
{
    return parser.states--;
}

 lxb_css_parser_state_t* lxb_css_parser_states_to_root(lxb_css_parser_t* parser)
{
    lxb_css_parser_state_t* entry = parser.states;

    while (!entry.root) {
        entry--;
    }

    parser.states = entry;

    return entry;
}

 bool lxb_css_parser_states_set_back(lxb_css_parser_t* parser)
{
    const(lxb_css_parser_state_t)* entry = parser.states;
    lxb_css_syntax_rule_t* rules = parser.rules;

    rules.state = entry.state;
    rules.context = cast(void*) entry.context;

    return true;
}

 void lxb_css_parser_states_clean(lxb_css_parser_t* parser)
{
    parser.states = parser.states_begin;
}

 lxb_css_parser_state_t* lxb_css_parser_states_current(lxb_css_parser_t* parser)
{
    return parser.states;
}

 void lxb_css_parser_states_set(lxb_css_parser_state_t* states, lxb_css_parser_state_f state, void* context)
{
    states.state = state;
    states.context = context;
}

 void lxb_css_parser_states_up(lxb_css_parser_t* parser)
{
    parser.states++;
}

 void lxb_css_parser_states_down(lxb_css_parser_t* parser)
{
    parser.states--;
}

 lxb_css_log_t* lxb_css_parser_log(lxb_css_parser_t* parser)
{
    return parser.log;
}

 const(lxb_css_syntax_token_t)* lxb_css_parser_token_end(lxb_css_parser_t* parser, size_t offset)
{
    parser.token_end.offset = offset;
    return &parser.token_end;
}

 void lxb_css_parser_set_context(lxb_css_parser_t* parser, void* ctx)
{
    parser.rules.context = ctx;
}

 void lxb_css_syntax_set_return(lxb_css_parser_t* parser, void* value)
{
    parser.rules[-1].returned = value;
}

 void* lxb_css_syntax_returned(lxb_css_parser_t* parser)
{
    return parser.rules.returned;
}

/*
 * No-inline functions for ABI.
 */






























// ---- parser.c ----
/*
 * Copyright (C) 2021-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_css_parser_t* lxb_css_parser_create()
{
    return cast(lxb_css_parser*) lexbor_calloc(1, lxb_css_parser_t.sizeof);
}

lxb_status_t lxb_css_parser_init(lxb_css_parser_t* parser, lxb_css_syntax_tokenizer_t* tkz)
{
    lxb_status_t status = void;
    static const(size_t) lxb_rules_length = 128;
    static const(size_t) lxb_states_length = 1024;

    if (parser == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    /* Stack */
    parser.states_begin = cast(lxb_css_parser_state_*) lexbor_malloc(lxb_css_parser_state_t.sizeof
                                         * lxb_states_length);
    if (parser.states_begin == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    parser.states = parser.states_begin;
    parser.states_end = parser.states_begin + lxb_states_length;

    memset(parser.states, 0x00, lxb_css_parser_state_t.sizeof);
    parser.states.root = true;

    /* Syntax */
    parser.my_tkz = false;

    if (tkz == null) {
        tkz = lxb_css_syntax_tokenizer_create();
        status = lxb_css_syntax_tokenizer_init(tkz);
        if (status != LXB_STATUS_OK) {
            return status;
        }

        parser.my_tkz = true;
    }

    /* Rules */
    parser.rules_begin = cast(lxb_css_syntax_rule*) lexbor_malloc(lxb_css_syntax_rule_t.sizeof
                                        * lxb_rules_length);
    if (parser.rules_begin == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    parser.rules_end = parser.rules_begin + lxb_rules_length;
    parser.rules = parser.rules_begin;

    /*
     * Zero those parameters that can be used (passed to the function).
     * The parser->rules->phase parameter will be assigned at the end of the
     * parsing.
     *
     * The point is that parser->rules[0] is used as a stub before exiting
     * parsing.
     */
    parser.rules.context = null;

    /* Temp */
    parser.str.length = 0;
    parser.str_size = 4096;

    parser.str.data = cast(ubyte*) lexbor_malloc(lxb_char_t.sizeof * parser.str_size);
    if (parser.str.data == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    parser.log = lxb_css_log_create();
    status = lxb_css_log_init(parser.log, null);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    parser.tkz = tkz;
    parser.types_begin = null;
    parser.types_pos = null;
    parser.types_end = null;
    parser.stage = LXB_CSS_PARSER_CLEAN;
    parser.status = LXB_STATUS_OK;
    parser.fake_null = false;
    parser.token_end.type = LXB_CSS_SYNTAX_TOKEN__END;

    return LXB_STATUS_OK;
}

lxb_status_t lxb_css_parser_selectors_init(lxb_css_parser_t* parser)
{
    lxb_status_t status = void;

    parser.selectors = lxb_css_selectors_create();
    status = lxb_css_selectors_init(parser.selectors);
    if (status != LXB_STATUS_OK) {
        parser.selectors = lxb_css_selectors_destroy(parser.selectors, true);
    }

    return status;
}

void lxb_css_parser_selectors_destroy(lxb_css_parser_t* parser)
{
    if (parser.selectors != null) {
        parser.selectors = lxb_css_selectors_destroy(parser.selectors, true);
    }
}

void lxb_css_parser_clean(lxb_css_parser_t* parser)
{
    lxb_css_syntax_tokenizer_clean(parser.tkz);
    lxb_css_log_clean(parser.log);

    parser.rules = parser.rules_begin;
    parser.states = parser.states_begin;
    parser.types_pos = parser.types_begin;
    parser.stage = LXB_CSS_PARSER_CLEAN;
    parser.status = LXB_STATUS_OK;
    parser.str.length = 0;
    parser.fake_null = false;
}

void lxb_css_parser_erase(lxb_css_parser_t* parser)
{
    lxb_css_parser_clean(parser);

    if (parser.memory != null) {
        lxb_css_memory_clean(parser.memory);
    }
}

lxb_css_parser_t* lxb_css_parser_destroy(lxb_css_parser_t* parser, bool self_destroy)
{
    if (parser == null) {
        return null;
    }

    if (parser.my_tkz) {
        parser.tkz = lxb_css_syntax_tokenizer_destroy(parser.tkz);
    }

    parser.log = lxb_css_log_destroy(parser.log, true);

    if (parser.rules_begin != null) {
        parser.rules_begin = cast(lxb_css_syntax_rule*) lexbor_free(parser.rules_begin);
    }

    if (parser.states_begin != null) {
        parser.states_begin = cast(lxb_css_parser_state_*) lexbor_free(parser.states_begin);
    }

    if (parser.types_begin != null) {
        parser.types_begin = cast(lxb_css_syntax_token_type_t*) lexbor_free(parser.types_begin);
    }

    if (parser.str.data != null) {
        parser.str.data = cast(ubyte*) lexbor_free(parser.str.data);
    }

    if (self_destroy) {
        return cast(lxb_css_parser*) lexbor_free(parser);
    }

    return parser;
}

lxb_css_parser_state_t* lxb_css_parser_states_push(lxb_css_parser_t* parser, lxb_css_parser_state_f state, void* ctx, bool root)
{
    size_t length = void, cur_length = void;
    lxb_css_parser_state_t* states = ++parser.states;

    if (states >= parser.states_end) {
        cur_length = states - parser.states_begin;

        if (SIZE_MAX - cur_length < 1024) {
            goto memory_error;
        }

        length = cur_length + 1024;

        states = cast(lxb_css_parser_state_*) lexbor_realloc(parser.states_begin,
                                length * lxb_css_parser_state_t.sizeof);
        if (states == null) {
            goto memory_error;
        }

        parser.states_begin = states;
        parser.states_end = states + length;
        parser.states = states + cur_length;

        states = parser.states;
    }

    states.state = state;
    states.context = ctx;
    states.root = root;

    return states;

memory_error:

    parser.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;

    return null;
}

lxb_css_parser_state_t* lxb_css_parser_states_next(lxb_css_parser_t* parser, lxb_css_parser_state_f next, lxb_css_parser_state_f back, void* ctx, bool root)
{
    lxb_css_parser_state_t* state = void;

    state = lxb_css_parser_states_push(parser, back, ctx, root);
    if (state == null) {
        return null;
    }

    parser.rules.state = next;

    return state;
}

lxb_status_t lxb_css_parser_types_push(lxb_css_parser_t* parser, lxb_css_syntax_token_type_t type)
{
    size_t length = void, new_length = void;
    lxb_css_syntax_token_type_t* tmp = void;

    if (parser.types_pos >= parser.types_end) {
        length = parser.types_end - parser.types_begin;

        if ((SIZE_MAX - length) < 1024) {
            return LXB_STATUS_ERROR_OVERFLOW;
        }

        new_length = length + 1024;

        tmp = cast(lxb_css_syntax_token_type_t*) lexbor_realloc(parser.types_begin,
                             new_length * lxb_css_syntax_token_type_t.sizeof);
        if (tmp == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        parser.types_begin = tmp;
        parser.types_end = tmp + new_length;
        parser.types_pos = parser.types_begin + length;
    }

    *parser.types_pos++ = type;

    return LXB_STATUS_OK;
}

bool lxb_css_parser_stop(lxb_css_parser_t* parser)
{
    parser.loop = false;
    return true;
}

bool lxb_css_parser_fail(lxb_css_parser_t* parser, lxb_status_t status)
{
    parser.status = status;
    parser.loop = false;
    return true;
}

bool lxb_css_parser_unexpected(lxb_css_parser_t* parser)
{
    cast(void) lxb_css_parser_unexpected_status(parser);
    return true;
}

bool lxb_css_parser_success(lxb_css_parser_t* parser)
{
    parser.rules.state = &lxb_css_state_success;
    return true;
}

bool lxb_css_parser_failed(lxb_css_parser_t* parser)
{
    lxb_css_syntax_rule_t* rule = parser.rules;

    rule.state = rule.cbx.cb.failed;
    rule.failed = true;

    return true;
}

lxb_status_t lxb_css_parser_unexpected_status(lxb_css_parser_t* parser)
{
    parser.status = LXB_STATUS_ERROR_UNEXPECTED_DATA;

    parser.rules.failed = true;

    return LXB_STATUS_ERROR_UNEXPECTED_DATA;
}

bool lxb_css_parser_unexpected_data(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token)
{
    static const(char)[10] selectors = "Selectors";
    parser.status = LXB_STATUS_ERROR_UNEXPECTED_DATA;

    if (lxb_css_syntax_token_error(parser, token, selectors.ptr) == null) {
        return lxb_css_parser_memory_fail(parser);
    }

    return true;
}

lxb_status_t lxb_css_parser_unexpected_data_status(lxb_css_parser_t* parser, const(lxb_css_syntax_token_t)* token)
{
    static const(char)[10] selectors = "Selectors";
    parser.status = LXB_STATUS_ERROR_UNEXPECTED_DATA;

    if (lxb_css_syntax_token_error(parser, token, selectors.ptr) == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    return LXB_STATUS_ERROR_UNEXPECTED_DATA;
}

void* lxb_css_parser_memory_fail_null(lxb_css_parser_t* parser)
{
    parser.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    parser.loop = false;
    return null;
}

bool lxb_css_parser_memory_fail(lxb_css_parser_t* parser)
{
    parser.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    parser.loop = false;
    return true;
}

lxb_status_t lxb_css_parser_memory_fail_status(lxb_css_parser_t* parser)
{
    parser.status = LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    parser.loop = false;

    return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
}

/*
 * No-inline functions for ABI.
 */
lxb_status_t lxb_css_parser_status_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_status(parser);
}

lxb_css_memory_t* lxb_css_parser_memory_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_memory(parser);
}

void lxb_css_parser_memory_set_noi(lxb_css_parser_t* parser, lxb_css_memory_t* memory)
{
    lxb_css_parser_memory_set(parser, memory);
}

lxb_css_selectors_t* lxb_css_parser_selectors_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_selectors(parser);
}

void lxb_css_parser_selectors_set_noi(lxb_css_parser_t* parser, lxb_css_selectors_t* selectors)
{
    lxb_css_parser_selectors_set(parser, selectors);
}

bool lxb_css_parser_is_running_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_is_running(parser);
}

bool lxb_css_parser_status_is_unexpected_data_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_status_is_unexpected_data(parser);
}

void lxb_css_parser_failed_set_noi(lxb_css_parser_t* parser, bool is_)
{
    lxb_css_parser_failed_set(parser, is_);
}

void lxb_css_parser_failed_set_by_id_noi(lxb_css_parser_t* parser, int idx, bool is_)
{
    lxb_css_parser_failed_set_by_id(parser, idx, is_);
}

bool lxb_css_parser_is_failed_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_is_failed(parser);
}

void lxb_css_parser_set_ok_noi(lxb_css_parser_t* parser)
{
    lxb_css_parser_set_ok(parser);
}

const(lxb_char_t)* lxb_css_parser_buffer_noi(lxb_css_parser_t* parser, size_t* length)
{
    return lxb_css_parser_buffer(parser, length);
}

void lxb_css_parser_buffer_set_noi(lxb_css_parser_t* parser, const(lxb_char_t)* data, size_t length)
{
    lxb_css_parser_buffer_set(parser, data, length);
}

lxb_css_parser_state_f lxb_css_parser_state_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_state(parser);
}

void lxb_css_parser_state_set_noi(lxb_css_parser_t* parser, lxb_css_parser_state_f state)
{
    lxb_css_parser_state_set(parser, state);
}

lxb_css_syntax_rule_t* lxb_css_parser_current_rule_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_current_rule(parser);
}

size_t lxb_css_parser_rule_deep_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_rule_deep(parser);
}

lxb_css_parser_state_t* lxb_css_parser_states_pop_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_states_pop(parser);
}

lxb_css_parser_state_t* lxb_css_parser_states_to_root_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_states_to_root(parser);
}

bool lxb_css_parser_states_set_back_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_states_set_back(parser);
}

void lxb_css_parser_states_clean_noi(lxb_css_parser_t* parser)
{
    lxb_css_parser_states_clean(parser);
}

lxb_css_parser_state_t* lxb_css_parser_states_current_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_states_current(parser);
}

void lxb_css_parser_states_set_noi(lxb_css_parser_state_t* states, lxb_css_parser_state_f state, void* context)
{
    lxb_css_parser_states_set(states, state, context);
}

void lxb_css_parser_states_up_noi(lxb_css_parser_t* parser)
{
    lxb_css_parser_states_up(parser);
}

void lxb_css_parser_states_down_noi(lxb_css_parser_t* parser)
{
    lxb_css_parser_states_down(parser);
}

lxb_css_log_t* lxb_css_parser_log_noi(lxb_css_parser_t* parser)
{
    return lxb_css_parser_log(parser);
}

const(lxb_css_syntax_token_t)* lxb_css_parser_token_end_noi(lxb_css_parser_t* parser, size_t offset)
{
    return lxb_css_parser_token_end(parser, offset);
}

void lxb_css_parser_set_context_noi(lxb_css_parser_t* parser, void* ctx)
{
    lxb_css_parser_set_context(parser, ctx);
}

void lxb_css_syntax_set_return_noi(lxb_css_parser_t* parser, void* value)
{
    lxb_css_syntax_set_return(parser, value);
}

void* lxb_css_syntax_returned_noi(lxb_css_parser_t* parser)
{
    return lxb_css_syntax_returned(parser);
}
