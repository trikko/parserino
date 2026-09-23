module parserino.lexbor.css.syntax.base;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.base;
public import parserino.lexbor.css.base;

extern(C) @nogc nothrow:
__gshared:

// ---- base.h ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
enum LXB_CSS_SYNTAX_VERSION_MAJOR = 1;
enum LXB_CSS_SYNTAX_VERSION_MINOR = 4;
enum LXB_CSS_SYNTAX_VERSION_PATCH = 0;

enum LXB_CSS_SYNTAX_VERSION_STRING = "0.0.0";
