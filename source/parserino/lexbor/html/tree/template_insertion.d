module parserino.lexbor.html.tree.template_insertion;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.core.array;
public import parserino.lexbor.html.tree;

extern(C) @nogc nothrow:
__gshared:

// ---- template_insertion.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_html_tree_template_insertion_t {
    lxb_html_tree_insertion_mode_f mode;
}

/*
 * Inline functions
 */
 lxb_html_tree_insertion_mode_f lxb_html_tree_template_insertion_current(lxb_html_tree_t* tree)
{
    if (lexbor_array_obj_length(tree.template_insertion_modes) == 0) {
        return null;
    }

    lxb_html_tree_template_insertion_t* tmp_ins = void;

    tmp_ins = cast(lxb_html_tree_template_insertion_t*)
              lexbor_array_obj_last(tree.template_insertion_modes);

    return tmp_ins.mode;
}

 lxb_html_tree_insertion_mode_f lxb_html_tree_template_insertion_get(lxb_html_tree_t* tree, size_t idx)
{
    lxb_html_tree_template_insertion_t* tmp_ins = void;

    tmp_ins = cast(lxb_html_tree_template_insertion_t*)
              lexbor_array_obj_get(tree.template_insertion_modes, idx);
    if (tmp_ins == null) {
        return null;
    }

    return tmp_ins.mode;
}

 lxb_html_tree_insertion_mode_f lxb_html_tree_template_insertion_first(lxb_html_tree_t* tree)
{
    return lxb_html_tree_template_insertion_get(tree, 0);
}

 lxb_status_t lxb_html_tree_template_insertion_push(lxb_html_tree_t* tree, lxb_html_tree_insertion_mode_f mode)
{
    lxb_html_tree_template_insertion_t* tmp_ins = void;

    tmp_ins = cast(lxb_html_tree_template_insertion_t*)
              lexbor_array_obj_push(tree.template_insertion_modes);
    if (tmp_ins == null) {
        return LXB_STATUS_ERROR_MEMORY_ALLOCATION;
    }

    tmp_ins.mode = mode;

    return LXB_STATUS_OK;
}

 lxb_html_tree_insertion_mode_f lxb_html_tree_template_insertion_pop(lxb_html_tree_t* tree)
{
    lxb_html_tree_template_insertion_t* tmp_ins = void;

    tmp_ins = cast(lxb_html_tree_template_insertion_t*)
              lexbor_array_obj_pop(tree.template_insertion_modes);
    if (tmp_ins == null) {
        return null;
    }

    return tmp_ins.mode;
}

// D port: implementation not needed by parserino, not ported.
