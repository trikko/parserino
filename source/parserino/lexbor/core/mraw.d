module parserino.lexbor.core.mraw;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import core.stdc.string;
public import parserino.lexbor.core.base;
public import parserino.lexbor.core.mem;
public import parserino.lexbor.core.bst;

extern(C) @nogc nothrow:
__gshared:

// ---- mraw.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lexbor_mraw_t {
    lexbor_mem_t* mem;
    lexbor_bst_t* cache;
    size_t ref_count;
}









/*
 * Inline functions
 */
 size_t lexbor_mraw_data_size(void* data)
{
    return *(cast(size_t*) ((cast(ubyte*) data) - (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof)));
}

 void lexbor_mraw_data_size_set(void* data, size_t size)
{
    data = ((cast(ubyte*) data) - (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof));
    memcpy(data, &size, size_t.sizeof);
}

 void* lexbor_mraw_dup(lexbor_mraw_t* mraw, const(void)* src, size_t size)
{
    void* data = lexbor_mraw_alloc(mraw, size);

    if (data != null) {
        memcpy(data, src, size);
    }

    return data;
}

 size_t lexbor_mraw_reference_count(lexbor_mraw_t* mraw)
{
    return mraw.ref_count;
}

/*
 * No inline functions for ABI.
 */



// ---- mraw.c ----
/*
 * Copyright (C) 2018-2019 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lexbor_mraw_t* lexbor_mraw_create()
{
    return cast(lexbor_mraw_t*) lexbor_calloc(1, lexbor_mraw_t.sizeof);
}

lxb_status_t lexbor_mraw_init(lexbor_mraw_t* mraw, size_t chunk_size)
{
    lxb_status_t status = void;

    if (mraw == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    if (chunk_size == 0) {
        return LXB_STATUS_ERROR_WRONG_ARGS;
    }

    /* Init memory */
    mraw.mem = lexbor_mem_create();

    status = lexbor_mem_init(mraw.mem, chunk_size + (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof));
    if (status) {
        return status;
    }

    /* Cache */
    mraw.cache = lexbor_bst_create();

    status = lexbor_bst_init(mraw.cache, 512);
    if (status) {
        return status;
    }

    mraw.ref_count = 0;

    return LXB_STATUS_OK;
}

void lexbor_mraw_clean(lexbor_mraw_t* mraw)
{
    if (mraw != null) {
        lexbor_mem_clean(mraw.mem);
        lexbor_bst_clean(mraw.cache);

        mraw.ref_count = 0;
    }
}

lexbor_mraw_t* lexbor_mraw_destroy(lexbor_mraw_t* mraw, bool destroy_self)
{
    if (mraw == null) {
        return null;
    }

    mraw.mem = lexbor_mem_destroy(mraw.mem, true);
    mraw.cache = lexbor_bst_destroy(mraw.cache, true);

    if (destroy_self) {
        return cast(lexbor_mraw_t*) lexbor_free(mraw);
    }

    return mraw;
}

 void* lexbor_mraw_mem_alloc(lexbor_mraw_t* mraw, size_t length)
{
    ubyte* data = void;
    lexbor_mem_t* mem = mraw.mem;

    if (length == 0) {
        return null;
    }

    if ((mem.chunk.length + length) > mem.chunk.size) {
        lexbor_mem_chunk_t* chunk = mem.chunk;

        if ((SIZE_MAX - mem.chunk_length) == 0) {
            return null;
        }

        if (chunk.length == 0) {
            lexbor_mem_chunk_destroy(mem, chunk, false);
            lexbor_mem_chunk_init(mem, chunk, length);

            chunk.length = length;

            return chunk.data;
        }

        size_t diff = lexbor_mem_align_floor(chunk.size - chunk.length);

        /* Save tail to cache */
        if (diff > (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof)) {
            diff -= (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof);

            do { memcpy(&chunk.data[chunk.length], &diff, size_t.sizeof); } while (0);

            lexbor_bst_insert(mraw.cache,
                              &((mraw.cache).root), diff,
                              &(cast(ubyte*) (&chunk.data[chunk.length]))[ (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof) ]);

            chunk.length = chunk.size;
        }

        chunk.next = lexbor_mem_chunk_make(mem, length);
        if (chunk.next == null) {
            return null;
        }

        chunk.next.prev = chunk;
        mem.chunk = chunk.next;

        mem.chunk_length++;

    }

    data = &mem.chunk.data[ mem.chunk.length ];
    mem.chunk.length += length;

    return data;
}

void* lexbor_mraw_alloc(lexbor_mraw_t* mraw, size_t size)
{
    void* data = void;

    size = lexbor_mem_align(size);

    if (mraw.cache.tree_length != 0) {
        data = lexbor_bst_remove_close(mraw.cache,
                                       &((mraw.cache).root),
                                       size, null);
        if (data != null) {
            mraw.ref_count++;

            return data;
        }
    }

    data = lexbor_mraw_mem_alloc(mraw, (size + (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof)));

    if (data == null) {
        return null;
    }

    mraw.ref_count++;

    do { memcpy(data, &size, size_t.sizeof); } while (0);
    return &(cast(ubyte*) (data))[ (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof) ];
}

void* lexbor_mraw_calloc(lexbor_mraw_t* mraw, size_t size)
{
    void* data = lexbor_mraw_alloc(mraw, size);

    if (data != null) {
        memset(data, 0, lexbor_mraw_data_size(data));
    }

    return data;
}

/*
 * TODO: I don't really like this interface. Perhaps need to simplify.
 */
 void* lexbor_mraw_realloc_tail(lexbor_mraw_t* mraw, void* data, void* begin, size_t size, size_t begin_len, size_t new_size, bool* is_valid)
{
    size_t length = void;
    ubyte* tmp = void;
    lexbor_mem_chunk_t* chunk = mraw.mem.chunk;

    if (chunk.size > (begin_len + new_size)) {
        *is_valid = true;

        if (new_size == 0) {
            chunk.length = begin_len - (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof);
            return null;
        }

        chunk.length = begin_len + new_size;
        memcpy(begin, &new_size, size_t.sizeof);

        return data;
    }

    /*
     * If the tail is short then we increase the current data.
     */
    if (begin_len == (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof)) {

        *is_valid = true;

        length = lexbor_mem_align(new_size + (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof)
                                  + mraw.mem.chunk_min_size);

        tmp = cast(ubyte*) lexbor_realloc(chunk.data, length);
        if (tmp == null) {
            return null;
        }

        chunk.data = tmp;
        chunk.size = length;
        chunk.length = new_size + (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof);

        do { memcpy(tmp, &new_size, size_t.sizeof); } while (0);

        return &(cast(ubyte*) (tmp))[ (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof) ];
    }

    *is_valid = false;

    /*
     * Next, this piece will go into the cache.
     */
    size = lexbor_mem_align_floor(size + (chunk.size - chunk.length));
    memcpy(begin, &size, size_t.sizeof);

    chunk.length = chunk.size;

    return null;
}

void* lexbor_mraw_realloc(lexbor_mraw_t* mraw, void* data, size_t new_size)
{
    void* begin = void;
    size_t size = void, begin_len = void;
    lexbor_mem_chunk_t* chunk = mraw.mem.chunk;

    begin = (cast(ubyte*) data) - (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof);
    memcpy(&size, begin, size_t.sizeof);

    new_size = lexbor_mem_align(new_size);

    /*
     * Look, whether there is an opportunity
     * to prolong the current data in chunk?
     */
    if (chunk.length >= size) {
        begin_len = chunk.length - size;

        if (&chunk.data[begin_len] == data) {
            bool is_valid = void;
            void* ptr = lexbor_mraw_realloc_tail(mraw, data, begin,
                                                 size, begin_len, new_size,
                                                 &is_valid);
            if (is_valid == true) {
                return ptr;
            }
        }
    }

    if (new_size < size) {
        if (new_size == 0) {

            mraw.ref_count--;

            lexbor_bst_insert(mraw.cache, &((mraw.cache).root),
                              size, data);
            return null;
        }

        size_t diff = lexbor_mem_align_floor(size - new_size);

        if (diff > (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof)) {
            memcpy(begin, &new_size, size_t.sizeof);

            new_size = diff - (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof);
            begin = &(cast(ubyte*) data)[diff];

            do { memcpy(begin, &new_size, size_t.sizeof); } while (0);

            lexbor_bst_insert(mraw.cache, &((mraw.cache).root),
                              new_size, &(cast(ubyte*) (begin))[ (((size_t.sizeof % LEXBOR_MEM_ALIGN_STEP) != 0) ? size_t.sizeof + (LEXBOR_MEM_ALIGN_STEP - (size_t.sizeof % LEXBOR_MEM_ALIGN_STEP)) : size_t.sizeof) ]);
        }

        return data;
    }

    begin = lexbor_mraw_alloc(mraw, new_size);
    if (begin == null) {
        return null;
    }

    if (size != 0) {
        memcpy(begin, data, ubyte.sizeof * size);
    }

    lexbor_mraw_free(mraw, data);

    return begin;
}

void* lexbor_mraw_free(lexbor_mraw_t* mraw, void* data)
{
    size_t size = lexbor_mraw_data_size(data);

    lexbor_bst_insert(mraw.cache, &((mraw.cache).root),
                      size, data);

    mraw.ref_count--;

    return null;
}

/*
 * No inline functions for ABI.
 */
size_t lexbor_mraw_data_size_noi(void* data)
{
    return lexbor_mraw_data_size(data);
}

void lexbor_mraw_data_size_set_noi(void* data, size_t size)
{
    lexbor_mraw_data_size_set(data, size);
}

void* lexbor_mraw_dup_noi(lexbor_mraw_t* mraw, const(void)* src, size_t size)
{
    return lexbor_mraw_dup(mraw, src, size);
}
