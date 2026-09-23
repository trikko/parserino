module parserino.lexbor.core.def;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>


extern(C) @nogc nothrow:
__gshared:

// ---- def.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

/* Format */

enum LEXBOR_FORMAT_Z = "%zu";

/* Deprecated */
/* Debug */
//#define LEXBOR_DEBUG(...) do {} while (0)
//#define LEXBOR_DEBUG_ERROR(...) do {} while (0)

enum LEXBOR_MEM_ALIGN_STEP = (void*).sizeof;
