// Uses the parser core without druntime (-betterC): see .github/workflows/d.yml
import parserino.dom, parserino.html.parser, parserino.html.serializer, parserino.arena;
import core.stdc.stdio, core.stdc.stdlib;
extern(C) int main()
{
    auto doc = cast(Document*) calloc(1, Document.sizeof);
    doc.initialize();
    parseDocument(doc, "<p class=x>Hello <b>betterC</b>");
    struct Sink { void put(scope const(char)[] s) @nogc nothrow { printf("%.*s", cast(int) s.length, s.ptr); } }
    Sink s;
    serialize(&doc.node, s, Serialize.tree);
    printf("\n");
    doc.release();
    free(doc);
    return 0;
}
