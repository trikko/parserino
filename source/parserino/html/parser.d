/++
 The HTML parser: tokenizer + tree builder, for documents (also chunk by chunk) and fragments.
+/
module parserino.html.parser;

import parserino.dom;
import parserino.names;
import parserino.html.tokenizer;
import parserino.html.treebuilder;

@nogc nothrow pure @safe:

/++ A parser. It must not be moved after `begin` (the tokenizer points to the tree builder):
 + keep it in memory that doesn't move (heap, or a local variable used in place).
 +/
struct Parser
{
@nogc nothrow pure @safe:
    @disable this(this);

    TreeBuilder tree;
    Tokenizer tokenizer;

    /// Start parsing `doc` (an empty document)
    void begin(DomDocument* doc)
    {
        tokenizer = Tokenizer(doc, tree.sink());
        tree.beginDocument(doc, &tokenizer);
    }

    /// Parse a chunk of input. It returns false if out of memory.
    bool feed(scope const(char)[] chunk)
    {
        return tokenizer.feed(chunk) && !tree.failed;
    }

    /// End of input
    bool finish()
    {
        bool ok = tokenizer.finish() && !tree.failed;
        tree.finish();
        return ok;
    }
}

/// Parse a whole document into `doc` (an empty document)
bool parseDocument(DomDocument* doc, scope const(char)[] html)
{

    auto p = newParser();
    if (p is null) return false;
    scope(exit) freeParser(p);

    p.begin(doc);
    return p.feed(html) && p.finish();
}

/++ Parse a fragment in the context of `context` (an element of `doc`).
 + It returns a detached `<html>` element whose children are the result, or null if out of memory.
 +/
DomElement* parseFragment(DomDocument* doc, DomElement* context, scope const(char)[] html)
{

    auto p = newParser();
    if (p is null) return null;
    scope(exit) freeParser(p);

    p.tokenizer = Tokenizer(doc, p.tree.sink());
    if (!p.tree.beginFragment(doc, &p.tokenizer, context)) return null;

    if (!p.feed(html) || !p.finish()) return null;
    return p.tree.fragmentRoot;
}

/// A parser on the heap (it must not move), initialized
Parser* newParser() @trusted
{
    import core.memory : pureMalloc;
    import core.lifetime : emplace;

    if (__ctfe) return ctfeNewOne!Parser();

    auto p = cast(Parser*) pureMalloc(Parser.sizeof);
    if (p is null) return null;
    emplace(p);
    return p;
}

void freeParser(Parser* p) @trusted
{
    import core.memory : pureFree;
    if (__ctfe) return;
    destroy(*p);
    pureFree(p);
}

@system unittest
{
    import core.memory : pureCalloc, pureFree;
    import parserino.html.serializer;

    auto doc = cast(DomDocument*) pureCalloc(1, DomDocument.sizeof);
    scope(exit) { doc.release(); pureFree(doc); }
    doc.initialize();

    assert(parseDocument(doc, "<!DOCTYPE html><p class=a>Hello <b>world</p>!"));

    Buffer!char out_;
    struct Sink { Buffer!char* b; void put(scope const(char)[] s) @nogc nothrow { foreach (c; s) b.put(c); } }
    auto sink = Sink(&out_);
    serialize(&doc.node, sink, Serialize.Tree);
    assert(out_[] == `<!DOCTYPE html><html><head></head><body><p class="a">Hello <b>world</b></p><b>!</b></body></html>`);
    assert(doc.compatMode == CompatMode.NoQuirks);
    assert(doc.body !is null && doc.head !is null);
}

import parserino.arena : Buffer, ctfeNewOne;
