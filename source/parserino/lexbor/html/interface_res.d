module parserino.lexbor.html.interface_res;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.dom.interfaces.cdata_section;
public import parserino.lexbor.dom.interfaces.character_data;
public import parserino.lexbor.dom.interfaces.comment;
public import parserino.lexbor.dom.interfaces.document;
public import parserino.lexbor.dom.interfaces.document_fragment;
public import parserino.lexbor.dom.interfaces.document_type;
public import parserino.lexbor.dom.interfaces.element;
public import parserino.lexbor.dom.interfaces.event_target;
public import parserino.lexbor.dom.interfaces.node;
public import parserino.lexbor.dom.interfaces.processing_instruction;
public import parserino.lexbor.dom.interfaces.shadow_root;
public import parserino.lexbor.dom.interfaces.text;
public import parserino.lexbor.html.interfaces.document;
public import parserino.lexbor.html.interfaces.anchor_element;
public import parserino.lexbor.html.interfaces.area_element;
public import parserino.lexbor.html.interfaces.audio_element;
public import parserino.lexbor.html.interfaces.br_element;
public import parserino.lexbor.html.interfaces.base_element;
public import parserino.lexbor.html.interfaces.body_element;
public import parserino.lexbor.html.interfaces.button_element;
public import parserino.lexbor.html.interfaces.canvas_element;
public import parserino.lexbor.html.interfaces.d_list_element;
public import parserino.lexbor.html.interfaces.data_element;
public import parserino.lexbor.html.interfaces.data_list_element;
public import parserino.lexbor.html.interfaces.details_element;
public import parserino.lexbor.html.interfaces.dialog_element;
public import parserino.lexbor.html.interfaces.directory_element;
public import parserino.lexbor.html.interfaces.div_element;
public import parserino.lexbor.html.interfaces.element;
public import parserino.lexbor.html.interfaces.embed_element;
public import parserino.lexbor.html.interfaces.field_set_element;
public import parserino.lexbor.html.interfaces.font_element;
public import parserino.lexbor.html.interfaces.form_element;
public import parserino.lexbor.html.interfaces.frame_element;
public import parserino.lexbor.html.interfaces.frame_set_element;
public import parserino.lexbor.html.interfaces.hr_element;
public import parserino.lexbor.html.interfaces.head_element;
public import parserino.lexbor.html.interfaces.heading_element;
public import parserino.lexbor.html.interfaces.html_element;
public import parserino.lexbor.html.interfaces.iframe_element;
public import parserino.lexbor.html.interfaces.image_element;
public import parserino.lexbor.html.interfaces.input_element;
public import parserino.lexbor.html.interfaces.li_element;
public import parserino.lexbor.html.interfaces.label_element;
public import parserino.lexbor.html.interfaces.legend_element;
public import parserino.lexbor.html.interfaces.link_element;
public import parserino.lexbor.html.interfaces.map_element;
public import parserino.lexbor.html.interfaces.marquee_element;
public import parserino.lexbor.html.interfaces.media_element;
public import parserino.lexbor.html.interfaces.menu_element;
public import parserino.lexbor.html.interfaces.meta_element;
public import parserino.lexbor.html.interfaces.meter_element;
public import parserino.lexbor.html.interfaces.mod_element;
public import parserino.lexbor.html.interfaces.o_list_element;
public import parserino.lexbor.html.interfaces.object_element;
public import parserino.lexbor.html.interfaces.opt_group_element;
public import parserino.lexbor.html.interfaces.option_element;
public import parserino.lexbor.html.interfaces.output_element;
public import parserino.lexbor.html.interfaces.paragraph_element;
public import parserino.lexbor.html.interfaces.param_element;
public import parserino.lexbor.html.interfaces.picture_element;
public import parserino.lexbor.html.interfaces.pre_element;
public import parserino.lexbor.html.interfaces.progress_element;
public import parserino.lexbor.html.interfaces.quote_element;
public import parserino.lexbor.html.interfaces.script_element;
public import parserino.lexbor.html.interfaces.select_element;
public import parserino.lexbor.html.interfaces.slot_element;
public import parserino.lexbor.html.interfaces.source_element;
public import parserino.lexbor.html.interfaces.span_element;
public import parserino.lexbor.html.interfaces.style_element;
public import parserino.lexbor.html.interfaces.table_caption_element;
public import parserino.lexbor.html.interfaces.table_cell_element;
public import parserino.lexbor.html.interfaces.table_col_element;
public import parserino.lexbor.html.interfaces.table_element;
public import parserino.lexbor.html.interfaces.table_row_element;
public import parserino.lexbor.html.interfaces.table_section_element;
public import parserino.lexbor.html.interfaces.template_element;
public import parserino.lexbor.html.interfaces.text_area_element;
public import parserino.lexbor.html.interfaces.time_element;
public import parserino.lexbor.html.interfaces.title_element;
public import parserino.lexbor.html.interfaces.track_element;
public import parserino.lexbor.html.interfaces.u_list_element;
public import parserino.lexbor.html.interfaces.unknown_element;
public import parserino.lexbor.html.interfaces.video_element;
public import parserino.lexbor.html.interfaces.window;

extern(C) @nogc nothrow:
__gshared:

// ---- interface_res.h ----
/*
 * Copyright (C) 2018-2025 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

/*
 * Caution!
 * This file generated by the script "utils/lexbor/tag_ns/tags.py"!
 * Do not change this file!
 */
 void* lxb_dom_element_interface_create_wrapper(void* interface_)
{
    return lxb_dom_element_interface_create(cast(lxb_dom_document*) interface_);
}

 void* lxb_dom_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_dom_element_interface_destroy(cast(lxb_dom_element*) interface_);
}

 void* lxb_html_unknown_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_unknown_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_unknown_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_unknown_element_interface_destroy(cast(lxb_html_unknown_element*) interface_);
}

 void* lxb_html_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_element_interface_destroy(cast(lxb_html_element*) interface_);
}

 void* lxb_dom_text_interface_create_wrapper(void* interface_)
{
    return lxb_dom_text_interface_create(cast(lxb_dom_document*) interface_);
}

 void* lxb_dom_text_interface_destroy_wrapper(void* interface_)
{
    return lxb_dom_text_interface_destroy(cast(lxb_dom_text*) interface_);
}

 void* lxb_html_document_interface_create_wrapper(void* interface_)
{
    return lxb_html_document_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_document_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_document_interface_destroy(cast(lxb_html_document*) interface_);
}

 void* lxb_dom_comment_interface_create_wrapper(void* interface_)
{
    return lxb_dom_comment_interface_create(cast(lxb_dom_document*) interface_);
}

 void* lxb_dom_comment_interface_destroy_wrapper(void* interface_)
{
    return lxb_dom_comment_interface_destroy(cast(lxb_dom_comment*) interface_);
}

 void* lxb_dom_document_type_interface_create_wrapper(void* interface_)
{
    return lxb_dom_document_type_interface_create(cast(lxb_dom_document*) interface_);
}

 void* lxb_dom_document_type_interface_destroy_wrapper(void* interface_)
{
    return lxb_dom_document_type_interface_destroy(cast(lxb_dom_document_type*) interface_);
}

 void* lxb_html_anchor_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_anchor_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_anchor_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_anchor_element_interface_destroy(cast(lxb_html_anchor_element*) interface_);
}

 void* lxb_html_area_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_area_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_area_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_area_element_interface_destroy(cast(lxb_html_area_element*) interface_);
}

 void* lxb_html_audio_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_audio_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_audio_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_audio_element_interface_destroy(cast(lxb_html_audio_element*) interface_);
}

 void* lxb_html_base_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_base_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_base_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_base_element_interface_destroy(cast(lxb_html_base_element*) interface_);
}

 void* lxb_html_quote_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_quote_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_quote_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_quote_element_interface_destroy(cast(lxb_html_quote_element*) interface_);
}

 void* lxb_html_body_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_body_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_body_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_body_element_interface_destroy(cast(lxb_html_body_element*) interface_);
}

 void* lxb_html_br_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_br_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_br_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_br_element_interface_destroy(cast(lxb_html_br_element*) interface_);
}

 void* lxb_html_button_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_button_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_button_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_button_element_interface_destroy(cast(lxb_html_button_element*) interface_);
}

 void* lxb_html_canvas_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_canvas_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_canvas_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_canvas_element_interface_destroy(cast(lxb_html_canvas_element*) interface_);
}

 void* lxb_html_table_caption_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_table_caption_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_table_caption_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_table_caption_element_interface_destroy(cast(lxb_html_table_caption_element*) interface_);
}

 void* lxb_html_table_col_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_table_col_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_table_col_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_table_col_element_interface_destroy(cast(lxb_html_table_col_element*) interface_);
}

 void* lxb_html_data_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_data_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_data_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_data_element_interface_destroy(cast(lxb_html_data_element*) interface_);
}

 void* lxb_html_data_list_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_data_list_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_data_list_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_data_list_element_interface_destroy(cast(lxb_html_data_list_element*) interface_);
}

 void* lxb_html_mod_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_mod_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_mod_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_mod_element_interface_destroy(cast(lxb_html_mod_element*) interface_);
}

 void* lxb_html_details_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_details_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_details_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_details_element_interface_destroy(cast(lxb_html_details_element*) interface_);
}

 void* lxb_html_dialog_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_dialog_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_dialog_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_dialog_element_interface_destroy(cast(lxb_html_dialog_element*) interface_);
}

 void* lxb_html_directory_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_directory_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_directory_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_directory_element_interface_destroy(cast(lxb_html_directory_element*) interface_);
}

 void* lxb_html_div_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_div_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_div_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_div_element_interface_destroy(cast(lxb_html_div_element*) interface_);
}

 void* lxb_html_d_list_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_d_list_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_d_list_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_d_list_element_interface_destroy(cast(lxb_html_d_list_element*) interface_);
}

 void* lxb_html_embed_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_embed_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_embed_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_embed_element_interface_destroy(cast(lxb_html_embed_element*) interface_);
}

 void* lxb_html_field_set_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_field_set_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_field_set_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_field_set_element_interface_destroy(cast(lxb_html_field_set_element*) interface_);
}

 void* lxb_html_font_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_font_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_font_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_font_element_interface_destroy(cast(lxb_html_font_element*) interface_);
}

 void* lxb_html_form_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_form_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_form_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_form_element_interface_destroy(cast(lxb_html_form_element*) interface_);
}

 void* lxb_html_frame_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_frame_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_frame_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_frame_element_interface_destroy(cast(lxb_html_frame_element*) interface_);
}

 void* lxb_html_frame_set_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_frame_set_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_frame_set_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_frame_set_element_interface_destroy(cast(lxb_html_frame_set_element*) interface_);
}

 void* lxb_html_heading_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_heading_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_heading_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_heading_element_interface_destroy(cast(lxb_html_heading_element*) interface_);
}

 void* lxb_html_head_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_head_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_head_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_head_element_interface_destroy(cast(lxb_html_head_element*) interface_);
}

 void* lxb_html_hr_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_hr_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_hr_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_hr_element_interface_destroy(cast(lxb_html_hr_element*) interface_);
}

 void* lxb_html_html_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_html_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_html_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_html_element_interface_destroy(cast(lxb_html_html_element*) interface_);
}

 void* lxb_html_iframe_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_iframe_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_iframe_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_iframe_element_interface_destroy(cast(lxb_html_iframe_element*) interface_);
}

 void* lxb_html_image_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_image_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_image_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_image_element_interface_destroy(cast(lxb_html_image_element*) interface_);
}

 void* lxb_html_input_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_input_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_input_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_input_element_interface_destroy(cast(lxb_html_input_element*) interface_);
}

 void* lxb_html_label_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_label_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_label_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_label_element_interface_destroy(cast(lxb_html_label_element*) interface_);
}

 void* lxb_html_legend_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_legend_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_legend_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_legend_element_interface_destroy(cast(lxb_html_legend_element*) interface_);
}

 void* lxb_html_li_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_li_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_li_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_li_element_interface_destroy(cast(lxb_html_li_element*) interface_);
}

 void* lxb_html_link_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_link_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_link_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_link_element_interface_destroy(cast(lxb_html_link_element*) interface_);
}

 void* lxb_html_pre_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_pre_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_pre_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_pre_element_interface_destroy(cast(lxb_html_pre_element*) interface_);
}

 void* lxb_html_map_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_map_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_map_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_map_element_interface_destroy(cast(lxb_html_map_element*) interface_);
}

 void* lxb_html_marquee_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_marquee_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_marquee_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_marquee_element_interface_destroy(cast(lxb_html_marquee_element*) interface_);
}

 void* lxb_html_menu_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_menu_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_menu_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_menu_element_interface_destroy(cast(lxb_html_menu_element*) interface_);
}

 void* lxb_html_meta_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_meta_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_meta_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_meta_element_interface_destroy(cast(lxb_html_meta_element*) interface_);
}

 void* lxb_html_meter_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_meter_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_meter_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_meter_element_interface_destroy(cast(lxb_html_meter_element*) interface_);
}

 void* lxb_html_object_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_object_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_object_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_object_element_interface_destroy(cast(lxb_html_object_element*) interface_);
}

 void* lxb_html_o_list_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_o_list_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_o_list_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_o_list_element_interface_destroy(cast(lxb_html_o_list_element*) interface_);
}

 void* lxb_html_opt_group_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_opt_group_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_opt_group_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_opt_group_element_interface_destroy(cast(lxb_html_opt_group_element*) interface_);
}

 void* lxb_html_option_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_option_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_option_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_option_element_interface_destroy(cast(lxb_html_option_element*) interface_);
}

 void* lxb_html_output_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_output_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_output_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_output_element_interface_destroy(cast(lxb_html_output_element*) interface_);
}

 void* lxb_html_paragraph_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_paragraph_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_paragraph_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_paragraph_element_interface_destroy(cast(lxb_html_paragraph_element*) interface_);
}

 void* lxb_html_param_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_param_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_param_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_param_element_interface_destroy(cast(lxb_html_param_element*) interface_);
}

 void* lxb_html_picture_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_picture_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_picture_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_picture_element_interface_destroy(cast(lxb_html_picture_element*) interface_);
}

 void* lxb_html_progress_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_progress_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_progress_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_progress_element_interface_destroy(cast(lxb_html_progress_element*) interface_);
}

 void* lxb_html_script_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_script_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_script_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_script_element_interface_destroy(cast(lxb_html_script_element*) interface_);
}

 void* lxb_html_select_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_select_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_select_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_select_element_interface_destroy(cast(lxb_html_select_element*) interface_);
}

 void* lxb_html_slot_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_slot_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_slot_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_slot_element_interface_destroy(cast(lxb_html_slot_element*) interface_);
}

 void* lxb_html_source_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_source_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_source_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_source_element_interface_destroy(cast(lxb_html_source_element*) interface_);
}

 void* lxb_html_span_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_span_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_span_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_span_element_interface_destroy(cast(lxb_html_span_element*) interface_);
}

 void* lxb_html_style_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_style_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_style_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_style_element_interface_destroy(cast(lxb_html_style_element*) interface_);
}

 void* lxb_html_table_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_table_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_table_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_table_element_interface_destroy(cast(lxb_html_table_element*) interface_);
}

 void* lxb_html_table_section_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_table_section_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_table_section_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_table_section_element_interface_destroy(cast(lxb_html_table_section_element*) interface_);
}

 void* lxb_html_table_cell_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_table_cell_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_table_cell_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_table_cell_element_interface_destroy(cast(lxb_html_table_cell_element*) interface_);
}

 void* lxb_html_template_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_template_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_template_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_template_element_interface_destroy(cast(lxb_html_template_element*) interface_);
}

 void* lxb_html_text_area_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_text_area_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_text_area_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_text_area_element_interface_destroy(cast(lxb_html_text_area_element*) interface_);
}

 void* lxb_html_time_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_time_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_time_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_time_element_interface_destroy(cast(lxb_html_time_element*) interface_);
}

 void* lxb_html_title_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_title_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_title_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_title_element_interface_destroy(cast(lxb_html_title_element*) interface_);
}

 void* lxb_html_table_row_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_table_row_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_table_row_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_table_row_element_interface_destroy(cast(lxb_html_table_row_element*) interface_);
}

 void* lxb_html_track_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_track_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_track_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_track_element_interface_destroy(cast(lxb_html_track_element*) interface_);
}

 void* lxb_html_u_list_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_u_list_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_u_list_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_u_list_element_interface_destroy(cast(lxb_html_u_list_element*) interface_);
}

 void* lxb_html_video_element_interface_create_wrapper(void* interface_)
{
    return lxb_html_video_element_interface_create(cast(lxb_html_document*) interface_);
}

 void* lxb_html_video_element_interface_destroy_wrapper(void* interface_)
{
    return lxb_html_video_element_interface_destroy(cast(lxb_html_video_element*) interface_);
}

lxb_dom_interface_constructor_f[LXB_NS__LAST_ENTRY][LXB_TAG__LAST_ENTRY] lxb_html_interface_res_constructors = [
    /* LXB_TAG__UNDEF */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG__END_OF_FILE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG__TEXT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_text_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_text_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_text_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG__DOCUMENT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_document_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG__EM_COMMENT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_comment_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_comment_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_comment_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG__EM_DOCTYPE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_document_type_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_A */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_anchor_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ABBR */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ACRONYM */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ADDRESS */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ALTGLYPH */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ALTGLYPHDEF */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ALTGLYPHITEM */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ANIMATECOLOR */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ANIMATEMOTION */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ANIMATETRANSFORM */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ANNOTATION_XML */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_APPLET */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_AREA */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_area_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ARTICLE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ASIDE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_AUDIO */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_audio_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_B */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_BASE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_base_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_BASEFONT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_BDI */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_BDO */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_BGSOUND */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_BIG */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_BLINK */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_BLOCKQUOTE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_quote_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_BODY */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_body_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_BR */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_br_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_BUTTON */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_button_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_CANVAS */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_canvas_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_CAPTION */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_table_caption_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_CENTER */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_CITE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_CLIPPATH */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_CODE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_COL */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_table_col_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_COLGROUP */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_table_col_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DATA */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_data_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DATALIST */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_data_list_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DD */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DEL */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_mod_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DESC */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DETAILS */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_details_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DFN */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DIALOG */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_dialog_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DIR */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_directory_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DIV */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_div_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DL */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_d_list_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_DT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_EM */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_EMBED */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_embed_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEBLEND */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FECOLORMATRIX */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FECOMPONENTTRANSFER */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FECOMPOSITE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FECONVOLVEMATRIX */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEDIFFUSELIGHTING */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEDISPLACEMENTMAP */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEDISTANTLIGHT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEDROPSHADOW */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEFLOOD */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEFUNCA */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEFUNCB */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEFUNCG */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEFUNCR */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEGAUSSIANBLUR */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEIMAGE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEMERGE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEMERGENODE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEMORPHOLOGY */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEOFFSET */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FEPOINTLIGHT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FESPECULARLIGHTING */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FESPOTLIGHT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FETILE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FETURBULENCE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FIELDSET */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_field_set_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FIGCAPTION */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FIGURE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FONT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_font_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FOOTER */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FOREIGNOBJECT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FORM */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_form_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FRAME */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_frame_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_FRAMESET */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_frame_set_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_GLYPHREF */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_H1 */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_heading_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_H2 */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_heading_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_H3 */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_heading_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_H4 */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_heading_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_H5 */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_heading_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_H6 */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_heading_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_HEAD */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_head_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_HEADER */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_HGROUP */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_HR */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_hr_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_HTML */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_I */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_IFRAME */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_iframe_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_IMAGE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_image_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_IMG */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_image_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_INPUT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_input_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_INS */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_mod_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_ISINDEX */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_KBD */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_KEYGEN */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_LABEL */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_label_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_LEGEND */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_legend_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_LI */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_li_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_LINEARGRADIENT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_LINK */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_link_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_LISTING */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_pre_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MAIN */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MALIGNMARK */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MAP */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_map_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MARK */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MARQUEE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_marquee_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MATH */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MENU */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_menu_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_META */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_meta_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_METER */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_meter_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MFENCED */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MGLYPH */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MI */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MN */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MO */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MS */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MTEXT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_MULTICOL */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_NAV */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_NEXTID */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_NOBR */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_NOEMBED */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_NOFRAMES */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_NOSCRIPT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_OBJECT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_object_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_OL */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_o_list_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_OPTGROUP */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_opt_group_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_OPTION */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_option_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_OUTPUT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_output_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_P */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_paragraph_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_PARAM */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_param_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_PATH */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_PICTURE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_picture_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_PLAINTEXT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_PRE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_pre_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_PROGRESS */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_progress_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_Q */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_quote_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_RADIALGRADIENT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_RB */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_RP */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_RT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_RTC */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_RUBY */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_S */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SAMP */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SCRIPT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_script_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SECTION */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SELECT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_select_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SLOT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_slot_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SMALL */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SOURCE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_source_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SPACER */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SPAN */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_span_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_STRIKE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_STRONG */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_STYLE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_style_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SUB */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SUMMARY */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SUP */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_SVG */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TABLE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_table_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TBODY */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_table_section_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TD */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_table_cell_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TEMPLATE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_template_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TEXTAREA */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_text_area_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TEXTPATH */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TFOOT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_table_section_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TH */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_table_cell_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_THEAD */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_table_section_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TIME */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_time_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TITLE */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_title_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TR */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_table_row_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TRACK */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_track_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_TT */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_U */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_UL */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_u_list_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_VAR */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_VIDEO */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_video_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_WBR */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ],
    /* LXB_TAG_XMP */
    [
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_unknown_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_html_pre_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper,
        cast(lxb_dom_interface_constructor_f) &lxb_dom_element_interface_create_wrapper
    ]
];

lxb_dom_interface_destructor_f[LXB_NS__LAST_ENTRY][LXB_TAG__LAST_ENTRY] lxb_html_interface_res_destructor = [
    /* LXB_TAG__UNDEF */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG__END_OF_FILE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG__TEXT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_text_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_text_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_text_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG__DOCUMENT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_document_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG__EM_COMMENT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_comment_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_comment_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_comment_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG__EM_DOCTYPE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_document_type_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_A */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_anchor_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ABBR */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ACRONYM */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ADDRESS */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ALTGLYPH */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ALTGLYPHDEF */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ALTGLYPHITEM */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ANIMATECOLOR */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ANIMATEMOTION */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ANIMATETRANSFORM */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ANNOTATION_XML */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_APPLET */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_AREA */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_area_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ARTICLE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ASIDE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_AUDIO */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_audio_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_B */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_BASE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_base_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_BASEFONT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_BDI */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_BDO */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_BGSOUND */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_BIG */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_BLINK */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_BLOCKQUOTE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_quote_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_BODY */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_body_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_BR */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_br_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_BUTTON */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_button_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_CANVAS */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_canvas_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_CAPTION */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_table_caption_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_CENTER */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_CITE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_CLIPPATH */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_CODE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_COL */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_table_col_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_COLGROUP */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_table_col_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DATA */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_data_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DATALIST */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_data_list_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DD */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DEL */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_mod_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DESC */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DETAILS */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_details_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DFN */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DIALOG */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_dialog_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DIR */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_directory_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DIV */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_div_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DL */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_d_list_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_DT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_EM */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_EMBED */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_embed_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEBLEND */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FECOLORMATRIX */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FECOMPONENTTRANSFER */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FECOMPOSITE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FECONVOLVEMATRIX */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEDIFFUSELIGHTING */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEDISPLACEMENTMAP */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEDISTANTLIGHT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEDROPSHADOW */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEFLOOD */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEFUNCA */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEFUNCB */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEFUNCG */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEFUNCR */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEGAUSSIANBLUR */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEIMAGE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEMERGE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEMERGENODE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEMORPHOLOGY */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEOFFSET */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FEPOINTLIGHT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FESPECULARLIGHTING */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FESPOTLIGHT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FETILE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FETURBULENCE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FIELDSET */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_field_set_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FIGCAPTION */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FIGURE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FONT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_font_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FOOTER */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FOREIGNOBJECT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FORM */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_form_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FRAME */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_frame_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_FRAMESET */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_frame_set_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_GLYPHREF */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_H1 */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_heading_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_H2 */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_heading_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_H3 */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_heading_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_H4 */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_heading_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_H5 */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_heading_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_H6 */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_heading_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_HEAD */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_head_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_HEADER */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_HGROUP */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_HR */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_hr_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_HTML */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_I */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_IFRAME */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_iframe_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_IMAGE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_image_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_IMG */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_image_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_INPUT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_input_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_INS */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_mod_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_ISINDEX */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_KBD */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_KEYGEN */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_LABEL */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_label_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_LEGEND */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_legend_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_LI */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_li_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_LINEARGRADIENT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_LINK */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_link_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_LISTING */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_pre_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MAIN */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MALIGNMARK */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MAP */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_map_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MARK */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MARQUEE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_marquee_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MATH */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MENU */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_menu_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_META */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_meta_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_METER */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_meter_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MFENCED */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MGLYPH */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MI */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MN */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MO */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MS */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MTEXT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_MULTICOL */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_NAV */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_NEXTID */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_NOBR */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_NOEMBED */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_NOFRAMES */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_NOSCRIPT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_OBJECT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_object_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_OL */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_o_list_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_OPTGROUP */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_opt_group_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_OPTION */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_option_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_OUTPUT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_output_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_P */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_paragraph_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_PARAM */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_param_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_PATH */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_PICTURE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_picture_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_PLAINTEXT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_PRE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_pre_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_PROGRESS */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_progress_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_Q */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_quote_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_RADIALGRADIENT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_RB */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_RP */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_RT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_RTC */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_RUBY */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_S */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SAMP */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SCRIPT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_script_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SECTION */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SELECT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_select_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SLOT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_slot_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SMALL */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SOURCE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_source_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SPACER */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SPAN */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_span_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_STRIKE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_STRONG */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_STYLE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_style_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SUB */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SUMMARY */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SUP */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_SVG */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TABLE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_table_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TBODY */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_table_section_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TD */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_table_cell_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TEMPLATE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_template_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TEXTAREA */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_text_area_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TEXTPATH */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TFOOT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_table_section_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TH */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_table_cell_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_THEAD */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_table_section_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TIME */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_time_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TITLE */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_title_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TR */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_table_row_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TRACK */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_track_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_TT */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_U */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_UL */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_u_list_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_VAR */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_VIDEO */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_video_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_WBR */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ],
    /* LXB_TAG_XMP */
    [
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_unknown_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_html_pre_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper,
        cast(lxb_dom_interface_destructor_f) &lxb_dom_element_interface_destroy_wrapper
    ]
];
