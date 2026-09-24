/++
 HTML serialization ("serializing HTML fragments" in the HTML spec).

 The output goes to any output range of `const(char)[]`, through a small buffer,
 so the sink receives a few large chunks.
+/
module parserino.html.serializer;

import parserino.lexbor.dom.interfaces.node;
import parserino.lexbor.dom.interfaces.element;
import parserino.lexbor.dom.interfaces.attr;
import parserino.lexbor.dom.interfaces.document;
import parserino.lexbor.dom.interfaces.document_type;
import parserino.lexbor.dom.interfaces.character_data;
import parserino.lexbor.dom.interfaces.processing_instruction;
import parserino.lexbor.html.interfaces.template_element;
import parserino.lexbor.tag.const_;
import parserino.lexbor.ns.const_;

alias Node = lxb_dom_node_t;

enum Serialize
{
    node,       /// only the node: the start tag for elements, the text for texts, ...
    tree,       /// the node and its descendants (for a document: its children)
    children,   /// only the descendants (innerHTML)
}

/// Serialize `node` to `sink` (an output range of `const(char)[]`)
void serialize(Sink)(Node* node, ref Sink sink, Serialize what)
{
    auto out_ = Buffered!Sink(&sink);

    final switch (what)
    {
        case Serialize.node:
            if (node.type == LXB_DOM_NODE_TYPE_DOCUMENT) out_.put("<#document>");
            else if (node.type == LXB_DOM_NODE_TYPE_ELEMENT) startTag(node, out_);
            else leaf(node, out_);
            break;

        case Serialize.tree:
            if (node.type == LXB_DOM_NODE_TYPE_DOCUMENT) children(node, out_);
            else subtree(node, out_);
            break;

        case Serialize.children:
            children(node, out_);
            break;
    }

    out_.flush();
}

///
unittest
{
    import parserino : Document;

    Document d = `<p class="a&quot;b">x &amp; <b>y</b><br>&nbsp;</p><!--c--><script>a<b</script>`;

    string s;
    auto sink = (const(char)[] c) { s ~= c; };
    auto p = d.byTagName("p").front;
    assert(p.toString == `<p class="a&quot;b">x &amp; <b>y</b><br>&nbsp;</p>`);
    assert(p.toString(false) == `<p class="a&quot;b">`);
    assert(d.byTagName("script").front.innerHTML == "a<b");
}

private:

struct Buffered(Sink)
{
    Sink* sink;
    char[4096] buf = void;
    size_t used;

    this(Sink* s) { sink = s; used = 0; }

    void put(const(char)[] s)
    {
        if (used + s.length > buf.length)
        {
            flush();
            if (s.length > buf.length) { putToSink(s); return; }
        }

        buf[used .. used + s.length] = s[];
        used += s.length;
    }

    void flush()
    {
        if (used == 0) return;
        putToSink(buf[0 .. used]);
        used = 0;
    }

    void putToSink(const(char)[] s)
    {
        import std.range.primitives : put;
        put(*sink, s);
    }
}

const(char)[] str(const(ubyte)* p, size_t len) { return p is null ? null : cast(const(char)[]) p[0 .. len]; }

void children(O)(Node* parent, ref O out_)
{
    for (auto c = parent.first_child; c !is null; c = c.next)
        subtree(c, out_);
}

// Iterative preorder, so deep trees don't overflow the stack
void subtree(O)(Node* root, ref O out_)
{
    Node* node = root;

    while (true)
    {
        bool isElement = node.type == LXB_DOM_NODE_TYPE_ELEMENT;

        if (isElement)
        {
            startTag(node, out_);

            // The children of a <template> live in its content fragment
            if (node.local_name == LXB_TAG_TEMPLATE && node.ns == LXB_NS_HTML)
            {
                auto t = cast(lxb_html_template_element_t*) node;
                if (t.content !is null) children(&t.content.node, out_);
            }
        }
        else leaf(node, out_);

        if (isElement && !isVoid(node) && node.first_child !is null)
        {
            node = node.first_child;
            continue;
        }

        // Close the elements we are leaving
        while (true)
        {
            if (node.type == LXB_DOM_NODE_TYPE_ELEMENT && !isVoid(node)) endTag(node, out_);
            if (node is root) return;
            if (node.next !is null) { node = node.next; break; }
            node = node.parent;
        }
    }
}

void startTag(O)(Node* node, ref O out_)
{
    auto e = cast(lxb_dom_element_t*) node;
    size_t len;

    out_.put("<");
    out_.put(str(lxb_dom_element_qualified_name(e, &len), len));

    // The "is" value of custom elements, if not already an attribute
    if (e.is_value !is null && e.is_value.data !is null && lxb_dom_element_attr_is_exist(e, cast(const(ubyte)*) "is".ptr, 2) is null)
    {
        out_.put(` is="`);
        escape!true(str(e.is_value.data, e.is_value.length), out_);
        out_.put(`"`);
    }

    for (auto a = e.first_attr; a !is null; a = a.next)
    {
        out_.put(" ");
        attribute(a, out_);
    }

    out_.put(">");
}

void endTag(O)(Node* node, ref O out_)
{
    size_t len;
    out_.put("</");
    out_.put(str(lxb_dom_element_qualified_name(cast(lxb_dom_element_t*) node, &len), len));
    out_.put(">");
}

void attribute(O)(lxb_dom_attr_t* a, ref O out_)
{
    size_t len;
    auto local = str(lxb_dom_attr_local_name(a, &len), len);

    switch (a.node.ns)
    {
        case LXB_NS__UNDEF: out_.put(local); break;
        case LXB_NS_XML: out_.put("xml:"); out_.put(local); break;
        case LXB_NS_XLINK: out_.put("xlink:"); out_.put(local); break;
        case LXB_NS_XMLNS:
            if (local == "xmlns") out_.put("xmlns");
            else { out_.put("xmlns:"); out_.put(local); }
            break;
        default:
            out_.put(str(lxb_dom_attr_qualified_name(a, &len), len));
            break;
    }

    out_.put(`="`);
    if (a.value !is null) escape!true(str(a.value.data, a.value.length), out_);
    out_.put(`"`);
}

// Texts, comments, doctypes and processing instructions
void leaf(O)(Node* node, ref O out_)
{
    switch (node.type)
    {
        case LXB_DOM_NODE_TYPE_TEXT:
            auto data = charData(node);
            if (isRawTextParent(node)) out_.put(data);
            else escape!false(data, out_);
            break;

        case LXB_DOM_NODE_TYPE_COMMENT:
            out_.put("<!--");
            out_.put(charData(node));
            out_.put("-->");
            break;

        case LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION:
            auto pi = cast(lxb_dom_processing_instruction_t*) node;
            out_.put("<?");
            out_.put(str(pi.target.data, pi.target.length));
            out_.put(" ");
            out_.put(charData(node));
            out_.put("?>");
            break;

        case LXB_DOM_NODE_TYPE_DOCUMENT_TYPE:
            size_t len;
            out_.put("<!DOCTYPE ");
            out_.put(str(lxb_dom_document_type_name(cast(lxb_dom_document_type_t*) node, &len), len));
            out_.put(">");
            break;

        default:
            break;
    }
}

const(char)[] charData(Node* n)
{
    auto cd = cast(lxb_dom_character_data_t*) n;
    return str(cd.data.data, cd.data.length);
}

// The text of these elements is not escaped
bool isRawTextParent(Node* text)
{
    auto p = text.parent;
    if (p is null || p.ns != LXB_NS_HTML) return false;

    switch (p.local_name)
    {
        case LXB_TAG_STYLE, LXB_TAG_SCRIPT, LXB_TAG_XMP, LXB_TAG_IFRAME, LXB_TAG_NOEMBED, LXB_TAG_NOFRAMES, LXB_TAG_PLAINTEXT:
            return true;
        case LXB_TAG_NOSCRIPT:
            return p.owner_document.scripting;
        default:
            return false;
    }
}

bool isVoid(Node* n)
{
    if (n.ns != LXB_NS_HTML) return false;

    switch (n.local_name)
    {
        case LXB_TAG_AREA, LXB_TAG_BASE, LXB_TAG_BASEFONT, LXB_TAG_BGSOUND, LXB_TAG_BR, LXB_TAG_COL, LXB_TAG_EMBED,
             LXB_TAG_FRAME, LXB_TAG_HR, LXB_TAG_IMG, LXB_TAG_INPUT, LXB_TAG_KEYGEN, LXB_TAG_LINK, LXB_TAG_META,
             LXB_TAG_PARAM, LXB_TAG_SOURCE, LXB_TAG_TRACK, LXB_TAG_WBR:
            return true;
        default:
            return false;
    }
}

// Escape `&`, U+00A0, `<`, `>` (and `"` in attributes)
void escape(bool attribute, O)(const(char)[] s, ref O out_)
{
    size_t start = 0;

    foreach (i; 0 .. s.length)
    {
        string rep;
        switch (s[i])
        {
            case '&': rep = "&amp;"; break;
            case '<': rep = "&lt;"; break;
            case '>': rep = "&gt;"; break;
            case '"': static if (attribute) { rep = "&quot;"; break; } else continue;
            case '\xC2':
                if (i + 1 < s.length && s[i + 1] == '\xA0')
                {
                    out_.put(s[start .. i]);
                    out_.put("&nbsp;");
                    start = i + 2;
                }
                continue;
            default: continue;
        }

        out_.put(s[start .. i]);
        out_.put(rep);
        start = i + 1;
    }

    if (start < s.length) out_.put(s[start .. $]);
}
