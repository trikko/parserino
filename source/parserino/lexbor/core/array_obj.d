module parserino.lexbor.core.array_obj;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- array_obj.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lexbor_array_obj_t {
    ubyte* list;
    size_t size;
    size_t length;
    size_t struct_size;
}











/*
 * Inline functions
 */
 void lexbor_array_obj_erase(lexbor_array_obj_t* array)
{
    memset(array, 0, lexbor_array_obj_t.sizeof);
}

 void* lexbor_array_obj_get(const(lexbor_array_obj_t)* array, size_t idx)
{
    if (idx >= array.length) {
        return null;
    }

    return cast(void*) (array.list + (idx * array.struct_size));
}

 size_t lexbor_array_obj_length(lexbor_array_obj_t* array)
{
    return array.length;
}

 size_t lexbor_array_obj_size(lexbor_array_obj_t* array)
{
    return array.size;
}

 size_t lexbor_array_obj_struct_size(lexbor_array_obj_t* array)
{
    return array.struct_size;
}

 void* lexbor_array_obj_last(lexbor_array_obj_t* array)
{
    if (array.length == 0) {
        return null;
    }

    return array.list + ((array.length - 1) * array.struct_size);
}

/*
 * No inline functions for ABI.
 */






// ---- array_obj.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lexbor_array_obj_t* lexbor_array_obj_create()
{
    return cast(lexbor_array_obj_t*) lexbor_calloc(1, lexbor_array_obj_t.sizeof);
}

lxb_status_t lexbor_array_obj_init(lexbor_array_obj_t* array, size_t size, size_t struct_size)
{
    if (array == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    if (size == 0 || struct_size == 0) {
        return LXB_STATUS_ERROR_TOO_SMALL_SIZE;
    }

    array.length = 0;
    array.size = size;
    array.struct_size = struct_size;

    array.list = cast(ubyte*) lexbor_malloc((ubyte*).sizeof * (array.size * struct_size));
    if (array.list == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    return LXB_STATUS_OK;
}

void lexbor_array_obj_clean(lexbor_array_obj_t* array)
{
    if (array != null) {
        array.length = 0;
    }
}

lexbor_array_obj_t* lexbor_array_obj_destroy(lexbor_array_obj_t* array, bool self_destroy)
{
    if (array == null)
        return null;

    if (array.list) {
        array.length = 0;
        array.size = 0;
        array.list = cast(ubyte*) lexbor_free(array.list);
    }

    if (self_destroy) {
        return cast(lexbor_array_obj_t*) lexbor_free(array);
    }

    return array;
}

ubyte* lexbor_array_obj_expand(lexbor_array_obj_t* array, size_t up_to)
{
    ubyte* list = void;
    size_t new_size = void;

    if (array.length > (SIZE_MAX - up_to)) {
        return null;
    }

    new_size = array.length + up_to;

    list = cast(ubyte*) lexbor_realloc(array.list, (ubyte*).sizeof * (new_size * array.struct_size));
    if (list == null) {
        return null;
    }

    array.list = list;
    array.size = new_size;

    return list;
}

void* lexbor_array_obj_push(lexbor_array_obj_t* array)
{
    void* entry = void;

    if (array.length >= array.size)
    {
        if ((lexbor_array_obj_expand(array, 128) == null)) {
            return null;
        }
    }

    entry = array.list + (array.length * array.struct_size);
    array.length++;

    memset(entry, 0, array.struct_size);

    return entry;
}

void* lexbor_array_obj_push_wo_cls(lexbor_array_obj_t* array)
{
    void* entry = void;

    if (array.length >= array.size) {
        if ((lexbor_array_obj_expand(array, 128) == null)) {
            return null;
        }
    }

    entry = array.list + (array.length * array.struct_size);
    array.length++;

    return entry;
}

void* lexbor_array_obj_push_n(lexbor_array_obj_t* array, size_t count)
{
    void* entry = void;

    if ((array.length + count) > array.size) {
        if ((lexbor_array_obj_expand(array, count + 128) == null)) {
            return null;
        }
    }

    entry = array.list + (array.length * array.struct_size);
    array.length += count;

    return entry;
}

void* lexbor_array_obj_pop(lexbor_array_obj_t* array)
{
    if (array.length == 0) {
        return null;
    }

    array.length--;
    return array.list + (array.length * array.struct_size);
}

void lexbor_array_obj_delete(lexbor_array_obj_t* array, size_t begin, size_t length)
{
    if (begin >= array.length || length == 0) {
        return;
    }

    size_t end_len = begin + length;

    if (end_len >= array.length) {
        array.length = begin;
        return;
    }

    memmove(&array.list[ begin * array.struct_size ],
            &array.list[ end_len * array.struct_size ],
            (ubyte*).sizeof * ((array.length - end_len) * array.struct_size));

    array.length -= length;
}

/*
 * No inline functions.
 */
void lexbor_array_obj_erase_noi(lexbor_array_obj_t* array)
{
    lexbor_array_obj_erase(array);
}

void* lexbor_array_obj_get_noi(lexbor_array_obj_t* array, size_t idx)
{
    return lexbor_array_obj_get(array, idx);
}

size_t lexbor_array_obj_length_noi(lexbor_array_obj_t* array)
{
    return lexbor_array_obj_length(array);
}

size_t lexbor_array_obj_size_noi(lexbor_array_obj_t* array)
{
    return lexbor_array_obj_size(array);
}

size_t lexbor_array_obj_struct_size_noi(lexbor_array_obj_t* array)
{
    return lexbor_array_obj_struct_size(array);
}

void* lexbor_array_obj_last_noi(lexbor_array_obj_t* array)
{
    return lexbor_array_obj_last(array);
}
