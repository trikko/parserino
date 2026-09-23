module parserino.lexbor.ns.ns;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.hash;
public import parserino.lexbor.core.shs;
public import parserino.lexbor.ns.const_;
import parserino.lexbor.core.str_res;
import parserino.lexbor.ns.res;

extern(C) @nogc nothrow:
__gshared:

// ---- ns.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_ns_data_t {
    lexbor_hash_entry_t entry;

    lxb_ns_id_t ns_id;
    size_t ref_count;
    bool read_only;
}

struct lxb_ns_prefix_data_t {
    lexbor_hash_entry_t entry;

    lxb_ns_prefix_id_t prefix_id;
    size_t ref_count;
    bool read_only;
}

/* Link */



/* Prefix */



// ---- ns.c ----
/*
 * Copyright (C) 2018-2019 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

 const(lxb_ns_data_t)* lxb_ns_append(lexbor_hash_t* hash, const(lxb_char_t)* link, size_t length)
{
    lxb_ns_data_t* data = void;
    const(lexbor_shs_entry_t)* entry = void;

    if (link == null || length == 0) {
        return null;
    }

    entry = lexbor_shs_entry_get_lower_static(lxb_ns_res_shs_link_data.ptr,
                                              link, length);
    if (entry != null) {
        return cast(const(lxb_ns_data_t)*) (entry.value);
    }

    data = cast(lxb_ns_data_t*) lexbor_hash_insert(hash, lexbor_hash_insert_lower, link, length);
    if (cast(lxb_ns_id_t) data <= LXB_NS__LAST_ENTRY) {
        return null;
    }

    data.ns_id = cast(lxb_ns_id_t) data;

    return data;
}

const(lxb_char_t)* lxb_ns_by_id(lexbor_hash_t* hash, lxb_ns_id_t ns_id, size_t* length)
{
    const(lxb_ns_data_t)* data = void;

    data = lxb_ns_data_by_id(hash, ns_id);
    if (data == null) {
        if (length != null) {
            *length = 0;
        }

        return null;
    }

    if (length != null) {
        *length = data.entry.length;
    }

    return lexbor_hash_entry_str(&data.entry);
}

const(lxb_ns_data_t)* lxb_ns_data_by_id(lexbor_hash_t* hash, lxb_ns_id_t ns_id)
{
    if (ns_id >= LXB_NS__LAST_ENTRY) {
        if (ns_id == LXB_NS__LAST_ENTRY) {
            return null;
        }

        return cast(const(lxb_ns_data_t)*) ns_id;
    }

    return &lxb_ns_res_data[ns_id];
}

const(lxb_ns_data_t)* lxb_ns_data_by_link(lexbor_hash_t* hash, const(lxb_char_t)* link, size_t length)
{
    const(lexbor_shs_entry_t)* entry = void;

    if (link == null || length == 0) {
        return null;
    }

    entry = lexbor_shs_entry_get_lower_static(lxb_ns_res_shs_link_data.ptr,
                                              link, length);
    if (entry != null) {
        return cast(const(lxb_ns_data_t)*) (entry.value);
    }

    return cast(const(lxb_ns_data_t)*) lexbor_hash_search(hash, lexbor_hash_search_lower, link, length);
}

/* Prefix */
const(lxb_ns_prefix_data_t)* lxb_ns_prefix_append(lexbor_hash_t* hash, const(lxb_char_t)* prefix, size_t length)
{
    lxb_ns_prefix_data_t* data = void;
    const(lexbor_shs_entry_t)* entry = void;

    if (prefix == null || length == 0) {
        return null;
    }

    entry = lexbor_shs_entry_get_lower_static(lxb_ns_res_shs_data.ptr,
                                              prefix, length);
    if (entry != null) {
        return cast(const(lxb_ns_prefix_data_t)*) (entry.value);
    }

    data = cast(lxb_ns_prefix_data_t*) lexbor_hash_insert(hash, lexbor_hash_insert_lower, prefix, length);
    if (cast(lxb_ns_prefix_id_t) data <= LXB_NS__LAST_ENTRY) {
        return null;
    }

    data.prefix_id = cast(lxb_ns_prefix_id_t) data;

    return data;
}

const(lxb_ns_prefix_data_t)* lxb_ns_prefix_data_by_id(lexbor_hash_t* hash, lxb_ns_prefix_id_t prefix_id)
{
    if (prefix_id >= LXB_NS__LAST_ENTRY) {
        if (prefix_id == LXB_NS__LAST_ENTRY) {
            return null;
        }

        return cast(const(lxb_ns_prefix_data_t)*) prefix_id;
    }

    return &lxb_ns_prefix_res_data[prefix_id];
}

const(lxb_ns_prefix_data_t)* lxb_ns_prefix_data_by_name(lexbor_hash_t* hash, const(lxb_char_t)* prefix, size_t length)
{
    const(lexbor_shs_entry_t)* entry = void;

    if (prefix == null || length == 0) {
        return null;
    }

    entry = lexbor_shs_entry_get_lower_static(lxb_ns_res_shs_data.ptr,
                                              prefix, length);
    if (entry != null) {
        return cast(const(lxb_ns_prefix_data_t)*) (entry.value);
    }

    return cast(const(lxb_ns_prefix_data_t)*) lexbor_hash_search(hash, lexbor_hash_search_lower, prefix, length);
}
