/++
 A document tree as plain arrays, without pointers.

 D can't store pointers to struct fields (like `&element.node`) in static data, so a
 document parsed at compile time is kept this way: the nodes in tree order, each one with
 its depth. At runtime it becomes a document again with a single pass (no tokenizer, no
 tree builder, no copy of the strings).
+/
module parserino.snapshot;

import parserino.arena;
import parserino.dom;
import parserino.names;

struct Snapshot
{
    CompatMode compatMode;
    bool scripting;
    SnapshotNode[] nodes;
    SnapshotAttribute[] attributes;     // the attributes of the elements, in the same order

    /++ Rebuild the tree into `doc` (an empty document). It returns false if out of memory.
     + The document uses the strings of the snapshot without copying them: the snapshot must
     + outlive it (a static one always does).
     +/
    bool restore(DomDocument* doc) const @nogc nothrow pure @trusted
    {
        doc.compatMode = compatMode;
        doc.scripting = scripting;

        // parents[d] is the parent of the nodes at depth d
        Buffer!(DomNode*) parents;
        parents.put(&doc.node);
        size_t nextAttr = 0;

        foreach (ref r; nodes)
        {
            if (parents.failed) return false;
            parents.shrinkTo(r.depth + 1);
            DomNode* parent = parents[r.depth];
            if (r.inTemplate) parent = &parent.as!DomElement.templateContent.node;

            DomNode* n;
            final switch (r.type)
            {
                case NodeType.Element:
                    auto e = doc.createElement(r.name != 0 ? r.name : doc.tagId(r.text), r.ns);
                    if (e is null) return false;
                    e.qualifiedName = r.qualifiedName;

                    foreach (ref a; attributes[nextAttr .. nextAttr + r.attributes])
                    {
                        auto na = doc.createAttribute(a.name != 0 ? a.name : doc.attrId(a.localName), null, a.ns);
                        if (na is null) return false;
                        na.qualifiedName = a.qualifiedName;
                        na.value = a.value;
                        e.appendAttribute(na);
                    }
                    nextAttr += r.attributes;

                    n = &e.node;
                    break;

                case NodeType.Text, NodeType.Comment, NodeType.CDataSection, NodeType.ProcessingInstruction:
                    auto cd = doc.createText(null);
                    if (cd is null) return false;
                    cd.node.type = r.type;
                    cd.node.name = r.name;
                    cd.target = r.qualifiedName;
                    cd.borrowData(r.text);
                    n = &cd.node;
                    break;

                case NodeType.DocumentType:
                    auto d = doc.createDocumentType(null, null, null);
                    if (d is null) return false;
                    d.name = r.text;
                    d.publicId = r.qualifiedName;
                    d.systemId = r.systemId;
                    if (parent is &doc.node) doc.doctype = d;
                    n = &d.node;
                    break;

                case NodeType.Document, NodeType.DocumentFragment:
                    assert(0, "Not a child node");
            }

            parent.appendChild(n);
            parents.put(n);
        }

        return !parents.failed;
    }
}

struct SnapshotNode
{
    NodeType type;
    Ns ns;
    bool inTemplate;            // a child of the template content of its parent
    uint depth;                 // 0 for the children of the document
    uint name;                  // the tag id if known (else 0 and the name is in `text`)
    uint attributes;            // how many attributes

    string text;                // unknown tag name, character data, doctype name
    string qualifiedName;       // element qualified name, processing instruction target, doctype public id
    string systemId;            // doctype system id
}

struct SnapshotAttribute
{
    uint name;                  // the attribute id if known (else 0 and the name is in `localName`)
    Ns ns;
    string localName;
    string qualifiedName;
    string value;
}

/// A snapshot of `doc` (it uses the GC; it also works at compile time)
Snapshot takeSnapshot(const(DomDocument)* doc) pure
{
    Snapshot s;
    s.compatMode = doc.compatMode;
    s.scripting = doc.scripting;

    void add(const(DomNode)* n, uint depth, bool inTemplate)
    {
        SnapshotNode r;
        r.type = n.type;
        r.ns = n.ns;
        r.depth = depth;
        r.inTemplate = inTemplate;

        switch (n.type)
        {
            case NodeType.Element:
                auto e = n.as!DomElement;
                if (n.name < Tag.Last) r.name = n.name;
                else r.text = doc.tagName(n.name).idup;
                r.qualifiedName = e.qualifiedName.idup;

                for (const(DomAttribute)* a = e.firstAttr; a !is null; a = a.next)
                {
                    SnapshotAttribute sa;
                    if (a.name < AttrName.Last) sa.name = a.name;
                    else sa.localName = doc.attrName(a.name).idup;
                    sa.ns = a.ns;
                    sa.qualifiedName = a.qualifiedName.idup;
                    sa.value = a.value.idup;
                    s.attributes ~= sa;
                    r.attributes++;
                }
                break;

            case NodeType.DocumentType:
                auto d = n.as!DomDocumentType;
                r.text = d.name.idup;
                r.qualifiedName = d.publicId.idup;
                r.systemId = d.systemId.idup;
                break;

            default:
                auto cd = n.as!DomCharacterData;
                r.name = n.name;
                r.text = cd.data.idup;
                r.qualifiedName = cd.target.idup;
                break;
        }

        s.nodes ~= r;
    }

    // Visit `root` and its subtree in tree order, the template contents before the children.
    // It's iterative, so deep trees don't overflow the stack.
    void visit(const(DomNode)* root)
    {
        const(DomNode)* n = root;
        uint depth = 0;
        bool inTemplate = false;

        while (true)
        {
            add(n, depth, inTemplate);

            // Down: the template content, else the children
            if (auto first = n.firstChildOrContent)
            {
                inTemplate = first.parent !is n;
                n = first;
                depth++;
                continue;
            }
            if (n.firstChild !is null)
            {
                inTemplate = false;
                n = n.firstChild;
                depth++;
                continue;
            }

            // Next: a sibling, the children of a template after its content, or up
            while (true)
            {
                if (n is root) return;
                if (n.next !is null) { n = n.next; break; }

                auto host = n.parentOrHost;
                depth--;
                if (host !is n.parent && host.firstChild !is null)
                {
                    // The end of a template content: then the children of the template
                    n = host.firstChild;
                    inTemplate = false;
                    depth++;
                    break;
                }

                n = host;
                inTemplate = n.parent !is null && n.parent.type == NodeType.DocumentFragment;
            }
        }
    }

    for (const(DomNode)* c = doc.node.firstChild; c !is null; c = c.next)
        visit(c);


    return s;
}

/// Parse `html` and take its snapshot (for compile time: `static immutable s = parseToSnapshot(html);`)
Snapshot parseToSnapshot(string html) pure
{
    import parserino.html.parser : parseDocument;

    DomDocument d;
    d.initialize();
    parseDocument(&d, html);
    auto s = takeSnapshot(&d);
    if (!__ctfe) d.release();
    return s;
}

unittest
{
    import core.memory : pureCalloc, pureFree;
    import parserino.html.parser;
    import parserino.html.serializer;

    static string toHtml(DomDocument* d)
    {
        struct Sink { string s; void put(scope const(char)[] x) { s ~= x; } }
        Sink sink;
        serialize(&d.node, sink, Serialize.Tree);
        return sink.s;
    }

    static DomDocument* newDoc()
    {
        auto d = cast(DomDocument*) pureCalloc(1, DomDocument.sizeof);
        d.initialize();
        return d;
    }

    enum html = `<!DOCTYPE html><html lang=en><title>t</title><p class=a data-x=1>Hi<!--c--><?pi x?>`
        ~ `<template><b>in</b></template><my-tag my-attr=2><svg viewBox="0 0 1"><foreignObject/></svg>`;

    auto a = newDoc();
    scope(exit) { a.release(); pureFree(a); }
    assert(parseDocument(a, html));

    // At runtime
    auto s = takeSnapshot(a);
    auto b = newDoc();
    scope(exit) { b.release(); pureFree(b); }
    assert(s.restore(b));
    assert(toHtml(a) == toHtml(b));
    assert(b.head !is null && b.body !is null && b.doctype !is null);
    assert(b.compatMode == a.compatMode);

    // At compile time
    static immutable Snapshot ct = parseToSnapshot(html);
    auto c = newDoc();
    scope(exit) { c.release(); pureFree(c); }
    assert(ct.restore(c));
    assert(toHtml(a) == toHtml(c));

    // Changing a restored text doesn't touch the snapshot
    auto text = c.body.node.firstChild.firstChild.as!DomCharacterData;
    assert(text.data == "Hi");
    assert(text.appendData("!"));
    assert(text.data == "Hi!");
    assert(ct.nodes.length == s.nodes.length);

    // A frameset replaces the body: the body of the document is the frameset (as in the standard)
    static immutable Snapshot fs = parseToSnapshot("<span><frameset>");
    auto d = newDoc();
    scope(exit) { d.release(); pureFree(d); }
    assert(fs.restore(d));
    assert(toHtml(d) == `<html><head></head><frameset></frameset></html>`);
    assert(d.body !is null && d.body.node.isHtml(Tag.Frameset) && d.body.node.parent !is null);
}
