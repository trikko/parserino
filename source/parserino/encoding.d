/++
 Encodings other than UTF-8.

 `Document` takes UTF-8. For html in another encoding (old pages, files saved as windows-1252,
 UTF-16, ...) convert the bytes first:
 ---
 import parserino, parserino.encoding;
 auto doc = Document(toUtf8(cast(const(ubyte)[]) std.file.read("page.html")));
 ---
 `toUtf8` finds the encoding as the HTML standard does ("encoding sniffing"): the byte order
 mark, then the `<meta charset>` (or `http-equiv=content-type`) in the first 1024 bytes. If
 nothing says it, valid UTF-8 is UTF-8, anything else windows-1252 (what browsers use for
 western pages). With the `Content-Type` of an HTTP response, pass its charset: it wins over
 the `<meta>`.

 Supported: UTF-8, UTF-16LE, UTF-16BE, windows-1252 (also for the labels `iso-8859-1`,
 `latin1`, `us-ascii`, as the Encoding standard says), ISO-8859-2, windows-1250, windows-1251.
+/
module parserino.encoding;

import parserino : ParserinoException;

/++ The encoding of the html in `bytes`, as its canonical name ("UTF-8", "windows-1252", ...).
 + `transportCharset` is the charset of the HTTP `Content-Type`, if known: it comes after the BOM
 + and before the `<meta>`.
 +/
string sniffEncoding(const(ubyte)[] bytes, const(char)[] transportCharset = null)
{
    // 1. The byte order mark
    if (bytes.length >= 3 && bytes[0 .. 3] == [0xEF, 0xBB, 0xBF]) return "UTF-8";
    if (bytes.length >= 2 && bytes[0 .. 2] == [0xFE, 0xFF]) return "UTF-16BE";
    if (bytes.length >= 2 && bytes[0 .. 2] == [0xFF, 0xFE]) return "UTF-16LE";

    // 2. The transport layer
    if (transportCharset.length)
        if (auto e = encodingForLabel(transportCharset)) return e;

    // 3. The <meta> in the first 1024 bytes ("prescan a byte stream")
    auto found = prescan(bytes.length > 1024 ? bytes[0 .. 1024] : bytes);
    if (found.length) return found;

    // 4. No declaration: UTF-8 if it's valid UTF-8, else the default of browsers for western pages
    import parserino.html.decoder : validLength;
    bool cr;
    return validLength(cast(const(char)[]) bytes, cr) == bytes.length ? "UTF-8" : "windows-1252";
}

/++ Convert html to UTF-8. `encoding` is a label ("utf-8", "latin1", "windows-1251", ...); if
 + null it's found with `sniffEncoding` (`transportCharset` is the charset of the HTTP
 + Content-Type, if known). Invalid sequences become U+FFFD. It throws `ParserinoException` for
 + unsupported encodings.
 +/
string toUtf8(const(ubyte)[] bytes, const(char)[] encoding = null, const(char)[] transportCharset = null)
{
    string name = encoding.length ? encodingForLabel(encoding) : sniffEncoding(bytes, transportCharset);
    if (name is null) throw new ParserinoException("Unknown encoding `" ~ encoding.idup ~ "`");

    switch (name)
    {
        case "UTF-8":
        {
            // The parser validates the UTF-8 and removes the BOM
            return cast(string) bytes.idup;
        }
        case "UTF-16LE", "UTF-16BE": return fromUtf16(bytes, name == "UTF-16BE");
        case "windows-1252": return fromWindows1252(bytes);
        case "ISO-8859-2": return transcodeWith!"Latin2"(bytes);
        case "windows-1250": return transcodeWith!"Windows1250"(bytes);
        case "windows-1251": return transcodeWith!"Windows1251"(bytes);
        default: throw new ParserinoException("Unsupported encoding `" ~ name ~ "`");
    }
}

///
unittest
{
    import parserino : Document;

    // A page in windows-1252 that says so
    const(ubyte)[] latin = cast(const(ubyte)[]) "<meta charset=\"windows-1252\"><p>caf\xE9 \x80";
    assert(sniffEncoding(latin) == "windows-1252");
    assert(Document(toUtf8(latin)).body.textContent == "café €");

    // Without a declaration: UTF-8 if valid, else windows-1252
    assert(sniffEncoding(cast(const(ubyte)[]) "<p>caf\xC3\xA9") == "UTF-8");
    assert(sniffEncoding(cast(const(ubyte)[]) "<p>caf\xE9") == "windows-1252");

    // UTF-16 with a BOM; the charset of HTTP wins over the <meta>
    assert(toUtf8(cast(const(ubyte)[]) "\xFF\xFE<\0p\0>\0\xE9\0") == "<p>é");
    assert(sniffEncoding(cast(const(ubyte)[]) "<meta charset=latin1>", "utf-8") == "UTF-8");
    assert(sniffEncoding(cast(const(ubyte)[]) "<meta http-equiv=Content-Type content='text/html; charset=ISO-8859-2'>")
        == "ISO-8859-2");
    assert(toUtf8(cast(const(ubyte)[]) "\xE8", "windows-1251") == "и");
}

/// The canonical name of an encoding label ("latin1" is "windows-1252"), or null if not supported
string encodingForLabel(const(char)[] label)
{
    import std.string : strip;
    import std.uni : toLower;

    switch (label.strip.toLower)
    {
        case "unicode-1-1-utf-8", "unicode11utf8", "unicode20utf8", "utf-8", "utf8", "x-unicode20utf8":
            return "UTF-8";
        case "csunicode", "iso-10646-ucs-2", "ucs-2", "unicode", "unicodefeff", "utf-16", "utf-16le":
            return "UTF-16LE";
        case "unicodefffe", "utf-16be":
            return "UTF-16BE";
        case "ansi_x3.4-1968", "ascii", "cp1252", "cp819", "csisolatin1", "ibm819", "iso-8859-1", "iso-ir-100",
             "iso8859-1", "iso88591", "iso_8859-1", "iso_8859-1:1987", "l1", "latin1", "us-ascii", "windows-1252",
             "x-cp1252":
            return "windows-1252";
        case "csisolatin2", "iso-8859-2", "iso-ir-101", "iso8859-2", "iso88592", "iso_8859-2", "iso_8859-2:1987",
             "l2", "latin2":
            return "ISO-8859-2";
        case "cp1250", "windows-1250", "x-cp1250": return "windows-1250";
        case "cp1251", "windows-1251", "x-cp1251": return "windows-1251";
        default: return null;
    }
}

private:

// "Prescan a byte stream to determine its encoding" (HTML standard)
string prescan(const(ubyte)[] s)
{
    size_t i = 0;

    bool at(size_t k, string what)
    {
        if (k + what.length > s.length) return false;
        foreach (j, c; what)
        {
            ubyte b = s[k + j];
            if (b >= 'A' && b <= 'Z') b |= 0x20;
            if (b != c) return false;
        }
        return true;
    }

    static bool isSpace(ubyte c) { return c == 0x09 || c == 0x0A || c == 0x0C || c == 0x0D || c == 0x20; }
    static bool isAlpha(ubyte c) { return (c | 0x20) >= 'a' && (c | 0x20) <= 'z'; }

    while (i < s.length)
    {
        if (at(i, "<!--"))
        {
            // Skip to "-->" (the "--" can overlap the "<!--")
            size_t j = i + 2;
            while (j + 2 < s.length && !(s[j] == '-' && s[j + 1] == '-' && s[j + 2] == '>')) j++;
            if (j + 2 >= s.length) return null;
            i = j + 3;
            continue;
        }

        if (at(i, "<meta") && i + 5 < s.length && (isSpace(s[i + 5]) || s[i + 5] == '/'))
        {
            i += 5;
            bool gotPragma = false, needPragma = false, needSet = false;
            string charset;
            bool[string] seen;

            while (true)
            {
                string name, value;
                if (!getAttribute(s, i, name, value)) break;
                if (name in seen) continue;
                seen[name] = true;

                if (name == "http-equiv") { if (value == "content-type") gotPragma = true; }
                else if (name == "content")
                {
                    if (charset is null)
                        if (auto c = charsetFromContent(value)) { charset = c; needPragma = true; needSet = true; }
                }
                else if (name == "charset")
                {
                    charset = value;
                    needPragma = false;
                    needSet = true;
                }
            }

            if (needSet && (!needPragma || gotPragma))
            {
                auto e = encodingForLabel(charset);
                if (e == "UTF-16LE" || e == "UTF-16BE") e = "UTF-8";
                if (e !is null) return e;
            }
            continue;
        }

        if (i + 1 < s.length && s[i] == '<' && (isAlpha(s[i + 1]) || (s[i + 1] == '/' && i + 2 < s.length && isAlpha(s[i + 2]))))
        {
            // A tag: skip its name and its attributes
            i += s[i + 1] == '/' ? 2 : 1;
            while (i < s.length && !isSpace(s[i]) && s[i] != '>') i++;
            string name, value;
            while (getAttribute(s, i, name, value)) {}
            continue;
        }

        if (at(i, "<!") || at(i, "</") || at(i, "<?"))
        {
            while (i < s.length && s[i] != '>') i++;
            i++;
            continue;
        }

        i++;
    }

    return null;
}

// "Get an attribute" of the prescan: false at the end of the tag (or of the input)
bool getAttribute(const(ubyte)[] s, ref size_t i, out string name, out string value)
{
    static bool isSpace(ubyte c) { return c == 0x09 || c == 0x0A || c == 0x0C || c == 0x0D || c == 0x20; }
    static char lower(ubyte c) { return cast(char) (c >= 'A' && c <= 'Z' ? c | 0x20 : c); }

    while (i < s.length && (isSpace(s[i]) || s[i] == '/')) i++;
    if (i >= s.length || s[i] == '>') { if (i < s.length) i++; return false; }

    char[] n, v;
    while (i < s.length)
    {
        auto c = s[i];
        if (c == '=' && n.length) { i++; goto Value; }
        if (isSpace(c)) break;
        if (c == '/' || c == '>') { name = n.idup; return true; }
        n ~= lower(c);
        i++;
    }

    while (i < s.length && isSpace(s[i])) i++;
    if (i >= s.length || s[i] != '=') { name = n.idup; return true; }
    i++;

Value:
    while (i < s.length && isSpace(s[i])) i++;
    if (i < s.length && (s[i] == '"' || s[i] == '\''))
    {
        auto q = s[i++];
        while (i < s.length && s[i] != q) v ~= lower(s[i++]);
        i++;
    }
    else
    {
        while (i < s.length && !isSpace(s[i]) && s[i] != '>') v ~= lower(s[i++]);
    }

    name = n.idup;
    value = v.idup;
    return true;
}

// "Extract a character encoding from a meta element": the charset in `text/html; charset=x`
string charsetFromContent(string s)
{
    import std.string : indexOf;

    size_t pos = 0;
    while (true)
    {
        auto k = s[pos .. $].indexOf("charset");
        if (k < 0) return null;
        pos += k + 7;

        while (pos < s.length && (s[pos] == ' ' || s[pos] == '\t' || s[pos] == '\n' || s[pos] == '\f' || s[pos] == '\r')) pos++;
        if (pos >= s.length || s[pos] != '=') continue;
        pos++;
        while (pos < s.length && (s[pos] == ' ' || s[pos] == '\t' || s[pos] == '\n' || s[pos] == '\f' || s[pos] == '\r')) pos++;
        if (pos >= s.length) return null;

        if (s[pos] == '"' || s[pos] == '\'')
        {
            auto q = s[pos];
            auto end = s[pos + 1 .. $].indexOf(q);
            return end < 0 ? null : s[pos + 1 .. pos + 1 + end];
        }

        size_t e = pos;
        while (e < s.length && s[e] != ';' && s[e] != ' ' && s[e] != '\t' && s[e] != '\n' && s[e] != '\f' && s[e] != '\r') e++;
        return s[pos .. e];
    }
}

// windows-1252 as the Encoding standard: 0x80-0x9F are the windows characters, the rest is Latin-1
string fromWindows1252(const(ubyte)[] bytes)
{
    static immutable wchar[32] high = [
        0x20AC, 0x0081, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, 0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0x008D, 0x017D, 0x008F,
        0x0090, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0x009D, 0x017E, 0x0178,
    ];

    import std.array : appender;
    import std.utf : encode;

    auto r = appender!string;
    r.reserve(bytes.length);
    foreach (b; bytes)
    {
        if (b < 0x80) { r.put(cast(char) b); continue; }
        char[4] buf;
        auto n = encode(buf, b < 0xA0 ? cast(dchar) high[b - 0x80] : cast(dchar) b);
        r.put(buf[0 .. n]);
    }
    return r.data;
}

string fromUtf16(const(ubyte)[] bytes, bool bigEndian)
{
    import std.array : appender;
    import std.utf : encode;

    auto r = appender!string;
    size_t i = 0;
    if (bytes.length >= 2 && ((bigEndian && bytes[0] == 0xFE && bytes[1] == 0xFF) || (!bigEndian && bytes[0] == 0xFF && bytes[1] == 0xFE)))
        i = 2;

    uint unit(size_t k) { return bigEndian ? (bytes[k] << 8 | bytes[k + 1]) : (bytes[k + 1] << 8 | bytes[k]); }

    while (i + 1 < bytes.length)
    {
        dchar c = unit(i);
        i += 2;
        if (c >= 0xD800 && c <= 0xDBFF && i + 1 < bytes.length && unit(i) >= 0xDC00 && unit(i) <= 0xDFFF)
        {
            c = 0x10000 + ((c - 0xD800) << 10) + (unit(i) - 0xDC00);
            i += 2;
        }
        else if (c >= 0xD800 && c <= 0xDFFF) c = 0xFFFD;   // a lone surrogate

        char[4] buf;
        r.put(buf[0 .. encode(buf, c)]);
    }
    if (i < bytes.length) r.put("�");                  // an odd byte at the end
    return r.data;
}

string transcodeWith(string name)(const(ubyte)[] bytes)
{
    import std.encoding : transcode, Latin2String, Windows1250String, Windows1251String;

    mixin("alias S = " ~ name ~ "String;");
    string r;
    transcode(cast(S) bytes.idup, r);
    return r;
}
