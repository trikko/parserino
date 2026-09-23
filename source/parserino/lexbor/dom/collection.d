module parserino.lexbor.dom.collection;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.core.array;
public import parserino.lexbor.dom.interface_;
import parserino.lexbor.dom.interfaces.document;

extern(C) @nogc nothrow:
__gshared:

// ---- collection.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_dom_collection_t {
    lexbor_array_t array;
    lxb_dom_document_t* document;
}

 lxb_dom_collection_t* lxb_dom_collection_create(lxb_dom_document_t* document);

 lxb_status_t lxb_dom_collection_init(lxb_dom_collection_t* col, size_t start_list_size);

 lxb_dom_collection_t* lxb_dom_collection_destroy(lxb_dom_collection_t* col, bool self_destroy);

/*
 * Inline functions
 */
/* D port: lxb_dom_collection_make removed (collection.c not ported). */

 void lxb_dom_collection_clean(lxb_dom_collection_t* col)
{
    lexbor_array_clean(&col.array);
}

 lxb_status_t lxb_dom_collection_append(lxb_dom_collection_t* col, void* value)
{
    return lexbor_array_push(&col.array, value);
}

 lxb_dom_element_t* lxb_dom_collection_element(lxb_dom_collection_t* col, size_t idx)
{
    return cast(lxb_dom_element_t*) lexbor_array_get(&col.array, idx);
}

 lxb_dom_node_t* lxb_dom_collection_node(lxb_dom_collection_t* col, size_t idx)
{
    return cast(lxb_dom_node_t*) lexbor_array_get(&col.array, idx);
}

 size_t lxb_dom_collection_length(lxb_dom_collection_t* col)
{
    return lexbor_array_length(&col.array);
}

/*
 * No inline functions for ABI.
 */
 lxb_dom_collection_t* lxb_dom_collection_make_noi(lxb_dom_document_t* document, size_t start_list_size);

 void lxb_dom_collection_clean_noi(lxb_dom_collection_t* col);

 lxb_status_t lxb_dom_collection_append_noi(lxb_dom_collection_t* col, void* value);

 lxb_dom_element_t* lxb_dom_collection_element_noi(lxb_dom_collection_t* col, size_t idx);

 lxb_dom_node_t* lxb_dom_collection_node_noi(lxb_dom_collection_t* col, size_t idx);

 size_t lxb_dom_collection_length_noi(lxb_dom_collection_t* col);

// D port: implementation not needed by parserino, not ported.
