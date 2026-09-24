/+ dub.sdl:
    name "newparse"
    dependency "parserino" path="../.."
+/
// Parses files with the new parser (parserino.html.parser) and prints the same
// "doc" lines as dump.d, to compare the new core with the reference.
module newparse;

import parserino.dom, parserino.html.parser, parserino.html.serializer;
import std.stdio, std.file, std.path, std.algorithm, std.array;
import core.stdc.stdlib : calloc, free;

void main(string[] args)
{
    foreach (f; args[1 .. $].sort)
    {
        auto html = readText(f);
        auto doc = cast(Document*) calloc(1, Document.sizeof);
        doc.initialize();
        parseDocument(doc, html);
        string s;
        auto sink = (const(char)[] c) { s ~= c; };
        serialize(&doc.node, sink, Serialize.tree);
        writeln("=== ", f.baseName);
        writeln("doc ", s.length, " ", hashOf(s));
        if (s.length < 3000) writeln(s);

        // chunked parsing must give the same tree
        if (args.length > 1)
        foreach (chunk; 1 .. 17)
        {
            if (chunk == 1 && html.length > 50_000) continue;
            auto d2 = cast(Document*) calloc(1, Document.sizeof);
            d2.initialize();
            auto p = newParser();
            p.begin(d2);
            for (size_t i = 0; i < html.length; i += chunk) p.feed(html[i .. min(i + chunk, html.length)]);
            p.finish();
            freeParser(p);
            string s2;
            auto sink2 = (const(char)[] c) { s2 ~= c; };
            serialize(&d2.node, sink2, Serialize.tree);
            if (s2 != s) { stderr.writeln("CHUNK DIFF ", f.baseName, " ", chunk); break; }
            d2.release();
            free(d2);
        }
        doc.release();
        free(doc);
    }
}
