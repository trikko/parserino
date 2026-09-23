module parserino.lexbor.core.array;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- array.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lexbor_array_t {
    void** list;
    size_t size;
    size_t length;
}











/*
 * Inline functions
 */
 void* lexbor_array_get(lexbor_array_t* array, size_t idx)
{
    if (idx >= array.length) {
        return null;
    }

    return array.list[idx];
}

 size_t lexbor_array_length(lexbor_array_t* array)
{
    return array.length;
}

 size_t lexbor_array_size(lexbor_array_t* array)
{
    return array.size;
}

/*
 * No inline functions for ABI.
 */



// ---- array.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lexbor_array_t* lexbor_array_create()
{
    return cast(lexbor_array_t*) lexbor_calloc(1, lexbor_array_t.sizeof);
}

lxb_status_t lexbor_array_init(lexbor_array_t* array, size_t size)
{
    if (array == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    if (size == 0) {
        return LXB_STATUS_ERROR_TOO_SMALL_SIZE;
    }

    array.length = 0;
    array.size = size;

    array.list = cast(void**) lexbor_malloc((void*).sizeof * size);
    if (array.list == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    return LXB_STATUS_OK;
}

void lexbor_array_clean(lexbor_array_t* array)
{
    if (array != null) {
        array.length = 0;
    }
}

lexbor_array_t* lexbor_array_destroy(lexbor_array_t* array, bool self_destroy)
{
    if (array == null)
        return null;

    if (array.list) {
        array.length = 0;
        array.size = 0;
        array.list = cast(void**) lexbor_free(array.list);
    }

    if (self_destroy) {
        return cast(lexbor_array_t*) lexbor_free(array);
    }

    return array;
}

void** lexbor_array_expand(lexbor_array_t* array, size_t up_to)
{
    void** list = void;
    size_t new_size = void;

    if (array.length > (SIZE_MAX - up_to))
        return null;

    new_size = array.length + up_to;
    list = cast(void**) lexbor_realloc(array.list, (void*).sizeof * new_size);

    if (list == null)
        return null;

    array.list = list;
    array.size = new_size;

    return list;
}

lxb_status_t lexbor_array_push(lexbor_array_t* array, void* value)
{
    if (array.length >= array.size) {
        if ((lexbor_array_expand(array, 128) == null)) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    array.list[ array.length ] = value;
    array.length++;

    return LXB_STATUS_OK;
}

void* lexbor_array_pop(lexbor_array_t* array)
{
    if (array.length == 0) {
        return null;
    }

    array.length--;
    return array.list[ array.length ];
}

lxb_status_t lexbor_array_insert(lexbor_array_t* array, size_t idx, void* value)
{
    if (idx >= array.length) {
        size_t up_to = (idx - array.length) + 1;

        if (idx >= array.size) {
            if ((lexbor_array_expand(array, up_to) == null)) {
                return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            }
        }

        memset(&array.list[array.length], 0, (void*).sizeof * up_to);

        array.list[ idx ] = value;
        array.length += up_to;

        return LXB_STATUS_OK;
    }

    if (array.length >= array.size) {
        if ((lexbor_array_expand(array, 32) == null)) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }
    }

    memmove(&array.list[idx + 1], &array.list[idx],
            (void*).sizeof * (array.length - idx));

    array.list[ idx ] = value;
    array.length++;

    return LXB_STATUS_OK;
}

lxb_status_t lexbor_array_set(lexbor_array_t* array, size_t idx, void* value)
{
    if (idx >= array.length) {
        size_t up_to = (idx - array.length) + 1;

        if (idx >= array.size) {
            if ((lexbor_array_expand(array, up_to) == null)) {
                return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
            }
        }

        memset(&array.list[array.length], 0, (void*).sizeof * up_to);

        array.length += up_to;
    }

    array.list[idx] = value;

    return LXB_STATUS_OK;
}

void lexbor_array_delete(lexbor_array_t* array, size_t begin, size_t length)
{
    if (begin >= array.length || length == 0) {
        return;
    }

    size_t end_len = begin + length;

    if (end_len >= array.length) {
        array.length = begin;
        return;
    }

    memmove(&array.list[begin], &array.list[end_len],
            (void*).sizeof * (array.length - end_len));

    array.length -= length;
}

/*
 * No inline functions.
 */
void* lexbor_array_get_noi(lexbor_array_t* array, size_t idx)
{
    return lexbor_array_get(array, idx);
}

size_t lexbor_array_length_noi(lexbor_array_t* array)
{
    return lexbor_array_length(array);
}

size_t lexbor_array_size_noi(lexbor_array_t* array)
{
    return lexbor_array_size(array);
}
