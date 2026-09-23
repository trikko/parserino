module parserino.lexbor.core.base;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import core.stdc.stdlib;
public import core.stdc.stddef;
public import core.stdc.stdio;
public import core.stdc.stdarg;
public import core.stdc.string;
public import core.stdc.limits;
public import core.stdc.config;
public import core.stdc.stdint;
public import parserino.lexbor.core.def;
public import parserino.lexbor.core.types;
public import parserino.lexbor.core.lexbor;

extern(C) @nogc nothrow:
__gshared:

// ---- base.h ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum LEXBOR_VERSION_MAJOR = 1;
enum LEXBOR_VERSION_MINOR = 9;
enum LEXBOR_VERSION_PATCH = 0;

enum LEXBOR_VERSION_STRING = "1.9.0";

/*
 * Very important!!!
 *
 * for lexbor 0..00AFFF; LXB_STATUS_OK == 0x000000
 */
enum lexbor_status_t {
    LXB_STATUS_OK = 0x0000,
    LXB_STATUS_ERROR = 0x0001,
    LXB_STATUS_ERROR_MEMORY_ALLOCATION,
    LXB_STATUS_ERROR_OBJECT_IS_NULL,
    LXB_STATUS_ERROR_SMALL_BUFFER,
    LXB_STATUS_ERROR_INCOMPLETE_OBJECT,
    LXB_STATUS_ERROR_NO_FREE_SLOT,
    LXB_STATUS_ERROR_TOO_SMALL_SIZE,
    LXB_STATUS_ERROR_NOT_EXISTS,
    LXB_STATUS_ERROR_WRONG_ARGS,
    LXB_STATUS_ERROR_WRONG_STAGE,
    LXB_STATUS_ERROR_UNEXPECTED_RESULT,
    LXB_STATUS_ERROR_UNEXPECTED_DATA,
    LXB_STATUS_ERROR_OVERFLOW,
    LXB_STATUS_CONTINUE,
    LXB_STATUS_SMALL_BUFFER,
    LXB_STATUS_ABORTED,
    LXB_STATUS_STOPPED,
    LXB_STATUS_NEXT,
    LXB_STATUS_STOP,
    LXB_STATUS_WARNING
}
alias LXB_STATUS_OK = lexbor_status_t.LXB_STATUS_OK;
alias LXB_STATUS_ERROR = lexbor_status_t.LXB_STATUS_ERROR;
alias LXB_STATUS_ERROR_MEMORY_ALLOCATION = lexbor_status_t.LXB_STATUS_ERROR_MEMORY_ALLOCATION;
alias LXB_STATUS_ERROR_OBJECT_IS_NULL = lexbor_status_t.LXB_STATUS_ERROR_OBJECT_IS_NULL;
alias LXB_STATUS_ERROR_SMALL_BUFFER = lexbor_status_t.LXB_STATUS_ERROR_SMALL_BUFFER;
alias LXB_STATUS_ERROR_INCOMPLETE_OBJECT = lexbor_status_t.LXB_STATUS_ERROR_INCOMPLETE_OBJECT;
alias LXB_STATUS_ERROR_NO_FREE_SLOT = lexbor_status_t.LXB_STATUS_ERROR_NO_FREE_SLOT;
alias LXB_STATUS_ERROR_TOO_SMALL_SIZE = lexbor_status_t.LXB_STATUS_ERROR_TOO_SMALL_SIZE;
alias LXB_STATUS_ERROR_NOT_EXISTS = lexbor_status_t.LXB_STATUS_ERROR_NOT_EXISTS;
alias LXB_STATUS_ERROR_WRONG_ARGS = lexbor_status_t.LXB_STATUS_ERROR_WRONG_ARGS;
alias LXB_STATUS_ERROR_WRONG_STAGE = lexbor_status_t.LXB_STATUS_ERROR_WRONG_STAGE;
alias LXB_STATUS_ERROR_UNEXPECTED_RESULT = lexbor_status_t.LXB_STATUS_ERROR_UNEXPECTED_RESULT;
alias LXB_STATUS_ERROR_UNEXPECTED_DATA = lexbor_status_t.LXB_STATUS_ERROR_UNEXPECTED_DATA;
alias LXB_STATUS_ERROR_OVERFLOW = lexbor_status_t.LXB_STATUS_ERROR_OVERFLOW;
alias LXB_STATUS_CONTINUE = lexbor_status_t.LXB_STATUS_CONTINUE;
alias LXB_STATUS_SMALL_BUFFER = lexbor_status_t.LXB_STATUS_SMALL_BUFFER;
alias LXB_STATUS_ABORTED = lexbor_status_t.LXB_STATUS_ABORTED;
alias LXB_STATUS_STOPPED = lexbor_status_t.LXB_STATUS_STOPPED;
alias LXB_STATUS_NEXT = lexbor_status_t.LXB_STATUS_NEXT;
alias LXB_STATUS_STOP = lexbor_status_t.LXB_STATUS_STOP;
alias LXB_STATUS_WARNING = lexbor_status_t.LXB_STATUS_WARNING;


enum lexbor_action_t {
    LEXBOR_ACTION_OK = 0x00,
    LEXBOR_ACTION_STOP = 0x01,
    LEXBOR_ACTION_NEXT = 0x02
}
alias LEXBOR_ACTION_OK = lexbor_action_t.LEXBOR_ACTION_OK;
alias LEXBOR_ACTION_STOP = lexbor_action_t.LEXBOR_ACTION_STOP;
alias LEXBOR_ACTION_NEXT = lexbor_action_t.LEXBOR_ACTION_NEXT;


alias lexbor_serialize_cb_f = lxb_status_t function(const(lxb_char_t)* data, size_t len, void* ctx);

alias lexbor_serialize_cb_cp_f = lxb_status_t function(const(lxb_codepoint_t)* cps, size_t len, void* ctx);

struct lexbor_serialize_ctx_t {
    lexbor_serialize_cb_f cb;
    void* ctx;

    intptr_t opt;
    size_t count;
}
