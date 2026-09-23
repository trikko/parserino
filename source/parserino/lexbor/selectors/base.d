module parserino.lexbor.selectors.base;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- base.h ----
/*
 * Copyright (C) 2021-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum LXB_SELECTORS_VERSION_MAJOR = 0;
enum LXB_SELECTORS_VERSION_MINOR = 4;
enum LXB_SELECTORS_VERSION_PATCH = 0;

enum LXB_SELECTORS_VERSION_STRING = "0.4.0";
