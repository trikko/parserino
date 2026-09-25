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

/++ Serialize `node` indented, to read it: each block element on its own line, two spaces for
 + each level; an element with only text and inline elements (`<li>Milk <b>2</b></li>`) stays
 + on one line. Whitespace between the nodes is changed (runs of spaces become one, the
 + whitespace between blocks is dropped), except in `<pre>`, `<textarea>`, `<script>`, `<style>`, ...
 +/
void serializePretty(Sink)(const(DomNode)* node, ref Sink sink)
{
    auto out_ = Buffered!Sink(&sink);
    auto p = Pretty!(typeof(out_))(&out_);
    p.run(node);
    out_.flush();
}

private:

struct Pretty(O)
{
    O* out_;
    bool firstLine = true;
    bool atStart;           // nothing written yet on this line, after the start tag
    bool pendingSpace;      // a run of whitespace, written only if something follows it

    this(O* o) { out_ = o; }

    // Iterative, so deep trees don't overflow the stack: the stack holds the expanded elements
    void run(const(DomNode)* root)
    {
        const(DomNode)*[] parents, nexts;
        size_t hidden = 0;      // 1 if the root itself is not written (a document, a fragment)

        if (root.type == NodeType.Document || root.type == NodeType.DocumentFragment) hidden = 1;
        else if (!unit(root, 0)) return;

        parents ~= root;
        nexts ~= root.firstChildOrContent;

        while (parents.length)
        {
            auto c = nexts[$ - 1];
            if (c is null)
            {
                auto p = parents[$ - 1];
                parents = parents[0 .. $ - 1];
                nexts = nexts[0 .. $ - 1];
                if (p.type == NodeType.Element)
                {
                    newLine(parents.length - hidden);
                    endTag(p.as!DomElement, *out_);
                }
                continue;
            }

            nexts[$ - 1] = c.next;
            if (unit(c, parents.length - hidden))
            {
                parents ~= c;
                nexts ~= c.firstChildOrContent;
            }
        }
    }

    // Write a child of an expanded element on its own line. True if it's an element to expand.
    bool unit(const(DomNode)* n, size_t depth)
    {
        switch (n.type)
        {
            case NodeType.Text:
                auto data = n.as!DomCharacterData.data;
                if (isBlank(data)) return false;
                newLine(depth);
                if (isRawTextParent(n)) out_.put(data);
                else text(data);
                return false;

            case NodeType.Element:
                newLine(depth);
                if (isCompact(n)) { flat(n); return false; }
                startTag(n.as!DomElement, *out_);
                return true;

            default:
                newLine(depth);
                leaf(n, *out_);
                return false;
        }
    }

    void newLine(size_t depth)
    {
        if (!firstLine) out_.put("\n");
        firstLine = false;
        foreach (_; 0 .. depth) out_.put("  ");
        atStart = true;
        pendingSpace = false;
    }

    // An element on one line: as `subtree`, with the whitespace of the texts collapsed
    void flat(const(DomNode)* root)
    {
        const(DomNode)* node = root;

        while (true)
        {
            bool isElement = node.type == NodeType.Element;

            if (isElement) { flushSpace(); startTag(node.as!DomElement, *out_); atStart = node is root; }
            else if (node.type == NodeType.Text)
            {
                auto data = node.as!DomCharacterData.data;
                if (isRawTextParent(node)) { flushSpace(); out_.put(data); }
                else if (verbatim(node, root)) { flushSpace(); escape!false(data, *out_); }
                else text(data);
            }
            else { flushSpace(); leaf(node, *out_); }

            if (isElement && !isVoid(node))
                if (auto first = node.firstChildOrContent)
                {
                    node = first;
                    continue;
                }

            while (true)
            {
                if (node.type == NodeType.Element && !isVoid(node))
                {
                    if (node is root) pendingSpace = false;     // no space before the last end tag
                    else flushSpace();
                    endTag(node.as!DomElement, *out_);
                }
                if (node is root) return;
                if (node.next !is null) { node = node.next; break; }
                node = node.parentOrHost;
            }
        }
    }

    // A text with its runs of whitespace collapsed; no space at the start of the line
    void text(scope const(char)[] data)
    {
        size_t i = 0;
        while (i < data.length)
        {
            if (isSpace(data[i]))
            {
                while (i < data.length && isSpace(data[i])) i++;
                pendingSpace = true;
                continue;
            }
            size_t start = i;
            while (i < data.length && !isSpace(data[i])) i++;
            flushSpace();
            escape!false(data[start .. i], *out_);
            atStart = false;
        }
    }

    void flushSpace()
    {
        if (pendingSpace && !atStart) out_.put(" ");
        pendingSpace = false;
        atStart = false;
    }
}

bool isSpace(char c) @nogc nothrow pure { return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\f'; }

bool isBlank(scope const(char)[] s) @nogc nothrow pure
{
    foreach (c; s) if (!isSpace(c)) return false;
    return true;
}

// Is the text inside an element that keeps its whitespace (up to `root`)?
bool verbatim(const(DomNode)* text, const(DomNode)* root) @nogc nothrow pure
{
    for (auto p = text.parentOrHost; p !is null; p = p.parentOrHost)
    {
        if (p.type == NodeType.Element && p.ns == Ns.Html)
            switch (p.name)
            {
                case Tag.Pre, Tag.Textarea, Tag.Listing, Tag.Plaintext: return true;
                default: break;
            }
        if (p is root) break;
    }
    return false;
}

// Can the element stay on one line? Yes if it keeps its whitespace, or if it has only texts,
// comments and inline elements inside
bool isCompact(const(DomNode)* e) @nogc nothrow pure
{
    if (e.ns == Ns.Html)
        switch (e.name)
        {
            case Tag.Pre, Tag.Textarea, Tag.Listing, Tag.Plaintext, Tag.Script, Tag.Style, Tag.Xmp,
                 Tag.Iframe, Tag.Noembed, Tag.Noframes, Tag.Title:
                return true;
            default: break;
        }

    const(DomNode)* node = e.firstChildOrContent;
    if (node is null) return true;

    while (true)
    {
        if (node.type == NodeType.Element)
        {
            if (!isInline(node)) return false;
            if (auto first = node.firstChildOrContent) { node = first; continue; }
        }
        while (node.next is null)
        {
            node = node.parentOrHost;
            if (node is e) return true;
        }
        node = node.next;
    }
}

// The html elements that are inline content ("phrasing content" in the standard)
bool isInline(const(DomNode)* n) @nogc nothrow pure
{
    if (n.ns != Ns.Html) return false;

    switch (n.name)
    {
        case Tag.A, Tag.Abbr, Tag.Area, Tag.Audio, Tag.B, Tag.Bdi, Tag.Bdo, Tag.Big, Tag.Br, Tag.Button,
             Tag.Canvas, Tag.Cite, Tag.Code, Tag.Data, Tag.Datalist, Tag.Del, Tag.Dfn, Tag.Em, Tag.Embed,
             Tag.Font, Tag.I, Tag.Iframe, Tag.Img, Tag.Input, Tag.Ins, Tag.Kbd, Tag.Label, Tag.Map,
             Tag.Mark, Tag.Meter, Tag.Nobr, Tag.Noscript, Tag.Object, Tag.Output, Tag.Picture,
             Tag.Progress, Tag.Q, Tag.Rp, Tag.Rt, Tag.Ruby, Tag.S, Tag.Samp, Tag.Script, Tag.Select,
             Tag.Slot, Tag.Small, Tag.Span, Tag.Strike, Tag.Strong, Tag.Sub, Tag.Sup, Tag.Template,
             Tag.Textarea, Tag.Time, Tag.Tt, Tag.U, Tag.Var, Tag.Video, Tag.Wbr:
            return true;
        default:
            return false;
    }
}

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
