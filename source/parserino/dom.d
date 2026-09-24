/++
 The document tree.

 Every node lives in the arena of its document and is freed with it: removed
 nodes stay valid. Nodes are plain structs: `Element`, `CharacterData`, ... start
 with a `Node`: `node.as!Element` (after checking `type`) gives the struct that contains it.
+/
module parserino.dom;

import parserino.arena;
import parserino.names;
import core.stdc.string : memcpy;
import std.traits : CopyConstness;

// Used by `Node.as` in CTFE (see `ctfeContainer`), they allocate: keep them outside the `@nogc:` sections
version (D_BetterC)
{
    // No AAs without druntime (and no parsing at compile time, see `parserino.arena`)
    private alias CtfeTable = void*;
    private void* ctfeLookup(const(Node)* n) nothrow pure { assert(0, "CTFE parsing needs druntime"); }
    private void ctfeStore(T)(T* x) nothrow pure { assert(0, "CTFE parsing needs druntime"); }
}
else
{
    private alias CtfeTable = void*[const(Node)*];
    private void* ctfeLookup(const(Node)* n) nothrow pure @trusted { return cast(void*) n.document.ctfeContainers[n]; }
    private void ctfeStore(T)(T* x) nothrow pure @trusted { x.node.document.ctfeContainers[&x.node] = cast(void*) x; }
}

/// The text of a node and its descendants (DOM `textContent`) written to `sink`
void textContent(Sink)(const(Node)* node, ref Sink sink)
{
    import std.range.primitives : put;

    if (auto cd = node.asCharacterData)
    {
        put(sink, cd.data);
        return;
    }

    for (const(Node)* n = node.firstChild; n !is null; n = n.nextInTree(node))
        if (n.type == NodeType.text || n.type == NodeType.cdataSection)
            put(sink, n.as!CharacterData.data);
}

@nogc nothrow:

enum NodeType : ubyte
{
    element = 1,
    text = 3,
    cdataSection = 4,
    processingInstruction = 7,
    comment = 8,
    document = 9,
    documentType = 10,
    documentFragment = 11,
}

enum CompatMode : ubyte { noQuirks, limitedQuirks, quirks }

/// The common part of all the nodes
struct Node
{
@nogc nothrow:

    NodeType type;
    Ns ns;
    /// Tag of elements (a `Tag` or an id from the document names). Other nodes: `Tag._text`, `Tag._comment`, ...
    uint name;

    Node* parent;
    Node* firstChild;
    Node* lastChild;
    Node* prev;
    Node* next;
    Document* document;

    /// Is this an element in the html namespace with this tag?
    bool isHtml(uint tag) const pure { return type == NodeType.element && name == tag && ns == Ns.html; }

    /++ The struct that contains this node: `Element`, `CharacterData`, `DocumentType`, `DocumentFragment` or `Document`.
     + Unchecked: `type` must match.
     +/
    T* as(T)() pure @trusted return
    {
        // CTFE can't reinterpret a pointer: the document remembers the container of each node
        if (__ctfe) return cast(T*) ctfeContainer(&this);
        return cast(T*) &this;
    }

    /// ditto
    const(T)* as(T)() const pure @trusted return
    {
        if (__ctfe) return cast(T*) ctfeContainer(&this);
        return cast(const(T)*) &this;
    }

    /// The element / character data, or null if the node is something else
    Element* asElement() pure return { return type == NodeType.element ? as!Element : null; }
    const(Element)* asElement() const pure return { return type == NodeType.element ? as!Element : null; }

    /// ditto
    CharacterData* asCharacterData() pure return { return isCharacterData ? as!CharacterData : null; }
    const(CharacterData)* asCharacterData() const pure return { return isCharacterData ? as!CharacterData : null; }

    bool isCharacterData() const pure
    {
        return type == NodeType.text || type == NodeType.comment || type == NodeType.processingInstruction || type == NodeType.cdataSection;
    }

    /// Previous/next sibling that is an element
    // These are templates on the constness of `this` (not `inout`: CTFE can't convert inout pointers)
    auto prevElement(this This)() pure { This* n = prev; while (n !is null && n.type != NodeType.element) n = n.prev; return n; }
    auto nextElement(this This)() pure { This* n = next; while (n !is null && n.type != NodeType.element) n = n.next; return n; }

    /// Append `child` as the last child (`child` must be detached)
    void appendChild(Node* child) pure
    {
        child.parent = &this;
        child.prev = lastChild;
        child.next = null;
        if (lastChild !is null) lastChild.next = child; else firstChild = child;
        lastChild = child;
    }

    /// Insert `node` (detached) before this node
    void insertBefore(Node* node) pure
    {
        node.parent = parent;
        node.next = &this;
        node.prev = prev;
        if (prev !is null) prev.next = node; else if (parent !is null) parent.firstChild = node;
        prev = node;
    }

    /// Insert `node` (detached) after this node
    void insertAfter(Node* node) pure
    {
        node.parent = parent;
        node.prev = &this;
        node.next = next;
        if (next !is null) next.prev = node; else if (parent !is null) parent.lastChild = node;
        next = node;
    }

    /// Detach this node from its parent
    void remove() pure
    {
        if (parent !is null)
        {
            if (parent.firstChild is &this) parent.firstChild = next;
            if (parent.lastChild is &this) parent.lastChild = prev;
        }

        if (prev !is null) prev.next = next;
        if (next !is null) next.prev = prev;
        parent = prev = next = null;
    }

    /// Move all the children of this node at the end of `to`
    void moveChildrenTo(Node* to) pure
    {
        while (firstChild !is null)
        {
            auto c = firstChild;
            c.remove();
            to.appendChild(c);
        }
    }

    /// Is `other` this node or one of its descendants?
    bool contains(const(Node)* other) const pure
    {
        for (auto n = other; n !is null; n = n.parent)
            if (n is &this) return true;
        return false;
    }

    /// Next node in tree order inside `root` (excluded), or null
    auto nextInTree(this This)(const(Node)* root) pure
    {
        This* n = firstChild;
        return n !is null ? n : nextSkippingChildren(root);
    }

    /// Next node in tree order after this subtree, inside `root`, or null
    auto nextSkippingChildren(this This)(const(Node)* root) pure
    {
        This* n = &this;
        while (n !is root && n.next is null) n = n.parent;
        This* r = n is root || n is null ? null : n.next;
        return r;
    }

    /// Local name ("div", "#text", "!--", ...; the target for processing instructions)
    const(char)[] localName() const pure
    {
        if (type == NodeType.processingInstruction) return as!CharacterData.target;
        return document.tagName(name);
    }

    /// Does this subtree contain only whitespace text and comments?
    bool isBlank() const pure
    {
        for (const(Node)* n = firstChild; n !is null; n = n.nextInTree(&this))
        {
            if (n.type == NodeType.comment) continue;
            if (n.type != NodeType.text) return false;
            foreach (c; n.as!CharacterData.data)
                if (c != ' ' && c != '\t' && c != '\n' && c != '\f' && c != '\r') return false;
        }
        return true;
    }
}

/// An attribute
struct Attribute
{
@nogc nothrow:

    /// Local name, lowercase (an `AttrName` or an id from the document names)
    uint name;
    Ns ns;
    /// The name to serialize, when it differs from the local name (`xlink:href`, `viewBox`), else null
    const(char)[] qualifiedName;
    const(char)[] value;

    Element* owner;
    Attribute* prev;
    Attribute* next;

    /// The local name
    const(char)[] localName() const pure { return owner.node.document.attrName(name); }

    /// The full name: `xlink:href`, `viewBox`, `class`
    const(char)[] fullName() const pure { return qualifiedName !is null ? qualifiedName : localName; }
}

/// An element
struct Element
{
@nogc nothrow:

    Node node;
    alias node this;

    /// The name to serialize, when it differs from the local name (`foreignObject`), else null
    const(char)[] qualifiedName;

    Attribute* firstAttr;
    Attribute* lastAttr;
    Attribute* idAttr;
    Attribute* classAttr;

    /// The content of a `<template>`
    DocumentFragment* templateContent;

    /// State used by the parser (option selectedness, ...)
    ubyte flags;

    /// Tag name as written in html: `div`, `foreignObject`
    const(char)[] fullName() const pure { return qualifiedName !is null ? qualifiedName : node.localName; }

    /// First attribute with this (lowercase) name id, any namespace
    CopyConstness!(This, Attribute)* attribute(this This)(uint id) pure
    {
        for (typeof(return) a = firstAttr; a !is null; a = a.next)
            if (a.name == id) return a;
        return null;
    }

    /// First attribute with this name (case-insensitive for html elements)
    CopyConstness!(This, Attribute)* attribute(this This)(scope const(char)[] name) pure
    {
        auto id = node.document.findAttrName(name);
        return id == 0 ? null : this.attribute(id);
    }

    /// Append an attribute (no duplicate check)
    void appendAttribute(Attribute* a) pure
    {
        a.owner = &this;
        a.prev = lastAttr;
        a.next = null;
        if (lastAttr !is null) lastAttr.next = a; else firstAttr = a;
        lastAttr = a;
        track(a);
    }

    /// Remove an attribute of this element
    void removeAttribute(Attribute* a) pure
    {
        if (a.prev !is null) a.prev.next = a.next; else firstAttr = a.next;
        if (a.next !is null) a.next.prev = a.prev; else lastAttr = a.prev;
        if (idAttr is a) idAttr = null;
        if (classAttr is a) classAttr = null;
        a.prev = a.next = null;
    }

    /// Keep `idAttr` and `classAttr` up to date
    void track(Attribute* a) pure
    {
        if (a.ns != Ns.none && a.ns != Ns.html) return;
        if (a.name == AttrName.id && idAttr is null) idAttr = a;
        else if (a.name == AttrName.class_ && classAttr is null) classAttr = a;
    }
}

/// Text, comments, processing instructions, CDATA sections
struct CharacterData
{
@nogc nothrow:

    Node node;
    alias node this;

    /// The target of a processing instruction
    const(char)[] target;

    private char* ptr;
    private size_t length;
    private size_t capacity;

    const(char)[] data() const pure return @trusted { return ptr is null ? "" : ptr[0 .. length]; }

    /++ Use `s` as the text, without copying it: `s` must outlive the document and never change
     + (it's never written: a later change of the text reallocates it).
     +/
    void borrowData(return scope const(char)[] s) pure @trusted
    {
        ptr = cast(char*) s.ptr;
        length = s.length;
        capacity = 0;
    }

    /// Replace the text
    bool setData(scope const(char)[] s) pure
    {
        length = 0;
        return appendData(s);
    }

    /// Append to the text. It returns false if out of memory.
    bool appendData(scope const(char)[] s) pure @trusted
    {
        if (length + s.length > capacity)
        {
            auto cap = capacity * 2;
            if (cap < length + s.length) cap = length + s.length;
            if (cap < 16) cap = 16;

            auto nb = node.document.arena.alloc!char(cap);
            if (nb is null) return false;
            copyItems(nb.ptr, ptr, length);
            ptr = nb.ptr;
            capacity = cap;
        }

        copyItems(ptr + length, s.ptr, s.length);
        length += s.length;
        return true;
    }
}

struct DocumentType
{
    Node node;
    alias node this;

    const(char)[] name;
    const(char)[] publicId;
    const(char)[] systemId;
}

struct DocumentFragment
{
    Node node;
    alias node this;
}

/// The document: it owns the memory of all its nodes
// CTFE helpers for `Node.as`: they use the GC (an AA), so they are called as @nogc

private void* ctfeContainer(const(Node)* n) @nogc nothrow pure @trusted
{
    alias F = void* function(const(Node)*) @nogc nothrow pure;
    return (cast(F) &ctfeLookup)(n);
}

private void ctfeRegister(T)(T* x) @nogc nothrow pure @trusted
{
    alias F = void function(T*) @nogc nothrow pure;
    (cast(F) &ctfeStore!T)(x);
}

struct Document
{
@nogc nothrow:

    Node node;
    alias node this;

    @disable this(this);

    Arena arena;
    CompatMode compatMode;
    bool scripting;

    DocumentType* doctype;
    Element* head;
    Element* body;

    /// The root element (`<html>`)
    Element* documentElement() pure
    {
        for (Node* n = node.firstChild; n !is null; n = n.next)
            if (n.type == NodeType.element) return n.as!Element;
        return null;
    }

    /// ditto
    const(Element)* documentElement() const pure
    {
        for (const(Node)* n = node.firstChild; n !is null; n = n.next)
            if (n.type == NodeType.element) return n.as!Element;
        return null;
    }

    /// Initialize a document allocated by the caller (zeroed memory)
    void initialize() pure
    {
        node.type = NodeType.document;
        node.name = Tag._document;
        node.document = &this;
        if (__ctfe) ctfeRegister(&this);
    }

    /// Free all the memory
    void release() pure
    {
        arena.release();
        destroy(tags);
        destroy(attrs);
    }

    // ------------------------------------------------------------ names

    /// Tag id of a lowercase name, adding it if unknown. 0 if out of memory.
    uint tagId(scope const(char)[] lowerName) pure
    {
        auto t = knownTag(lowerName);
        if (t != Tag._undef) return t;
        return tags.intern(lowerName, arena, Tag._last);
    }

    /// Tag id of a name (any case), 0 if the document never saw it
    uint findTagName(scope const(char)[] name) const pure
    {
        char[64] buf = void;
        auto lower = toLower(name, buf);
        if (lower is null) return 0;
        auto t = knownTag(lower);
        if (t != Tag._undef) return t;
        return tags.find(lower, Tag._last);
    }

    const(char)[] tagName(uint id) const pure
    {
        return id < Tag._last ? tagNames[id] : tags.name(id, Tag._last);
    }

    /// Attribute id of a lowercase name, adding it if unknown. 0 if out of memory.
    uint attrId(scope const(char)[] lowerName) pure
    {
        auto a = knownAttr(lowerName);
        if (a != AttrName._undef) return a;
        return attrs.intern(lowerName, arena, AttrName._last);
    }

    /// Attribute id of a name (any case), 0 if the document never saw it
    uint findAttrName(scope const(char)[] name) const pure
    {
        char[64] buf = void;
        auto lower = toLower(name, buf);
        if (lower is null) return 0;
        auto a = knownAttr(lower);
        if (a != AttrName._undef) return a;
        return attrs.find(lower, AttrName._last);
    }

    const(char)[] attrName(uint id) const pure
    {
        return id < AttrName._last ? attrNames[id] : attrs.name(id, AttrName._last);
    }

    // ------------------------------------------------------------ creation

    Element* createElement(uint tag, Ns ns) pure
    {
        auto e = arena.make!Element;
        if (e is null) return null;
        e.node.type = NodeType.element;
        e.node.name = tag;
        e.node.ns = ns;
        e.node.document = &this;
        if (__ctfe) ctfeRegister(e);

        if (tag == Tag.template_ && ns == Ns.html)
        {
            e.templateContent = createFragment();
            if (e.templateContent is null) return null;
        }

        return e;
    }

    CharacterData* createText(scope const(char)[] data) pure { return createCharacterData(NodeType.text, Tag._text, data); }
    CharacterData* createComment(scope const(char)[] data) pure { return createCharacterData(NodeType.comment, Tag._comment, data); }

    CharacterData* createProcessingInstruction(scope const(char)[] target, scope const(char)[] data) pure
    {
        auto pi = createCharacterData(NodeType.processingInstruction, Tag._processingInstruction, data);
        if (pi is null) return null;
        pi.target = copy(target);
        return pi;
    }

    DocumentType* createDocumentType(scope const(char)[] name, scope const(char)[] publicId, scope const(char)[] systemId) pure
    {
        auto d = arena.make!DocumentType;
        if (d is null) return null;
        d.node.type = NodeType.documentType;
        d.node.name = Tag._doctype;
        d.node.document = &this;
        if (__ctfe) ctfeRegister(d);
        d.name = copy(name);
        d.publicId = copy(publicId);
        d.systemId = copy(systemId);
        return d;
    }

    DocumentFragment* createFragment() pure
    {
        auto f = arena.make!DocumentFragment;
        if (f is null) return null;
        f.node.type = NodeType.documentFragment;
        f.node.name = Tag._document;
        f.node.document = &this;
        if (__ctfe) ctfeRegister(f);
        return f;
    }

    /// A new attribute (not attached). The name must be lowercase.
    Attribute* createAttribute(scope const(char)[] lowerName, scope const(char)[] value, Ns ns = Ns.none) pure
    {
        auto id = attrId(lowerName);
        if (id == 0) return null;
        return createAttribute(id, value, ns);
    }

    /// ditto
    Attribute* createAttribute(uint id, scope const(char)[] value, Ns ns = Ns.none) pure
    {
        auto a = arena.make!Attribute;
        if (a is null) return null;
        a.name = id;
        a.ns = ns;
        a.value = copy(value);
        return a;
    }

    /// Set (or add) an attribute. The name is lowercased. It returns null if out of memory.
    Attribute* setAttribute(Element* e, scope const(char)[] name, scope const(char)[] value) pure
    {
        char[64] buf = void;
        const(char)[] lower = toLower(name, buf);
        Buffer!char big;
        if (lower is null)
        {
            foreach (c; name) big.put(c >= 'A' && c <= 'Z' ? cast(char) (c | 0x20) : c);
            lower = big[];
        }

        auto id = attrId(lower);
        if (id == 0) return null;

        if (auto a = e.attribute(id))
        {
            a.value = copy(value);
            return a;
        }

        auto a = createAttribute(id, value);
        if (a is null) return null;
        e.appendAttribute(a);
        return a;
    }

    /// A copy of `src` owned by this document (deep: with all the descendants)
    Node* importNode(const(Node)* src, bool deep) pure
    {
        auto copy = cloneNode(src);
        if (copy is null || !deep) return copy;

        for (const(Node)* c = src.firstChild; c !is null; c = c.next)
        {
            auto cc = importNode(c, true);
            if (cc is null) return null;
            copy.appendChild(cc);
        }

        return copy;
    }

    /// A string owned by the document
    const(char)[] copy(scope const(char)[] s) pure
    {
        if (s.length == 0) return s is null ? null : "";
        return arena.dup(s);
    }


    private:

    NameTable tags;
    NameTable attrs;

    // Only in CTFE: node -> the struct that contains it (see `Node.as`)
    CtfeTable ctfeContainers;


    CharacterData* createCharacterData(NodeType type, uint name, scope const(char)[] data) pure
    {
        auto t = arena.make!CharacterData;
        if (t is null) return null;
        t.node.type = type;
        t.node.name = name;
        t.node.document = &this;
        if (__ctfe) ctfeRegister(t);
        if (data.length && !t.setData(data)) return null;
        return t;
    }

    Node* cloneNode(const(Node)* src) pure
    {
        final switch (src.type)
        {
            case NodeType.element:
                auto se = src.as!Element;
                auto name = src.document is &this ? src.name : tagId(src.document.tagName(src.name));
                auto e = createElement(name, src.ns);
                if (e is null) return null;
                e.qualifiedName = copy(se.qualifiedName);

                for (const(Attribute)* a = se.firstAttr; a !is null; a = a.next)
                {
                    auto an = src.document is &this ? a.name : attrId(src.document.attrName(a.name));
                    auto na = createAttribute(an, a.value, a.ns);
                    if (na is null) return null;
                    na.qualifiedName = copy(a.qualifiedName);
                    e.appendAttribute(na);
                }

                if (se.templateContent !is null)
                {
                    for (const(Node)* c = se.templateContent.node.firstChild; c !is null; c = c.next)
                    {
                        auto cc = importNode(c, true);
                        if (cc is null) return null;
                        e.templateContent.node.appendChild(cc);
                    }
                }
                return &e.node;

            case NodeType.text, NodeType.comment, NodeType.cdataSection, NodeType.processingInstruction:
                auto scd = src.as!CharacterData;
                auto cd = createCharacterData(src.type, src.name, scd.data);
                if (cd is null) return null;
                cd.target = copy(scd.target);
                return &cd.node;

            case NodeType.documentType:
                auto sd = src.as!DocumentType;
                auto d = createDocumentType(sd.name, sd.publicId, sd.systemId);
                return d is null ? null : &d.node;

            case NodeType.documentFragment, NodeType.document:
                auto f = createFragment();
                return f is null ? null : &f.node;
        }
    }
}

/// ASCII lowercase into `buf`, or `s` itself if already lowercase; null if longer than `buf`
const(char)[] toLower(return scope const(char)[] s, return ref char[64] buf) pure
{
    bool upper = false;
    foreach (c; s) if (c >= 'A' && c <= 'Z') { upper = true; break; }
    if (!upper) return s;
    if (s.length > buf.length) return null;

    foreach (i, c; s) buf[i] = c >= 'A' && c <= 'Z' ? cast(char) (c | 0x20) : c;
    return buf[0 .. s.length];
}

unittest
{
    import core.memory : pureCalloc, pureFree;

    auto doc = cast(Document*) pureCalloc(1, Document.sizeof);
    scope(exit) { doc.release(); pureFree(doc); }
    doc.initialize();

    auto html = doc.createElement(Tag.html, Ns.html);
    doc.node.appendChild(&html.node);
    auto p = doc.createElement(doc.tagId("p"), Ns.html);
    auto x = doc.createElement(doc.tagId("x-custom"), Ns.html);
    html.appendChild(&p.node);
    html.appendChild(&x.node);

    assert(doc.documentElement is html);
    assert(x.localName == "x-custom");
    assert(doc.findTagName("X-CUSTOM") == x.name);

    auto t = doc.createText("hello");
    p.appendChild(&t.node);
    t.appendData(" world, this is longer than sixteen chars");
    assert(t.data == "hello world, this is longer than sixteen chars");

    doc.setAttribute(p, "CLASS", "a b");
    assert(p.classAttr !is null && p.classAttr.value == "a b");
    assert(p.attribute("class").value == "a b");

    auto c = doc.importNode(&p.node, true);
    assert(c.firstChild !is null && c.firstChild.as!CharacterData.data == t.data);

    p.remove();
    assert(html.firstChild is &x.node && x.prev is null);
}
