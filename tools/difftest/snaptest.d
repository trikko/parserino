/+ dub.sdl:
    name "snaptest"
    dependency "parserino" path="../.."
+/
/++
 Round trip of the snapshots (the representation used by `ctDocument`): for each file, the document
 restored from the snapshot of a parsed document must be the same as the parsed one.

 Usage: snaptest files...
+/
module snaptest;

import parserino.dom, parserino.html.parser, parserino.html.serializer, parserino.snapshot;
import core.stdc.stdlib : calloc, free;
import std.file, std.stdio, std.path, std.datetime.stopwatch;

string toHtml(Document* d)
{
    struct Sink { string s; void put(scope const(char)[] x) { s ~= x; } }
    Sink sink;
    serialize(&d.node, sink, Serialize.tree);
    return sink.s;
}

Document* newDoc() { auto d = cast(Document*) calloc(1, Document.sizeof); d.initialize(); return d; }
void freeDoc(Document* d) { d.release(); free(d); }

int main(string[] args)
{
    size_t bad;
    Duration parseT, restoreT;
    foreach (f; args[1 .. $])
    {
        auto html = readText(f);
        auto a = newDoc();
        auto sw = StopWatch(AutoStart.yes);
        parseDocument(a, html);
        parseT += sw.peek;

        auto s = takeSnapshot(a);
        auto b = newDoc();
        sw.reset();
        s.restore(b);
        restoreT += sw.peek;

        if (toHtml(a) != toHtml(b) || (a.head is null) != (b.head is null) || (a.body is null) != (b.body is null)
            || a.compatMode != b.compatMode || (a.doctype is null) != (b.doctype is null))
        {
            bad++;
            writeln("DIFF ", f.baseName);
        }
        freeDoc(a);
        freeDoc(b);
    }
    writeln(args.length - 1, " files, ", bad, " differences; parse ", parseT.total!"msecs", " ms, restore ",
        restoreT.total!"msecs", " ms");
    return bad != 0;
}
