module parserino.lexbor.core.conv;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
import core.stdc.math;
import core.stdc.float_;
import parserino.lexbor.core.dtoa;
import parserino.lexbor.core.strtod;

extern(C) @nogc nothrow:
__gshared:

// ---- conv.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */








 c_long lexbor_conv_double_to_long(double number)
{
    if (number > cast(double) LONG_MAX) {
        return LONG_MAX;
    }

    if (number < cast(double) LONG_MIN) {
        return -LONG_MAX;
    }

    return cast(c_long) number;
}

// ---- conv.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

size_t lexbor_conv_float_to_data(double num, lxb_char_t* buf, size_t len)
{
    return lexbor_dtoa(num, buf, len);
}

size_t lexbor_conv_long_to_data(c_long num, lxb_char_t* buf, size_t len)
{
    return lexbor_conv_int64_to_data(cast(long) num, buf, len);
}

size_t lexbor_conv_int64_to_data(long num, lxb_char_t* buf, size_t len)
{
    long tmp = void;
    size_t have_minus = void, i = void, length = void;

    static const(lxb_char_t)* digits = cast(const(lxb_char_t)*) "0123456789";

    if (num != 0) {
        tmp = num;
        length = 0;
        have_minus = 0;

        if (num < 0) {
            length = 1;
            num = -num;
            have_minus = 1;
        }

        while (tmp != 0) {
            length += 1;
            tmp /= 10;
        }

        /* length += (size_t) floor(log10(labs((long) num))) + 1; */
    }
    else {
        if (len > 0) {
            buf[0] = '0';
            return 1;
        }

        return 0;
    }

    if (len < length) {
        i = (length + have_minus) - len;

        while (i != have_minus) {
            i -= 1;
            num /= 10;
        }

        length = len;
    }

    if (have_minus) {
        buf[0] = '-';
    }

    i = length;
    buf[length] = '\0';

    while (i != have_minus) {
        i -= 1;
        buf[i] = digits[ num % 10 ];
        num /= 10;
    }

    return length;
}

double lexbor_conv_data_to_double(const(lxb_char_t)** start, size_t len)
{
    int exponent = void, exp = void, insignf = void;
    lxb_char_t c = void; lxb_char_t* pos = void;
    bool minus = void, ex_minus = void;
    double num = void;
    const(lxb_char_t)* e = void, p = void, last = void, end = void;
    lxb_char_t[128] data = void;

    end = *start + len;

    exponent = 0;
    insignf = 0;

    pos = data.ptr;
    last = data.ptr + data.sizeof;

    minus = false;

    switch (**start) {
        case '-':
            minus = true;
            /* fall through */
            goto case; /* C fallthrough */
        case '+':
            (*start)++;
            /* fall through */
            goto default; /* C fallthrough */
        default:
            break;
    }

    for (p = *start; p < end; p++) {
        /* Values less than '0' become >= 208. */
        c = cast(lxb_char_t) (*p - '0');

        if (c > 9) {
            break;
        }

        if (pos < last) {
            *pos++ = *p;
        }
        else {
            insignf++;
        }
    }

    /* Do not emit a '.', but adjust the exponent instead. */
    if (p < end && *p == '.') {

        for (p++; p < end; p++) {
            /* Values less than '0' become >= 208. */
            c = cast(lxb_char_t) (*p - '0');

            if (c > 9) {
                break;
            }

            if (pos < last) {
                *pos++ = *p;
                exponent--;
            }
            else {
                /* Ignore insignificant digits in the fractional part. */
            }
        }
    }

    e = p + 1;

    if (e < end && (*p == 'e' || *p == 'E')) {
        ex_minus = 0;

        if (e + 1 < end) {
            if (*e == '-') {
                e++;
                ex_minus = 1;
            }
            else if (*e == '+') {
                e++;
            }
        }

        /* Values less than '0' become >= 208. */
        c = cast(lxb_char_t) (*e - '0');

        if (c <= 9) {
            exp = c;

            for (p = e + 1; p < end; p++) {
                /* Values less than '0' become >= 208. */
                c = cast(lxb_char_t) (*p - '0');

                if (c > 9) {
                    break;
                }

                exp = exp * 10 + c;
            }

            exponent += ex_minus ? -exp : exp;
        }
    }

    *start = p;

    exponent += insignf;

    num = lexbor_strtod_internal(data.ptr, pos - data.ptr, exponent);

    if (minus) {
        num = -num;
    }

    return num;
}

c_ulong lexbor_conv_data_to_ulong(const(lxb_char_t)** data, size_t length)
{
    const(lxb_char_t)* p = *data;
    const(lxb_char_t)* end = p + length;
    c_ulong last_number = 0, number = 0;

    for (; p < end; p++) {
        if (*p < '0' || *p > '9') {
            goto done;
        }

        number = (*p - '0') + number * 10;

        if (last_number > number) {
            *data = p - 1;
            return last_number;
        }

        last_number = number;
    }

done:

    *data = p;

    return number;
}

c_long lexbor_conv_data_to_long(const(lxb_char_t)** data, size_t length)
{
    bool minus = void;
    const(lxb_char_t)* p = void;
    const(lxb_char_t)* end = void;
    c_ulong n = 0, number = 0;

    minus = false;
    p = *data;
    end = p + length;

    switch (*p) {
        case '-':
            minus = true;
            goto case;
            /* fall through */
        case '+':
            p++;
            goto default;
            /* fall through */
        default:
            break;
    }

    for (; p < end; p++) {
        if (*p < '0' || *p > '9') {
            break;
        }

        n = (*p - '0') + number * 10;

        if (n > LONG_MAX) {
            p -= 1;
            break;
        }

        number = n;
    }

    *data = p;

    return (minus) ? -number : number;
}

uint lexbor_conv_data_to_uint(const(lxb_char_t)** data, size_t length)
{
    const(lxb_char_t)* p = *data;
    const(lxb_char_t)* end = p + length;
    uint last_number = 0, number = 0;

    for (; p < end; p++) {
        if (*p < '0' || *p > '9') {
            goto done;
        }

        number = (*p - '0') + number * 10;

        if (last_number > number) {
            *data = p - 1;
            return last_number;
        }

        last_number = number;
    }

done:

    *data = p;

    return number;
}

size_t lexbor_conv_dec_to_hex(uint number, lxb_char_t* out_, size_t length, bool upper)
{
    lxb_char_t c = void;
    size_t len = void;
    uint tmp = void;
    const(lxb_char_t)* map_str = void;

    static const(lxb_char_t)[17] map_str_l = lexbor_carray!"0123456789abcdef";
    static const(lxb_char_t)[17] map_str_u = lexbor_carray!"0123456789ABCDEF";

    map_str = (upper) ? map_str_u.ptr : map_str_l.ptr;

    if(number != 0) {
        tmp = number;
        len = 0;

        while (tmp != 0) {
            len += 1;
            tmp /= 16;
        }

        /* len = (size_t) floor(log10(labs((long) number))) + 1; */
    }
    else {
        if (length > 0) {
            out_[0] = '0';
            return 1;
        }

        return 0;
    }

    length = len - 1;

    while (number != 0) {
        c = number % 16;
        number = number / 16;

        out_[ length-- ] = map_str[c];
    }

    return len;
}
