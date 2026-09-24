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


/++ HTML5 parser and DOM manipulation library.
 +
 + Parserino is a fast html5 parser and DOM manipulation library written in pure D
 + (the tree construction is derived from the lexbor library).
 + ---
 + import parserino;
 + void main()
 + {
 +    auto doc = Document("<html><body><p>Hello World!</p></body></html>");
 +    assert(doc.body.firstChild.textContent == "Hello World!");
 +    assert(doc.byTagName("p").front.textContent == "Hello World!");
 + }
 + ---
 + The main types are `Document`, `Node` and `Element`:
 + - a `Node` is any node of the tree: an element, a text, a comment, a doctype, ...;
 + - an `Element` is a node that is an element: it adds attributes, `innerHTML`, `matches`, ...
 +   It converts implicitly to `Node`; `node.asElement` goes the other way.
 +
 + Navigation: one method for each direction, with the kinds of nodes to see as a template
 + parameter (`Show`, as `whatToShow` in the DOM). The default is `Show.Element`, and then the
 + result is an `Element` (or a range of `Element`); with other filters it's a `Node`.
 + ---
 + p.children                           // the child elements
 + p.children!(Show.All)                // all the child nodes
 + doc.descendants!(Show.Comment)       // all the comments of the document
 + p.firstChild!(Show.Text)             // the first child text node
 + doc.body.descendants.retro           // reverse document order
 + ---
 +
 + Errors: searches and navigation give an invalid node (`== null`, `isValid` is false) or an
 + empty range when nothing is found; a node that can't have children (a text, a comment) just
 + has no children. Calling a method on an invalid node or document, or a mutation that is not
 + possible (a child of a text, a node inside itself, a node of another document, a sibling of a
 + node without parent), throws a `ParserinoException`.
 +
 + Views: the getters that copy a string stored in the document have a `...View` variant that
 + returns a slice of the document memory instead (`localNameView`, `idView`, `getAttributeView`,
 + `classesView`, `attributesView`, `dataView`). The slice is valid until that value changes or
 + the document is destroyed. Computed values (`textContent` of an element, `innerHTML`, `title`)
 + have no view.
 +
 + Memory: a `Document` is reference counted. Every `Node` keeps its document alive, so nodes are
 + always safe to use, even after the `Document` variable goes out of scope. Nodes removed from
 + the tree stay valid (they are released with their document).
 +
 + Lazy parsing: `Document(html, Parsing.Lazy)` builds the tree only as far as your queries need.
 + `doc.byClass("x").take(3)` stops parsing a little after the third match.
 +
 + Input: the html must be UTF-8 (invalid bytes become U+FFFD, a BOM is removed). For other
 + encodings see `parserino.encoding.toUtf8`.
 +/
module parserino;

import parserino.names : Tag, Ns;
import parserino.dom : textContent, DomNode, DomElement, DomAttribute, DomDocument, DomCharacterData,
    DomDocumentFragment, DomDocumentType;
import parserino.html.parser : Parser, newParser, freeParser, parseDocument, parseFragment;
import parserino.html.treebuilder : TreeBuilder;
static import parserino.html.serializer;
import parserino.html.serializer : Serialize;
import parserino.arena : Arena;
import parserino.snapshot : DomSnapshot, takeSnapshot, parseToSnapshot;
import parserino.css.selector : SelectorList, parseSelector;
static import parserino.css.matcher;

public import parserino.dom : NodeType;
public import parserino.html.errors : ParseErrorCode;
import parserino.html.errors : RawParseError, errorName;
import parserino.arena : Buffer;

import core.stdc.stdlib : calloc, realloc, free, malloc;
import core.stdc.string : memchr, memcpy;
import core.atomic : atomicOp;
import std.range.primitives : isInputRange, isOutputRange, ElementType;
import std.traits : isSomeString;

/++ The kinds of nodes that a navigation or a range gives: the same bits of `NodeFilter.whatToShow`
 + in the DOM. Combine them with `|`: `children!(Show.Text | Show.Comment)`.
 +/
enum Show : uint
{
    Element = 0x1,                  /// elements
    Text = 0x4,                     /// text nodes
    CDataSection = 0x8,             /// CDATA sections
    ProcessingInstruction = 0x40,   /// processing instructions (`<?target data>`)
    Comment = 0x80,                 /// comments
    Document = 0x100,               /// the document
    DocumentType = 0x200,           /// the doctype
    DocumentFragment = 0x400,       /// document fragments
    All = 0xFFFF_FFFF,              /// all the nodes
}

/// Thrown on invalid operations (invalid node, impossible mutation, bad selector, ...)
class ParserinoException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow @safe { super(msg, file, line); }
}

/// How `Document` parses its input
enum Parsing
{
    Eager,  /// Parse everything at once
    Lazy,   /// Parse chunk by chunk, only as far as queries and accessors need
}

/// Default chunk size for `Parsing.Lazy`
enum size_t DefaultChunkSize = 16 * 1024;

/// Options of the parser (see `Document.this`)
struct ParseOptions
{
    Parsing parsing = Parsing.Eager;        /// eager or lazy parsing
    size_t chunkSize = DefaultChunkSize;    /// the chunk size of lazy parsing

    /++ Parse as a browser with scripting enabled: the content of `<noscript>` is text.
     + Off by default, so the content of `<noscript>` is parsed as html (useful for scraping).
     +/
    bool scripting = false;

    /++ Collect the parse errors (see `Document.parseErrors`). Off by default: then they cost nothing.
     + With `ctDocument` the parse errors become compile errors.
     +/
    bool collectErrors = false;
}

/++ A parse error: the html is not valid (the parser recovers anyway, as a browser does).
+ The codes of the tokenizer are the ones of the HTML standard; the standard doesn't name the
+ errors of the tree construction, so they have codes in the same style (`misnested-tag`, ...).
+/
struct ParseError
{
    ParseErrorCode code;    /// the error
    size_t line;            /// 1-based
    size_t column;          /// 1-based, in characters

    /// The name of the error: `"unexpected-null-character"`, `"missing-doctype"`, ...
    @property string name() const @safe nothrow pure @nogc { return errorName(code); }

    /// `"line:column: name"`
    string toString() const @safe pure
    {
        import std.conv : to;
        return line.to!string ~ ":" ~ column.to!string ~ ": " ~ name;
    }
}

/// The HTML5 Document
struct Document
{
    /++ Parse a document.
    + With `Parsing.Lazy` the tree is built chunk by chunk (`chunkSize` bytes), only when a query
    + or an accessor needs more of it. The results are always the same as for a fully parsed document.
    + ---
    + auto doc = Document(hugeHtml, Parsing.Lazy);
    + auto links = doc.byTagName("a").take(3).array;   // parses only the beginning of the document
    + assert(doc.bytesParsed < hugeHtml.length);
    + ---
    + Any mutation of a lazy document (or of one of its nodes) completes the parsing first.
    + To parse at compile time, see `ctDocument`.
    +/
    this(const(char)[] html, Parsing parsing = Parsing.Eager, size_t chunkSize = DefaultChunkSize)
    {
        ParseOptions options;
        options.parsing = parsing;
        options.chunkSize = chunkSize;
        this(html, options);
    }

    /// ditto
    this(const(char)[] html, ParseOptions options)
    {
        impl = DocImpl.create();
        scope(failure) { DocImpl.release(impl); impl = null; }

        impl.dom.scripting = options.scripting;
        impl.collectErrors = options.collectErrors;
        if (options.parsing == Parsing.Lazy)
            impl.beginLazy(html, options.chunkSize == 0 ? DefaultChunkSize : options.chunkSize);
        else impl.parseAll(html);
    }

    ///
    unittest
    {
        import std.range : take;
        import std.array : array, replicate;

        string html = "<html><body>" ~ `<p class="x">hello</p>`.replicate(10_000);

        auto doc = Document(html, Parsing.Lazy, 1024);
        assert(doc.isParsing);

        auto found = doc.byClass("x").take(3).array;
        assert(found.length == 3);
        assert(found[0].textContent == "hello");

        // Only a small part of the input was parsed
        assert(doc.bytesParsed < 4096);

        doc.finishParsing();
        assert(!doc.isParsing);
        assert(doc.bytesParsed == html.length);
        assert(doc.byClass("x").walkLength == 10_000);
    }

    ///
    unittest
    {
        // With scripting, <noscript> is text (as in a browser); by default it's parsed as html
        string html = "<body><noscript><p>enable js</p></noscript>";

        assert(Document(html).byTagName("p").walkLength == 1);

        ParseOptions options = { scripting: true };
        auto scripted = Document(html, options);
        assert(scripted.byTagName("p").empty);
        assert(scripted.byTagName("noscript").front.textContent == "<p>enable js</p>");
    }

    unittest
    {
        import std.range : take;
        import std.array : array, replicate;

        // A mutation in the middle of a lazy query completes the parsing: the range goes on
        string html = "<body>" ~ `<div class="x"><b>a</b></div>`.replicate(2000);
        auto doc = Document(html, Parsing.Lazy, 256);

        auto r = doc.byClass("x");
        r.front.setAttribute("id", "first");
        assert(!doc.isParsing);

        r.popFront();
        assert(r.front.innerHTML == "<b>a</b>");
        assert(r.walkLength == 1999);
        assert(doc.byId("first").isValid);

        // Accessors wait for the element to be complete
        auto doc2 = Document("<body><table><tr><td>1<td>2</table><p>after", Parsing.Lazy, 4);
        auto td = doc2.byTagName("td").front;
        assert(td.nextSibling == "<td>2</td>");
        assert(doc2.byTagName("p").front.textContent == "after");

        // Foster parenting: text inside an open table goes before it
        auto doc3 = Document("<body><table>moved<tr><td>x</table>", Parsing.Lazy, 3);
        assert(doc3.body.firstChild!(Show.All).textContent == "moved");
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
                    auto doc = i % 2 ? Document(html) : Document(html, Parsing.Lazy, 512);
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

    unittest
    {
        // The input is UTF-8: a BOM is removed, invalid bytes become U+FFFD (as in a browser)
        foreach (parsing; [Parsing.Eager, Parsing.Lazy])
        {
            auto doc = Document("\xEF\xBB\xBF<!DOCTYPE html><p title=\"a\xFFb\">x\xC0\xAFy\xE2\x82", parsing, 1);
            assert(!doc.children!(Show.DocumentType).empty);
            assert(doc.body.textContent == "x\uFFFD\uFFFDy\uFFFD");
            assert(doc.byTagName("p").front.getAttribute("title") == "a\uFFFDb");
        }

        // A BOM that is not at the beginning is a character (U+FEFF)
        assert(Document("<p>\xEF\xBB\xBF").body.textContent == "\uFEFF");
    }

    /++ Rebuild a document from a snapshot (see `snapshot`): much faster than parsing again.
    + Each call gives a new, independent document.
    +/
    this(Snapshot snapshot)
    {
        if (!snapshot.isValid) throw new ParserinoException("Invalid snapshot");

        impl = DocImpl.create();
        scope(failure) { DocImpl.release(impl); impl = null; }

        // The document uses the strings of the snapshot: keep it alive
        impl.keepSnapshot(snapshot.data);
        if (!snapshot.data.restore(impl.dom)) throw new ParserinoException("Out of memory");
        impl.fed = snapshot.inputLength;
    }

    ///
    unittest
    {
        Document page = `<ul><li class="item">template</li></ul>`;
        auto snap = page.snapshot;

        foreach (i; 0 .. 3)
        {
            auto copy = Document(snap);
            copy.byClass("item").front.textContent = "copy";
            assert(copy.byClass("item").front.textContent == "copy");
        }

        assert(page.byClass("item").front.textContent == "template");
    }

    unittest
    {
        import core.memory : GC;
        import std.array : replicate;

        // The document keeps the snapshot (and its strings) alive
        Document make()
        {
            auto snap = Document(`<p title="t">` ~ "x".replicate(1000) ~ "</p>").snapshot;
            return Document(snap);
        }

        auto d = make();
        foreach (_; 0 .. 3) { GC.collect(); auto garbage = new char[](100_000); garbage[] = 'z'; }
        assert(d.byTagName("p").front.textContent == "x".replicate(1000));
        assert(d.byTagName("p").front.getAttribute("title") == "t");
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

    /// Parse `html` into a new document: `doc = "<html>...";`
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

    /// Is the document still being parsed? (see `Parsing.Lazy`)
    @property bool isParsing() const @safe nothrow pure @nogc { return impl !is null && impl.parsing; }

    /// Number of input bytes given to the parser so far
    @property size_t bytesParsed() const @safe nothrow pure @nogc { return impl is null ? 0 : impl.fed; }

    /// Complete the parsing of a lazy document. It does nothing on a fully parsed one.
    void finishParsing() { onlyValid(); impl.finish(); }

    /++ The parse errors, in the order of the input (it completes the parsing). They are collected
    + only with `ParseOptions.collectErrors`, else the list is empty. The errors of the tree
    + construction are at the end of the token that causes them.
    + ---
    + ParseOptions options = { collectErrors: true };
    + auto doc = Document("<p>unclosed <b>tags", options);
    + foreach (e; doc.parseErrors) writeln(e);    // 1:4: missing-doctype, 1:20: unclosed-element-at-eof
    + ---
    +/
    @property ParseError[] parseErrors()
    {
        import std.algorithm : sort, SwapStrategy;

        onlyValid();
        impl.finish();

        ParseError[] r;
        r.reserve(impl.errors.length);
        foreach (e; impl.errors[]) r ~= ParseError(e.code, e.line, e.column);
        r.sort!((a, b) => a.line < b.line || (a.line == b.line && a.column < b.column), SwapStrategy.stable);
        return r;
    }

    ///
    unittest
    {
        import std.algorithm : map, startsWith;
        import std.array : array;

        ParseOptions options = { collectErrors: true };

        auto doc = Document("<!DOCTYPE html><p>a</b>\0<p x=1 x=2>", options);
        assert(doc.parseErrors.map!(e => e.name).array
            == ["unexpected-end-tag", "unexpected-null-character", "duplicate-attribute", "unexpected-null-character"]);
        assert(doc.parseErrors[0].line == 1 && doc.parseErrors[0].toString.startsWith("1:"));

        // A valid document, lazy parsing, errors not collected
        assert(Document("<!DOCTYPE html><title>ok</title><p>fine", options).parseErrors.length == 0);
        options.parsing = Parsing.Lazy;
        options.chunkSize = 3;
        assert(Document("<p>\n\n<b>", options).parseErrors.map!(e => e.toString).array
            == ["1:4: missing-doctype", "3:4: unclosed-element-at-eof"]);
        assert(Document("<p>x</b>").parseErrors.length == 0);
    }

    /// A deep copy of the document, independent from this one
    Document dup()
    {
        onlyValid();
        impl.finish();

        Document d;
        d.impl = DocImpl.create();
        scope(failure) { DocImpl.release(d.impl); d.impl = null; }

        auto from = impl.dom;
        auto to = d.impl.dom;
        to.compatMode = from.compatMode;
        to.scripting = from.scripting;

        for (auto c = from.node.firstChild; c !is null; c = c.next)
        {
            auto n = to.importNode(c, true);
            if (n is null) throw new ParserinoException("Out of memory");
            to.node.appendChild(n);
            if (n.type == NodeType.DocumentType && to.doctype is null) to.doctype = n.as!DomDocumentType;
        }

        d.impl.fed = impl.fed;
        return d;
    }

    ///
    unittest
    {
        Document a = `<!DOCTYPE html><title>A</title><p id="x">text</p>`;
        Document b = a.dup;

        b.byId("x").textContent = "changed";
        assert(a.byId("x").textContent == "text");
        assert(b.byId("x").textContent == "changed");
        assert(b.title == "A");
        import std.array : replace;
        assert(b.toString == a.toString.replace("text", "changed"));
    }

    /++ A compact copy of the tree: `Document(snapshot)` rebuilds a document from it without
    + parsing, many times faster. Parse a template once, then make many documents from it.
    + (`ctDocument` does the same at compile time.)
    +/
    @property Snapshot snapshot()
    {
        onlyValid();
        impl.finish();

        auto data = new DomSnapshot;
        *data = takeSnapshot(impl.dom);

        Snapshot s;
        s.data = cast(immutable) data;
        s.inputLength = impl.fed;
        return s;
    }

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
        serializeTo(Serialize.Tree, &d.dom.node, sink);
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

    /// The content of `<title>`, with the whitespace stripped and collapsed (as in the DOM)
    @property string title() { return titleImpl(false); }

    /// ditto, without whitespace normalization
    @property string rawTitle() { return titleImpl(true); }

    /// Set the content of `<title>` tag
    @property void title(const(char)[] s)
    {
        onlyValid();
        impl.mutate();

        auto dom = impl.dom;
        if (dom.head is null) return;

        auto t = findTitle();
        if (t is null)
        {
            auto e = dom.createElement(Tag.Title, Ns.Html);
            if (e is null) throw new ParserinoException("Out of memory");
            dom.head.appendChild(&e.node);
            t = &e.node;
        }

        Node(this, t).textContent = s;
    }

    unittest
    {
        Document doc = Document("<html><head><title>Hello  World!&gt;\n");
        assert(doc.title == "Hello World!>");
        assert(doc.rawTitle == "Hello  World!>\n");

        doc.title = "Goodbye";
        assert(doc.title == "Goodbye");

        Document empty = "<p>";
        assert(empty.title == "");
    }

    /// Create a html element
    Element createElement(const(char)[] tagName)
    {
        onlyValid();
        import std.uni : toLower;
        auto id = impl.dom.tagId(tagName.toLower);
        auto e = id == 0 ? null : impl.dom.createElement(id, Ns.Html);
        if (e is null) throw new ParserinoException("Can't create element `" ~ tagName.idup ~ "`");
        return Element(this, &e.node);
    }

    /// Create a text node
    Node createText(const(char)[] text)
    {
        onlyValid();
        auto t = impl.dom.createText(text);
        if (t is null) throw new ParserinoException("Can't create text node");
        return Node(this, &t.node);
    }

    /// Create a comment
    Node createComment(const(char)[] text)
    {
        onlyValid();
        auto c = impl.dom.createComment(text);
        if (c is null) throw new ParserinoException("Can't create comment");
        return Node(this, &c.node);
    }

    ///
    unittest
    {
        Document d = `<p>`;

        Element p = d.body.firstChild;
        Node t = d.createText("this is a test");
        Node c = d.createComment("this is a comment");
        p.append(t);
        p.append(c);

        assert(p == "<p>this is a test<!--this is a comment--></p>");
        assert(t.isText && c.isComment);
    }

    unittest
    {
        Document doc = Document("<html>");
        Element e = doc.createElement("title");

        assert(e.isValid);

        auto html = doc;
        assert(html == "<html><head></head><body></body></html>");
    }

    /// The document as a `Node` (for the functions that take any node)
    @property Node node() { onlyValid(); return Node(this, &impl.dom.node); }

    /// The `<html>` element
    @property Element documentElement()
    {
        onlyValid();
        while (impl.dom.documentElement is null && impl.advance()) {}
        auto e = impl.dom.documentElement;
        return Element(this, e is null ? null : &e.node);
    }

    /// The `<body>` element: the first `<body>` or `<frameset>` child of `<html>`, as in the DOM
    @property Element body()
    {
        onlyValid();
        while (impl.parsing && (impl.dom.body is null || !impl.isStable(&impl.dom.body.node)))
            impl.advance();

        auto b = impl.dom.body;
        return Element(this, b is null ? null : &b.node);
    }

    /// The `<head>` element
    @property Element head()
    {
        onlyValid();
        while (impl.parsing && impl.dom.head is null)
            impl.advance();

        auto h = impl.dom.head;
        return Element(this, h is null ? null : &h.node);
    }

    unittest
    {
        Document doc = Document("<html><body>Text");

        assert(doc.head.isValid());
        assert(doc.body.isValid());
        assert(doc.body.textContent == "Text");
        assert(doc.documentElement.localName == "html");

        // With a frameset, the body is the frameset
        Document f = "<span><frameset><frame>";
        assert(f.body.localName == "frameset");
        assert(f.body.parent == f.documentElement);
    }

    // Note: the forwarders below use a local variable, because dmd 2.112 miscompiles
    // `return temporary().method();` when the result has a destructor.

    /// Get an element by id. It returns an invalid element (`== null`) if not found.
    Element byId(const(char)[] id) { auto root = node; return root.byId(id); }

    /// A lazy range of elements filtered by class
    auto byClass(string name) { auto root = node; return root.byClass(name); }

    /// A lazy range of elements filtered by tag name (`"*"`: all the elements)
    auto byTagName(string name) { auto root = node; return root.byTagName(name); }

    /++ A lazy range of the comments with this text (whitespace at the ends ignored)
    + ---
    + Document doc = "<div><!-- hello --><p></p></div>";
    + Node c = doc.byComment("hello").front;
    + assert(c.nextSibling.localName == "p");
    + ---
    +/
    auto byComment(string text) { auto root = node; return root.byComment(text); }

    /// A lazy range of the comments with exactly this text
    auto byCommentExact(string text) { auto root = node; return root.byCommentExact(text); }

    /// A lazy range of elements filtered using a css selector
    auto bySelector(const(char)[] selector) { auto root = node; return root.bySelector(selector); }

    /// ditto
    auto bySelector(Selector selector) { auto root = node; return root.bySelector(selector); }

    /// ditto, parsed at compile time
    auto bySelector(string css)() { auto root = node; return root.bySelector(ctSelector!css); }

    /// The children of the document (the doctype, the `<html>` element, comments, ...)
    auto children(Show show = Show.Element)() { auto root = node; return root.children!show; }

    /// All the nodes of the document, in tree order
    auto descendants(Show show = Show.Element)() { auto root = node; return root.descendants!show; }

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
        // Nodes keep the document alive
        Element p;
        {
            Document doc = "<p>hello</p>";
            p = doc.byTagName("p").front;
        }

        assert(p.textContent == "hello");
        assert(p.ownerDocument.isValid);
        assert(p.ownerDocument.body.firstChild == p);
    }

    /++ Parse a fragment of html. The result is a `DocumentFragment` node, not attached to the
    + document: inserting it (`append`, `before`, ...) moves its children.
    +
    + `context` is the element where the html is meant to go, as in the standard fragment
    + parsing: the default is `body`. With `"tr"` the html `<td>x` gives a cell, with
    + `"textarea"` everything is text, with `"template"` the content of a template, ...
    + Use `"svg"` or `"math"` for foreign content.
    +/
    Node fragment(const(char)[] html, const(char)[] context = "body")
    {
        onlyValid();
        impl.finish();

        import std.uni : toLower;
        auto lower = context.toLower;
        Ns ns = lower == "svg" ? Ns.Svg : lower == "math" ? Ns.Math : Ns.Html;
        auto id = impl.dom.tagId(lower);
        auto ctx = id == 0 ? null : impl.dom.createElement(id, ns);
        if (ctx is null) throw new ParserinoException("Out of memory");

        return Node(this, &parseToFragment(impl.dom, ctx, html).node);
    }

    ///
    unittest
    {
        Document doc = Document("<html>");
        Node f = doc.fragment("<p><b>hello</b>world");

        assert(f.nodeType == NodeType.DocumentFragment);
        assert(f.descendants.front.localName == "p");

        // The context changes the parsing
        assert(doc.fragment("<td>x").children.empty);                  // in body, <td> is ignored
        assert(doc.fragment("<td>x", "tr").children.front.localName == "td");
        assert(doc.fragment("<b>x</b>", "textarea").textContent == "<b>x</b>");

        // Inserting a fragment moves its children
        doc.body.append(f);
        assert(doc.body.innerHTML == "<p><b>hello</b>world</p>");
        assert(!f.hasChildNodes);
    }

    private:

    DocImpl* impl;

    DocImpl* mutableImpl() { onlyValid(); return impl; }

    void onlyValid(string fname = __FUNCTION__) const
    {
        if (impl is null)
            throw new ParserinoException("Can't call `" ~ fname ~ "` for an invalid/uninitialized document");
    }

    // The first html <title> in tree order (found lazily)
    DomNode* findTitle()
    {
        foreach (t; node.byTagName("title"))
            if (t.raw.ns == Ns.Html) return t.raw;
        return null;
    }

    string titleImpl(bool raw)
    {
        onlyValid();

        auto t = findTitle();
        if (t is null) return "";
        impl.ensureClosed(t);

        auto text = Node(this, t).textContent;
        if (raw) return text;

        // Strip and collapse the ASCII whitespace
        import std.array : appender;
        auto app = appender!string;
        bool space = false;
        foreach (c; text)
        {
            if (isHtmlSpace(c)) { space = app.data.length > 0; continue; }
            if (space) app.put(' ');
            space = false;
            app.put(c);
        }
        return app.data;
    }
}

/++ A compact copy of a document tree, made by `Document.snapshot`: `Document(snapshot)` makes
+ new documents from it without parsing. It can be shared between threads.
+/
struct Snapshot
{
    /// Is this a snapshot of a document?
    @property bool isValid() const @safe nothrow pure @nogc { return data !is null; }

    private:
    immutable(DomSnapshot)* data;
    size_t inputLength;
}


/++ A node of a document: an element, a text, a comment, a doctype, the document itself, ...
+ See the module documentation for the navigation (`Show`) and the rules on errors.
+/
struct Node
{
    /// The document of this node
    @property Document ownerDocument() { return doc; }

    /// Is this a valid node?
    @property bool isValid() const @safe nothrow pure @nogc { return raw !is null; }

    /// The type of the node (`NodeType.Element`, `NodeType.Text`, ...)
    @property NodeType nodeType() const { onlyValid(); return raw.type; }

    /++ The name of the node, as in the DOM: the tag name for elements (uppercase for html
    + elements: `"DIV"`), `"#text"`, `"#comment"`, `"#document"`, `"#document-fragment"`, the
    + name of a doctype, the target of a processing instruction.
    +/
    @property string nodeName()
    {
        onlyValid();
        final switch (raw.type)
        {
            case NodeType.Element: return Element(doc, raw).tagName;
            case NodeType.Text: return "#text";
            case NodeType.CDataSection: return "#cdata-section";
            case NodeType.Comment: return "#comment";
            case NodeType.Document: return "#document";
            case NodeType.DocumentFragment: return "#document-fragment";
            case NodeType.DocumentType: return raw.as!DomDocumentType.name.idup;
            case NodeType.ProcessingInstruction: return raw.as!DomCharacterData.target.idup;
        }
    }

    /// Is this node an element?
    @property bool isElement() const @safe nothrow pure @nogc { return raw !is null && raw.type == NodeType.Element; }

    /// Is this a text node?
    @property bool isText() const @safe nothrow pure @nogc { return raw !is null && raw.type == NodeType.Text; }

    /// Is this a comment?
    @property bool isComment() const @safe nothrow pure @nogc { return raw !is null && raw.type == NodeType.Comment; }

    /// This node as an `Element`, or an invalid element if it isn't one
    Element asElement() { return isElement ? Element(doc, raw) : Element.init; }

    unittest
    {
        Document doc = "<p>text<!--c--></p>";
        Node p = doc.body.firstChild;
        Node t = p.firstChild!(Show.All);

        assert(p.isElement && p.asElement.localName == "p");
        assert(t.isText && !t.asElement.isValid);
        assert(p.nodeName == "P" && t.nodeName == "#text" && t.nextSibling!(Show.All).nodeName == "#comment");
        assert(doc.node.nodeName == "#document" && doc.node.nodeType == NodeType.Document);
    }

    /++ The text of the node (DOM `textContent`): the text of all the descendants for elements
    + and fragments, the data for texts, comments and processing instructions, `null` for the
    + document and the doctype.
    +/
    @property string textContent()
    {
        onlyValid();
        impl.ensureClosed(raw);

        if (raw.isCharacterData) return raw.as!DomCharacterData.data.idup;
        if (raw.type != NodeType.Element && raw.type != NodeType.DocumentFragment) return null;

        import std.array : appender;
        auto app = appender!string;
        raw.textContent(app);
        return app.data;
    }

    /++ Set the text: for elements and fragments it replaces all the children with a text node,
    + for texts, comments and processing instructions it replaces the data. It does nothing on
    + the document and the doctype (as in the DOM).
    +/
    @property void textContent(const(char)[] text)
    {
        onlyValid();
        impl.mutate();

        if (auto cd = raw.asCharacterData)
        {
            if (!cd.setData(text)) throw new ParserinoException("Out of memory");
            return;
        }

        if (raw.type != NodeType.Element && raw.type != NodeType.DocumentFragment) return;

        removeChildren();

        if (text.length > 0)
        {
            auto t = impl.dom.createText(text);
            if (t is null) throw new ParserinoException("Can't create text node");
            raw.appendChild(&t.node);
        }
    }

    /// The data of a text, comment or processing instruction without copying it; `null` for other nodes
    @property const(char)[] dataView()
    {
        onlyValid();
        impl.ensureClosed(raw);
        auto cd = raw.asCharacterData;
        return cd is null ? null : cd.data;
    }

    ///
    unittest
    {
        Document doc = Document("<html><p>");
        Element p = doc.byTagName("p").front;

        assert(p.descendants.empty);
        p.innerHTML = `<a href="uri">link</a>`;
        assert(p.descendants.front.localName == "a");
        assert(p.byTagName("a").front.textContent == "link");

        p.byTagName("a").front.textContent = "hello";
        assert(p.byTagName("a").front.textContent == "hello");

        Element a = p.byTagName("a").front;
        p.textContent = "plain text";

        assert(p.descendants!(Show.All).front.nodeName == "#text");
        assert(p.textContent == "plain text");
        assert(p.firstChild!(Show.Text).dataView == "plain text");
        assert(p.byTagName("a").empty);

        // The old child is detached, but still valid
        assert(a.parent == null);
        assert(a == `<a href="uri">hello</a>`);
    }

    /++ The parent, if it matches `show` (else an invalid node). By default the parent element:
    + the parent of `<html>` is the document, so `html.parent` is invalid and
    + `html.parent!(Show.All)` is the document.
    +/
    auto parent(Show show = Show.Element)()
    {
        onlyValid();
        impl.ensureStable(raw);
        auto p = raw.parent;
        return NodeOf!show(doc, p !is null && shown(show, p) ? p : null);
    }

    /// The first child that matches `show`
    auto firstChild(Show show = Show.Element)()
    {
        onlyValid();
        return NodeRange!(AnyFilter, show)(doc, raw, false, AnyFilter.init).frontOrInit;
    }

    /// The last child that matches `show`
    auto lastChild(Show show = Show.Element)()
    {
        onlyValid();
        impl.ensureClosed(raw);

        auto n = raw.lastChild;
        while (n !is null && !shown(show, n)) n = n.prev;
        return NodeOf!show(doc, n);
    }

    /// The next sibling that matches `show`
    auto nextSibling(Show show = Show.Element)()
    {
        onlyValid();
        impl.ensureStable(raw);

        if (raw.parent is null) return NodeOf!show.init;

        auto r = NodeRange!(AnyFilter, show)(doc, raw.parent, false, AnyFilter.init);
        r.start(raw);
        return r.frontOrInit;
    }

    /// The previous sibling that matches `show`
    auto previousSibling(Show show = Show.Element)()
    {
        onlyValid();
        impl.ensureStable(raw);

        auto n = raw.prev;
        while (n !is null && !shown(show, n)) n = n.prev;
        return NodeOf!show(doc, n);
    }

    unittest
    {
        Document d = `<div><p></p><!--hmm--><i></i><!--ohh--></div>`;

        Element p = d.byTagName("p").front;
        Element i = d.byTagName("i").front;

        assert(i.previousSibling == p);
        assert(p.nextSibling == i);
        assert(p.nextSibling!(Show.All).textContent == "hmm");
        assert(i.previousSibling!(Show.All).textContent == "hmm");

        assert(i.nextSibling == null);
        assert(i.nextSibling!(Show.All).textContent == "ohh");
        assert(i.nextSibling!(Show.Text) == null);

        assert(d.documentElement.parent == null);
        assert(d.documentElement.parent!(Show.All) == d.node);
    }

    unittest
    {
        Document d = "<p><!--hello--><b></b>text</p>";

        assert(d.body.firstChild.firstChild == "<b></b>");
        assert(d.body.firstChild.lastChild == "<b></b>");
        assert(d.body.firstChild.firstChild!(Show.All) == "<!--hello-->");
        assert(d.body.firstChild.lastChild!(Show.All) == "text");
        assert(d.body.firstChild.lastChild!(Show.Comment) == "<!--hello-->");
    }

    /// The children that match `show`, as a lazy (bidirectional) range
    auto children(Show show = Show.Element)()
    {
        onlyValid();
        return NodeRange!(AnyFilter, show)(doc, raw, false, AnyFilter.init);
    }

    /// All the descendants that match `show`, in tree order, as a lazy (bidirectional) range
    auto descendants(Show show = Show.Element)()
    {
        onlyValid();
        return NodeRange!(AnyFilter, show)(doc, raw, true, AnyFilter.init);
    }

    /// Does this node have children? (any kind of node)
    bool hasChildNodes()
    {
        onlyValid();
        return !children!(Show.All).empty;
    }

    ///
    unittest
    {
        import std.array : array;

        Document d = "<p><b>test</b>test2<!--c--></p>";
        Element p = d.body.firstChild;

        Node[] c = p.children!(Show.All).array;
        assert(c.length == 3);
        assert(c[0] == "<b>test</b>");
        assert(c[1] == "test2");

        assert(p.children.walkLength == 1);
        assert(p.children!(Show.Text | Show.Comment).walkLength == 2);
        assert(p.hasChildNodes && p.firstChild.hasChildNodes);

        // Texts and comments have no children
        assert(c[1].children!(Show.All).empty);
        assert(!c[1].hasChildNodes);
    }

    unittest
    {
        import std.algorithm : map;
        import std.array : array, join;
        import std.range : retro;

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

        assert(d.body.descendants.map!(x => x.localName).join("->") == "p->b->i->a->br");
        assert(d.body.descendants.retro.map!(x => x.localName).join("->") == "br->a->i->b->p");
        assert(d.body.children.map!(x => x.localName).join("->") == "p->br");
        assert(d.body.children.retro.map!(x => x.localName).join("->") == "br->p");

        // Both ends
        auto r = d.body.descendants;
        assert(r.front.localName == "p" && r.back.localName == "br");
        r.popFront();
        r.popBack();
        assert(r.map!(x => x.localName).array == ["b", "i", "a"]);
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

    /// Is `other` this node or one of its descendants? (as in the DOM)
    bool contains(Node other)
    {
        onlyValid();
        if (!other.isValid) return false;
        impl.ensureStable(other.raw);
        return raw.contains(other.raw);
    }

    unittest
    {
        Document d = "<html><p><!--hey<b>--><a>hello<b></b></a>";
        Element p = d.byTagName("p").front;
        Element b = d.byTagName("b").front;

        Node c = p.firstChild!(Show.All);
        assert(c.textContent == "hey<b>");
        assert(c.isComment && c.nodeName == "#comment");
        assert(c.children!(Show.All).empty);

        assert(p.contains(c));
        assert(p.contains(b));
        assert(p.contains(p));
        assert(!b.contains(p));
        assert(!d.head.contains(c));
        assert(d.node.contains(c));
    }

    /// Search for an element by id. It returns an invalid element (`== null`) if not found.
    Element byId(const(char)[] id)
    {
        onlyValid();

        // On a whole parsed document, from the second search on: an index (until a mutation)
        if (raw is &impl.dom.node && !impl.parsing && impl.idSearches++ > 0)
        {
            auto e = impl.elementById(id);
            return Element(doc, e is null ? null : &e.node);
        }

        return NodeRange!(IdFilter, Show.Element)(doc, raw, true, IdFilter(id)).frontOrInit;
    }

    /++ Search for elements by class
    + See_also: `parserino.Document.byClass`
    +/
    auto byClass(string name)
    {
        onlyValid();
        return NodeRange!(ClassFilter, Show.Element)(doc, raw, true, ClassFilter(name));
    }

    /++ Search for elements by tag name (case-insensitive for html elements; `"*"` gives all the elements)
    + See_also: `parserino.Document.byTagName`
    +/
    auto byTagName(string name)
    {
        onlyValid();
        return NodeRange!(TagFilter, Show.Element)(doc, raw, true, TagFilter(name));
    }

    /++ Search for comments by text (whitespace at the ends ignored)
    + See_also: `parserino.Document.byComment`
    +/
    auto byComment(string text)
    {
        onlyValid();
        return NodeRange!(CommentFilter, Show.Comment)(doc, raw, true, CommentFilter(text, true));
    }

    /// Search for comments with exactly this text
    auto byCommentExact(string text)
    {
        onlyValid();
        return NodeRange!(CommentFilter, Show.Comment)(doc, raw, true, CommentFilter(text, false));
    }

    /++ Search for elements by css selector
    + See_also: `parserino.Document.bySelector`
    +/
    auto bySelector(const(char)[] selector) { return bySelector(Selector(selector)); }

    /// ditto
    auto bySelector(Selector selector)
    {
        onlyValid();
        if (!selector.isValid) throw new ParserinoException("Invalid selector");
        return NodeRange!(SelectorFilter, Show.Element)(doc, raw, true, SelectorFilter(selector, raw));
    }

    /// ditto, parsed at compile time
    auto bySelector(string css)() { return bySelector(ctSelector!css); }

    unittest
    {
        import std.exception : assertThrown;

        Document doc = "<div><!-- hello --><p></p><!--hello--></div>";
        Node c = doc.byComment("hello").front;
        assert(c.nextSibling.localName == "p");
        assert(doc.byComment("hello").walkLength == 2);
        assert(doc.byCommentExact("hello").walkLength == 1);
        assert(doc.byComment("hell").frontOrInit == null);

        assertThrown!ParserinoException(doc.bySelector("div >"));
        assertThrown!ParserinoException(doc.bySelector("a["));
    }

    unittest
    {
        // The index of the ids follows the changes of the document
        Document doc = `<p id=a>1</p><p id=b>2</p><p id=a>3</p>`;
        assert(doc.byId("a").textContent == "1");
        assert(doc.byId("zz") == null);

        doc.byId("a").remove();
        assert(doc.byId("a").textContent == "3");
        doc.byId("b").id = "c";
        assert(doc.byId("b") == null && doc.byId("c").textContent == "2");
        doc.body.prepend(doc.createElement("i"));
        doc.body.firstChild.id = "b";
        assert(doc.byId("b").localName == "i");
        doc.body.innerHTML = "<b id=a>new</b>";
        assert(doc.byId("a").textContent == "new" && doc.byId("c") == null);

        // A subtree is searched directly
        assert(doc.body.byId("a").textContent == "new");
    }

    unittest
    {
        Document doc = Document(`<html><body><p id="test"/><p id="another" class="hello world">this is a text`);

        {
            Element e = doc.byId("test");
            assert(e.isValid);
            assert(e.localName == "p");
            assert(e.id == "test");
            assert(doc.byId("blah") == null);
        }

        import std.array;

        {
            Element[] res = doc.byClass("world").array;
            assert(res.length == 1);
            assert(res[0].id == "another");
            assert(res[0].localName == "p");
        }

        {
            Element[] res = doc.byTagName("p").array;
            assert(res.length == 2);
            assert(res[0].id == "test");
            assert(res[1].id == "another");
        }

        assert(doc.byTagName("P").walkLength == 2);
        assert(doc.byTagName("*").walkLength == 5);
        assert(doc.byTagName("#text").empty);
    }

    /++ Append a node (or a text, or a fragment) as the last child.
    + Strings become text nodes; `"<b>x</b>".asFragment` is parsed as html (in the context of
    + this element); a `DocumentFragment` (see `Document.fragment`) gives its children.
    +/
    void append(E)(auto ref E what)
    {
        onlyParent();
        impl.mutate();

        foreach (n; nodesToInsert(what, raw, raw))
            raw.appendChild(n);
    }

    /// Insert a node (or a text, or a fragment) as the first child
    void prepend(E)(auto ref E what)
    {
        onlyParent();
        impl.mutate();

        auto first = raw.firstChild;
        foreach (n; nodesToInsert(what, raw, raw))
        {
            if (first is null) raw.appendChild(n);
            else first.insertBefore(n);
        }
    }

    /// Insert a node (or a text, or a fragment) before this one
    void before(E)(auto ref E what)
    {
        onlySibling();
        impl.mutate();

        foreach (n; nodesToInsert(what, raw.parent, raw))
            raw.insertBefore(n);
    }

    /// Insert a node (or a text, or a fragment) after this one
    void after(E)(auto ref E what)
    {
        onlySibling();
        impl.mutate();

        DomNode* last = raw;
        foreach (n; nodesToInsert(what, raw.parent, raw))
        {
            last.insertAfter(n);
            last = n;
        }
    }

    /// Replace this node with another one (or with a text, or a fragment)
    void replaceWith(E)(auto ref E what)
    {
        onlySibling();
        static if (is(E : Node))
        {
            Node n = what;
            if (n.raw is raw) return;
        }

        before(what);
        remove();
    }

    /// Append a child node (as `append`, only for nodes)
    void appendChild(Node child) { append(child); }

    /// `node ~= x` is `node.append(x)`
    void opOpAssign(string op : "~", E)(auto ref E what) { append(what); }

    /++ Remove this node from its parent. The node is still valid and can be inserted again.
    + It returns false if the node had no parent.
    +/
    bool remove()
    {
        onlyValid();
        impl.mutate();

        if (raw.parent is null) return false;
        raw.remove();
        return true;
    }

    ///
    unittest
    {
        Document doc = "<p>";
        Element p = doc.byTagName("p").front;
        p.before("<a>first-before</a><a><b>second</b></a>".asFragment);
        p.after("<a>first-after</a><a><b>second</b></a>".asFragment);
        assert(doc.toString() == `<html><head></head><body><a>first-before</a><a><b>second</b></a><p></p><a>first-after</a><a><b>second</b></a></body></html>`);
    }

    ///
    unittest
    {
        Document doc = `<p id="start">`;

        Element p = doc.byTagName("p").front;
        p.append("<p>post</p><p>post1</p>".asFragment);
        p.prepend("<p>pre</p><p>pre1</p>".asFragment);
        p.append("<p>text</p>");

        assert(doc.body.toString == `<body><p id="start"><p>pre</p><p>pre1</p><p>post</p><p>post1</p>&lt;p&gt;text&lt;/p&gt;</p></body>`);

        // The fragment is parsed in the context of the element
        Element table = doc.createElement("table");
        doc.body.append(table);
        table.append("<tr><td>cell".asFragment);
        assert(table == "<table><tbody><tr><td>cell</td></tr></tbody></table>");
    }

    unittest
    {
        Document doc = "<p>";
        Element e = doc.body.children.front;
        e.append("world");
        e.prepend("hello");
        e.append("!");
        e.before("before");
        e.after("after");
        assert(doc == "<html><head></head><body>before<p>helloworld!</p>after</body></html>");
    }

    unittest
    {
        Document doc = "<p>";
        Element bod = doc.body;
        Element other = doc.createElement("a");
        bod ~= other;
        bod ~= doc.createElement("a");
        bod.appendChild(doc.createElement("b"));
        bod.prepend(doc.createElement("i"));
        assert(doc.body.toString == "<body><i></i><p></p><a></a><a></a><b></b></body>");
    }

    unittest
    {
        Document doc = "<p><b>hello";
        auto comment = doc.createComment("comment");
        doc.byTagName("b").front.before(comment);
        doc.byTagName("b").front.after(comment);
        assert(!doc.descendants!(Show.Comment).empty);
        assert(doc.byTagName("p").front.toString == `<p><b>hello</b><!--comment--></p>`);
    }

    unittest
    {
        Document doc = "<html>";
        auto e = doc.createElement("a");
        assert (doc == "<html><head></head><body></body></html>");

        assert(e.remove() == false);

        doc.body.append(e);
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

        Document a = "<p>text";
        Document b = "<i>";

        // Nodes can't be moved between documents
        assertThrown!ParserinoException(a.body.append(b.body.firstChild));

        // A node can't become a child of itself
        Element p = a.body.firstChild;
        assertThrown!ParserinoException(p.append(a.body));

        // A text can't have children, a node without parent can't have siblings
        assertThrown!ParserinoException(p.firstChild!(Show.Text).append("x"));
        assertThrown!ParserinoException(a.createElement("b").before("x"));

        // Invalid nodes
        Node invalid;
        assertThrown!ParserinoException(invalid.textContent);
        assertThrown!ParserinoException(invalid.children.empty);
    }

    unittest
    {
        Document doc = `<html><p class="p1"><b><p class="p2"><i>`;

        Element p1 = doc.byClass("p1").frontOrThrow;
        Element p2 = doc.byClass("p2").frontOrThrow;
        Element b = p1.descendants.frontOrThrow;
        Element i = p2.descendants.frontOrThrow;

        i.replaceWith(b);
        assert(p1.descendants.empty == true);
        assert(p2.descendants.frontOrThrow.localName == "b");
        assert(p2.descendants.frontOrThrow == b);

        b.replaceWith(b);
        assert(p2.descendants.frontOrThrow == b);
    }

    /// A deep copy of this node (with all the descendants), not attached to the document
    Node dup()
    {
        onlyValid();
        impl.ensureClosed(raw);
        return Node(doc, cloned(true));
    }

    /// A copy of this node alone (for an element: the tag and the attributes, without children)
    Node shallowDup()
    {
        onlyValid();
        impl.ensureStable(raw);
        impl.ensureAttrs(raw);
        return Node(doc, cloned(false));
    }

    /// The node as html (for an element: `outerHTML`)
    string toString() const
    {
        import std.array : appender;
        auto app = appender!string;
        toString((const(char)[] s) { app.put(s); });
        return app.data;
    }

    /// Write the node as html to a sink
    void toString(scope void delegate(const(char)[]) sink) const
    {
        auto self = cast() this;
        self.onlyValid();
        self.impl.ensureClosed(self.raw);
        serializeTo(Serialize.Tree, self.raw, sink);
    }

    /// ditto
    void toString(W)(ref W writer) const
    if (isOutputRange!(W, const(char)[]) && !is(W : void delegate(const(char)[])))
    {
        import std.range.primitives : put;
        toString((const(char)[] s) { put(writer, s); });
    }

    ///
    string opCast(T : string)() const { return toString(); }

    unittest
    {
        Document d = "<p>";
        Element e = d.byTagName("p").front;

        string se = cast(string) e;
        string de = cast(string) d;

        assert(se == "<p></p>");
        assert(de == "<html><head></head><body><p></p></body></html>");
    }

    bool opEquals(const typeof(null)) const @safe nothrow pure @nogc { return !isValid; }
    bool opEquals(E)(auto ref const E e) const
    {
        static if (isSomeString!E) return isValid && e == this.toString;
        else return e.raw is this.raw;
    }

    size_t toHash() const nothrow @safe { return hashOf(raw); }

    ///
    ref Node opAssign(typeof(null)) return { this = Node.init; return this; }

    private:

    Document doc;
    DomNode* raw;

    this(ref Document doc, DomNode* raw)
    {
        if (raw is null) return;
        this.doc = doc;
        this.raw = raw;
    }

    inout(DocImpl)* impl() inout { return doc.impl; }

    void onlyValid(string fname = __FUNCTION__) const
    {
        if (raw is null)
            throw new ParserinoException("Can't call `" ~ fname ~ "` for an invalid/uninitialized node");
    }

    // Nodes that can have children: elements, documents and fragments
    void onlyParent(string fname = __FUNCTION__)
    {
        onlyValid(fname);
        if (raw.type != NodeType.Element && raw.type != NodeType.Document && raw.type != NodeType.DocumentFragment)
            throw new ParserinoException("Can't call `" ~ fname ~ "` for a node that can't have children (" ~ nodeName ~ ")");
    }

    // Nodes that can have siblings: the ones with a parent
    void onlySibling(string fname = __FUNCTION__)
    {
        onlyValid(fname);
        impl.ensureStable(raw);
        if (raw.parent is null)
            throw new ParserinoException("Can't call `" ~ fname ~ "` for a node without parent");
    }

    void removeChildren()
    {
        while (raw.firstChild !is null)
            raw.firstChild.remove();
    }

    DomNode* cloned(bool deep)
    {
        auto n = impl.dom.importNode(raw, deep);
        if (n is null) throw new ParserinoException("Out of memory");
        return n;
    }

    /+ The nodes to insert for a node, a text or a fragment, detached from where they are.
     + `parent` is where they go (it's also the context of the fragments), `target` the node
     + they go into or next to.
     +/
    DomNode*[] nodesToInsert(E)(auto ref E what, DomNode* parent, DomNode* target)
    {
        static if (is(E == FragmentString))
        {
            auto context = parent !is null && parent.type == NodeType.Element ? parent.as!DomElement : null;
            if (context is null)
            {
                context = impl.dom.createElement(Tag.Body, Ns.Html);
                if (context is null) throw new ParserinoException("Out of memory");
            }
            return childrenOf(&parseToFragment(impl.dom, context, what.fragment).node);
        }
        else static if (isSomeString!E)
        {
            auto t = impl.dom.createText(what);
            if (t is null) throw new ParserinoException("Can't create text node");
            return [&t.node];
        }
        else static if (is(E : Node))
        {
            Node n = what;
            n.onlyValid();
            if (n.raw.document !is raw.document)
                throw new ParserinoException("Can't insert a node of another document (use `dup` on a fragment of this document)");

            if (n.raw.type == NodeType.DocumentFragment) return childrenOf(n.raw);
            if (n.raw.type == NodeType.Document) throw new ParserinoException("Can't insert a document");
            if (n.raw is target) return null;

            for (auto p = parent; p !is null; p = p.parent)
                if (p is n.raw) throw new ParserinoException("Can't insert a node inside itself");

            if (n.raw.parent !is null) n.raw.remove();
            return [n.raw];
        }
        else static assert(0, "Can't insert a " ~ E.stringof);
    }

    // The children of a node, detached
    static DomNode*[] childrenOf(DomNode* parent)
    {
        DomNode*[] nodes;
        for (auto c = parent.firstChild; c !is null; c = c.next) nodes ~= c;
        foreach (n; nodes) n.remove();
        return nodes;
    }
}


/// A node that is an element. It converts implicitly to `Node`.
struct Element
{
    Node node;          /// This element as a `Node`
    alias node this;

    /// A simple key/value struct representing a html attribute
    struct Attribute
    {
        string name;    /// Name of the attribute. For example "href"
        string value;   /// Value of the attribute. For example "https://dlang.org"
    }

    /// ditto, as slices of the document memory (see `attributesView`)
    struct AttributeView
    {
        const(char)[] name;     /// Name of the attribute
        const(char)[] value;    /// Value of the attribute
    }

    /// The local name, as in the DOM: `"div"`, `"foreignObject"`
    @property string localName() { return localNameView.idup; }

    /// ditto, without copying
    @property const(char)[] localNameView() { onlyValid(); return element.fullName; }

    /// The tag name, as in the DOM: uppercase for html elements (`"DIV"`), else the local name
    @property string tagName()
    {
        onlyValid();
        auto name = element.fullName;
        if (raw.ns != Ns.Html) return name.idup;

        import std.ascii : toUpper;
        auto r = new char[name.length];
        foreach (i, c; name) r[i] = toUpper(c);
        return cast(string) r;
    }

    unittest
    {
        Document doc = Document(`<!doctype html><html><body id="bo"><svg><foreignObject/></svg>`);
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

        assert(g.localName == "body" && g.tagName == "BODY");
        assert(c.localName == "head");

        Element fo = doc.byTagName("foreignObject").front;
        assert(fo.localName == "foreignObject" && fo.tagName == "foreignObject");
    }

    /// Is this element empty? No element and no text children (comments don't count), as `:empty`
    @property bool isEmpty() { onlyValid(); impl.ensureClosed(raw); return raw.isEmpty; }

    /// Like `isEmpty`, but whitespace text doesn't count either, as `:blank`
    @property bool isBlank() { onlyValid(); impl.ensureClosed(raw); return raw.isBlank; }

    unittest
    {
        import std.array;
        import std.algorithm : map;

        Document doc = "<b>hello</b><br><b><!--x--></b><i> </i>";
        assert(doc.body.children.map!(x => x.isEmpty()).array == [false, true, true, false]);
        assert(doc.body.children.map!(x => x.isBlank()).array == [false, true, true, true]);
    }

    /// Return a lazy range of attributes for this element
    @property AttributeRange!false attributes()
    {
        onlyValid();
        impl.ensureAttrs(raw);
        return AttributeRange!false(doc, element.firstAttr);
    }

    /// ditto, without copying names and values
    @property AttributeRange!true attributesView()
    {
        onlyValid();
        impl.ensureAttrs(raw);
        return AttributeRange!true(doc, element.firstAttr);
    }

    /// Check if an attribute exists
    bool hasAttribute(const(char)[] attr)
    {
        onlyValid();
        impl.ensureAttrs(raw);
        return attributeByName(element, attr) !is null;
    }

    /// Remove an attribute from this element
    void removeAttribute(const(char)[] attr)
    {
        onlyValid();
        impl.mutate();
        if (auto a = attributeByName(element, attr)) element.removeAttribute(a);
    }

    /// Set an attribute for this element
    void setAttribute(const(char)[] name, const(char)[] value)
    {
        onlyValid();
        impl.mutate();
        auto dom = impl.dom;
        if (auto a = attributeByName(element, name))
        {
            a.value = dom.copy(value);
            return;
        }

        import std.uni : toLower;
        auto a = dom.createAttribute(name.toLower, value);
        if (a is null) throw new ParserinoException("Can't set attribute `" ~ name.idup ~ "`");
        element.appendAttribute(a);
    }

    /// Get an attribute. It returns `null` if the attribute is missing.
    string getAttribute(const(char)[] attr)
    {
        auto v = getAttributeView(attr);
        if (v is null) return null;
        return v.length == 0 ? "" : v.idup;
    }

    /// ditto, without copying
    const(char)[] getAttributeView(const(char)[] attr)
    {
        onlyValid();
        impl.ensureAttrs(raw);

        auto a = attributeByName(element, attr);
        if (a is null) return null;
        return attrValue(a);
    }

    /// The id of this element (empty if missing)
    @property string id() { return idView.idup; }

    /// ditto, without copying
    @property const(char)[] idView()
    {
        onlyValid();
        impl.ensureAttrs(raw);
        return element.idAttr is null ? "" : attrValue(element.idAttr);
    }

    /// Set the id of this element
    @property void id(const(char)[] value) { setAttribute("id", value); }

    /// All the classes of this element
    @property auto classes()
    {
        import std.algorithm : map;
        return classesView.map!(c => c.idup);
    }

    /// ditto, without copying
    @property auto classesView()
    {
        import std.algorithm : splitter, filter;

        onlyValid();
        impl.ensureAttrs(raw);

        auto cls = element.classAttr is null ? "" : attrValue(element.classAttr);
        return cls.splitter!(c => c < 0x80 && isHtmlSpace(cast(char) c)).filter!(x => x.length > 0);
    }

    unittest
    {
        import std.array;

        Document doc = Document(`<html><p class="hello world" id="world" style><a>`);
        assert(doc.byId("world").attributes.array == [Attribute("class", "hello world"), Attribute("id", "world"), Attribute("style", "")]);
        assert(doc.byId("world").attributesView.front == AttributeView("class", "hello world"));
        assert(doc.byTagName("a").front.attributes.empty);

        auto p = doc.byTagName("p").front;
        auto a = doc.byTagName("a").front;

        assert(p.hasAttribute("style"));
        assert(p.hasAttribute("STYLE"));
        assert(p.hasAttribute("href") == false);
        assert(p.classes.array == ["hello", "world"]);
        assert(p.classesView.array == ["hello", "world"]);

        assert(p.id == "world");
        assert(p.idView == "world");

        a.setAttribute("href", "url");
        a.id = "link";

        assert(a.hasAttribute("href"));
        assert(a.getAttribute("href") == "url");
        assert(a.getAttributeView("href") == "url");
        assert(a.getAttribute("title") is null);
        assert(a.id == "link" && doc.byId("link") == a);
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

    /// A deep copy of this element, not attached to the document
    Element dup() { auto n = node.dup; return Element(n); }

    /// A copy of this element alone: the tag and the attributes, without children
    Element shallowDup() { auto n = node.shallowDup; return Element(n); }

    ///
    unittest
    {
        import std.array;
        import std.algorithm : map;

        Document doc = Document(`<html><p data-a="a" data-b="b"><i></i><b></b>`);
        Element e = doc.byTagName("p").front;
        Element f = e;
        Element g = e.shallowDup;
        Element h = g;

        assert(e != g);
        assert(f != g);
        assert(g == h);

        assert(g.localName == "p");
        assert(g.attributes.array == [Attribute("data-a", "a"), Attribute("data-b", "b")]);
        assert(g.descendants.map!(x => x.localName).array == []);

        g = e.dup;
        assert(g.localName == "p");
        assert(g.attributes.array == [Attribute("data-a", "a"), Attribute("data-b", "b")]);
        assert(g.descendants.map!(x => x.localName).array == ["i", "b"]);
    }

    /// Make this element a copy of another one: the tag, the attributes and the children
    void copyFrom(Element e) { copyImpl(e, true); }

    /// Make this element a copy of another one, without the children: the tag and the attributes
    void shallowCopyFrom(Element e) { copyImpl(e, false); }

    unittest
    {
        Document d = `<p id="hello"></p><a>`;

        auto p = d.byId("hello");
        auto a = d.byTagName("a").front;

        p.copyFrom(a);

        assert(p.attributes.empty);
        assert(p.localName == "a");
    }

    unittest
    {
        Document doc = `<html><p class="p1"><b></b><p class="p2"><i>x</i><template>t</template>`;

        Element p1 = doc.byClass("p1").frontOrThrow;
        Element p1Copy = p1;
        Element p2 = doc.byClass("p2").frontOrThrow;

        p1.copyFrom(p2);
        assert(p1.classes.frontOrThrow == "p2");
        assert(p1Copy.classes.frontOrThrow == "p2");
        assert(p1.innerHTML == "<i>x</i><template>t</template>");
        assert(p1.descendants.frontOrThrow != p2.descendants.frontOrThrow);

        p1.shallowCopyFrom(doc.createElement("b"));
        assert(p1.localName == "b" && p1.attributes.empty && p1.innerHTML == "<i>x</i><template>t</template>");

        // A template gets a content, and a copy of it
        Element t = doc.byTagName("template").front;
        p2.copyFrom(t);
        assert(p2 == "<template>t</template>");
        assert(p2.innerHTML == "t");
    }

    /// Set the html content of this element (for a `<template>`: its content)
    @property void innerHTML(const(char)[] html)
    {
        onlyValid();
        impl.mutate();

        auto frag = parseToFragment(impl.dom, element, html);

        // The old children are detached (not destroyed): other `Node`s may still point to them.
        auto target = element.templateContent !is null ? &element.templateContent.node : raw;
        while (target.firstChild !is null) target.firstChild.remove();
        frag.node.moveChildrenTo(target);
    }

    /// Get the html content of this element
    @property string innerHTML()
    {
        import std.array : appender;

        onlyValid();
        impl.ensureClosed(raw);

        auto app = appender!string;
        serializeTo(Serialize.Children, raw, (const(char)[] s) { app.put(s); });
        return app.data;
    }

    unittest
    {
        Document doc = "<template><b>x</b></template>";
        Element t = doc.byTagName("template").front;
        assert(t.innerHTML == "<b>x</b>");
        t.innerHTML = "<i>y</i>";
        assert(t.innerHTML == "<i>y</i>");
        assert(!t.hasChildNodes);
    }

    /// The text of the element (the same as `textContent`: here nothing depends on the layout)
    @property string innerText() { return node.textContent; }

    /// Set the text of the element (the same as `textContent`)
    @property void innerText(const(char)[] text) { node.textContent = text; }

    /// The outer html of this element
    @property string outerHTML() { return node.toString(); }

    /// Replace this element with the html (parsed in the context of the parent)
    @property void outerHTML(const(char)[] html)
    {
        onlyValid();
        impl.ensureStable(raw);
        if (raw.parent is null || raw.parent.type == NodeType.Document)
            throw new ParserinoException("Can't set outerHTML of an element without a parent element");

        node.before(FragmentString(html.idup));
        node.remove();
    }

    ///
    unittest
    {
        Document d = "<html><a><p>";

        auto p = d.byTagName("p").front;
        p.outerHTML = "<div><a>";

        assert(p.localName == "p");
        assert(d.body.descendants.front.localName == "a");
    }

    /// The start tag of this element, with its attributes: `<a href="x">`
    @property string startTag()
    {
        import std.array : appender;

        onlyValid();
        impl.ensureStable(raw);
        impl.ensureAttrs(raw);

        auto app = appender!string;
        serializeTo(Serialize.Node, raw, (const(char)[] s) { app.put(s); });
        return app.data;
    }

    unittest
    {
        Document d = `<p class=a>text<b>bold`;
        assert(d.byTagName("p").front.startTag == `<p class="a">`);
    }

    /// Does this element match a css selector?
    bool matches(const(char)[] selector) { return matches(Selector(selector)); }

    /// ditto
    bool matches(Selector selector)
    {
        onlyValid();
        if (!selector.isValid) throw new ParserinoException("Invalid selector");

        if (selector.whole) impl.finish();
        impl.ensureStable(raw);
        if (selector.forward && raw.parent !is null) impl.ensureClosed(raw.parent);
        return impl.matches(raw, selector.list, raw);
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

        auto elements = res.map!(x => x.textContent).array;
        assert(elements.canFind("two"));
        assert(elements.canFind("four"));

        assert(doc.byId("this").matches("li:last-child"));
        assert(!doc.byId("this").matches("li:first-child"));

        // A compiled selector can be reused
        auto sel = Selector("ul > li");
        assert(doc.bySelector(sel).walkLength == 5);
        assert(Document("<ul><li>").bySelector(sel).walkLength == 1);
    }

    /// Replace this element with the (single) element parsed from `html`: `el = "<b>x</b>";`
    ref Element opAssign(const(char)[] html) return
    {
        if (!isValid)
            throw new ParserinoException("Can't set html for a null element");

        auto f = doc.fragment(html);
        auto children = f.children!(Show.All);
        Node first = children.frontOrInit();

        if (!first.isElement)
            throw new ParserinoException("Can't assign: the html must be a single element");

        children.popFront();

        if (!children.empty)
            throw new ParserinoException("Can't assign a fragment with more than one child");

        copyFrom(first.asElement);
        return this;
    }

    ///
    ref Element opAssign(typeof(null)) return { this = Element.init; return this; }

    ///
    ref Element opAssign(Element rhs) return
    {
        node = rhs.node;
        return this;
    }

    unittest
    {
        import std.exception;
        Element e;
        assertThrown(e = `<a href="hmm.html>blah</a>`);
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

    this(ref Document doc, DomNode* raw) { node = Node(doc, raw); }
    this(Node n) { node = n; }

    inout(DocImpl)* impl() inout { return node.doc.impl; }
    DomNode* raw() { return node.raw; }
    DomElement* element() { return node.raw.as!DomElement; }
    ref Document doc() return { return node.doc; }

    void onlyValid(string fname = __FUNCTION__) const { node.onlyValid(fname); }

    void copyImpl(Element e, bool deep)
    {
        onlyValid();
        e.onlyValid();
        impl.mutate();

        if (e.raw is raw) return;

        auto dom = impl.dom;
        while (element.firstAttr !is null) element.removeAttribute(element.firstAttr);

        // The tag too (a template needs a content)
        raw.name = e.raw.name;
        raw.ns = e.raw.ns;
        element.qualifiedName = e.element.qualifiedName;

        if (e.element.templateContent is null) element.templateContent = null;
        else if (element.templateContent is null)
        {
            element.templateContent = dom.createFragment();
            if (element.templateContent is null) throw new ParserinoException("Out of memory");
            element.templateContent.host = element;
        }

        for (auto a = e.element.firstAttr; a !is null; a = a.next)
        {
            auto na = dom.createAttribute(a.name, a.value, a.ns);
            if (na is null) throw new ParserinoException("Out of memory");
            na.qualifiedName = a.qualifiedName;
            element.appendAttribute(na);
        }

        if (!deep) return;

        node.removeChildren();

        // The copy has the children and, for a template, a copy of the content
        auto copy = dom.importNode(e.raw, true);
        if (copy is null) throw new ParserinoException("Out of memory");
        copy.moveChildrenTo(raw);
        if (auto content = copy.as!DomElement.templateContent)
        {
            auto mine = &element.templateContent.node;
            while (mine.firstChild !is null) mine.firstChild.remove();
            content.node.moveChildrenTo(mine);
        }
    }
}


/// A range of attributes. It keeps the document alive.
struct AttributeRange(bool view)
{
    ///
    @property bool empty() const @safe nothrow pure @nogc { return current is null; }

    ///
    @property auto front()
    {
        static if (view) return Element.AttributeView(current.fullName, attrValue(current));
        else return Element.Attribute(current.fullName.idup, attrValue(current).idup);
    }

    ///
    void popFront() { current = current.next; }

    ///
    @property AttributeRange save() { return this; }

    private:
    Document doc;
    DomAttribute* current;
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
        owner = cast(SelImpl*) calloc(1, SelImpl.sizeof);
        if (owner is null) throw new ParserinoException("Out of memory");

        // The compiled selector keeps slices of its text: a copy in the arena outlives the argument
        auto text = owner.arena.dup(selector);
        list = text is null && selector.length ? null : parseSelector(text, owner.arena);
        if (list is null)
        {
            owner.arena.release();
            free(owner);
            owner = null;
            throw new ParserinoException("Invalid selector: `" ~ selector.idup ~ "`");
        }

        owner.refs = 1;
        forward = list.looksForward;
        whole = list.needsDocument;
    }

    this(this) { if (owner !is null) atomicOp!"+="(owner.refs, 1); }

    ~this()
    {
        if (owner !is null && atomicOp!"-="(owner.refs, 1) == 0)
        {
            owner.arena.release();
            free(owner);
        }
        owner = null;
    }

    ///
    ref Selector opAssign(Selector rhs) return
    {
        import std.algorithm.mutation : swap;
        swap(owner, rhs.owner);
        list = rhs.list;
        forward = rhs.forward;
        whole = rhs.whole;
        return this;
    }

    /// Is this a valid (compiled) selector?
    @property bool isValid() const @safe nothrow pure @nogc { return list !is null; }

    unittest
    {
        import std.exception : assertThrown;

        assert(Selector("div p").isValid);
        assert(!Selector.init.isValid);
        assertThrown!ParserinoException(Selector("1bad"));
        assertThrown!ParserinoException(Selector(""));
    }

    private:
    SelImpl* owner;                 // null for selectors compiled at compile time
    const(SelectorList)* list;
    bool forward;                   // does it look at following siblings or at children? (:last-child, :has, ...)
    bool whole;                     // does it need the whole document? (:lang, :dir)
}

/++ A selector parsed at compile time: syntax errors are compile errors.
+ ---
+ auto links = doc.bySelector(ctSelector!"nav > a[href]");
+ auto same = doc.bySelector!"nav > a[href]";
+ ---
+/
template ctSelector(string css)
{
    static assert(isValidSelector(css), "Invalid css selector: `" ~ css ~ "`");

    private static immutable SelectorList* list = compileAtCt(css);

    Selector ctSelector()
    {
        Selector s;
        s.list = list;
        s.forward = list.looksForward;
        s.whole = list.needsDocument;
        return s;
    }
}

///
unittest
{
    Document doc = "<ul><li>a</li><li class=x>b</li></ul>";
    assert(doc.bySelector!"li.x".front.textContent == "b");
    assert(doc.bySelector(ctSelector!"ul > li:last-child").front.textContent == "b");
    static assert(!__traits(compiles, ctSelector!"div >"));
}

// Selectors follow the standard (Selectors 4 + HTML) for a static document
unittest
{
    import std.algorithm : map;
    import std.array : array;

    string[] ids(Document d, string sel) { return d.bySelector(sel).map!(e => e.id).array; }

    // Form states
    Document f = `<form>
        <input id=a disabled><input id=b>
        <fieldset id=fs disabled><legend id=lg><input id=c></legend><input id=d></fieldset>
        <select id=s><optgroup id=og disabled><option id=o1></option></optgroup><option id=o2></option></select>
        <select id=m multiple><option id=o3></option></select>
        <input id=cb type=checkbox checked><input id=r type=radio>
        <input id=ro readonly><input id=chk type=checkbox><textarea id=ta></textarea>
        <div id=ce contenteditable><span id=sp></span></div><div id=nce></div>
        <input id=ph placeholder=x><input id=ph2 placeholder=x value=v>
        </form>`;

    assert(ids(f, ":disabled") == ["a", "fs", "d", "og", "o1"]);
    assert(ids(f, "input:enabled") == ["b", "c", "cb", "r", "ro", "chk", "ph", "ph2"]);
    assert(ids(f, "div:enabled").length == 0);
    assert(ids(f, ":checked") == ["o2", "cb"]);        // o2: first enabled option of a single select
    assert(ids(f, ":read-write") == ["b", "c", "ta", "ce", "sp", "ph", "ph2"]);
    assert(ids(f, ":placeholder-shown") == ["ph"]);

    // :lang(), :scope, namespaces, pseudo-elements, states
    Document d = `<html lang=en-US><body><p id=p1>x</p><div lang=fr><p id=p2>y</p></div>
        <svg><a id=sa xlink:href=z></a><rect id="r1"/></svg><a id=ha href=h>h</a></body></html>`;

    assert(ids(d, "p:lang(en)") == ["p1"]);
    assert(ids(d, "p:lang(fr, de)") == ["p2"]);
    assert(ids(d, "p:lang('*')") == ["p1", "p2"]);
    assert(ids(d, "svg|rect") == ["r1"]);
    assert(ids(d, "html|a") == ["ha"]);
    assert(ids(d, "[xlink|href]") == ["sa"]);
    assert(ids(d, "[href]") == ["ha"]);
    assert(ids(d, "[*|href]") == ["sa", "ha"]);
    assert(ids(d, "p::before").length == 0);
    assert(ids(d, "a:hover, a:visited, :focus").length == 0);
    assert(ids(d, "a:link") == ["ha"]);
    assert(d.byTagName("div").front.bySelector(":scope > p").map!(e => e.id).array == ["p2"]);
    assert(d.byId("p1").matches(":scope"));
    assert(ids(d, ":is()").length == 0);

    // :first-child counts elements only (the doctype is not an element)
    Document dt = "<!doctype html><html><body>";
    assert(dt.bySelector("html:first-child").walkLength == 1);

    // :lang(): extended filtering (RFC 4647), xml:lang wins over lang, the <meta> default language
    Document l = `<html lang=de-Latn-DE><meta http-equiv=content-language content=it><body>
        <p id=a>x</p><p id=b lang=de-DE-1996>y</p><div lang=""><p id=c>z</p></div>
        <svg><text id=s xml:lang=fr lang=en>t</text></svg></body></html>`;
    assert(ids(l, "p:lang(de-DE)") == ["a", "b"]);
    assert(ids(l, "p:lang('*-DE')") == ["a", "b"]);
    assert(ids(l, "p:lang(de-x-DE)").length == 0);
    assert(ids(l, "text:lang(fr)") == ["s"]);
    assert(ids(l, "p:lang(it)").length == 0);
    assert(ids(l, "p:lang('*')") == ["a", "b"]);
    Document m = `<meta http-equiv="Content-Language" content="it"><p id=x>`;
    assert(ids(m, "p:lang(it)") == ["x"]);

    // :dir(): the dir attribute, dir=auto and <bdi> from the text, inherited
    Document dirs = "<body><p id=l>abc</p><div dir=rtl><p id=r>x</p><p id=l2 dir=ltr>y</p></div>"
        ~ "<p id=a1 dir=auto>\u05E9\u05DC\u05D5\u05DD</p><p id=a2 dir=auto>123 hello</p>"
        ~ "<bdi id=b1>\u0645\u0631\u062D\u0628\u0627</bdi><div dir=rtl><input id=t type=tel></div>";
    assert(ids(dirs, "p:dir(rtl), bdi:dir(rtl), input:dir(rtl)") == ["r", "a1", "b1"]);
    assert(ids(dirs, "p:dir(ltr), input:dir(ltr)") == ["l", "l2", "a2", "t"]);
    assert(ids(dirs, ":dir(up)").length == 0);

    // Names of foreign elements and attributes are case-sensitive; some html values are not
    Document cs = `<svg><clipPath id=cp viewBox="0 0 1 1"/><a id=q xlink:href=A></a></svg><p ID=x TYPE=Text>`;
    assert(ids(cs, "clipPath") == ["cp"]);
    assert(ids(cs, "clippath").length == 0);
    assert(ids(cs, "[viewBox]") == ["cp"]);
    assert(ids(cs, "[viewbox]").length == 0);
    assert(ids(cs, "P[TYPE=text]") == ["x"]);
    assert(ids(cs, "[*|href=A]") == ["q"]);
    assert(ids(cs, "[*|href=a]").length == 0);
}

unittest
{
    import core.memory : GC;

    // A selector doesn't depend on the memory of its text
    char[] text = "p.x".dup;
    auto sel = Selector(text);
    text[] = 'z';
    GC.collect();
    assert(Document("<p class=x>").bySelector(sel).walkLength == 1);

    // :lang() and :dir() give the same results with lazy parsing
    string html = `<p id=a>x</p><p id=b dir=auto>` ~ "\u05D0" ~ `</p><meta http-equiv=content-language content=fr>`;
    auto lazyDoc = Document(html, Parsing.Lazy, 4);
    assert(lazyDoc.bySelector("p:lang(fr)").walkLength == 2);
    assert(Document(html, Parsing.Lazy, 4).bySelector("p:dir(rtl)").front.id == "b");
}

// Parse at compile time, with the parse errors as text (the first 20)
private struct CheckedTree { DomSnapshot tree; string errors; }

private CheckedTree parseChecked(string html, bool scripting) pure
{
    import std.conv : to;

    RawParseError[] raw;
    CheckedTree r;
    r.tree = parseToSnapshot(html, scripting, raw);

    // In the order of the input (insertion sort: stable, and fine in CTFE for a few errors)
    foreach (i; 1 .. raw.length)
        for (size_t j = i; j > 0 && (raw[j].line < raw[j - 1].line
            || (raw[j].line == raw[j - 1].line && raw[j].column < raw[j - 1].column)); j--)
        {
            auto t = raw[j];
            raw[j] = raw[j - 1];
            raw[j - 1] = t;
        }

    foreach (i, e; raw)
    {
        if (i == 20) { r.errors ~= "... (" ~ (raw.length - 20).to!string ~ " more)\n"; break; }
        r.errors ~= e.line.to!string ~ ":" ~ e.column.to!string ~ ": " ~ errorName(e.code) ~ "\n";
    }
    return r;
}

/// Is this a valid css selector? It works at compile time too.
bool isValidSelector(const(char)[] css) @nogc nothrow
{
    Arena a;
    return parseSelector(css, a) !is null;
}

private const(SelectorList)* compileAtCt(string css) pure
{
    Arena a;
    return parseSelector(css, a);
}

/++ A document parsed at compile time.
+ The compiler parses `html` once and stores the tree in the executable. At runtime each call
+ returns a new document (mutable, independent from the others) copied from that tree, without
+ tokenizing or building it again.
+ ---
+ auto page = ctDocument!(import("page.html"));   // needs -J with the path of page.html
+ page.byId("title").textContent = "Hello";
+ ---
+ With `options.collectErrors` the html is validated at compile time: any parse error is a
+ compile error that lists them. The other options don't matter here.
+ ---
+ enum ParseOptions strict = { collectErrors: true };
+ auto page = ctDocument!(import("page.html"), strict);   // doesn't compile if page.html is not valid html
+ ---
+ CTFE needs a lot of compiler memory: it's fine for templates of some tens of KB, not for big pages.
+/
template ctDocument(string html, ParseOptions options = ParseOptions.init)
{
    static if (options.collectErrors)
    {
        private enum checked = parseChecked(html, options.scripting);
        static assert(checked.errors.length == 0, "Invalid html in ctDocument:\n" ~ checked.errors);
        private static immutable DomSnapshot tree = checked.tree;
    }
    else private static immutable DomSnapshot tree = parseToSnapshot(html, options.scripting);

    Document ctDocument()
    {
        Document d;
        d.impl = DocImpl.create();
        scope(failure) { DocImpl.release(d.impl); d.impl = null; }

        if (!tree.restore(d.impl.dom)) throw new ParserinoException("Out of memory");
        d.impl.fed = html.length;
        return d;
    }
}

///
unittest
{
    enum html = "<!DOCTYPE html><title>Hi</title><p class=a>Hello <b>world</p>!<table><td>x";

    auto doc = ctDocument!html;
    assert(doc.toString == Document(html).toString);
    assert(doc.title == "Hi");
    assert(doc.body.firstChild!(Show.All).textContent == "Hello world");
    assert(doc.bySelector!"td".front.textContent == "x");

    // Each call returns a new document
    doc.body.innerHTML = "changed";
    assert(ctDocument!html.body.innerHTML != "changed");

    enum ParseOptions scripting = { scripting: true };
    assert(ctDocument!("<noscript><p>x</p></noscript>", scripting).byTagName("p").empty);

    // Validated at compile time
    enum ParseOptions strict = { collectErrors: true };
    assert(ctDocument!("<!DOCTYPE html><title>ok</title><p>valid", strict).title == "ok");
    static assert(!__traits(compiles, ctDocument!("<!DOCTYPE html><p>x</b>", strict)));
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

/// Get the first element of a range, or its `init` (an invalid node for the ranges of nodes)
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

    assert(doc.bySelector("p b").frontOrThrow.localName == "b");
    assert(doc.bySelector("p b").frontOrInit.localName == "b");

    assertThrown(doc.bySelector("p i").frontOrThrow);
    assert(doc.bySelector("p i").frontOrInit == Element());
    assert(doc.bySelector("p i").frontOrInit == null);
    assert(doc.bySelector("p i").frontOr(div).localName == "div");
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
/++ A lazy range of nodes in tree order: `descendants`, `children`, `byTagName`, `byClass`,
+ `bySelector`, ... return it. It's a bidirectional range: `save` gives an independent copy,
+ `back`/`popBack` (and so `retro`) go in reverse document order. The elements are `Element`s
+ if `show` is `Show.Element`, else `Node`s.
+/
struct NodeRange(Filter, Show show)
{
    ///
    @property bool empty() { prime(); return current is null; }

    ///
    @property NodeOf!show front()
    {
        prime();
        if (current is null) throw new ParserinoException("Range is empty.");
        return NodeOf!show(doc, current);
    }

    ///
    void popFront()
    {
        prime();
        if (current is null) throw new ParserinoException("Range is empty.");
        if (current is last) current = last = null;
        else current = seek(current);
    }

    ///
    @property NodeOf!show back()
    {
        primeBack();
        if (last is null) throw new ParserinoException("Range is empty.");
        return NodeOf!show(doc, last);
    }

    ///
    void popBack()
    {
        primeBack();
        if (last is null) throw new ParserinoException("Range is empty.");
        if (current is last) current = last = null;
        else last = seekBack(last);
    }

    ///
    @property typeof(this) save() { return this; }

    private:

    Document doc;
    DomNode* root;
    DomNode* current;       // the front (null: empty)
    DomNode* last;          // the back, once known (null: not known yet, or empty)
    bool deep;
    bool primed;
    bool primedBack;
    Filter filter;

    this(ref Document doc, DomNode* root, bool deep, Filter filter)
    {
        this.doc = doc;
        this.root = root;
        this.deep = deep;
        this.filter = filter;
    }

    // Start the visit after `from` instead of from the beginning.
    void start(DomNode* from) { primed = true; current = seek(from); }

    void prime()
    {
        if (primed) return;
        primed = true;
        if (filter.wholeDocument) doc.impl.finish();
        current = seek(root);
    }

    // The back needs the whole subtree: from then on the range knows both ends
    void primeBack()
    {
        prime();
        if (primedBack) return;
        primedBack = true;
        if (current is null) return;

        doc.impl.ensureClosed(root);
        last = seekBack(root);

        // The front could be after the back only if the range is empty
        if (last is null) current = null;
    }

    // The next node after `pos` accepted by the filter.
    DomNode* seek(DomNode* pos)
    {
        auto d = doc.impl;

        while (true)
        {
            auto next = stepForward(d, pos);

            if (next is waitSentinel) { d.advance(); continue; }
            if (next is null) return null;

            if (d.parsing && !passable(d, next)) { d.advance(); continue; }

            pos = next;
            if (accepted(d, next)) return next;
        }
    }

    // The previous node before `pos` (in tree order) accepted by the filter; `root` means from the end.
    DomNode* seekBack(DomNode* pos)
    {
        auto d = doc.impl;

        while (true)
        {
            pos = pos is root ? lastInTree(root) : stepBackward(pos);
            if (pos is null || pos is root) return null;
            if (accepted(d, pos)) return pos;
        }
    }

    bool accepted(DocImpl* d, DomNode* n) { return shown(show, n) && filter.match(d, n); }

    // The next node in tree order. It returns `waitSentinel` if the parser could still add it.
    DomNode* stepForward(DocImpl* d, DomNode* pos)
    {
        if (deep || pos is root)
        {
            if (pos.firstChild !is null) return pos.firstChild;
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

    // The last node of the range in tree order (the deepest last descendant), or null
    DomNode* lastInTree(DomNode* r)
    {
        auto n = r.lastChild;
        if (n is null) return null;
        if (deep) while (n.lastChild !is null) n = n.lastChild;
        return n;
    }

    // The previous node in tree order; `root` (or null) at the beginning
    DomNode* stepBackward(DomNode* pos)
    {
        if (pos.prev !is null)
        {
            auto n = pos.prev;
            if (deep) while (n.lastChild !is null) n = n.lastChild;
            return n;
        }

        if (!deep) return null;
        return pos.parent;
    }

    // Can the walker go past this node, or could the parser still change it?
    bool passable(DocImpl* d, DomNode* n)
    {
        if (!d.isStable(n)) return false;

        // Selectors like :last-child or :has() need all the siblings
        if (filter.strict && n.parent !is null && d.isOpen(n.parent)) return false;

        // A later <html> or <body> tag can still add attributes to these elements
        if (isRootElement(n) && (Filter.attrSensitive || filter.match(d, n)) && !d.rootAttrsFinal()) return false;

        return true;
    }
}

// The result of a navigation with this filter: `Element` only for elements
template NodeOf(Show show)
{
    static if (show == Show.Element) alias NodeOf = Element;
    else alias NodeOf = Node;
}

// Does the filter accept this node?
bool shown(Show show, const(DomNode)* n) @safe nothrow pure @nogc { return ((1u << (n.type - 1)) & show) != 0; }


private:

// ---------------------------------------------------------------- filters

struct AnyFilter
{
    enum attrSensitive = true;
    enum strict = false;
    enum wholeDocument = false;
    bool match(DocImpl*, DomNode*) { return true; }
}

struct TagFilter
{
    enum attrSensitive = false;
    enum strict = false;
    enum wholeDocument = false;

    string name;
    uint id = Tag.Undef;
    size_t generation = size_t.max;

    bool match(DocImpl* d, DomNode* n)
    {
        if (name == "*") return true;

        // Unknown tags get an id when the parser meets them: retry after each parsed chunk
        if (id == Tag.Undef && generation != d.generation)
        {
            id = d.dom.findTagName(name);
            generation = d.generation;
        }

        return id != Tag.Undef && n.name == id;
    }
}

struct ClassFilter
{
    enum attrSensitive = true;
    enum strict = false;
    enum wholeDocument = false;

    string name;

    bool match(DocImpl*, DomNode* n)
    {
        auto a = n.as!DomElement.classAttr;
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
    enum wholeDocument = false;

    const(char)[] id;

    bool match(DocImpl*, DomNode* n)
    {
        auto a = n.as!DomElement.idAttr;
        return a !is null && attrValue(a) == id;
    }
}

struct CommentFilter
{
    enum attrSensitive = false;
    enum strict = false;
    enum wholeDocument = false;

    string comment;
    bool stripSpaces;

    this(string comment, bool stripSpaces)
    {
        import std.string : strip;
        this.comment = stripSpaces ? comment.strip : comment;
        this.stripSpaces = stripSpaces;
    }

    bool match(DocImpl*, DomNode* n)
    {
        import std.string : strip;

        if (n.type != NodeType.Comment) return false;

        auto cd = n.as!DomCharacterData;
        auto text = cd.data;
        return (stripSpaces ? text.strip : text) == comment;
    }
}

struct SelectorFilter
{
    enum attrSensitive = true;

    Selector selector;

    @property bool strict() const { return selector.forward; }
    @property bool wholeDocument() const { return selector.whole; }

    DomNode* scope_;     // the root of the query, for :scope

    bool match(DocImpl* d, DomNode* n)
    {
        // The bloom filter only on a parsed document: while parsing, the attributes of <html> and
        // <body> can still change
        if (!d.parsing && !mayMatch(d, n)) return false;
        return d.matches(n, selector.list, scope_);
    }

    private:

    /+ A bloom filter of the ancestors, as in the browsers: for `div p a`, an `a` can match only
     + if its ancestors have the keys `div` and `p` (tags, ids, classes of the compounds on the
     + left of a descendant or child combinator). The filters of the chain of ancestors are kept
     + while the range goes on in tree order.
     +/
    enum Capacity = 32;
    Bloom[] required;               // for each selector of the list; empty: the filter can't help
    bool prepared;
    bool needIds, needClasses;      // only the kinds of keys the selectors look for are hashed
    size_t mutations;
    size_t pathLength;
    size_t bloomsValid;             // the filters of pathNodes[0 .. bloomsValid] are computed
    DomNode*[Capacity] pathNodes;
    Bloom[Capacity] pathBlooms;     // the keys of the node and of all its ancestors

    bool mayMatch(DocImpl* d, DomNode* n)
    {
        if (!prepared) prepare();
        if (required.length == 0) return true;

        if (d.mutations != mutations) { pathLength = bloomsValid = 0; mutations = d.mutations; }

        // The chain up to the parent: the nodes come in tree order, so it's on the path
        auto p = n.parent;
        while (pathLength && pathNodes[pathLength - 1] !is p) pathLength--;
        if (bloomsValid > pathLength) bloomsValid = pathLength;
        bool known = pathLength > 0 || p is null || p.type != NodeType.Element || rebuild(p);

        size_t parentIndex = pathLength;    // the parent is at parentIndex - 1
        if (pathLength < Capacity) pathNodes[pathLength++] = n;
        if (!known) return true;

        // First the last compound (cheap), then the ancestors: only for the candidates
        bool candidate = false;
        foreach (i, ref r; required)
            if (parserino.css.matcher.matchesLastCompound(selector.list, i, n, scope_)) { candidate = true; break; }
        if (!candidate) return false;
        if (parentIndex == 0) return true;

        // The filters of the chain, computed only when needed
        foreach (i; bloomsValid .. parentIndex)
        {
            pathBlooms[i] = i ? pathBlooms[i - 1] : Bloom.init;
            addKeys(pathBlooms[i], pathNodes[i], needIds, needClasses);
        }
        if (bloomsValid < parentIndex) bloomsValid = parentIndex;

        foreach (i, ref r; required)
            if (pathBlooms[parentIndex - 1].covers(r) && parserino.css.matcher.matchesLastCompound(selector.list, i, n, scope_))
                return true;
        return false;
    }

    // The chain of nodes from the root element to `p`; false if it's deeper than the capacity
    bool rebuild(DomNode* p)
    {
        size_t depth = 0;
        for (auto a = p; a !is null && a.type == NodeType.Element; a = a.parent) depth++;
        if (depth > Capacity) return false;

        pathLength = depth;
        bloomsValid = 0;
        auto a = p;
        foreach_reverse (i; 0 .. depth)
        {
            pathNodes[i] = a;
            a = a.parent;
        }
        return true;
    }

    static void addKeys(ref Bloom b, DomNode* n, bool ids, bool classes)
    {
        b.add(Bloom.tagKey(n.name));
        auto e = n.as!DomElement;
        if (ids && e.idAttr !is null) b.add(Bloom.key('#', attrValue(e.idAttr)));
        if (classes && e.classAttr !is null)
        {
            auto v = attrValue(e.classAttr);
            size_t i = 0;
            while (i < v.length)
            {
                while (i < v.length && isHtmlSpace(v[i])) i++;
                size_t start = i;
                while (i < v.length && !isHtmlSpace(v[i])) i++;
                if (i > start) b.add(Bloom.key('.', v[start .. i]));
            }
        }
    }

    // The keys each selector of the list needs in the ancestors
    void prepare()
    {
        import parserino.css.selector : SimpleKind, Combinator, NsMatch;

        prepared = true;
        Bloom[] r;
        foreach (ref item; selector.list.items)
        {
            Bloom need;
            bool any = false;
            auto cs = item.compounds;
            foreach_reverse (i; 1 .. cs.length)
            {
                if (cs[i].combinator != Combinator.Descendant && cs[i].combinator != Combinator.Child) continue;
                foreach (ref x; cs[i - 1].simples)
                {
                    switch (x.kind)
                    {
                        case SimpleKind.Type:
                            if (x.knownId && (x.ns == NsMatch.Any || x.ns == NsMatch.Html)) { need.add(Bloom.tagKey(x.knownId)); any = true; }
                            break;
                        case SimpleKind.Id: need.add(Bloom.key('#', x.name)); any = needIds = true; break;
                        case SimpleKind.Class: need.add(Bloom.key('.', x.name)); any = needClasses = true; break;
                        default: break;
                    }
                }
            }

            // A selector with nothing to look for in the ancestors: the filter can't reject anything
            if (!any) return;
            r ~= need;
        }
        required = r;
    }
}

// 256 bits, 2 per key. Ids and classes are hashed in ASCII lowercase: in quirks mode they are
// case-insensitive (a false positive only costs the full match).
struct Bloom
{
    ulong[4] bits;

    void add(uint h) nothrow @nogc
    {
        bits[(h & 0xFF) >> 6] |= 1UL << (h & 63);
        h >>= 8;
        bits[(h & 0xFF) >> 6] |= 1UL << (h & 63);
    }

    bool covers(ref const Bloom need) const nothrow @nogc
    {
        foreach (i; 0 .. 4) if ((bits[i] & need.bits[i]) != need.bits[i]) return false;
        return true;
    }

    static uint key(char kind, scope const(char)[] s) nothrow @nogc
    {
        uint h = 2166136261u ^ kind;
        foreach (c; s) { h ^= c >= 'A' && c <= 'Z' ? c | 0x20 : c; h *= 16777619u; }
        return h ^ (h >> 16);
    }

    static uint tagKey(uint id) nothrow @nogc
    {
        uint h = (id + 1) * 2654435761u;
        return h ^ (h >> 15);
    }
}


// ---------------------------------------------------------------- document state

__gshared DomNode waitSentinelNode;
@property DomNode* waitSentinel() @trusted nothrow @nogc { return &waitSentinelNode; }

struct DocImpl
{
    shared size_t refs;
    DomDocument* dom;

    // Incremental parsing
    bool parsing;
    Parser* parser;
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
    NodeList selects;       // open selects: they can fill their <selectedcontent>

    // The snapshot this document was restored from: the document uses its strings
    immutable(DomSnapshot)* snapshot;

    // The parse errors (see `ParseOptions.collectErrors`)
    bool collectErrors;
    Buffer!RawParseError errors;

    // byId: an index of the ids, valid while `mutations` doesn't change
    size_t mutations;
    size_t idSearches;
    IdIndex ids;

    static DocImpl* create()
    {
        auto d = cast(DocImpl*) calloc(1, DocImpl.sizeof);
        if (d is null) throw new ParserinoException("Out of memory");
        *d = DocImpl.init;
        d.refs = 1;

        d.dom = cast(DomDocument*) calloc(1, DomDocument.sizeof);
        if (d.dom is null) { free(d); throw new ParserinoException("Out of memory"); }
        d.dom.initialize();
        return d;
    }

    void retain() { atomicOp!"+="(refs, 1); }

    static void release(DocImpl* d)
    {
        if (atomicOp!"-="(d.refs, 1) != 0) return;

        if (d.parser !is null) freeParser(d.parser);
        if (d.source !is null) free(d.source);
        d.dom.release();
        free(d.dom);
        d.tables.dispose();
        d.formatting.dispose();
        d.selects.dispose();
        destroy(d.errors);
        d.ids.dispose();
        if (d.snapshot !is null)
        {
            import core.memory : GC;
            GC.removeRoot(cast(void*) d.snapshot);
        }
        free(d);
    }

    // Keep a snapshot alive (the GC doesn't see this malloc'd struct)
    void keepSnapshot(immutable(DomSnapshot)* s)
    {
        import core.memory : GC;
        GC.addRoot(cast(void*) s);
        snapshot = s;
    }

    void parseAll(const(char)[] input)
    {
        fed = input.length;
        if (!collectErrors)
        {
            if (!parseDocument(dom, input)) throw new ParserinoException("Can't parse the document (out of memory)");
            return;
        }

        auto p = newParser();
        if (p is null) throw new ParserinoException("Out of memory");
        scope(exit) freeParser(p);

        p.begin(dom);
        p.tokenizer.collectErrors = true;
        bool ok = p.feed(input) && p.finish();
        errors.put(p.tokenizer.errors[]);
        if (!ok || errors.failed) throw new ParserinoException("Can't parse the document (out of memory)");
    }

    void beginLazy(const(char)[] input, size_t chunk)
    {
        parser = newParser();
        if (parser is null) throw new ParserinoException("Out of memory");
        parser.begin(dom);
        parser.tokenizer.collectErrors = collectErrors;

        source = cast(ubyte*) malloc(input.length + 1);
        if (source is null) throw new ParserinoException("Out of memory");
        memcpy(source, input.ptr, input.length);

        sourceLength = input.length;
        chunkSize = chunk;
        parsing = true;
    }

    // Before a change of the tree: the parsing ends, the index of the ids is no longer valid
    void mutate()
    {
        finish();
        mutations++;
    }

    // The first element with this id, in tree order (the document must be parsed)
    DomElement* elementById(scope const(char)[] id)
    {
        if (!ids.built || ids.version_ != mutations)
        {
            ids.clear();
            for (auto n = dom.node.firstChild; n !is null; n = n.nextInTree(&dom.node))
            {
                if (n.type != NodeType.Element) continue;
                auto a = n.as!DomElement.idAttr;
                if (a !is null) ids.add(attrValue(a), n.as!DomElement);
            }
            ids.built = true;
            ids.version_ = mutations;
        }
        return ids.find(id);
    }

    // Parse one more chunk. It returns false if the parsing is already complete.
    bool advance()
    {
        if (!parsing) return false;

        import std.algorithm : min;
        auto n = min(chunkSize, sourceLength - fed);
        if (n > 0)
        {
            bool ok = parser.feed(cast(const(char)[]) source[fed .. fed + n]);
            fed += n;
            generation++;
            if (!ok) { endParsing(); throw new ParserinoException("Can't parse the document (out of memory)"); }
        }

        if (fed == sourceLength) finish();
        return true;
    }

    // Complete the parsing
    void finish()
    {
        if (!parsing) return;

        bool ok = true;
        if (fed < sourceLength) ok = parser.feed(cast(const(char)[]) source[fed .. sourceLength]);
        fed = sourceLength;

        ok = endParsing() && ok;
        if (!ok) throw new ParserinoException("Can't parse the document (out of memory)");
    }

    bool endParsing()
    {
        auto ok = parser.finish();
        if (collectErrors) errors.put(parser.tokenizer.errors[]);
        freeParser(parser);
        parser = null;
        parsing = false;
        generation++;
        free(source);
        source = null;
        tables.clear();
        formatting.clear();
        selects.clear();
        return ok;
    }

    ref TreeBuilder tree() { return parser.tree; }

    // Is the node still open (the parser can add children to it)?
    bool isOpen(const(DomNode)* n)
    {
        if (!parsing) return false;
        if (n.type == NodeType.Document) return n is &dom.node;
        if (n.type != NodeType.Element) return false;

        // In the "after head" insertion mode the parser puts <head> back on the stack
        // for <script>, <style>, <meta>, ...: it can get children until <body> exists.
        auto head = dom.head;
        if (head !is null && n is &head.node && dom.body is null) return true;

        auto oe = tree.openElements[];
        foreach_reverse (e; oe)
            if (e is n) return true;

        // A <selectedcontent> gets a copy of the selected option when the options end
        if (n.ns == Ns.Html && n.name == Tag.Selectedcontent)
        {
            refreshVolatile();
            if (selects.length) return true;
        }

        return false;
    }

    void refreshVolatile()
    {
        if (volatileGeneration == generation) return;
        volatileGeneration = generation;

        tables.clear();
        formatting.clear();
        selects.clear();

        auto oe = tree.openElements[];
        auto af = tree.activeFormatting[];

        foreach (n; oe)
        {
            if (n.ns == Ns.Html && n.name == Tag.Table) tables.add(n);
            else if (n.ns == Ns.Html && n.name == Tag.Select) selects.add(n);
            else
            {
                foreach (f; af)
                    if (f is n) { formatting.add(n); break; }
            }
        }
    }

    /+ Is the node in its final position?
     + - foster parenting inserts content before the open tables
     + - the adoption agency moves the descendants of the open formatting elements
     + - a <frameset> can still replace <body> while `frameset_ok` is set
     + - the last text node can still grow
     + - the content of a <selectedcontent> is replaced while its select is open
     +/
    bool isStable(DomNode* n)
    {
        if (!parsing) return true;

        refreshVolatile();

        auto b = dom.body;
        auto body = b is null ? null : &b.node;
        bool framesetOk = tree.framesetOk && body !is null;

        if (tables.length || formatting.length || framesetOk || selects.length)
        {
            for (auto a = n; a !is null; a = a.parent)
            {
                if (tables.contains(a)) return false;
                if (a !is n && formatting.contains(a)) return false;
                if (framesetOk && a is body) return false;
                // The content of a <selectedcontent> is replaced when an option is selected
                if (a !is n && selects.length && a.ns == Ns.Html && a.name == Tag.Selectedcontent) return false;
            }
        }

        if (n.type == NodeType.Text)
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

    void ensureStable(DomNode* n) { while (parsing && !isStable(n)) advance(); }
    void ensureClosed(DomNode* n) { while (parsing && (isOpen(n) || !isStable(n))) advance(); }
    void ensureAttrs(DomNode* n) { if (isRootElement(n)) while (parsing && !rootAttrsFinal()) advance(); }

    bool matches(DomNode* n, const(SelectorList)* list, DomNode* scope_)
    {
        return parserino.css.matcher.matches(list, n, scope_);
    }
}

// The ids of a document: open addressing, the first element for each id (malloc'd)
struct IdIndex
{
    static struct Entry { const(char)[] id; DomElement* element; }

    Entry* slots;
    size_t capacity;        // a power of 2
    size_t count;
    bool built;
    size_t version_;

    static size_t hash(scope const(char)[] s) nothrow @nogc
    {
        size_t h = 14695981039346656037UL;
        foreach (c; s) { h ^= c; h *= 1099511628211UL; }
        return h;
    }

    void add(const(char)[] id, DomElement* e)
    {
        if ((count + 1) * 2 > capacity) grow();
        auto mask = capacity - 1;
        for (auto i = hash(id) & mask; ; i = (i + 1) & mask)
        {
            if (slots[i].element is null) { slots[i] = Entry(id, e); count++; return; }
            if (slots[i].id == id) return;      // the first one in tree order stays
        }
    }

    DomElement* find(scope const(char)[] id) nothrow @nogc
    {
        if (capacity == 0) return null;
        auto mask = capacity - 1;
        for (auto i = hash(id) & mask; slots[i].element !is null; i = (i + 1) & mask)
            if (slots[i].id == id) return slots[i].element;
        return null;
    }

    void grow()
    {
        auto old = slots[0 .. capacity];
        auto n = capacity == 0 ? 64 : capacity * 2;
        auto p = cast(Entry*) calloc(n, Entry.sizeof);
        if (p is null) throw new ParserinoException("Out of memory");
        slots = p;
        capacity = n;
        count = 0;
        foreach (ref e; old) if (e.element !is null) add(e.id, e.element);
        free(old.ptr);
    }

    void clear() nothrow @nogc
    {
        if (slots !is null) foreach (ref e; slots[0 .. capacity]) e = Entry.init;
        count = 0;
        built = false;
    }

    void dispose() nothrow @nogc { free(slots); slots = null; capacity = count = 0; built = false; }
}

// A small malloc'd list of nodes
struct NodeList
{
    DomNode** ptr;
    size_t length;
    size_t capacity;

    void add(DomNode* n)
    {
        if (length == capacity)
        {
            auto c = capacity == 0 ? 8 : capacity * 2;
            auto p = cast(DomNode**) realloc(ptr, c * (DomNode*).sizeof);
            if (p is null) throw new ParserinoException("Out of memory");
            ptr = p;
            capacity = c;
        }

        ptr[length++] = n;
    }

    bool contains(const(DomNode)* n) const nothrow @nogc
    {
        foreach (i; 0 .. length) if (ptr[i] is n) return true;
        return false;
    }

    void clear() nothrow @nogc { length = 0; }
    void dispose() nothrow @nogc { free(ptr); ptr = null; length = capacity = 0; }
}

bool isRootElement(const(DomNode)* n) nothrow @nogc
{
    return n.type == NodeType.Element && n.ns == Ns.Html
        && (n.name == Tag.Html || n.name == Tag.Body);
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
    enum S { BeforeName, Name, AfterName, BeforeValue, Dq, Sq, Unquoted, AfterQuoted, SelfClosing }
    S st = S.BeforeName;

    // The tag name state: whitespace, '/' or '>' ends it
    if (s[i] == '>') return i + 1;
    if (s[i] == '/') st = S.SelfClosing;
    i++;

    for (; i < s.length; i++)
    {
        char c = s[i];
        bool ws = isHtmlSpace(c);

        final switch (st)
        {
            case S.BeforeName:
                if (ws) break;
                if (c == '/' || c == '>') { st = S.AfterName; i--; break; }
                st = S.Name;
                break;

            case S.Name:
                if (ws || c == '/' || c == '>') { st = S.AfterName; i--; break; }
                if (c == '=') st = S.BeforeValue;
                break;

            case S.AfterName:
                if (ws) break;
                if (c == '/') { st = S.SelfClosing; break; }
                if (c == '=') { st = S.BeforeValue; break; }
                if (c == '>') return i + 1;
                st = S.Name;
                break;

            case S.BeforeValue:
                if (ws) break;
                if (c == '"') { st = S.Dq; break; }
                if (c == '\'') { st = S.Sq; break; }
                if (c == '>') return i + 1;
                st = S.Unquoted;
                break;

            case S.Dq:
                if (c == '"') st = S.AfterQuoted;
                break;

            case S.Sq:
                if (c == '\'') st = S.AfterQuoted;
                break;

            case S.Unquoted:
                if (ws) { st = S.BeforeName; break; }
                if (c == '>') return i + 1;
                break;

            case S.AfterQuoted:
                if (ws) { st = S.BeforeName; break; }
                if (c == '/') { st = S.SelfClosing; break; }
                if (c == '>') return i + 1;
                st = S.BeforeName; i--;
                break;

            case S.SelfClosing:
                if (c == '>') return i + 1;
                st = S.BeforeName; i--;
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
}


// ---------------------------------------------------------------- helpers

const(char)[] attrValue(const(DomAttribute)* a) nothrow @nogc
{
    return a.value is null ? "" : a.value;
}

// The attribute with this (qualified) name, ASCII case-insensitive
DomAttribute* attributeByName(DomElement* e, scope const(char)[] name) nothrow @nogc
{
    for (auto a = e.firstAttr; a !is null; a = a.next)
    {
        auto n = a.fullName;
        if (n.length != name.length) continue;

        bool same = true;
        foreach (i, c; n)
        {
            char d = name[i];
            if (d >= 'A' && d <= 'Z') d |= 0x20;
            if ((c >= 'A' && c <= 'Z' ? cast(char) (c | 0x20) : c) != d) { same = false; break; }
        }
        if (same) return a;
    }
    return null;
}

// Serialize a node to a sink
void serializeTo(Serialize what, DomNode* node, scope void delegate(const(char)[]) sink)
{
    parserino.html.serializer.serialize(node, sink, what);
}

/++ Parse `html` in the context of `context` (an element of `doc`) into a new document fragment.
 + The context decides the parsing (see `Document.fragment`); the template contents too.
 +/
DomDocumentFragment* parseToFragment(DomDocument* doc, DomElement* context, const(char)[] html)
{
    auto root = parseFragment(doc, context, html);
    auto f = root is null ? null : doc.createFragment();
    if (f is null) throw new ParserinoException("Can't parse the fragment (out of memory)");
    root.node.moveChildrenTo(&f.node);
    return f;
}
