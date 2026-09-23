module parserino.lexbor.html.interfaces.title_element;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.interface_;
public import parserino.lexbor.html.interfaces.element;
import parserino.lexbor.html.interfaces.document;
import parserino.lexbor.dom.interfaces.text;

extern(C) @nogc nothrow:
__gshared:

// ---- title_element.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
struct lxb_html_title_element {
    lxb_html_element_t element;

    lexbor_str_t* strict_text;
}





// ---- title_element.c ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */

lxb_html_title_element_t* lxb_html_title_element_interface_create(lxb_html_document_t* document)
{
    lxb_html_title_element_t* element = void;

    element = cast(lxb_html_title_element*) lexbor_mraw_calloc(document.dom_document.mraw,
                                 lxb_html_title_element_t.sizeof);
    if (element == null) {
        return null;
    }

    lxb_dom_node_t* node = (cast(lxb_dom_node_t*) (element));

    node.owner_document = lxb_html_document_original_ref(document);
    node.type = LXB_DOM_NODE_TYPE_ELEMENT;

    return element;
}

lxb_html_title_element_t* lxb_html_title_element_interface_destroy(lxb_html_title_element_t* title)
{
    lexbor_str_t* text = void;
    lxb_dom_document_t* doc = (cast(lxb_dom_node_t*) (title)).owner_document;

    text = title.strict_text;

    cast(void) lxb_dom_node_interface_destroy((cast(lxb_dom_node_t*) (title)));

    if (text != null) {
        lexbor_str_destroy(text, doc.text, false);
        lxb_dom_document_destroy_struct(doc, text);
    }

    return null;
}

const(lxb_char_t)* lxb_html_title_element_text(lxb_html_title_element_t* title, size_t* len)
{
    lxb_dom_text_t* text = void; /* D port: hoisted, goto may not skip it */

    if ((cast(lxb_dom_node_t*) (title)).first_child == null) {
        goto failed;
    }

    if ((cast(lxb_dom_node_t*) (title)).first_child.type != LXB_DOM_NODE_TYPE_TEXT) {
        goto failed;
    }

    text = (cast(lxb_dom_text_t*) ((cast(lxb_dom_node_t*) (title)).first_child));

    if (len != null) {
        *len = text.char_data.data.length;
    }

    return text.char_data.data.data;

failed:

    if (len != null) {
        *len = 0;
    }

    return null;
}

const(lxb_char_t)* lxb_html_title_element_strict_text(lxb_html_title_element_t* title, size_t* len)
{
    const(lxb_char_t)* text = void;
    size_t text_len = void;

    lxb_dom_document_t* doc = (cast(lxb_dom_node_t*) (title)).owner_document;

    text = lxb_html_title_element_text(title, &text_len);
    if (text == null) {
        goto failed;
    }

    if (title.strict_text != null) {
        if (title.strict_text.length < text_len) {
            const(lxb_char_t)* data = void;

            data = lexbor_str_realloc(title.strict_text,
                                      doc.text, (text_len + 1));
            if (data == null) {
                goto failed;
            }
        }
    }
    else {
        title.strict_text = cast(lexbor_str_t*) lxb_dom_document_create_struct(doc,
                                                            lexbor_str_t.sizeof);
        if (title.strict_text == null) {
            goto failed;
        }

        lexbor_str_init(title.strict_text, doc.text, text_len);
        if (title.strict_text.data == null) {
            title.strict_text = cast(lexbor_str_t*) lxb_dom_document_destroy_struct(doc,
                                                                 title.strict_text);
            goto failed;
        }
    }

    memcpy(title.strict_text.data, text, lxb_char_t.sizeof * text_len);

    title.strict_text.data[text_len] = 0x00;
    title.strict_text.length = text_len;

    lexbor_str_strip_collapse_whitespace(title.strict_text);

    if (len != null) {
        *len = title.strict_text.length;
    }

    return title.strict_text.data;

failed:

    if (len != null) {
        *len = 0;
    }

    return null;
}
