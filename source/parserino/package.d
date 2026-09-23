/*
Copyright (c) 2022-2026 Andrea Fontana
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

/** HTML5 parser and DOM manipulation library.
 *
 * Parserino is a fast html5 parser and DOM manipulation library written in pure D
 * (the parser is a D port of the lexbor library).
 * ---
 * import parserino;
 * void main()
 * {
 *    auto doc = Document("<html><body><p>Hello World!</p></body></html>");
 *    assert(doc.body.firstChild.innerText == "Hello World!");
 *    assert(doc.byTagName("p").front.innerText == "Hello World!");
 * }
 * ---
 * The main types you will use are `parserino.Document` and `parserino.Element`.
 *
 * Memory: a `Document` is reference counted. Every `Element` keeps its document alive,
 * so elements are always safe to use, even after the `Document` variable goes out of scope.
 * Nodes removed from the tree stay valid (they are released with their document).
 *
 * Lazy parsing: `Document.parseLazy` builds the tree only as far as your queries need.
 * `doc.byClass("x").take(3)` stops parsing a little after the third match.
 */
module parserino;

import parserino.lexbor.core.base;
import parserino.lexbor.core.array;
import parserino.lexbor.core.str;
import parserino.lexbor.tag.tag;
import parserino.lexbor.tag.const_;
import parserino.lexbor.ns.const_;
import parserino.lexbor.dom.interfaces.node;
import parserino.lexbor.dom.interfaces.element;
import parserino.lexbor.dom.interfaces.attr;
import parserino.lexbor.dom.interfaces.document;
import parserino.lexbor.dom.interfaces.character_data;
import parserino.lexbor.html.interfaces.document;
import parserino.lexbor.html.parser;
import parserino.lexbor.html.tree;
import parserino.lexbor.html.serialize;
import parserino.arena : Arena;
import parserino.css.selector : SelectorList, parseSelector;
static import parserino.css.matcher;

import core.stdc.stdlib : calloc, realloc, free, malloc;
import core.stdc.string : memchr, memcpy;
import core.atomic : atomicOp;
import std.range.primitives : isInputRange, isOutputRange, ElementType;
import std.traits : isSomeString;

/// Order of visit
enum VisitOrder
{
    Normal, /// Normal
    Reverse /// Reverse
}

/// Thrown on invalid operations (invalid element, wrong node type, bad selector, ...)
class ParserinoException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow @safe { super(msg, file, line); }
}

/// Default chunk size used by `Document.parseLazy`
enum size_t defaultChunkSize = 16 * 1024;

/// The HTML5 Document
struct Document
{
    /// Parse a whole document
    this(const(char)[] html)
    {
        impl = DocImpl.create();
        scope(failure) { DocImpl.release(impl); impl = null; }
        impl.parseAll(html);
    }

    /++ Parse a document incrementally.
    + The tree is built chunk by chunk, only when a query or an accessor needs more of it.
    + The results are always the same as for a fully parsed document.
    + ---
    + auto doc = Document.parseLazy(hugeHtml);
    + auto links = doc.byTagName("a").take(3).array;   // parses only the beginning of the document
    + assert(doc.bytesParsed < hugeHtml.length);
    + ---
    + Any mutation of the document (or of one of its elements) completes the parsing first.
    +/
    static Document parseLazy(const(char)[] html, size_t chunkSize = defaultChunkSize)
    {
        Document d;
        d.impl = DocImpl.create();
        scope(failure) { DocImpl.release(d.impl); d.impl = null; }
        d.impl.beginLazy(html, chunkSize == 0 ? defaultChunkSize : chunkSize);
        return d;
    }

    ///
    unittest
    {
        import std.range : take;
        import std.array : array, replicate;

        string html = "<html><body>" ~ `<p class="x">hello</p>`.replicate(10_000);

        auto doc = Document.parseLazy(html, 1024);
        assert(doc.isParsing);

        auto found = doc.byClass("x").take(3).array;
        assert(found.length == 3);
        assert(found[0].innerText == "hello");

        // Only a small part of the input was parsed
        assert(doc.bytesParsed < 4096);

        doc.finishParsing();
        assert(!doc.isParsing);
        assert(doc.bytesParsed == html.length);
        assert(doc.byClass("x").walkLength == 10_000);
    }

    unittest
    {
        import std.range : take;
        import std.array : array, replicate;

        // A mutation in the middle of a lazy query completes the parsing: the range goes on
        string html = "<body>" ~ `<div class="x"><b>a</b></div>`.replicate(2000);
        auto doc = Document.parseLazy(html, 256);

        auto r = doc.byClass("x");
        r.front.setAttribute("id", "first");
        assert(!doc.isParsing);

        r.popFront();
        assert(r.front.innerHTML == "<b>a</b>");
        assert(r.walkLength == 1999);
        assert(doc.byId("first").isValid);

        // Accessors wait for the element to be complete
        auto doc2 = Document.parseLazy("<body><table><tr><td>1<td>2</table><p>after", 4);
        auto td = doc2.byTagName("td").front;
        assert(td.next == "<td>2</td>");
        assert(doc2.byTagName("p").front.innerText == "after");

        // Foster parenting: text inside an open table goes before it
        auto doc3 = Document.parseLazy("<body><table>moved<tr><td>x</table>", 3);
        assert(doc3.body.firstChild(true).innerText == "moved");
    }

    unittest
    {
        import core.thread : Thread;
        import std.array : replicate;

        // Different documents in different threads
        string html = "<ul>" ~ `<li class="a">x</li>`.replicate(500) ~ "</ul>";
        size_t[4] counts;
        Thread[] threads;

        auto worker(size_t i)
        {
            return {
                foreach (_; 0 .. 20)
                {
                    auto doc = i % 2 ? Document(html) : Document.parseLazy(html, 512);
                    counts[i] += doc.bySelector("ul > li.a:nth-child(2n)").walkLength;
                }
            };
        }

        foreach (i; 0 .. counts.length)
        {
            threads ~= new Thread(worker(i));
            threads[$ - 1].start();
        }

        foreach (t; threads) t.join();
        foreach (c; counts) assert(c == 20 * 250);
    }

    // Postblit (not a copy constructor): copy constructors break ranges like `map!(x => ...)`
    this(this) { if (impl !is null) impl.retain(); }

    ~this() { if (impl !is null) DocImpl.release(impl); impl = null; }

    ///
    ref Document opAssign(Document rhs) return
    {
        auto tmp = impl;
        impl = rhs.impl;
        rhs.impl = tmp;
        return this;
    }

    ///
    ref Document opAssign(const(char)[] html) return { return this = Document(html); }

    ///
    ref Document opAssign(typeof(null)) return { return this = Document.init; }

    bool opEquals(const typeof(null)) const @safe nothrow pure { return !isValid; }
    bool opEquals(D)(auto ref const D d) const
    {
        static if (isSomeString!D) return isValid && toString() == d;
        else return impl is d.impl;
    }

    /// Is this a valid html5 document?
    @property bool isValid() const @safe nothrow pure @nogc { return impl !is null; }

    ///
    unittest
    {
        Document doc = Document("<html><body>");
        Document doc2;
        Document docCpy = doc;

        assert(doc != null);
        assert(doc.isValid);
        assert(docCpy != null);
        assert(docCpy.isValid);

        assert(doc2 == null);
        assert(!doc2.isValid);

        assert(doc == docCpy);
        assert(doc2 != doc);
        assert(doc2 != docCpy);
    }

    /// Is the document still being parsed? (see `parseLazy`)
    @property bool isParsing() const @safe nothrow pure @nogc { return impl !is null && impl.parsing; }

    /// Number of input bytes given to the parser so far
    @property size_t bytesParsed() const @safe nothrow pure @nogc { return impl is null ? 0 : impl.fed; }

    /// Complete the parsing of a lazy document. It does nothing on a fully parsed one.
    void finishParsing() { onlyValid(); impl.finish(); }

    /// Return document as html string
    string toString() const
    {
        import std.array : appender;
        auto app = appender!string;
        toString((const(char)[] s) { app.put(s); });
        return app.data;
    }

    /// Write the document as html to a sink
    void toString(scope void delegate(const(char)[]) sink) const
    {
        auto d = (cast() this).mutableImpl();
        d.finish();
        serialize!lxb_html_serialize_tree_cb(&d.html.dom_document.node, sink);
    }

    /// ditto
    void toString(W)(ref W writer) const
    if (isOutputRange!(W, const(char)[]) && !is(W : void delegate(const(char)[])))
    {
        import std.range.primitives : put;
        toString((const(char)[] s) { put(writer, s); });
    }

    unittest
    {
        Document doc = "<html>";
        assert(doc == "<html><head></head><body></body></html>");

        import std.array : appender;
        auto app = appender!string;
        doc.toString(app);
        assert(app.data == "<html><head></head><body></body></html>");

        import std.format : format;
        assert(format("%s", doc) == "<html><head></head><body></body></html>");
    }

    /// The content of `<title>` tag
    @property string title() { return titleImpl(false); }

    /// ditto, without whitespace normalization
    @property string rawTitle() { return titleImpl(true); }

    /// Set the content of `<title>` tag
    @property void title(const(char)[] s)
    {
        onlyValid();
        impl.finish();
        check(lxb_html_document_title_set(impl.html, cast(const(ubyte)*) s.ptr, s.length), "Can't set the title");
    }

    unittest
    {
        Document doc = Document("<html><head><title>Hello World!&gt;");
        assert(doc.title == "Hello World!>");

        doc.title = "Goodbye";
        assert(doc.title == "Goodbye");

        Document empty = "<p>";
        assert(empty.title == "");
    }

    /// Create a html element
    Element createElement(const(char)[] tagName)
    {
        onlyValid();
        auto e = lxb_dom_document_create_element(&impl.html.dom_document, cast(const(ubyte)*) tagName.ptr, tagName.length, null);
        if (e is null) throw new ParserinoException("Can't create element `" ~ tagName.idup ~ "`");
        return Element(this, &e.node);
    }

    /// Create a text node
    Element createText(const(char)[] text)
    {
        onlyValid();
        auto t = lxb_dom_document_create_text_node(&impl.html.dom_document, cast(const(ubyte)*) text.ptr, text.length);
        if (t is null) throw new ParserinoException("Can't create text node");
        return Element(this, cast(lxb_dom_node_t*) t);
    }

    /// Create a comment
    Element createComment(const(char)[] text)
    {
        onlyValid();
        auto c = lxb_dom_document_create_comment(&impl.html.dom_document, cast(const(ubyte)*) text.ptr, text.length);
        if (c is null) throw new ParserinoException("Can't create comment");
        return Element(this, cast(lxb_dom_node_t*) c);
    }

    ///
    unittest
    {
        Document d = `<p>`;

        Element p = d.body.firstChild;
        Element t = d.createText("this is a test");
        Element c = d.createComment("this is a comment");
        p.appendChild(t);
        p.appendChild(c);

        assert(p == "<p>this is a test<!--this is a comment--></p>");
    }

    unittest
    {
        Document doc = Document("<html>");
        Element e = doc.createElement("title");

        assert(e.isValid);

        auto html = doc;
        assert(html == "<html><head></head><body></body></html>");
    }

    /// The `<html>` element
    @property Element documentElement()
    {
        onlyValid();
        while (impl.html.dom_document.element is null && impl.advance()) {}
        return Element(this, cast(lxb_dom_node_t*) impl.html.dom_document.element);
    }

    /// The `<body>` element
    @property Element body()
    {
        onlyValid();
        while (impl.parsing && (impl.html.body is null || !impl.isStable(cast(lxb_dom_node_t*) impl.html.body)))
            impl.advance();

        return Element(this, cast(lxb_dom_node_t*) impl.html.body);
    }

    /// The `<head>` element
    @property Element head()
    {
        onlyValid();
        while (impl.parsing && impl.html.head is null)
            impl.advance();

        return Element(this, cast(lxb_dom_node_t*) impl.html.head);
    }

    unittest
    {
        Document doc = Document("<html><body>Text");

        assert(doc.head.isValid());
        assert(doc.body.isValid());
        assert(doc.body.innerText == "Text");
        assert(doc.documentElement.name == "html");
    }

    // Note: the forwarders below use a local variable, because dmd 2.112 miscompiles
    // `return temporary().method();` when the result has a destructor.

    /// Get an element by id. It returns an invalid element (`== null`) if not found.
    Element byId(string id) { auto root = rootElement; return root.byId(id); }

    /// A lazy range of elements filtered by class
    auto byClass(string name) { auto root = rootElement; return root.byClass(name); }

    /// A lazy range of elements filtered by tag name
    auto byTagName(string name) { auto root = rootElement; return root.byTagName(name); }

    /++ A lazy range of elements identified by an adjacent comment
    + ---
    + Document doc = "<div><!--hello--><p></p></div>";
    + Element e = doc.byComment("hello").front;
    + assert(e.next.name == "p");
    + ---
    +/
    auto byComment(string comment, bool stripSpaces = true) { auto root = rootElement; return root.byComment(comment, stripSpaces); }

    /// A lazy range of elements filtered using a css selector
    auto bySelector(const(char)[] selector) { auto root = rootElement; return root.bySelector(selector); }

    /// ditto
    auto bySelector(Selector selector) { auto root = rootElement; return root.bySelector(selector); }

    /// All the nodes of the document, in tree order
    auto descendants(VisitOrder order = VisitOrder.Normal)(bool returnAllElements = false) { auto root = rootElement; return root.descendants!order(returnAllElements); }

    /++ You can cast a document to a string
    + ---
    + string html = cast(string) doc;
    + assert(doc == html);
    + ---
    +/
    string opCast(T : string)() const { return toString(); }

    unittest
    {
        Document doc = "<p>";
        Document doc2;
        doc2 = doc;

        assert(doc == "<html><head></head><body><p></p></body></html>");
        assert(doc2 == "<html><head></head><body><p></p></body></html>");

        doc = Document("<b>");
        assert(doc == "<html><head></head><body><b></b></body></html>");
        assert(doc2 == "<html><head></head><body><p></p></body></html>");

        doc = "<i>";
        assert(doc == "<html><head></head><body><i></i></body></html>");
        assert(doc2 == "<html><head></head><body><p></p></body></html>");
    }

    unittest
    {
        Document doc = "<html><p>";
        assert(doc == "<html><head></head><body><p></p></body></html>");

        doc = null;
        assert(doc == null);
        doc = "<a>";
        assert(doc == "<html><head></head><body><a></a></body></html>");
    }

    unittest
    {
        // Elements keep the document alive
        Element p;
        {
            Document doc = "<p>hello</p>";
            p = doc.byTagName("p").front;
        }

        assert(p.innerText == "hello");
        assert(p.owner.isValid);
        assert(p.owner.body.firstChild == p);
    }

    /// Parse a fragment of html. The fragment is not attached to the document.
    Element fragment(const(char)[] html)
    {
        onlyValid();
        impl.finish();

        auto context = lxb_dom_document_create_element(&impl.html.dom_document, cast(const(ubyte)*) "div".ptr, 3, null);
        auto node = lxb_html_document_parse_fragment(impl.html, context, cast(const(ubyte)*) html.ptr, html.length);
        if (node is null) throw new ParserinoException("Can't parse the fragment");
        return Element(this, node);
    }

    ///
    unittest
    {
        Document doc = Document("<html>");
        Element e = doc.fragment("<p><b>hello</b>world");

        auto range = e.descendants();
        assert(range.front.name == "p");
    }

    private:

    DocImpl* impl;

    DocImpl* mutableImpl() { onlyValid(); return impl; }

    void onlyValid(string fname = __FUNCTION__) const
    {
        if (impl is null)
            throw new ParserinoException("Can't call `" ~ fname ~ "` for an invalid/uninitialized document");
    }

    Element rootElement() { onlyValid(); return Element(this, &impl.html.dom_document.node); }

    string titleImpl(bool raw)
    {
        onlyValid();

        // The title is the first <title> in tree order: find it lazily, then wait until it is complete.
        auto t = rootElement.byTagName("title").frontOrInit;
        if (t.isValid) impl.ensureClosed(t.node);

        size_t length;
        const(ubyte)* res = raw
            ? lxb_html_document_title_raw(impl.html, &length)
            : lxb_html_document_title(impl.html, &length);

        return res is null ? "" : (cast(const(char)[]) res[0 .. length]).idup;
    }
}


/// A html element (or a text/comment node)
struct Element
{
    /// A simple key/value struct representing a html attribute
    struct Attribute
    {
        string name;    /// Name of the attribute. For example "href"
        string value;   /// Value of the attribute. For example "https://dlang.org"
    }

    /// The owner of this element
    @property Document owner() { return doc; }

    /// Is this element valid?
    @property bool isValid() const @safe nothrow pure @nogc { return node !is null; }

    /// Is this a html element? (and not a text or a comment node)
    @property bool isElement() const @safe nothrow pure @nogc { return node !is null && node.type == LXB_DOM_NODE_TYPE_ELEMENT; }

    /// Is this a text node?
    @property bool isText() const @safe nothrow pure @nogc { return node !is null && node.type == LXB_DOM_NODE_TYPE_TEXT; }

    /// Is this a comment?
    @property bool isComment() const @safe nothrow pure @nogc { return node !is null && node.type == LXB_DOM_NODE_TYPE_COMMENT; }

    /// Is this element empty? (no elements and no text, whitespaces excluded)
    @property bool isEmpty() { onlyValidElements(); impl.ensureClosed(node); return lxb_dom_node_is_empty(node); }

    unittest
    {
        Document doc = "<b>hello</b><br><b>";
        import std.array;
        import std.algorithm : map;
        assert(doc.body.children.map!(x => x.isEmpty()).array == [false, true, true]);
    }

    /// Return a lazy range of attributes for this element
    @property AttributeRange attributes()
    {
        onlyRealElements();
        impl.ensureAttrs(node);
        return AttributeRange(doc, element.first_attr);
    }

    /// Check if an attribute exists
    bool hasAttribute(const(char)[] attr)
    {
        onlyRealElements();
        impl.ensureAttrs(node);
        return lxb_dom_element_has_attribute(element, cast(const(ubyte)*) attr.ptr, attr.length);
    }

    /// Remove an attribute from this element
    void removeAttribute(const(char)[] attr)
    {
        onlyRealElements();
        impl.finish();
        lxb_dom_element_remove_attribute(element, cast(const(ubyte)*) attr.ptr, attr.length);
    }

    /// Set an attribute for this element
    void setAttribute(const(char)[] name, const(char)[] value)
    {
        onlyRealElements();
        impl.finish();
        if (lxb_dom_element_set_attribute(element, cast(const(ubyte)*) name.ptr, name.length, cast(const(ubyte)*) value.ptr, value.length) is null)
            throw new ParserinoException("Can't set attribute `" ~ name.idup ~ "`");
    }

    /// Get an attribute. It returns `null` if the attribute is missing.
    string getAttribute(const(char)[] attr)
    {
        auto v = getAttributeView(attr);
        if (v is null) return null;
        return v.length == 0 ? "" : v.idup;
    }

    /++ Get an attribute without copying it.
    + The slice points into the document memory: it is valid until the attribute is changed
    + or the document is destroyed. It returns `null` if the attribute is missing.
    +/
    const(char)[] getAttributeView(const(char)[] attr)
    {
        onlyRealElements();
        impl.ensureAttrs(node);

        auto a = lxb_dom_element_attr_by_name(element, cast(const(ubyte)*) attr.ptr, attr.length);
        if (a is null) return null;
        return attrValue(a);
    }

    /// The id of this element (if present)
    @property string id()
    {
        onlyRealElements();
        impl.ensureAttrs(node);
        if (element.attr_id is null) return string.init;
        return attrValue(element.attr_id).idup;
    }

    /// All the classes of this element
    @property auto classes()
    {
        import std.algorithm : splitter, filter;
        import std.ascii : isWhite;

        onlyRealElements();
        impl.ensureAttrs(node);

        string cls = element.attr_class is null ? "" : attrValue(element.attr_class).idup;
        return cls.splitter!isWhite.filter!(x => x.length > 0);
    }

    unittest
    {
        import std.array;

        Document doc = Document(`<html><p class="hello world" id="world" style><a>`);
        assert(doc.byId("world").attributes.array == [Attribute("class", "hello world"), Attribute("id", "world"), Attribute("style", "")]);
        assert(doc.byTagName("a").front.attributes.empty);

        auto p = doc.byTagName("p").front;
        auto a = doc.byTagName("a").front;

        assert(p.hasAttribute("style"));
        assert(p.hasAttribute("href") == false);
        assert(p.classes.array == ["hello", "world"]);

        assert(p.id == "world");

        a.setAttribute("href", "url");

        assert(a.hasAttribute("href"));
        assert(a.getAttribute("href") == "url");
        assert(a.getAttribute("title") is null);
        assert(p.getAttribute("style") !is null);
        assert(p.getAttribute("style") == "");

        p.removeAttribute("id");
        p.removeAttribute("class");

        assert(p.hasAttribute("style"));
        assert(!p.hasAttribute("id"));
        assert(!p.hasAttribute("class"));
        assert(p.id.length == 0);
        assert(p.classes.array.length == 0);
    }

    bool opEquals(const typeof(null)) const @safe nothrow pure @nogc { return !isValid; }
    bool opEquals(E)(auto ref const E e) const
    {
        static if (isSomeString!E) return isValid && e == this.toString;
        else return e.node is this.node;
    }

    size_t toHash() const nothrow @safe { return hashOf(node); }

    /// The tag name of this element. For example "p" or "div" ("#text" for texts, "!--" for comments)
    @property string name() { return nameView.idup; }

    /// ditto, without copying
    @property const(char)[] nameView()
    {
        onlyValidElements();
        size_t len;
        auto s = lxb_dom_element_local_name(cast(lxb_dom_element_t*) node, &len);
        return s is null ? null : cast(const(char)[]) s[0 .. len];
    }

    unittest
    {
        Document doc = Document(`<!doctype html><html><body id="bo"/>`);
        Element a;
        Element b = doc.body;
        Element c = doc.head;
        Element d = b;
        Element e = a;

        assert(a.isValid == false);
        assert(a == e);
        assert(a == null);

        assert(b != a);
        assert(b != c);
        assert(d == b);

        Element f = doc.byTagName("body").front;
        Element g = doc.byId("bo");

        assert(b == f);
        assert(b == g);

        assert(g.name == "body");
        assert(c.name == "head");
    }

    alias clone = dup;

    /// Clone this element. The new element is not attached to the document.
    Element dup(bool deep = true)
    {
        onlyValidElements();
        impl.ensureClosed(node);

        auto n = lxb_dom_node_clone(node, deep);
        if (n is null) throw new ParserinoException("Can't clone the element");
        return Element(doc, n);
    }

    ///
    unittest
    {
        import std.array;
        import std.algorithm : map;

        Document doc = Document(`<html><p data-a="a" data-b="b"><i></i><b></b>`);
        Element e = doc.byTagName("p").front;
        Element f = e;
        Element g = e.dup(false);
        Element h = g;

        assert(e!=g);
        assert(f!=g);
        assert(g==h);

        assert(g.name == "p");
        assert(g.attributes.array == [Attribute("data-a", "a"), Attribute("data-b", "b")]);
        assert(g.descendants.map!(x=>x.name).array == []);

        g = e.clone(true);
        assert(g.name == "p");
        assert(g.attributes.array == [Attribute("data-a", "a"), Attribute("data-b", "b")]);
        assert(g.descendants.map!(x=>x.name).array == ["i", "b"]);
    }

    /// Insert an element (or a text, or a fragment) before this one
    void prependSibling(E)(auto ref E el)
    {
        onlyValidElements();
        impl.finish();

        foreach (n; nodesToInsert(el))
            lxb_dom_node_insert_before(node, n);
    }

    /// Insert an element (or a text, or a fragment) after this one
    void appendSibling(E)(auto ref E el)
    {
        onlyValidElements();
        impl.finish();

        lxb_dom_node_t* after = node;
        foreach (n; nodesToInsert(el))
        {
            lxb_dom_node_insert_after(after, n);
            after = n;
        }
    }

    /// Put a new child (or a text, or a fragment) in the first position
    void prependChild(E)(auto ref E el)
    {
        onlyRealElements();
        impl.finish();

        auto first = node.first_child;
        foreach (n; nodesToInsert(el))
        {
            if (first is null) lxb_dom_node_insert_child(node, n);
            else lxb_dom_node_insert_before(first, n);
        }
    }

    /// Put a new child (or a text, or a fragment) in the last position
    void appendChild(E)(auto ref E el)
    {
        onlyRealElements();
        impl.finish();

        foreach (n; nodesToInsert(el))
            lxb_dom_node_insert_child(node, n);
    }

    ///
    unittest
    {
        Document doc = "<p>";
        Element p = doc.byTagName("p").front;
        p.prependSibling("<a>first-before</a><a><b>second</b></a>".asFragment);
        p.appendSibling("<a>first-after</a><a><b>second</b></a>".asFragment);
        assert(doc.toString() == `<html><head></head><body><a>first-before</a><a><b>second</b></a><p></p><a>first-after</a><a><b>second</b></a></body></html>`);
    }

    ///
    unittest
    {
        Document doc = `<p id="start">`;

        Element p = doc.byTagName("p").front;
        p.appendChild("<p>post</p><p>post1</p>".asFragment);
        p.prependChild("<p>pre</p><p>pre1</p>".asFragment);
        p.appendChild("<p>text</p>");

        assert(doc.body.toString == `<body><p id="start"><p>pre</p><p>pre1</p><p>post</p><p>post1</p>&lt;p&gt;text&lt;/p&gt;</p></body>`);
    }

    unittest
    {
        Document doc = "<p>";
        Element e = doc.body.children.front;
        e.appendChild("world");
        e.prependChild("hello");
        e.appendChild("!");
        e.prependSibling("before");
        e.appendSibling("after");
        assert(doc == "<html><head></head><body>before<p>helloworld!</p>after</body></html>");
    }

    ///
    void opOpAssign(string op, E)(auto ref E e) if (op == "~") { appendChild(e); }

    /// Remove this element from the document. The element is still valid and can be inserted again.
    bool remove()
    {
        onlyValidElements();
        impl.finish();

        if (node.parent is null) return false;
        lxb_dom_node_remove(node);
        return true;
    }

    unittest
    {
        Document doc = "<p>";
        Element bod = doc.body;
        Element other = doc.createElement("a");
        bod ~= other;
        bod ~= doc.createElement("a");
        bod.appendChild(doc.createElement("b"));
        bod.prependChild(doc.createElement("i"));
        assert(doc.body.toString == "<body><i></i><p></p><a></a><a></a><b></b></body>");
    }

    unittest
    {
        Document doc = "<p><b>hello";
        auto comment = doc.createComment("comment");
        doc.byTagName("b").front.prependSibling(comment);
        doc.byTagName("b").front.appendSibling(comment);
        assert(!doc.byTagName("!--").empty);
        assert(doc.byTagName("p").front.toString == `<p><b>hello</b><!--comment--></p>`);
    }

    unittest
    {
        Document doc = Document("<html>");

        Element p = doc.createElement("p");
        doc.body.appendChild(p);

        Element b = doc.createElement("b");
        Element i = doc.createElement("i");
        Element a = doc.createElement("a");
        p.prependSibling(b);
        p.appendSibling(i);
        p.appendChild(a);

        assert(doc.toString == `<html><head></head><body><b></b><p><a></a></p><i></i></body></html>`);
    }

    unittest
    {
        Document doc = "<html>";
        auto e = doc.createElement("a");
        assert (doc == "<html><head></head><body></body></html>");

        assert(e.remove() == false);

        doc.body.appendChild(e);
        assert (doc == "<html><head></head><body><a></a></body></html>");

        assert(e.remove() == true);
        assert(doc == "<html><head></head><body></body></html>");

        assert(e.remove() == false);
        assert(doc == "<html><head></head><body></body></html>");

        assert(e == "<a></a>");
    }

    unittest
    {
        import std.exception : assertThrown;

        Document a = "<p>";
        Document b = "<i>";

        // Elements can't be moved between documents
        assertThrown!ParserinoException(a.body.appendChild(b.body.firstChild));

        // An element can't become a child of itself
        Element p = a.body.firstChild;
        assertThrown!ParserinoException(p.appendChild(a.body));
    }

    /// Replace this element with another one
    void replaceWith(E)(auto ref E el)
    {
        onlyValidElements();

        static if (is(E == Element)) assert(el != this);

        prependSibling(el);
        remove();
    }

    /// Copy another element here (attributes and, if deep, children)
    void copyFrom(E = Element)(auto ref E e, bool deep = true)
    {
        onlyRealElements();
        e.onlyRealElements();
        impl.finish();

        assert(e != this);

        while (element.first_attr !is null)
        {
            auto a = element.first_attr;
            size_t len;
            auto n = lxb_dom_attr_qualified_name(a, &len);
            lxb_dom_element_remove_attribute(element, n, len);
        }

        check(lxb_dom_element_interface_copy(element, e.element), "Can't copy the element");

        if (deep)
        {
            removeChildren();

            for (auto c = e.node.first_child; c !is null; c = c.next)
            {
                auto cl = lxb_dom_document_import_node(node.owner_document, c, true);
                if (cl is null) throw new ParserinoException("Can't clone the element");
                lxb_dom_node_insert_child(node, cl);
            }
        }
    }

    unittest
    {
        Document d = `<p id="hello"></p><a>`;

        auto p = d.byId("hello");
        auto a = d.byTagName("a").front;

        p.copyFrom(a);

        assert(p.attributes.empty);
    }

    unittest
    {
        Document doc = `<html><p class="p1"><b><p class="p2"><i>`;

        Element p1 = doc.byClass("p1").frontOrThrow;
        Element p1Copy = p1;

        Element p2 = doc.byClass("p2").frontOrThrow;
        Element b = p1.descendants.frontOrThrow;
        Element i = p2.descendants.frontOrThrow;

        i.replaceWith(b);
        assert(p1.descendants.empty == true);
        assert(p2.descendants.frontOrThrow.name == "b");
        assert(p2.descendants.frontOrThrow == b);

        p1.copyFrom(p2);
        assert(p1.classes.frontOrThrow == "p2");
        assert(p1Copy.classes.frontOrThrow == "p2");
        assert(p1.descendants.frontOrThrow.name == "b");
        assert(p1.descendants.frontOrThrow != b);
        assert(p2.descendants.frontOrThrow == b);
    }

    /// Set the html content of this element
    @property void innerHTML(const(char)[] html)
    {
        onlyRealElements();
        impl.finish();

        auto frag = lxb_html_document_parse_fragment(cast(lxb_html_document_t*) node.owner_document, element, cast(const(ubyte)*) html.ptr, html.length);
        if (frag is null) throw new ParserinoException("Can't parse the fragment");

        // Old children are detached (not destroyed): other `Element`s may still point to them.
        removeChildren();

        while (frag.first_child !is null)
        {
            auto c = frag.first_child;
            lxb_dom_node_remove(c);
            lxb_dom_node_insert_child(node, c);
        }
    }

    /// Get the html content of this element
    @property string innerHTML()
    {
        import std.array : appender;

        onlyRealElements();
        impl.ensureClosed(node);

        auto app = appender!string;
        serialize!lxb_html_serialize_deep_cb(node, (const(char)[] s) { app.put(s); });
        return app.data;
    }

    /// Get the text of this element (ignoring html tags)
    @property string innerText()
    {
        onlyValidElements();
        impl.ensureClosed(node);

        if (node.type == LXB_DOM_NODE_TYPE_TEXT || node.type == LXB_DOM_NODE_TYPE_COMMENT
            || node.type == LXB_DOM_NODE_TYPE_PROCESSING_INSTRUCTION)
        {
            auto cd = cast(lxb_dom_character_data_t*) node;
            return (cast(const(char)[]) cd.data.data[0 .. cd.data.length]).idup;
        }

        if (node.type != LXB_DOM_NODE_TYPE_ELEMENT && node.type != LXB_DOM_NODE_TYPE_DOCUMENT)
            return string.init;

        size_t len;
        auto s = lxb_dom_node_text_content(node, &len);
        if (s is null) return string.init;

        scope(exit) lxb_dom_document_destroy_text(node.owner_document, s);
        return (cast(const(char)[]) s[0 .. len]).idup;
    }

    /// Set the inner text of this element (replacing html)
    @property void innerText(const(char)[] text)
    {
        onlyValidElements();
        impl.finish();

        if (node.type != LXB_DOM_NODE_TYPE_ELEMENT)
        {
            check(lxb_dom_node_text_content_set(node, cast(const(ubyte)*) text.ptr, text.length), "Can't set the text");
            return;
        }

        removeChildren();

        if (text.length > 0)
        {
            auto t = lxb_dom_document_create_text_node(node.owner_document, cast(const(ubyte)*) text.ptr, text.length);
            if (t is null) throw new ParserinoException("Can't create text node");
            lxb_dom_node_insert_child(node, cast(lxb_dom_node_t*) t);
        }
    }

    ///
    unittest
    {
        import std.array;

        Document doc = Document("<html><p>");
        Element p = doc.byTagName("p").front;

        assert(p.descendants.empty);
        p.innerHTML = `<a href="uri">link</a>`;
        assert(p.descendants.front.name == "a");
        assert(p.byTagName("a").front.innerText == "link");

        p.byTagName("a").front.innerText = "hello";
        assert(p.byTagName("a").front.innerText == "hello");

        Element a = p.byTagName("a").front;
        p.innerText = "plain text";

        assert(p.descendants(true).front.name == "#text");
        assert(p.innerText == "plain text");
        assert(p.byTagName("a").empty);

        // The old child is detached, but still valid
        assert(a.parent == null);
        assert(a == `<a href="uri">hello</a>`);
    }

    /// Search for an element by id. It returns an invalid element (`== null`) if not found.
    Element byId(string id)
    {
        onlyRealOrDocument();
        return NodeRange!IdFilter(doc, node, true, false, IdFilter(id)).frontOrInit;
    }

    /++ Search for elements by class
    + See_also: `parserino.Document.byClass`
    +/
    auto byClass(string name)
    {
        onlyRealOrDocument();
        return NodeRange!ClassFilter(doc, node, true, false, ClassFilter(name));
    }

    /++ Search for elements by tag name ("#text" and "!--" select text and comment nodes)
    + See_also: `parserino.Document.byTagName`
    +/
    auto byTagName(string name)
    {
        onlyRealOrDocument();
        return NodeRange!TagFilter(doc, node, true, true, TagFilter(name));
    }

    /++ Search for elements by comment
    + ---
    + Document doc = "<div><!--hello--><p></p></div>";
    + Element e = doc.byComment("hello").front;
    + assert(e.next.name == "p");
    + ---
    + See_also: `parserino.Document.byComment`
    +/
    auto byComment(string comment, bool stripSpaces = true)
    {
        onlyRealOrDocument();
        return NodeRange!CommentFilter(doc, node, true, true, CommentFilter(comment, stripSpaces));
    }

    /++ Search for elements by css selector
    + See_also: `parserino.Document.bySelector`
    +/
    auto bySelector(const(char)[] selector) { return bySelector(Selector(selector)); }

    /// ditto
    auto bySelector(Selector selector)
    {
        onlyRealOrDocument();
        if (!selector.isValid) throw new ParserinoException("Invalid selector");
        return NodeRange!SelectorFilter(doc, node, true, false, SelectorFilter(selector));
    }

    /// Does this element match a css selector?
    bool matches(const(char)[] selector) { return matches(Selector(selector)); }

    /// ditto
    bool matches(Selector selector)
    {
        onlyValidElements();
        if (!selector.isValid) throw new ParserinoException("Invalid selector");
        if (node.type != LXB_DOM_NODE_TYPE_ELEMENT) return false;

        impl.ensureStable(node);
        if (selector.impl.forward && node.parent !is null) impl.ensureClosed(node.parent);
        return impl.matches(node, selector.impl.list);
    }

    ///
    unittest
    {
        Document doc = Document(
        `<html><body>
            <ul><li>one</li><li id="this">two</li></ul>
            <h4>title</h4>
            <ul><li>three</li><li>four</li><li>five</li></ul>
        `);

        import std.array;
        import std.algorithm : map, canFind;
        Element[] res = doc.bySelector("h4+ul li:nth-of-type(2), #this").array;

        assert(res.length == 2);

        auto elements = res.map!(x => x.innerText).array;
        assert(elements.canFind("two"));
        assert(elements.canFind("four"));

        assert(doc.byId("this").matches("li:last-child"));
        assert(!doc.byId("this").matches("li:first-child"));

        // A compiled selector can be reused
        auto sel = Selector("ul > li");
        assert(doc.bySelector(sel).walkLength == 5);
        assert(Document("<ul><li>").bySelector(sel).walkLength == 1);
    }

    unittest
    {
        import std.exception : assertThrown;

        Document doc = "<div><!--hello--><p></p></div>";
        Element e = doc.byComment("hello").front;
        assert(e.next.name == "p");
        assert(doc.byComment("hell").frontOrInit == null);

        assertThrown!ParserinoException(doc.bySelector("div >"));
        assertThrown!ParserinoException(doc.bySelector("a["));
    }

    unittest
    {
        Document doc = Document(`<html><body><p id="test"/><p id="another" class="hello world">this is a text`);

        {
            Element e = doc.byId("test");
            assert(e.isValid);
            assert(e.name == "p");
            assert(e.id == "test");
            assert(doc.byId("blah") == null);
        }

        import std.array;

        {
            Element[] res = doc.byClass("world").array;
            assert(res.length == 1);
            assert(res[0].id == "another");
            assert(res[0].name == "p");
        }

        {
            Element[] res = doc.byTagName("p").array;
            assert(res.length == 2);
            assert(res[0].id == "test");
            assert(res[1].id == "another");
        }
    }

    /// The next element in the document
    @property Element next(bool includeAllElements = false)
    {
        onlyValidElements();
        impl.ensureStable(node);

        if (node.parent is null) return Element.init;

        auto r = NodeRange!AnyFilter(doc, node.parent, false, includeAllElements, AnyFilter.init);
        r.start(node);
        return r.frontOrInit;
    }

    /// The previous element in the document
    @property Element prev(bool includeAllElements = false)
    {
        onlyValidElements();
        impl.ensureStable(node);

        auto el = node.prev;
        while (el !is null && !includeAllElements && el.type != LXB_DOM_NODE_TYPE_ELEMENT)
            el = el.prev;

        return Element(doc, el);
    }

    /// The parent element
    @property Element parent()
    {
        onlyValidElements();
        impl.ensureStable(node);
        return Element(doc, node.parent);
    }

    unittest
    {
        Document d = `<div><p></p><!--hmm--><i></i><!--ohh--></div>`;

        Element p = d.byTagName("p").front;
        Element i = d.byTagName("i").front;

        assert(i.prev == p);
        assert(p.next == i);
        assert(p.next(true).innerText == "hmm");
        assert(i.prev(true).innerText == "hmm");

        assert(i.next == null);
        assert(i.next(true).innerText == "ohh");
    }

    /// The first child
    @property Element firstChild(bool includeAllElements = false)
    {
        onlyValidElements();
        if (node.type != LXB_DOM_NODE_TYPE_ELEMENT && node.type != LXB_DOM_NODE_TYPE_DOCUMENT) return Element.init;
        return NodeRange!AnyFilter(doc, node, false, includeAllElements, AnyFilter.init).frontOrInit;
    }

    /// The last child
    @property Element lastChild(bool includeAllElements = false)
    {
        onlyValidElements();
        impl.ensureClosed(node);

        auto el = node.last_child;
        while (el !is null && !includeAllElements && el.type != LXB_DOM_NODE_TYPE_ELEMENT)
            el = el.prev;

        return Element(doc, el);
    }

    unittest
    {
        Document d = "<p><!--hello--><b></b>text</p>";

        assert(d.body.firstChild.firstChild == "<b></b>");
        assert(d.body.firstChild.lastChild == "<b></b>");
        assert(d.body.firstChild.firstChild(true) == "<!--hello-->");
        assert(d.body.firstChild.lastChild(true) == "text");
    }

    /// All the children contained in this element. (deep search)
    auto descendants(VisitOrder order = VisitOrder.Normal)(bool returnAllElements = false)
    {
        onlyRealOrDocument();
        return NodeRange!(AnyFilter, order)(doc, node, true, returnAllElements, AnyFilter.init);
    }

    /// All the children contained in this element. (non-deep search)
    auto children(VisitOrder order = VisitOrder.Normal)(bool returnAllElements = false)
    {
        onlyRealOrDocument();
        return NodeRange!(AnyFilter, order)(doc, node, false, returnAllElements, AnyFilter.init);
    }

    ///
    unittest
    {
        Document d = "<p><b>test</b>test2</p>";

        import std.array;
        Element[] c = d.body.firstChild.children(true).array;
        assert(c.length == 2);
        assert(c[0] == "<b>test</b>");
        assert(c[1] == "test2");
    }

    unittest
    {
        Document d = "<p><!--comment-->text";

        Element p = d.byTagName("p").frontOrThrow;

        assert(p.children.empty == true);
        assert(p.children(false).empty == true);
        assert(p.children(true).empty == false);
    }

    alias canFind = contains;

    /// Check if this element contains another one
    bool contains(E = Element)(auto ref E e, bool deep = true)
    {
        onlyRealElements();

        if (e == this) return false;

        Element tmp = e.parent;
        while (tmp != null)
        {
            if (tmp == this) return true;
            else if (!deep) return false;
            else tmp = tmp.parent;
        }

        return false;
    }

    /// Check if this element is the ancestor of another one
    bool isAncestorOf(E = Element)(auto ref E e) { return this.contains(e); }

    /// Check if this element is the descendant of another one
    bool isDescendantOf(E = Element)(auto ref E e) { return e.contains(this); }

    unittest
    {
        import std.exception : assertThrown;

        Document d = "<html><p><!--hey<b>--><a>hello</a>";
        Element p = d.byTagName("p").front;

        Element c = p.children(true).front;
        assert(c.innerText == "hey<b>");
        assertThrown(c.hasAttribute("hello") == false);
        assertThrown(c.children.empty);
        assertThrown(c.byTagName("b").empty);
        assert(c.name == "!--");
        assert(c.isComment);

        assert(p.contains(c));
        assert(p.canFind(c));

        assert(!d.head.canFind(c));
    }

    unittest
    {
        import std.array;
        Document doc = Document("<html><p><p><p><p>");
        assert(doc.body.descendants.array.length == 4);

        auto range = doc.body.descendants;
        auto original = range.save;

        range.popFront;

        auto saved = range.save;

        range.popFront;

        assert(range.array.length == 2);
        assert(saved.array.length == 3);
        assert(original.array.length == 4);

        assert(doc.body.descendants.array == doc.body.children.array);
    }

    unittest
    {
        import std.array;

        Document d = `<html><p><a><b>`;

        assert(d.body.children.array.length == 1);
        assert(d.body.descendants.array.length == 3);
        assert(d.body.children.front.toString == d.body.descendants.front.toString);
        assert(d.body.descendants.array[0].name == "p");
        assert(d.body.descendants.array[1].name == "a");

        auto b = d.byTagName("b").front;
        auto p = d.byTagName("p").front;
        assert(p.contains(b));
        assert(!p.contains(b, false));

        assert(p.isAncestorOf(b));
        assert(b.isDescendantOf(p));
        assert(!p.isDescendantOf(b));
        assert(!b.isAncestorOf(p));

        assert(!p.isDescendantOf(p));
        assert(!b.isAncestorOf(b));
    }

    unittest
    {
        import std.algorithm : map;
        import std.array;

        Document d =
            `<p>
                <b>
                    <i>
                    </i>
                    <a>
                    </a>
                </b>
            </p>
            <br>`;

        {
            string trip = d.body.descendants.map!(x => x.name).join("->");
            string tripReverse = d.body.descendants!(VisitOrder.Reverse).map!(x => x.name).join("->");

            assert(trip == "p->b->i->a->br");
            assert(tripReverse == "br->p->b->a->i");
        }

        {
            string trip = d.body.children.map!(x => x.name).join("->");
            string tripReverse = d.body.children!(VisitOrder.Reverse).map!(x => x.name).join("->");

            assert(trip == "p->br");
            assert(tripReverse == "br->p");
        }
    }

    /// The outer html of this element
    @property string outerHTML() { onlyValidElements(); return toString(); }

    /// Set the outer html of this element
    @property void outerHTML(const(char)[] html)
    {
        onlyValidElements();
        prependSibling(FragmentString(html.idup));
        remove();
    }

    ///
    unittest
    {
        Document d = "<html><a><p>";

        auto p = d.byTagName("p").front;
        p.outerHTML = "<div><a>";

        assert(p.name == "p");
        assert(d.body.descendants.front.name == "a");
    }

    /// Convert this element to a string
    string toString(bool deep = true) const
    {
        import std.array : appender;
        auto app = appender!string;
        toString((const(char)[] s) { app.put(s); }, deep);
        return app.data;
    }

    /// Write this element as html to a sink
    void toString(scope void delegate(const(char)[]) sink, bool deep = true) const
    {
        auto self = cast() this;
        self.onlyValidElements();

        if (deep)
        {
            self.impl.ensureClosed(self.node);
            serialize!lxb_html_serialize_tree_cb(self.node, sink);
        }
        else
        {
            self.impl.ensureStable(self.node);
            self.impl.ensureAttrs(self.node);
            serialize!lxb_html_serialize_cb(self.node, sink);
        }
    }

    /// ditto
    void toString(W)(ref W writer, bool deep = true) const
    if (isOutputRange!(W, const(char)[]) && !is(W : void delegate(const(char)[])))
    {
        import std.range.primitives : put;
        toString((const(char)[] s) { put(writer, s); }, deep);
    }

    /// Replace this element with the (single) element parsed from `html`
    ref Element opAssign(const(char)[] html) return
    {
        if (!isValid)
            throw new ParserinoException("Can't set html for a null element");

        Element fragment = doc.fragment(html);

        auto cld = fragment.children;
        Element first = cld.frontOrInit();

        if (first == null)
            throw new ParserinoException("Can't assign: invalid fragment");

        cld.popFront();

        if (!cld.empty)
            throw new ParserinoException("Can't assign a fragment with more than one child");

        copyFrom(first, true);
        return this;
    }

    ///
    ref Element opAssign(typeof(null)) return { this = Element.init; return this; }

    ///
    ref Element opAssign(Element rhs) return
    {
        doc = rhs.doc;
        node = rhs.node;
        return this;
    }

    ///
    string opCast(T : string)() const { return toString(); }

    unittest
    {
        import std.exception;
        Element e;
        assertThrown(e = `<a href="hmm.html>blah</a>`);
    }

    unittest
    {
        Document d = "<p>";
        Element e = d.byTagName("p").front;

        string se = cast(string)e;
        string de = cast(string)d;

        assert(se == "<p></p>");
        assert(de == "<html><head></head><body><p></p></body></html>");
    }

    unittest
    {
        import std.exception : assertThrown;

        Document d = "<p><a><b>";
        assert(d == "<html><head></head><body><p><a><b></b></a></p></body></html>");

        Element e = d.byTagName("b").front;
        e = "<i><span>";

        assert(e == "<i><span></span></i>");
        assert(d.body == "<body><p><a><i><span></span></i></a></p></body>");
        assertThrown(e = "<i></i><b></b>");
        assertThrown(e = "");

        e.outerHTML = "<b></b>";
        assert(e == "<i><span></span></i>");
        assert(d.body == "<body><p><a><b></b></a></p></body>");
    }

    private:

    Document doc;
    lxb_dom_node_t* node;

    this(ref Document doc, lxb_dom_node_t* node)
    {
        if (node is null) return;
        this.doc = doc;
        this.node = node;
    }

    inout(DocImpl)* impl() inout { return doc.impl; }
    lxb_dom_element_t* element() { return cast(lxb_dom_element_t*) node; }

    void onlyValidElements(string fname = __FUNCTION__) const
    {
        if (node is null)
            throw new ParserinoException("Can't call `" ~ fname ~ "` for an invalid/uninitialized node");
    }

    void onlyRealElements(string fname = __FUNCTION__)
    {
        onlyValidElements(fname);

        if (node.type != LXB_DOM_NODE_TYPE_ELEMENT)
            throw new ParserinoException("Can't call `" ~ fname ~ "` for a node with type " ~ name());
    }

    void onlyRealOrDocument(string fname = __FUNCTION__)
    {
        onlyValidElements(fname);
        if (node.type != LXB_DOM_NODE_TYPE_DOCUMENT) onlyRealElements(fname);
    }

    void removeChildren()
    {
        while (node.first_child !is null)
            lxb_dom_node_remove(node.first_child);
    }

    // The nodes to insert for an Element, a text or a fragment.
    lxb_dom_node_t*[] nodesToInsert(E)(auto ref E el)
    {
        static if (is(E == FragmentString))
        {
            Element root = doc.fragment(el.fragment);
            lxb_dom_node_t*[] nodes;
            for (auto c = root.node.first_child; c !is null; c = c.next) nodes ~= c;
            foreach (n; nodes) lxb_dom_node_remove(n);
            return nodes;
        }
        else static if (isSomeString!E)
        {
            return [doc.createText(el).node];
        }
        else static if (is(E == Element))
        {
            el.onlyValidElements();
            if (el.node.owner_document !is node.owner_document)
                throw new ParserinoException("Can't insert an element from another document (use `dup` on a fragment of this document)");

            for (auto p = node; p !is null; p = p.parent)
                if (p is el.node) throw new ParserinoException("Can't insert an element inside itself");

            if (el.node.parent !is null) lxb_dom_node_remove(el.node);
            return [el.node];
        }
        else static assert(0, "Can't insert a " ~ E.stringof);
    }
}


/// A range of attributes. It keeps the document alive.
struct AttributeRange
{
    ///
    @property bool empty() const @safe nothrow pure @nogc { return current is null; }

    ///
    @property Element.Attribute front()
    {
        size_t len;
        auto n = lxb_dom_attr_qualified_name(current, &len);
        return Element.Attribute((cast(const(char)[]) n[0 .. len]).idup, attrValue(current).idup);
    }

    ///
    void popFront() { current = current.next; }

    ///
    @property AttributeRange save() { return this; }

    private:
    Document doc;
    lxb_dom_attr_t* current;
}


/++ A compiled css selector. It can be used with any document, many times.
+ ---
+ auto sel = Selector("div > a[href]");
+ foreach (doc; documents)
+    foreach (link; doc.bySelector(sel)) { ... }
+ ---
+/
struct Selector
{
    /// Compile a selector. It throws on invalid syntax.
    this(const(char)[] selector)
    {
        impl = cast(SelImpl*) calloc(1, SelImpl.sizeof);
        if (impl is null) throw new ParserinoException("Out of memory");

        impl.list = parseSelector(selector, impl.arena);
        if (impl.list is null)
        {
            impl.arena.release();
            free(impl);
            impl = null;
            throw new ParserinoException("Invalid selector: `" ~ selector.idup ~ "`");
        }

        impl.refs = 1;
        impl.forward = impl.list.looksForward;
    }

    this(this) { if (impl !is null) atomicOp!"+="(impl.refs, 1); }

    ~this()
    {
        if (impl !is null && atomicOp!"-="(impl.refs, 1) == 0)
        {
            impl.arena.release();
            free(impl);
        }
        impl = null;
    }

    ///
    ref Selector opAssign(Selector rhs) return
    {
        auto tmp = impl;
        impl = rhs.impl;
        rhs.impl = tmp;
        return this;
    }

    /// Is this a valid (compiled) selector?
    @property bool isValid() const @safe nothrow pure @nogc { return impl !is null; }

    unittest
    {
        import std.exception : assertThrown;

        assert(Selector("div p").isValid);
        assert(!Selector.init.isValid);
        assertThrown!ParserinoException(Selector("1bad"));
        assertThrown!ParserinoException(Selector(""));
    }

    private:
    SelImpl* impl;
}

import std.range.primitives : walkLength;

/// Get the first element of a range or throw an exception
auto frontOrThrow(T)(T range)
if (isInputRange!T)
{
    if (range.empty) throw new ParserinoException("Range is empty.");
    else return range.front;
}

/// Get the first element of a range or return the second args
auto frontOr(T, El)(T range, El fallback)
if (isInputRange!T && is(El == ElementType!T))
{
    if (range.empty) return fallback;
    else return range.front;
}

/// Get the first element of a range or return Element.init
auto frontOrInit(T)(T range)
if (isInputRange!T)
{
    if (range.empty) return (ElementType!T).init;
    else return range.front;
}

///
unittest
{
    import std.exception : assertThrown;

    Document doc = Document(`<html><p><b>hello`);
    Element div = doc.createElement("div");
    div.setAttribute("id", "test");

    assert(doc.bySelector("p b").frontOrThrow.name == "b");
    assert(doc.bySelector("p b").frontOrInit.name == "b");

    assertThrown(doc.bySelector("p i").frontOrThrow);
    assert(doc.bySelector("p i").frontOrInit == Element());
    assert(doc.bySelector("p i").frontOrInit == null);
    assert(doc.bySelector("p i").frontOr(div).name == "div");
    assert(doc.bySelector("p i").frontOr(div).id == "test");
}

private struct FragmentString
{
    string fragment;
    alias fragment this;
}

/++ Create a fragment from a string. The fragment is not attached to any document by default.
+ The fragment is not a valid element or document, it's just a piece of html you can add to a document.
+ ---
+ auto fragment = "<b>hello</b>".asFragment;
+ doc.body.appendChild(fragment);
+ ---
+/
auto asFragment(string s)
{
    return FragmentString(s);
}


/++ A lazy range of nodes in tree order (or in reverse tree order).
+ It is returned by `descendants`, `children`, `byTagName`, `byClass`, `bySelector`, ...
+ It is a forward range: `save` gives an independent copy.
+/
struct NodeRange(Filter, VisitOrder order = VisitOrder.Normal)
{
    ///
    @property bool empty() { prime(); return current is null; }

    ///
    @property Element front()
    {
        prime();
        if (current is null) throw new ParserinoException("Range is empty.");
        return Element(doc, current);
    }

    ///
    void popFront() { prime(); current = seek(current); }

    ///
    @property typeof(this) save() { return this; }

    private:

    Document doc;
    lxb_dom_node_t* root;
    lxb_dom_node_t* current;
    bool deep;
    bool all;
    bool primed;
    Filter filter;

    this(ref Document doc, lxb_dom_node_t* root, bool deep, bool all, Filter filter)
    {
        this.doc = doc;
        this.root = root;
        this.deep = deep;
        this.all = all;
        this.filter = filter;
    }

    // Start the visit after `from` instead of from the beginning.
    void start(lxb_dom_node_t* from) { primed = true; current = seek(from); }

    void prime()
    {
        if (primed) return;
        primed = true;

        static if (order == VisitOrder.Reverse) doc.impl.ensureClosed(root);
        current = seek(root);
    }

    // The next node after `pos` accepted by the filter.
    lxb_dom_node_t* seek(lxb_dom_node_t* pos)
    {
        auto d = doc.impl;

        while (true)
        {
            static if (order == VisitOrder.Normal) auto next = stepForward(d, pos);
            else auto next = stepBackward(pos);

            if (next is waitSentinel) { d.advance(); continue; }
            if (next is null) return null;

            static if (order == VisitOrder.Normal)
                if (d.parsing && !passable(d, next)) { d.advance(); continue; }

            pos = next;

            if ((all || next.type == LXB_DOM_NODE_TYPE_ELEMENT) && filter.match(d, next))
                return next;
        }
    }

    // The next node in tree order. It returns `waitSentinel` if the parser could still add it.
    lxb_dom_node_t* stepForward(DocImpl* d, lxb_dom_node_t* pos)
    {
        if (deep || pos is root)
        {
            if (pos.first_child !is null) return pos.first_child;
            if (d.parsing && d.isOpen(pos)) return waitSentinel;
            if (pos is root) return null;
        }

        while (true)
        {
            if (pos.next !is null) return pos.next;

            auto p = pos.parent;
            if (p is null) return null; // node removed while browsing
            if (d.parsing && d.isOpen(p)) return waitSentinel;
            if (p is root || !deep) return null;
            pos = p;
        }
    }

    lxb_dom_node_t* stepBackward(lxb_dom_node_t* pos)
    {
        if ((deep || pos is root) && pos.last_child !is null) return pos.last_child;
        if (pos is root) return null;

        while (true)
        {
            if (pos.prev !is null) return pos.prev;

            pos = pos.parent;
            if (pos is null || pos is root || !deep) return null;
        }
    }

    // Can the walker go past this node, or could the parser still change it?
    bool passable(DocImpl* d, lxb_dom_node_t* n)
    {
        if (!d.isStable(n)) return false;

        // Selectors like :last-child or :has() need all the siblings
        if (filter.strict && n.parent !is null && d.isOpen(n.parent)) return false;

        // A later <html> or <body> tag can still add attributes to these elements
        if (isRootElement(n) && (Filter.attrSensitive || filter.match(d, n)) && !d.rootAttrsFinal()) return false;

        return true;
    }
}


private:

// ---------------------------------------------------------------- filters

struct AnyFilter
{
    enum attrSensitive = true;
    enum strict = false;
    bool match(DocImpl*, lxb_dom_node_t*) { return true; }
}

struct TagFilter
{
    enum attrSensitive = false;
    enum strict = false;

    string name;
    lxb_tag_id_t id = LXB_TAG__UNDEF;
    size_t generation = size_t.max;

    bool match(DocImpl* d, lxb_dom_node_t* n)
    {
        // Unknown tags get an id when the parser meets them: retry after each parsed chunk
        if (id == LXB_TAG__UNDEF && generation != d.generation)
        {
            id = lxb_tag_id_by_name(d.html.dom_document.tags, cast(const(ubyte)*) name.ptr, name.length);
            generation = d.generation;
        }

        return id != LXB_TAG__UNDEF && n.local_name == id;
    }
}

struct ClassFilter
{
    enum attrSensitive = true;
    enum strict = false;

    string name;

    bool match(DocImpl*, lxb_dom_node_t* n)
    {
        auto a = (cast(lxb_dom_element_t*) n).attr_class;
        if (a is null || name.length == 0) return false;

        auto v = attrValue(a);
        size_t i = 0;
        while (i < v.length)
        {
            while (i < v.length && isHtmlSpace(v[i])) i++;
            size_t s = i;
            while (i < v.length && !isHtmlSpace(v[i])) i++;
            if (v[s .. i] == name) return true;
        }

        return false;
    }
}

struct IdFilter
{
    enum attrSensitive = true;
    enum strict = false;

    string id;

    bool match(DocImpl*, lxb_dom_node_t* n)
    {
        auto a = (cast(lxb_dom_element_t*) n).attr_id;
        return a !is null && attrValue(a) == id;
    }
}

struct CommentFilter
{
    enum attrSensitive = false;
    enum strict = false;

    string comment;
    bool stripSpaces;

    this(string comment, bool stripSpaces)
    {
        import std.string : strip;
        this.comment = stripSpaces ? comment.strip : comment;
        this.stripSpaces = stripSpaces;
    }

    bool match(DocImpl*, lxb_dom_node_t* n)
    {
        import std.string : strip;

        if (n.type != LXB_DOM_NODE_TYPE_COMMENT) return false;

        auto cd = cast(lxb_dom_character_data_t*) n;
        auto text = cast(const(char)[]) cd.data.data[0 .. cd.data.length];
        return (stripSpaces ? text.strip : text) == comment;
    }
}

struct SelectorFilter
{
    enum attrSensitive = true;

    Selector selector;

    @property bool strict() const { return selector.impl.forward; }

    bool match(DocImpl* d, lxb_dom_node_t* n) { return d.matches(n, selector.impl.list); }
}


// ---------------------------------------------------------------- document state

__gshared lxb_dom_node_t waitSentinelNode;
@property lxb_dom_node_t* waitSentinel() @trusted nothrow @nogc { return &waitSentinelNode; }

struct DocImpl
{
    shared size_t refs;
    lxb_html_document_t* html;

    // Incremental parsing
    bool parsing;
    ubyte* source;          // private copy of the input (freed when the parsing ends)
    size_t sourceLength;
    size_t fed;             // bytes given to the parser
    size_t chunkSize;
    size_t generation;      // incremented at each chunk
    size_t rootTagsEnd = size_t.max;

    // Nodes the parser can still change (recomputed at each chunk)
    size_t volatileGeneration = size_t.max;
    NodeList tables;        // open tables: foster parenting inserts before them
    NodeList formatting;    // open formatting elements: the adoption agency moves their descendants

    static DocImpl* create()
    {
        auto d = cast(DocImpl*) calloc(1, DocImpl.sizeof);
        if (d is null) throw new ParserinoException("Out of memory");
        *d = DocImpl.init;
        d.refs = 1;

        d.html = lxb_html_document_create();
        if (d.html is null) { free(d); throw new ParserinoException("Can't create the document"); }
        return d;
    }

    void retain() { atomicOp!"+="(refs, 1); }

    static void release(DocImpl* d)
    {
        if (atomicOp!"-="(d.refs, 1) != 0) return;

        if (d.source !is null) free(d.source);
        lxb_html_document_destroy(d.html);
        d.tables.dispose();
        d.formatting.dispose();
        free(d);
    }

    void parseAll(const(char)[] input)
    {
        fed = input.length;
        check(lxb_html_document_parse(html, cast(const(ubyte)*) input.ptr, input.length), "Can't parse the document");
    }

    void beginLazy(const(char)[] input, size_t chunk)
    {
        check(lxb_html_document_parse_chunk_begin(html), "Can't parse the document");

        source = cast(ubyte*) malloc(input.length + 1);
        if (source is null) throw new ParserinoException("Out of memory");
        memcpy(source, input.ptr, input.length);

        sourceLength = input.length;
        chunkSize = chunk;
        parsing = true;
    }

    // Parse one more chunk. It returns false if the parsing is already complete.
    bool advance()
    {
        if (!parsing) return false;

        import std.algorithm : min;
        auto n = min(chunkSize, sourceLength - fed);
        if (n > 0)
        {
            auto status = lxb_html_document_parse_chunk(html, source + fed, n);
            fed += n;
            generation++;
            if (status != LXB_STATUS_OK) { endParsing(); throw new ParserinoException("Can't parse the document"); }
        }

        if (fed == sourceLength) finish();
        return true;
    }

    // Complete the parsing
    void finish()
    {
        if (!parsing) return;

        lxb_status_t status = LXB_STATUS_OK;
        if (fed < sourceLength) status = lxb_html_document_parse_chunk(html, source + fed, sourceLength - fed);
        fed = sourceLength;

        auto endStatus = endParsing();
        if (status == LXB_STATUS_OK) status = endStatus;
        if (status != LXB_STATUS_OK) throw new ParserinoException("Can't parse the document");
    }

    lxb_status_t endParsing()
    {
        auto status = lxb_html_document_parse_chunk_end(html);
        parsing = false;
        generation++;
        free(source);
        source = null;
        tables.clear();
        formatting.clear();
        return status;
    }

    lxb_html_tree_t* tree() { return (cast(lxb_html_parser_t*) html.dom_document.parser).tree; }

    // Is the node still open (the parser can add children to it)?
    bool isOpen(const(lxb_dom_node_t)* n)
    {
        if (!parsing) return false;
        if (n.type == LXB_DOM_NODE_TYPE_DOCUMENT) return n is &html.dom_document.node;
        if (n.type != LXB_DOM_NODE_TYPE_ELEMENT) return false;

        // In the "after head" insertion mode the parser puts <head> back on the stack
        // for <script>, <style>, <meta>, ...: it can get children until <body> exists.
        if (n is cast(lxb_dom_node_t*) html.head && html.body is null) return true;

        auto oe = tree.open_elements;
        foreach_reverse (i; 0 .. oe.length)
            if (oe.list[i] is n) return true;

        return false;
    }

    void refreshVolatile()
    {
        if (volatileGeneration == generation) return;
        volatileGeneration = generation;

        tables.clear();
        formatting.clear();

        auto t = tree;
        auto oe = t.open_elements;
        auto af = t.active_formatting;

        foreach (i; 0 .. oe.length)
        {
            auto n = cast(lxb_dom_node_t*) oe.list[i];

            if (n.ns == LXB_NS_HTML && n.local_name == LXB_TAG_TABLE) tables.add(n);
            else
            {
                foreach (j; 0 .. af.length)
                    if (af.list[j] is n) { formatting.add(n); break; }
            }
        }
    }

    /+ Is the node in its final position?
     + - foster parenting inserts content before the open tables
     + - the adoption agency moves the descendants of the open formatting elements
     + - a <frameset> can still replace <body> while `frameset_ok` is set
     + - the last text node can still grow
     +/
    bool isStable(lxb_dom_node_t* n)
    {
        if (!parsing) return true;

        refreshVolatile();

        auto body = cast(lxb_dom_node_t*) html.body;
        bool framesetOk = tree.frameset_ok && body !is null;

        if (tables.length || formatting.length || framesetOk)
        {
            for (auto a = n; a !is null; a = a.parent)
            {
                if (tables.contains(a)) return false;
                if (a !is n && formatting.contains(a)) return false;
                if (framesetOk && a is body) return false;
            }
        }

        if (n.type == LXB_DOM_NODE_TYPE_TEXT)
        {
            if (n.next is null) return n.parent is null || !isOpen(n.parent);
            if (tables.contains(n.next)) return false;
        }

        return true;
    }

    // Are the attributes of <html> and <body> final?
    bool rootAttrsFinal()
    {
        if (!parsing) return true;
        if (rootTagsEnd == size_t.max) rootTagsEnd = scanRootTags(source[0 .. sourceLength]);
        return fed >= rootTagsEnd;
    }

    void ensureStable(lxb_dom_node_t* n) { while (parsing && !isStable(n)) advance(); }
    void ensureClosed(lxb_dom_node_t* n) { while (parsing && (isOpen(n) || !isStable(n))) advance(); }
    void ensureAttrs(lxb_dom_node_t* n) { if (isRootElement(n)) while (parsing && !rootAttrsFinal()) advance(); }

    bool matches(lxb_dom_node_t* n, const(SelectorList)* list)
    {
        return parserino.css.matcher.matches(list, n);
    }
}

// A small malloc'd list of nodes
struct NodeList
{
    lxb_dom_node_t** ptr;
    size_t length;
    size_t capacity;

    void add(lxb_dom_node_t* n)
    {
        if (length == capacity)
        {
            auto c = capacity == 0 ? 8 : capacity * 2;
            auto p = cast(lxb_dom_node_t**) realloc(ptr, c * (lxb_dom_node_t*).sizeof);
            if (p is null) throw new ParserinoException("Out of memory");
            ptr = p;
            capacity = c;
        }

        ptr[length++] = n;
    }

    bool contains(const(lxb_dom_node_t)* n) const nothrow @nogc
    {
        foreach (i; 0 .. length) if (ptr[i] is n) return true;
        return false;
    }

    void clear() nothrow @nogc { length = 0; }
    void dispose() nothrow @nogc { free(ptr); ptr = null; length = capacity = 0; }
}

bool isRootElement(const(lxb_dom_node_t)* n) nothrow @nogc
{
    return n.type == LXB_DOM_NODE_TYPE_ELEMENT && n.ns == LXB_NS_HTML
        && (n.local_name == LXB_TAG_HTML || n.local_name == LXB_TAG_BODY);
}

bool isHtmlSpace(char c) nothrow @nogc pure { return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\f'; }

/+ The end offset of the last <html ...> or <body ...> start tag in the input (0 if none).
 + These tags can add attributes to the existing <html>/<body> elements at any time.
 + The tag end follows the tokenizer rules for attributes, so quotes are handled correctly.
 + Occurrences inside comments or scripts are false positives: they only make parsing less lazy.
 +/
size_t scanRootTags(const(ubyte)[] s) nothrow @nogc
{
    size_t result = 0;
    size_t i = 0;

    while (i < s.length)
    {
        auto p = cast(const(ubyte)*) memchr(s.ptr + i, '<', s.length - i);
        if (p is null) break;

        i = p - s.ptr + 1;
        if (i + 4 >= s.length) break;

        ubyte[4] name = [s[i] | 0x20, s[i + 1] | 0x20, s[i + 2] | 0x20, s[i + 3] | 0x20];
        if (name != cast(ubyte[4]) "html" && name != cast(ubyte[4]) "body") continue;

        auto c = s[i + 4];
        if (!isHtmlSpace(c) && c != '/' && c != '>') continue;

        auto e = startTagEnd(s, i + 4);
        if (e == size_t.max) return size_t.max - 1; // unterminated: final only at the end
        if (e > result) result = e;
    }

    return result;
}

// Offset after the '>' closing a start tag, beginning at the end of the tag name.
size_t startTagEnd(const(ubyte)[] s, size_t i) nothrow @nogc
{
    enum S { beforeName, name, afterName, beforeValue, dq, sq, unquoted, afterQuoted, selfClosing }
    S st = S.beforeName;

    // The tag name state: whitespace, '/' or '>' ends it
    if (s[i] == '>') return i + 1;
    if (s[i] == '/') st = S.selfClosing;
    i++;

    for (; i < s.length; i++)
    {
        char c = s[i];
        bool ws = isHtmlSpace(c);

        final switch (st)
        {
            case S.beforeName:
                if (ws) break;
                if (c == '/' || c == '>') { st = S.afterName; i--; break; }
                st = S.name;
                break;

            case S.name:
                if (ws || c == '/' || c == '>') { st = S.afterName; i--; break; }
                if (c == '=') st = S.beforeValue;
                break;

            case S.afterName:
                if (ws) break;
                if (c == '/') { st = S.selfClosing; break; }
                if (c == '=') { st = S.beforeValue; break; }
                if (c == '>') return i + 1;
                st = S.name;
                break;

            case S.beforeValue:
                if (ws) break;
                if (c == '"') { st = S.dq; break; }
                if (c == '\'') { st = S.sq; break; }
                if (c == '>') return i + 1;
                st = S.unquoted;
                break;

            case S.dq:
                if (c == '"') st = S.afterQuoted;
                break;

            case S.sq:
                if (c == '\'') st = S.afterQuoted;
                break;

            case S.unquoted:
                if (ws) { st = S.beforeName; break; }
                if (c == '>') return i + 1;
                break;

            case S.afterQuoted:
                if (ws) { st = S.beforeName; break; }
                if (c == '/') { st = S.selfClosing; break; }
                if (c == '>') return i + 1;
                st = S.beforeName; i--;
                break;

            case S.selfClosing:
                if (c == '>') return i + 1;
                st = S.beforeName; i--;
                break;
        }
    }

    return size_t.max;
}

unittest
{
    auto t(string s) { return scanRootTags(cast(const(ubyte)[]) s); }

    assert(t("<p>hello</p>") == 0);
    assert(t("<html>") == 6);
    assert(t("<HTML lang=en><body class='a>b'>x") == 32);
    assert(t(`<body a"=">"x>tail`) == 14);
    assert(t("<bodyx><htmlx>") == 0);
    assert(t("<body a=b") == size_t.max - 1);
    assert(t("<p><body/>") == 10);
}


// ---------------------------------------------------------------- selectors

struct SelImpl
{
    shared size_t refs;
    Arena arena;
    const(SelectorList)* list;
    bool forward;   // does it look at following siblings or at children? (:last-child, :has, ...)
}


// ---------------------------------------------------------------- helpers

const(char)[] attrValue(lxb_dom_attr_t* a) nothrow @nogc
{
    if (a.value is null || a.value.data is null) return "";
    return cast(const(char)[]) a.value.data[0 .. a.value.length];
}

void check(lxb_status_t status, string msg)
{
    if (status != LXB_STATUS_OK) throw new ParserinoException(msg);
}

struct SinkContext
{
    void delegate(const(char)[]) sink;
    Exception error;
}

extern(C) lxb_status_t sinkTrampoline(const(lxb_char_t)* data, size_t len, void* ctx) nothrow
{
    auto c = cast(SinkContext*) ctx;

    try c.sink(cast(const(char)[]) data[0 .. len]);
    catch (Exception e) { c.error = e; return LXB_STATUS_ERROR; }

    return LXB_STATUS_OK;
}

// Serialize a node to a sink. Exceptions thrown by the sink are rethrown here.
void serialize(alias fn)(lxb_dom_node_t* node, scope void delegate(const(char)[]) sink)
{
    SinkContext ctx;
    ctx.sink = sink;

    auto status = fn(node, cast(lxb_html_serialize_cb_f) &sinkTrampoline, &ctx);
    if (ctx.error !is null) throw ctx.error;
    if (status != LXB_STATUS_OK) throw new ParserinoException("Serialization failed");
}
