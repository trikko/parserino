/++
 HTML tokenizer (HTML Living Standard, "Tokenization").

 The input comes in chunks of any size: a token can span many chunks.
 Tokens are given to a sink (the tree builder) as soon as they are complete;
 their data is valid only during the call.
+/
module parserino.html.tokenizer;

import parserino.arena;
import parserino.names;
import parserino.dom : DomDocument;
import parserino.html.entities;
import parserino.html.decoder;
import parserino.html.errors;

@nogc nothrow pure @safe:

/// Token types (a text token is a run of characters)
enum TokenType : ubyte
{
    StartTag,
    EndTag,
    Text,
    Comment,
    Doctype,
    ProcessingInstruction,
    Eof,
}

/// An attribute of a tag token
struct TokenAttribute
{
    const(char)[] name;     /// lowercase
    const(char)[] value;    /// the value, with character references decoded
}

/// A token. Slices are valid only while the sink processes it.
struct Token
{
    TokenType type;     /// the token type

    /// Tag id (interned in the document) and lowercase name, for tags; the name of a doctype
    uint tag;
    const(char)[] name;                     /// ditto
    bool selfClosing;                       /// `<br/>`
    const(TokenAttribute)[] attributes;     /// of a start tag, without duplicates (end tags have none)

    /// Text, comment or processing instruction data
    const(char)[] data;
    /// The text contains U+0000
    bool hasNull;

    /// Processing instruction target
    const(char)[] target;

    /// Doctype: the force-quirks flag
    bool forceQuirks;
    bool hasName;               /// Doctype: is there a name, a public id, a system id? (missing is not empty)
    bool hasPublicId;           /// ditto
    bool hasSystemId;           /// ditto
    const(char)[] publicId;     /// Doctype identifiers
    const(char)[] systemId;     /// ditto
}

/// The receiver of the tokens (the tree builder)
struct TokenSink
{
    void* context;  /// Passed to the functions
    /// Process a token. It returns false to stop (out of memory).
    bool function(void* context, ref Token token) @nogc nothrow pure @safe process;
    /// Is the adjusted current node an element not in the html namespace? (for CDATA sections)
    bool function(void* context) @nogc nothrow pure @safe inForeignContent;
}

/++ States of the tokenizer, named after the states of the standard (`BeforeAttrName` is the
 + "before attribute name state"). The ones the tree builder can set are `Data`, `Rcdata`,
 + `Rawtext`, `ScriptData`, `Plaintext`.
 +/
enum State : ubyte
{
    Data, Rcdata, Rawtext, ScriptData, Plaintext,
    TagOpen, EndTagOpen, TagName,
    RcdataLessThan, RcdataEndTagOpen, RcdataEndTagName,
    RawtextLessThan, RawtextEndTagOpen, RawtextEndTagName,
    ScriptDataLessThan, ScriptDataEndTagOpen, ScriptDataEndTagName,
    ScriptDataEscapeStart, ScriptDataEscapeStartDash, ScriptDataEscaped, ScriptDataEscapedDash, ScriptDataEscapedDashDash,
    ScriptDataEscapedLessThan, ScriptDataEscapedEndTagOpen, ScriptDataEscapedEndTagName,
    ScriptDataDoubleEscapeStart, ScriptDataDoubleEscaped, ScriptDataDoubleEscapedDash, ScriptDataDoubleEscapedDashDash,
    ScriptDataDoubleEscapedLessThan, ScriptDataDoubleEscapeEnd,
    BeforeAttrName, AttrName, AfterAttrName, BeforeAttrValue,
    AttrValueDoubleQuoted, AttrValueSingleQuoted, AttrValueUnquoted, AfterAttrValueQuoted, SelfClosingStartTag,
    BogusComment, MarkupDeclarationOpen,
    CommentStart, CommentStartDash, Comment, CommentLessThan, CommentLessThanBang, CommentLessThanBangDash,
    CommentLessThanBangDashDash, CommentEndDash, CommentEnd, CommentEndBang,
    Doctype, BeforeDoctypeName, DoctypeName, AfterDoctypeName,
    AfterDoctypePublicKeyword, BeforeDoctypePublicId, DoctypePublicIdDoubleQuoted, DoctypePublicIdSingleQuoted,
    AfterDoctypePublicId, BetweenDoctypePublicAndSystem,
    AfterDoctypeSystemKeyword, BeforeDoctypeSystemId, DoctypeSystemIdDoubleQuoted, DoctypeSystemIdSingleQuoted,
    AfterDoctypeSystemId, BogusDoctype,
    CDataSection, CDataSectionBracket, CDataSectionEnd,
    CharRef, NamedCharRef, NumericCharRef, HexCharRefStart, DecimalCharRefStart, HexCharRef, DecimalCharRef,
    ProcessingInstructionOpen, ProcessingInstructionTarget, AfterProcessingInstructionTarget,
    ProcessingInstructionData, ProcessingInstructionQuestionable,
    AmbiguousAmpersand,
}

/// The tokenizer: `feed` it the input, then `finish`
struct Tokenizer
{
@nogc nothrow pure @safe:
    @disable this(this);

    /// Tokens go to `sink`; the tag names are interned in `document`
    this(DomDocument* document, TokenSink sink)
    {
        this.document = document;
        this.sink = sink;
    }

    /++ Set by the tree builder, while it processes a start tag (or before the input for fragments).
     + For RCDATA, RAWTEXT and script data, the current start tag is the one that closes them.
     +/
    void switchTo(State s)
    {
        state = s;
        if (s == State.Rcdata || s == State.Rawtext || s == State.ScriptData)
        {
            lastStartTag.clear();
            lastStartTag.put(tagName[]);
        }
    }

    /// Set the last start tag, which closes RCDATA, RAWTEXT and script data (for tests of the tokenizer alone)
    void setLastStartTag(scope const(char)[] name)
    {
        lastStartTag.clear();
        lastStartTag.put(name);
    }

    /// The UTF-8 decoding of the input (set `decoder.stripBom` for documents)
    Utf8Decoder decoder;

    /// Collect the parse errors in `errors` (off by default: then they cost nothing)
    bool collectErrors;

    /// The parse errors found so far (with `collectErrors`), in the order they were found
    Buffer!RawParseError errors;

    /// A parse error at the current position (the tree builder reports its errors here too)
    void error(ParseErrorCode code)
    {
        if (!collectErrors) return;
        countTo(pos);
        errors.put(RawParseError(code, line, column + 1));
    }

    /// Tokenize a chunk. It returns false on errors (out of memory).
    bool feed(scope const(char)[] chunk)
    {
        if (failed) return false;
        auto decoded = decoder.decode(chunk);
        return feedDecoded(decoded, decoder.hasCR);
    }

    // Tokenize a chunk of valid UTF-8 (`hasCR`: does it contain a '\r'?)
    private bool feedDecoded(scope const(char)[] chunk, bool hasCR)
    {
        if (decoder.failed) failed = true;
        if (failed) return false;

        // Newlines: CR LF and CR become LF (also across chunks)
        const(char)[] input = chunk;
        if (skipLF && input.length && input[0] == '\n') input = input[1 .. $];
        skipLF = false;

        if (hasCR || carry.length)
        {
            work.clear();
            work.put(carry[]);
            carry.clear();

            foreach (i, c; input)
            {
                if (c == '\r')
                {
                    work.put('\n');
                    if (i + 1 < input.length) { if (input[i + 1] == '\n') continue; }
                    else skipLF = true;
                }
                else if (c == '\n' && i > 0 && input[i - 1] == '\r') continue;
                else work.put(c);
            }

            run(work[]);
        }
        else run(input);

        if (buffersFailed()) failed = true;
        return !failed;
    }

    /// End of input: the pending data is completed and an EOF token is emitted
    bool finish()
    {
        if (failed) return false;

        // An incomplete UTF-8 sequence at the end
        if (auto rest = decoder.finish()) if (!feedDecoded(rest, false)) return false;

        eof = true;
        if (carry.length)
        {
            work.clear();
            work.put(carry[]);
            carry.clear();
            run(work[]);
        }

        handleEof();
        flushText();
        if (collectErrors) countTo(input.length);

        Token t;
        t.type = TokenType.Eof;
        emit(t);
        if (buffersFailed()) failed = true;
        return !failed;
    }

    /// Out of memory (or stopped by the sink)
    bool failed;

    private:

    DomDocument* document;
    TokenSink sink;
    State state;
    State returnState;
    bool eof;
    bool skipLF;

    // Input of the current chunk
    const(char)[] input;
    size_t pos;

    // Chars kept for the next chunk (an incomplete lookahead)
    Buffer!char carry;
    Buffer!char work;

    // Pending text
    Buffer!char text;
    bool textHasNull;

    // Current tag
    bool isEndTag;
    bool selfClosing;
    Buffer!char tagName;
    Buffer!char tokData;          // names and values of the attributes, comment and doctype data
    static struct AttrSpan { size_t name, nameLen, value, valueLen; bool drop; }
    Buffer!AttrSpan attrs;
    Buffer!TokenAttribute attrSlices;
    size_t attrStart;             // start of the current attribute name in tokData
    bool inAttr;

    // Doctype
    bool forceQuirks, hasName, hasPublic, hasSystem;
    size_t nameStart, nameLen, publicStart, publicLen, systemStart, systemLen;

    // Processing instruction
    size_t targetLen;

    // The position, for the parse errors: the chars of `input` before `counted` are counted
    uint line = 1, column;
    size_t counted;

    // The "temporary buffer" of the spec and the last start tag name
    Buffer!char temp;
    Buffer!char lastStartTag;

    // Character references
    EntityMatcher matcher;
    Buffer!char refBuf;
    uint charCode;
    bool charCodeOverflow;

    // ------------------------------------------------------------ helpers

    static bool isSpace(char c) pure { return c == ' ' || c == '\t' || c == '\n' || c == '\f'; }
    static bool isAlpha(char c) pure { return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'); }
    static bool isDigit(char c) pure { return c >= '0' && c <= '9'; }
    static bool isAlnum(char c) pure { return isAlpha(c) || isDigit(c); }
    static bool isHex(char c) pure { return isDigit(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F'); }
    static char lower(char c) pure { return c >= 'A' && c <= 'Z' ? cast(char) (c | 0x20) : c; }

    enum Replacement = "\xEF\xBF\xBD";

    // Character classes for the fast loops
    enum : ubyte { DataSpecial = 1, EndOfName = 2, EndOfAttrName = 4, EndOfUnquoted = 8, Upper = 16 }

    static immutable ubyte[256] charClass = () {
        ubyte[256] t;
        foreach (c; "<&\0") t[c] |= DataSpecial;
        foreach (c; " \t\n\f\r/>\0") t[c] |= EndOfName;
        foreach (c; " \t\n\f\r/>=\0") t[c] |= EndOfAttrName;
        foreach (c; " \t\n\f\r>&\0") t[c] |= EndOfUnquoted;
        foreach (c; 'A' .. 'Z' + 1) t[c] |= Upper;
        return t;
    }();

    /+ The index of the first `a`, `b` or `c` in `s` from `i`, or `s.length`. It reads 8 bytes at
     + a time (SWAR: a byte equal to `a` is a zero byte of `w ^ a...a`).
     +/
    static size_t findAny(char a, char b, char c)(scope const(char)[] s, size_t i) @trusted
    {
        enum ulong ones = 0x0101_0101_0101_0101, high = 0x8080_8080_8080_8080;
        enum ulong ma = ones * a, mb = ones * b, mc = ones * c;

        if (!__ctfe)
        {
            while (i + 8 <= s.length)
            {
                ulong w = *cast(const(ulong)*) (s.ptr + i);
                ulong x = w ^ ma, y = w ^ mb, z = w ^ mc;
                if ((((x - ones) & ~x) | ((y - ones) & ~y) | ((z - ones) & ~z)) & high) break;
                i += 8;
            }
        }

        while (i < s.length && s[i] != a && s[i] != b && s[i] != c) i++;
        return i;
    }

    // Did a buffer run out of memory?
    bool buffersFailed() const
    {
        return carry.failed || work.failed || text.failed || tagName.failed || tokData.failed || attrs.failed
            || attrSlices.failed || temp.failed || lastStartTag.failed || refBuf.failed;
    }

    void emitText(char c) { text.put(c); if (c == '\0') textHasNull = true; }
    void emitText(scope const(char)[] s) { text.put(s); }

    bool attributeState() const
    {
        return returnState == State.AttrValueDoubleQuoted || returnState == State.AttrValueSingleQuoted || returnState == State.AttrValueUnquoted;
    }

    // Chars consumed by a character reference: to the attribute value or to the text
    void flushRef(scope const(char)[] s)
    {
        if (attributeState) foreach (c; s) tokData.put(c);
        else emitText(s);
    }

    void emit(ref Token t)
    {
        if (failed) return;
        if (buffersFailed() || !sink.process(sink.context, t)) failed = true;
    }

    void flushText()
    {
        if (text.length == 0) return;

        Token t;
        t.type = TokenType.Text;
        t.data = text[];
        t.hasNull = textHasNull;
        emit(t);
        text.clear();
        textHasNull = false;
    }

    void startTag(bool end)
    {
        isEndTag = end;
        selfClosing = false;
        tagName.clear();
        tokData.clear();
        attrs.clear();
        inAttr = false;
    }

    void startAttribute()
    {
        endAttribute();
        attrStart = tokData.length;
        attrs.put(AttrSpan(attrStart, 0, 0, 0, false));
        inAttr = true;
    }

    // The name is complete: duplicates are dropped
    void endAttrName()
    {
        auto a = &attrs[attrs.length - 1];
        a.nameLen = tokData.length - a.name;
        a.value = tokData.length;

        auto n = tokData[][a.name .. a.name + a.nameLen];
        foreach (i; 0 .. attrs.length - 1)
        {
            auto o = attrs[i];
            if (!o.drop && tokData[][o.name .. o.name + o.nameLen] == n)
            {
                a.drop = true;
                error(ParseErrorCode.DuplicateAttribute);
                break;
            }
        }
    }

    void endAttribute()
    {
        if (!inAttr) return;
        auto a = &attrs[attrs.length - 1];
        if (a.value == 0 && a.nameLen == 0) endAttrName();
        a.valueLen = tokData.length - a.value;
        inAttr = false;
    }

    // The value starts here (after the name, '=' and spaces)
    void startValue() { attrs[attrs.length - 1].value = tokData.length; }

    void emitTag()
    {
        endAttribute();
        flushText();

        if (isEndTag && collectErrors)
        {
            if (attrs.length) error(ParseErrorCode.EndTagWithAttributes);
            if (selfClosing) error(ParseErrorCode.EndTagWithTrailingSolidus);
        }

        attrSlices.clear();
        if (!isEndTag)
        {
            foreach (ref a; attrs[])
            {
                if (a.drop) continue;
                auto d = tokData[];
                attrSlices.put(TokenAttribute(d[a.name .. a.name + a.nameLen], a.valueLen ? d[a.value .. a.value + a.valueLen] : ""));
            }
        }

        Token t;
        t.type = isEndTag ? TokenType.EndTag : TokenType.StartTag;
        t.name = tagName[];
        t.tag = document.tagId(t.name);
        if (t.tag == 0) { failed = true; return; }
        t.selfClosing = selfClosing;
        t.attributes = attrSlices[];

        state = State.Data;
        emit(t);
    }

    void startComment() { tokData.clear(); }

    void emitComment()
    {
        flushText();
        Token t;
        t.type = TokenType.Comment;
        t.data = tokData[];
        emit(t);
    }

    void startDoctype()
    {
        tokData.clear();
        forceQuirks = hasName = hasPublic = hasSystem = false;
        nameStart = nameLen = publicStart = publicLen = systemStart = systemLen = 0;
    }

    void emitDoctype()
    {
        flushText();
        auto d = tokData[];
        Token t;
        t.type = TokenType.Doctype;
        t.forceQuirks = forceQuirks;
        t.hasName = hasName;
        t.hasPublicId = hasPublic;
        t.hasSystemId = hasSystem;
        t.name = d[nameStart .. nameStart + nameLen];
        t.publicId = d[publicStart .. publicStart + publicLen];
        t.systemId = d[systemStart .. systemStart + systemLen];
        emit(t);
    }

    void emitProcessingInstruction()
    {
        flushText();
        auto d = tokData[];
        Token t;
        t.type = TokenType.ProcessingInstruction;
        t.target = d[0 .. targetLen];
        t.data = d[targetLen .. $];
        emit(t);
    }

    // Is the current end tag an "appropriate end tag token"?
    bool appropriateEndTag() { return tagName[] == lastStartTag[]; }

    // Keep the rest of the chunk for later: the lookahead is incomplete
    void holdBack()
    {
        foreach (c; input[pos .. $]) carry.put(c);
        pos = input.length;
    }

    // Does the input continue with `s` (ASCII case-insensitive if `ci`)?
    // It returns 1 if yes, 0 if not, -1 if more input is needed.
    int lookahead(string s, bool ci)
    {
        foreach (i, c; s)
        {
            if (pos + i >= input.length) return eof ? 0 : -1;
            auto d = input[pos + i];
            if (ci ? lower(d) != c : d != c) return 0;
        }
        return 1;
    }

    // ------------------------------------------------------------ the state machine

    void run(const(char)[] chunk)
    {
        input = chunk;
        pos = 0;
        counted = 0;

        while (pos < input.length && !failed)
            step();

        // The chars held back are counted with the next chunk
        if (collectErrors) countTo(input.length - carry.length);
    }

    /+ Advance the line and the column up to `at` in the input (only when collecting errors).
     + The errors of the input stream preprocessing are found here: control characters and
     + noncharacters (surrogates can't be in valid UTF-8).
     +/
    void countTo(size_t at)
    {
        if (at > input.length) at = input.length;

        while (counted < at)
        {
            auto c = cast(ubyte) input[counted];
            if (c == '\n') { line++; column = 0; counted++; continue; }

            uint cp = c;
            size_t len = 1;
            if (c >= 0x80)
            {
                len = c >= 0xF0 ? 4 : c >= 0xE0 ? 3 : 2;
                if (counted + len > input.length) break;
                cp = c & (0x7F >> len);
                foreach (i; 1 .. len) cp = (cp << 6) | (input[counted + i] & 0x3F);
            }

            if ((cp < 0x20 && cp != '\t' && cp != '\f' && cp != 0) || (cp >= 0x7F && cp <= 0x9F))
                errors.put(RawParseError(ParseErrorCode.ControlCharacterInInputStream, line, column + 1));
            else if ((cp >= 0xFDD0 && cp <= 0xFDEF) || (cp & 0xFFFE) == 0xFFFE)
                errors.put(RawParseError(ParseErrorCode.NoncharacterInInputStream, line, column + 1));

            column++;
            counted += len;
        }
    }

    // One step: consume the chars of the current state
    void step()
    {
        char c = input[pos];

        final switch (state)
        {
            case State.Data:
            {
                // Fast path: a run of plain text
                size_t start = pos;
                pos = findAny!('<', '&', '\0')(input, pos);
                if (pos > start) emitText(input[start .. pos]);
                if (pos == input.length) return;
                c = input[pos];

                pos++;
                if (c == '<') state = State.TagOpen;
                else if (c == '&') { returnState = State.Data; state = State.CharRef; }
                else { error(ParseErrorCode.UnexpectedNullCharacter); emitText('\0'); }
                return;
            }

            case State.Rcdata:
            {
                size_t start = pos;
                pos = findAny!('<', '&', '\0')(input, pos);
                if (pos > start) emitText(input[start .. pos]);
                if (pos == input.length) return;

                c = input[pos++];
                if (c == '<') state = State.RcdataLessThan;
                else if (c == '&') { returnState = State.Rcdata; state = State.CharRef; }
                else { error(ParseErrorCode.UnexpectedNullCharacter); emitText(Replacement); }
                return;
            }

            case State.Rawtext, State.ScriptData, State.Plaintext:
            {
                size_t start = pos;
                pos = state != State.Plaintext ? findAny!('<', '\0', '\0')(input, pos) : findAny!('\0', '\0', '\0')(input, pos);
                if (pos > start) emitText(input[start .. pos]);
                if (pos == input.length) return;

                c = input[pos++];
                if (c == '\0') { error(ParseErrorCode.UnexpectedNullCharacter); emitText(Replacement); }
                else state = state == State.Rawtext ? State.RawtextLessThan : State.ScriptDataLessThan;
                return;
            }

            case State.TagOpen:
                if (c == '!') { pos++; state = State.MarkupDeclarationOpen; }
                else if (c == '/') { pos++; state = State.EndTagOpen; }
                else if (isAlpha(c)) { startTag(false); state = State.TagName; }
                else if (c == '?') { pos++; state = State.ProcessingInstructionOpen; }
                else { error(ParseErrorCode.InvalidFirstCharacterOfTagName); emitText('<'); state = State.Data; }
                return;

            case State.EndTagOpen:
                if (isAlpha(c)) { startTag(true); state = State.TagName; }
                else if (c == '>') { error(ParseErrorCode.MissingEndTagName); pos++; state = State.Data; }
                else { error(ParseErrorCode.InvalidFirstCharacterOfTagName); startComment(); state = State.BogusComment; }
                return;

            case State.TagName:
                while (pos < input.length)
                {
                    // The names are almost always lowercase: they are lowercased only if needed
                    size_t start = pos;
                    ubyte seen = 0;
                    while (pos < input.length)
                    {
                        auto k = charClass[input[pos]];
                        if (k & EndOfName) break;
                        seen |= k;
                        pos++;
                    }
                    if (seen & Upper) tagName.putLower(input[start .. pos]);
                    else tagName.put(input[start .. pos]);
                    if (pos == input.length) return;

                    c = input[pos++];
                    if (isSpace(c)) { state = State.BeforeAttrName; return; }
                    if (c == '/') { state = State.SelfClosingStartTag; return; }
                    if (c == '>') { emitTag(); return; }
                    error(ParseErrorCode.UnexpectedNullCharacter);
                    tagName.put(Replacement);
                }
                return;

            // RCDATA, RAWTEXT and script data end tags
            case State.RcdataLessThan, State.RawtextLessThan:
                if (c == '/')
                {
                    pos++;
                    temp.clear();
                    state = state == State.RcdataLessThan ? State.RcdataEndTagOpen : State.RawtextEndTagOpen;
                }
                else { emitText('<'); state = state == State.RcdataLessThan ? State.Rcdata : State.Rawtext; }
                return;

            case State.RcdataEndTagOpen, State.RawtextEndTagOpen, State.ScriptDataEndTagOpen, State.ScriptDataEscapedEndTagOpen:
            {
                auto back = textStateOf(state);
                if (isAlpha(c))
                {
                    startTag(true);
                    state = state == State.RcdataEndTagOpen ? State.RcdataEndTagName
                        : state == State.RawtextEndTagOpen ? State.RawtextEndTagName
                        : state == State.ScriptDataEndTagOpen ? State.ScriptDataEndTagName : State.ScriptDataEscapedEndTagName;
                }
                else { emitText("</"); state = back; }
                return;
            }

            case State.RcdataEndTagName, State.RawtextEndTagName, State.ScriptDataEndTagName, State.ScriptDataEscapedEndTagName:
            {
                auto back = textStateOf(state);
                if (isAlpha(c))
                {
                    pos++;
                    tagName.put(lower(c));
                    temp.put(c);
                    return;
                }

                if (appropriateEndTag())
                {
                    if (isSpace(c)) { pos++; state = State.BeforeAttrName; return; }
                    if (c == '/') { pos++; state = State.SelfClosingStartTag; return; }
                    if (c == '>') { pos++; emitTag(); return; }
                }

                emitText("</");
                emitText(temp[]);
                state = back;
                return;
            }

            case State.ScriptDataLessThan:
                if (c == '/') { pos++; temp.clear(); state = State.ScriptDataEndTagOpen; }
                else if (c == '!') { pos++; emitText("<!"); state = State.ScriptDataEscapeStart; }
                else { emitText('<'); state = State.ScriptData; }
                return;

            case State.ScriptDataEscapeStart:
                if (c == '-') { pos++; emitText('-'); state = State.ScriptDataEscapeStartDash; }
                else state = State.ScriptData;
                return;

            case State.ScriptDataEscapeStartDash:
                if (c == '-') { pos++; emitText('-'); state = State.ScriptDataEscapedDashDash; }
                else state = State.ScriptData;
                return;

            case State.ScriptDataEscaped:
            {
                size_t start = pos;
                pos = findAny!('-', '<', '\0')(input, pos);
                if (pos > start) emitText(input[start .. pos]);
                if (pos == input.length) return;

                c = input[pos++];
                if (c == '-') { emitText('-'); state = State.ScriptDataEscapedDash; }
                else if (c == '<') state = State.ScriptDataEscapedLessThan;
                else { error(ParseErrorCode.UnexpectedNullCharacter); emitText(Replacement); }
                return;
            }

            case State.ScriptDataEscapedDash:
                pos++;
                if (c == '-') { emitText('-'); state = State.ScriptDataEscapedDashDash; }
                else if (c == '<') state = State.ScriptDataEscapedLessThan;
                else if (c == '\0') { error(ParseErrorCode.UnexpectedNullCharacter); emitText(Replacement); state = State.ScriptDataEscaped; }
                else { emitText(c); state = State.ScriptDataEscaped; }
                return;

            case State.ScriptDataEscapedDashDash:
                pos++;
                if (c == '-') emitText('-');
                else if (c == '<') state = State.ScriptDataEscapedLessThan;
                else if (c == '>') { emitText('>'); state = State.ScriptData; }
                else if (c == '\0') { error(ParseErrorCode.UnexpectedNullCharacter); emitText(Replacement); state = State.ScriptDataEscaped; }
                else { emitText(c); state = State.ScriptDataEscaped; }
                return;

            case State.ScriptDataEscapedLessThan:
                if (c == '/') { pos++; temp.clear(); state = State.ScriptDataEscapedEndTagOpen; }
                else if (isAlpha(c)) { temp.clear(); emitText('<'); state = State.ScriptDataDoubleEscapeStart; }
                else { emitText('<'); state = State.ScriptDataEscaped; }
                return;

            case State.ScriptDataDoubleEscapeStart, State.ScriptDataDoubleEscapeEnd:
            {
                bool starting = state == State.ScriptDataDoubleEscapeStart;
                if (isSpace(c) || c == '/' || c == '>')
                {
                    pos++;
                    emitText(c);
                    bool isScript = temp[] == "script";
                    if (starting) state = isScript ? State.ScriptDataDoubleEscaped : State.ScriptDataEscaped;
                    else state = isScript ? State.ScriptDataEscaped : State.ScriptDataDoubleEscaped;
                }
                else if (isAlpha(c)) { pos++; temp.put(lower(c)); emitText(c); }
                else state = starting ? State.ScriptDataEscaped : State.ScriptDataDoubleEscaped;
                return;
            }

            case State.ScriptDataDoubleEscaped:
            {
                size_t start = pos;
                pos = findAny!('-', '<', '\0')(input, pos);
                if (pos > start) emitText(input[start .. pos]);
                if (pos == input.length) return;

                c = input[pos++];
                if (c == '-') { emitText('-'); state = State.ScriptDataDoubleEscapedDash; }
                else if (c == '<') { emitText('<'); state = State.ScriptDataDoubleEscapedLessThan; }
                else { error(ParseErrorCode.UnexpectedNullCharacter); emitText(Replacement); }
                return;
            }

            case State.ScriptDataDoubleEscapedDash:
                pos++;
                if (c == '-') { emitText('-'); state = State.ScriptDataDoubleEscapedDashDash; }
                else if (c == '<') { emitText('<'); state = State.ScriptDataDoubleEscapedLessThan; }
                else if (c == '\0') { error(ParseErrorCode.UnexpectedNullCharacter); emitText(Replacement); state = State.ScriptDataDoubleEscaped; }
                else { emitText(c); state = State.ScriptDataDoubleEscaped; }
                return;

            case State.ScriptDataDoubleEscapedDashDash:
                pos++;
                if (c == '-') emitText('-');
                else if (c == '<') { emitText('<'); state = State.ScriptDataDoubleEscapedLessThan; }
                else if (c == '>') { emitText('>'); state = State.ScriptData; }
                else if (c == '\0') { error(ParseErrorCode.UnexpectedNullCharacter); emitText(Replacement); state = State.ScriptDataDoubleEscaped; }
                else { emitText(c); state = State.ScriptDataDoubleEscaped; }
                return;

            case State.ScriptDataDoubleEscapedLessThan:
                if (c == '/') { pos++; temp.clear(); emitText('/'); state = State.ScriptDataDoubleEscapeEnd; }
                else state = State.ScriptDataDoubleEscaped;
                return;

            // Attributes
            case State.BeforeAttrName:
                if (isSpace(c)) { pos++; return; }
                if (c == '/' || c == '>') { state = State.AfterAttrName; return; }
                startAttribute();
                if (c == '=') { error(ParseErrorCode.UnexpectedEqualsSignBeforeAttributeName); pos++; tokData.put('='); }
                state = State.AttrName;
                return;

            case State.AttrName:
                while (pos < input.length)
                {
                    size_t start = pos;
                    ubyte seen = 0;
                    while (pos < input.length)
                    {
                        auto k = charClass[input[pos]];
                        if (k & EndOfAttrName) break;
                        seen |= k;
                        pos++;
                    }
                    if (collectErrors) foreach (i, ch; input[start .. pos])
                        if (ch == '"' || ch == '\'' || ch == '<')
                        {
                            countTo(start + i);
                            errors.put(RawParseError(ParseErrorCode.UnexpectedCharacterInAttributeName, line, column + 1));
                        }
                    if (seen & Upper) tokData.putLower(input[start .. pos]);
                    else tokData.put(input[start .. pos]);
                    if (pos == input.length) return;

                    c = input[pos];
                    if (isSpace(c) || c == '/' || c == '>') { endAttrName(); state = State.AfterAttrName; return; }
                    pos++;
                    if (c == '=') { endAttrName(); state = State.BeforeAttrValue; return; }
                    error(ParseErrorCode.UnexpectedNullCharacter);
                    tokData.put(Replacement);
                }
                return;

            case State.AfterAttrName:
                if (isSpace(c)) { pos++; return; }
                if (c == '/') { pos++; state = State.SelfClosingStartTag; return; }
                if (c == '=') { pos++; state = State.BeforeAttrValue; return; }
                if (c == '>') { pos++; emitTag(); return; }
                startAttribute();
                state = State.AttrName;
                return;

            case State.BeforeAttrValue:
                if (isSpace(c)) { pos++; return; }
                startValue();
                if (c == '"') { pos++; state = State.AttrValueDoubleQuoted; }
                else if (c == '\'') { pos++; state = State.AttrValueSingleQuoted; }
                else if (c == '>') { error(ParseErrorCode.MissingAttributeValue); pos++; emitTag(); }
                else state = State.AttrValueUnquoted;
                return;

            case State.AttrValueDoubleQuoted, State.AttrValueSingleQuoted:
            {
                char q = state == State.AttrValueDoubleQuoted ? '"' : '\'';
                while (pos < input.length)
                {
                    size_t start = pos;
                    pos = q == '"' ? findAny!('"', '&', '\0')(input, pos) : findAny!('\'', '&', '\0')(input, pos);
                    tokData.put(input[start .. pos]);
                    if (pos == input.length) return;

                    c = input[pos++];
                    if (c == q) { state = State.AfterAttrValueQuoted; return; }
                    if (c == '&') { returnState = state; state = State.CharRef; return; }
                    error(ParseErrorCode.UnexpectedNullCharacter);
                    tokData.put(Replacement);
                }
                return;
            }

            case State.AttrValueUnquoted:
                while (pos < input.length)
                {
                    size_t start = pos;
                    while (pos < input.length && !(charClass[input[pos]] & EndOfUnquoted)) pos++;
                    if (collectErrors) foreach (i, ch; input[start .. pos])
                        if (ch == '"' || ch == '\'' || ch == '<' || ch == '=' || ch == '`')
                        {
                            countTo(start + i);
                            errors.put(RawParseError(ParseErrorCode.UnexpectedCharacterInUnquotedAttributeValue, line, column + 1));
                        }
                    tokData.put(input[start .. pos]);
                    if (pos == input.length) return;

                    c = input[pos];
                    if (isSpace(c)) { pos++; endAttribute(); state = State.BeforeAttrName; return; }
                    if (c == '>') { pos++; emitTag(); return; }
                    pos++;
                    if (c == '&') { returnState = State.AttrValueUnquoted; state = State.CharRef; return; }
                    if (c == '\0') { error(ParseErrorCode.UnexpectedNullCharacter); tokData.put(Replacement); continue; }
                    tokData.put(c);
                }
                return;

            case State.AfterAttrValueQuoted:
                endAttribute();
                if (isSpace(c)) { pos++; state = State.BeforeAttrName; }
                else if (c == '/') { pos++; state = State.SelfClosingStartTag; }
                else if (c == '>') { pos++; emitTag(); }
                else { error(ParseErrorCode.MissingWhitespaceBetweenAttributes); state = State.BeforeAttrName; }
                return;

            case State.SelfClosingStartTag:
                if (c == '>') { pos++; selfClosing = true; emitTag(); }
                else { error(ParseErrorCode.UnexpectedSolidusInTag); state = State.BeforeAttrName; }
                return;

            // Comments
            case State.BogusComment:
                while (pos < input.length)
                {
                    c = input[pos++];
                    if (c == '>') { emitComment(); state = State.Data; return; }
                    if (c == '\0') { error(ParseErrorCode.UnexpectedNullCharacter); tokData.put(Replacement); continue; }
                    tokData.put(c);
                }
                return;

            case State.MarkupDeclarationOpen:
            {
                auto dashes = lookahead("--", false);
                if (dashes < 0) { holdBack(); return; }
                if (dashes > 0) { pos += 2; startComment(); state = State.CommentStart; return; }

                auto dt = lookahead("doctype", true);
                if (dt < 0) { holdBack(); return; }
                if (dt > 0) { pos += 7; state = State.Doctype; return; }

                auto cd = lookahead("[CDATA[", false);
                if (cd < 0) { holdBack(); return; }
                if (cd > 0)
                {
                    pos += 7;
                    flushText();
                    if (sink.inForeignContent(sink.context)) state = State.CDataSection;
                    else
                    {
                        error(ParseErrorCode.CDataInHtmlContent);
                        startComment();
                        foreach (ch; "[CDATA[") tokData.put(ch);
                        state = State.BogusComment;
                    }
                    return;
                }

                error(ParseErrorCode.IncorrectlyOpenedComment);
                startComment();
                state = State.BogusComment;
                return;
            }

            case State.CommentStart:
                if (c == '-') { pos++; state = State.CommentStartDash; }
                else if (c == '>') { error(ParseErrorCode.AbruptClosingOfEmptyComment); pos++; emitComment(); state = State.Data; }
                else state = State.Comment;
                return;

            case State.CommentStartDash:
                if (c == '-') { pos++; state = State.CommentEnd; }
                else if (c == '>') { error(ParseErrorCode.AbruptClosingOfEmptyComment); pos++; emitComment(); state = State.Data; }
                else { tokData.put('-'); state = State.Comment; }
                return;

            case State.Comment:
                while (pos < input.length)
                {
                    size_t start = pos;
                    pos = findAny!('<', '-', '\0')(input, pos);
                    tokData.put(input[start .. pos]);
                    if (pos == input.length) return;

                    c = input[pos++];
                    if (c == '<') { tokData.put('<'); state = State.CommentLessThan; return; }
                    if (c == '-') { state = State.CommentEndDash; return; }
                    error(ParseErrorCode.UnexpectedNullCharacter);
                    tokData.put(Replacement);
                }
                return;

            case State.CommentLessThan:
                if (c == '!') { pos++; tokData.put('!'); state = State.CommentLessThanBang; }
                else if (c == '<') { pos++; tokData.put('<'); }
                else state = State.Comment;
                return;

            case State.CommentLessThanBang:
                if (c == '-') { pos++; state = State.CommentLessThanBangDash; }
                else state = State.Comment;
                return;

            case State.CommentLessThanBangDash:
                if (c == '-') { pos++; state = State.CommentLessThanBangDashDash; }
                else state = State.CommentEndDash;
                return;

            case State.CommentLessThanBangDashDash:
                if (c != '>') error(ParseErrorCode.NestedComment);
                state = State.CommentEnd;
                return;

            case State.CommentEndDash:
                if (c == '-') { pos++; state = State.CommentEnd; }
                else { tokData.put('-'); state = State.Comment; }
                return;

            case State.CommentEnd:
                if (c == '>') { pos++; emitComment(); state = State.Data; }
                else if (c == '!') { pos++; state = State.CommentEndBang; }
                else if (c == '-') { pos++; tokData.put('-'); }
                else { tokData.put('-'); tokData.put('-'); state = State.Comment; }
                return;

            case State.CommentEndBang:
                if (c == '-') { pos++; foreach (ch; "--!") tokData.put(ch); state = State.CommentEndDash; }
                else if (c == '>') { error(ParseErrorCode.IncorrectlyClosedComment); pos++; emitComment(); state = State.Data; }
                else { foreach (ch; "--!") tokData.put(ch); state = State.Comment; }
                return;

            // Doctype
            case State.Doctype:
                startDoctype();
                if (isSpace(c)) pos++;
                else if (c != '>') error(ParseErrorCode.MissingWhitespaceBeforeDoctypeName);
                state = State.BeforeDoctypeName;
                return;

            case State.BeforeDoctypeName:
                if (isSpace(c)) { pos++; return; }
                if (c == '>') { error(ParseErrorCode.MissingDoctypeName); pos++; forceQuirks = true; emitDoctype(); state = State.Data; return; }
                hasName = true;
                nameStart = tokData.length;
                state = State.DoctypeName;
                return;

            case State.DoctypeName:
                while (pos < input.length)
                {
                    c = input[pos++];
                    if (isSpace(c)) { nameLen = tokData.length - nameStart; state = State.AfterDoctypeName; return; }
                    if (c == '>') { nameLen = tokData.length - nameStart; emitDoctype(); state = State.Data; return; }
                    if (c == '\0') { error(ParseErrorCode.UnexpectedNullCharacter); tokData.put(Replacement); continue; }
                    tokData.put(lower(c));
                }
                return;

            case State.AfterDoctypeName:
            {
                if (isSpace(c)) { pos++; return; }
                if (c == '>') { pos++; emitDoctype(); state = State.Data; return; }

                auto pub = lookahead("public", true);
                if (pub < 0) { holdBack(); return; }
                if (pub > 0) { pos += 6; state = State.AfterDoctypePublicKeyword; return; }

                auto sys = lookahead("system", true);
                if (sys < 0) { holdBack(); return; }
                if (sys > 0) { pos += 6; state = State.AfterDoctypeSystemKeyword; return; }

                error(ParseErrorCode.InvalidCharacterSequenceAfterDoctypeName);
                forceQuirks = true;
                state = State.BogusDoctype;
                return;
            }

            case State.AfterDoctypePublicKeyword, State.BeforeDoctypePublicId:
                if (isSpace(c)) { pos++; state = State.BeforeDoctypePublicId; return; }
                if (c == '"' || c == '\'')
                {
                    if (state == State.AfterDoctypePublicKeyword) error(ParseErrorCode.MissingWhitespaceAfterDoctypePublicKeyword);
                    pos++;
                    hasPublic = true;
                    publicStart = tokData.length;
                    state = c == '"' ? State.DoctypePublicIdDoubleQuoted : State.DoctypePublicIdSingleQuoted;
                    return;
                }
                if (c == '>') { error(ParseErrorCode.MissingDoctypePublicIdentifier); pos++; forceQuirks = true; emitDoctype(); state = State.Data; return; }
                error(ParseErrorCode.MissingQuoteBeforeDoctypePublicIdentifier);
                forceQuirks = true;
                state = State.BogusDoctype;
                return;

            case State.DoctypePublicIdDoubleQuoted, State.DoctypePublicIdSingleQuoted,
                 State.DoctypeSystemIdDoubleQuoted, State.DoctypeSystemIdSingleQuoted:
            {
                bool pub = state == State.DoctypePublicIdDoubleQuoted || state == State.DoctypePublicIdSingleQuoted;
                char q = state == State.DoctypePublicIdDoubleQuoted || state == State.DoctypeSystemIdDoubleQuoted ? '"' : '\'';
                while (pos < input.length)
                {
                    c = input[pos++];
                    if (c == q || c == '>')
                    {
                        if (pub) publicLen = tokData.length - publicStart;
                        else systemLen = tokData.length - systemStart;

                        if (c == q) state = pub ? State.AfterDoctypePublicId : State.AfterDoctypeSystemId;
                        else
                        {
                            error(pub ? ParseErrorCode.AbruptDoctypePublicIdentifier : ParseErrorCode.AbruptDoctypeSystemIdentifier);
                            forceQuirks = true;
                            emitDoctype();
                            state = State.Data;
                        }
                        return;
                    }
                    if (c == '\0') { error(ParseErrorCode.UnexpectedNullCharacter); tokData.put(Replacement); continue; }
                    tokData.put(c);
                }
                return;
            }

            case State.AfterDoctypePublicId, State.BetweenDoctypePublicAndSystem:
                if (isSpace(c)) { pos++; state = State.BetweenDoctypePublicAndSystem; return; }
                if (c == '>') { pos++; emitDoctype(); state = State.Data; return; }
                if (c == '"' || c == '\'')
                {
                    if (state == State.AfterDoctypePublicId) error(ParseErrorCode.MissingWhitespaceBetweenDoctypePublicAndSystemIdentifiers);
                    pos++;
                    hasSystem = true;
                    systemStart = tokData.length;
                    state = c == '"' ? State.DoctypeSystemIdDoubleQuoted : State.DoctypeSystemIdSingleQuoted;
                    return;
                }
                error(ParseErrorCode.MissingQuoteBeforeDoctypeSystemIdentifier);
                forceQuirks = true;
                state = State.BogusDoctype;
                return;

            case State.AfterDoctypeSystemKeyword, State.BeforeDoctypeSystemId:
                if (isSpace(c)) { pos++; state = State.BeforeDoctypeSystemId; return; }
                if (c == '"' || c == '\'')
                {
                    if (state == State.AfterDoctypeSystemKeyword) error(ParseErrorCode.MissingWhitespaceAfterDoctypeSystemKeyword);
                    pos++;
                    hasSystem = true;
                    systemStart = tokData.length;
                    state = c == '"' ? State.DoctypeSystemIdDoubleQuoted : State.DoctypeSystemIdSingleQuoted;
                    return;
                }
                if (c == '>') { error(ParseErrorCode.MissingDoctypeSystemIdentifier); pos++; forceQuirks = true; emitDoctype(); state = State.Data; return; }
                error(ParseErrorCode.MissingQuoteBeforeDoctypeSystemIdentifier);
                forceQuirks = true;
                state = State.BogusDoctype;
                return;

            case State.AfterDoctypeSystemId:
                if (isSpace(c)) { pos++; return; }
                if (c == '>') { pos++; emitDoctype(); state = State.Data; return; }
                error(ParseErrorCode.UnexpectedCharacterAfterDoctypeSystemIdentifier);
                state = State.BogusDoctype;
                return;

            case State.BogusDoctype:
                while (pos < input.length)
                {
                    c = input[pos++];
                    if (c == '>') { emitDoctype(); state = State.Data; return; }
                    if (c == '\0') { pos--; error(ParseErrorCode.UnexpectedNullCharacter); pos++; }
                }
                return;

            // CDATA sections: the text is emitted as is
            case State.CDataSection:
            {
                size_t start = pos;
                while (pos < input.length && input[pos] != ']') pos++;
                if (pos > start) emitText(input[start .. pos]);
                foreach (ch; input[start .. pos]) if (ch == '\0') { textHasNull = true; break; }
                if (pos == input.length) return;
                pos++;
                state = State.CDataSectionBracket;
                return;
            }

            case State.CDataSectionBracket:
                if (c == ']') { pos++; state = State.CDataSectionEnd; }
                else { emitText(']'); state = State.CDataSection; }
                return;

            case State.CDataSectionEnd:
                if (c == ']') { pos++; emitText(']'); }
                else if (c == '>') { pos++; state = State.Data; }
                else { emitText("]]"); state = State.CDataSection; }
                return;

            // Character references
            case State.CharRef:
                if (isAlnum(c)) { matcher = EntityMatcher.init; refBuf.clear(); state = State.NamedCharRef; }
                else if (c == '#') { pos++; state = State.NumericCharRef; }
                else { flushRef("&"); state = returnState; }
                return;

            case State.NamedCharRef:
                while (pos < input.length)
                {
                    c = input[pos];
                    if (!matcher.put(c)) { namedRefDone(c, true); return; }
                    refBuf.put(c);
                    pos++;
                }
                return;

            case State.NumericCharRef:
                charCode = 0;
                charCodeOverflow = false;
                if (c == 'x' || c == 'X') { pos++; refBuf.clear(); refBuf.put(c); state = State.HexCharRefStart; }
                else state = State.DecimalCharRefStart;
                return;

            case State.HexCharRefStart:
                if (isHex(c)) state = State.HexCharRef;
                else { error(ParseErrorCode.AbsenceOfDigitsInNumericCharacterReference); flushRef("&#"); flushRef(refBuf[]); state = returnState; }
                return;

            case State.DecimalCharRefStart:
                if (isDigit(c)) state = State.DecimalCharRef;
                else { error(ParseErrorCode.AbsenceOfDigitsInNumericCharacterReference); flushRef("&#"); state = returnState; }
                return;

            case State.HexCharRef, State.DecimalCharRef:
            {
                bool hex = state == State.HexCharRef;
                while (pos < input.length)
                {
                    c = input[pos];
                    uint d;
                    if (isDigit(c)) d = c - '0';
                    else if (hex && isHex(c)) d = lower(c) - 'a' + 10;
                    else
                    {
                        if (c == ';') pos++;
                        else error(ParseErrorCode.MissingSemicolonAfterCharacterReference);
                        numericRefDone();
                        return;
                    }

                    pos++;
                    if (charCode > 0x10FFFF) charCodeOverflow = true;
                    else charCode = charCode * (hex ? 16 : 10) + d;
                }
                return;
            }

            // After a named reference that matches nothing: an error if the name ends with ';'
            case State.AmbiguousAmpersand:
            {
                size_t start = pos;
                while (pos < input.length && isAlnum(input[pos])) pos++;
                flushRef(input[start .. pos]);
                if (pos == input.length) return;
                if (input[pos] == ';') error(ParseErrorCode.UnknownNamedCharacterReference);
                state = returnState;
                return;
            }

            // Processing instructions (`<?target data?>`)
            case State.ProcessingInstructionOpen:
                if (isAlpha(c) || c == '_') { tokData.clear(); state = State.ProcessingInstructionTarget; }
                else
                {
                    error(ParseErrorCode.InvalidFirstCharacterOfProcessingInstructionTarget);
                    startComment();
                    tokData.put('?');
                    state = State.BogusComment;
                }
                return;

            case State.ProcessingInstructionTarget:
                while (pos < input.length)
                {
                    c = input[pos];
                    if (isSpace(c) || c == '\r' || c == '?' || c == '>')
                    {
                        auto t = tokData[];
                        if (equalsCi(t, "xml") || equalsCi(t, "xml-stylesheet"))
                        {
                            error(ParseErrorCode.DisallowedProcessingInstructionTarget);
                            targetToComment();
                            return;
                        }
                        targetLen = tokData.length;
                        state = State.AfterProcessingInstructionTarget;
                        return;
                    }
                    if (!isAlnum(c) && c != '-' && c != '_')
                    {
                        error(ParseErrorCode.InvalidProcessingInstructionTarget);
                        targetToComment();
                        return;
                    }
                    tokData.put(c);
                    pos++;
                }
                return;

            case State.AfterProcessingInstructionTarget:
                if (isSpace(c)) { pos++; return; }
                state = State.ProcessingInstructionData;
                return;

            case State.ProcessingInstructionData:
                while (pos < input.length)
                {
                    c = input[pos++];
                    if (c == '?') { state = State.ProcessingInstructionQuestionable; return; }
                    if (c == '>') { emitProcessingInstruction(); state = State.Data; return; }
                    tokData.put(c);
                }
                return;

            case State.ProcessingInstructionQuestionable:
                if (c == '>') { pos++; emitProcessingInstruction(); state = State.Data; }
                else { tokData.put('?'); state = State.ProcessingInstructionData; }
                return;
        }
    }

    static bool equalsCi(scope const(char)[] a, string b) pure
    {
        if (a.length != b.length) return false;
        foreach (i, c; a) if (lower(c) != b[i]) return false;
        return true;
    }

    // An invalid processing instruction target: it becomes a bogus comment "?target..."
    void targetToComment()
    {
        auto t = tokData[];
        temp.clear();
        foreach (ch; t) temp.put(ch);
        tokData.clear();
        tokData.put('?');
        foreach (ch; temp[]) tokData.put(ch);
        state = State.BogusComment;
    }

    // The text state an end tag state goes back to
    static State textStateOf(State s) pure
    {
        switch (s)
        {
            case State.RcdataEndTagOpen, State.RcdataEndTagName: return State.Rcdata;
            case State.RawtextEndTagOpen, State.RawtextEndTagName: return State.Rawtext;
            case State.ScriptDataEndTagOpen, State.ScriptDataEndTagName: return State.ScriptData;
            default: return State.ScriptDataEscaped;
        }
    }

    // The named reference ends before `next` (not consumed). `hasNext` is false at EOF.
    void namedRefDone(char next, bool hasNext)
    {
        auto consumed = refBuf[];

        if (matcher.best == size_t.max)
        {
            // No match: the chars are plain text, and so the alphanumerics after them
            flushRef("&");
            flushRef(consumed);
            state = hasNext ? State.AmbiguousAmpersand : returnState;
            return;
        }

        auto e = entities[matcher.best];
        auto rest = consumed[matcher.bestLength .. $];

        if (attributeState && e.name[$ - 1] != ';')
        {
            char after = rest.length ? rest[0] : next;
            bool afterExists = rest.length || hasNext;
            if (afterExists && (after == '=' || isAlnum(after)))
            {
                flushRef("&");
                flushRef(consumed);
                state = returnState;
                return;
            }
        }

        if (e.name[$ - 1] != ';') error(ParseErrorCode.MissingSemicolonAfterCharacterReference);
        flushRef(e.value);
        flushRef(rest);
        state = returnState;
    }

    void numericRefDone()
    {
        uint cp = charCodeOverflow ? 0x110000 : charCode;

        if (collectErrors)
        {
            if (cp == 0) error(ParseErrorCode.NullCharacterReference);
            else if (cp > 0x10FFFF) error(ParseErrorCode.CharacterReferenceOutsideUnicodeRange);
            else if (cp >= 0xD800 && cp <= 0xDFFF) error(ParseErrorCode.SurrogateCharacterReference);
            else if ((cp >= 0xFDD0 && cp <= 0xFDEF) || (cp & 0xFFFE) == 0xFFFE) error(ParseErrorCode.NoncharacterCharacterReference);
            else if (cp == 0x0D || ((cp < 0x20 || (cp >= 0x7F && cp <= 0x9F)) && cp != '\t' && cp != '\n' && cp != '\f' && cp != ' '))
                error(ParseErrorCode.ControlCharacterReference);
        }

        if (cp == 0 || cp > 0x10FFFF || (cp >= 0xD800 && cp <= 0xDFFF)) cp = 0xFFFD;
        else if (cp >= 0x80 && cp <= 0x9F)
        {
            static immutable ushort[32] c1 = [
                0x20AC, 0x81, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, 0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0x8D, 0x017D, 0x8F,
                0x90, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0x9D, 0x017E, 0x0178,
            ];
            cp = c1[cp - 0x80];
        }

        char[4] buf;
        flushRef(encode(cp, buf));
        state = returnState;
    }

    static const(char)[] encode(uint c, return ref char[4] b) pure
    {
        if (c < 0x80) { b[0] = cast(char) c; return b[0 .. 1]; }
        if (c < 0x800) { b[0] = cast(char) (0xC0 | (c >> 6)); b[1] = cast(char) (0x80 | (c & 0x3F)); return b[0 .. 2]; }
        if (c < 0x10000)
        {
            b[0] = cast(char) (0xE0 | (c >> 12)); b[1] = cast(char) (0x80 | ((c >> 6) & 0x3F)); b[2] = cast(char) (0x80 | (c & 0x3F));
            return b[0 .. 3];
        }
        b[0] = cast(char) (0xF0 | (c >> 18)); b[1] = cast(char) (0x80 | ((c >> 12) & 0x3F));
        b[2] = cast(char) (0x80 | ((c >> 6) & 0x3F)); b[3] = cast(char) (0x80 | (c & 0x3F));
        return b[0 .. 4];
    }

    // What the current state does at the end of the input
    void handleEof()
    {
        pos = input.length;

        while (!failed)
        {
            final switch (state)
            {
                case State.Data, State.Rcdata, State.Rawtext, State.ScriptData, State.Plaintext:
                    return;

                case State.ScriptDataEscaped, State.ScriptDataEscapedDash, State.ScriptDataEscapedDashDash,
                     State.ScriptDataDoubleEscaped, State.ScriptDataDoubleEscapedDash, State.ScriptDataDoubleEscapedDashDash:
                    error(ParseErrorCode.EofInScriptHtmlCommentLikeText);
                    return;

                case State.CDataSection:
                    error(ParseErrorCode.EofInCData);
                    return;

                case State.TagOpen: error(ParseErrorCode.EofBeforeTagName); emitText('<'); return;
                case State.EndTagOpen: error(ParseErrorCode.EofBeforeTagName); emitText("</"); return;

                case State.RcdataLessThan, State.RawtextLessThan, State.ScriptDataLessThan, State.ScriptDataEscapedLessThan:
                    emitText('<'); return;

                case State.RcdataEndTagOpen, State.RawtextEndTagOpen, State.ScriptDataEndTagOpen, State.ScriptDataEscapedEndTagOpen:
                    emitText("</"); return;

                case State.RcdataEndTagName, State.RawtextEndTagName, State.ScriptDataEndTagName, State.ScriptDataEscapedEndTagName:
                    emitText("</"); emitText(temp[]); return;

                case State.ScriptDataEscapeStart, State.ScriptDataEscapeStartDash:
                    return;

                case State.ScriptDataDoubleEscapeStart:
                    error(ParseErrorCode.EofInScriptHtmlCommentLikeText);
                    return;

                case State.ScriptDataDoubleEscapeEnd, State.ScriptDataDoubleEscapedLessThan:
                    error(ParseErrorCode.EofInScriptHtmlCommentLikeText);
                    return;

                // EOF in a tag: the tag is dropped
                case State.TagName, State.BeforeAttrName, State.AttrName, State.AfterAttrName, State.BeforeAttrValue,
                     State.AttrValueDoubleQuoted, State.AttrValueSingleQuoted, State.AttrValueUnquoted,
                     State.AfterAttrValueQuoted, State.SelfClosingStartTag:
                    error(ParseErrorCode.EofInTag);
                    return;

                case State.BogusComment:
                    emitComment(); return;

                case State.CommentStart, State.CommentStartDash, State.Comment, State.CommentLessThan,
                     State.CommentLessThanBang, State.CommentLessThanBangDash, State.CommentLessThanBangDashDash,
                     State.CommentEndDash, State.CommentEnd, State.CommentEndBang:
                    error(ParseErrorCode.EofInComment);
                    emitComment(); return;

                case State.MarkupDeclarationOpen:
                    error(ParseErrorCode.IncorrectlyOpenedComment);
                    startComment(); emitComment(); return;

                case State.Doctype, State.BeforeDoctypeName:
                    error(ParseErrorCode.EofInDoctype);
                    startDoctype(); forceQuirks = true; emitDoctype(); return;

                case State.DoctypeName:
                    error(ParseErrorCode.EofInDoctype);
                    nameLen = tokData.length - nameStart; forceQuirks = true; emitDoctype(); return;

                case State.DoctypePublicIdDoubleQuoted, State.DoctypePublicIdSingleQuoted:
                    error(ParseErrorCode.EofInDoctype);
                    publicLen = tokData.length - publicStart; forceQuirks = true; emitDoctype(); return;

                case State.DoctypeSystemIdDoubleQuoted, State.DoctypeSystemIdSingleQuoted:
                    error(ParseErrorCode.EofInDoctype);
                    systemLen = tokData.length - systemStart; forceQuirks = true; emitDoctype(); return;

                case State.AfterDoctypeName, State.AfterDoctypePublicKeyword, State.BeforeDoctypePublicId,
                     State.AfterDoctypePublicId, State.BetweenDoctypePublicAndSystem, State.AfterDoctypeSystemKeyword,
                     State.BeforeDoctypeSystemId, State.AfterDoctypeSystemId:
                    error(ParseErrorCode.EofInDoctype);
                    forceQuirks = true; emitDoctype(); return;

                case State.BogusDoctype: emitDoctype(); return;

                case State.CDataSectionBracket: error(ParseErrorCode.EofInCData); emitText(']'); return;
                case State.CDataSectionEnd: error(ParseErrorCode.EofInCData); emitText("]]"); return;
                case State.AmbiguousAmpersand: state = returnState; continue;

                case State.CharRef: flushRef("&"); state = returnState; continue;
                case State.NamedCharRef: namedRefDone('\0', false); continue;
                case State.NumericCharRef, State.DecimalCharRefStart:
                    error(ParseErrorCode.AbsenceOfDigitsInNumericCharacterReference);
                    flushRef("&#"); state = returnState; continue;
                case State.HexCharRefStart:
                    error(ParseErrorCode.AbsenceOfDigitsInNumericCharacterReference);
                    flushRef("&#"); flushRef(refBuf[]); state = returnState; continue;
                case State.HexCharRef, State.DecimalCharRef:
                    error(ParseErrorCode.MissingSemicolonAfterCharacterReference);
                    numericRefDone(); continue;

                // EOF in a processing instruction: nothing is emitted
                case State.ProcessingInstructionOpen, State.ProcessingInstructionTarget, State.AfterProcessingInstructionTarget,
                     State.ProcessingInstructionData, State.ProcessingInstructionQuestionable:
                    error(ParseErrorCode.EofInProcessingInstruction);
                    return;
            }
        }
    }
}
