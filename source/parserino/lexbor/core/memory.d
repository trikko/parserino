module parserino.lexbor.core.memory;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- memory.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

private lexbor_memory_malloc_f lexbor_memory_malloc = &malloc;
private lexbor_memory_realloc_f lexbor_memory_realloc = &realloc;
private lexbor_memory_calloc_f lexbor_memory_calloc = &calloc;
private lexbor_memory_free_f lexbor_memory_free = &free;

void* lexbor_malloc(size_t size)
{
    return lexbor_memory_malloc(size);
}

void* lexbor_realloc(void* dst, size_t size)
{
    return lexbor_memory_realloc(dst, size);
}

void* lexbor_calloc(size_t num, size_t size)
{
    return lexbor_memory_calloc(num, size);
}

void* lexbor_free(void* dst)
{
    lexbor_memory_free(dst);
    return null;
}

lxb_status_t lexbor_memory_setup(lexbor_memory_malloc_f new_malloc, lexbor_memory_realloc_f new_realloc, lexbor_memory_calloc_f new_calloc, lexbor_memory_free_f new_free)
{
    if (new_malloc == null || new_realloc == null || new_calloc == null || new_free == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    lexbor_memory_malloc = new_malloc;
    lexbor_memory_realloc = new_realloc;
    lexbor_memory_calloc = new_calloc;
    lexbor_memory_free = new_free;

    return LXB_STATUS_OK;
}
