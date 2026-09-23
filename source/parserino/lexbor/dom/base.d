module parserino.lexbor.dom.base;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;

extern(C) @nogc nothrow:
__gshared:

// ---- base.h ----
/*
 * Copyright (C) 2019-2024 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum LXB_DOM_VERSION_MAJOR = 1;
enum LXB_DOM_VERSION_MINOR = 8;
enum LXB_DOM_VERSION_PATCH = 0;

enum LXB_DOM_VERSION_STRING = "1.8.0";
