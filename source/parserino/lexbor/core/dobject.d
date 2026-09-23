module parserino.lexbor.core.dobject;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.core.mem;
public import parserino.lexbor.core.array;

extern(C) @nogc nothrow:
__gshared:

// ---- dobject.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lexbor_dobject_t {
    lexbor_mem_t* mem;
    lexbor_array_t* cache;

    size_t allocated;
    size_t struct_size;
}





 ubyte* lexbor_dobject_init_list_entries(lexbor_dobject_t* dobject, size_t pos);





/*
 * Inline functions
 */
 size_t lexbor_dobject_allocated(lexbor_dobject_t* dobject)
{
    return dobject.allocated;
}

 size_t lexbor_dobject_cache_length(lexbor_dobject_t* dobject)
{
    return lexbor_array_length(dobject.cache);
}

/*
 * No inline functions for ABI.
 */


// ---- dobject.c ----
/*
 * Copyright (C) 2018-2019 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lexbor_dobject_t* lexbor_dobject_create()
{
    return cast(lexbor_dobject_t*) lexbor_calloc(1, lexbor_dobject_t.sizeof);
}

lxb_status_t lexbor_dobject_init(lexbor_dobject_t* dobject, size_t chunk_size, size_t struct_size)
{
    lxb_status_t status = void;

    if (dobject == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    if (chunk_size == 0 || struct_size == 0) {
        return LXB_STATUS_ERROR_WRONG_ARGS;
    }

    /* Set params */
    dobject.allocated = 0UL;
    dobject.struct_size = struct_size;

    /* Init memory */
    dobject.mem = lexbor_mem_create();

    status = lexbor_mem_init(dobject.mem,
                           lexbor_mem_align(chunk_size * dobject.struct_size));
    if (status) {
        return status;
    }

    /* Array */
    dobject.cache = lexbor_array_create();

    status = lexbor_array_init(dobject.cache, chunk_size);
    if (status)
        return status;

    return LXB_STATUS_OK;
}

void lexbor_dobject_clean(lexbor_dobject_t* dobject)
{
    if (dobject != null) {
        dobject.allocated = 0UL;

        lexbor_mem_clean(dobject.mem);
        lexbor_array_clean(dobject.cache);
    }
}

lexbor_dobject_t* lexbor_dobject_destroy(lexbor_dobject_t* dobject, bool destroy_self)
{
    if (dobject == null)
        return null;

    dobject.mem = lexbor_mem_destroy(dobject.mem, true);
    dobject.cache = lexbor_array_destroy(dobject.cache, true);

    if (destroy_self == true) {
        return cast(lexbor_dobject_t*) lexbor_free(dobject);
    }

    return dobject;
}

void* lexbor_dobject_alloc(lexbor_dobject_t* dobject)
{
    void* data = void;

    if (lexbor_array_length(dobject.cache) != 0) {
        dobject.allocated++;

        return lexbor_array_pop(dobject.cache);

    }

    data = lexbor_mem_alloc(dobject.mem, dobject.struct_size);
    if (data == null) {
        return null;
    }

    dobject.allocated++;

    return data;
}

void* lexbor_dobject_calloc(lexbor_dobject_t* dobject)
{
    void* data = lexbor_dobject_alloc(dobject);

    if (data != null) {
        memset(data, 0, dobject.struct_size);
    }

    return data;
}

void* lexbor_dobject_free(lexbor_dobject_t* dobject, void* data)
{
    if (data == null) {
        return null;
    }

    if (lexbor_array_push(dobject.cache, data) == LXB_STATUS_OK) {
        dobject.allocated--;
        return null;
    }

    return data;
}

void* lexbor_dobject_by_absolute_position(lexbor_dobject_t* dobject, size_t pos)
{
    size_t chunk_idx = void, chunk_pos = void, i = void;
    lexbor_mem_chunk_t* chunk = void;

    if (pos >= dobject.allocated) {
        return null;
    }

    chunk = dobject.mem.chunk_first;
    chunk_pos = pos * dobject.struct_size;
    chunk_idx = chunk_pos / dobject.mem.chunk_min_size;

    for (i = 0; i < chunk_idx; i++) {
        chunk = chunk.next;
    }

    return &chunk.data[chunk_pos % chunk.size];
}

/*
 * No inline functions for ABI.
 */
size_t lexbor_dobject_allocated_noi(lexbor_dobject_t* dobject)
{
    return lexbor_dobject_allocated(dobject);
}

size_t lexbor_dobject_cache_length_noi(lexbor_dobject_t* dobject)
{
    return lexbor_dobject_cache_length(dobject);
}
