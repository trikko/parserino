module parserino.lexbor.html.common;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.base;
public import parserino.lexbor.core.utils;

extern(C) @nogc nothrow:
__gshared:

// ---- common.h ----
/*
 * Copyright (C) 2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */


// ---- common.c ----
/*
 * Copyright (C) 2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_status_t lxb_html_common_parsing_integer(const(lxb_char_t)* data, size_t length, long* result)
{
    bool sign = void;
    ulong value = void;
    const(lxb_char_t)* end = void;

    if (data == null || length == 0) {
        goto error;
    }

    end = data + length;

    /* 4. Skip ASCII whitespace. */

    while (data < end && (*data == ' ' || *data == '\t' || *data == '\n' || *data == '\f' || *data == '\r')) {
        data++;
    }

    /* 5. If position is past the end of input, return an error. */

    if (data >= end) {
        goto error;
    }

    /* 6. */

    sign = true;

    if (*data == '-') {
        sign = false;
        data++;

        if (data >= end) {
            goto error;
        }
    }
    else if (*data == '+') {
        data++;

        if (data >= end) {
            goto error;
        }
    }

    /* 7. If the character indicated by position is not an ASCII digit,
     * then return an error. */

    if (*data < '0' || *data > '9') {
        goto error;
    }

    /* 8. Collect a sequence of code points that are ASCII digits from input
     * given position, and interpret the resulting sequence as a base-ten
     * integer. Let value be that integer. */

    value = 0;

    while (data < end && *data >= '0' && *data <= '9') {
        value = value * 10 + (*data - '0');
        data++;
    }

    /* 9. If sign is "positive", return value, otherwise return the result
     * of subtracting value from zero. */

    *result = (sign) ? cast(long) value : -(cast(long) value);

    return LXB_STATUS_OK;

error:

    *result = 0;

    return LXB_STATUS_ERROR;
}

lxb_status_t lxb_html_common_parsing_nonneg_integer(const(lxb_char_t)* data, size_t length, long* result)
{
    lxb_status_t status = void;

    /* 2. Let value be the result of parsing input using the rules
     * for parsing integers. */

    status = lxb_html_common_parsing_integer(data, length, result);

    /* 3. If value is an error, return an error. */

    if (status != LXB_STATUS_OK) {
        return status;
    }

    /* 4. If value is less than zero, return an error. */

    if (*result < 0) {
        return LXB_STATUS_ERROR;
    }

    /* 5. Return value. */

    return LXB_STATUS_OK;
}
