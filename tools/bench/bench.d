/+ dub.sdl:
    name "bench"
    dependency "parserino" path="../.."
    dflags "-O3" "-mcpu=native" platform="ldc"
+/
/++
 Benchmark of parsing (full and lazy), `ctDocument`, queries and serialization.
 See README.md for the instructions (fixed core, compiler flags).

 Usage: bench [--rounds N] [--only name] [files...]   (default: the real_* pages of tools/corpus/files)
   --only name   run only the measures whose name starts with `name` (for profiling)
+/
module bench;

import parserino;
import std.stdio, std.file, std.path, std.algorithm, std.array, std.range, std.conv, std.format;
import std.datetime.stopwatch;

// A template for ctDocument, built at compile time (about 60 KB)
enum string ctHtml = "<!DOCTYPE html><html><head><title>Bench</title></head><body><table>"
    ~ `<tr class="row"><td class="a">cell <b>bold</b></td><td><a href="/x">link</a></td></tr>`.replicate(600)
    ~ "</table></body></html>";

enum string[] selectors = ["a[href]", "div p", "ul > li:nth-child(2n+1)", ".mw-body a", "table tr td b", "h1, h2, h3"];

// The median time (in µs) of `rounds` runs of `fn`
double median(size_t rounds, scope void delegate() fn)
{
    if (rounds == 0) return 0;
    double[] times;
    foreach (_; 0 .. rounds)
    {
        auto sw = StopWatch(AutoStart.yes);
        fn();
        times ~= sw.peek.total!"nsecs" / 1000.0;
    }
    times.sort();
    return times[$ / 2];
}

void main(string[] args)
{
    size_t rounds = 30;
    string only;
    string[] files;
    for (size_t i = 1; i < args.length; i++)
    {
        if (args[i] == "--rounds") rounds = args[++i].to!size_t;
        else if (args[i] == "--only") only = args[++i];
        else files ~= args[i];
    }
    if (files.length == 0)
        files = dirEntries(buildPath(__FILE_FULL_PATH__.dirName, "../corpus/files"), "real_*", SpanMode.shallow)
            .map!(e => e.name).array.sort.array;

    auto pages = files.map!(f => readText(f)).array;
    size_t total = pages.map!(p => p.length).sum;
    writefln("%d files, %.2f MB, median of %d rounds", pages.length, total / 1e6, rounds);

    // With --only, the other measures run 0 rounds
    size_t roundsOf(string name) { return only.length && !name.startsWith(only) ? 0 : rounds; }

    void report(string name, double us, size_t bytes = 0)
    {
        if (us == 0) return;
        if (bytes) writefln("%-28s %10.0f µs  %8.1f MB/s", name, us, bytes / us);
        else writefln("%-28s %10.0f µs", name, us);
    }

    report("parse", median(roundsOf("parse"), { foreach (p; pages) { auto d = Document(p); } }), total);

    report("parse lazy + 5 links", median(roundsOf("parse lazy + 5 links"), {
        foreach (p; pages) { auto d = Document(p, Parsing.Lazy); d.byTagName("a").take(5).walkLength; }
    }));

    report("parse lazy + finish", median(roundsOf("parse lazy + finish"), {
        foreach (p; pages) { auto d = Document(p, Parsing.Lazy); d.finishParsing(); }
    }), total);

    report("ctDocument (60 KB)", median(roundsOf("ctDocument (60 KB)"), { foreach (_; 0 .. 10) { auto d = ctDocument!ctHtml; } }) / 10);
    report("parse the same 60 KB", median(roundsOf("parse the same 60 KB"), { foreach (_; 0 .. 10) { auto d = Document(ctHtml); } }) / 10);

    auto docs = pages.map!(p => Document(p)).array;

    auto sels = selectors.map!(s => Selector(s)).array;
    report("selectors", median(roundsOf("selectors"), {
        foreach (ref d; docs) foreach (ref s; sels) d.bySelector(s).walkLength;
    }));

    auto descendant = [Selector("div div a"), Selector("body div span"), Selector("ul li a"), Selector("div p"),
        Selector("#mw-content-text p a"), Selector(".infobox td a"), Selector("table td a"), Selector("nav ul li a")];
    report("descendant selectors", median(roundsOf("descendant selectors"), {
        foreach (ref d; docs) foreach (ref s; descendant) d.bySelector(s).walkLength;
    }));

    report("byTagName + byClass + byId", median(roundsOf("byTagName + byClass + byId"), {
        foreach (ref d; docs) { d.byTagName("a").walkLength; d.byClass("x").walkLength; d.byId("content"); }
    }));

    // 100 lookups of ids of each document
    auto idsOf = docs.map!(d => d.descendants.map!(e => e.id).filter!(i => i.length).take(100).array).array;
    report("byId x100", median(roundsOf("byId x100"), {
        foreach (i, ref d; docs) foreach (id; idsOf[i]) d.byId(id);
    }));

    // Into a sink that only counts: no GC in the measure
    size_t written;
    report("serialize", median(roundsOf("serialize"), {
        foreach (ref d; docs) d.toString((const(char)[] s) { written += s.length; });
    }), total);

    auto snaps = docs.map!(d => d.snapshot).array;
    report("Document(snapshot)", median(roundsOf("Document(snapshot)"), { foreach (ref s; snaps) { auto d = Document(s); } }), total);
}
