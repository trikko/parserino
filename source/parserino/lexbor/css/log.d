module parserino.lexbor.css.log;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.mraw;
public import parserino.lexbor.core.str;
public import parserino.lexbor.core.array_obj;
public import parserino.lexbor.css.base;
import parserino.lexbor.core.print;
import parserino.lexbor.core.serialize;

extern(C) @nogc nothrow:
__gshared:

// ---- log.h ----
/*
 * Copyright (C) 2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum lxb_css_log_type_t {
    LXB_CSS_LOG_INFO = 0,
    LXB_CSS_LOG_WARNING,
    LXB_CSS_LOG_ERROR,
    LXB_CSS_LOG_SYNTAX_ERROR
}
alias LXB_CSS_LOG_INFO = lxb_css_log_type_t.LXB_CSS_LOG_INFO;
alias LXB_CSS_LOG_WARNING = lxb_css_log_type_t.LXB_CSS_LOG_WARNING;
alias LXB_CSS_LOG_ERROR = lxb_css_log_type_t.LXB_CSS_LOG_ERROR;
alias LXB_CSS_LOG_SYNTAX_ERROR = lxb_css_log_type_t.LXB_CSS_LOG_SYNTAX_ERROR;


struct lxb_css_log_message_t {
    lexbor_str_t text;
    lxb_css_log_type_t type;
}

struct lxb_css_log_t {
    lexbor_array_obj_t messages;
    lexbor_mraw_t* mraw;
    bool self_mraw;
}














/*
 * Inline functions
 */
 size_t lxb_css_log_length(lxb_css_log_t* log)
{
    return lexbor_array_obj_length(&log.messages);
}

// ---- log.c ----
/*
 * Copyright (C) 2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

struct lxb_css_log_type_str_t {
    const(char)* msg;
    size_t length;
}

private const(lxb_css_log_type_str_t)[4] lxb_css_log_types_map = [
    {"Info", 4},
    {"Warning", 7},
    {"Error", 5},
    {"Syntax error", 12}
];

lxb_css_log_t* lxb_css_log_create()
{
    return cast(lxb_css_log_t*) lexbor_calloc(1, lxb_css_log_t.sizeof);
}

lxb_status_t lxb_css_log_init(lxb_css_log_t* log, lexbor_mraw_t* mraw)
{
    lxb_status_t status = void;

    if (log == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    status = lexbor_array_obj_init(&log.messages, 64,
                                   lxb_css_log_message_t.sizeof);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    if (mraw != null) {
        log.mraw = mraw;
        log.self_mraw = false;
        return LXB_STATUS_OK;
    }

    log.self_mraw = true;

    log.mraw = lexbor_mraw_create();

    return lexbor_mraw_init(log.mraw, 4096);
}

void lxb_css_log_clean(lxb_css_log_t* log)
{
    if (log != null) {
        lexbor_array_obj_clean(&log.messages);

        if (log.self_mraw) {
            lexbor_mraw_clean(log.mraw);
        }
    }
}

lxb_css_log_t* lxb_css_log_destroy(lxb_css_log_t* log, bool self_destroy)
{
    if (log == null) {
        return null;
    }

    cast(void) lexbor_array_obj_destroy(&log.messages, false);

    if (log.self_mraw) {
        cast(void) lexbor_mraw_destroy(log.mraw, true);
    }

    if (self_destroy) {
        log = cast(lxb_css_log_t*) lexbor_free(log);
    }

    return log;
}

lxb_css_log_message_t* lxb_css_log_append(lxb_css_log_t* log, lxb_css_log_type_t type, const(lxb_char_t)* str, size_t length)
{
    lxb_css_log_message_t* msg = void;

    msg = cast(lxb_css_log_message_t*) lexbor_array_obj_push(&log.messages);
    if (msg == null) {
        return null;
    }

    if (lexbor_str_init(&msg.text, log.mraw, length) == null) {
        lexbor_array_obj_pop(&log.messages);
        return null;
    }

    memcpy(msg.text.data, str, length);
    msg.text.length = length;

    msg.text.data[length] = '\0';

    msg.type = type;

    return msg;
}

lxb_css_log_message_t* lxb_css_log_push(lxb_css_log_t* log, lxb_css_log_type_t type, size_t length)
{
    lxb_css_log_message_t* msg = void;

    msg = cast(lxb_css_log_message_t*) lexbor_array_obj_push(&log.messages);
    if (msg == null) {
        return null;
    }

    if (lexbor_str_init(&msg.text, log.mraw, length) == null) {
        lexbor_array_obj_pop(&log.messages);
        return null;
    }

    msg.type = type;

    return msg;
}

lxb_css_log_message_t* lxb_css_log_format(lxb_css_log_t* log, lxb_css_log_type_t type, const(char)* format, ...)
{
    size_t psize = void;
    lxb_css_log_message_t* msg = void;
    va_list va = void;

    va_start(va, format);
    psize = lexbor_vprintf_size(format, va);
    va_end(va);

    if (psize == LXB_PRINT_ERROR) {
        return null;
    }

    msg = lxb_css_log_push(log, LXB_CSS_LOG_SYNTAX_ERROR, psize);
    if (msg == null) {
        return null;
    }

    va_start(va, format);
    cast(void) lexbor_vsprintf(msg.text.data, psize, format, va);
    va_end(va);

    msg.text.length = psize;

    return msg;
}

lxb_css_log_message_t* lxb_css_log_not_supported(lxb_css_log_t* log, const(char)* module_name, const(char)* description)
{
    static const(char)[22] unexpected = "%s. Not supported: %s";

    return lxb_css_log_format(log, LXB_CSS_LOG_SYNTAX_ERROR, unexpected.ptr,
                              module_name, description);
}

const(lxb_char_t)* lxb_css_log_type_by_id(lxb_css_log_type_t type, size_t* out_length)
{
    if (out_length != null) {
        *out_length = lxb_css_log_types_map[type].length;
    }

    return cast(const(lxb_char_t)*) lxb_css_log_types_map[type].msg;
}

lxb_status_t lxb_css_log_serialize(lxb_css_log_t* log, lexbor_serialize_cb_f cb, void* ctx, const(lxb_char_t)* indent, size_t indent_length)
{
    size_t i = void;
    lxb_status_t status = void;
    lxb_css_log_message_t* msg = void;

    if (log.messages.length == 0) {
        return LXB_STATUS_OK;
    }

    i = 0;

    do {
        msg = cast(lxb_css_log_message_t*) lexbor_array_obj_get(&log.messages, i);

        if (indent != null) {
            do { (status) = cb(cast(lxb_char_t*) (indent), (indent_length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
        }

        status = lxb_css_log_message_serialize(msg, cb, ctx);
        if (status != LXB_STATUS_OK) {
            return status;
        }

        i++;

        if (i == log.messages.length) {
            break;
        }

        do { (status) = cb(cast(lxb_char_t*) ("\n"), (1), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    }
    while (true);

    return LXB_STATUS_OK;
}

lxb_char_t* lxb_css_log_serialize_char(lxb_css_log_t* log, size_t* out_length, const(lxb_char_t)* indent, size_t indent_length)
{
    size_t length = 0;
    lxb_status_t status = void;
    lexbor_str_t str = void;

    status = lxb_css_log_serialize(log, &lexbor_serialize_length_cb, &length,
                                   indent, indent_length);
    if (status != LXB_STATUS_OK) {
        goto failed;
    }

    /* + 1 == '\0' */
    str.data = cast(ubyte*) lexbor_malloc(length + 1);
    if (str.data == null) {
        goto failed;
    }

    str.length = 0;

    status = lxb_css_log_serialize(log, &lexbor_serialize_copy_cb, &str,
                                   indent, indent_length);
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

lxb_status_t lxb_css_log_message_serialize(lxb_css_log_message_t* msg, lexbor_serialize_cb_f cb, void* ctx)
{
    size_t length = void;
    lxb_status_t status = void;
    const(lxb_char_t)* type_name = void;

    type_name = lxb_css_log_type_by_id(msg.type, &length);

    do { (status) = cb(cast(lxb_char_t*) (type_name), (length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    do { (status) = cb(cast(lxb_char_t*) (". "), (2), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);
    do { (status) = cb(cast(lxb_char_t*) (msg.text.data), (msg.text.length), (ctx)); if ((status) != LXB_STATUS_OK) { return (status); } } while (false);

    return LXB_STATUS_OK;
}

lxb_char_t* lxb_css_log_message_serialize_char(lxb_css_log_message_t* msg, size_t* out_length)
{
    size_t length = 0;
    lxb_status_t status = void;
    lexbor_str_t str = void;

    status = lxb_css_log_message_serialize(msg, &lexbor_serialize_length_cb,
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

    status = lxb_css_log_message_serialize(msg, &lexbor_serialize_copy_cb, &str);
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
