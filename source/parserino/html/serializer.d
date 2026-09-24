/++
 HTML serialization ("serializing HTML fragments" in the HTML spec).

 The output goes to any output range of `const(char)[]`, through a small buffer,
 so the sink receives a few large chunks.
+/
module parserino.html.serializer;

import parserino.dom;
import parserino.names;

enum Serialize
{
    node,       /// only the node: the start tag for elements, the text for texts, ...
    tree,       /// the node and its descendants (for a document: its children)
    children,   /// only the descendants (innerHTML)
}

/// Serialize `node` to `sink` (an output range of `const(char)[]`)
void serialize(Sink)(const(Node)* node, ref Sink sink, Serialize what)
{
    auto out_ = Buffered!Sink(&sink);

    final switch (what)
    {
        case Serialize.node:
            if (node.type == NodeType.document) out_.put("<#document>");
            else if (node.type == NodeType.element) startTag(node.as!Element, out_);
            else leaf(node, out_);
            break;

        case Serialize.tree:
            if (node.type == NodeType.document || node.type == NodeType.documentFragment) children(node, out_);
            else subtree(node, out_);
            break;

        case Serialize.children:
            children(node, out_);
            break;
    }

    out_.flush();
}

private:

struct Buffered(Sink)
{
    Sink* sink;
    char[4096] buf = void;
    size_t used;

    this(Sink* s) { sink = s; used = 0; }

    void put(scope const(char)[] s)
    {
        // CTFE doesn't handle the uninitialized buffer well (and doesn't need it)
        if (__ctfe) { putToSink(s); return; }

        if (used + s.length > buf.length)
        {
            flush();
            if (s.length > buf.length) { putToSink(s); return; }
        }

        import parserino.arena : copyItems;
        () @trusted { copyItems(buf.ptr + used, s.ptr, s.length); }();
        used += s.length;
    }

    void flush()
    {
        if (used == 0) return;
        putToSink(buf[0 .. used]);
        used = 0;
    }

    void putToSink(scope const(char)[] s)
    {
        import std.range.primitives : put;
        put(*sink, s);
    }
}

void children(O)(const(Node)* parent, ref O out_)
{
    for (const(Node)* c = parent.firstChild; c !is null; c = c.next)
        subtree(c, out_);
}

// Iterative preorder, so deep trees don't overflow the stack
void subtree(O)(const(Node)* root, ref O out_)
{
    const(Node)* node = root;

    while (true)
    {
        bool isElement = node.type == NodeType.element;

        if (isElement)
        {
            auto e = node.as!Element;
            startTag(e, out_);

            // The children of a <template> live in its content fragment
            if (e.templateContent !is null)
                for (const(Node)* c = e.templateContent.node.firstChild; c !is null; c = c.next)
                    subtree(c, out_);
        }
        else leaf(node, out_);

        if (isElement && !isVoid(node) && node.firstChild !is null)
        {
            node = node.firstChild;
            continue;
        }

        // Close the elements we are leaving
        while (true)
        {
            if (node.type == NodeType.element && !isVoid(node)) endTag(node.as!Element, out_);
            if (node is root) return;
            if (node.next !is null) { node = node.next; break; }
            node = node.parent;
        }
    }
}

void startTag(O)(const(Element)* e, ref O out_)
{
    out_.put("<");
    out_.put(e.fullName);

    for (const(Attribute)* a = e.firstAttr; a !is null; a = a.next)
    {
        out_.put(" ");
        attribute(a, out_);
    }

    out_.put(">");
}

void endTag(O)(const(Element)* e, ref O out_)
{
    out_.put("</");
    out_.put(e.fullName);
    out_.put(">");
}

void attribute(O)(const(Attribute)* a, ref O out_)
{
    auto local = a.localName;

    switch (a.ns)
    {
        case Ns.xml: out_.put("xml:"); out_.put(local); break;
        case Ns.xlink: out_.put("xlink:"); out_.put(local); break;
        case Ns.xmlns:
            if (local == "xmlns") out_.put("xmlns");
            else { out_.put("xmlns:"); out_.put(local); }
            break;
        default:
            out_.put(a.fullName);
            break;
    }

    out_.put(`="`);
    escape!true(a.value, out_);
    out_.put(`"`);
}

// Texts, comments, doctypes and processing instructions
void leaf(O)(const(Node)* node, ref O out_)
{
    switch (node.type)
    {
        case NodeType.text:
            auto data = node.as!CharacterData.data;
            if (isRawTextParent(node)) out_.put(data);
            else escape!false(data, out_);
            break;

        case NodeType.comment:
            out_.put("<!--");
            out_.put(node.as!CharacterData.data);
            out_.put("-->");
            break;

        case NodeType.processingInstruction:
            auto pi = node.as!CharacterData;
            out_.put("<?");
            out_.put(pi.target);
            out_.put(" ");
            out_.put(pi.data);
            out_.put("?>");
            break;

        case NodeType.documentType:
            out_.put("<!DOCTYPE ");
            out_.put(node.as!DocumentType.name);
            out_.put(">");
            break;

        default:
            break;
    }
}

// The text of these elements is not escaped
bool isRawTextParent(const(Node)* text) @nogc nothrow pure
{
    auto p = text.parent;
    if (p is null || p.ns != Ns.html || p.type != NodeType.element) return false;

    switch (p.name)
    {
        case Tag.style, Tag.script, Tag.xmp, Tag.iframe, Tag.noembed, Tag.noframes, Tag.plaintext:
            return true;
        case Tag.noscript:
            return p.document.scripting;
        default:
            return false;
    }
}

bool isVoid(const(Node)* n) @nogc nothrow pure
{
    if (n.ns != Ns.html) return false;

    switch (n.name)
    {
        case Tag.area, Tag.base, Tag.basefont, Tag.bgsound, Tag.br, Tag.col, Tag.embed, Tag.frame, Tag.hr, Tag.img,
             Tag.input, Tag.keygen, Tag.link, Tag.meta, Tag.param, Tag.source, Tag.track, Tag.wbr:
            return true;
        default:
            return false;
    }
}

// Escape `&`, U+00A0, `<`, `>` (and `"` in attributes)
void escape(bool attribute, O)(scope const(char)[] s, ref O out_)
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
