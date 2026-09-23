module parserino.lexbor.core.hash;

import parserino.lexbor.core.str_res;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.dobject;
public import parserino.lexbor.core.mraw;
import parserino.lexbor.core.str;

extern(C) @nogc nothrow:
__gshared:

// ---- hash.h ----
/*
 * Copyright (C) 2019 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum LEXBOR_HASH_SHORT_SIZE = 16;
enum LEXBOR_HASH_TABLE_MIN_SIZE = 32;

alias lexbor_hash_search_t = lexbor_hash_search_;
alias lexbor_hash_insert_t = lexbor_hash_insert_;

// extern const(lexbor_hash_insert_t)* lexbor_hash_insert_raw;
// extern const(lexbor_hash_insert_t)* lexbor_hash_insert_lower;
// extern const(lexbor_hash_insert_t)* lexbor_hash_insert_upper;

// extern const(lexbor_hash_search_t)* lexbor_hash_search_raw;
// extern const(lexbor_hash_search_t)* lexbor_hash_search_lower;
// extern const(lexbor_hash_search_t)* lexbor_hash_search_upper;

/*
 * FIXME:
 * It is necessary to add the rebuild of a hash table
 * and optimize collisions.
 */

alias lexbor_hash_t = lexbor_hash;
alias lexbor_hash_entry_t = lexbor_hash_entry;

alias lexbor_hash_id_f = uint function(const(lxb_char_t)* key, size_t size);

alias lexbor_hash_copy_f = lxb_status_t function(lexbor_hash_t* hash, lexbor_hash_entry_t* entry, const(lxb_char_t)* key, size_t size);

alias lexbor_hash_cmp_f = bool function(const(lxb_char_t)* first, const(lxb_char_t)* second, size_t size);

struct lexbor_hash_entry {
    union _U {
        lxb_char_t* long_str;
        lxb_char_t[LEXBOR_HASH_SHORT_SIZE + 1] short_str;
    }_U u;

    size_t length;

    lexbor_hash_entry_t* next;
}

/* D port: CTFE helper for static tables using the inline short string. */
extern(D) lxb_char_t[LEXBOR_HASH_SHORT_SIZE + 1] lexbor_hash_short_str(string s) pure
{
    typeof(return) r = 0;
    foreach (i, c; s) r[i] = c;
    return r;
}

struct lexbor_hash {
    lexbor_dobject_t* entries;
    lexbor_mraw_t* mraw;

    lexbor_hash_entry_t** table;
    size_t table_size;

    size_t struct_size;
}

struct lexbor_hash_insert_ {
    lexbor_hash_id_f hash; /* For generate a hash id. */
    lexbor_hash_cmp_f cmp; /* For compare key. */
    lexbor_hash_copy_f copy; /* For copy key. */
}

struct lexbor_hash_search_ {
    lexbor_hash_id_f hash; /* For generate a hash id. */
    lexbor_hash_cmp_f cmp; /* For compare key. */
}

















/*
 * Inline functions
 */
 lexbor_mraw_t* lexbor_hash_mraw(const(lexbor_hash_t)* hash)
{
    return cast(lexbor_mraw_t*) (hash.mraw);
}

 lxb_char_t* lexbor_hash_entry_str(const(lexbor_hash_entry_t)* entry)
{
    if (entry.length <= LEXBOR_HASH_SHORT_SIZE) {
        return cast(lxb_char_t*) entry.u.short_str;
    }

    return cast(ubyte*) (entry.u.long_str);
}

 lxb_char_t* lexbor_hash_entry_str_set(lexbor_hash_entry_t* entry, lxb_char_t* data, size_t length)
{
    entry.length = length;

    if (length <= LEXBOR_HASH_SHORT_SIZE) {
        memcpy(entry.u.short_str.ptr, data, length);
        return cast(lxb_char_t*) entry.u.short_str;
    }

    entry.u.long_str = data;
    return entry.u.long_str;
}

 void lexbor_hash_entry_str_free(lexbor_hash_t* hash, lexbor_hash_entry_t* entry)
{
    if (entry.length > LEXBOR_HASH_SHORT_SIZE) {
        lexbor_mraw_free(hash.mraw, entry.u.long_str);
    }

    entry.length = 0;
}

 lexbor_hash_entry_t* lexbor_hash_entry_create(lexbor_hash_t* hash)
{
    return cast(lexbor_hash_entry_t*) lexbor_dobject_calloc(hash.entries);
}

 lexbor_hash_entry_t* lexbor_hash_entry_destroy(lexbor_hash_t* hash, lexbor_hash_entry_t* entry)
{
    return cast(lexbor_hash_entry_t*) lexbor_dobject_free(hash.entries, entry);
}

 size_t lexbor_hash_entries_count(lexbor_hash_t* hash)
{
    return lexbor_dobject_allocated(hash.entries);
}

// ---- hash.c ----
/*
 * Copyright (C) 2019-2026 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

    // D port (C extern, imported instead): extern const(lxb_char_t)[256] lexbor_str_res_map_lowercase;
    // D port (C extern, imported instead): extern const(lxb_char_t)[256] lexbor_str_res_map_uppercase;

/* Insert variable. */
const(lexbor_hash_insert_t) lexbor_hash_insert_var = {
    hash: &lexbor_hash_make_id,
    copy: &lexbor_hash_copy,
    cmp: &lexbor_str_data_ncmp
};

const(lexbor_hash_insert_t) lexbor_hash_insert_lower_var = {
    hash: &lexbor_hash_make_id_lower,
    copy: &lexbor_hash_copy_lower,
    cmp: &lexbor_str_data_nlocmp_right
};

const(lexbor_hash_insert_t) lexbor_hash_insert_upper_var = {
    hash: &lexbor_hash_make_id_upper,
    copy: &lexbor_hash_copy_upper,
    cmp: &lexbor_str_data_nupcmp_right
};

 const(lexbor_hash_insert_t)* lexbor_hash_insert_raw = &lexbor_hash_insert_var;

 const(lexbor_hash_insert_t)* lexbor_hash_insert_lower = &lexbor_hash_insert_lower_var;

 const(lexbor_hash_insert_t)* lexbor_hash_insert_upper = &lexbor_hash_insert_upper_var;

/* Search variable. */
const(lexbor_hash_search_t) lexbor_hash_search_var = {
    hash: &lexbor_hash_make_id,
    cmp: &lexbor_str_data_ncmp
};

const(lexbor_hash_search_t) lexbor_hash_search_lower_var = {
    hash: &lexbor_hash_make_id_lower,
    cmp: &lexbor_str_data_nlocmp_right
};

const(lexbor_hash_search_t) lexbor_hash_search_upper_var = {
    hash: &lexbor_hash_make_id_upper,
    cmp: &lexbor_str_data_nupcmp_right
};

 const(lexbor_hash_search_t)* lexbor_hash_search_raw = &lexbor_hash_search_var;

 const(lexbor_hash_search_t)* lexbor_hash_search_lower = &lexbor_hash_search_lower_var;

 const(lexbor_hash_search_t)* lexbor_hash_search_upper = &lexbor_hash_search_upper_var;

 lexbor_hash_entry_t** lexbor_hash_table_create(lexbor_hash_t* hash)
{
    return cast(lexbor_hash_entry**) lexbor_calloc(hash.table_size, (lexbor_hash_entry_t*).sizeof);
}

 void lexbor_hash_table_clean(lexbor_hash_t* hash)
{
    memset(hash.table, 0, (lexbor_hash_t*).sizeof * hash.table_size);
}

 lexbor_hash_entry_t** lexbor_hash_table_destroy(lexbor_hash_t* hash)
{
    if (hash.table != null) {
        return cast(lexbor_hash_entry**) lexbor_free(hash.table);
    }

    return null;
}

 lexbor_hash_entry_t* _lexbor_hash_entry_create(lexbor_hash_t* hash, const(lexbor_hash_copy_f) copy_func, const(lxb_char_t)* key, size_t length)
{
    lexbor_hash_entry_t* entry = cast(lexbor_hash_entry*) lexbor_dobject_calloc(hash.entries);
    if (entry == null) {
        return null;
    }

    entry.length = length;

    if (copy_func(hash, entry, key, length) != LXB_STATUS_OK) {
        lexbor_dobject_free(hash.entries, entry);
        return null;
    }

    return entry;
}

lexbor_hash_t* lexbor_hash_create()
{
    return cast(lexbor_hash*) lexbor_calloc(1, lexbor_hash_t.sizeof);
}

lxb_status_t lexbor_hash_init(lexbor_hash_t* hash, size_t table_size, size_t struct_size)
{
    lxb_status_t status = void;
    size_t chunk_size = void;

    if (hash == null) {
        return LXB_STATUS_ERROR_OBJECT_IS_NULL;
    }

    if (table_size < LEXBOR_HASH_TABLE_MIN_SIZE) {
        table_size = LEXBOR_HASH_TABLE_MIN_SIZE;
    }

    chunk_size = table_size / 2;

    hash.table_size = table_size;

    hash.entries = lexbor_dobject_create();
    status = lexbor_dobject_init(hash.entries, chunk_size, struct_size);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    hash.mraw = lexbor_mraw_create();
    status = lexbor_mraw_init(hash.mraw, chunk_size * 12);
    if (status != LXB_STATUS_OK) {
        return status;
    }

    hash.table = lexbor_hash_table_create(hash);
    if (hash.table == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    hash.struct_size = struct_size;

    return LXB_STATUS_OK;
}

void lexbor_hash_clean(lexbor_hash_t* hash)
{
    lexbor_dobject_clean(hash.entries);
    lexbor_mraw_clean(hash.mraw);
    lexbor_hash_table_clean(hash);
}

lexbor_hash_t* lexbor_hash_destroy(lexbor_hash_t* hash, bool destroy_obj)
{
    if (hash == null) {
        return null;
    }

    hash.entries = lexbor_dobject_destroy(hash.entries, true);
    hash.mraw = lexbor_mraw_destroy(hash.mraw, true);
    hash.table = lexbor_hash_table_destroy(hash);

    if (destroy_obj) {
        return cast(lexbor_hash*) lexbor_free(hash);
    }

    return hash;
}

void* lexbor_hash_insert(lexbor_hash_t* hash, const(lexbor_hash_insert_t)* insert, const(lxb_char_t)* key, size_t length)
{
    lxb_char_t* str = void;
    uint hash_id = void, table_idx = void;
    lexbor_hash_entry_t* entry = void;

    hash_id = insert.hash(key, length);
    table_idx = hash_id % hash.table_size;

    entry = hash.table[table_idx];

    if (entry == null) {
        entry = _lexbor_hash_entry_create(hash, insert.copy, key, length);
        hash.table[table_idx] = entry;

        return entry;
    }

    do {
        str = lexbor_hash_entry_str(entry);

        if (entry.length == length && insert.cmp(str, key, length)) {
            return entry;
        }

        if (entry.next == null) {
            break;
        }

        entry = entry.next;
    }
    while (1);

    entry.next = _lexbor_hash_entry_create(hash, insert.copy, key, length);

    return entry.next;
}

void* lexbor_hash_insert_by_entry(lexbor_hash_t* hash, lexbor_hash_entry_t* entry, const(lexbor_hash_search_t)* search, const(lxb_char_t)* key, size_t length)
{
    lxb_char_t* str = void;
    uint hash_id = void, table_idx = void;
    lexbor_hash_entry_t* item = void;

    hash_id = search.hash(key, length);
    table_idx = hash_id % hash.table_size;

    item = hash.table[table_idx];

    if (item == null) {
        hash.table[table_idx] = entry;

        return entry;
    }

    do {
        str = lexbor_hash_entry_str(item);

        if (item.length == length && search.cmp(str, key, length)) {
            return item;
        }

        if (item.next == null) {
            break;
        }

        item = item.next;
    }
    while (1);

    item.next = entry;

    return entry;
}

void lexbor_hash_remove(lexbor_hash_t* hash, const(lexbor_hash_search_t)* search, const(lxb_char_t)* key, size_t length)
{
    lexbor_hash_remove_by_hash_id(hash, search.hash(key, length),
                                  key, length, search.cmp);
}

void* lexbor_hash_search(lexbor_hash_t* hash, const(lexbor_hash_search_t)* search, const(lxb_char_t)* key, size_t length)
{
    return lexbor_hash_search_by_hash_id(hash, search.hash(key, length),
                                         key, length, search.cmp);
}

void lexbor_hash_remove_by_hash_id(lexbor_hash_t* hash, uint hash_id, const(lxb_char_t)* key, size_t length, const(lexbor_hash_cmp_f) cmp_func)
{
    uint table_idx = void;
    lxb_char_t* str = void;
    lexbor_hash_entry_t* entry = void, prev = void;

    table_idx = hash_id % hash.table_size;
    entry = hash.table[table_idx];
    prev = null;

    while (entry != null) {
        str = lexbor_hash_entry_str(entry);

        if (entry.length == length && cmp_func(str, key, length)) {
            if (prev == null) {
                hash.table[table_idx] = entry.next;
            }
            else {
                prev.next = entry.next;
            }

            if (length > LEXBOR_HASH_SHORT_SIZE) {
                lexbor_mraw_free(hash.mraw, entry.u.long_str);
            }

            lexbor_dobject_free(hash.entries, entry);

            return;
        }

        prev = entry;
        entry = entry.next;
    }
}

void* lexbor_hash_search_by_hash_id(lexbor_hash_t* hash, uint hash_id, const(lxb_char_t)* key, size_t length, const(lexbor_hash_cmp_f) cmp_func)
{
    lxb_char_t* str = void;
    lexbor_hash_entry_t* entry = void;

    entry = hash.table[ hash_id % hash.table_size ];

    while (entry != null) {
        str = lexbor_hash_entry_str(entry);

        if (entry.length == length && cmp_func(str, key, length)) {
            return entry;
        }

        entry = entry.next;
    }

    return null;
}

uint lexbor_hash_make_id(const(lxb_char_t)* key, size_t length)
{
    size_t i = void;
    uint hash_id = void;

    for (i = hash_id = 0; i < length; i++) {
        hash_id += key[i];
        hash_id += (hash_id << 10);
        hash_id ^= (hash_id >> 6);
    }

    hash_id += (hash_id << 3);
    hash_id ^= (hash_id >> 11);
    hash_id += (hash_id << 15);

    return hash_id;
}

uint lexbor_hash_make_id_lower(const(lxb_char_t)* key, size_t length)
{
    size_t i = void;
    uint hash_id = void;

    for (i = hash_id = 0; i < length; i++) {
        hash_id += lexbor_str_res_map_lowercase[ key[i] ];
        hash_id += (hash_id << 10);
        hash_id ^= (hash_id >> 6);
    }

    hash_id += (hash_id << 3);
    hash_id ^= (hash_id >> 11);
    hash_id += (hash_id << 15);

    return hash_id;
}

uint lexbor_hash_make_id_upper(const(lxb_char_t)* key, size_t length)
{
    size_t i = void;
    uint hash_id = void;

    for (i = hash_id = 0; i < length; i++) {
        hash_id += lexbor_str_res_map_uppercase[ key[i] ];
        hash_id += (hash_id << 10);
        hash_id ^= (hash_id >> 6);
    }

    hash_id += (hash_id << 3);
    hash_id ^= (hash_id >> 11);
    hash_id += (hash_id << 15);

    return hash_id;
}

lxb_status_t lexbor_hash_copy(lexbor_hash_t* hash, lexbor_hash_entry_t* entry, const(lxb_char_t)* key, size_t length)
{
    lxb_char_t* to = void;

    if (length <= LEXBOR_HASH_SHORT_SIZE) {
        to = entry.u.short_str.ptr;
    }
    else {
        entry.u.long_str = cast(ubyte*) lexbor_mraw_alloc(hash.mraw, length + 1);
        if (entry.u.long_str == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        to = entry.u.long_str;
    }

    memcpy(to, key, length);

    to[length] = '\0';

    return LXB_STATUS_OK;
}

lxb_status_t lexbor_hash_copy_lower(lexbor_hash_t* hash, lexbor_hash_entry_t* entry, const(lxb_char_t)* key, size_t length)
{
    lxb_char_t* to = void;

    if (length <= LEXBOR_HASH_SHORT_SIZE) {
        to = entry.u.short_str.ptr;
    }
    else {
        entry.u.long_str = cast(ubyte*) lexbor_mraw_alloc(hash.mraw, length + 1);
        if (entry.u.long_str == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        to = entry.u.long_str;
    }

    for (size_t i = 0; i < length; i++) {
        to[i] = lexbor_str_res_map_lowercase[ key[i] ];
    }

    to[length] = '\0';

    return LXB_STATUS_OK;
}

lxb_status_t lexbor_hash_copy_upper(lexbor_hash_t* hash, lexbor_hash_entry_t* entry, const(lxb_char_t)* key, size_t length)
{
    lxb_char_t* to = void;

    if (length <= LEXBOR_HASH_SHORT_SIZE) {
        to = entry.u.short_str.ptr;
    }
    else {
        entry.u.long_str = cast(ubyte*) lexbor_mraw_alloc(hash.mraw, length + 1);
        if (entry.u.long_str == null) {
            return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
        }

        to = entry.u.long_str;
    }

    for (size_t i = 0; i < length; i++) {
        to[i] = lexbor_str_res_map_uppercase[ key[i] ];
    }

    to[length] = '\0';

    return LXB_STATUS_OK;
}
