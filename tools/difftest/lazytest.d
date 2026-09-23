/+ dub.sdl:
    name "lazytest"
    dependency "parserino" path="../.."
+/
/++
 Differential test: every query must give the same nodes on a lazy document
 (parsed chunk by chunk, only as needed) and on a fully parsed one.

 Usage: dub run --single lazytest.d -- [--quick] files...
+/
module lazytest;

import parserino;
import std.stdio, std.file, std.algorithm, std.array, std.conv, std.range, std.path, std.format;

enum string[] selectors = [
    "*", "p", "div p", "div > p", "a + b", "p ~ p", "#main", ".mw-body", "a[href]",
    "a[href^=\"http\"]", "a[href$=\".html\"]", "a[href*=\"wiki\"]", "[class~=\"a\"]",
    "[lang|=\"en\"]", "[type=\"text\" i]", "li:first-child", "li:last-child", "li:only-child",
    "tr:nth-child(2n+1)", "tr:nth-child(odd)", "td:nth-last-child(2)", "p:nth-of-type(2)",
    "p:nth-last-of-type(1)", "span:first-of-type", "span:last-of-type", "b:only-of-type",
    "p:empty", ":root", "div:not(.x)", "a:not([href])", "div:has(> p)", "div:has(a)",
    ":is(h1, h2, h3)", ":where(ul, ol) li", "li:nth-child(2 of .x)", "input:checked",
    "input:disabled", "input:enabled", "option:checked", "html body div",
    "body > *", "table tr td", "head title", "script", "meta[charset]", "link[rel=\"stylesheet\"]",
    "h1, h2, h3, h4, h5, h6", "ul li a", "div.a.b", "div#x.y", "*|*", "svg|rect", "img[alt=\"\"]",
    "[data-x]", "div:nth-child(-n+3)", ":first-child:last-child", "a:any-link", "a:link",
    "p:lexbor-contains(x)", "body.x p", "html[lang] b", "table b", "b i", "i b", "font", "td > b",
];

// The identity of a node: its path from the document plus its shallow serialization,
// taken when the range emits it.
string ident(Element e)
{
    size_t[] path;
    for (auto n = e; n.isValid; )
    {
        size_t i = 0;
        for (auto p = n.prev(true); p.isValid; p = p.prev(true)) i++;
        path ~= i;
        auto par = n.parent;
        if (!par.isValid) break;
        n = par;
    }
    return format("%(%s.%) %s", path.retro, e.toString(false));
}

string[] run(R)(R r, size_t limit = size_t.max)
{
    string[] res;
    foreach (e; r)
    {
        res ~= ident(e);
        if (res.length >= limit) break;
    }
    return res;
}

int failures;

void compare(string file, string what, size_t chunk, string[] eager, string[] lazy_)
{
    if (eager == lazy_) return;
    failures++;
    writefln("DIFF %s chunk=%s %s: eager %s nodes, lazy %s nodes", file.baseName, chunk, what, eager.length, lazy_.length);
    foreach (i; 0 .. max(eager.length, lazy_.length))
    {
        auto a = i < eager.length ? eager[i] : "<none>";
        auto b = i < lazy_.length ? lazy_[i] : "<none>";
        if (a != b) { writefln("  #%s\n    eager: %s\n    lazy:  %s", i, a.take(200), b.take(200)); break; }
    }
}

void main(string[] args)
{
    bool quick = args.canFind("--quick");
    auto files = args[1 .. $].filter!(a => !a.startsWith("--")).array.sort.array;
    size_t[] chunks = quick ? [7, 1024] : [1, 7, 64, 1024];

    foreach (fname; files)
    {
        auto html = cast(string) read(fname);
        auto eager = Document(html);

        // Queries: all nodes, some tags, some classes, selectors
        alias Query = string[] delegate(Document d);
        Query[string] queries;

        queries["descendants"] = (Document d) => run(d.descendants(true));
        foreach (t; ["a", "p", "td", "b", "div", "html", "body", "title", "!--", "#text", "tr", "table"])
            queries["tag:" ~ t] = ((t) => (Document d) => run(d.byTagName(t)))(t);

        string[] classes = eager.descendants.map!(e => e.classes.array).joiner.array.sort.uniq.take(quick ? 3 : 8).array;
        foreach (c; classes)
            queries["class:" ~ c] = ((c) => (Document d) => run(d.byClass(c)))(c);

        foreach (s; selectors)
        {
            try Selector(s); catch (ParserinoException) continue;
            queries["sel:" ~ s] = ((s) => (Document d) => run(d.bySelector(s)))(s);
        }

        // take(3) and element accessors in the middle of the parsing
        queries["take3+inner"] = (Document d) => d.byTagName("p").take(3).map!(e => ident(e) ~ " " ~ e.innerHTML).array;
        queries["next"] = (Document d) => d.byTagName("td").take(5).map!(e => e.next(true).isValid ? ident(e.next(true)) : "null").array;
        queries["body+title"] = (Document d) => [d.body.isValid ? ident(d.body) : "nobody", d.title];

        foreach (name, q; queries)
        {
            auto expected = q(eager);
            foreach (chunk; chunks)
            {
                if (chunk == 1 && html.length > 20_000) continue;
                auto d = Document.parseLazy(html, chunk);
                auto got = q(d);
                compare(fname, name, chunk, expected, got);
            }
        }

        // The whole lazy document, after a partial query, must serialize the same
        auto d = Document.parseLazy(html, 7);
        d.bySelector("p").take(2).walkLength;
        if (d.toString != eager.toString) { failures++; writeln("DIFF ", fname.baseName, " toString"); }
    }

    writeln(files.length, " files, ", failures, " failures");
    if (failures) throw new Exception("lazy/eager mismatch");
}
