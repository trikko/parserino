/++
 Differential test harness: link it once against the C lexbor and once
 against the D port (parserino.lexbor), run on the same files and diff the
 output. It only uses the C ABI (parserino.c.lexbor), so the source is the same.
+/
module harness;

import parserino.c.lexbor;
import std.stdio, std.file, std.string, std.conv, std.algorithm, std.range, std.path;

extern (C) @nogc nothrow
{
    lxb_status_t lxb_html_document_parse_chunk_begin(lxb_html_document_t*);
    lxb_status_t lxb_html_document_parse_chunk(lxb_html_document_t*, const(lxb_char_t)*, size_t);
    lxb_status_t lxb_html_document_parse_chunk_end(lxb_html_document_t*);
}

enum string[] selectors = [
    "*", "p", "div p", "div > p", "a + b", "p ~ p", "#main", ".mw-body", "a[href]",
    "a[href^=\"http\"]", "a[href$=\".html\"]", "a[href*=\"wiki\"]", "[class~=\"a\"]",
    "[lang|=\"en\"]", "[type=\"text\" i]", "li:first-child", "li:last-child", "li:only-child",
    "tr:nth-child(2n+1)", "tr:nth-child(odd)", "td:nth-last-child(2)", "p:nth-of-type(2)",
    "p:nth-last-of-type(1)", "span:first-of-type", "span:last-of-type", "b:only-of-type",
    "p:empty", ":root", "div:not(.x)", "a:not([href])", "div:has(> p)", "div:has(a)",
    ":is(h1, h2, h3)", ":where(ul, ol) li", "li:nth-child(2 of .x)", "input:checked",
    "input:disabled", "input:enabled", "option:checked", "p:lang(en)", "html body div",
    "body > *", "table tr td", "head title", "script", "meta[charset]", "link[rel=\"stylesheet\"]",
    "h1, h2, h3, h4, h5, h6", "ul li a", "div.a.b", "div#x.y", "::before", "p::first-line",
    "a:hover", "*|*", "svg|rect", "img[alt=\"\"]", "[data-x]", "div:nth-child(-n+3)",
    ":first-child:last-child", "a:any-link", "a:link", "p:contains(x)", "1bad", "a[", "div >",
    ":nth-child(", "p:nth-child(n)", "p:nth-child(0n+0)", "span:nth-child(3n-1)",
];

string ser(lxb_dom_node_t* node, bool deep)
{
    extern (C) lxb_status_t cb(const(lxb_char_t)* data, size_t len, void* ctx)
    {
        *(cast(string*) ctx) ~= cast(string) data[0 .. len].idup;
        return 0;
    }
    string s;
    if (deep) lxb_html_serialize_tree_cb(node, &cb, &s);
    else lxb_html_serialize_cb(node, &cb, &s);
    return s;
}

string pretty(lxb_dom_node_t* node)
{
    extern (C) lxb_status_t cb(const(lxb_char_t)* data, size_t len, void* ctx)
    {
        *(cast(string*) ctx) ~= cast(string) data[0 .. len].idup;
        return 0;
    }
    string s;
    lxb_html_serialize_pretty_tree_cb(node, 0, 0, &cb, &s);
    return s;
}

struct Found { string[] items; size_t count; }

extern (C) lxb_status_t findcb(lxb_dom_node_t* node, void* spec, void* ctx)
{
    auto f = cast(Found*) ctx;
    f.count++;
    if (f.items.length < 5) f.items ~= ser(node, false);
    return 0;
}

void main(string[] args)
{
    auto sels = lxb_selectors_create();
    lxb_selectors_init(sels);

    foreach (fname; args[1 .. $].sort)
    {
        auto html = cast(string) read(fname);
        writeln("=== ", fname.baseName); stdout.flush();

        auto doc = lxb_html_document_create();
        auto st = lxb_html_document_parse(doc, cast(const(ubyte)*) html.ptr, html.length);
        auto root = &doc.dom_document.node;
        auto full = ser(root, true);
        writeln("status ", st, " len ", full.length, " hash ", hashOf(full));
        if (full.length < 4000) writeln(full);
        auto pr = pretty(root);
        writeln("pretty ", pr.length, " ", hashOf(pr));

        size_t tlen;
        auto t = lxb_html_document_title(doc, &tlen);
        writeln("title [", t is null ? "" : cast(string) t[0 .. tlen], "]");

        size_t textLen;
        auto txt = lxb_dom_node_text_content(root, &textLen);
        writeln("text ", textLen, " ", txt is null ? 0 : hashOf(txt[0 .. textLen]));

        foreach (s; selectors)
        {
            auto parser = lxb_css_parser_create();
            lxb_css_parser_init(parser, null, null);
            auto list = lxb_css_selectors_parse(parser, cast(const(ubyte)*) s.ptr, s.length);
            if (list is null) { writeln("sel ", s, " -> parse error"); lxb_css_parser_destroy(parser, true); continue; }
            Found f;
            auto fs = lxb_selectors_find(sels, root, list, &findcb, &f);
            writeln("sel ", s, " -> ", fs, " ", f.count, " ", f.items.join("|").replace("\n", "\\n").take(300));
            lxb_css_selector_list_destroy_memory(list);
            lxb_css_parser_destroy(parser, true);
        }

        // chunked parsing (3 bytes at a time) must give the same tree
        auto doc2 = lxb_html_document_create();
        lxb_html_document_parse_chunk_begin(doc2);
        for (size_t i = 0; i < html.length; i += 3)
        {
            auto e = min(i + 3, html.length);
            lxb_html_document_parse_chunk(doc2, cast(const(ubyte)*) html.ptr + i, e - i);
        }
        lxb_html_document_parse_chunk_end(doc2);
        auto full2 = ser(&doc2.dom_document.node, true);
        writeln("chunked ", full2 == full ? "same" : "DIFF " ~ hashOf(full2).to!string);
        lxb_html_document_destroy(doc2);

        // fragment parsing + innerHTML on body
        auto body = cast(lxb_dom_element_t*) lxb_html_document_body_element_noi(doc);
        if (body !is null)
        {
            auto frag = lxb_html_document_parse_fragment(doc, body, cast(const(ubyte)*) html.ptr, html.length);
            writeln("fragment ", frag is null ? 0 : hashOf(ser(frag, true)));
            lxb_html_element_inner_html_set(cast(lxb_html_element_t*) body, cast(const(ubyte)*) html.ptr, html.length);
            writeln("innerhtml ", hashOf(ser(root, true)));
        }

        // mutations: clone first element, insert, remove, text set
        auto first = lxb_dom_node_first_child_noi(body is null ? root : &body.node);
        size_t nlen;
        if (first !is null && first.type == lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_ELEMENT
            && (cast(string) lxb_dom_element_local_name(cast(lxb_dom_element_t*) first, &nlen)[0 .. nlen]) != "template")
        {
            // (cloning a <template> crashes lexbor's serializer in C too: skipped)
            auto el = cast(lxb_dom_element_t*) first;
            auto c = lxb_dom_element_interface_clone(&doc.dom_document, el);
            lxb_dom_element_set_attribute(c, cast(const(ubyte)*) "data-t".ptr, 6, cast(const(ubyte)*) "v".ptr, 1);
            lxb_dom_node_insert_after(first, &c.node);
            lxb_dom_node_text_content_set(&c.node, cast(const(ubyte)*) "<x>".ptr, 3);
            lxb_dom_node_remove(first);
            writeln("mutate ", ser(root, true).hashOf);
        }

        lxb_html_document_title_set(doc, cast(const(ubyte)*) "T&<".ptr, 3);
        writeln("titleset ", ser(root, true).hashOf);
        lxb_html_document_destroy(doc);
    }
}
