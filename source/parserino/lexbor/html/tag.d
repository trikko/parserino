module parserino.lexbor.html.tag;

// D port of lexbor (https://github.com/lexbor/lexbor), Apache-2.0.
// Original author: Alexander Borisov <borisov@lexbor.com>

public import parserino.lexbor.html.base;
public import parserino.lexbor.tag.tag;
public import parserino.lexbor.ns.ns;
public import parserino.lexbor.html.tag_res;

extern(C) @nogc nothrow:
__gshared:

// ---- tag.h ----
/*
 * Copyright (C) 2018 Alexander Borisov
 *
 * Author: Alexander Borisov <borisov@lexbor.com>
 */
alias lxb_html_tag_category_t = int;

enum lxb_html_tag_category {
    LXB_HTML_TAG_CATEGORY__UNDEF = 0x0000,
    LXB_HTML_TAG_CATEGORY_ORDINARY = 0x0001,
    LXB_HTML_TAG_CATEGORY_SPECIAL = 0x0002,
    LXB_HTML_TAG_CATEGORY_FORMATTING = 0x0004,
    LXB_HTML_TAG_CATEGORY_SCOPE = 0x0008,
    LXB_HTML_TAG_CATEGORY_SCOPE_LIST_ITEM = 0x0010,
    LXB_HTML_TAG_CATEGORY_SCOPE_BUTTON = 0x0020,
    LXB_HTML_TAG_CATEGORY_SCOPE_TABLE = 0x0040,
    LXB_HTML_TAG_CATEGORY_SCOPE_SELECT = 0x0080,
}
alias LXB_HTML_TAG_CATEGORY__UNDEF = lxb_html_tag_category.LXB_HTML_TAG_CATEGORY__UNDEF;
alias LXB_HTML_TAG_CATEGORY_ORDINARY = lxb_html_tag_category.LXB_HTML_TAG_CATEGORY_ORDINARY;
alias LXB_HTML_TAG_CATEGORY_SPECIAL = lxb_html_tag_category.LXB_HTML_TAG_CATEGORY_SPECIAL;
alias LXB_HTML_TAG_CATEGORY_FORMATTING = lxb_html_tag_category.LXB_HTML_TAG_CATEGORY_FORMATTING;
alias LXB_HTML_TAG_CATEGORY_SCOPE = lxb_html_tag_category.LXB_HTML_TAG_CATEGORY_SCOPE;
alias LXB_HTML_TAG_CATEGORY_SCOPE_LIST_ITEM = lxb_html_tag_category.LXB_HTML_TAG_CATEGORY_SCOPE_LIST_ITEM;
alias LXB_HTML_TAG_CATEGORY_SCOPE_BUTTON = lxb_html_tag_category.LXB_HTML_TAG_CATEGORY_SCOPE_BUTTON;
alias LXB_HTML_TAG_CATEGORY_SCOPE_TABLE = lxb_html_tag_category.LXB_HTML_TAG_CATEGORY_SCOPE_TABLE;
alias LXB_HTML_TAG_CATEGORY_SCOPE_SELECT = lxb_html_tag_category.LXB_HTML_TAG_CATEGORY_SCOPE_SELECT;


struct lxb_html_tag_fixname_t {
    const(lxb_char_t)* name;
    uint len;
}

/*
 * Inline functions
 */
 bool lxb_html_tag_is_category(lxb_tag_id_t tag_id, lxb_ns_id_t ns, lxb_html_tag_category_t cat)
{
    if (tag_id < LXB_TAG__LAST_ENTRY && ns < LXB_NS__LAST_ENTRY) {
        return cast(bool) (lxb_html_tag_res_cats[tag_id][ns] & cat);
    }

    return cast(bool) ((LXB_HTML_TAG_CATEGORY_ORDINARY|LXB_HTML_TAG_CATEGORY_SCOPE_SELECT) & cat);
}

 const(lxb_html_tag_fixname_t)* lxb_html_tag_fixname_svg(lxb_tag_id_t tag_id)
{
    if (tag_id >= LXB_TAG__LAST_ENTRY) {
        return null;
    }

    return &lxb_html_tag_res_fixname_svg[tag_id];
}

 bool lxb_html_tag_is_void(lxb_tag_id_t tag_id)
{
    switch (tag_id) {
        case LXB_TAG_AREA:
        case LXB_TAG_BASE:
        case LXB_TAG_BR:
        case LXB_TAG_COL:
        case LXB_TAG_EMBED:
        case LXB_TAG_HR:
        case LXB_TAG_IMG:
        case LXB_TAG_INPUT:
        case LXB_TAG_LINK:
        case LXB_TAG_META:
        case LXB_TAG_SOURCE:
        case LXB_TAG_TRACK:
        case LXB_TAG_WBR:
            return true;

        default:
            return false;
    }

    return false;
}
