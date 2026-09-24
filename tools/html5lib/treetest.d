/+ dub.sdl:
    name "treetest"
    dependency "parserino" path="../.."
+/
/++
 Runs the tree construction tests (web-platform-tests html/syntax/parsing/resources/*.dat, the
 format of html5lib-tests) against the parser, in one piece and in chunks (like `Parsing.Lazy`).

 Usage: treetest [--verbose] [--update] [dir with .dat files]
   --verbose  print input, expected and actual tree of each failure
   --update   rewrite expected-failures.txt with the current failures
   --errors   list the documents where the parse errors are missing or unexpected
 The default dir is ../corpus/wpt/html/syntax/parsing/resources (see tools/corpus/fetch.sh).
 It fails if a test not listed in expected-failures.txt fails.
+/
module treetest;

import parserino.dom, parserino.names, parserino.html.parser;
import std.stdio, std.file, std.path, std.algorithm, std.array, std.string, std.conv, std.range;
import core.stdc.stdlib : calloc, free;

struct Test
{
    string file;
    size_t index;
    string data;
    string fragment;        // context, e.g. "td" or "svg path" ("" for documents)
    int scripting = -1;     // -1: both, 0: off, 1: on
    string expected;
    bool hasErrors;         // the test expects parse errors
}

Test[] readTests(string path)
{
    Test[] tests;
    Test t;
    string section;
    string[] lines;

    void flush()
    {
        if (section is null) return;
        auto text = lines.join("\n");
        switch (section)
        {
            case "data": t.data = text; break;
            case "document": t.expected = text; break;
            case "document-fragment": t.fragment = text.strip; break;
            case "errors", "new-errors": if (text.strip.length) t.hasErrors = true; break;
            default: break;
        }
        lines = null;
    }

    foreach (line; readText(path).split("\n") ~ ["#data"])
    {
        switch (line)
        {
            case "#data":
                flush();
                if (section !is null) { tests ~= t; }
                t = Test(path.baseName, tests.length);
                section = "data";
                continue;
            case "#errors", "#new-errors", "#document", "#document-fragment":
                flush();
                section = line[1 .. $];
                continue;
            case "#script-on", "#script-off":
                flush();
                t.scripting = line == "#script-on";
                section = "flag";
                continue;
            default:
                lines ~= line;
        }
    }
    // The document section ends with an empty line before the next test
    foreach (ref x; tests) x.expected = x.expected.stripRight("\n");
    return tests;
}

// The html5lib tree format
void dumpTree(const(DomNode)* n, size_t depth, ref Appender!string o)
{
    for (const(DomNode)* c = n.firstChild; c !is null; c = c.next)
        dumpNode(c, depth, o);
}

void line(ref Appender!string o, size_t depth, const(char)[] s)
{
    if (o.data.length) o.put("\n");
    o.put("| ");
    foreach (_; 0 .. depth) o.put("  ");
    o.put(s);
}

void dumpNode(const(DomNode)* c, size_t depth, ref Appender!string o)
{
    final switch (c.type)
    {
        case NodeType.Element:
        {
            auto e = cast(const(DomElement)*) c;
            string prefix = c.ns == Ns.Svg ? "svg " : c.ns == Ns.Math ? "math " : "";
            line(o, depth, "<" ~ prefix ~ e.fullName.idup ~ ">");

            string[] attrs;
            for (const(DomAttribute)* a = e.firstAttr; a !is null; a = a.next)
            {
                auto full = a.fullName.idup;
                string name = full;
                if (a.ns == Ns.Xlink || a.ns == Ns.Xml || a.ns == Ns.Xmlns)
                {
                    auto local = full.canFind(':') ? full[full.indexOf(':') + 1 .. $] : full;
                    name = (a.ns == Ns.Xlink ? "xlink " : a.ns == Ns.Xml ? "xml " : "xmlns ") ~ local;
                }
                attrs ~= name ~ "=\"" ~ (a.value is null ? "" : a.value.idup) ~ "\"";
            }
            foreach (a; attrs.sort) line(o, depth + 1, a);

            if (e.templateContent !is null)
            {
                line(o, depth + 1, "content");
                dumpTree(&e.templateContent.node, depth + 2, o);
            }
            dumpTree(c, depth + 1, o);
            break;
        }
        case NodeType.Text, NodeType.CDataSection:
            line(o, depth, "\"" ~ (cast(const(DomCharacterData)*) c).data.idup ~ "\"");
            break;
        case NodeType.Comment:
            line(o, depth, "<!-- " ~ (cast(const(DomCharacterData)*) c).data.idup ~ " -->");
            break;
        case NodeType.ProcessingInstruction:
        {
            auto pi = cast(const(DomCharacterData)*) c;
            line(o, depth, "<?" ~ pi.target.idup ~ " " ~ pi.data.idup ~ "?>");
            break;
        }
        case NodeType.DocumentType:
        {
            auto d = cast(const(DomDocumentType)*) c;
            string s = "<!DOCTYPE " ~ d.name.idup;
            if (d.publicId.length || d.systemId.length)
                s ~= " \"" ~ d.publicId.idup ~ "\" \"" ~ d.systemId.idup ~ "\"";
            line(o, depth, s ~ ">");
            break;
        }
        case NodeType.Document, NodeType.DocumentFragment:
            dumpTree(c, depth, o);
            break;
    }
}

DomDocument* newDoc(bool scripting)
{
    auto d = cast(DomDocument*) calloc(1, DomDocument.sizeof);
    d.initialize();
    d.scripting = scripting;
    return d;
}

void freeDoc(DomDocument* d) { d.release(); free(d); }

// Parse and dump; chunk = 0 parses in one piece. `errors`: did the parser find errors?
string run(ref const Test t, bool scripting, size_t chunk, out bool errors)
{
    auto doc = newDoc(scripting);
    scope(exit) freeDoc(doc);
    Appender!string o;

    if (t.fragment.length)
    {
        auto parts = t.fragment.split(" ");
        Ns ns = Ns.Html;
        string name = parts[$ - 1];
        if (parts.length == 2) ns = parts[0] == "svg" ? Ns.Svg : Ns.Math;
        auto ctx = doc.createElement(doc.tagId(name.toLower), ns);
        auto root = parseFragment(doc, ctx, t.data);
        if (root is null) return "PARSE FAILED";
        dumpTree(&root.node, 0, o);
        return o.data;
    }

    {
        auto p = newParser();
        scope(exit) freeParser(p);
        p.begin(doc);
        p.tokenizer.collectErrors = true;
        size_t step = chunk == 0 ? t.data.length + 1 : chunk;
        for (size_t i = 0; i < t.data.length; i += step)
            if (!p.feed(t.data[i .. min(i + step, t.data.length)])) return "PARSE FAILED";
        if (!p.finish()) return "PARSE FAILED";
        errors = p.tokenizer.errors.length > 0;
    }

    dumpTree(&doc.node, 0, o);
    return o.data;
}

void main(string[] args)
{
    bool verbose = args.canFind("--verbose");
    bool update = args.canFind("--update");
    bool listErrors = args.canFind("--errors");
    args = args.filter!(a => !a.startsWith("--")).array;

    string here = __FILE_FULL_PATH__.dirName;
    string dir = args.length > 1 ? args[1] : buildPath(here, "../corpus/wpt/html/syntax/parsing/resources");
    string expectedFile = buildPath(here, "expected-failures.txt");

    bool[string] known;
    if (exists(expectedFile))
        foreach (l; readText(expectedFile).splitLines)
            if (l.length && l[0] != '#') known[l.split(" ")[0]] = true;

    size_t total, passed, errorTests, errorsAgree;
    string[] failures, unexpected;

    foreach (f; dirEntries(dir, "*.dat", SpanMode.shallow).map!(e => e.name).array.sort)
    {
        // These need a script engine
        if (f.baseName.startsWith("scripted_")) continue;

        foreach (t; readTests(f))
        {
            int[] modes = t.scripting == -1 ? [0, 1] : [t.scripting];
            foreach (s; modes)
            {
                size_t[] chunks = t.fragment.length ? [0] : [0, 1, 7, 64];
                foreach (chunk; chunks)
                {
                    string id = format("%s:%d:%s%s", t.file, t.index, s ? "script-on" : "script-off",
                        chunk ? ":chunk" ~ chunk.to!string : "");
                    total++;
                    bool errors;
                    auto actual = run(t, s == 1, chunk, errors);
                    // Some newer tests don't list their errors: they can be checked only if they have a doctype
                    bool checkable = t.hasErrors || t.data.toLower.startsWith("<!doctype");
                    if (!t.fragment.length && chunk == 0 && checkable)
                    {
                        errorTests++;
                        if (errors == t.hasErrors) errorsAgree++;
                        else if (listErrors) writeln(errors ? "EXTRA ERRORS " : "MISSING ERRORS ", id, "\n", t.data, "\n");
                    }
                    if (actual == t.expected) { passed++; continue; }

                    failures ~= id;
                    if (id !in known) unexpected ~= id;
                    if (verbose && (chunk == 0 || id !in known))
                    {
                        writeln("FAIL ", id, t.fragment.length ? " (fragment " ~ t.fragment ~ ")" : "");
                        writeln("--- input\n", t.data);
                        writeln("--- expected\n", t.expected);
                        writeln("--- actual\n", actual, "\n");
                    }
                }
            }
        }
    }

    writefln("%d/%d tree construction tests passed, %d failures (%d not in expected-failures.txt); "
        ~ "parse errors found when expected (and only then) in %d/%d documents",
        passed, total, failures.length, unexpected.length, errorsAgree, errorTests);

    if (update)
    {
        auto o = File(expectedFile, "w");
        o.writeln("# Tree construction tests that fail (file:index:mode[:chunkN]). Regenerate with treetest --update.");
        foreach (id; failures) o.writeln(id);
        return;
    }

    foreach (id; unexpected) writeln("UNEXPECTED FAIL ", id);
    if (unexpected.length) throw new Exception("regressions");
}
