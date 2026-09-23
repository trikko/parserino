module parserino.lexbor.core.lexbor;

import parserino.lexbor.core.types;
// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.def;

extern(C) @nogc nothrow:
__gshared:

// ---- lexbor.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lexbor_memory_malloc_f = void* function(size_t size);
alias lexbor_memory_realloc_f = void* function(void* dst, size_t size);
alias lexbor_memory_calloc_f = void* function(size_t num, size_t size);
alias lexbor_memory_free_f = void function(void* dst);

 void* lexbor_malloc(size_t size);

 void* lexbor_realloc(void* dst, size_t size);

 void* lexbor_calloc(size_t num, size_t size);

 void* lexbor_free(void* dst);

 lxb_status_t lexbor_memory_setup(lexbor_memory_malloc_f new_malloc, lexbor_memory_realloc_f new_realloc, lexbor_memory_calloc_f new_calloc, lexbor_memory_free_f new_free);
