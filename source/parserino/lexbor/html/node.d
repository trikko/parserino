module parserino.lexbor.html.node;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.tag.tag;
public import parserino.lexbor.dom.interfaces.node;

extern(C) @nogc nothrow:
__gshared:

// ---- node.h ----
/*
 * Copyright (C) 2020 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
/*
 * Inline functions
 */
 bool lxb_html_node_is_void(lxb_dom_node_t* node)
{
    if (node.ns != LXB_NS_HTML) {
        return false;
    }

    switch (node.local_name) {
        case LXB_TAG_AREA:
        case LXB_TAG_BASE:
        case LXB_TAG_BASEFONT:
        case LXB_TAG_BGSOUND:
        case LXB_TAG_BR:
        case LXB_TAG_COL:
        case LXB_TAG_EMBED:
        case LXB_TAG_FRAME:
        case LXB_TAG_HR:
        case LXB_TAG_IMG:
        case LXB_TAG_INPUT:
        case LXB_TAG_KEYGEN:
        case LXB_TAG_LINK:
        case LXB_TAG_META:
        case LXB_TAG_PARAM:
        case LXB_TAG_SOURCE:
        case LXB_TAG_TRACK:
        case LXB_TAG_WBR:
            return true;

        default:
            return false;
    }

    return false;
}

 bool lxb_html_node_is(const(lxb_dom_node_t)* node, lxb_tag_id_t tag_id)
{
    return node.local_name == tag_id && node.ns == LXB_NS_HTML;
}

/*
 * No inline functions for ABI.
 */

// D port: implementation not needed by parserino, not ported.
