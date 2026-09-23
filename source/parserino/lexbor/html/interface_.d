module parserino.lexbor.html.interface_;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.base;
public import parserino.lexbor.tag.const_;
public import parserino.lexbor.ns.const_;
public import parserino.lexbor.dom.interface_;
import parserino.lexbor.core.mraw;
import parserino.lexbor.html.interfaces.document;
import parserino.lexbor.html.interface_res;

extern(C) @nogc nothrow:
__gshared:

// ---- interface.h ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_html_document_t = lxb_html_document;
alias lxb_html_anchor_element_t = lxb_html_anchor_element;
alias lxb_html_area_element_t = lxb_html_area_element;
alias lxb_html_audio_element_t = lxb_html_audio_element;
alias lxb_html_br_element_t = lxb_html_br_element;
alias lxb_html_base_element_t = lxb_html_base_element;
alias lxb_html_body_element_t = lxb_html_body_element;
alias lxb_html_button_element_t = lxb_html_button_element;
alias lxb_html_canvas_element_t = lxb_html_canvas_element;
alias lxb_html_d_list_element_t = lxb_html_d_list_element;
alias lxb_html_data_element_t = lxb_html_data_element;
alias lxb_html_data_list_element_t = lxb_html_data_list_element;
alias lxb_html_details_element_t = lxb_html_details_element;
alias lxb_html_dialog_element_t = lxb_html_dialog_element;
alias lxb_html_directory_element_t = lxb_html_directory_element;
alias lxb_html_div_element_t = lxb_html_div_element;
alias lxb_html_element_t = lxb_html_element;
alias lxb_html_embed_element_t = lxb_html_embed_element;
alias lxb_html_field_set_element_t = lxb_html_field_set_element;
alias lxb_html_font_element_t = lxb_html_font_element;
alias lxb_html_form_element_t = lxb_html_form_element;
alias lxb_html_frame_element_t = lxb_html_frame_element;
alias lxb_html_frame_set_element_t = lxb_html_frame_set_element;
alias lxb_html_hr_element_t = lxb_html_hr_element;
alias lxb_html_head_element_t = lxb_html_head_element;
alias lxb_html_heading_element_t = lxb_html_heading_element;
alias lxb_html_html_element_t = lxb_html_html_element;
alias lxb_html_iframe_element_t = lxb_html_iframe_element;
alias lxb_html_image_element_t = lxb_html_image_element;
alias lxb_html_input_element_t = lxb_html_input_element;
alias lxb_html_li_element_t = lxb_html_li_element;
alias lxb_html_label_element_t = lxb_html_label_element;
alias lxb_html_legend_element_t = lxb_html_legend_element;
alias lxb_html_link_element_t = lxb_html_link_element;
alias lxb_html_map_element_t = lxb_html_map_element;
alias lxb_html_marquee_element_t = lxb_html_marquee_element;
alias lxb_html_media_element_t = lxb_html_media_element;
alias lxb_html_menu_element_t = lxb_html_menu_element;
alias lxb_html_meta_element_t = lxb_html_meta_element;
alias lxb_html_meter_element_t = lxb_html_meter_element;
alias lxb_html_mod_element_t = lxb_html_mod_element;
alias lxb_html_o_list_element_t = lxb_html_o_list_element;
alias lxb_html_object_element_t = lxb_html_object_element;
alias lxb_html_opt_group_element_t = lxb_html_opt_group_element;
alias lxb_html_option_element_t = lxb_html_option_element;
alias lxb_html_output_element_t = lxb_html_output_element;
alias lxb_html_paragraph_element_t = lxb_html_paragraph_element;
alias lxb_html_param_element_t = lxb_html_param_element;
alias lxb_html_picture_element_t = lxb_html_picture_element;
alias lxb_html_pre_element_t = lxb_html_pre_element;
alias lxb_html_progress_element_t = lxb_html_progress_element;
alias lxb_html_quote_element_t = lxb_html_quote_element;
alias lxb_html_script_element_t = lxb_html_script_element;
alias lxb_html_select_element_t = lxb_html_select_element;
alias lxb_html_slot_element_t = lxb_html_slot_element;
alias lxb_html_source_element_t = lxb_html_source_element;
alias lxb_html_span_element_t = lxb_html_span_element;
alias lxb_html_style_element_t = lxb_html_style_element;
alias lxb_html_table_caption_element_t = lxb_html_table_caption_element;
alias lxb_html_table_cell_element_t = lxb_html_table_cell_element;
alias lxb_html_table_col_element_t = lxb_html_table_col_element;
alias lxb_html_table_element_t = lxb_html_table_element;
alias lxb_html_table_row_element_t = lxb_html_table_row_element;
alias lxb_html_table_section_element_t = lxb_html_table_section_element;
alias lxb_html_template_element_t = lxb_html_template_element;
alias lxb_html_text_area_element_t = lxb_html_text_area_element;
alias lxb_html_time_element_t = lxb_html_time_element;
alias lxb_html_title_element_t = lxb_html_title_element;
alias lxb_html_track_element_t = lxb_html_track_element;
alias lxb_html_u_list_element_t = lxb_html_u_list_element;
alias lxb_html_unknown_element_t = lxb_html_unknown_element;
alias lxb_html_video_element_t = lxb_html_video_element;
alias lxb_html_window_t = lxb_html_window;




// ---- interface.c ----
/*
 * Copyright (C) 2018-2021 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */


lxb_dom_interface_t* lxb_html_interface_create(lxb_html_document_t* document, lxb_tag_id_t tag_id, lxb_ns_id_t ns)
{
    lxb_dom_node_t* node = void;

    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        if (ns == LXB_NS_HTML) {
            lxb_html_unknown_element_t* unel = void;

            unel = lxb_html_unknown_element_interface_create(document);
            node = (cast(lxb_dom_node_t*) (unel));
        }
        else if (ns == LXB_NS_SVG) {
            /* TODO: For this need implement SVGElement */
            lxb_dom_element_t* domel = void;

            domel = lxb_dom_element_interface_create(&document.dom_document);
            node = (cast(lxb_dom_node_t*) (domel));
        }
        else {
            lxb_dom_element_t* domel = void;

            domel = lxb_dom_element_interface_create(&document.dom_document);
            node = (cast(lxb_dom_node_t*) (domel));
        }
    }
    else {
        node = cast(lxb_dom_node*) lxb_html_interface_res_constructors[tag_id][ns](document);
    }

    if (node == null) {
        return null;
    }

    node.local_name = tag_id;
    node.ns = ns;

    return node;
}

lxb_dom_interface_t* lxb_html_interface_clone(lxb_dom_document_t* document, const(lxb_dom_interface_t)* intrfc)
{
    const(lxb_dom_node_t)* node = cast(const(lxb_dom_node)*) intrfc;

    if (document == null) {
        document = cast(lxb_dom_document*) node.owner_document;
    }

    switch (node.type) {
        case LXB_DOM_NODE_TYPE_ELEMENT:
            return lxb_html_interface_clone_element(document, cast(const(lxb_dom_element)*) intrfc);

        case LXB_DOM_NODE_TYPE_TEXT:
            return lxb_dom_text_interface_clone(document, cast(const(lxb_dom_text)*) intrfc);

        case LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION:
            return lxb_dom_processing_instruction_interface_clone(document,
                                                                  cast(const(lxb_dom_processing_instruction)*) intrfc);
        case LXB_DOM_NODE_TYPE_COMMENT:
            return lxb_dom_comment_interface_clone(document, cast(const(lxb_dom_comment)*) intrfc);

        case LXB_DOM_NODE_TYPE_DOCUMENT:
            return lxb_dom_document_interface_clone(document, cast(const(lxb_dom_document)*) intrfc);

        case LXB_DOM_NODE_TYPE_DOCUMENT_TYPE:
            return lxb_dom_document_type_interface_clone(document, cast(const(lxb_dom_document_type)*) intrfc);

        default:
            return lxb_dom_node_interface_clone(document, node, false);
    }
}

private lxb_dom_element_t* lxb_html_interface_clone_element(lxb_dom_document_t* document, const(lxb_dom_element_t)* element)
{
    lxb_dom_element_t* new_ = void;
    const(lxb_dom_node_t)* node = cast(const(lxb_dom_node_t)*) (cast(lxb_dom_node_t*) (element));

    new_ = cast(lxb_dom_element*) lxb_html_interface_create(cast(lxb_html_document_t*) document,
                                    node.local_name, node.ns);
    if (new_ == null) {
        return null;
    }

    if (lxb_dom_element_interface_copy(new_, element) != LXB_STATUS_OK) {
        return lxb_dom_element_interface_destroy(new_);
    }

    return new_;
}

lxb_dom_interface_t* lxb_html_interface_destroy(lxb_dom_interface_t* intrfc)
{
    if (intrfc == null) {
        return null;
    }

    lxb_dom_node_t* node = cast(lxb_dom_node*) intrfc;

    switch (node.type) {
        case LXB_DOM_NODE_TYPE_TEXT:
        case LXB_DOM_NODE_TYPE_COMMENT:
        case LXB_DOM_NODE_TYPE_ELEMENT:
        case LXB_DOM_NODE_TYPE_DOCUMENT:
        case LXB_DOM_NODE_TYPE_DOCUMENT_TYPE:
            if (node.local_name >= LXB_TAG__LAST_ENTRY) {
                if (node.ns == LXB_NS_HTML) {
                    return lxb_html_unknown_element_interface_destroy(cast(lxb_html_unknown_element*) intrfc);
                }
                else if (node.ns == LXB_NS_SVG) {
                    /* TODO: For this need implement SVGElement */
                    return lxb_dom_element_interface_destroy(cast(lxb_dom_element*) intrfc);
                }
                else {
                    return lxb_dom_element_interface_destroy(cast(lxb_dom_element*) intrfc);
                }
            }
            else {
                return lxb_html_interface_res_destructor[node.local_name][node.ns](intrfc);
            }

        case LXB_DOM_NODE_TYPE_ATTRIBUTE:
            return lxb_dom_attr_interface_destroy(cast(lxb_dom_attr*) intrfc);

        case LXB_DOM_NODE_TYPE_CDATA_SECTION:
            return lxb_dom_cdata_section_interface_destroy(cast(lxb_dom_cdata_section*) intrfc);

        case LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT:
            return lxb_dom_document_fragment_interface_destroy(cast(lxb_dom_document_fragment*) intrfc);

        case LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION:
            return lxb_dom_processing_instruction_interface_destroy(cast(lxb_dom_processing_instruction*) intrfc);

        default:
            return null;
    }
}
