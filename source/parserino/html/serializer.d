/++
 HTML serialization ("serializing HTML fragments" in the HTML spec).

 The output goes to any output range of `const(char)[]`, through a small buffer,
 so the sink receives a few large chunks.
+/
module parserino.html.serializer;

import parserino.dom;
import parserino.names;

/// What `serialize` writes
enum Serialize
{
    Node,       /// only the node: the start tag for elements, the text for texts, ...
    Tree,       /// the node and its descendants (for a document: its children)
    Children,   /// only the descendants (innerHTML)
}

/// Serialize `node` to `sink` (an output range of `const(char)[]`)
void serialize(Sink)(const(DomNode)* node, ref Sink sink, Serialize what)
{
    auto out_ = Buffered!Sink(&sink);

    final switch (what)
    {
        case Serialize.Node:
            if (node.type == NodeType.Document) out_.put("<#document>");
            else if (node.type == NodeType.Element) startTag(node.as!DomElement, out_);
            else leaf(node, out_);
            break;

        case Serialize.Tree:
            if (node.type == NodeType.Document || node.type == NodeType.DocumentFragment) children(node, out_);
            else subtree(node, out_);
            break;

        case Serialize.Children:
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

void children(O)(const(DomNode)* parent, ref O out_)
{
    for (const(DomNode)* c = parent.firstChildOrContent; c !is null; c = c.next)
        subtree(c, out_);
}

// Iterative preorder, so deep trees don't overflow the stack.
// For a <template> the content is serialized instead of the children (as in the standard).
void subtree(O)(const(DomNode)* root, ref O out_)
{
    const(DomNode)* node = root;

    while (true)
    {
        bool isElement = node.type == NodeType.Element;

        if (isElement) startTag(node.as!DomElement, out_);
        else leaf(node, out_);

        if (isElement && !isVoid(node))
            if (auto first = node.firstChildOrContent)
            {
                node = first;
                continue;
            }

        // Close the elements we are leaving
        while (true)
        {
            if (node.type == NodeType.Element && !isVoid(node)) endTag(node.as!DomElement, out_);
            if (node is root) return;
            if (node.next !is null) { node = node.next; break; }
            node = node.parentOrHost;
        }
    }
}

void startTag(O)(const(DomElement)* e, ref O out_)
{
    out_.put("<");
    out_.put(e.fullName);

    for (const(DomAttribute)* a = e.firstAttr; a !is null; a = a.next)
    {
        out_.put(" ");
        attribute(a, out_);
    }

    out_.put(">");
}

void endTag(O)(const(DomElement)* e, ref O out_)
{
    out_.put("</");
    out_.put(e.fullName);
    out_.put(">");
}

void attribute(O)(const(DomAttribute)* a, ref O out_)
{
    auto local = a.localName;

    switch (a.ns)
    {
        case Ns.Xml: out_.put("xml:"); out_.put(local); break;
        case Ns.Xlink: out_.put("xlink:"); out_.put(local); break;
        case Ns.Xmlns:
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
void leaf(O)(const(DomNode)* node, ref O out_)
{
    switch (node.type)
    {
        case NodeType.Text:
            auto data = node.as!DomCharacterData.data;
            if (isRawTextParent(node)) out_.put(data);
            else escape!false(data, out_);
            break;

        case NodeType.Comment:
            out_.put("<!--");
            out_.put(node.as!DomCharacterData.data);
            out_.put("-->");
            break;

        case NodeType.ProcessingInstruction:
            auto pi = node.as!DomCharacterData;
            out_.put("<?");
            out_.put(pi.target);
            out_.put(" ");
            out_.put(pi.data);
            out_.put("?>");
            break;

        case NodeType.DocumentType:
            out_.put("<!DOCTYPE ");
            out_.put(node.as!DomDocumentType.name);
            out_.put(">");
            break;

        default:
            break;
    }
}

// The text of these elements is not escaped
bool isRawTextParent(const(DomNode)* text) @nogc nothrow pure
{
    auto p = text.parent;
    if (p is null || p.ns != Ns.Html || p.type != NodeType.Element) return false;

    switch (p.name)
    {
        case Tag.Style, Tag.Script, Tag.Xmp, Tag.Iframe, Tag.Noembed, Tag.Noframes, Tag.Plaintext:
            return true;
        case Tag.Noscript:
            return p.document.scripting;
        default:
            return false;
    }
}

bool isVoid(const(DomNode)* n) @nogc nothrow pure
{
    if (n.ns != Ns.Html) return false;

    switch (n.name)
    {
        case Tag.Area, Tag.Base, Tag.Basefont, Tag.Bgsound, Tag.Br, Tag.Col, Tag.Embed, Tag.Frame, Tag.Hr, Tag.Img,
             Tag.Input, Tag.Keygen, Tag.Link, Tag.Meta, Tag.Param, Tag.Source, Tag.Track, Tag.Wbr:
            return true;
        default:
            return false;
    }
}

// Escape `&`, U+00A0, `<`, `>` (and `"` in attributes)
void escape(bool attribute, O)(scope const(char)[] s, ref O out_)
{
    size_t start = 0;
    size_t i = 0;

    while (true)
    {
        i = nextSpecial!attribute(s, i);
        if (i >= s.length) break;

        string rep;
        switch (s[i])
        {
            case '&': rep = "&amp;"; break;
            case '<': rep = "&lt;"; break;
            case '>': rep = "&gt;"; break;
            case '"': rep = "&quot;"; break;
            default:
                // U+00A0 (\xC2\xA0) is &nbsp;
                if (i + 1 < s.length && s[i + 1] == '\xA0')
                {
                    out_.put(s[start .. i]);
                    out_.put("&nbsp;");
                    i += 2;
                    start = i;
                }
                else i++;
                continue;
        }

        out_.put(s[start .. i]);
        out_.put(rep);
        i++;
        start = i;
    }

    if (start < s.length) out_.put(s[start .. $]);
}

// The next char to escape from `i` (`&`, `<`, `>`, `\xC2`, and `"` in attributes), or s.length.
// 8 bytes at a time: a byte equal to `c` is a zero byte of `w ^ c...c`.
size_t nextSpecial(bool attribute)(scope const(char)[] s, size_t i) @trusted
{
    enum ulong ones = 0x0101_0101_0101_0101, high = 0x8080_8080_8080_8080;
    static ulong zeroByte(ulong x) { return (x - ones) & ~x; }

    if (!__ctfe)
    {
        while (i + 8 <= s.length)
        {
            ulong w = *cast(const(ulong)*) (s.ptr + i);
            ulong m = zeroByte(w ^ (ones * '&')) | zeroByte(w ^ (ones * '<')) | zeroByte(w ^ (ones * '>'))
                | zeroByte(w ^ (ones * 0xC2));
            static if (attribute) m |= zeroByte(w ^ (ones * '"'));
            if (m & high) break;
            i += 8;
        }
    }

    for (; i < s.length; i++)
    {
        auto c = s[i];
        if (c == '&' || c == '<' || c == '>' || c == '\xC2') return i;
        static if (attribute) if (c == '"') return i;
    }
    return i;
}
