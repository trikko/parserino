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
    private void* ctfeLookup(const(DomNode)* n) nothrow pure { assert(0, "CTFE parsing needs druntime"); }
    private void ctfeStore(T)(T* x) nothrow pure { assert(0, "CTFE parsing needs druntime"); }
}
else
{
    private alias CtfeTable = void*[const(DomNode)*];
    private void* ctfeLookup(const(DomNode)* n) nothrow pure @trusted { return cast(void*) n.document.ctfeContainers[n]; }
    private void ctfeStore(T)(T* x) nothrow pure @trusted { x.node.document.ctfeContainers[&x.node] = cast(void*) x; }
}

/// The text of a node and its descendants (DOM `textContent`) written to `sink`
void textContent(Sink)(const(DomNode)* node, ref Sink sink)
{
    import std.range.primitives : put;

    if (auto cd = node.asCharacterData)
    {
        put(sink, cd.data);
        return;
    }

    for (const(DomNode)* n = node.firstChild; n !is null; n = n.nextInTree(node))
        if (n.type == NodeType.Text || n.type == NodeType.CDataSection)
            put(sink, n.as!DomCharacterData.data);
}

@nogc nothrow pure @safe:

enum NodeType : ubyte
{
    Element = 1,
    Text = 3,
    CDataSection = 4,
    ProcessingInstruction = 7,
    Comment = 8,
    Document = 9,
    DocumentType = 10,
    DocumentFragment = 11,
}

enum CompatMode : ubyte { NoQuirks, LimitedQuirks, Quirks }

/// The common part of all the nodes
struct DomNode
{
@nogc nothrow pure @safe:

    NodeType type;
    Ns ns;
    /// Tag of elements (a `Tag` or an id from the document names). Other nodes: `Tag.TextNode`, `Tag.CommentNode`, ...
    uint name;

    DomNode* parent;
    DomNode* firstChild;
    DomNode* lastChild;
    DomNode* prev;
    DomNode* next;
    DomDocument* document;

    /// Is this an element in the html namespace with this tag?
    bool isHtml(uint tag) const pure { return type == NodeType.Element && name == tag && ns == Ns.Html; }

    /++ The struct that contains this node: `DomElement`, `DomCharacterData`, `DomDocumentType`,
     + `DomDocumentFragment` or `DomDocument`. `type` must match (checked only by an assert).
     +/
    T* as(T)() pure @trusted return
    {
        assert(isA!T(type), "Wrong node type for " ~ T.stringof);

        // CTFE can't reinterpret a pointer: the document remembers the container of each node
        if (__ctfe) return cast(T*) ctfeContainer(&this);
        return cast(T*) &this;
    }

    /// ditto
    const(T)* as(T)() const pure @trusted return
    {
        assert(isA!T(type), "Wrong node type for " ~ T.stringof);

        if (__ctfe) return cast(T*) ctfeContainer(&this);
        return cast(const(T)*) &this;
    }

    /// The element / character data, or null if the node is something else
    DomElement* asElement() pure return { return type == NodeType.Element ? as!DomElement : null; }
    const(DomElement)* asElement() const pure return { return type == NodeType.Element ? as!DomElement : null; }

    /// ditto
    DomCharacterData* asCharacterData() pure return { return isCharacterData ? as!DomCharacterData : null; }
    const(DomCharacterData)* asCharacterData() const pure return { return isCharacterData ? as!DomCharacterData : null; }

    bool isCharacterData() const pure
    {
        return type == NodeType.Text || type == NodeType.Comment || type == NodeType.ProcessingInstruction || type == NodeType.CDataSection;
    }

    /// Previous/next sibling that is an element
    // These are templates on the constness of `this` (not `inout`: CTFE can't convert inout pointers)
    auto prevElement(this This)() pure { This* n = prev; while (n !is null && n.type != NodeType.Element) n = n.prev; return n; }
    auto nextElement(this This)() pure { This* n = next; while (n !is null && n.type != NodeType.Element) n = n.next; return n; }

    /// Append `child` as the last child (`child` must be detached)
    void appendChild(DomNode* child) pure
    {
        child.parent = &this;
        child.prev = lastChild;
        child.next = null;
        if (lastChild !is null) lastChild.next = child; else firstChild = child;
        lastChild = child;
    }

    /// Insert `node` (detached) before this node
    void insertBefore(DomNode* node) pure
    {
        node.parent = parent;
        node.next = &this;
        node.prev = prev;
        if (prev !is null) prev.next = node; else if (parent !is null) parent.firstChild = node;
        prev = node;
    }

    /// Insert `node` (detached) after this node
    void insertAfter(DomNode* node) pure
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
    void moveChildrenTo(DomNode* to) pure
    {
        while (firstChild !is null)
        {
            auto c = firstChild;
            c.remove();
            to.appendChild(c);
        }
    }

    /// The parent, or the `<template>` for the nodes of a template content
    auto parentOrHost(this This)() pure
    {
        This* p = parent;
        if (p !is null && p.type == NodeType.DocumentFragment)
            if (auto h = p.as!DomDocumentFragment.host) return cast(This*) &h.node;
        return p;
    }

    /// The first node of the template content for a `<template>`, else the first child
    auto firstChildOrContent(this This)() pure
    {
        if (type == NodeType.Element)
            if (auto c = as!DomElement.templateContent) return cast(This*) c.node.firstChild;
        return firstChild;
    }

    /// Is `other` this node or one of its descendants?
    bool contains(const(DomNode)* other) const pure
    {
        for (auto n = other; n !is null; n = n.parent)
            if (n is &this) return true;
        return false;
    }

    /// Next node in tree order inside `root` (excluded), or null
    auto nextInTree(this This)(const(DomNode)* root) pure
    {
        This* n = firstChild;
        return n !is null ? n : nextSkippingChildren(root);
    }

    /// Next node in tree order after this subtree, inside `root`, or null
    auto nextSkippingChildren(this This)(const(DomNode)* root) pure
    {
        This* n = &this;
        while (n !is root && n.next is null) n = n.parent;
        This* r = n is root || n is null ? null : n.next;
        return r;
    }

    /// Local name ("div", "#text", "!--", ...; the target for processing instructions)
    const(char)[] localName() const pure
    {
        if (type == NodeType.ProcessingInstruction) return as!DomCharacterData.target;
        return document.tagName(name);
    }

    /// Does this subtree contain only whitespace text and comments?
    bool isBlank() const pure
    {
        for (const(DomNode)* n = firstChild; n !is null; n = n.nextInTree(&this))
        {
            if (n.type == NodeType.Comment) continue;
            if (n.type != NodeType.Text) return false;
            foreach (c; n.as!DomCharacterData.data)
                if (c != ' ' && c != '\t' && c != '\n' && c != '\f' && c != '\r') return false;
        }
        return true;
    }
}

/// An attribute
struct DomAttribute
{
@nogc nothrow pure @safe:

    /// Local name, lowercase (an `AttrName` or an id from the document names)
    uint name;
    Ns ns;
    /// The name to serialize, when it differs from the local name (`xlink:href`, `viewBox`), else null
    const(char)[] qualifiedName;
    const(char)[] value;

    DomElement* owner;
    DomAttribute* prev;
    DomAttribute* next;

    /// The local name
    const(char)[] localName() const pure { return owner.node.document.attrName(name); }

    /// The full name: `xlink:href`, `viewBox`, `class`
    const(char)[] fullName() const pure { return qualifiedName !is null ? qualifiedName : localName; }
}

/// An element
struct DomElement
{
@nogc nothrow pure @safe:

    DomNode node;
    alias node this;

    /// The name to serialize, when it differs from the local name (`foreignObject`), else null
    const(char)[] qualifiedName;

    DomAttribute* firstAttr;
    DomAttribute* lastAttr;
    DomAttribute* idAttr;
    DomAttribute* classAttr;

    /// The content of a `<template>`
    DomDocumentFragment* templateContent;

    /// State used by the parser (option selectedness, ...)
    ubyte flags;

    /// Tag name as written in html: `div`, `foreignObject`
    const(char)[] fullName() const pure { return qualifiedName !is null ? qualifiedName : node.localName; }

    /// First attribute with this (lowercase) name id, any namespace
    CopyConstness!(This, DomAttribute)* attribute(this This)(uint id) pure
    {
        for (typeof(return) a = firstAttr; a !is null; a = a.next)
            if (a.name == id) return a;
        return null;
    }

    /// First attribute with this name (case-insensitive for html elements)
    CopyConstness!(This, DomAttribute)* attribute(this This)(scope const(char)[] name) pure
    {
        auto id = node.document.findAttrName(name);
        return id == 0 ? null : this.attribute(id);
    }

    /// Append an attribute (no duplicate check)
    void appendAttribute(DomAttribute* a) pure
    {
        a.owner = &this;
        a.prev = lastAttr;
        a.next = null;
        if (lastAttr !is null) lastAttr.next = a; else firstAttr = a;
        lastAttr = a;
        track(a);
    }

    /// Remove an attribute of this element
    void removeAttribute(DomAttribute* a) pure
    {
        if (a.prev !is null) a.prev.next = a.next; else firstAttr = a.next;
        if (a.next !is null) a.next.prev = a.prev; else lastAttr = a.prev;
        if (idAttr is a) idAttr = null;
        if (classAttr is a) classAttr = null;
        a.prev = a.next = null;
    }

    /// Keep `idAttr` and `classAttr` up to date
    void track(DomAttribute* a) pure
    {
        if (a.ns != Ns.None && a.ns != Ns.Html) return;
        if (a.name == AttrName.Id && idAttr is null) idAttr = a;
        else if (a.name == AttrName.Class && classAttr is null) classAttr = a;
    }
}

/// Text, comments, processing instructions, CDATA sections
struct DomCharacterData
{
@nogc nothrow pure @safe:

    DomNode node;
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

struct DomDocumentType
{
    DomNode node;
    alias node this;

    const(char)[] name;
    const(char)[] publicId;
    const(char)[] systemId;
}

struct DomDocumentFragment
{
    DomNode node;
    alias node this;

    /// The `<template>` of a template content, else null
    DomElement* host;
}

// Is `T` the struct of the nodes of this type?
private bool isA(T)(NodeType t) @nogc nothrow pure
{
    static if (is(T == DomElement)) return t == NodeType.Element;
    else static if (is(T == DomCharacterData))
        return t == NodeType.Text || t == NodeType.Comment || t == NodeType.ProcessingInstruction || t == NodeType.CDataSection;
    else static if (is(T == DomDocumentType)) return t == NodeType.DocumentType;
    else static if (is(T == DomDocumentFragment)) return t == NodeType.DocumentFragment;
    else static if (is(T == DomDocument)) return t == NodeType.Document;
    else static assert(0, T.stringof ~ " is not a node");
}

/// The document: it owns the memory of all its nodes
// CTFE helpers for `Node.as`: they use the GC (an AA), so they are called as @nogc

private void* ctfeContainer(const(DomNode)* n) @nogc nothrow pure @trusted
{
    alias F = void* function(const(DomNode)*) @nogc nothrow pure;
    return (cast(F) &ctfeLookup)(n);
}

private void ctfeRegister(T)(T* x) @nogc nothrow pure @trusted
{
    alias F = void function(T*) @nogc nothrow pure;
    (cast(F) &ctfeStore!T)(x);
}

struct DomDocument
{
@nogc nothrow pure @safe:

    DomNode node;
    alias node this;

    @disable this(this);

    Arena arena;
    CompatMode compatMode;
    bool scripting;

    DomDocumentType* doctype;
    DomElement* head;
    DomElement* body;

    /// The root element (`<html>`)
    DomElement* documentElement() pure
    {
        for (DomNode* n = node.firstChild; n !is null; n = n.next)
            if (n.type == NodeType.Element) return n.as!DomElement;
        return null;
    }

    /// ditto
    const(DomElement)* documentElement() const pure
    {
        for (const(DomNode)* n = node.firstChild; n !is null; n = n.next)
            if (n.type == NodeType.Element) return n.as!DomElement;
        return null;
    }

    /// Initialize a document allocated by the caller (zeroed memory)
    void initialize() pure
    {
        node.type = NodeType.Document;
        node.name = Tag.DocumentNode;
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
        if (t != Tag.Undef) return t;
        return tags.intern(lowerName, arena, Tag.Last);
    }

    /// Tag id of a name (any case), 0 if the document never saw it
    uint findTagName(scope const(char)[] name) const pure
    {
        char[64] buf = void;
        Buffer!char big;
        auto lower = toLower(name, buf, big);
        if (lower is null) return 0;
        auto t = knownTag(lower);
        if (t != Tag.Undef) return t;
        return tags.find(lower, Tag.Last);
    }

    const(char)[] tagName(uint id) const pure
    {
        return id < Tag.Last ? tagNames[id] : tags.name(id, Tag.Last);
    }

    /// Attribute id of a lowercase name, adding it if unknown. 0 if out of memory.
    uint attrId(scope const(char)[] lowerName) pure
    {
        auto a = knownAttr(lowerName);
        if (a != AttrName.Undef) return a;
        return attrs.intern(lowerName, arena, AttrName.Last);
    }

    /// Attribute id of a name (any case), 0 if the document never saw it
    uint findAttrName(scope const(char)[] name) const pure
    {
        char[64] buf = void;
        Buffer!char big;
        auto lower = toLower(name, buf, big);
        if (lower is null) return 0;
        auto a = knownAttr(lower);
        if (a != AttrName.Undef) return a;
        return attrs.find(lower, AttrName.Last);
    }

    const(char)[] attrName(uint id) const pure
    {
        return id < AttrName.Last ? attrNames[id] : attrs.name(id, AttrName.Last);
    }

    // ------------------------------------------------------------ creation

    DomElement* createElement(uint tag, Ns ns) pure
    {
        auto e = arena.make!DomElement;
        if (e is null) return null;
        e.node.type = NodeType.Element;
        e.node.name = tag;
        e.node.ns = ns;
        e.node.document = &this;
        if (__ctfe) ctfeRegister(e);

        if (tag == Tag.Template && ns == Ns.Html)
        {
            e.templateContent = createFragment();
            if (e.templateContent is null) return null;
            e.templateContent.host = e;
        }

        return e;
    }

    DomCharacterData* createText(scope const(char)[] data) pure { return createCharacterData(NodeType.Text, Tag.TextNode, data); }
    DomCharacterData* createComment(scope const(char)[] data) pure { return createCharacterData(NodeType.Comment, Tag.CommentNode, data); }

    DomCharacterData* createProcessingInstruction(scope const(char)[] target, scope const(char)[] data) pure
    {
        auto pi = createCharacterData(NodeType.ProcessingInstruction, Tag.ProcessingInstructionNode, data);
        if (pi is null) return null;
        pi.target = copy(target);
        return pi;
    }

    DomDocumentType* createDocumentType(scope const(char)[] name, scope const(char)[] publicId, scope const(char)[] systemId) pure
    {
        auto d = arena.make!DomDocumentType;
        if (d is null) return null;
        d.node.type = NodeType.DocumentType;
        d.node.name = Tag.DoctypeNode;
        d.node.document = &this;
        if (__ctfe) ctfeRegister(d);
        d.name = copy(name);
        d.publicId = copy(publicId);
        d.systemId = copy(systemId);
        return d;
    }

    DomDocumentFragment* createFragment() pure
    {
        auto f = arena.make!DomDocumentFragment;
        if (f is null) return null;
        f.node.type = NodeType.DocumentFragment;
        f.node.name = Tag.DocumentNode;
        f.node.document = &this;
        if (__ctfe) ctfeRegister(f);
        return f;
    }

    /// A new attribute (not attached). The name must be lowercase.
    DomAttribute* createAttribute(scope const(char)[] lowerName, scope const(char)[] value, Ns ns = Ns.None) pure
    {
        auto id = attrId(lowerName);
        if (id == 0) return null;
        return createAttribute(id, value, ns);
    }

    /// ditto
    DomAttribute* createAttribute(uint id, scope const(char)[] value, Ns ns = Ns.None) pure
    {
        auto a = arena.make!DomAttribute;
        if (a is null) return null;
        a.name = id;
        a.ns = ns;
        a.value = copy(value);
        return a;
    }

    /// Set (or add) an attribute. The name is lowercased. It returns null if out of memory.
    DomAttribute* setAttribute(DomElement* e, scope const(char)[] name, scope const(char)[] value) pure
    {
        char[64] buf = void;
        Buffer!char big;
        auto lower = toLower(name, buf, big);
        if (lower is null) return null;

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

    /++ A copy of `src` owned by this document. Deep: with all the descendants and the template
     + contents; else only the node (and the attributes). It returns null if out of memory.
     + The visit is iterative, so deep trees don't overflow the stack.
     +/
    DomNode* importNode(const(DomNode)* src, bool deep) pure
    {
        auto root = cloneNode(src);
        if (root is null || !deep) return root;

        // `s` walks the source (template contents first, then children), `c` is its copy
        const(DomNode)* s = src;
        DomNode* c = root;

        while (true)
        {
            const(DomNode)* down = null;
            DomNode* container;
            if (s.type == NodeType.Element && s.as!DomElement.templateContent !is null
                && s.as!DomElement.templateContent.node.firstChild !is null)
            {
                down = s.as!DomElement.templateContent.node.firstChild;
                container = &c.as!DomElement.templateContent.node;
            }
            else if (s.firstChild !is null)
            {
                down = s.firstChild;
                container = c;
            }

            if (down !is null)
            {
                auto n = cloneNode(down);
                if (n is null) return null;
                container.appendChild(n);
                s = down;
                c = n;
                continue;
            }

            // Go on with a sibling, the children after a template content, or go up
            while (true)
            {
                if (s is src) return root;

                if (s.next !is null)
                {
                    auto n = cloneNode(s.next);
                    if (n is null) return null;
                    c.parent.appendChild(n);
                    s = s.next;
                    c = n;
                    break;
                }

                auto p = s.parent;
                if (p is src) return root;

                if (p.type == NodeType.DocumentFragment && p.as!DomDocumentFragment.host !is null)
                {
                    // The end of a template content: then the children of the template
                    const(DomNode)* host = &p.as!DomDocumentFragment.host.node;
                    DomNode* hostCopy = &c.parent.as!DomDocumentFragment.host.node;
                    if (host.firstChild !is null)
                    {
                        auto n = cloneNode(host.firstChild);
                        if (n is null) return null;
                        hostCopy.appendChild(n);
                        s = host.firstChild;
                        c = n;
                        break;
                    }
                    s = host;
                    c = hostCopy;
                    continue;
                }

                s = p;
                c = c.parent;
            }
        }
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

    // Only in CTFE: node -> the struct that contains it (see `DomNode.as`). At runtime it's
    // always null, but it takes 8 bytes of each document (not of each node): that's fine.
    CtfeTable ctfeContainers;


    DomCharacterData* createCharacterData(NodeType type, uint name, scope const(char)[] data) pure
    {
        auto t = arena.make!DomCharacterData;
        if (t is null) return null;
        t.node.type = type;
        t.node.name = name;
        t.node.document = &this;
        if (__ctfe) ctfeRegister(t);
        if (data.length && !t.setData(data)) return null;
        return t;
    }

    // A copy of the node alone (a template gets an empty content)
    DomNode* cloneNode(const(DomNode)* src) pure
    {
        final switch (src.type)
        {
            case NodeType.Element:
                auto se = src.as!DomElement;
                auto name = src.document is &this ? src.name : tagId(src.document.tagName(src.name));
                auto e = createElement(name, src.ns);
                if (e is null) return null;
                e.qualifiedName = copy(se.qualifiedName);

                for (const(DomAttribute)* a = se.firstAttr; a !is null; a = a.next)
                {
                    auto an = src.document is &this ? a.name : attrId(src.document.attrName(a.name));
                    auto na = createAttribute(an, a.value, a.ns);
                    if (na is null) return null;
                    na.qualifiedName = copy(a.qualifiedName);
                    e.appendAttribute(na);
                }
                return &e.node;

            case NodeType.Text, NodeType.Comment, NodeType.CDataSection, NodeType.ProcessingInstruction:
                auto scd = src.as!DomCharacterData;
                auto cd = createCharacterData(src.type, src.name, scd.data);
                if (cd is null) return null;
                cd.target = copy(scd.target);
                return &cd.node;

            case NodeType.DocumentType:
                auto sd = src.as!DomDocumentType;
                auto d = createDocumentType(sd.name, sd.publicId, sd.systemId);
                return d is null ? null : &d.node;

            case NodeType.DocumentFragment, NodeType.Document:
                auto f = createFragment();
                return f is null ? null : &f.node;
        }
    }
}

/++ ASCII lowercase: `s` itself if already lowercase, else a copy in `buf`, or in `big`
 + for long names. It returns null only if out of memory.
 +/
const(char)[] toLower(return scope const(char)[] s, return ref char[64] buf, return ref Buffer!char big) pure @trusted
{
    bool upper = false;
    foreach (c; s) if (c >= 'A' && c <= 'Z') { upper = true; break; }
    if (!upper) return s;

    if (s.length > buf.length)
    {
        big.putLower(s);
        return big.failed ? null : big[];
    }

    foreach (i, c; s) buf[i] = c >= 'A' && c <= 'Z' ? cast(char) (c | 0x20) : c;
    return buf[0 .. s.length];
}

@system unittest
{
    import core.memory : pureCalloc, pureFree;

    auto doc = cast(DomDocument*) pureCalloc(1, DomDocument.sizeof);
    scope(exit) { doc.release(); pureFree(doc); }
    doc.initialize();

    auto html = doc.createElement(Tag.Html, Ns.Html);
    doc.node.appendChild(&html.node);
    auto p = doc.createElement(doc.tagId("p"), Ns.Html);
    auto x = doc.createElement(doc.tagId("x-custom"), Ns.Html);
    html.appendChild(&p.node);
    html.appendChild(&x.node);

    assert(doc.documentElement is html);
    assert(x.localName == "x-custom");
    assert(doc.findTagName("X-CUSTOM") == x.name);

    // Long names with uppercase letters, the empty name
    enum long_ = "x-a-very-long-custom-element-name-longer-than-sixty-four-characters-in-total";
    auto l = doc.createElement(doc.tagId(long_), Ns.Html);
    assert(doc.findTagName("X-A-VERY-LONG-CUSTOM-ELEMENT-NAME-LONGER-THAN-SIXTY-FOUR-CHARACTERS-IN-TOTAL") == l.name);
    auto empty = doc.attrId("");
    assert(empty != 0 && doc.attrId("") == empty && doc.findAttrName("") == empty && doc.attrName(empty) == "");

    auto t = doc.createText("hello");
    p.appendChild(&t.node);
    t.appendData(" world, this is longer than sixteen chars");
    assert(t.data == "hello world, this is longer than sixteen chars");

    doc.setAttribute(p, "CLASS", "a b");
    assert(p.classAttr !is null && p.classAttr.value == "a b");
    assert(p.attribute("class").value == "a b");

    auto c = doc.importNode(&p.node, true);
    assert(c.firstChild !is null && c.firstChild.as!DomCharacterData.data == t.data);

    p.remove();
    assert(html.firstChild is &x.node && x.prev is null);
}

@system unittest
{
    import core.memory : pureCalloc, pureFree;

    auto doc = cast(DomDocument*) pureCalloc(1, DomDocument.sizeof);
    scope(exit) { doc.release(); pureFree(doc); }
    doc.initialize();

    // A very deep tree: the copy is iterative, so the stack doesn't overflow
    auto root = doc.createElement(Tag.Div, Ns.Html);
    DomNode* last = &root.node;
    foreach (i; 0 .. 200_000)
    {
        auto e = doc.createElement(i % 1000 == 0 ? Tag.Template : Tag.B, Ns.Html);
        auto parent = last.type == NodeType.Element && last.as!DomElement.templateContent !is null
            ? &last.as!DomElement.templateContent.node : last;
        parent.appendChild(&e.node);
        last = &e.node;
    }
    last.appendChild(&doc.createText("deep").node);

    auto copy = doc.importNode(&root.node, true);
    size_t depth = 0;
    const(DomNode)* n = copy;
    while (n.firstChildOrContent !is null) { n = n.firstChildOrContent; depth++; }
    assert(depth == 200_001 && n.as!DomCharacterData.data == "deep");
    assert(n.parentOrHost.parentOrHost !is null);

    // A shallow copy of a template has an empty content
    auto t = doc.createElement(Tag.Template, Ns.Html);
    t.templateContent.node.appendChild(&doc.createText("x").node);
    auto shallow = doc.importNode(&t.node, false);
    assert(shallow.as!DomElement.templateContent.node.firstChild is null);
    assert(doc.importNode(&t.node, true).as!DomElement.templateContent.node.firstChild.as!DomCharacterData.data == "x");
}
