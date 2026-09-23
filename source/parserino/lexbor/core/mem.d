module parserino.lexbor.core.mem;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import core.stdc.string;
public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- mem.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lexbor_mem_chunk_t = lexbor_mem_chunk;
alias lexbor_mem_t = lexbor_mem;

struct lexbor_mem_chunk {
    ubyte* data;
    size_t length;
    size_t size;

    lexbor_mem_chunk_t* next;
    lexbor_mem_chunk_t* prev;
}

struct lexbor_mem {
    lexbor_mem_chunk_t* chunk;
    lexbor_mem_chunk_t* chunk_first;

    size_t chunk_min_size;
    size_t chunk_length;
}





/*
 * The memory allocated in lexbor_mem_chunk_* functions needs to be freed
 * by lexbor_mem_chunk_destroy function.
 *
 * This memory will not be automatically freed by a function lexbor_mem_destroy.
 */



/*
 * The memory allocated in lexbor_mem_alloc and lexbor_mem_calloc function
 * will be freeds after calling lexbor_mem_destroy function.
 */


/*
 * Inline functions
 */
 size_t lexbor_mem_current_length(lexbor_mem_t* mem)
{
    return mem.chunk.length;
}

 size_t lexbor_mem_current_size(lexbor_mem_t* mem)
{
    return mem.chunk.size;
}

 size_t lexbor_mem_chunk_length(lexbor_mem_t* mem)
{
    return mem.chunk_length;
}

 size_t lexbor_mem_align(size_t size)
{
    return ((size % LEXBOR_MEM_ALIGN_STEP) != 0)
           ? size + (LEXBOR_MEM_ALIGN_STEP - (size % LEXBOR_MEM_ALIGN_STEP))
           : size;
}

 size_t lexbor_mem_align_floor(size_t size)
{
    return ((size % LEXBOR_MEM_ALIGN_STEP) != 0)
           ? size - (size % LEXBOR_MEM_ALIGN_STEP)
           : size;
}

/*
 * No inline functions for ABI.
 */





// ---- mem.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lexbor_mem_t* lexbor_mem_create()
{
    return cast(lexbor_mem*) lexbor_calloc(1, lexbor_mem_t.sizeof);
}

lxb_status_t lexbor_mem_init(lexbor_mem_t* mem, size_t min_chunk_size)
{
    if (mem == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    if (min_chunk_size == 0) {
        return LXB_STATUS_ERROR_WRONG_ARGS;
    }

    mem.chunk_min_size = lexbor_mem_align(min_chunk_size);

    /* Create first chunk */
    mem.chunk = lexbor_mem_chunk_make(mem, mem.chunk_min_size);
    if (mem.chunk == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    mem.chunk_length = 1;
    mem.chunk_first = mem.chunk;

    return LXB_STATUS_OK;
}

void lexbor_mem_clean(lexbor_mem_t* mem)
{
    lexbor_mem_chunk_t* prev = void, chunk = void;

    if (mem == null) {
        return;
    }

    chunk = mem.chunk;

    while (chunk.prev) {
        prev = chunk.prev;

        chunk.data = cast(ubyte*) lexbor_free(chunk.data);
        lexbor_free(chunk);

        chunk = prev;
    }

    chunk.next = null;
    chunk.length = 0;

    mem.chunk = mem.chunk_first;
    mem.chunk_length = 1;
}

lexbor_mem_t* lexbor_mem_destroy(lexbor_mem_t* mem, bool destroy_self)
{
    lexbor_mem_chunk_t* chunk = void, prev = void;

    if (mem == null) {
        return null;
    }

    /* Destroy all chunk */
    if (mem.chunk) {
        chunk = mem.chunk;

        while (chunk) {
            prev = chunk.prev;
            lexbor_mem_chunk_destroy(mem, chunk, true);
            chunk = prev;
        }

        mem.chunk = null;
    }

    if (destroy_self) {
        return cast(lexbor_mem*) lexbor_free(mem);
    }

    return mem;
}

ubyte* lexbor_mem_chunk_init(lexbor_mem_t* mem, lexbor_mem_chunk_t* chunk, size_t length)
{
    length = lexbor_mem_align(length);

    if (length > mem.chunk_min_size) {
        if (mem.chunk_min_size > (SIZE_MAX - length)) {
            chunk.size = length;
        }
        else {
            chunk.size = length + mem.chunk_min_size;
        }
    }
    else {
        chunk.size = mem.chunk_min_size;
    }

    chunk.length = 0;
    chunk.data = cast(ubyte*) lexbor_malloc(chunk.size * ubyte.sizeof);

    return chunk.data;
}

lexbor_mem_chunk_t* lexbor_mem_chunk_make(lexbor_mem_t* mem, size_t length)
{
    lexbor_mem_chunk_t* chunk = cast(lexbor_mem_chunk*) lexbor_calloc(1, lexbor_mem_chunk_t.sizeof);

    if (chunk == null) {
        return null;
    }

    if (lexbor_mem_chunk_init(mem, chunk, length) == null) {
        return cast(lexbor_mem_chunk*) lexbor_free(chunk);
    }

    return chunk;
}

lexbor_mem_chunk_t* lexbor_mem_chunk_destroy(lexbor_mem_t* mem, lexbor_mem_chunk_t* chunk, bool self_destroy)
{
    if (chunk == null || mem == null) {
        return null;
    }

    if (chunk.data) {
        chunk.data = cast(ubyte*) lexbor_free(chunk.data);
    }

    if (self_destroy) {
        return cast(lexbor_mem_chunk*) lexbor_free(chunk);
    }

    return chunk;
}

void* lexbor_mem_alloc(lexbor_mem_t* mem, size_t length)
{
    if (length == 0) {
        return null;
    }

    length = lexbor_mem_align(length);

    if ((mem.chunk.length + length) > mem.chunk.size) {
        if ((SIZE_MAX - mem.chunk_length) == 0) {
            return null;
        }

        mem.chunk.next = lexbor_mem_chunk_make(mem, length);
        if (mem.chunk.next == null) {
            return null;
        }

        mem.chunk.next.prev = mem.chunk;
        mem.chunk = mem.chunk.next;

        mem.chunk_length++;
    }

    mem.chunk.length += length;

    return &mem.chunk.data[(mem.chunk.length - length)];
}

void* lexbor_mem_calloc(lexbor_mem_t* mem, size_t length)
{
    void* data = lexbor_mem_alloc(mem, length);

    if (data != null) {
        memset(data, 0, length);
    }

    return data;
}

/*
 * No inline functions for ABI.
 */
size_t lexbor_mem_current_length_noi(lexbor_mem_t* mem)
{
    return lexbor_mem_current_length(mem);
}

size_t lexbor_mem_current_size_noi(lexbor_mem_t* mem)
{
    return lexbor_mem_current_size(mem);
}

size_t lexbor_mem_chunk_length_noi(lexbor_mem_t* mem)
{
    return lexbor_mem_chunk_length(mem);
}
size_t lexbor_mem_align_noi(size_t size)
{
    return lexbor_mem_align(size);
}

size_t lexbor_mem_align_floor_noi(size_t size)
{
    return lexbor_mem_align_floor(size);
}
