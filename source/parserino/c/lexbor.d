/*
Copyright (c) 2022 Andrea Fontana
Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

module parserino.c.lexbor;
import core.stdc.stdint;

extern (C):

alias lxb_html_serialize_cb_f = uint function (const(lxb_char_t)* data, size_t len, void* ctx);
alias lxb_selectors_cb_f = uint function (lxb_dom_node_t*, void*, void*);

version(Windows)
{
    enum ToImport;

    __gshared {
        @ToImport:
        lxb_dom_element_t* function (lxb_dom_element_t* element) lxb_dom_element_destroy;
        lxb_dom_element_t* function (lxb_dom_document_t* document, const(lxb_dom_element_t)* element) lxb_dom_element_interface_clone;
        lxb_dom_element_t* function (lxb_dom_element_t* element) lxb_dom_element_interface_destroy;
        lxb_status_t function (lxb_dom_element_t* dst, const(lxb_dom_element_t)* src) lxb_dom_element_interface_copy;

        lxb_dom_attr_t* function (lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len, const(lxb_char_t)* value, size_t value_len) lxb_dom_element_set_attribute;
        const(lxb_char_t)* function (lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len, size_t* value_len) lxb_dom_element_get_attribute;
        lxb_status_t function (lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len) lxb_dom_element_remove_attribute;
        bool function (lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len) lxb_dom_element_has_attribute;

        const(lxb_char_t)* function (lxb_dom_element_t* element, size_t* len) lxb_dom_element_tag_name;
        const(lxb_char_t)* function (lxb_dom_element_t* element, size_t* len) lxb_dom_element_local_name;
        lxb_dom_attr_t* function (lxb_dom_element_t* element) lxb_dom_element_first_attribute_noi;
        lxb_dom_attr_t* function (lxb_dom_attr_t* attr) lxb_dom_element_next_attribute_noi;

        void function (lxb_dom_node_t* to, lxb_dom_node_t* node) lxb_dom_node_insert_child;
        void function (lxb_dom_node_t* to, lxb_dom_node_t* node) lxb_dom_node_insert_before;
        void function (lxb_dom_node_t* to, lxb_dom_node_t* node) lxb_dom_node_insert_after;
        void function (lxb_dom_node_t* node) lxb_dom_node_remove;

        lxb_char_t* function (lxb_dom_node_t* node, size_t* len) lxb_dom_node_text_content;
        lxb_status_t function (lxb_dom_node_t* node, const(lxb_char_t)* content, size_t len) lxb_dom_node_text_content_set;
        bool function (lxb_dom_node_t* root) lxb_dom_node_is_empty;

        lxb_dom_node_t* function (lxb_dom_node_t* node) lxb_dom_node_next_noi;
        lxb_dom_node_t* function (lxb_dom_node_t* node) lxb_dom_node_prev_noi;
        lxb_dom_node_t* function (lxb_dom_node_t* node) lxb_dom_node_parent_noi;
        lxb_dom_node_t* function (lxb_dom_node_t* node) lxb_dom_node_first_child_noi;
        lxb_dom_node_t* function (lxb_dom_node_t* node) lxb_dom_node_last_child_noi;

        const(lxb_char_t)* function (lxb_dom_attr_t* attr, size_t* len) lxb_dom_attr_local_name_noi;
        const(lxb_char_t)* function (lxb_dom_attr_t* attr, size_t* len) lxb_dom_attr_value_noi;

        lxb_status_t function (lxb_dom_node_t* node, lxb_html_serialize_cb_f cb, void* ctx) lxb_html_serialize_cb;
        lxb_status_t function (lxb_dom_node_t* node, lexbor_str_t* str) lxb_html_serialize_str;
        lxb_status_t function (lxb_dom_node_t* node, lxb_html_serialize_cb_f cb, void* ctx) lxb_html_serialize_tree_cb;
        lxb_status_t function (lxb_dom_node_t* node, lexbor_str_t* str) lxb_html_serialize_tree_str;
        lxb_status_t function (lxb_dom_node_t* node, lxb_html_serialize_cb_f cb, void* ctx) lxb_html_serialize_deep_cb;
        lxb_status_t function (lxb_dom_node_t* node, lexbor_str_t* str) lxb_html_serialize_deep_str;
        lxb_status_t function (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx) lxb_html_serialize_pretty_cb;
        lxb_status_t function (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lexbor_str_t* str) lxb_html_serialize_pretty_str;
        lxb_status_t function (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx) lxb_html_serialize_pretty_tree_cb;
        lxb_status_t function (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lexbor_str_t* str) lxb_html_serialize_pretty_tree_str;
        lxb_status_t function (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx) lxb_html_serialize_pretty_deep_cb;
        lxb_status_t function (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lexbor_str_t* str) lxb_html_serialize_pretty_deep_str;

        lxb_html_element_t* function (lxb_html_element_t* element, const(lxb_char_t)* html, size_t size) lxb_html_element_inner_html_set;

        lxb_selectors_t* function () lxb_selectors_create;
        lxb_status_t function (lxb_selectors_t* selectors) lxb_selectors_init;
        lxb_selectors_t* function (lxb_selectors_t* selectors, bool self_destroy) lxb_selectors_destroy;

        lxb_status_t function (lxb_selectors_t* selectors, lxb_dom_node_t* root, lxb_css_selector_list_t* list, lxb_selectors_cb_f cb, void* ctx) lxb_selectors_find;

        lxb_css_parser_t* function() lxb_css_parser_create;
        lxb_status_t function (lxb_css_parser_t *, lxb_css_syntax_tokenizer_t *, lexbor_mraw_t *) lxb_css_parser_init;
        lxb_css_parser_t* function(lxb_css_parser_t *, bool) lxb_css_parser_destroy;

        lxb_html_document_t* function () lxb_html_document_create;
        void function (lxb_html_document_t* document) lxb_html_document_clean;
        lxb_html_document_t* function (lxb_html_document_t* document) lxb_html_document_destroy;
        lxb_status_t function (lxb_html_document_t*, const(lxb_char_t)*, size_t) lxb_html_document_parse;
        lxb_dom_node_t* function (lxb_html_document_t*, lxb_dom_element_t*, const(lxb_char_t)*, size_t) lxb_html_document_parse_fragment;
        const(lxb_char_t)* function (lxb_html_document_t*, size_t*) lxb_html_document_title;
        lxb_status_t function (lxb_html_document_t*, const(lxb_char_t)*, size_t) lxb_html_document_title_set;
        const(lxb_char_t)* function (lxb_html_document_t*, size_t*) lxb_html_document_title_raw;
        lxb_html_head_element_t* function (lxb_html_document_t*) lxb_html_document_head_element_noi;
        lxb_html_body_element_t* function (lxb_html_document_t*) lxb_html_document_body_element_noi;

        lxb_dom_element_t* function (lxb_dom_document_t*, const(lxb_char_t)*, size_t, void*) lxb_dom_document_create_element;
        void function(lxb_css_selector_list_t *) lxb_css_selector_list_destroy_memory;
        lxb_css_selector_list_t * function(lxb_css_parser_t *, const lxb_char_t *, size_t) lxb_css_selectors_parse;
    }

    extern(D) shared static this()
    {
        import core.sys.windows.windows;
        import std.traits;
        import std.stdio;
        import std.file : thisExePath, getcwd;
        import std.path : buildPath,dirName;
        import std.string : toStringz;

        HINSTANCE handle = LoadLibraryA(buildPath(thisExePath.dirName, "lexbor.dll").toStringz);

        if (handle == null)
            handle = LoadLibraryA(buildPath(getcwd(), "lexbor.dll").toStringz);

        if (handle == null)
            throw new Exception("Can't find lexbor.dll.");

        static foreach(s; getSymbolsByUDA!(parserino.c.lexbor, ToImport))
            static if (isFunctionPointer!s)
                mixin(`*(cast(void**)&` ~ s.stringof ~ `) = cast(void*)GetProcAddress(handle, "` ~ s.stringof ~ `");`);
    }
}
else
{
    lxb_dom_element_t* lxb_dom_element_destroy (lxb_dom_element_t* element);
    lxb_dom_element_t* lxb_dom_element_interface_clone (lxb_dom_document_t* document, const(lxb_dom_element_t)* element);
    lxb_dom_element_t* lxb_dom_element_interface_destroy (lxb_dom_element_t* element);
    lxb_status_t lxb_dom_element_interface_copy (lxb_dom_element_t* dst, const(lxb_dom_element_t)* src);

    lxb_dom_attr_t* lxb_dom_element_set_attribute (lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len, const(lxb_char_t)* value, size_t value_len);
    const(lxb_char_t)* lxb_dom_element_get_attribute (lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len, size_t* value_len);
    lxb_status_t lxb_dom_element_remove_attribute (lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len);
    bool lxb_dom_element_has_attribute (lxb_dom_element_t* element, const(lxb_char_t)* qualified_name, size_t qn_len);

    const(lxb_char_t)* lxb_dom_element_tag_name (lxb_dom_element_t* element, size_t* len);
    const(lxb_char_t)* lxb_dom_element_local_name (lxb_dom_element_t* element, size_t* len);
    lxb_dom_attr_t* lxb_dom_element_first_attribute_noi (lxb_dom_element_t* element);
    lxb_dom_attr_t* lxb_dom_element_next_attribute_noi (lxb_dom_attr_t* attr);

    void lxb_dom_node_insert_child (lxb_dom_node_t* to, lxb_dom_node_t* node);
    void lxb_dom_node_insert_before (lxb_dom_node_t* to, lxb_dom_node_t* node);
    void lxb_dom_node_insert_after (lxb_dom_node_t* to, lxb_dom_node_t* node);
    void lxb_dom_node_remove (lxb_dom_node_t* node);

    lxb_char_t* lxb_dom_node_text_content (lxb_dom_node_t* node, size_t* len);
    lxb_status_t lxb_dom_node_text_content_set (lxb_dom_node_t* node, const(lxb_char_t)* content, size_t len);
    bool lxb_dom_node_is_empty (lxb_dom_node_t* root);

    lxb_dom_node_t* lxb_dom_node_next_noi (lxb_dom_node_t* node);
    lxb_dom_node_t* lxb_dom_node_prev_noi (lxb_dom_node_t* node);
    lxb_dom_node_t* lxb_dom_node_parent_noi (lxb_dom_node_t* node);
    lxb_dom_node_t* lxb_dom_node_first_child_noi (lxb_dom_node_t* node);
    lxb_dom_node_t* lxb_dom_node_last_child_noi (lxb_dom_node_t* node);

    const(lxb_char_t)* lxb_dom_attr_local_name_noi (lxb_dom_attr_t* attr, size_t* len);
    const(lxb_char_t)* lxb_dom_attr_value_noi (lxb_dom_attr_t* attr, size_t* len);

    lxb_status_t lxb_html_serialize_cb (lxb_dom_node_t* node, lxb_html_serialize_cb_f cb, void* ctx);
    lxb_status_t lxb_html_serialize_str (lxb_dom_node_t* node, lexbor_str_t* str);
    lxb_status_t lxb_html_serialize_tree_cb (lxb_dom_node_t* node, lxb_html_serialize_cb_f cb, void* ctx);
    lxb_status_t lxb_html_serialize_tree_str (lxb_dom_node_t* node, lexbor_str_t* str);
    lxb_status_t lxb_html_serialize_deep_cb (lxb_dom_node_t* node, lxb_html_serialize_cb_f cb, void* ctx);
    lxb_status_t lxb_html_serialize_deep_str (lxb_dom_node_t* node, lexbor_str_t* str);
    lxb_status_t lxb_html_serialize_pretty_cb (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx);
    lxb_status_t lxb_html_serialize_pretty_str (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lexbor_str_t* str);
    lxb_status_t lxb_html_serialize_pretty_tree_cb (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx);
    lxb_status_t lxb_html_serialize_pretty_tree_str (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lexbor_str_t* str);
    lxb_status_t lxb_html_serialize_pretty_deep_cb (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lxb_html_serialize_cb_f cb, void* ctx);
    lxb_status_t lxb_html_serialize_pretty_deep_str (lxb_dom_node_t* node, lxb_html_serialize_opt_t opt, size_t indent, lexbor_str_t* str);

    lxb_html_element_t* lxb_html_element_inner_html_set (lxb_html_element_t* element, const(lxb_char_t)* html, size_t size);

    lxb_selectors_t* lxb_selectors_create ();
    lxb_status_t lxb_selectors_init (lxb_selectors_t* selectors);
    lxb_selectors_t* lxb_selectors_destroy (lxb_selectors_t* selectors, bool self_destroy);

    lxb_status_t lxb_selectors_find (lxb_selectors_t* selectors, lxb_dom_node_t* root, lxb_css_selector_list_t* list, lxb_selectors_cb_f cb, void* ctx);

    lxb_css_parser_t* lxb_css_parser_create();
    lxb_status_t lxb_css_parser_init(lxb_css_parser_t *, lxb_css_syntax_tokenizer_t *, lexbor_mraw_t *);
    lxb_css_parser_t *lxb_css_parser_destroy(lxb_css_parser_t *, bool);

    lxb_html_document_t* lxb_html_document_create ();
    void lxb_html_document_clean (lxb_html_document_t* document);
    lxb_html_document_t* lxb_html_document_destroy (lxb_html_document_t* document);
    lxb_status_t lxb_html_document_parse (lxb_html_document_t*, const(lxb_char_t)*, size_t);
    lxb_dom_node_t* lxb_html_document_parse_fragment (lxb_html_document_t*, lxb_dom_element_t*, const(lxb_char_t)*, size_t);
    const(lxb_char_t)* lxb_html_document_title (lxb_html_document_t*, size_t*);
    lxb_status_t lxb_html_document_title_set (lxb_html_document_t*, const(lxb_char_t)*, size_t);
    const(lxb_char_t)* lxb_html_document_title_raw (lxb_html_document_t*, size_t*);
    lxb_html_head_element_t* lxb_html_document_head_element_noi (lxb_html_document_t*);
    lxb_html_body_element_t* lxb_html_document_body_element_noi (lxb_html_document_t*);

    lxb_dom_element_t* lxb_dom_document_create_element (lxb_dom_document_t*, const(lxb_char_t)*, size_t, void*);
    void lxb_css_selector_list_destroy_memory(lxb_css_selector_list_t *);
    lxb_css_selector_list_t * lxb_css_selectors_parse(lxb_css_parser_t *, const lxb_char_t *, size_t);
}

// STRUCTS
alias lxb_dom_attr_id_t = uintptr_t;
alias lxb_char_t = ubyte;
alias lxb_status_t = uint;
alias lxb_html_document_opt_t = uint;
alias lxb_html_serialize_opt_t = int;

struct lxb_selectors_t;
struct lxb_css_selector_list_t;
struct lxb_css_parser_t;
struct lxb_css_syntax_tokenizer_t;
struct lexbor_mraw_t;

alias lxb_html_body_element_t = lxb_html_body_element;
struct lxb_html_body_element;

alias lxb_html_head_element_t = lxb_html_head_element;
struct lxb_html_head_element;

alias lxb_dom_event_target_t = lxb_dom_event_target;
struct lxb_dom_event_target
{
    void* events;
}

alias lxb_html_element_t = lxb_html_element;
struct lxb_html_element
{
    lxb_dom_element_t element;
}

alias lexbor_str_t = lexbor_str;
struct lexbor_str
{
    lxb_char_t *data;
    size_t     length;
}

alias lxb_dom_element_t = lxb_dom_element;
struct lxb_dom_element
{
    lxb_dom_node_t node;
    lxb_dom_attr_id_t upper_name;
    lxb_dom_attr_id_t qualified_name;
    lexbor_str_t* _value;
    lxb_dom_attr_t* first_attr;
    lxb_dom_attr_t* last_attr;
    lxb_dom_attr_t* attr_id;
    lxb_dom_attr_t* attr_class;
}

alias lxb_dom_document_type_t = lxb_dom_document_type;
struct lxb_dom_document_type {
    lxb_dom_node_t    node;

    lxb_dom_attr_id_t name;
    lexbor_str_t      public_id;
    lexbor_str_t      system_id;
}

alias lexbor_hash_t = lexbor_hash;
struct lexbor_hash {
    void    *entries;
    void    *mraw;

    void    **table;
    size_t  table_size;

    size_t  struct_size;
}

alias lxb_dom_document_t = lxb_dom_document;
struct lxb_dom_document {
    lxb_dom_node_t              node;

    lxb_dom_document_cmode_t    compat_mode;
    lxb_dom_document_dtype_t    type;

    lxb_dom_document_type_t     *doctype;
    lxb_dom_element_t           *element;

    void*  create_interface;
    void*  clone_interface;
    void*  destroy_interface;

    lexbor_mraw_t               *mraw;
    lexbor_mraw_t               *text;
    lexbor_hash_t               *tags;
    lexbor_hash_t               *attrs;
    lexbor_hash_t               *prefix;
    lexbor_hash_t               *ns;
    void                        *parser;
    void                        *user;

    bool                        tags_inherited;
    bool                        ns_inherited;

    bool                        scripting;
}

alias lxb_html_document_t = lxb_html_document;
struct lxb_html_document {
    lxb_dom_document_t              dom_document;
    void                            *iframe_srcdoc;
    lxb_html_head_element_t         *head;
    lxb_html_body_element_t         *body;
    lxb_html_document_ready_state_t ready_state;
    lxb_html_document_opt_t         opt;
}

alias lxb_dom_node_t = lxb_dom_node;
struct lxb_dom_node
{
    lxb_dom_event_target_t event_target;
    uintptr_t local_name;
    uintptr_t prefix;
    uintptr_t ns;
    lxb_dom_document_t* owner_document;
    lxb_dom_node_t* next;
    lxb_dom_node_t* prev;
    lxb_dom_node_t* parent;
    lxb_dom_node_t* first_child;
    lxb_dom_node_t* last_child;
    void* user;
    lxb_dom_node_type_t type;
}

alias lxb_dom_attr_t = lxb_dom_attr;
struct lxb_dom_attr
{
    lxb_dom_node_t node;
    lxb_dom_attr_id_t upper_name; /* uppercase, with prefix: FIX:ME */
    lxb_dom_attr_id_t qualified_name; /* original, with prefix: Fix:Me */
    lexbor_str_t* value;
    lxb_dom_element_t* owner;
    lxb_dom_attr_t* next;
    lxb_dom_attr_t* prev;
}

// ENUMS

enum lxb_html_document_ready_state_t {
    LXB_HTML_DOCUMENT_READY_STATE_UNDEF       = 0x00,
    LXB_HTML_DOCUMENT_READY_STATE_LOADING     = 0x01,
    LXB_HTML_DOCUMENT_READY_STATE_INTERACTIVE = 0x02,
    LXB_HTML_DOCUMENT_READY_STATE_COMPLETE    = 0x03,
}

enum lexbor_status_t {
    LXB_STATUS_OK                       = 0x0000,
    LXB_STATUS_ERROR                    = 0x0001,
    LXB_STATUS_ERROR_MEMORY_ALLOCATION,
    LXB_STATUS_ERROR_OBJECT_IS_NULL,
    LXB_STATUS_ERROR_SMALL_BUFFER,
    LXB_STATUS_ERROR_INCOMPLETE_OBJECT,
    LXB_STATUS_ERROR_NO_FREE_SLOT,
    LXB_STATUS_ERROR_TOO_SMALL_SIZE,
    LXB_STATUS_ERROR_NOT_EXISTS,
    LXB_STATUS_ERROR_WRONG_ARGS,
    LXB_STATUS_ERROR_WRONG_STAGE,
    LXB_STATUS_ERROR_UNEXPECTED_RESULT,
    LXB_STATUS_ERROR_UNEXPECTED_DATA,
    LXB_STATUS_ERROR_OVERFLOW,
    LXB_STATUS_CONTINUE,
    LXB_STATUS_SMALL_BUFFER,
    LXB_STATUS_ABORTED,
    LXB_STATUS_STOPPED,
    LXB_STATUS_NEXT,
    LXB_STATUS_STOP,
}

enum lxb_html_serialize_opt
{
    LXB_HTML_SERIALIZE_OPT_UNDEF = 0x00,
    LXB_HTML_SERIALIZE_OPT_SKIP_WS_NODES = 0x01,
    LXB_HTML_SERIALIZE_OPT_SKIP_COMMENT = 0x02,
    LXB_HTML_SERIALIZE_OPT_RAW = 0x04,
    LXB_HTML_SERIALIZE_OPT_WITHOUT_CLOSING = 0x08,
    LXB_HTML_SERIALIZE_OPT_TAG_WITH_NS = 0x10,
    LXB_HTML_SERIALIZE_OPT_WITHOUT_TEXT_INDENT = 0x20,
    LXB_HTML_SERIALIZE_OPT_FULL_DOCTYPE = 0x40
}


enum lxb_dom_node_type_t
{
    LXB_DOM_NODE_TYPE_UNDEF = 0x00,
    LXB_DOM_NODE_TYPE_ELEMENT = 0x01,
    LXB_DOM_NODE_TYPE_ATTRIBUTE = 0x02,
    LXB_DOM_NODE_TYPE_TEXT = 0x03,
    LXB_DOM_NODE_TYPE_CDATA_SECTION = 0x04,
    LXB_DOM_NODE_TYPE_ENTITY_REFERENCE = 0x05, // historical
    LXB_DOM_NODE_TYPE_ENTITY = 0x06, // historical
    LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION = 0x07,
    LXB_DOM_NODE_TYPE_COMMENT = 0x08,
    LXB_DOM_NODE_TYPE_DOCUMENT = 0x09,
    LXB_DOM_NODE_TYPE_DOCUMENT_TYPE = 0x0A,
    LXB_DOM_NODE_TYPE_DOCUMENT_FRAGMENT = 0x0B,
    LXB_DOM_NODE_TYPE_NOTATION = 0x0C, // historical
    LXB_DOM_NODE_TYPE_LAST_ENTRY = 0x0D
}

enum lxb_dom_document_cmode_t
{
    LXB_DOM_DOCUMENT_CMODE_NO_QUIRKS       = 0x00,
    LXB_DOM_DOCUMENT_CMODE_QUIRKS          = 0x01,
    LXB_DOM_DOCUMENT_CMODE_LIMITED_QUIRKS  = 0x02
}

enum lxb_dom_document_dtype_t
{
    LXB_DOM_DOCUMENT_DTYPE_UNDEF = 0x00,
    LXB_DOM_DOCUMENT_DTYPE_HTML  = 0x01,
    LXB_DOM_DOCUMENT_DTYPE_XML   = 0x02
}
