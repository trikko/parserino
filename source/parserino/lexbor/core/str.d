module parserino.lexbor.core.str;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.core.mraw;
public import parserino.lexbor.core.utils;
import parserino.lexbor.core.str_res;

extern(C) @nogc nothrow:
__gshared:

// ---- str.h ----
/*
 * Copyright (C) 2018-2023 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lexbor_str_t {
    lxb_char_t* data;
    size_t length;
}









/* Append */





/* Other functions */








/* Data utils */
/*
 * [in] first: must be null-terminated
 * [in] sec: no matter what data
 * [in] sec_size: size of the 'sec' buffer
 *
 * Function compare two lxb_char_t data until find '\0' in first arg.
 * Successfully if the function returned a pointer starting with '\0',
 * otherwise, if the data of the second buffer is insufficient function returned
 * position in first buffer.
 * If function returns NULL, the data are not equal.
 */








/*
 * Inline functions
 */
 lxb_char_t* lexbor_str_data(lexbor_str_t* str)
{
    return str.data;
}

 size_t lexbor_str_length(lexbor_str_t* str)
{
    return str.length;
}

 size_t lexbor_str_size(lexbor_str_t* str)
{
    return lexbor_mraw_data_size(str.data);
}

 void lexbor_str_data_set(lexbor_str_t* str, lxb_char_t* data)
{
    str.data = data;
}

 lxb_char_t* lexbor_str_length_set(lexbor_str_t* str, lexbor_mraw_t* mraw, size_t length)
{
    if (length >= lexbor_str_size(str)) {
        lxb_char_t* tmp = void;

        tmp = lexbor_str_realloc(str, mraw, length + 1);
        if (tmp == null) {
            return null;
        }
    }

    str.length = length;
    str.data[length] = 0x00;

    return str.data;
}

/*
 * No inline functions for ABI.
 */





// ---- str.c ----
/*
 * Copyright (C) 2018-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lexbor_str_t* lexbor_str_create()
{
    return cast(lexbor_str_t*) lexbor_calloc(1, lexbor_str_t.sizeof);
}

lxb_char_t* lexbor_str_init(lexbor_str_t* str, lexbor_mraw_t* mraw, size_t size)
{
    if (str == null) {
        return null;
    }

    str.data = cast(ubyte*) lexbor_mraw_alloc(mraw, (size + 1));
    str.length = 0;

    if (str.data != null) {
        *str.data = '\0';
    }

    return str.data;
}

lxb_char_t* lexbor_str_init_append(lexbor_str_t* str, lexbor_mraw_t* mraw, const(lxb_char_t)* data, size_t length)
{
    lxb_char_t* p = void;

    if (str == null) {
        return null;
    }

    p = cast(ubyte*) lexbor_mraw_alloc(mraw, (length + 1));
    if (p == null) {
        return null;
    }

    memcpy(p, data, length);

    p[length] = '\0';

    str.data = p;
    str.length = length;

    return p;
}

void lexbor_str_clean(lexbor_str_t* str)
{
    str.length = 0;
}

void lexbor_str_clean_all(lexbor_str_t* str)
{
    memset(str, 0, lexbor_str_t.sizeof);
}

lexbor_str_t* lexbor_str_destroy(lexbor_str_t* str, lexbor_mraw_t* mraw, bool destroy_obj)
{
    if (str == null) {
        return null;
    }

    if (str.data != null) {
        lexbor_str_clean(str);
        str.data = cast(ubyte*) lexbor_mraw_free(mraw, str.data);
    }

    if (destroy_obj) {
        return cast(lexbor_str_t*) lexbor_free(str);
    }

    return str;
}

lxb_char_t* lexbor_str_realloc(lexbor_str_t* str, lexbor_mraw_t* mraw, size_t new_size)
{
    lxb_char_t* tmp = cast(ubyte*) lexbor_mraw_realloc(mraw, str.data, new_size);
    if (tmp == null) {
        return null;
    }

    str.data = tmp;

    return tmp;
}

lxb_char_t* lexbor_str_check_size(lexbor_str_t* str, lexbor_mraw_t* mraw, size_t plus_len)
{
    lxb_char_t* tmp = void;

    if (str.length > (SIZE_MAX - plus_len)) {
        return null;
    }

    if ((str.length + plus_len) <= lexbor_str_size(str)) {
        return str.data;
    }

    tmp = cast(ubyte*) lexbor_mraw_realloc(mraw, str.data, (str.length + plus_len));
    if (tmp == null) {
        return null;
    }

    str.data = tmp;

    return tmp;
}

/* Append API */
lxb_char_t* lexbor_str_append(lexbor_str_t* str, lexbor_mraw_t* mraw, const(lxb_char_t)* buff, size_t length)
{
    lxb_char_t* data_begin = void;

    if (length == 0) {
        return str.data;
    }

    do { void* tmp = void; if (str.length > (SIZE_MAX - ((length + 1)))) return (null); if ((str.length + ((length + 1))) > (lexbor_str_size(str))) { tmp = lexbor_mraw_realloc(mraw, str.data, (str.length + (length + 1))); if (tmp == null) { return (null); } str.data = cast(lxb_char_t*) tmp; } } while (0)
                                                         ;

    data_begin = &str.data[str.length];
    memcpy(data_begin, buff, lxb_char_t.sizeof * length);

    str.length += length;
    str.data[str.length] = '\0';

    return data_begin;
}

lxb_char_t* lexbor_str_append_before(lexbor_str_t* str, lexbor_mraw_t* mraw, const(lxb_char_t)* buff, size_t length)
{
    lxb_char_t* data_begin = void;

    do { void* tmp = void; if (str.length > (SIZE_MAX - ((length + 1)))) return (null); if ((str.length + ((length + 1))) > (lexbor_str_size(str))) { tmp = lexbor_mraw_realloc(mraw, str.data, (str.length + (length + 1))); if (tmp == null) { return (null); } str.data = cast(lxb_char_t*) tmp; } } while (0)
                                                         ;

    data_begin = &str.data[str.length];

    memmove(&str.data[length], str.data, lxb_char_t.sizeof * str.length);
    memcpy(str.data, buff, lxb_char_t.sizeof * length);

    str.length += length;
    str.data[str.length] = '\0';

    return data_begin;
}

lxb_char_t* lexbor_str_append_one(lexbor_str_t* str, lexbor_mraw_t* mraw, const(lxb_char_t) data)
{
    do { void* tmp = void; if (str.length > (SIZE_MAX - (2))) return (null); if ((str.length + (2)) > (lexbor_str_size(str))) { tmp = lexbor_mraw_realloc(mraw, str.data, (str.length + 2)); if (tmp == null) { return (null); } str.data = cast(lxb_char_t*) tmp; } } while (0);

    str.data[str.length] = data;

    str.length += 1;
    str.data[str.length] = '\0';

    return &str.data[(str.length - 1)];
}

lxb_char_t* lexbor_str_append_lowercase(lexbor_str_t* str, lexbor_mraw_t* mraw, const(lxb_char_t)* data, size_t length)
{
    size_t i = void;
    lxb_char_t* data_begin = void;

    do { void* tmp = void; if (str.length > (SIZE_MAX - ((length + 1)))) return (null); if ((str.length + ((length + 1))) > (lexbor_str_size(str))) { tmp = lexbor_mraw_realloc(mraw, str.data, (str.length + (length + 1))); if (tmp == null) { return (null); } str.data = cast(lxb_char_t*) tmp; } } while (0)
                                                         ;

    data_begin = &str.data[str.length];

    for (i = 0; i < length; i++) {
        data_begin[i] = lexbor_str_res_map_lowercase[ data[i] ];
    }

    data_begin[i] = '\0';
    str.length += length;

    return data_begin;
}

lxb_char_t* lexbor_str_append_with_rep_null_chars(lexbor_str_t* str, lexbor_mraw_t* mraw, const(lxb_char_t)* buff, size_t length)
{
    const(lxb_char_t)* pos = void, res = void, end = void;
    size_t current_len = str.length;

    do { void* tmp = void; if (str.length > (SIZE_MAX - ((length + 1)))) return (null); if ((str.length + ((length + 1))) > (lexbor_str_size(str))) { tmp = lexbor_mraw_realloc(mraw, str.data, (str.length + (length + 1))); if (tmp == null) { return (null); } str.data = cast(lxb_char_t*) tmp; } } while (0)
                                                         ;
    end = buff + length;

    while (buff != end) {
        pos = cast(const(ubyte)*) memchr(buff, '\0', lxb_char_t.sizeof * (end - buff));
        if (pos == null) {
            break;
        }

        res = lexbor_str_append(str, mraw, buff, (pos - buff));
        if (res == null) {
            return null;
        }

        res = lexbor_str_append(str, mraw,
                         lexbor_str_res_ansi_replacement_character.ptr,
                         lexbor_str_res_ansi_replacement_character.sizeof - 1);
        if (res == null) {
            return null;
        }

        buff = pos + 1;
    }

    if (buff != end) {
        res = lexbor_str_append(str, mraw, buff, (end - buff));
        if (res == null) {
            return null;
        }
    }

    return &str.data[current_len];
}

lxb_char_t* lexbor_str_copy(lexbor_str_t* dest, const(lexbor_str_t)* target, lexbor_mraw_t* mraw)
{
    if (target.data == null) {
        return null;
    }

    if (dest.data == null) {
        lexbor_str_init(dest, mraw, target.length);

        if (dest.data == null) {
            return null;
        }
    }

    return lexbor_str_append(dest, mraw, target.data, target.length);
}

void lexbor_str_stay_only_whitespace(lexbor_str_t* target)
{
    size_t i = void, pos = 0;
    lxb_char_t* data = target.data;

    for (i = 0; i < target.length; i++) {
        if ((data[i] == ' ' || data[i] == '\t' || data[i] == '\n' || data[i] == '\f' || data[i] == '\r')) {
            data[pos] = data[i];
            pos++;
        }
    }

    target.length = pos;
}

void lexbor_str_strip_collapse_whitespace(lexbor_str_t* target)
{
    size_t i = void, offset = void, ws_i = void;
    lxb_char_t* data = target.data;

    if (target.length == 0) {
        return;
    }

    if ((*data == ' ' || *data == '\t' || *data == '\n' || *data == '\f' || *data == '\r')) {
        *data = 0x20;
    }

    for (i = 0, offset = 0, ws_i = 0; i < target.length; i++)
    {
        if ((data[i] == ' ' || data[i] == '\t' || data[i] == '\n' || data[i] == '\f' || data[i] == '\r')) {
            if (data[ws_i] != 0x20) {
                data[offset] = 0x20;

                ws_i = offset;
                offset++;
            }
        }
        else {
            if (data[ws_i] == 0x20) {
                ws_i = offset;
            }

            data[offset] = data[i];
            offset++;
        }
    }

    if (offset != i) {
        if (offset != 0) {
            if (data[offset - 1] == 0x20) {
                offset--;
            }
        }

        data[offset] = 0x00;
        target.length = offset;
    }
}

size_t lexbor_str_crop_whitespace_from_begin(lexbor_str_t* target)
{
    size_t i = void;
    lxb_char_t* data = target.data;

    for (i = 0; i < target.length; i++) {
        if ((data[i] != ' ' && data[i] != '\t' && data[i] != '\n' && data[i] != '\f' && data[i] != '\r')) {
            break;
        }
    }

    if (i != 0 && i != target.length) {
        memmove(target.data, &target.data[i], (target.length - i));
    }

    target.length -= i;
    return i;
}

size_t lexbor_str_whitespace_from_begin(lexbor_str_t* target)
{
    size_t i = void;
    lxb_char_t* data = target.data;

    for (i = 0; i < target.length; i++) {
        if ((data[i] != ' ' && data[i] != '\t' && data[i] != '\n' && data[i] != '\f' && data[i] != '\r')) {
            break;
        }
    }

    return i;
}

size_t lexbor_str_whitespace_from_end(lexbor_str_t* target)
{
    size_t i = target.length;
    lxb_char_t* data = target.data;

    while (i) {
        i--;

        if ((data[i] != ' ' && data[i] != '\t' && data[i] != '\n' && data[i] != '\f' && data[i] != '\r')) {
            return target.length - (i + 1);
        }
    }

    return 0;
}

lxb_char_t* lexbor_str_copy_to(lexbor_str_t* str, const(lxb_char_t)* buff, size_t length)
{
    lxb_char_t* data_begin = void;

    data_begin = &str.data[str.length];
    memcpy(data_begin, buff, lxb_char_t.sizeof * length);

    str.length += length;

    return data_begin;
}

lxb_char_t* lexbor_str_copy_to_with_null(lexbor_str_t* str, const(lxb_char_t)* buff, size_t length)
{
    lxb_char_t* data_begin = lexbor_str_copy_to(str, buff, length);

    str.data[str.length] = '\0';

    return data_begin;
}

/*
 * Data utils
 * TODO: All functions need optimization.
 */
const(lxb_char_t)* lexbor_str_data_ncasecmp_first(const(lxb_char_t)* first, const(lxb_char_t)* sec, size_t sec_size)
{
    size_t i = void;

    for (i = 0; i < sec_size; i++) {
        if (first[i] == '\0') {
            return &first[i];
        }

        if (lexbor_str_res_map_lowercase[ first[i] ]
            != lexbor_str_res_map_lowercase[ sec[i] ])
        {
            return null;
        }
    }

    return &first[i];
}

bool lexbor_str_data_ncasecmp_end(const(lxb_char_t)* first, const(lxb_char_t)* sec, size_t size)
{
    while (size != 0) {
        size--;

        if (lexbor_str_res_map_lowercase[ first[size] ]
            != lexbor_str_res_map_lowercase[ sec[size] ])
        {
            return false;
        }
    }

    return true;
}

bool lexbor_str_data_ncasecmp_contain(const(lxb_char_t)* where, size_t where_size, const(lxb_char_t)* what, size_t what_size)
{
    for (size_t i = 0; what_size <= (where_size - i); i++) {
        if(lexbor_str_data_ncasecmp(&where[i], what, what_size)) {
            return true;
        }
    }

    return false;
}

bool lexbor_str_data_ncasecmp(const(lxb_char_t)* first, const(lxb_char_t)* sec, size_t size)
{
    for (size_t i = 0; i < size; i++) {
        if (lexbor_str_res_map_lowercase[ first[i] ]
            != lexbor_str_res_map_lowercase[ sec[i] ])
        {
            return false;
        }
    }

    return true;
}

bool lexbor_str_data_nlocmp_right(const(lxb_char_t)* first, const(lxb_char_t)* sec, size_t size)
{
    for (size_t i = 0; i < size; i++) {
        if (first[i] != lexbor_str_res_map_lowercase[ sec[i] ]) {
            return false;
        }
    }

    return true;
}

bool lexbor_str_data_nupcmp_right(const(lxb_char_t)* first, const(lxb_char_t)* sec, size_t size)
{
    for (size_t i = 0; i < size; i++) {
        if (first[i] != lexbor_str_res_map_uppercase[ sec[i] ]) {
            return false;
        }
    }

    return true;
}

bool lexbor_str_data_casecmp(const(lxb_char_t)* first, const(lxb_char_t)* sec)
{
    for (;;) {
        if (lexbor_str_res_map_lowercase[*first]
            != lexbor_str_res_map_lowercase[*sec])
        {
            return false;
        }

        if (*first == '\0') {
            return true;
        }

        first++;
        sec++;
    }
}

bool lexbor_str_data_ncmp_end(const(lxb_char_t)* first, const(lxb_char_t)* sec, size_t size)
{
    while (size != 0) {
        size--;

        if (first[size] != sec[size]) {
            return false;
        }
    }

    return true;
}

bool lexbor_str_data_ncmp_contain(const(lxb_char_t)* where, size_t where_size, const(lxb_char_t)* what, size_t what_size)
{
    for (size_t i = 0; what_size <= (where_size - i); i++) {
        if(memcmp(&where[i], what, lxb_char_t.sizeof * what_size) == 0) {
            return true;
        }
    }

    return false;
}

bool lexbor_str_data_ncmp(const(lxb_char_t)* first, const(lxb_char_t)* sec, size_t size)
{
    return memcmp(first, sec, lxb_char_t.sizeof * size) == 0;
}

bool lexbor_str_data_cmp(const(lxb_char_t)* first, const(lxb_char_t)* sec)
{
    for (;;) {
        if (*first != *sec) {
            return false;
        }

        if (*first == '\0') {
            return true;
        }

        first++;
        sec++;
    }
}

bool lexbor_str_data_cmp_ws(const(lxb_char_t)* first, const(lxb_char_t)* sec)
{
    for (;;) {
        if (*first != *sec) {
            return false;
        }

        if ((*first == ' ' || *first == '\t' || *first == '\n' || *first == '\f' || *first == '\r') || *first == '\0') {
            return true;
        }

        first++;
        sec++;
    }
}

void lexbor_str_data_to_lowercase(lxb_char_t* to, const(lxb_char_t)* from, size_t len)
{
    while (len) {
        len--;

        to[len] = lexbor_str_res_map_lowercase[ from[len] ];
    }
}

void lexbor_str_data_to_uppercase(lxb_char_t* to, const(lxb_char_t)* from, size_t len)
{
    while (len) {
        len--;

        to[len] = lexbor_str_res_map_uppercase[ from[len] ];
    }
}

const(lxb_char_t)* lexbor_str_data_find_lowercase(const(lxb_char_t)* data, size_t len)
{
    while (len) {
        len--;

        if (data[len] == lexbor_str_res_map_lowercase[ data[len] ]) {
            return &data[len];
        }
    }

    return null;
}

const(lxb_char_t)* lexbor_str_data_find_uppercase(const(lxb_char_t)* data, size_t len)
{
    while (len) {
        len--;

        if (data[len] == lexbor_str_res_map_uppercase[ data[len] ]) {
            return &data[len];
        }
    }

    return null;
}

/*
 * No inline functions for ABI.
 */
lxb_char_t* lexbor_str_data_noi(lexbor_str_t* str)
{
    return lexbor_str_data(str);
}

size_t lexbor_str_length_noi(lexbor_str_t* str)
{
    return lexbor_str_length(str);
}

size_t lexbor_str_size_noi(lexbor_str_t* str)
{
    return lexbor_str_size(str);
}

void lexbor_str_data_set_noi(lexbor_str_t* str, lxb_char_t* data)
{
    lexbor_str_data_set(str, data);
}

lxb_char_t* lexbor_str_length_set_noi(lexbor_str_t* str, lexbor_mraw_t* mraw, size_t length)
{
    return lexbor_str_length_set(str, mraw, length);
}
