/++
 UTF-8 decoding of the input, as the Encoding standard (the "UTF-8 decode" of the HTML parser):
 invalid bytes become U+FFFD (one for each "maximal subpart", as browsers do) and a leading
 byte order mark is removed. The input comes in chunks: a sequence can span two chunks.
+/
module parserino.html.decoder;

import parserino.arena;

struct Utf8Decoder
{
@nogc nothrow pure @safe:
    @disable this(this);

    /// Remove a byte order mark at the beginning (only for documents, not for fragments)
    bool stripBom;

    /++ Decode a chunk. It returns `chunk` itself if it's valid (the common case), else a copy
     + with the replacements, valid until the next call. An incomplete sequence at the end is kept
     + for the next chunk.
     +/
    const(char)[] decode(return scope const(char)[] chunk) return
    {
        const(char)[] data = chunk;
        if (pendingLength)
        {
            joined.clear();
            joined.put(pending[0 .. pendingLength]);
            joined.put(chunk);
            data = joined[];
            pendingLength = 0;
        }

        if (!started)
        {
            if (stripBom && data.length < 3 && isPrefixOfBom(data))
            {
                keep(data);
                hasCR = false;
                return null;
            }

            started = true;
            if (stripBom && data.length >= 3 && data[0 .. 3] == "\xEF\xBB\xBF") data = data[3 .. $];
        }

        auto valid = validLength(data, hasCR);
        if (valid == data.length) return data;

        output.clear();
        output.put(data[0 .. valid]);

        size_t i = valid;
        while (i < data.length)
        {
            auto c = cast(ubyte) data[i];
            if (c < 0x80) { if (c == '\r') hasCR = true; output.put(data[i]); i++; continue; }

            size_t needed;
            ubyte lower = 0x80, upper = 0xBF;
            if (c >= 0xC2 && c <= 0xDF) needed = 1;
            else if (c >= 0xE0 && c <= 0xEF)
            {
                needed = 2;
                if (c == 0xE0) lower = 0xA0;
                else if (c == 0xED) upper = 0x9F;
            }
            else if (c >= 0xF0 && c <= 0xF4)
            {
                needed = 3;
                if (c == 0xF0) lower = 0x90;
                else if (c == 0xF4) upper = 0x8F;
            }
            else
            {
                output.put(Replacement);
                i++;
                continue;
            }

            size_t k = 1;
            for (; k <= needed; k++)
            {
                if (i + k >= data.length)
                {
                    // Incomplete: the rest comes with the next chunk
                    keep(data[i .. $]);
                    return output[];
                }

                auto d = cast(ubyte) data[i + k];
                if (d < lower || d > upper) break;
                lower = 0x80;
                upper = 0xBF;
            }

            if (k > needed) output.put(data[i .. i + needed + 1]);
            else output.put(Replacement);   // the bytes so far are the maximal subpart; `d` is decoded again
            i += k > needed ? needed + 1 : k;
        }

        return output[];
    }

    /// The end of the input: U+FFFD if a sequence (or a BOM) is incomplete, else empty
    const(char)[] finish()
    {
        started = true;
        if (pendingLength == 0) return null;

        // The pending bytes are the beginning of a sequence: a single maximal subpart
        pendingLength = 0;
        output.clear();
        output.put(Replacement);
        hasCR = false;
        return output[];
    }

    /// Did the last result of `decode` contain a '\r'?
    bool hasCR;

    /// Out of memory
    bool failed() const { return joined.failed || output.failed; }

    private:

    enum Replacement = "\xEF\xBF\xBD";

    char[4] pending;
    size_t pendingLength;
    bool started;
    Buffer!char joined;
    Buffer!char output;

    void keep(scope const(char)[] s)
    {
        assert(s.length < pending.length);
        foreach (i, c; s) pending[i] = c;   // not a slice copy: it needs druntime (betterC)
        pendingLength = s.length;
    }

    static bool isPrefixOfBom(scope const(char)[] s) { return s.length <= 3 && s == "\xEF\xBB\xBF"[0 .. s.length]; }
}

/++ The length of the longest prefix of `s` that is valid and complete UTF-8. `hasCR` tells
 + if that prefix contains a '\r' (the tokenizer normalizes newlines): one pass for both.
 + ASCII runs are checked 16 bytes at a time.
 +/
size_t validLength(scope const(char)[] s, out bool hasCR) @nogc nothrow pure @trusted
{
    size_t i = 0;
    auto p = cast(const(ubyte)*) s.ptr;
    auto n = s.length;

    enum ulong ones = 0x0101_0101_0101_0101, high = 0x8080_8080_8080_8080, cr = 0x0D0D_0D0D_0D0D_0D0D;

    // Does the (ASCII) word contain a '\r'? (zero byte of w ^ cr)
    static bool anyCR(ulong w) { auto x = w ^ cr; return ((x - ones) & ~x & high) != 0; }

    while (i < n)
    {
        // Fast path: ASCII, 16 bytes at a time (unaligned loads)
        if (!__ctfe)
        {
            while (i + 16 <= n)
            {
                auto w = cast(const(ulong)*) (p + i);
                if ((w[0] | w[1]) & high) break;
                if (!hasCR && (anyCR(w[0]) || anyCR(w[1]))) hasCR = true;
                i += 16;
            }
            if (i >= n) break;
        }

        auto c = p[i];
        if (c < 0x80) { if (c == '\r') hasCR = true; i++; continue; }

        size_t needed;
        ubyte lower = 0x80, upper = 0xBF;
        if (c >= 0xC2 && c <= 0xDF) needed = 1;
        else if (c >= 0xE0 && c <= 0xEF)
        {
            needed = 2;
            if (c == 0xE0) lower = 0xA0;
            else if (c == 0xED) upper = 0x9F;
        }
        else if (c >= 0xF0 && c <= 0xF4)
        {
            needed = 3;
            if (c == 0xF0) lower = 0x90;
            else if (c == 0xF4) upper = 0x8F;
        }
        else return i;

        if (i + needed >= n) return i;
        foreach (k; 1 .. needed + 1)
        {
            auto d = p[i + k];
            if (d < lower || d > upper) return i;
            lower = 0x80;
            upper = 0xBF;
        }
        i += needed + 1;
    }

    return n;
}

@system unittest
{
    static string decodeAll(const(char)[][] chunks, bool bom = false)
    {
        Utf8Decoder d;
        d.stripBom = bom;
        string r;
        foreach (c; chunks) r ~= d.decode(c).idup;
        r ~= d.finish().idup;
        return r;
    }

    enum R = "\uFFFD";

    // Valid input comes back as it is
    assert(decodeAll(["hello é 😀"]) == "hello é 😀");
    bool cr;
    assert(validLength("abcdefghijklmnopé", cr) == "abcdefghijklmnopé".length && !cr);
    assert(validLength("abcdefghijklmnopqrstuvwxyz\r1234567890", cr) == 37 && cr);
    assert(validLength("abcdefghijklmnopqrstuvwxyz\x0E\x0C1234567890", cr) == 38 && !cr);
    assert(validLength("abcdefghijklmnopqrstuvwxyzé\r", cr) == 29 && cr);

    // Maximal subparts, as the Encoding standard
    assert(decodeAll(["a\xFFb"]) == "a" ~ R ~ "b");
    assert(decodeAll(["\xC0\xAF"]) == R ~ R);
    assert(decodeAll(["\xE0\x80\x80"]) == R ~ R ~ R);
    assert(decodeAll(["\xED\xA0\x80"]) == R ~ R ~ R);            // surrogate
    assert(decodeAll(["\xF4\x90\x80\x80"]) == R ~ R ~ R ~ R);    // above U+10FFFF
    assert(decodeAll(["\xE2\x82A"]) == R ~ "A");
    assert(decodeAll(["\xF0\x9F\x98"]) == R);                    // truncated at the end
    assert(decodeAll(["\xF0\x9F\x98\x80\x80"]) == "😀" ~ R);

    // Sequences split between chunks
    assert(decodeAll(["a\xF0", "\x9F", "\x98\x80b"]) == "a😀b");
    assert(decodeAll(["\xE2", "\x82", "A"]) == R ~ "A");

    // The BOM, also split
    assert(decodeAll(["\xEF\xBB\xBF<p>"], true) == "<p>");
    assert(decodeAll(["\xEF", "\xBB", "\xBFx"], true) == "x");
    assert(decodeAll(["\xEF\xBB\xBFx"]) == "\uFEFFx");
    assert(decodeAll(["x\xEF\xBB\xBF"], true) == "x\uFEFF");
    assert(decodeAll(["\xEF\xBB"], true) == R);
}
