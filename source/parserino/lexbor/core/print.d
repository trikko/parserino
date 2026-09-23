module parserino.lexbor.core.print;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import core.stdc.stdarg;
public import parserino.lexbor.core.base;
import parserino.lexbor.core.str;

extern(C) @nogc nothrow:
__gshared:

// ---- print.h ----
/*
 * Copyright (C) 2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum size_t LXB_PRINT_ERROR = cast(size_t) -1;





// ---- print.c ----
/*
 * Copyright (C) 2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

size_t lexbor_printf_size(const(char)* format, ...)
{
    size_t ret = void;
    va_list va = void;

    va_start(va, format);
    ret = lexbor_vprintf_size(format, va);
    va_end(va);

    return ret;
}

size_t lexbor_vprintf_size(const(char)* format, va_list va)
{
    char c = void;
    const(char)* begin = void, cdata = void;
    size_t size = void;
    lexbor_str_t* str = void;

    begin = format;
    size = 0;

    while (true) {
        c = *format;

        if (c == '%') {
            c = format[1];

            switch (c) {
                case '\0':
                    return size + (format - begin) + 1;

                case 's':
                    cdata = va_arg!(const(char)*)(va);
                    size += (format - begin) + strlen(cdata);
                    break;

                case 'S':
                    str = va_arg!(lexbor_str_t*)(va);
                    size += (format - begin) + str.length;
                    break;

                case '%':
                    size += (format - begin) + 1;
                    break;

                default:
                    return LXB_PRINT_ERROR;
            }

            format++;
            begin = format + 1;
        }
        else if (c == '\0') {
            return size + (format - begin);
        }

        format++;
    }
}

size_t lexbor_sprintf(lxb_char_t* dst, size_t size, const(char)* format, ...)
{
    size_t ret = void;
    va_list va = void;

    va_start(va, format);
    ret = lexbor_vsprintf(dst, size, format, va);
    va_end(va);

    return ret;
}

size_t lexbor_vsprintf(lxb_char_t* dst, size_t size, const(char)* format, va_list va)
{
    char c = void;
    const(char)* begin = void, cdata = void;
    lxb_char_t* end = void, start = void;
    lexbor_str_t* str = void;

    begin = format;
    start = dst;
    end = dst + size;

    while (true) {
        c = *format;

        if (c == '%') {
            c = format[1];

            switch (c) {
                case '\0':
                    size = (format - begin) + 1;
                    do { if (cast(size_t) ((end) - (dst)) < (size)) { return (end) - (dst); } memcpy((dst), (begin), (size)); (dst) += (size); } while (false);
                    goto done;

                case 's':
                    size = format - begin;
                    do { if (cast(size_t) ((end) - (dst)) < (size)) { return (end) - (dst); } memcpy((dst), (begin), (size)); (dst) += (size); } while (false);

                    cdata = va_arg!(const(char)*)(va);
                    size = strlen(cdata);
                    do { if (cast(size_t) ((end) - (dst)) < (size)) { return (end) - (dst); } memcpy((dst), (cdata), (size)); (dst) += (size); } while (false);
                    break;

                case 'S':
                    size = format - begin;
                    do { if (cast(size_t) ((end) - (dst)) < (size)) { return (end) - (dst); } memcpy((dst), (begin), (size)); (dst) += (size); } while (false);

                    str = va_arg!(lexbor_str_t*)(va);
                    do { if (cast(size_t) ((end) - (dst)) < (str.length)) { return (end) - (dst); } memcpy((dst), (str.data), (str.length)); (dst) += (str.length); } while (false);
                    break;

                case '%':
                    size = (format - begin) + 1;
                    do { if (cast(size_t) ((end) - (dst)) < (size)) { return (end) - (dst); } memcpy((dst), (begin), (size)); (dst) += (size); } while (false);
                    break;

                default:
                    return LXB_PRINT_ERROR;
            }

            format++;
            begin = format + 1;
        }
        else if (c == '\0') {
            size = format - begin;
            do { if (cast(size_t) ((end) - (dst)) < (size)) { return (end) - (dst); } memcpy((dst), (begin), (size)); (dst) += (size); } while (false);
            goto done;
        }

        format++;
    }

done:

    if (end - dst > 0) {
        *dst = '\0';
    }

    return dst - start;
}
