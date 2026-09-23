/++
 CSS selectors: syntax tree and parser.

 The parser follows the grammar accepted by lexbor, so results are the same as
 the previous versions of parserino. It works at runtime and at compile time.
+/
module parserino.css.selector;

import parserino.arena;
import parserino.css.tokenizer;

@nogc nothrow:

/// How a compound selector is related to the previous one
enum Combinator : ubyte
{
    descendant,         /// `a b`
    child,              /// `a > b`
    nextSibling,        /// `a + b`
    subsequentSibling,  /// `a ~ b`
}

enum SimpleKind : ubyte
{
    universal,      /// `*`
    type,           /// `div`
    id,             /// `#x`
    class_,         /// `.x`
    attribute,      /// `[x]`, `[x=y]`, ...
    pseudoClass,    /// `:first-child`, ...
    not,            /// `:not(list)`
    is_,            /// `:is(list)`, `:where(list)`, `:current(list)`
    has,            /// `:has(relative list)`
    nthChild,       /// `:nth-child(an+b [of list])`
    nthLastChild,
    nthOfType,
    nthLastOfType,
    contains,       /// `:lexbor-contains(text [i])`
}

enum AttrMatch : ubyte
{
    exists,     /// `[x]`
    equal,      /// `[x=y]`
    includes,   /// `[x~=y]`
    dash,       /// `[x|=y]`
    prefix,     /// `[x^=y]`
    suffix,     /// `[x$=y]`
    substring,  /// `[x*=y]`
}

enum AttrCase : ubyte
{
    auto_,          /// case-insensitive only for some html attributes (type, lang, ...)
    insensitive,    /// `[x=y i]`
    sensitive,      /// `[x=y s]`
}

enum PseudoClass : ubyte
{
    active, anyLink, blank, checked, disabled, empty, enabled, firstChild, firstOfType, focus,
    hover, lastChild, lastOfType, link, onlyChild, onlyOfType, optional, placeholderShown,
    readOnly, readWrite, required, root,
}

/// A simple selector
struct Simple
{
    SimpleKind kind;
    AttrMatch match;
    AttrCase attrCase;
    PseudoClass pseudo;
    bool insensitive;               /// `:lexbor-contains(x i)`
    const(char)[] name;             /// type (lowercase), id, class, attribute (lowercase) or contains text
    const(char)[] value;            /// attribute value
    long a, b;                      /// an+b
    const(SelectorList)* list;      /// argument of :not, :is, :has, :nth-*(... of list)
}

/// A sequence of simple selectors (`div.a[x]`)
struct Compound
{
    Combinator combinator;  /// relation with the previous compound (the leading one for :has)
    const(Simple)[] simples;
}

/// A chain of compounds (`div > p a`), left to right
struct Complex
{
    const(Compound)[] compounds;
}

/// A comma separated list of complex selectors
struct SelectorList
{
    const(Complex)[] items;

    /// Does any selector need the following siblings or the children of the element?
    /// (`:last-child`, `:has()`, `:empty`, ...)
    bool looksForward() const @nogc nothrow
    {
        foreach (ref c; items)
            foreach (ref comp; c.compounds)
                foreach (ref s; comp.simples)
                {
                    switch (s.kind)
                    {
                        case SimpleKind.has, SimpleKind.nthLastChild, SimpleKind.nthLastOfType, SimpleKind.contains:
                            return true;

                        case SimpleKind.pseudoClass:
                            with (PseudoClass) switch (s.pseudo)
                            {
                                case blank, empty, lastChild, lastOfType, onlyChild, onlyOfType: return true;
                                default: break;
                            }
                            break;

                        default:
                            break;
                    }

                    if (s.list !is null && s.list.looksForward) return true;
                }

        return false;
    }
}

/// Parse a selector list. It returns `null` on syntax errors or if out of memory.
/// All the memory comes from `arena`.
const(SelectorList)* parseSelector(const(char)[] input, ref Arena arena)
{
    auto p = Parser(input, &arena);
    auto list = p.parseList(ListKind.complex, false);
    if (list is null || p.tokens.failed) return null;
    if (p.tokens.frontSkipSpace.type != TokenType.eof) return null;
    return list;
}

///
unittest
{
    Arena a;
    auto l = parseSelector("div > p.a, #x", a);
    assert(l !is null);
    assert(l.items.length == 2);
    assert(l.items[0].compounds.length == 2);
    assert(l.items[0].compounds[1].combinator == Combinator.child);
    assert(l.items[0].compounds[1].simples[1].name == "a");

    assert(parseSelector("div >", a) is null);
    assert(parseSelector("::before", a) is null);
    assert(parseSelector("", a) is null);
}

// The parser works at compile time too
unittest
{
    static bool ct()
    {
        Arena a;
        auto l = parseSelector(":is(ul, ol) > li:nth-child(2n+1 of .x):not([href$='.pdf' i])", a);
        return l !is null && l.items[0].compounds[1].simples[1].a == 2;
    }

    static assert(ct());
}

private:

enum ListKind { complex, relative }

struct Parser
{
@nogc nothrow:
    @disable this(this);

    this(const(char)[] input, Arena* arena)
    {
        tokens = Tokenizer(input, arena);
        this.arena = arena;
    }

    Tokenizer tokens;
    Arena* arena;

    // Nesting of function arguments: EOF closes them all
    int depth;

    ref const(Token) tok() { return tokens.front; }
    void next() { tokens.popFront(); }

    bool isEnd()
    {
        auto t = tok.type;
        return t == TokenType.eof || (depth > 0 && t == TokenType.rightParen);
    }

    bool isDelim(dchar c) { return tok.type == TokenType.delim && tok.delim == c; }

    void skipSpace() { if (tok.type == TokenType.whitespace) next(); }

    /+ A comma separated list.
     + Forgiving lists (:is, :where, :has) drop the invalid items, the others fail.
     +/
    const(SelectorList)* parseList(ListKind kind, bool forgiving)
    {
        Buffer!Complex items;

        while (true)
        {
            Complex c;
            bool ok = kind == ListKind.relative ? parseRelative(c) : parseComplex(c);

            if (ok) items.put(c);
            else if (!forgiving || tokens.failed) return null;
            else skipToComma();

            skipSpace();

            if (tok.type == TokenType.comma) { next(); continue; }
            if (isEnd()) break;

            // Unexpected token after a selector
            if (!forgiving) return null;
            skipToComma();
            if (tok.type == TokenType.comma) { next(); continue; }
            break;
        }

        if (items.empty) return null;

        auto list = arena.make!SelectorList;
        if (list is null) return null;
        list.items = arena.dup(items[]);
        return list;
    }

    // Skip an invalid item of a forgiving list (nested blocks included)
    void skipToComma()
    {
        int nested = 0;
        while (tok.type != TokenType.eof)
        {
            auto t = tok.type;
            if (nested == 0 && (t == TokenType.comma || t == TokenType.rightParen)) return;

            if (t == TokenType.function_ || t == TokenType.leftParen || t == TokenType.leftSquare || t == TokenType.leftCurly) nested++;
            else if (t == TokenType.rightParen || t == TokenType.rightSquare || t == TokenType.rightCurly) nested--;
            next();
        }
    }

    // <relative-selector>: an optional leading combinator
    bool parseRelative(ref Complex c)
    {
        auto combinator = Combinator.descendant;
        skipSpace();

        if (isDelim('>')) { combinator = Combinator.child; next(); }
        else if (isDelim('+')) { combinator = Combinator.nextSibling; next(); }
        else if (isDelim('~')) { combinator = Combinator.subsequentSibling; next(); }

        return parseComplex(c, combinator);
    }

    // <complex-selector>
    bool parseComplex(ref Complex c, Combinator first = Combinator.descendant)
    {
        Buffer!Compound compounds;
        Compound comp;

        skipSpace();
        comp.combinator = first;
        if (!parseCompound(comp)) return false;
        compounds.put(comp);

        while (true)
        {
            bool space = tok.type == TokenType.whitespace;
            if (space) next();

            Combinator combinator = Combinator.descendant;
            bool explicit = true;

            if (isDelim('>')) combinator = Combinator.child;
            else if (isDelim('+')) combinator = Combinator.nextSibling;
            else if (isDelim('~')) combinator = Combinator.subsequentSibling;
            else explicit = false;

            if (explicit)
            {
                next();
                skipSpace();
            }
            else if (!space || tok.type == TokenType.comma || isEnd()) break;

            comp = Compound.init;
            comp.combinator = combinator;
            if (!parseCompound(comp)) return false;
            compounds.put(comp);
        }

        c.compounds = arena.dup(compounds[]);
        return c.compounds !is null;
    }

    // <compound-selector>: [type] subclass*
    bool parseCompound(ref Compound comp)
    {
        Buffer!Simple simples;
        Simple s;

        TokenType t = tok.type;
        if (t == TokenType.ident || isDelim('*') || isDelim('|'))
        {
            if (!parseType(s)) return false;
            simples.put(s);
        }

        while (true)
        {
            s = Simple.init;
            t = tok.type;

            if (t == TokenType.hash)
            {
                s.kind = SimpleKind.id;
                s.name = tok.text;
                next();
            }
            else if (isDelim('.'))
            {
                next();
                if (tok.type != TokenType.ident) return false;
                s.kind = SimpleKind.class_;
                s.name = tok.text;
                next();
            }
            else if (t == TokenType.leftSquare)
            {
                next();
                if (!parseAttribute(s)) return false;
            }
            else if (t == TokenType.colon)
            {
                next();
                if (!parsePseudo(s)) return false;
            }
            else break;

            simples.put(s);
        }

        if (simples.empty) return false;
        comp.simples = arena.dup(simples[]);
        return comp.simples !is null;
    }

    // `name`, `*`, `ns|name`, `ns|*`, `*|name`, `|name`: the namespace is ignored
    bool parseType(ref Simple s)
    {
        if (tok.type == TokenType.ident)
        {
            s.kind = SimpleKind.type;
            s.name = lower(tok.text);
            next();
        }
        else if (isDelim('*'))
        {
            s.kind = SimpleKind.universal;
            next();
        }
        else
        {
            // `|name`
            next();
            return parseTypeAfterNs(s);
        }

        if (isDelim('|'))
        {
            next();
            return parseTypeAfterNs(s);
        }

        return true;
    }

    bool parseTypeAfterNs(ref Simple s)
    {
        if (tok.type == TokenType.ident)
        {
            s.kind = SimpleKind.type;
            s.name = lower(tok.text);
            next();
            return true;
        }

        if (isDelim('*'))
        {
            s.kind = SimpleKind.universal;
            s.name = null;
            next();
            return true;
        }

        return false;
    }

    // After '['. EOF closes the attribute selector.
    bool parseAttribute(ref Simple s)
    {
        s.kind = SimpleKind.attribute;
        s.match = AttrMatch.exists;

        skipSpace();

        if (isDelim('|'))
        {
            next();
            if (tok.type != TokenType.ident) return false;
            s.name = lower(tok.text);
            next();
            skipSpace();
        }
        else if (tok.type == TokenType.ident)
        {
            s.name = lower(tok.text);
            next();

            if (isDelim('|'))
            {
                next();
                if (tok.type != TokenType.ident)
                {
                    // `[x|=y]`
                    s.match = AttrMatch.dash;
                    return parseAttributeValue(s);
                }

                // `[ns|x]`
                s.name = lower(tok.text);
                next();
                skipSpace();
            }
            else skipSpace();
        }
        else return false;

        auto t = tok.type;
        if (t == TokenType.rightSquare) { next(); return true; }
        if (t == TokenType.eof) return true;
        if (t != TokenType.delim) return false;

        switch (tok.delim)
        {
            case '~': s.match = AttrMatch.includes; break;
            case '|': s.match = AttrMatch.dash; break;
            case '^': s.match = AttrMatch.prefix; break;
            case '$': s.match = AttrMatch.suffix; break;
            case '*': s.match = AttrMatch.substring; break;
            case '=':
                s.match = AttrMatch.equal;
                next();
                skipSpace();
                return parseAttributeString(s);
            default: return false;
        }

        next();
        return parseAttributeValue(s);
    }

    // `=value [i|s] ]`
    bool parseAttributeValue(ref Simple s)
    {
        if (!isDelim('=')) return false;
        next();
        skipSpace();
        return parseAttributeString(s);
    }

    bool parseAttributeString(ref Simple s)
    {
        if (tok.type != TokenType.string_ && tok.type != TokenType.ident) return false;
        s.value = tok.text.length ? tok.text : "";
        next();
        skipSpace();

        if (tok.type == TokenType.rightSquare) { next(); return true; }
        if (tok.type == TokenType.eof) return true;
        if (tok.type != TokenType.ident || tok.text.length != 1) return false;

        switch (tok.text[0])
        {
            case 'i', 'I': s.attrCase = AttrCase.insensitive; break;
            case 's', 'S': s.attrCase = AttrCase.sensitive; break;
            default: return false;
        }

        next();
        skipSpace();

        if (tok.type == TokenType.rightSquare) { next(); return true; }
        return tok.type == TokenType.eof;
    }

    // After ':'. Pseudo-elements and unsupported pseudo-classes are errors.
    bool parsePseudo(ref Simple s)
    {
        if (tok.type == TokenType.ident)
        {
            if (!pseudoClassByName(tok.text, s.pseudo)) return false;
            s.kind = SimpleKind.pseudoClass;
            next();
            return true;
        }

        if (tok.type != TokenType.function_) return false;

        auto name = tok.text;
        next();

        depth++;
        scope(exit) depth--;

        bool ok;
        if (eq(name, "not")) { s.kind = SimpleKind.not; ok = parseArgList(s, ListKind.complex, false); }
        else if (eq(name, "is") || eq(name, "where")) { s.kind = SimpleKind.is_; ok = parseArgList(s, ListKind.complex, true); }
        else if (eq(name, "current")) { s.kind = SimpleKind.is_; ok = parseArgList(s, ListKind.complex, false); }
        else if (eq(name, "has")) { s.kind = SimpleKind.has; ok = parseArgList(s, ListKind.relative, true); }
        else if (eq(name, "nth-child")) { s.kind = SimpleKind.nthChild; ok = parseNth(s, true); }
        else if (eq(name, "nth-last-child")) { s.kind = SimpleKind.nthLastChild; ok = parseNth(s, true); }
        else if (eq(name, "nth-of-type")) { s.kind = SimpleKind.nthOfType; ok = parseNth(s, false); }
        else if (eq(name, "nth-last-of-type")) { s.kind = SimpleKind.nthLastOfType; ok = parseNth(s, false); }
        else if (eq(name, "lexbor-contains")) { s.kind = SimpleKind.contains; ok = parseContains(s); }
        else return false;

        if (!ok) return false;
        return closeFunction();
    }

    // At the end of the arguments: ')' or EOF
    bool closeFunction()
    {
        skipSpace();
        if (tok.type == TokenType.rightParen) { next(); return true; }
        return tok.type == TokenType.eof;
    }

    // Skip the remaining arguments, up to the ')' (not consumed)
    void skipArguments()
    {
        int nested = 0;
        while (tok.type != TokenType.eof)
        {
            auto t = tok.type;
            if (nested == 0 && t == TokenType.rightParen) return;
            if (t == TokenType.function_ || t == TokenType.leftParen || t == TokenType.leftSquare || t == TokenType.leftCurly) nested++;
            else if (t == TokenType.rightParen || t == TokenType.rightSquare || t == TokenType.rightCurly) nested--;
            next();
        }
    }

    bool parseArgList(ref Simple s, ListKind kind, bool forgiving)
    {
        s.list = parseList(kind, forgiving);
        return s.list !is null;
    }

    // an+b [of S]
    bool parseNth(ref Simple s, bool allowOf)
    {
        if (!parseAnb(s)) return false;

        skipSpace();
        if (allowOf && tok.type == TokenType.ident && eq(tok.text, "of"))
        {
            next();
            s.list = parseList(ListKind.complex, false);
            return s.list !is null;
        }

        // Anything else after an+b is ignored
        skipArguments();
        return true;
    }

    bool parseContains(ref Simple s)
    {
        skipSpace();
        if (tok.type != TokenType.string_ && tok.type != TokenType.ident) return false;
        s.name = tok.text;
        next();
        skipSpace();

        if (tok.type == TokenType.ident && tok.text.length == 1 && (tok.text[0] == 'i' || tok.text[0] == 'I'))
        {
            s.insensitive = true;
            next();
            skipSpace();
        }

        return isEnd();
    }

    /+ An+B, as lexbor reads it (css-syntax-3 with a few differences):
     + `odd`, `even`, `5`, `n`, `-n`, `+n`, `2n`, `2n+1`, `2n + 1`, `2n- 1`, `-n-3`, ...
     +/
    bool parseAnb(ref Simple s)
    {
        skipSpace();

        const(char)[] rest;
        auto t = tok.type;

        if (t == TokenType.dimension)
        {
            if (!tok.isInteger) return false;
            s.a = toLong(tok.number);
            rest = tok.text;
            if (rest[0] != 'n' && rest[0] != 'N') return false;
            rest = rest[1 .. $];
        }
        else if (t == TokenType.number)
        {
            if (!tok.isInteger) return false;
            s.a = 0;
            s.b = toLong(tok.number);
            next();
            return true;
        }
        else if (t == TokenType.ident)
        {
            auto id = tok.text;
            if (eq(id, "odd")) { s.a = 2; s.b = 1; next(); return true; }
            if (eq(id, "even")) { s.a = 2; s.b = 0; next(); return true; }

            if (id[0] == 'n' || id[0] == 'N') { s.a = 1; rest = id[1 .. $]; }
            else if (id[0] == '-' && id.length > 1 && (id[1] == 'n' || id[1] == 'N')) { s.a = -1; rest = id[2 .. $]; }
            else return false;
        }
        else if (isDelim('+'))
        {
            next();
            if (tok.type != TokenType.ident) return false;
            auto id = tok.text;
            if (id[0] != 'n' && id[0] != 'N') return false;
            s.a = 1;
            rest = id[1 .. $];
        }
        else return false;

        // The token holding `n` is the current one
        if (rest.length == 0)
        {
            next();
            skipSpace();

            int sign = 0;
            if (tok.type == TokenType.number)
            {
                if (!tok.hasSign) { s.b = 0; return true; }
            }
            else if (isDelim('-') || isDelim('+'))
            {
                sign = isDelim('-') ? -1 : 1;
                next();
                skipSpace();
            }
            else { s.b = 0; return true; }

            return anbNumber(s, sign);
        }

        if (rest[0] != '-') return false;
        rest = rest[1 .. $];

        if (rest.length)
        {
            long v = 0;
            foreach (c; rest)
            {
                if (c < '0' || c > '9') return false;
                v = v * 10 + (c - '0');
            }
            s.b = -v;
            next();
            return true;
        }

        // `n-` followed by a number
        next();
        skipSpace();
        return anbNumber(s, -1);
    }

    bool anbNumber(ref Simple s, int sign)
    {
        if (tok.type != TokenType.number || !tok.isInteger) return false;
        if (sign != 0 && tok.hasSign) return false;

        s.b = toLong(tok.number);
        if (sign < 0) s.b = -s.b;
        next();
        return true;
    }

    static long toLong(double d)
    {
        if (d > cast(double) long.max) return long.max;
        if (d < cast(double) long.min) return -long.max;
        return cast(long) d;
    }

    const(char)[] lower(const(char)[] s)
    {
        bool upper = false;
        foreach (c; s) if (c >= 'A' && c <= 'Z') { upper = true; break; }
        if (!upper) return s;

        auto r = arena.alloc!char(s.length);
        if (r is null) { tokens.failed = true; return s; }
        foreach (i, c; s) r[i] = (c >= 'A' && c <= 'Z') ? cast(char) (c | 0x20) : c;
        return r;
    }
}

// ASCII case-insensitive comparison with a lowercase literal
bool eq(const(char)[] a, string lowerB)
{
    if (a.length != lowerB.length) return false;
    foreach (i, c; a)
    {
        char l = (c >= 'A' && c <= 'Z') ? cast(char) (c | 0x20) : c;
        if (l != lowerB[i]) return false;
    }
    return true;
}

bool pseudoClassByName(const(char)[] name, ref PseudoClass p)
{
    static struct Entry { string name; PseudoClass id; }

    static immutable Entry[] entries = [
        Entry("active", PseudoClass.active), Entry("any-link", PseudoClass.anyLink),
        Entry("blank", PseudoClass.blank), Entry("checked", PseudoClass.checked),
        Entry("disabled", PseudoClass.disabled), Entry("empty", PseudoClass.empty),
        Entry("enabled", PseudoClass.enabled), Entry("first-child", PseudoClass.firstChild),
        Entry("first-of-type", PseudoClass.firstOfType), Entry("focus", PseudoClass.focus),
        Entry("hover", PseudoClass.hover), Entry("last-child", PseudoClass.lastChild),
        Entry("last-of-type", PseudoClass.lastOfType), Entry("link", PseudoClass.link),
        Entry("only-child", PseudoClass.onlyChild), Entry("only-of-type", PseudoClass.onlyOfType),
        Entry("optional", PseudoClass.optional), Entry("placeholder-shown", PseudoClass.placeholderShown),
        Entry("read-only", PseudoClass.readOnly), Entry("read-write", PseudoClass.readWrite),
        Entry("required", PseudoClass.required), Entry("root", PseudoClass.root),
    ];

    foreach (ref e; entries)
        if (eq(name, e.name)) { p = e.id; return true; }

    return false;
}
