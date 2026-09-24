/++
 CSS tokenizer (CSS Syntax Level 3), limited to what selectors need.
 It works at runtime and at compile time.
+/
module parserino.css.tokenizer;

import parserino.arena;

@nogc nothrow pure @safe:

enum TokenType : ubyte
{
    Eof,
    Ident,
    Function,      /// `name(`: `text` is the name
    AtKeyword,
    Hash,           /// `text` is the name after '#'
    String,
    BadString,
    Delim,          /// `delim` is the character
    Number,
    Percentage,
    Dimension,      /// number + `text` (the unit)
    Whitespace,
    Cdo,
    Cdc,
    Colon,
    Semicolon,
    Comma,
    LeftSquare,
    RightSquare,
    LeftParen,
    RightParen,
    LeftCurly,
    RightCurly,
}

struct Token
{
    TokenType type;
    dchar delim;            /// for `delim`
    const(char)[] text;     /// unescaped name or string value
    double number = 0;      /// for number, percentage, dimension
    bool isInteger;         /// the number has no '.' and no exponent
    bool hasSign;           /// the number starts with '+' or '-'
}

struct Tokenizer
{
@nogc nothrow pure @safe:
    @disable this(this);

    this(const(char)[] input, Arena* arena)
    {
        this.input = input;
        this.arena = arena;
    }

    /// Current token (not consumed)
    ref const(Token) front() return
    {
        if (!ready) { current = read(); ready = true; }
        return current;
    }

    /// Consume the current token
    void popFront()
    {
        if (!ready) current = read();
        ready = false;
    }

    /// Current token, skipping one whitespace token
    ref const(Token) frontSkipSpace() return
    {
        if (front.type == TokenType.Whitespace) popFront();
        return front;
    }

    /// Out of memory while unescaping
    bool failed;

    private:

    const(char)[] input;
    size_t pos;
    Arena* arena;
    Token current;
    bool ready;

    char at(size_t i) const { return pos + i < input.length ? input[pos + i] : '\0'; }
    bool more(size_t i = 0) const { return pos + i < input.length; }

    static bool isSpace(char c) { return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\f'; }
    static bool isDigit(char c) { return c >= '0' && c <= '9'; }
    static bool isHex(char c) { return isDigit(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F'); }
    static bool isNameStart(char c) { return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' || c >= 0x80; }
    static bool isName(char c) { return isNameStart(c) || isDigit(c) || c == '-'; }

    // A '\' starts a valid escape if it is not followed by a newline (or EOF inside a name is fine: U+FFFD)
    bool validEscape(size_t i) const { return at(i) == '\\' && at(i + 1) != '\n' && at(i + 1) != '\r' && at(i + 1) != '\f'; }

    bool startsIdent(size_t i) const
    {
        auto c = at(i);
        if (c == '-')
        {
            auto d = at(i + 1);
            return (more(i + 1) && (isNameStart(d) || d == '-')) || validEscape(i + 1);
        }
        if (more(i) && isNameStart(c)) return true;
        return c == '\\' && more(i) && validEscape(i);
    }

    bool startsNumber(size_t i) const
    {
        auto c = at(i);
        if (c == '+' || c == '-')
        {
            if (isDigit(at(i + 1))) return true;
            return at(i + 1) == '.' && isDigit(at(i + 2));
        }
        if (c == '.') return isDigit(at(i + 1));
        return isDigit(c);
    }

    Token read()
    {
        Token t;

        // Comments are dropped: whitespace separated by comments is a single token
        skipComments();
        if (!more()) { t.type = TokenType.Eof; return t; }

        char c = at(0);

        if (isSpace(c))
        {
            while (true)
            {
                while (more() && isSpace(at(0))) pos++;
                auto save = pos;
                skipComments();
                if (!more() || !isSpace(at(0))) { pos = save; break; }
            }

            t.type = TokenType.Whitespace;
            return t;
        }

        switch (c)
        {
            case '"': case '\'':
                return readString(c);

            case '#':
                if (more(1) && (isName(at(1)) || validEscape(1)))
                {
                    pos++;
                    t.type = TokenType.Hash;
                    t.text = readName();
                    return t;
                }
                break;

            case '(': pos++; t.type = TokenType.LeftParen; return t;
            case ')': pos++; t.type = TokenType.RightParen; return t;
            case '[': pos++; t.type = TokenType.LeftSquare; return t;
            case ']': pos++; t.type = TokenType.RightSquare; return t;
            case '{': pos++; t.type = TokenType.LeftCurly; return t;
            case '}': pos++; t.type = TokenType.RightCurly; return t;
            case ',': pos++; t.type = TokenType.Comma; return t;
            case ':': pos++; t.type = TokenType.Colon; return t;
            case ';': pos++; t.type = TokenType.Semicolon; return t;

            case '+': case '.':
                if (startsNumber(0)) return readNumeric();
                break;

            case '-':
                if (startsNumber(0)) return readNumeric();
                if (at(1) == '-' && at(2) == '>') { pos += 3; t.type = TokenType.Cdc; return t; }
                if (startsIdent(0)) return readIdentLike();
                break;

            case '<':
                if (at(1) == '!' && at(2) == '-' && at(3) == '-') { pos += 4; t.type = TokenType.Cdo; return t; }
                break;

            case '@':
                if (startsIdent(1))
                {
                    pos++;
                    t.type = TokenType.AtKeyword;
                    t.text = readName();
                    return t;
                }
                break;

            case '\\':
                if (validEscape(0)) return readIdentLike();
                break;

            default:
                if (isDigit(c)) return readNumeric();
                if (isNameStart(c)) return readIdentLike();
                break;
        }

        // A delim: a whole UTF-8 sequence counts as one character
        t.type = TokenType.Delim;
        t.delim = decodeChar();
        return t;
    }

    void skipComments()
    {
        while (at(0) == '/' && at(1) == '*')
        {
            pos += 2;
            while (more() && !(at(0) == '*' && at(1) == '/')) pos++;
            pos = more() ? pos + 2 : input.length;
        }
    }

    dchar decodeChar()
    {
        char c = at(0);
        size_t n = c < 0x80 ? 1 : c < 0xE0 ? 2 : c < 0xF0 ? 3 : 4;
        if (pos + n > input.length) n = input.length - pos;

        dchar d = n == 1 ? c : n == 2 ? c & 0x1F : n == 3 ? c & 0x0F : c & 0x07;
        foreach (i; 1 .. n) d = (d << 6) | (at(i) & 0x3F);
        pos += n;
        return d;
    }

    Token readIdentLike()
    {
        Token t;
        t.text = readName();

        if (at(0) == '(')
        {
            pos++;
            t.type = TokenType.Function;
            return t;
        }

        t.type = TokenType.Ident;
        return t;
    }

    // Name chars and escapes. The result is a slice of the input when there are no escapes.
    const(char)[] readName()
    {
        size_t start = pos;
        bool escaped = false;

        for (size_t i = pos; i < input.length; )
        {
            if (isName(input[i])) { i++; continue; }
            if (input[i] == '\\' && !(i + 1 < input.length && (input[i + 1] == '\n' || input[i + 1] == '\r' || input[i + 1] == '\f')))
            {
                escaped = true;
                break;
            }
            break;
        }

        if (!escaped)
        {
            while (more() && isName(at(0))) pos++;
            return input[start .. pos];
        }

        Buffer!char buf;
        while (more())
        {
            auto c = at(0);
            if (isName(c)) { buf.put(c); pos++; }
            else if (validEscape(0)) { pos++; putUtf8(buf, readEscape()); }
            else if (c == '\\' && !more(1)) { pos++; putUtf8(buf, 0xFFFD); }
            else break;
        }

        if (buf.failed) failed = true;
        return keep(buf[]);
    }

    // After the '\': hex digits (1-6) and an optional whitespace, or any other char
    dchar readEscape()
    {
        if (!more()) return 0xFFFD;

        if (isHex(at(0)))
        {
            uint v = 0;
            size_t n = 0;
            while (n < 6 && more() && isHex(at(0)))
            {
                auto h = at(0);
                v = v * 16 + (isDigit(h) ? h - '0' : (h | 0x20) - 'a' + 10);
                pos++;
                n++;
            }

            if (more() && isSpace(at(0)))
            {
                if (at(0) == '\r' && at(1) == '\n') pos++;
                pos++;
            }

            if (v == 0 || (v >= 0xD800 && v <= 0xDFFF) || v > 0x10FFFF) return 0xFFFD;
            return v;
        }

        return decodeChar();
    }

    Token readString(char quote)
    {
        Token t;
        pos++;

        size_t start = pos;
        bool simple = true;
        for (size_t i = pos; i < input.length && input[i] != quote; i++)
            if (input[i] == '\\' || input[i] == '\n' || input[i] == '\r' || input[i] == '\f') { simple = false; break; }

        if (simple)
        {
            while (more() && at(0) != quote) pos++;
            t.text = input[start .. pos];
            if (more()) pos++;
            t.type = TokenType.String;
            return t;
        }

        Buffer!char buf;
        while (true)
        {
            if (!more()) break;

            auto c = at(0);
            if (c == quote) { pos++; break; }

            if (c == '\n' || c == '\r' || c == '\f')
            {
                // Unescaped newline: bad string (the newline is not consumed)
                t.type = TokenType.BadString;
                return t;
            }

            if (c == '\\')
            {
                if (!more(1)) { pos++; continue; }
                auto d = at(1);
                if (d == '\n' || d == '\f') { pos += 2; continue; }
                if (d == '\r') { pos += at(2) == '\n' ? 3 : 2; continue; }
                pos++;
                putUtf8(buf, readEscape());
                continue;
            }

            buf.put(c);
            pos++;
        }

        t.type = TokenType.String;
        if (buf.failed) failed = true;
        t.text = keep(buf[]);
        return t;
    }

    Token readNumeric()
    {
        Token t;
        size_t start = pos;
        bool integer = true;

        if (at(0) == '+' || at(0) == '-') { t.hasSign = true; pos++; }
        while (isDigit(at(0))) pos++;

        if (at(0) == '.' && isDigit(at(1)))
        {
            integer = false;
            pos++;
            while (isDigit(at(0))) pos++;
        }

        if ((at(0) == 'e' || at(0) == 'E') && (isDigit(at(1)) || ((at(1) == '+' || at(1) == '-') && isDigit(at(2)))))
        {
            integer = false;
            pos += 2;
            while (isDigit(at(0))) pos++;
        }

        t.number = parseNumber(input[start .. pos]);
        t.isInteger = integer;

        if (startsIdent(0))
        {
            t.type = TokenType.Dimension;
            t.text = readName();
        }
        else if (at(0) == '%')
        {
            pos++;
            t.type = TokenType.Percentage;
        }
        else t.type = TokenType.Number;

        return t;
    }

    static double parseNumber(const(char)[] s)
    {
        size_t i = 0;
        double sign = 1;
        if (i < s.length && (s[i] == '+' || s[i] == '-')) { if (s[i] == '-') sign = -1; i++; }

        double v = 0;
        while (i < s.length && isDigit(s[i])) v = v * 10 + (s[i++] - '0');

        if (i < s.length && s[i] == '.')
        {
            i++;
            double f = 0.1;
            while (i < s.length && isDigit(s[i])) { v += (s[i++] - '0') * f; f /= 10; }
        }

        if (i < s.length && (s[i] == 'e' || s[i] == 'E'))
        {
            i++;
            int es = 1;
            if (i < s.length && (s[i] == '+' || s[i] == '-')) { if (s[i] == '-') es = -1; i++; }
            int e = 0;
            while (i < s.length && isDigit(s[i])) { if (e < 10000) e = e * 10 + (s[i] - '0'); i++; }
            foreach (_; 0 .. e) v = es > 0 ? v * 10 : v / 10;
        }

        return sign * v;
    }

    const(char)[] keep(const(char)[] s)
    {
        if (s.length == 0) return "";
        auto r = arena.dup!char(s);
        if (r is null) { failed = true; return ""; }
        return r;
    }
}

void putUtf8(ref Buffer!char buf, dchar c)
{
    if (c < 0x80) buf.put(cast(char) c);
    else if (c < 0x800) { buf.put(cast(char) (0xC0 | (c >> 6))); buf.put(cast(char) (0x80 | (c & 0x3F))); }
    else if (c < 0x10000)
    {
        buf.put(cast(char) (0xE0 | (c >> 12)));
        buf.put(cast(char) (0x80 | ((c >> 6) & 0x3F)));
        buf.put(cast(char) (0x80 | (c & 0x3F)));
    }
    else
    {
        buf.put(cast(char) (0xF0 | (c >> 18)));
        buf.put(cast(char) (0x80 | ((c >> 12) & 0x3F)));
        buf.put(cast(char) (0x80 | ((c >> 6) & 0x3F)));
        buf.put(cast(char) (0x80 | (c & 0x3F)));
    }
}
