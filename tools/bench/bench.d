/+ dub.sdl:
    name "bench"
    dependency "parserino" path="../.."
    dflags "-O3" "-mcpu=native" platform="ldc"
+/
/++
 Benchmark of parsing (full and lazy), `ctDocument`, queries and serialization.
 See README.md for the instructions (fixed core, compiler flags).

 Usage: bench [--rounds N] [files...]   (default: the real_* pages of tools/corpus/files)
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
    string[] files;
    for (size_t i = 1; i < args.length; i++)
    {
        if (args[i] == "--rounds") rounds = args[++i].to!size_t;
        else files ~= args[i];
    }
    if (files.length == 0)
        files = dirEntries(buildPath(__FILE_FULL_PATH__.dirName, "../corpus/files"), "real_*", SpanMode.shallow)
            .map!(e => e.name).array.sort.array;

    auto pages = files.map!(f => readText(f)).array;
    size_t total = pages.map!(p => p.length).sum;
    writefln("%d files, %.2f MB, median of %d rounds", pages.length, total / 1e6, rounds);

    void report(string name, double us, size_t bytes = 0)
    {
        if (bytes) writefln("%-28s %10.0f µs  %8.1f MB/s", name, us, bytes / us);
        else writefln("%-28s %10.0f µs", name, us);
    }

    report("parse", median(rounds, { foreach (p; pages) { auto d = Document(p); } }), total);

    report("parse lazy + 5 links", median(rounds, {
        foreach (p; pages) { auto d = Document(p, Parsing.lazy_); d.byTagName("a").take(5).walkLength; }
    }));

    report("parse lazy + finish", median(rounds, {
        foreach (p; pages) { auto d = Document(p, Parsing.lazy_); d.finishParsing(); }
    }), total);

    report("ctDocument (60 KB)", median(rounds, { foreach (_; 0 .. 10) { auto d = ctDocument!ctHtml; } }) / 10);
    report("parse the same 60 KB", median(rounds, { foreach (_; 0 .. 10) { auto d = Document(ctHtml); } }) / 10);

    auto docs = pages.map!(p => Document(p)).array;

    auto sels = selectors.map!(s => Selector(s)).array;
    report("selectors", median(rounds, {
        foreach (ref d; docs) foreach (ref s; sels) d.bySelector(s).walkLength;
    }));

    report("byTagName + byClass + byId", median(rounds, {
        foreach (ref d; docs) { d.byTagName("a").walkLength; d.byClass("x").walkLength; d.byId("content"); }
    }));

    report("serialize", median(rounds, { foreach (ref d; docs) d.toString(); }), total);
}
