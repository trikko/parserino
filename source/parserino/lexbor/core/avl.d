module parserino.lexbor.core.avl;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.core.dobject;

extern(C) @nogc nothrow:
__gshared:

// ---- avl.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lexbor_avl_t = lexbor_avl;
alias lexbor_avl_node_t = lexbor_avl_node;

alias lexbor_avl_node_f = lxb_status_t function(lexbor_avl_t* avl, lexbor_avl_node_t** root, lexbor_avl_node_t* node, void* ctx);

struct lexbor_avl_node {
    size_t type;
    short height;
    void* value;

    lexbor_avl_node_t* left;
    lexbor_avl_node_t* right;
    lexbor_avl_node_t* parent;
}

struct lexbor_avl {
    lexbor_dobject_t* nodes;
    lexbor_avl_node_t* last_right;
}

 lexbor_avl_t* lexbor_avl_create();

 lxb_status_t lexbor_avl_init(lexbor_avl_t* avl, size_t chunk_len, size_t struct_size);

 void lexbor_avl_clean(lexbor_avl_t* avl);

 lexbor_avl_t* lexbor_avl_destroy(lexbor_avl_t* avl, bool self_destroy);

 lexbor_avl_node_t* lexbor_avl_node_make(lexbor_avl_t* avl, size_t type, void* value);

 void lexbor_avl_node_clean(lexbor_avl_node_t* node);

 lexbor_avl_node_t* lexbor_avl_node_destroy(lexbor_avl_t* avl, lexbor_avl_node_t* node, bool self_destroy);

 lexbor_avl_node_t* lexbor_avl_insert(lexbor_avl_t* avl, lexbor_avl_node_t** scope_, size_t type, void* value);

 lexbor_avl_node_t* lexbor_avl_search(lexbor_avl_t* avl, lexbor_avl_node_t* scope_, size_t type);

 void* lexbor_avl_remove(lexbor_avl_t* avl, lexbor_avl_node_t** scope_, size_t type);

 void lexbor_avl_remove_by_node(lexbor_avl_t* avl, lexbor_avl_node_t** root, lexbor_avl_node_t* node);

 lxb_status_t lexbor_avl_foreach(lexbor_avl_t* avl, lexbor_avl_node_t** scope_, lexbor_avl_node_f cb, void* ctx);

 void lexbor_avl_foreach_recursion(lexbor_avl_t* avl, lexbor_avl_node_t* scope_, lexbor_avl_node_f callback, void* ctx);

// D port: implementation not needed by parserino, not ported.
