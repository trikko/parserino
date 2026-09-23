module parserino.lexbor.html.tree.insertion_mode;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.token;
public import parserino.lexbor.html.tree;

extern(C) @nogc nothrow:
__gshared:

// ---- insertion_mode.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
 bool lxb_html_tree_insertion_mode_initial(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_before_html(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_before_head(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_head(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_head_noscript(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_after_head(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_body(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_body_skip_new_line(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_body_skip_new_line_textarea(lxb_html_tree_t* tree, lxb_html_token_t* token);

 lxb_status_t lxb_html_tree_insertion_mode_in_body_text_append(lxb_html_tree_t* tree, lexbor_str_t* str);

 bool lxb_html_tree_insertion_mode_text(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_table(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_table_anything_else(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_table_text(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_caption(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_column_group(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_table_body(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_row(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_cell(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_select(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_select_in_table(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_template(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_after_body(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_in_frameset(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_after_frameset(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_after_after_body(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_after_after_frameset(lxb_html_tree_t* tree, lxb_html_token_t* token);

 bool lxb_html_tree_insertion_mode_foreign_content(lxb_html_tree_t* tree, lxb_html_token_t* token);
