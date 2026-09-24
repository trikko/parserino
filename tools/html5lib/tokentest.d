/+ dub.sdl:
    name "tokentest"
    dependency "parserino" path="../.."
+/
/++
 Runs the tokenizer tests of html5lib-tests (tokenizer/*.test) against `parserino.html.tokenizer`,
 in one piece and one char at a time.

 Usage: tokentest [--verbose] [--update] [dir with .test files]
 The default dir is ../corpus/html5lib-tests/tokenizer (see tools/corpus/fetch.sh).
 It fails if a test not listed in expected-tokenizer-failures.txt fails.
+/
module tokentest;

import parserino.dom, parserino.html.tokenizer;
import std.stdio, std.file, std.path, std.algorithm, std.array, std.string, std.conv, std.json, std.utf;
import core.stdc.stdlib : calloc, free;

struct Collector
{
    JSONValue[] tokens;

    static bool add(void* ctx, ref Token t)
    {
        auto c = cast(Collector*) ctx;
        try c.put(t);
        catch (Exception) {}
        return true;
    }

    static bool foreign(void*) @nogc nothrow pure { return false; }

    void put(ref Token t)
    {
        final switch (t.type)
        {
            case TokenType.startTag:
            {
                JSONValue attrs = JSONValue(string[string].init);
                foreach (a; t.attributes) attrs[a.name.idup] = a.value.idup;
                auto j = JSONValue([JSONValue("StartTag"), JSONValue(t.name.idup), attrs]);
                if (t.selfClosing) j.array ~= JSONValue(true);
                tokens ~= j;
                break;
            }
            case TokenType.endTag:
                tokens ~= JSONValue([JSONValue("EndTag"), JSONValue(t.name.idup)]);
                break;
            case TokenType.text:
                if (tokens.length && tokens[$ - 1].array[0].str == "Character")
                    tokens[$ - 1].array[1] = JSONValue(tokens[$ - 1].array[1].str ~ t.data.idup);
                else
                    tokens ~= JSONValue([JSONValue("Character"), JSONValue(t.data.idup)]);
                break;
            case TokenType.comment:
                tokens ~= JSONValue([JSONValue("Comment"), JSONValue(t.data.idup)]);
                break;
            case TokenType.doctype:
                tokens ~= JSONValue([JSONValue("DOCTYPE"),
                    t.hasName ? JSONValue(t.name.idup) : JSONValue(null),
                    t.hasPublicId ? JSONValue(t.publicId.idup) : JSONValue(null),
                    t.hasSystemId ? JSONValue(t.systemId.idup) : JSONValue(null),
                    JSONValue(!t.forceQuirks)]);
                break;
            case TokenType.processingInstruction:
                tokens ~= JSONValue([JSONValue("ProcessingInstruction"), JSONValue(t.target.idup), JSONValue(t.data.idup)]);
                break;
            case TokenType.eof:
                break;
        }
    }
}

State stateByName(string s)
{
    switch (s)
    {
        case "Data state": return State.data;
        case "PLAINTEXT state": return State.plaintext;
        case "RCDATA state": return State.rcdata;
        case "RAWTEXT state": return State.rawtext;
        case "Script data state": return State.scriptData;
        case "CDATA section state": return State.cdataSection;
        default: throw new Exception("unknown state " ~ s);
    }
}

// "doubleEscaped" tests escape the strings once more (\uXXXX); lone surrogates can't be tested in UTF-8
string unescape(string s, out bool ok)
{
    ok = true;
    string r;
    for (size_t i = 0; i < s.length; i++)
    {
        if (s[i] == '\\' && i + 5 < s.length + 0 && s[i + 1] == 'u')
        {
            auto code = s[i + 2 .. i + 6].to!uint(16);
            i += 5;
            if (code >= 0xD800 && code <= 0xDFFF)
            {
                if (code < 0xDC00 && i + 6 < s.length && s[i + 1] == '\\' && s[i + 2] == 'u')
                {
                    auto low = s[i + 3 .. i + 7].to!uint(16);
                    i += 6;
                    r ~= cast(dchar) (0x10000 + ((code - 0xD800) << 10) + (low - 0xDC00));
                    continue;
                }
                ok = false;
                return null;
            }
            r ~= cast(dchar) code;
        }
        else r ~= s[i];
    }
    return r;
}

JSONValue unescapeTokens(JSONValue v, out bool ok)
{
    ok = true;
    bool k;
    switch (v.type)
    {
        case JSONType.string: auto s = unescape(v.str, k); ok = k; return JSONValue(s);
        case JSONType.array:
            JSONValue[] a;
            foreach (x; v.array) { a ~= unescapeTokens(x, k); ok = ok && k; }
            return JSONValue(a);
        case JSONType.object:
            JSONValue o = JSONValue(string[string].init);
            foreach (key, x; v.object) { o[unescape(key, k)] = unescapeTokens(x, k); ok = ok && k; }
            return o;
        default: return v;
    }
}

// Merge adjacent Character tokens of the expected output
JSONValue[] normalize(JSONValue[] tokens)
{
    JSONValue[] r;
    foreach (t; tokens)
    {
        if (t.array[0].str == "Character" && r.length && r[$ - 1].array[0].str == "Character")
            r[$ - 1].array[1] = JSONValue(r[$ - 1].array[1].str ~ t.array[1].str);
        else r ~= t;
    }
    return r;
}

JSONValue[] tokenize(string input, State state, string lastStartTag, bool oneByOne)
{
    auto doc = cast(Document*) calloc(1, Document.sizeof);
    doc.initialize();
    scope(exit) { doc.release(); free(doc); }

    Collector c;
    TokenSink sink;
    sink.context = &c;
    // The sink must be @nogc nothrow pure for the tokenizer; the test doesn't care
    sink.process = cast(bool function(void*, ref Token) @nogc nothrow pure) &Collector.add;
    sink.inForeignContent = &Collector.foreign;

    auto t = new Tokenizer(doc, sink);
    t.switchTo(state);
    if (lastStartTag.length) t.setLastStartTag(lastStartTag);

    if (oneByOne) foreach (i; 0 .. input.length) t.feed(input[i .. i + 1]);
    else t.feed(input);
    t.finish();
    return c.tokens;
}

void main(string[] args)
{
    bool verbose = args.canFind("--verbose");
    bool update = args.canFind("--update");
    args = args.filter!(a => !a.startsWith("--")).array;

    string here = __FILE_FULL_PATH__.dirName;
    string dir = args.length > 1 ? args[1] : buildPath(here, "../corpus/html5lib-tests/tokenizer");
    string expectedFile = buildPath(here, "expected-tokenizer-failures.txt");

    bool[string] known;
    if (exists(expectedFile))
        foreach (l; readText(expectedFile).splitLines)
            if (l.length && l[0] != '#') known[l] = true;

    size_t total, passed, skipped;
    string[] failures, unexpected;

    foreach (f; dirEntries(dir, "*.test", SpanMode.shallow).map!(e => e.name).array.sort)
    {
        // Only for the "XML violation" mode, not used by browsers
        if (f.baseName == "xmlViolation.test") continue;

        auto json = parseJSON(readText(f));
        auto list = "tests" in json.object ? json["tests"].array : json["xmlViolationTests"].array;

        foreach (i, test; list)
        {
            string input = test["input"].str;
            JSONValue expected = test["output"];
            if ("doubleEscaped" in test.object && test["doubleEscaped"].boolean)
            {
                bool ok1, ok2;
                input = unescape(input, ok1);
                expected = unescapeTokens(expected, ok2);
                if (!ok1 || !ok2) { skipped++; continue; }
            }

            string[] states = "initialStates" in test.object
                ? test["initialStates"].array.map!(s => s.str).array : ["Data state"];
            string last = "lastStartTag" in test.object ? test["lastStartTag"].str : "";
            auto want = normalize(expected.array);

            foreach (st; states)
                foreach (oneByOne; [false, true])
                {
                    string id = format("%s:%d:%s%s", f.baseName, i, st, oneByOne ? ":bytes" : "");
                    total++;
                    auto got = tokenize(input, stateByName(st), last, oneByOne);
                    if (JSONValue(got) == JSONValue(want)) { passed++; continue; }

                    failures ~= id;
                    if (id !in known) unexpected ~= id;
                    if (verbose && (!oneByOne || id !in known))
                    {
                        writeln("FAIL ", id, " ", test["description"].str);
                        writeln("  input    ", JSONValue(input).toString);
                        writeln("  expected ", JSONValue(want).toString);
                        writeln("  actual   ", JSONValue(got).toString);
                    }
                }
        }
    }

    writefln("%d/%d tokenizer tests passed (%d skipped: lone surrogates), %d failures (%d not in expected-tokenizer-failures.txt)",
        passed, total, skipped, failures.length, unexpected.length);

    if (update)
    {
        auto o = File(expectedFile, "w");
        o.writeln("# Tokenizer tests that fail (file:index:state[:bytes]). Regenerate with tokentest --update.");
        foreach (id; failures) o.writeln(id);
        return;
    }

    foreach (id; unexpected) writeln("UNEXPECTED FAIL ", id);
    if (unexpected.length) throw new Exception("regressions");
}
