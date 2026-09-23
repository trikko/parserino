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














// D port: implementation not needed by parserino, not ported.
