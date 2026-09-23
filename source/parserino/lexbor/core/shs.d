module parserino.lexbor.core.shs;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import core.stdc.string;
public import parserino.lexbor.core.base;
import parserino.lexbor.core.str;
import parserino.lexbor.core.str_res;

extern(C) @nogc nothrow:
__gshared:

// ---- shs.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lexbor_shs_entry_t {
    char* key;
    void* value;

    size_t key_len;
    size_t next;
}

struct lexbor_shs_hash_t {
    uint key;
    void* value;

    size_t next;
}




/*
 * Inline functions
 */
 const(lexbor_shs_hash_t)* lexbor_shs_hash_get_static(const(lexbor_shs_hash_t)* table, const(size_t) table_size, const(uint) key)
{
    const(lexbor_shs_hash_t)* entry = void;

    entry = &table[ (key % table_size) + 1 ];

    do {
        if (entry.key == key) {
            return entry;
        }

        entry = &table[entry.next];
    }
    while (entry != table);

    return null;
}

// ---- shs.c ----
/*
 * Copyright (C) 2018-2019 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
const(lexbor_shs_entry_t)* lexbor_shs_entry_get_static(const(lexbor_shs_entry_t)* root, const(lxb_char_t)* key, size_t key_len)
{
    const(lexbor_shs_entry_t)* entry = void;
    entry = root + (((((key[0] * key[key_len - 1]) * key[0]) + key_len) % root.key_len) + 0x01);

    while (entry.key != null)
    {
        if (entry.key_len == key_len) {
            if (lexbor_str_data_ncmp(cast(const(lxb_char_t)*) entry.key,
                                     key, key_len))
            {
                return entry;
            }

            entry = &root[entry.next];
        }
        else if (entry.key_len > key_len) {
            return null;
        }
        else {
            entry = &root[entry.next];
        }
    }

    return null;
}

const(lexbor_shs_entry_t)* lexbor_shs_entry_get_lower_static(const(lexbor_shs_entry_t)* root, const(lxb_char_t)* key, size_t key_len)
{
    const(lexbor_shs_entry_t)* entry = void;
    entry = root + (((((lexbor_str_res_map_lowercase[key[0]] * lexbor_str_res_map_lowercase[key[key_len - 1]]) * lexbor_str_res_map_lowercase[key[0]]) + key_len) % root.key_len) + 0x01);

    while (entry.key != null)
    {
        if (entry.key_len == key_len) {
            if (lexbor_str_data_nlocmp_right(cast(const(lxb_char_t)*) entry.key,
                                             key, key_len))
            {
                return entry;
            }

            entry = &root[entry.next];
        }
        else if (entry.key_len > key_len) {
            return null;
        }
        else {
            entry = &root[entry.next];
        }
    }

    return null;
}

const(lexbor_shs_entry_t)* lexbor_shs_entry_get_upper_static(const(lexbor_shs_entry_t)* root, const(lxb_char_t)* key, size_t key_len)
{
    const(lexbor_shs_entry_t)* entry = void;
    entry = root + (((((lexbor_str_res_map_uppercase[key[0]] * lexbor_str_res_map_uppercase[key[key_len - 1]]) * lexbor_str_res_map_uppercase[key[0]]) + key_len) % root.key_len) + 0x01);

    while (entry.key != null)
    {
        if (entry.key_len == key_len) {
            if (lexbor_str_data_nupcmp_right(cast(const(lxb_char_t)*) entry.key,
                                             key, key_len))
            {
                return entry;
            }

            entry = &root[entry.next];
        }
        else if (entry.key_len > key_len) {
            return null;
        }
        else {
            entry = &root[entry.next];
        }
    }

    return null;
}
