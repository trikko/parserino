module parserino.lexbor.tag.tag;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.hash;
public import parserino.lexbor.core.shs;
public import parserino.lexbor.core.dobject;
public import parserino.lexbor.core.str;
public import parserino.lexbor.tag.const_;
import parserino.lexbor.tag.res;

extern(C) @nogc nothrow:
__gshared:

// ---- tag.h ----
/*
 * Copyright (C) 2018-2019 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_tag_data_t {
    lexbor_hash_entry_t entry;
    lxb_tag_id_t tag_id;
    size_t ref_count;
    bool read_only;
}




/*
 * Inline functions
 */
 const(lxb_char_t)* lxb_tag_name_by_id(lxb_tag_id_t tag_id, size_t* len)
{
    const(lxb_tag_data_t)* data = lxb_tag_data_by_id(tag_id);
    if (data == null) {
        if (len != null) {
            *len = 0;
        }

        return null;
    }

    if (len != null) {
        *len = data.entry.length;
    }

    return lexbor_hash_entry_str(&data.entry);
}

 const(lxb_char_t)* lxb_tag_name_upper_by_id(lxb_tag_id_t tag_id, size_t* len)
{
    const(lxb_tag_data_t)* data = lxb_tag_data_by_id(tag_id);
    if (data == null) {
        if (len != null) {
            *len = 0;
        }

        return null;
    }

    if (len != null) {
        *len = data.entry.length;
    }

    return lexbor_hash_entry_str(&data.entry);
}

 lxb_tag_id_t lxb_tag_id_by_name(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t len)
{
    const(lxb_tag_data_t)* data = lxb_tag_data_by_name(hash, name, len);
    if (data == null) {
        return LXB_TAG__UNDEF;
    }

    return data.tag_id;
}

 lexbor_mraw_t* lxb_tag_mraw(lexbor_hash_t* hash)
{
    return lexbor_hash_mraw(hash);
}

/*
 * No inline functions for ABI.
 */




// ---- tag.c ----
/*
 * Copyright (C) 2018-2019 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

 const(lxb_tag_data_t)* lxb_tag_append(lexbor_hash_t* hash, lxb_tag_id_t tag_id, const(lxb_char_t)* name, size_t length)
{
    lxb_tag_data_t* data = void;
    const(lexbor_shs_entry_t)* entry = void;

    entry = lexbor_shs_entry_get_static(lxb_tag_res_shs_data_default.ptr,
                                        name, length);
    if (entry != null) {
        return cast(const(lxb_tag_data_t)*) (entry.value);
    }

    data = cast(lxb_tag_data_t*) lexbor_hash_insert(hash, lexbor_hash_insert_raw, name, length);
    if (data == null) {
        return null;
    }

    if (tag_id == LXB_TAG__UNDEF) {
        data.tag_id = cast(lxb_tag_id_t) data;
    }
    else {
        data.tag_id = tag_id;
    }

    return data;
}

 const(lxb_tag_data_t)* lxb_tag_append_lower(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t length)
{
    lxb_tag_data_t* data = void;
    const(lexbor_shs_entry_t)* entry = void;

    entry = lexbor_shs_entry_get_lower_static(lxb_tag_res_shs_data_default.ptr,
                                              name, length);
    if (entry != null) {
        return cast(const(lxb_tag_data_t)*) (entry.value);
    }

    data = cast(lxb_tag_data_t*) lexbor_hash_insert(hash, lexbor_hash_insert_lower, name, length);
    if (data == null) {
        return null;
    }

    data.tag_id = cast(lxb_tag_id_t) data;

    return data;
}

const(lxb_tag_data_t)* lxb_tag_data_by_id(lxb_tag_id_t tag_id)
{
    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (tag_id == LXB_TAG__LAST_ENTRY) {
            return null;
        }

        return cast(const(lxb_tag_data_t)*) tag_id;
    }

    return &lxb_tag_res_data_default[tag_id];
}

const(lxb_tag_data_t)* lxb_tag_data_by_name(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t len)
{
    const(lexbor_shs_entry_t)* entry = void;

    if (name == null || len == 0) {
        return null;
    }

    entry = lexbor_shs_entry_get_lower_static(lxb_tag_res_shs_data_default.ptr,
                                              name, len);
    if (entry != null) {
        return cast(const(lxb_tag_data_t)*) entry.value;
    }

    return cast(const(lxb_tag_data_t)*) lexbor_hash_search(hash,
                                           lexbor_hash_search_lower, name, len);
}

const(lxb_tag_data_t)* lxb_tag_data_by_name_upper(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t len)
{
    uintptr_t dif = void;
    const(lexbor_shs_entry_t)* entry = void;

    if (name == null || len == 0) {
        return null;
    }

    entry = lexbor_shs_entry_get_upper_static(lxb_tag_res_shs_data_default.ptr,
                                              name, len);
    if (entry != null) {
        dif = cast(const(lxb_tag_data_t)*) entry.value - lxb_tag_res_data_default.ptr;

        return cast(const(lxb_tag_data_t)*) (lxb_tag_res_data_upper_default.ptr + dif);
    }

    return cast(const(lxb_tag_data_t)*) lexbor_hash_search(hash,
                                           lexbor_hash_search_upper, name, len);
}

/*
 * No inline functions for ABI.
 */
const(lxb_char_t)* lxb_tag_name_by_id_noi(lxb_tag_id_t tag_id, size_t* len)
{
    return lxb_tag_name_by_id(tag_id, len);
}

const(lxb_char_t)* lxb_tag_name_upper_by_id_noi(lxb_tag_id_t tag_id, size_t* len)
{
    return lxb_tag_name_upper_by_id(tag_id, len);
}

lxb_tag_id_t lxb_tag_id_by_name_noi(lexbor_hash_t* hash, const(lxb_char_t)* name, size_t len)
{
    return lxb_tag_id_by_name(hash, name, len);
}

lexbor_mraw_t* lxb_tag_mraw_noi(lexbor_hash_t* hash)
{
    return lxb_tag_mraw(hash);
}
