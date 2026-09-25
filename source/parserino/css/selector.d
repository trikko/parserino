/++
 CSS selectors: syntax tree and parser.

 The parser follows Selectors Level 4, for a static document: user-action and
 time pseudo-classes (`:hover`, `:visited`, ...) and pseudo-elements (`::before`)
 are valid but never match. It works at runtime and at compile time.

 Namespace prefixes are predefined: `html`, `svg`, `math`, `xlink`, `xml`, `xmlns`.
+/
module parserino.css.selector;

import parserino.arena;
import parserino.css.tokenizer;
import parserino.names : knownTag, knownAttr;

@nogc nothrow pure @safe:

/// How a compound selector is related to the previous one
enum Combinator : ubyte
{
    Descendant,         /// `a b`
    Child,              /// `a > b`
    NextSibling,        /// `a + b`
    SubsequentSibling,  /// `a ~ b`
}

/// Kinds of simple selectors
enum SimpleKind : ubyte
{
    Universal,      /// `*`
    Type,           /// `div`
    Id,             /// `#x`
    Class,         /// `.x`
    Attribute,      /// `[x]`, `[x=y]`, ...
    PseudoClass,    /// `:first-child`, ...
    Not,            /// `:not(list)`
    Is,            /// `:is(list)`, `:where(list)`
    Has,            /// `:has(relative list)`
    NthChild,       /// `:nth-child(an+b [of list])`
    NthLastChild,   /// `:nth-last-child(an+b [of list])`
    NthOfType,      /// `:nth-of-type(an+b)`
    NthLastOfType,  /// `:nth-last-of-type(an+b)`
    Contains,       /// `:lexbor-contains(text [i])`
    Lang,           /// `:lang(en, "fr-CH")`
    Dir,            /// `:dir(ltr)`, `:dir(rtl)`: `name` is the direction (lowercase)
    Never,          /// states of a live document (`:hover`), pseudo-elements (`::before`)
}

/// Namespace of a type or attribute selector (`svg|rect`, `[xlink|href]`): the other members are the predefined prefixes
enum NsMatch : ubyte
{
    Any,    /// `*|x`, or no prefix for type selectors
    None,   /// `|x`, or no prefix for attribute selectors
    Html,
    Svg,
    Math,
    Xlink,
    Xml,
    Xmlns,
}

/// Operator of an attribute selector
enum AttrMatch : ubyte
{
    Exists,     /// `[x]`
    Equal,      /// `[x=y]`
    Includes,   /// `[x~=y]`
    Dash,       /// `[x|=y]`
    Prefix,     /// `[x^=y]`
    Suffix,     /// `[x$=y]`
    Substring,  /// `[x*=y]`
}

/// Case sensitivity of the value of an attribute selector
enum AttrCase : ubyte
{
    Auto,          /// case-insensitive only for some html attributes (type, lang, ...)
    Insensitive,    /// `[x=y i]`
    Sensitive,      /// `[x=y s]`
}

/// Pseudo-classes without arguments that can match (`:first-child` is `FirstChild`)
enum PseudoClass : ubyte
{
    AnyLink, Blank, Checked, Disabled, Empty, Enabled, FirstChild, FirstOfType,
    LastChild, LastOfType, Link, OnlyChild, OnlyOfType, Optional, PlaceholderShown,
    ReadOnly, ReadWrite, Required, Root, Scope,
}

/// A simple selector
struct Simple
{
    SimpleKind kind;                /// what it is: the other fields depend on it
    AttrMatch match;                /// attribute selectors
    AttrCase attrCase;              /// ditto
    PseudoClass pseudo;             /// `SimpleKind.PseudoClass`
    bool insensitive;               /// `:lexbor-contains(x i)`
    NsMatch ns;                     /// type, universal and attribute selectors
    const(char)[] name;             /// type (lowercase), id, class, attribute (lowercase) or contains text
    const(char)[] rawName;          /// type and attribute: the name as written (for the non-html elements)
    uint knownId;                   /// type and attribute: the id of a known name (`Tag`, `AttrName`), else 0
    const(char)[] value;            /// attribute value
    long a;                         /// an+b
    long b;                         /// ditto
    const(SelectorList)* list;      /// argument of :not, :is, :has, :nth-*(... of list)
    const(const(char)[])[] ranges;  /// language ranges of :lang()
}

/// A sequence of simple selectors (`div.a[x]`)
struct Compound
{
    Combinator combinator;  /// relation with the previous compound (the leading one for :has)
    const(Simple)[] simples;    /// the simple selectors, all to match
}

/// A chain of compounds (`div > p a`), left to right
struct Complex
{
    const(Compound)[] compounds;    /// the compounds: the last one is the subject
}

/// A comma separated list of complex selectors
struct SelectorList
{
    const(Complex)[] items;     /// the complex selectors

    /// Does any selector need the following siblings or the children of the element?
    /// (`:last-child`, `:has()`, `:empty`, ...)
    bool looksForward() const @nogc nothrow pure
    {
        foreach (ref c; items)
            foreach (ref comp; c.compounds)
                foreach (ref s; comp.simples)
                {
                    switch (s.kind)
                    {
                        case SimpleKind.Has, SimpleKind.NthLastChild, SimpleKind.NthLastOfType, SimpleKind.Contains:
                            return true;

                        case SimpleKind.PseudoClass:
                            with (PseudoClass) switch (s.pseudo)
                            {
                                case Blank, Empty, LastChild, LastOfType, OnlyChild, OnlyOfType, Checked, PlaceholderShown: return true;
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

    /// Does any selector depend on the whole document? (`:lang()` on the `<meta>` default
    /// language, `:dir()` on the text of the ancestors with `dir=auto`)
    bool needsDocument() const @nogc nothrow pure
    {
        foreach (ref c; items)
            foreach (ref comp; c.compounds)
                foreach (ref s; comp.simples)
                {
                    if (s.kind == SimpleKind.Lang || s.kind == SimpleKind.Dir) return true;
                    if (s.list !is null && s.list.needsDocument) return true;
                }

        return false;
    }
}

/// Parse a selector list. It returns `null` on syntax errors or if out of memory.
/// All the memory comes from `arena`.
const(SelectorList)* parseSelector(const(char)[] input, ref Arena arena) @trusted // the parser keeps &arena only here
{
    auto p = Parser(input, &arena);
    auto list = p.parseList(ListKind.Complex, false);
    if (list is null || p.tokens.failed) return null;
    if (p.tokens.frontSkipSpace.type != TokenType.Eof) return null;
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
    assert(l.items[0].compounds[1].combinator == Combinator.Child);
    assert(l.items[0].compounds[1].simples[1].name == "a");

    assert(parseSelector("div >", a) is null);
    assert(parseSelector("", a) is null);
    assert(parseSelector("p::before", a) !is null);     // valid, never matches
    assert(parseSelector("p::nope", a) is null);
    assert(parseSelector(":is()", a) !is null);         // forgiving
    assert(parseSelector(":has()", a) is null);
    assert(parseSelector(":has(:has(p))", a) is null);  // :has can't be nested
    assert(parseSelector(":nth-child(2 x)", a) is null);
    assert(parseSelector("foo|p", a) is null);          // unknown namespace prefix
    assert(parseSelector("svg|rect, [xlink|href], *|*, |p", a) !is null);
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

enum ListKind { Complex, Relative }

struct Parser
{
@nogc nothrow pure @safe:
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

    ref const(Token) tok() return { return tokens.front; }
    void next() { tokens.popFront(); }

    bool isEnd()
    {
        auto t = tok.type;
        return t == TokenType.Eof || (depth > 0 && t == TokenType.RightParen);
    }

    bool isDelim(dchar c) { return tok.type == TokenType.Delim && tok.delim == c; }

    void skipSpace() { if (tok.type == TokenType.Whitespace) next(); }

    /+ A comma separated list.
     + Forgiving lists (:is, :where, :has) drop the invalid items, the others fail.
     +/
    const(SelectorList)* parseList(ListKind kind, bool forgiving)
    {
        Buffer!Complex items;

        while (true)
        {
            Complex c;
            bool ok = kind == ListKind.Relative ? parseRelative(c) : parseComplex(c);

            if (ok) items.put(c);
            else if (!forgiving || tokens.failed) return null;
            else skipToComma();

            skipSpace();

            if (tok.type == TokenType.Comma) { next(); continue; }
            if (isEnd()) break;

            // Unexpected token after a selector
            if (!forgiving) return null;
            skipToComma();
            if (tok.type == TokenType.Comma) { next(); continue; }
            break;
        }

        // A forgiving list can be empty: it matches nothing
        if (items.empty && !forgiving) return null;

        auto list = arena.make!SelectorList;
        if (list is null) return null;
        if (items.failed) { tokens.failed = true; return null; }
        list.items = arena.dup(items[]);
        return list;
    }

    // Skip an invalid item of a forgiving list (nested blocks included)
    void skipToComma()
    {
        int nested = 0;
        while (tok.type != TokenType.Eof)
        {
            auto t = tok.type;
            if (nested == 0 && (t == TokenType.Comma || t == TokenType.RightParen)) return;

            if (t == TokenType.Function || t == TokenType.LeftParen || t == TokenType.LeftSquare || t == TokenType.LeftCurly) nested++;
            else if (t == TokenType.RightParen || t == TokenType.RightSquare || t == TokenType.RightCurly) nested--;
            next();
        }
    }

    // <relative-selector>: an optional leading combinator
    bool parseRelative(ref Complex c)
    {
        auto combinator = Combinator.Descendant;
        skipSpace();

        if (isDelim('>')) { combinator = Combinator.Child; next(); }
        else if (isDelim('+')) { combinator = Combinator.NextSibling; next(); }
        else if (isDelim('~')) { combinator = Combinator.SubsequentSibling; next(); }

        return parseComplex(c, combinator);
    }

    // <complex-selector>
    bool parseComplex(ref Complex c, Combinator first = Combinator.Descendant)
    {
        Buffer!Compound compounds;
        Compound comp;

        skipSpace();
        comp.combinator = first;
        if (!parseCompound(comp)) return false;
        compounds.put(comp);

        while (true)
        {
            bool space = tok.type == TokenType.Whitespace;
            if (space) next();

            Combinator combinator = Combinator.Descendant;
            bool explicit = true;

            if (isDelim('>')) combinator = Combinator.Child;
            else if (isDelim('+')) combinator = Combinator.NextSibling;
            else if (isDelim('~')) combinator = Combinator.SubsequentSibling;
            else explicit = false;

            if (explicit)
            {
                next();
                skipSpace();
            }
            else if (!space || tok.type == TokenType.Comma || isEnd()) break;

            comp = Compound.init;
            comp.combinator = combinator;
            if (!parseCompound(comp)) return false;
            compounds.put(comp);
        }

        if (compounds.failed) { tokens.failed = true; return false; }
        c.compounds = arena.dup(compounds[]);
        return c.compounds !is null;
    }

    // <compound-selector>: [type] subclass*
    bool parseCompound(ref Compound comp)
    {
        Buffer!Simple simples;
        Simple s;

        TokenType t = tok.type;
        if (t == TokenType.Ident || isDelim('*') || isDelim('|'))
        {
            if (!parseType(s)) return false;
            setKnownId(s);
            simples.put(s);
        }

        while (true)
        {
            s = Simple.init;
            t = tok.type;

            if (t == TokenType.Hash)
            {
                s.kind = SimpleKind.Id;
                s.name = tok.text;
                next();
            }
            else if (isDelim('.'))
            {
                next();
                if (tok.type != TokenType.Ident) return false;
                s.kind = SimpleKind.Class;
                s.name = tok.text;
                next();
            }
            else if (t == TokenType.LeftSquare)
            {
                next();
                if (!parseAttribute(s)) return false;
            }
            else if (t == TokenType.Colon)
            {
                next();
                bool element;
                if (!parsePseudo(s, element)) return false;

                // A pseudo-element ends the compound
                if (element) { simples.put(s); break; }
            }
            else break;

            setKnownId(s);
            simples.put(s);
        }

        if (simples.empty) return false;
        if (simples.failed) { tokens.failed = true; return false; }
        comp.simples = arena.dup(simples[]);
        return comp.simples !is null;
    }

    // The known names have fixed ids: the matcher doesn't need to look them up in each document
    static void setKnownId(ref Simple s)
    {
        if (s.kind == SimpleKind.Type) s.knownId = knownTag(s.name);
        else if (s.kind == SimpleKind.Attribute) s.knownId = knownAttr(s.name);
    }

    // `name`, `*`, `ns|name`, `ns|*`, `*|name`, `|name`
    bool parseType(ref Simple s)
    {
        s.ns = NsMatch.Any;

        if (tok.type == TokenType.Ident)
        {
            auto name = tok.text;
            next();

            if (isDelim('|'))
            {
                if (!nsByPrefix(name, s.ns)) return false;
                next();
                return parseTypeName(s);
            }

            s.kind = SimpleKind.Type;
            s.rawName = name;
            s.name = lower(name);
            return true;
        }

        if (isDelim('*'))
        {
            next();
            if (isDelim('|')) { next(); return parseTypeName(s); }
            s.kind = SimpleKind.Universal;
            return true;
        }

        // `|name`: no namespace
        next();
        s.ns = NsMatch.None;
        return parseTypeName(s);
    }

    bool parseTypeName(ref Simple s)
    {
        if (tok.type == TokenType.Ident)
        {
            s.kind = SimpleKind.Type;
            s.rawName = tok.text;
            s.name = lower(tok.text);
            next();
            return true;
        }

        if (isDelim('*'))
        {
            s.kind = SimpleKind.Universal;
            next();
            return true;
        }

        return false;
    }

    // After '['. EOF closes the attribute selector.
    bool parseAttribute(ref Simple s)
    {
        s.kind = SimpleKind.Attribute;
        s.match = AttrMatch.Exists;

        s.ns = NsMatch.None;
        skipSpace();

        if (isDelim('|') || isDelim('*'))
        {
            // `[|x]`, `[*|x]`
            if (isDelim('*'))
            {
                next();
                if (!isDelim('|')) return false;
                s.ns = NsMatch.Any;
            }

            next();
            if (tok.type != TokenType.Ident) return false;
            s.rawName = tok.text;
            s.name = lower(tok.text);
            next();
            skipSpace();
        }
        else if (tok.type == TokenType.Ident)
        {
            auto name = tok.text;
            next();

            if (isDelim('|'))
            {
                next();
                if (tok.type != TokenType.Ident)
                {
                    // `[x|=y]`
                    s.rawName = name;
                    s.name = lower(name);
                    s.match = AttrMatch.Dash;
                    return parseAttributeValue(s);
                }

                // `[ns|x]`
                if (!nsByPrefix(name, s.ns)) return false;
                s.rawName = tok.text;
                s.name = lower(tok.text);
                next();
            }
            else
            {
                s.rawName = name;
                s.name = lower(name);
            }

            skipSpace();
        }
        else return false;

        auto t = tok.type;
        if (t == TokenType.RightSquare) { next(); return true; }
        if (t == TokenType.Eof) return true;
        if (t != TokenType.Delim) return false;

        switch (tok.delim)
        {
            case '~': s.match = AttrMatch.Includes; break;
            case '|': s.match = AttrMatch.Dash; break;
            case '^': s.match = AttrMatch.Prefix; break;
            case '$': s.match = AttrMatch.Suffix; break;
            case '*': s.match = AttrMatch.Substring; break;
            case '=':
                s.match = AttrMatch.Equal;
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
        if (tok.type != TokenType.String && tok.type != TokenType.Ident) return false;
        s.value = tok.text.length ? tok.text : "";
        next();
        skipSpace();

        if (tok.type == TokenType.RightSquare) { next(); return true; }
        if (tok.type == TokenType.Eof) return true;
        if (tok.type != TokenType.Ident || tok.text.length != 1) return false;

        switch (tok.text[0])
        {
            case 'i', 'I': s.attrCase = AttrCase.Insensitive; break;
            case 's', 'S': s.attrCase = AttrCase.Sensitive; break;
            default: return false;
        }

        next();
        skipSpace();

        if (tok.type == TokenType.RightSquare) { next(); return true; }
        return tok.type == TokenType.Eof;
    }

    // After ':'. `element` is set for pseudo-elements.
    bool parsePseudo(ref Simple s, out bool element)
    {
        // `::name`
        if (tok.type == TokenType.Colon)
        {
            next();
            if (tok.type != TokenType.Ident || !isPseudoElement(tok.text)) return false;
            next();
            s.kind = SimpleKind.Never;
            element = true;
            return true;
        }

        if (tok.type == TokenType.Ident)
        {
            auto name = tok.text;
            next();

            if (pseudoClassByName(name, s.pseudo)) { s.kind = SimpleKind.PseudoClass; return true; }
            if (isStatePseudoClass(name)) { s.kind = SimpleKind.Never; return true; }

            // Legacy pseudo-elements with a single colon
            if (eq(name, "before") || eq(name, "after") || eq(name, "first-line") || eq(name, "first-letter"))
            {
                s.kind = SimpleKind.Never;
                element = true;
                return true;
            }

            return false;
        }

        if (tok.type != TokenType.Function) return false;

        auto name = tok.text;
        next();

        depth++;
        scope(exit) depth--;

        bool ok;
        if (eq(name, "not")) { s.kind = SimpleKind.Not; ok = parseArgList(s, ListKind.Complex, false); }
        else if (eq(name, "is") || eq(name, "where")) { s.kind = SimpleKind.Is; ok = parseArgList(s, ListKind.Complex, true); }
        else if (eq(name, "current"))
        {
            // Time-dimensional: nothing is "current" in a parsed document
            ok = parseArgList(s, ListKind.Complex, true);
            s.kind = SimpleKind.Never;
            s.list = null;
        }
        else if (eq(name, "has"))
        {
            // :has() can't be nested
            if (inHas) return false;
            inHas = true;
            scope(exit) inHas = false;
            s.kind = SimpleKind.Has;
            ok = parseArgList(s, ListKind.Relative, false);
        }
        else if (eq(name, "nth-child")) { s.kind = SimpleKind.NthChild; ok = parseNth(s, true); }
        else if (eq(name, "nth-last-child")) { s.kind = SimpleKind.NthLastChild; ok = parseNth(s, true); }
        else if (eq(name, "nth-of-type")) { s.kind = SimpleKind.NthOfType; ok = parseNth(s, false); }
        else if (eq(name, "nth-last-of-type")) { s.kind = SimpleKind.NthLastOfType; ok = parseNth(s, false); }
        else if (eq(name, "lexbor-contains")) { s.kind = SimpleKind.Contains; ok = parseContains(s); }
        else if (eq(name, "lang")) { s.kind = SimpleKind.Lang; ok = parseLang(s); }
        else if (eq(name, "dir")) { s.kind = SimpleKind.Dir; ok = parseDir(s); }
        else return false;

        if (!ok) return false;
        return closeFunction();
    }

    bool inHas;

    // :lang(): comma separated idents or strings
    bool parseLang(ref Simple s)
    {
        Buffer!(const(char)[]) ranges;

        while (true)
        {
            skipSpace();
            if (tok.type != TokenType.Ident && tok.type != TokenType.String) return false;
            ranges.put(tok.text.length ? tok.text : "");
            next();
            skipSpace();

            if (tok.type != TokenType.Comma) break;
            next();
        }

        if (ranges.failed) { tokens.failed = true; return false; }
        s.ranges = arena.dup(ranges[]);
        return s.ranges !is null;
    }

    // :dir(): an ident (only ltr and rtl can match)
    bool parseDir(ref Simple s)
    {
        skipSpace();
        if (tok.type != TokenType.Ident) return false;
        s.name = lower(tok.text);
        next();
        skipSpace();
        return true;
    }

    // At the end of the arguments: ')' or EOF
    bool closeFunction()
    {
        skipSpace();
        if (tok.type == TokenType.RightParen) { next(); return true; }
        return tok.type == TokenType.Eof;
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
        if (allowOf && tok.type == TokenType.Ident && eq(tok.text, "of"))
        {
            next();
            s.list = parseList(ListKind.Complex, false);
            return s.list !is null;
        }

        return isEnd();
    }

    bool parseContains(ref Simple s)
    {
        skipSpace();
        if (tok.type != TokenType.String && tok.type != TokenType.Ident) return false;
        s.name = tok.text;
        next();
        skipSpace();

        if (tok.type == TokenType.Ident && tok.text.length == 1 && (tok.text[0] == 'i' || tok.text[0] == 'I'))
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

        if (t == TokenType.Dimension)
        {
            if (!tok.isInteger) return false;
            s.a = toLong(tok.number);
            rest = tok.text;
            if (rest[0] != 'n' && rest[0] != 'N') return false;
            rest = rest[1 .. $];
        }
        else if (t == TokenType.Number)
        {
            if (!tok.isInteger) return false;
            s.a = 0;
            s.b = toLong(tok.number);
            next();
            return true;
        }
        else if (t == TokenType.Ident)
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
            if (tok.type != TokenType.Ident) return false;
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
            if (tok.type == TokenType.Number)
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
        if (tok.type != TokenType.Number || !tok.isInteger) return false;
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

bool nsByPrefix(const(char)[] prefix, ref NsMatch ns)
{
    if (eq(prefix, "html")) ns = NsMatch.Html;
    else if (eq(prefix, "svg")) ns = NsMatch.Svg;
    else if (eq(prefix, "math") || eq(prefix, "mathml")) ns = NsMatch.Math;
    else if (eq(prefix, "xlink")) ns = NsMatch.Xlink;
    else if (eq(prefix, "xml")) ns = NsMatch.Xml;
    else if (eq(prefix, "xmlns")) ns = NsMatch.Xmlns;
    else return false;
    return true;
}

bool isPseudoElement(const(char)[] name)
{
    static immutable string[] names = [
        "after", "backdrop", "before", "cue", "file-selector-button", "first-letter", "first-line",
        "grammar-error", "marker", "placeholder", "selection", "spelling-error", "target-text",
    ];

    foreach (n; names) if (eq(name, n)) return true;
    return false;
}

// Pseudo-classes about the state of a live document: they never match a parsed document
bool isStatePseudoClass(const(char)[] name)
{
    static immutable string[] names = [
        "active", "autofill", "current", "focus", "focus-visible", "focus-within", "fullscreen", "future",
        "hover", "local-link", "modal", "past", "paused", "picture-in-picture", "playing", "popover-open",
        "target", "target-within", "user-invalid", "user-valid", "visited",
    ];

    foreach (n; names) if (eq(name, n)) return true;
    return false;
}

bool pseudoClassByName(const(char)[] name, ref PseudoClass p)
{
    static struct Entry { string name; PseudoClass id; }

    static immutable Entry[] entries = [
        Entry("any-link", PseudoClass.AnyLink),
        Entry("blank", PseudoClass.Blank), Entry("checked", PseudoClass.Checked),
        Entry("disabled", PseudoClass.Disabled), Entry("empty", PseudoClass.Empty),
        Entry("enabled", PseudoClass.Enabled), Entry("first-child", PseudoClass.FirstChild),
        Entry("first-of-type", PseudoClass.FirstOfType), Entry("last-child", PseudoClass.LastChild),
        Entry("last-of-type", PseudoClass.LastOfType), Entry("link", PseudoClass.Link),
        Entry("only-child", PseudoClass.OnlyChild), Entry("only-of-type", PseudoClass.OnlyOfType),
        Entry("optional", PseudoClass.Optional), Entry("placeholder-shown", PseudoClass.PlaceholderShown),
        Entry("read-only", PseudoClass.ReadOnly), Entry("read-write", PseudoClass.ReadWrite),
        Entry("required", PseudoClass.Required), Entry("root", PseudoClass.Root),
        Entry("scope", PseudoClass.Scope),
    ];

    foreach (ref e; entries)
        if (eq(name, e.name)) { p = e.id; return true; }

    return false;
}
