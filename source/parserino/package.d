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

module parserino;

import parserino.c.lexbor;
import std.string : representation;
import std.conv : to;
import std.experimental.logger;
import core.atomic;
import std.algorithm : splitter, filter, map, canFind;
import core.thread : Fiber;

enum VisitOrder
{
    Normal,
    Reverse
}

/// The HTML5 Document
struct Document
{
    /// C-tor
    this(const string html) { parse(html); }

    bool opEquals(const typeof(null) o) const @safe nothrow pure { return !isValid; }
    bool opEquals(D = Document)(const auto ref D d) const
    {
        import std.traits : isSomeString;

        static if(isSomeString!D) return isValid && this.toString == d;
        else
        {
            size_t invalid = 0;
            if (!d.isValid) invalid++;
            if (!isValid) invalid++;

            if (invalid == 1) return false;
            else if (invalid == 0) return d.payload.document == this.payload.document;
            else return true;
        }
    }

    /// Is this a valid html5 document?
    @property pure @safe nothrow bool isValid() const { return payload != null && payload.document != null; }

    ///
    unittest
    {
        version(DigitalMars) scope(exit) assert(Document.RefCounter.refs.length == 0);
        version(DigitalMars) scope(exit) assert(Element.RefCounter.refs.length == 0);

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

        assert(Document.RefCounter.refs.length == 1);
        assert(Document.RefCounter.refs[doc.payload] == 2);

    }

    /// Recreate the document from source
    private void parse(const string html)
    {
        if(payload != null)
            RefCounter.remove(payload);

        payload = new DocumentPayload();

        with(payload)
        {
            document = lxb_html_document_create();
            parser = lxb_css_parser_create();
            lxb_css_parser_init(parser, null, null);
        }

        Document.RefCounter.add(payload);

        lxb_html_document_clean(payload.document);
        CallWithLexborString!lxb_html_document_parse(payload.document, html);
    }

    /// Return document as html string
    string toString() const
    {
        extern(C) lxb_status_t cb(const lxb_char_t *data, size_t len, void *ctx)
        {
            *(cast(string*)ctx) ~= cast(string)data[0..len];
            return lexbor_status_t.LXB_STATUS_OK;
        }

        string output;

        lxb_html_serialize_tree_cb(cast(lxb_dom_node*)&(payload.document.dom_document.node), &cb, &output);
        return output;
    }

    unittest
    {
        version(DigitalMars) scope(exit) assert(Document.RefCounter.refs.length == 0);
        version(DigitalMars) scope(exit) assert(Element.RefCounter.refs.length == 0);

        Document doc;
        doc.parse("<html>");
        assert(doc == "<html><head></head><body></body></html>");
    }

    /// The content of <title>
    @property string title() { return titleImpl(false); }
    @property string rawTitle() { return titleImpl(true); }

    /// Set the content of <title>
    @property void title(const string s) { CallWithLexborString!lxb_html_document_title_set(payload.document, s); }

    unittest
    {
        version(DigitalMars) scope(exit) assert(Document.RefCounter.refs.length == 0);
        version(DigitalMars) scope(exit) assert(Element.RefCounter.refs.length == 0);

        Document doc = Document("<html><head><title>Hello World!&gt;");
        assert(doc.title == "Hello World!>");

        doc.title = "Goodbye";
        assert(doc.title == "Goodbye");
    }

    /// Create a html element
    Element createElement(string tagName) { return Element(payload, lxb_dom_document_create_element(&(payload.document.dom_document), tagName.representation.ptr, tagName.representation.length, null)); }

    /// Create a text element
    Element createText(string text) { Element e = createElement("#text"); e.innerText = text; return e; }

    /// Create a comment
    Element createComment(string text) {  Element e = createElement("!--"); e.innerText = text; return e; }

    ///
    unittest
    {
        version(DigitalMars) scope(exit) assert(Document.RefCounter.refs.length == 0);
        version(DigitalMars) scope(exit) assert(Element.RefCounter.refs.length == 0);


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
        version(DigitalMars) scope(exit) assert(Document.RefCounter.refs.length == 0);
        version(DigitalMars) scope(exit) assert(Element.RefCounter.refs.length == 0);

        Document doc = Document("<html>");
        Element e = doc.createElement("title");

        assert(e.isValid);

        auto html = doc;
        assert(html == "<html><head></head><body></body></html>");
    }

    /// The <body> element
    @property Element body() { return Element(payload, cast(lxb_dom_element_t*)lxb_html_document_body_element_noi(payload.document)); }

    /// The <head> element
    @property Element head() { return Element(payload, cast(lxb_dom_element_t*)lxb_html_document_head_element_noi(payload.document)); }

    unittest
    {
        version(DigitalMars) scope(exit) assert(Document.RefCounter.refs.length == 0);
        version(DigitalMars) scope(exit) assert(Element.RefCounter.refs.length == 0);

        Document doc = Document("<html><body>Text");

        assert(doc.head.isValid());
        assert(doc.body.isValid());
        assert(doc.body.innerText == "Text");
    }

    /// Get an element by id
    Element byId(string id) { auto range =  Element(payload, payload.document.dom_document.element).byId(id); return range; }

    /// A lazy range of elements filtered by class
    auto byClass(string name) { auto range =  Element(payload, payload.document.dom_document.element).byClass(name); return range; }

    /// A lazy range of elements filtered by tag name
    auto byTagName(string name) { auto range = Element(payload, payload.document.dom_document.element).byTagName(name); return range; }

    /// A lazy range of elements filtered by comment text
    auto byComment(string comment) { auto range =  Element(payload, payload.document.dom_document.element).byComment(comment); return range; }

    /// A lazy range of elements filtered using a css selector
    auto bySelector(string selector) { auto range =  Element(payload, payload.document.dom_document.element).bySelector(selector); return range; }

    this(ref return scope typeof(this) rhs)
    {
        if (rhs.payload == null) return;
        payload = rhs.payload;

        RefCounter.add(payload);
    }

    auto opAssign(const string html)
    {
        if(payload != null)
            RefCounter.remove(payload);

        payload = null;

        parse(html);
    }

    auto opAssign(typeof(null) n)
    {
        if(payload != null)
            RefCounter.remove(payload);

        payload = null;
    }

    auto opAssign(typeof(this) rhs)
    {
        auto oldPayload = payload;
        payload = rhs.payload;

        if (payload != null)
            RefCounter.add(payload);

        if (oldPayload != null)
            RefCounter.remove(oldPayload);

        return this;
    }

    auto opCast(string)() const { return toString(); }

    unittest
    {
        version(DigitalMars) scope(exit) assert(Document.RefCounter.refs.length == 0);
        version(DigitalMars) scope(exit) assert(Element.RefCounter.refs.length == 0);

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
        version(DigitalMars) scope(exit) assert(Document.RefCounter.refs.length == 0);
        version(DigitalMars) scope(exit) assert(Element.RefCounter.refs.length == 0);

        Document doc = "<html><p>";
        assert(doc == "<html><head></head><body><p></p></body></html>");

        doc = null;
        doc = "<a>";
        assert(doc == "<html><head></head><body><a></a></body></html>");
    }

    unittest
    {
        Document doc = Document("<html>");
        assert(doc.isValid);
        assert(doc != null);
        assert(Document.RefCounter.refs.length == 1);
        assert(Document.RefCounter.refs[doc.payload] == 1);

        DocumentPayload* docPayload = doc.payload;

        Document doc2 = Document("<html><p>");
        assert(Document.RefCounter.refs.length == 2);
        assert(Document.RefCounter.refs[doc2.payload] == 1);

        assert(docPayload in Document.RefCounter.refs);
        doc = doc2;
        assert(docPayload !in Document.RefCounter.refs);

        assert(Document.RefCounter.refs.length == 1);
        assert(Document.RefCounter.refs[doc2.payload] == 2);

        assert(doc == doc2);

        assert(doc.isValid);

        auto r = doc.byTagName("p");
        assert(r.empty == false);
        r.destroy();


        import core.memory : GC;
        GC.collect();

        doc = null;
        assert(doc.isValid == false);
        assert(doc == null);

        doc2 = null;
    }

    ~this() {
        if (payload == null) return;
        RefCounter.remove(payload);
    }

    /// Create a document fragment from source
    Element fragment(const string html)
    {
        Element element = createElement("div");
        auto node = cast(lxb_dom_element_t*)CallWithLexborString!lxb_html_document_parse_fragment(payload.document, element.element, html);
        return Element(payload, node);
    }

    ///
    unittest
    {
        version(DigitalMars) scope(exit) assert(Document.RefCounter.refs.length == 0);
        version(DigitalMars) scope(exit) assert(Element.RefCounter.refs.length == 0);

        Document doc = Document("<html>");
        Element e = doc.fragment("<p><b>hello</b>world");

        auto range = e.descendants();
        assert(range.front.name == "p");
        range.destroy();

        import core.memory : GC;
        GC.collect();
    }
    private:

    string titleImpl(bool raw = false)
    {
        size_t length;
        const(ubyte)* res;

        if (!raw) res = lxb_html_document_title(payload.document, &length);
        else res = lxb_html_document_title_raw(payload.document, &length);

        return cast(string)res[0..length];
    }

    DocumentPayload* payload;

    struct DocumentPayload
    {
        lxb_html_document_t* document = null;
        lxb_css_parser_t* parser = null;
    }

    struct RefCounter
    {
        static void add(DocumentPayload* resource)
        {
            //trace("ADD +1 document: ", resource);
            if (resource == null) return;

            auto r = (resource in refs);
            if (r is null) refs[resource] = 1;
            else atomicFetchAdd(*r, 1);
        }

        static void remove(DocumentPayload* resource)
        {
            //trace("REMOVE -1 document: ", resource);
            if (resource == null) return;

            size_t pre = atomicFetchSub(refs[resource], 1);

            if (pre == 1)
            {
                //trace("DELETED document: ", resource);
                lxb_html_document_destroy(resource.document);
                lxb_css_parser_destroy(resource.parser, true);
                refs.remove(resource);
            }
        }

        private:
        __gshared size_t[DocumentPayload*] refs;
    }

}


struct Element
{
    /// A simple key/value struct representing a html attribute
    struct Attribute
    {
        string name;
        string value;
    }

    private void onlyValidElements(string fname = __FUNCTION__) const
    {
        if (this.element == null)
            throw new Exception("Can't call `" ~ fname ~ "` for an invalid/uninitialized node");
    }

    private void onlyRealElements(string fname = __FUNCTION__)
    {
        onlyValidElements(fname);

        if (this.element.node.type != lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_ELEMENT)
            throw new Exception("Can't call `" ~ fname ~ "` for a node with type " ~ name());
    }

    /// The owner of this element
    @property Document owner()
    {
        Document doc;
        doc.payload = docPayload;
        Document.RefCounter.add(doc.payload);

        return doc;
    }

    /// Is this element empty?
    @property bool isEmpty() { onlyValidElements(); return lxb_dom_node_is_empty(&element.node); }

    unittest
    {
        version(DigitalMars) scope(exit) assert(Document.RefCounter.refs.length == 0);
        version(DigitalMars) scope(exit) assert(Element.RefCounter.refs.length == 0);

        Document doc = "<b>hello</b><br><b>";
        import std.array;
        import std.algorithm : map;
        assert(doc.body.children.map!(x => x.isEmpty()).array == [false, true, true]);
    }

    /// Is this element valid?
    @property pure @safe nothrow bool isValid() const { return element != null; }

    /// Return a lazy range of attributes for this element
    @property auto attributes()
    {
        onlyRealElements();

        class AttributeRange
        {
            AttributeRange save()
            {
                auto newRange = new AttributeRange(docPayload, element);
                newRange.current = current;
                newRange.destroyed = destroyed;
                return newRange;
            }

            Attribute front() { return Attribute(ReturnLexborString!lxb_dom_attr_local_name_noi(current), ReturnLexborString!lxb_dom_attr_value_noi(current)); }
            void popFront() { current = lxb_dom_element_next_attribute_noi(current); if (empty) unref(); }

            @property bool empty() { return current is null; }

            ~this() {
                unref();
            }

            private:

            void unref() {

                if (!destroyed)
                {
                    Element.RefCounter.remove(element);
                    Document.RefCounter.remove(docPayload);
                }

                destroyed = true;
            }

            @disable this();

            this(Document.DocumentPayload* docPayload, lxb_dom_element_t* e)
            {
                this.docPayload = docPayload;
                element = e;
                current = lxb_dom_element_first_attribute_noi(element);

                if (!empty)
                {
                    Document.RefCounter.add(docPayload);
                    Element.RefCounter.add(e);
                }
                else destroyed = true;
            }


            bool destroyed = false;
            lxb_dom_attr_t* current = null;

            Document.DocumentPayload*     docPayload;
            lxb_dom_element_t*       element;
        }

        return new AttributeRange(docPayload, element);
    }

    /// Check if an attribute exists
    @property bool hasAttribute(string attr) { onlyRealElements(); return CallWithLexborString!lxb_dom_element_has_attribute(element, attr); }

    /// Remove an attribute from this element
    @property void removeAttribute(string attr) { onlyRealElements(); CallWithLexborString!lxb_dom_element_remove_attribute(element, attr); }

    /// Set an attribute for this element
    @property void setAttribute(string name, string value) { onlyRealElements(); lxb_dom_element_set_attribute(element, name.representation.ptr, name.representation.length, value.representation.ptr, value.representation.length); }

    /// Get an attribute
    @property string getAttribute(string attr) { onlyRealElements(); return ReturnLexborString!(lxb_dom_element_get_attribute)(element, attr.representation.ptr, attr.representation.length); }

    /// The id of this element (if present)
    @property string id()
    {
        onlyRealElements();
        if (element.attr_id == null) return string.init;
        return ReturnLexborString!lxb_dom_attr_value_noi(element.attr_id);
    }

    /// All the classes of this element
    @property auto classes()
    {
        onlyRealElements();
        if (element.attr_class == null) return string.init.splitter(" ");
        return ReturnLexborString!lxb_dom_attr_value_noi(element.attr_class).splitter(" ");
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

        p.removeAttribute("id");
        p.removeAttribute("class");

        assert(p.hasAttribute("style"));
        assert(!p.hasAttribute("id"));
        assert(!p.hasAttribute("class"));
        assert(p.id.length == 0);
        assert(p.classes.array.length == 0);
    }

    bool opEquals(const typeof(null) o) const @safe nothrow pure { return !isValid; }
    bool opEquals(E = Element)(const auto ref E e) const
    {
        import std.traits : isSomeString;
        static if (isSomeString!E) return e == this.toString;
        else return e.element == this.element;
    }


    /// Tag
    @property string name() { onlyValidElements(); return ReturnLexborString!lxb_dom_element_local_name(element); }

    unittest
    {
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
    }

    alias clone = dup;
    /// Clone this element
    Element dup(bool deep = true)
    {
        onlyValidElements();

        auto newElement = lxb_dom_element_interface_clone(&(docPayload.document.dom_document), element);
        auto e = Element(docPayload, newElement);

        // FIXME: not the best option
        if(deep)
            e.innerHTML = innerHTML;

        return e;
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

    /// Prepend an element
    void prependSibling(E = Element)(auto ref E el)
    {
        import std.array : array;
        onlyValidElements();

        import std.traits;
        static if (is(E == FragmentString))
        {
            Element root = owner.fragment(el);
            foreach(ref e; root.children(false).array)
                prependSibling(e);
        }
        else
        {
            static if (isSomeString!E)
            {
                Element e = owner.createElement("#text");
                e.innerText = el;
            }
            else alias e = el;

            e.remove();
            lxb_dom_node_insert_before(&(element.node), &(e.element.node));
        }
    }

    /// Append an element
    void appendSibling(E = Element)(auto ref E el)
    {
        import std.array : array;
        onlyValidElements();

        import std.traits;
        static if (is(E == FragmentString))
        {
            Element root = owner.fragment(el);
            foreach(ref e; root.children!(VisitOrder.Reverse)(false).array)
                appendSibling(e);
        }
        else
        {
            static if (isSomeString!E)
            {
                Element e = owner.createElement("#text");
                e.innerText = el;
            }
            else alias e = el;

            e.remove();
            lxb_dom_node_insert_after(&(element.node), &(e.element.node));
        }
    }

    /// Put a new child in the first position
    void prependChild(E = Element)(auto ref E el)
    {
        import std.array : array;
        onlyRealElements();

        import std.traits;
        static if (is(E == FragmentString))
        {
            Element root = owner.fragment(el);
            foreach(ref e; root.children!(VisitOrder.Reverse)(false).array)
                prependChild(e);
        }
        else
        {
            static if (isSomeString!E)
            {
                Element e = owner.createElement("#text");
                e.innerText = el;
            }
            else alias e = el;

            e.remove();
            auto last = element.node.first_child;
            if (last == null) lxb_dom_node_insert_child(&(element.node), &(e.element.node));
            else lxb_dom_node_insert_before(last, &(e.element.node));
        }
    }

    /// Put a new child in the last position
    void appendChild(E = Element)(auto ref E el)
    {
        import std.array : array;
        onlyRealElements();

        import std.traits;

        static if (is(E == FragmentString))
        {
            Element root = owner.fragment(el);
            foreach(ref e; root.children(false).array)
                appendChild(e);
        }
        else
        {
            static if (isSomeString!E)
            {
                Element e = owner.createElement("#text");
                e.innerText = el;
            }
            else alias e = el;
            e.remove();
            auto last = element.node.last_child;
            if (last == null) lxb_dom_node_insert_child(&(element.node), &(e.element.node));
            else lxb_dom_node_insert_after(last, &(e.element.node));
        }
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

    void opOpAssign(string op)(auto ref Element e) if (op == "~") { onlyRealElements(); appendChild(e); }

    /// Remove this element from the document
    bool remove()
    {
        onlyValidElements();

        if (element.node.parent == null) return false;
        lxb_dom_node_remove(&(element.node));
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
        auto comment = doc.createElement("!--");
        comment.innerText = "comment";
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


    /// Replace this element with another one
    void replaceWith(E = Element)(auto ref E el)
    {
        onlyValidElements();

        assert(el != this);

        import std.traits : isSomeString;

        static if (isSomeString!E)
        {
            Element e = owner.createElement("#text");
            e.innerText = el;
        }
        else alias e = el;

        e.remove();
        prependSibling(e);
        remove();
    }

    /// Copy another element here
    void copyFrom(E = Element)(auto ref E e, bool deep = true)
    {
        onlyRealElements();

        assert(e != this);

        import std.algorithm : map;
        import std.array : array;
        auto attr = attributes.map!(x => x.name).array;

        foreach(a; attr)
            removeAttribute(a);

        lxb_dom_element_interface_copy(element, e.element);

        // FIXME: not the best option
        if(deep)
            innerHTML = e.innerHTML;
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
    @property void innerHTML(string html) { onlyValidElements(); CallWithLexborString!lxb_html_element_inner_html_set(cast(lxb_html_element_t*)element, html); }

    /// Get the content of this element
    @property string innerHTML()
    {
        onlyRealElements();

        extern(C) lxb_status_t cb(const lxb_char_t *data, size_t len, void *ctx)
        {
            *(cast(string*)ctx) ~= cast(string)data[0..len];
            return lexbor_status_t.LXB_STATUS_OK;
        }

        string output;
        lxb_html_serialize_deep_cb(&(element.node), &cb, &output);
        return output;
    }

    /// Set the inner text of this element (replacing html)
    @property string innerText() { onlyValidElements(); return ReturnLexborString!lxb_dom_node_text_content(&(element.node)); }

    /// Get the inner text of this element (ignoring html tags)
    @property void innerText(string text) { onlyValidElements(); CallWithLexborString!lxb_dom_node_text_content_set(&(element.node), text); }

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

        p.innerText = "plain text";

        assert(p.descendants(true).front.name == "#text");
        assert(p.innerText == "plain text");
        assert(p.byTagName("a").empty);

    }

    /// See_also: Document.byId
    Element byId(string id)
    {
        onlyRealElements();

        auto r = descendants()
        .filter!(c => c.element.attr_id != null)
        .filter!((c){
            size_t len;
            auto s = lxb_dom_attr_value_noi(c.element.attr_id, &len);
            return (cast(string)s[0..len] == id);
        });

        scope(exit) r.destroy();

        if (r.empty) throw new Exception("Element not found");
        else return r.front;
    }

    /// See_also: Document.byClass
    auto byClass(string name)
    {
        onlyRealElements();

        return descendants()
        .filter!(c => c.element.attr_class != null)
        .filter!((c){
            size_t len;
            auto s = lxb_dom_attr_value_noi(c.element.attr_class, &len);
            return ((cast(string)s[0..len]).splitter(" ").canFind(name));
        });
    }

    /// See_also: Document.byTagName
    auto byTagName(string name)
    {
        onlyRealElements();

        return descendants(true)
        .filter!((c){
            return name == ReturnLexborString!lxb_dom_element_local_name(c.element);
        });
    }

    /// See_also: Document.byComment
    auto byComment(string comment, bool stripSpaces = true)
    {
        import std.string : strip;
        onlyRealElements();

        return byTagName("!--").filter!(x => stripSpaces?(x.innerText.strip == comment.strip):(x.innerText == comment));
    }

    /// See_also: Document.bySelector
    auto bySelector(string selector) { onlyRealElements(); return new SelectorElementRange(docPayload, element, selector); }

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
        Element[] res = doc.bySelector("h4+ul li:nth-of-type(2), #this").array;

        assert(res.length == 2);
        assert(res[0].innerText == "four");
        assert(res[1].innerText == "two");
    }

    unittest
    {
        Document doc = "<div><!--hello--><p></p></div>";
        Element e = doc.byComment("hello").front;
        assert(e.next.name == "p");
        assert(doc.byComment("hell").frontOrInit == null);

    }

    unittest
    {
        Document doc = Document(`<html><body><p id="test"/><p id="another" class="hello world">this is a text`);

        {
            import std.exception : assertThrown;

            Element e = doc.byId("test");
            assert(e.isValid);
            assert(e.name == "p");
            assert(e.id == "test");
            assertThrown(doc.byId("blah"));
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
        lxb_dom_node* el = element.node.next;

        with(lxb_dom_node_type_t)
        {

            while(el != null)
            {
                if (cast(int)el.type ==  cast(int)LXB_DOM_NODE_TYPE_ELEMENT)
                    break;

                if (includeAllElements)
                    break;

                el = el.next;
            }
        }

        return Element(docPayload, cast(lxb_dom_element_t*)el);
    }

    /// The previous element in the document
    @property Element prev(bool includeAllElements = false)
    {
        onlyValidElements();
        lxb_dom_node* el = element.node.prev;

        with(lxb_dom_node_type_t)
        {

            while(el != null)
            {
                if (cast(int)el.type ==  cast(int)LXB_DOM_NODE_TYPE_ELEMENT)
                    break;

                if (includeAllElements)
                    break;

                el = el.prev;
            }
        }

        return Element(docPayload, cast(lxb_dom_element_t*)el);
    }

    /// The parent element
    @property Element parent() { onlyValidElements(); return Element(docPayload,cast(lxb_dom_element_t*) element.node.parent); }

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
        auto el = element.node.first_child;

        with(lxb_dom_node_type_t)
        {

            while(el != null)
            {
                if (cast(int)el.type ==  cast(int)LXB_DOM_NODE_TYPE_ELEMENT)
                    break;

                if (includeAllElements)
                    break;

                el = el.next;
            }
        }

        return Element(docPayload, cast(lxb_dom_element_t*)el);
    }

    /// The last child
    @property Element lastChild(bool includeAllElements = false)
    {
        onlyValidElements();
        auto el = element.node.last_child;

        with(lxb_dom_node_type_t)
        {
            while(el != null)
            {
                if (cast(int)el.type ==  cast(int)LXB_DOM_NODE_TYPE_ELEMENT)
                    break;

                if (includeAllElements)
                    break;

                el = el.prev;
            }
        }

        return Element(docPayload, cast(lxb_dom_element_t*)el);
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
    @property auto descendants(VisitOrder order = VisitOrder.Normal)(bool returnAllElements = false) { onlyRealElements(); return new ChildrenElementRange!order(docPayload, element, true, returnAllElements); }
    /// All the children contained in this element. (non-deep search)
    @property auto children(VisitOrder order = VisitOrder.Normal)(bool returnAllElements = false) { onlyRealElements(); return new ChildrenElementRange!order(docPayload, element, false, returnAllElements); }

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

    ///
    @property bool contains(E = Element)(auto ref E e, bool deep = true)
    {
        onlyRealElements();

        if (e == this) return false;

        Element tmp = e;
        while(tmp != null)
        {
            if (tmp == this) return true;
            else if (!deep) return false;
            else tmp = tmp.parent();
        }

        return false;
    }

    ///
    @property bool isAncestorOf(E = element)(auto ref E e) { onlyRealElements(); return this.contains(e); }
    ///
    @property bool isDescendantOf(E = element)(auto ref E e) { return e.contains(this); }

    unittest
    {
        import std.stdio;
        import std.exception : assertThrown;

        Document d = "<html><p><!--hey<b>--><a>hello</a>";
        Element p = d.byTagName("p").front;

        Element c = p.children(true).front;
        assert(c.innerText == "hey<b>");
        assertThrown(c.hasAttribute("hello") == false);
        assertThrown(c.children.empty);
        assertThrown(c.byTagName("b").empty);
        assert(c.name == "!--");

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
        import std.stdio;
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

    ///
    @property string outerHTML() { onlyValidElements(); return toString(); }
    ///
    @property void outerHTML(string html)
    {
        onlyValidElements();
        Element fragment = owner.fragment(html);

        import std.array;
        foreach(ref c; fragment.children.array)
            prependSibling(c);

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

    ///
    string toString(bool deep = true) const
    {
        onlyValidElements();

        extern(C) lxb_status_t cb(const lxb_char_t *data, size_t len, void *ctx)
        {
            *(cast(string*)ctx) ~= cast(string)data[0..len];
            return lexbor_status_t.LXB_STATUS_OK;
        }

        string output;


        if (deep) lxb_html_serialize_tree_cb(cast(lxb_dom_node*)&(element.node), &cb, &output);
        else lxb_html_serialize_cb(cast(lxb_dom_node*)&(element.node), &cb, &output);

        return output;
    }

    this(ref return scope typeof(this) rhs)
    {
        if (rhs.element == null) return;
        element = rhs.element;
        docPayload = rhs.docPayload;

        Element.RefCounter.add(element);
        Document.RefCounter.add(docPayload);
    }


    auto opAssign(typeof(null) n)
    {
        if (element != null)
            Element.RefCounter.remove(element);

        if (docPayload != null)
            Document.RefCounter.remove(docPayload);

        docPayload = null;
        element = null;
    }

    auto opAssign(const string html)
    {
        if (owner == null)
            throw new Exception("Can't set html for a null element");

        Element fragment = owner.fragment(html);

        auto cld = fragment.children;
        Element first = cld.frontOrInit();

        if (first == null)
            throw new Exception("Can't assign: invalid fragment");

        cld.popFront();

        if (!cld.empty)
            throw new Exception("Can't assign a fragment with more than one child");

        copyFrom(first, true);

    }

    auto opCast(string)()
    {
        onlyValidElements();
        return toString();
    }

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

    auto opAssign(typeof(this) rhs)
    {
        auto oldPayload = docPayload;
        auto oldElement = element;

        docPayload = rhs.docPayload;
        element = rhs.element;

        if (docPayload != null)
            Document.RefCounter.add(docPayload);

        if (element != null)
            Element.RefCounter.add(element);

        if (oldElement != null)
            Element.RefCounter.add(oldElement);

        if (oldPayload != null)
            Document.RefCounter.remove(oldPayload);

        return this;
    }

    ~this() {
        if (element == null) return;
        Element.RefCounter.remove(element);
        Document.RefCounter.remove(docPayload);
    }

    private:
        Document.DocumentPayload*     docPayload;

        lxb_dom_element_t* element;

        this(Document.DocumentPayload* docPayload, lxb_dom_element_t* element)
        {
            this.docPayload = docPayload;
            this.element = element;

            Document.RefCounter.add(docPayload);
            Element.RefCounter.add(element);
        }

        struct RefCounter
        {
            static void add(lxb_dom_element_t* resource)
            {
                //trace("ADD +1 element: ", resource);
                if (resource == null) return;

                auto r = (resource in refs);
                if (r is null) refs[resource] = 1;
                else atomicFetchAdd(*r, 1);
            }

            static void remove(lxb_dom_element_t* resource)
            {
                //trace("REMOVE -1 element: ", resource);
                if (resource == null) return;

                size_t pre = atomicFetchSub(refs[resource], 1);

                if (pre == 1)
                {
                    //trace("DELETE REQ element: ", resource);
                    if (resource.node.owner_document == null)
                    {
                        //trace("DELETED element: ", resource);
                        lxb_dom_element_destroy(resource);
                    }

                    refs.remove(resource);
                }
            }

            private:
            __gshared size_t[lxb_dom_element_t*] refs;
        }

}


class ChildrenElementRange(VisitOrder order = VisitOrder.Normal)
{
    ChildrenElementRange save()
    {
        auto newRange = new ChildrenElementRange!order(docPayload, element, recursive, returnAllElements);
        newRange.current = current;
        newRange.destroyed = destroyed;
        return newRange;
    }

    Element front() {
        return Element(docPayload, current);
    }

    void popFront()
    {
        while(true)
        {
            static if (order == VisitOrder.Reverse)
            {
                auto child = current.node.last_child;
                auto next = current.node.prev;
            }
            else
            {
                auto child = current.node.first_child;
                auto next = current.node.next;
            }

            if (recursive && child != null) current = cast(lxb_dom_element*)(child);
            else if (next != null) current = cast(lxb_dom_element*)(next);
            else
            {
                while(true)
                {
                    if (cast(lxb_dom_element*)current.node.parent == element) { current = null; break; }
                    else
                    {
                        // Node removed during browsing, exit
                        if (current.node.parent == null)
                        {
                            current = null;
                            break;
                        }

                        static if (order == VisitOrder.Reverse) auto candidate = cast(lxb_dom_element*)(current.node.parent.prev);
                        else auto candidate = cast(lxb_dom_element*)(current.node.parent.next);

                        if (candidate == null) current = cast(lxb_dom_element*)current.node.parent;
                        else
                        {
                            current = candidate;
                            break;
                        }
                    }
                }
            }

            if (current == null) break;
            auto type = cast(int)current.node.type;

            if (type == cast(int)lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_ELEMENT) break;
            else if (returnAllElements) break;
        }

        if (empty) unref();
    }

    @property bool empty()
    {
        return current == null;
    }

    ~this() {
        unref();
    }

    private:

    void unref()
    {
        if (!destroyed)
        {
            Element.RefCounter.remove(element);
            Document.RefCounter.remove(docPayload);
        }

        destroyed = true;
    }

    @disable this();

    this(Document.DocumentPayload* docPayload, lxb_dom_element_t* e, bool recursive, bool returnAllElements)
    {
        this.docPayload = docPayload;
        element = e;

        static if (order == VisitOrder.Reverse) current = cast(lxb_dom_element*)(e.node.last_child);
        else current = cast(lxb_dom_element*)(e.node.first_child);

        this.recursive = recursive;
        this.returnAllElements = returnAllElements;

        Document.RefCounter.add(docPayload);
        Element.RefCounter.add(e);

        if (current != null && current.node.type != lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_ELEMENT && returnAllElements == false)
            popFront();

        if (empty)
            unref();
    }

    bool destroyed = false;
    bool recursive;
    bool returnAllElements;

    lxb_dom_element_t* current = null;

    Document.DocumentPayload*   docPayload;
    lxb_dom_element_t*          element;
}


class SelectorElementRange
{
    Element front() { return Element(docPayload, current); }

    void popFront()
    {
        fiber.call();

        if (fiber.state == Fiber.State.TERM)
            current = null;

        if (empty)
            unref();
    }

    @property bool empty() { return current is null; }

    ~this() {
        unref();
    }

    private:

    void unref()
    {
        if (!destroyed)
        {
            lxb_selectors_destroy(selectors,true);
            lxb_css_selector_list_destroy_memory(list);
            Element.RefCounter.remove(element);
            Document.RefCounter.remove(docPayload);
        }

        destroyed = true;
    }

    @disable this();


    extern(C) static lxb_status_t find_callback(lxb_dom_node_t *node, void *spec, void *ctx)
    {
        auto current = (cast(lxb_dom_element_t**)ctx);
        *current = null;

        if (cast(int)node.type == cast(int)lxb_dom_node_type_t.LXB_DOM_NODE_TYPE_ELEMENT)
        {
            *current = cast(lxb_dom_element_t*)node;
            Fiber.yield();

            if(*current == null)
                return lexbor_status_t.LXB_STATUS_ERROR;
        }

        return lexbor_status_t.LXB_STATUS_OK;
    }

    this(Document.DocumentPayload* docPayload, lxb_dom_element_t* e, string selector)
    {
        this.docPayload = docPayload;
        this.element = e;

        selectors = lxb_selectors_create();
        lxb_selectors_init(selectors);
        list = CallWithLexborString!lxb_css_selectors_parse(docPayload.parser, selector);

        Document.RefCounter.add(docPayload);
        Element.RefCounter.add(element);

        fiber = new CBFiber();
        fiber.call();

        if (empty)
            unref();
    }

    class CBFiber : Fiber {

        this() {
            super({lxb_selectors_find(selectors, &(element.node), list, &find_callback, &current);});
        }

        ~this() {
            current = null;
            if (state == Fiber.State.HOLD)
                call();
        }
    }

    bool destroyed              = false;
    Fiber fiber                 = null;

    lxb_dom_element_t* current  = null;
    lxb_dom_element_t* element  = null;

    Document.DocumentPayload*   docPayload;
    lxb_selectors_t*            selectors;
    lxb_css_selector_list_t*    list;

}

import std.range : isInputRange, ElementType;
import std.traits : ReturnType;

/// Get the first element of a range or throw an exception
auto frontOrThrow(T)(T range)
if (isInputRange!T)
{
    if (range.empty) throw new Exception("Range is empty.");
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

auto asFragment(string s)
{
    return cast(FragmentString)s;
}

private auto CallWithLexborString(alias T, A...)(A params, string str) { return T(params, str.representation.ptr, str.representation.length); }

private string ReturnLexborString(alias T, A...)(A params)
{
    size_t len;
    auto r = T(params, &len);
    return cast(string)r[0..len];
}
