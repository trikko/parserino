/++
 HTML tokenizer (HTML Living Standard, "Tokenization").

 The input comes in chunks of any size: a token can span many chunks.
 Tokens are given to a sink (the tree builder) as soon as they are complete;
 their data is valid only during the call.
+/
module parserino.html.tokenizer;

import parserino.arena;
import parserino.names;
import parserino.dom : Document;
import parserino.html.entities;

@nogc nothrow:

enum TokenType : ubyte
{
    startTag,
    endTag,
    text,
    comment,
    doctype,
    processingInstruction,
    eof,
}

struct TokenAttribute
{
    const(char)[] name;     /// lowercase
    const(char)[] value;
}

/// A token. Slices are valid only while the sink processes it.
struct Token
{
    TokenType type;

    /// Tag id (interned in the document) and lowercase name, for tags
    uint tag;
    const(char)[] name;
    bool selfClosing;
    const(TokenAttribute)[] attributes;

    /// Text, comment or processing instruction data
    const(char)[] data;
    /// The text contains U+0000
    bool hasNull;

    /// Processing instruction target
    const(char)[] target;

    /// Doctype
    bool forceQuirks;
    bool hasName, hasPublicId, hasSystemId;
    const(char)[] publicId, systemId;
}

/// The receiver of the tokens (the tree builder)
struct TokenSink
{
    void* context;
    /// Process a token. It returns false to stop (out of memory).
    bool function(void* context, ref Token token) @nogc nothrow process;
    /// Is the adjusted current node an element not in the html namespace? (for CDATA sections)
    bool function(void* context) @nogc nothrow inForeignContent;
}

/// States of the tokenizer (the ones the tree builder can set are `data`, `rcdata`, `rawtext`, `scriptData`, `plaintext`)
enum State : ubyte
{
    data, rcdata, rawtext, scriptData, plaintext,
    tagOpen, endTagOpen, tagName,
    rcdataLessThan, rcdataEndTagOpen, rcdataEndTagName,
    rawtextLessThan, rawtextEndTagOpen, rawtextEndTagName,
    scriptDataLessThan, scriptDataEndTagOpen, scriptDataEndTagName,
    scriptDataEscapeStart, scriptDataEscapeStartDash, scriptDataEscaped, scriptDataEscapedDash, scriptDataEscapedDashDash,
    scriptDataEscapedLessThan, scriptDataEscapedEndTagOpen, scriptDataEscapedEndTagName,
    scriptDataDoubleEscapeStart, scriptDataDoubleEscaped, scriptDataDoubleEscapedDash, scriptDataDoubleEscapedDashDash,
    scriptDataDoubleEscapedLessThan, scriptDataDoubleEscapeEnd,
    beforeAttrName, attrName, afterAttrName, beforeAttrValue,
    attrValueDoubleQuoted, attrValueSingleQuoted, attrValueUnquoted, afterAttrValueQuoted, selfClosingStartTag,
    bogusComment, markupDeclarationOpen,
    commentStart, commentStartDash, comment, commentLessThan, commentLessThanBang, commentLessThanBangDash,
    commentLessThanBangDashDash, commentEndDash, commentEnd, commentEndBang,
    doctype, beforeDoctypeName, doctypeName, afterDoctypeName,
    afterDoctypePublicKeyword, beforeDoctypePublicId, doctypePublicIdDoubleQuoted, doctypePublicIdSingleQuoted,
    afterDoctypePublicId, betweenDoctypePublicAndSystem,
    afterDoctypeSystemKeyword, beforeDoctypeSystemId, doctypeSystemIdDoubleQuoted, doctypeSystemIdSingleQuoted,
    afterDoctypeSystemId, bogusDoctype,
    cdataSection, cdataSectionBracket, cdataSectionEnd,
    charRef, namedCharRef, numericCharRef, hexCharRefStart, decimalCharRefStart, hexCharRef, decimalCharRef,
    processingInstructionOpen, processingInstructionTarget, afterProcessingInstructionTarget,
    processingInstructionData, processingInstructionQuestionable,
}

struct Tokenizer
{
@nogc nothrow:
    @disable this(this);

    this(Document* document, TokenSink sink)
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
        if (s == State.rcdata || s == State.rawtext || s == State.scriptData)
        {
            lastStartTag.clear();
            lastStartTag.put(tagName[]);
        }
    }

    /// Tokenize a chunk. It returns false on errors (out of memory).
    bool feed(scope const(char)[] chunk)
    {
        if (failed) return false;

        // Newlines: CR LF and CR become LF (also across chunks)
        const(char)[] input = chunk;
        if (skipLF && input.length && input[0] == '\n') input = input[1 .. $];
        skipLF = false;

        bool hasCR = false;
        foreach (c; input) if (c == '\r') { hasCR = true; break; }

        if (hasCR || carry.length)
        {
            work.clear();
            foreach (c; carry[]) work.put(c);
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

        return !failed;
    }

    /// End of input: the pending data is completed and an EOF token is emitted
    bool finish()
    {
        if (failed) return false;

        eof = true;
        if (carry.length)
        {
            work.clear();
            foreach (c; carry[]) work.put(c);
            carry.clear();
            run(work[]);
        }

        handleEof();
        flushText();

        Token t;
        t.type = TokenType.eof;
        emit(t);
        return !failed;
    }

    /// Out of memory (or stopped by the sink)
    bool failed;

    private:

    Document* document;
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

    enum replacement = "\xEF\xBF\xBD";

    // Character classes for the fast loops
    enum : ubyte { dataSpecial = 1, endOfName = 2, endOfAttrName = 4, endOfUnquoted = 8 }

    static immutable ubyte[256] charClass = () {
        ubyte[256] t;
        foreach (c; "<&\0") t[c] |= dataSpecial;
        foreach (c; " \t\n\f\r/>\0") t[c] |= endOfName;
        foreach (c; " \t\n\f\r/>=\0") t[c] |= endOfAttrName;
        foreach (c; " \t\n\f\r>&\0") t[c] |= endOfUnquoted;
        return t;
    }();

    // Append ASCII-lowercased
    static void putLower(ref Buffer!char buf, scope const(char)[] s)
    {
        auto at = buf.length;
        buf.put(s);
        foreach (ref c; buf.data[at .. buf.length])
            if (c >= 'A' && c <= 'Z') c |= 0x20;
    }

    void emitText(char c) { text.put(c); if (c == '\0') textHasNull = true; }
    void emitText(scope const(char)[] s) { text.put(s); }

    bool attributeState() const
    {
        return returnState == State.attrValueDoubleQuoted || returnState == State.attrValueSingleQuoted || returnState == State.attrValueUnquoted;
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
        if (!sink.process(sink.context, t)) failed = true;
    }

    void flushText()
    {
        if (text.length == 0) return;

        Token t;
        t.type = TokenType.text;
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
            if (!o.drop && tokData[][o.name .. o.name + o.nameLen] == n) { a.drop = true; break; }
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
        t.type = isEndTag ? TokenType.endTag : TokenType.startTag;
        t.name = tagName[];
        t.tag = document.tagId(t.name);
        if (t.tag == 0) { failed = true; return; }
        t.selfClosing = selfClosing;
        t.attributes = attrSlices[];

        state = State.data;
        emit(t);
    }

    void startComment() { tokData.clear(); }

    void emitComment()
    {
        flushText();
        Token t;
        t.type = TokenType.comment;
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
        t.type = TokenType.doctype;
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
        t.type = TokenType.processingInstruction;
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

        while (pos < input.length && !failed)
            step();
    }

    // One step: consume the chars of the current state
    void step()
    {
        char c = input[pos];

        final switch (state)
        {
            case State.data:
            {
                // Fast path: a run of plain text
                size_t start = pos;
                while (pos < input.length && !(charClass[input[pos]] & dataSpecial)) pos++;
                if (pos > start) emitText(input[start .. pos]);
                if (pos == input.length) return;
                c = input[pos];
                if (pos == input.length) return;

                pos++;
                if (c == '<') state = State.tagOpen;
                else if (c == '&') { returnState = State.data; state = State.charRef; }
                else emitText('\0');
                return;
            }

            case State.rcdata:
            {
                size_t start = pos;
                while (pos < input.length && input[pos] != '<' && input[pos] != '&' && input[pos] != '\0') pos++;
                if (pos > start) emitText(input[start .. pos]);
                if (pos == input.length) return;

                c = input[pos++];
                if (c == '<') state = State.rcdataLessThan;
                else if (c == '&') { returnState = State.rcdata; state = State.charRef; }
                else emitText(replacement);
                return;
            }

            case State.rawtext, State.scriptData, State.plaintext:
            {
                size_t start = pos;
                bool lt = state != State.plaintext;
                while (pos < input.length && !(lt && input[pos] == '<') && input[pos] != '\0') pos++;
                if (pos > start) emitText(input[start .. pos]);
                if (pos == input.length) return;

                c = input[pos++];
                if (c == '\0') emitText(replacement);
                else state = state == State.rawtext ? State.rawtextLessThan : State.scriptDataLessThan;
                return;
            }

            case State.tagOpen:
                if (c == '!') { pos++; state = State.markupDeclarationOpen; }
                else if (c == '/') { pos++; state = State.endTagOpen; }
                else if (isAlpha(c)) { startTag(false); state = State.tagName; }
                else if (c == '?') { pos++; state = State.processingInstructionOpen; }
                else { emitText('<'); state = State.data; }
                return;

            case State.endTagOpen:
                if (isAlpha(c)) { startTag(true); state = State.tagName; }
                else if (c == '>') { pos++; state = State.data; }
                else { startComment(); state = State.bogusComment; }
                return;

            case State.tagName:
                while (pos < input.length)
                {
                    size_t start = pos;
                    while (pos < input.length && !(charClass[input[pos]] & endOfName)) pos++;
                    putLower(tagName, input[start .. pos]);
                    if (pos == input.length) return;

                    c = input[pos++];
                    if (isSpace(c)) { state = State.beforeAttrName; return; }
                    if (c == '/') { state = State.selfClosingStartTag; return; }
                    if (c == '>') { emitTag(); return; }
                    tagName.put(replacement);
                }
                return;

            // RCDATA, RAWTEXT and script data end tags
            case State.rcdataLessThan, State.rawtextLessThan:
                if (c == '/')
                {
                    pos++;
                    temp.clear();
                    state = state == State.rcdataLessThan ? State.rcdataEndTagOpen : State.rawtextEndTagOpen;
                }
                else { emitText('<'); state = state == State.rcdataLessThan ? State.rcdata : State.rawtext; }
                return;

            case State.rcdataEndTagOpen, State.rawtextEndTagOpen, State.scriptDataEndTagOpen, State.scriptDataEscapedEndTagOpen:
            {
                auto back = textStateOf(state);
                if (isAlpha(c))
                {
                    startTag(true);
                    state = state == State.rcdataEndTagOpen ? State.rcdataEndTagName
                        : state == State.rawtextEndTagOpen ? State.rawtextEndTagName
                        : state == State.scriptDataEndTagOpen ? State.scriptDataEndTagName : State.scriptDataEscapedEndTagName;
                }
                else { emitText("</"); state = back; }
                return;
            }

            case State.rcdataEndTagName, State.rawtextEndTagName, State.scriptDataEndTagName, State.scriptDataEscapedEndTagName:
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
                    if (isSpace(c)) { pos++; state = State.beforeAttrName; return; }
                    if (c == '/') { pos++; state = State.selfClosingStartTag; return; }
                    if (c == '>') { pos++; emitTag(); return; }
                }

                emitText("</");
                emitText(temp[]);
                state = back;
                return;
            }

            case State.scriptDataLessThan:
                if (c == '/') { pos++; temp.clear(); state = State.scriptDataEndTagOpen; }
                else if (c == '!') { pos++; emitText("<!"); state = State.scriptDataEscapeStart; }
                else { emitText('<'); state = State.scriptData; }
                return;

            case State.scriptDataEscapeStart:
                if (c == '-') { pos++; emitText('-'); state = State.scriptDataEscapeStartDash; }
                else state = State.scriptData;
                return;

            case State.scriptDataEscapeStartDash:
                if (c == '-') { pos++; emitText('-'); state = State.scriptDataEscapedDashDash; }
                else state = State.scriptData;
                return;

            case State.scriptDataEscaped:
            {
                size_t start = pos;
                while (pos < input.length && input[pos] != '-' && input[pos] != '<' && input[pos] != '\0') pos++;
                if (pos > start) emitText(input[start .. pos]);
                if (pos == input.length) return;

                c = input[pos++];
                if (c == '-') { emitText('-'); state = State.scriptDataEscapedDash; }
                else if (c == '<') state = State.scriptDataEscapedLessThan;
                else emitText(replacement);
                return;
            }

            case State.scriptDataEscapedDash:
                pos++;
                if (c == '-') { emitText('-'); state = State.scriptDataEscapedDashDash; }
                else if (c == '<') state = State.scriptDataEscapedLessThan;
                else if (c == '\0') { emitText(replacement); state = State.scriptDataEscaped; }
                else { emitText(c); state = State.scriptDataEscaped; }
                return;

            case State.scriptDataEscapedDashDash:
                pos++;
                if (c == '-') emitText('-');
                else if (c == '<') state = State.scriptDataEscapedLessThan;
                else if (c == '>') { emitText('>'); state = State.scriptData; }
                else if (c == '\0') { emitText(replacement); state = State.scriptDataEscaped; }
                else { emitText(c); state = State.scriptDataEscaped; }
                return;

            case State.scriptDataEscapedLessThan:
                if (c == '/') { pos++; temp.clear(); state = State.scriptDataEscapedEndTagOpen; }
                else if (isAlpha(c)) { temp.clear(); emitText('<'); state = State.scriptDataDoubleEscapeStart; }
                else { emitText('<'); state = State.scriptDataEscaped; }
                return;

            case State.scriptDataDoubleEscapeStart, State.scriptDataDoubleEscapeEnd:
            {
                bool starting = state == State.scriptDataDoubleEscapeStart;
                if (isSpace(c) || c == '/' || c == '>')
                {
                    pos++;
                    emitText(c);
                    bool isScript = temp[] == "script";
                    if (starting) state = isScript ? State.scriptDataDoubleEscaped : State.scriptDataEscaped;
                    else state = isScript ? State.scriptDataEscaped : State.scriptDataDoubleEscaped;
                }
                else if (isAlpha(c)) { pos++; temp.put(lower(c)); emitText(c); }
                else state = starting ? State.scriptDataEscaped : State.scriptDataDoubleEscaped;
                return;
            }

            case State.scriptDataDoubleEscaped:
            {
                size_t start = pos;
                while (pos < input.length && input[pos] != '-' && input[pos] != '<' && input[pos] != '\0') pos++;
                if (pos > start) emitText(input[start .. pos]);
                if (pos == input.length) return;

                c = input[pos++];
                if (c == '-') { emitText('-'); state = State.scriptDataDoubleEscapedDash; }
                else if (c == '<') { emitText('<'); state = State.scriptDataDoubleEscapedLessThan; }
                else emitText(replacement);
                return;
            }

            case State.scriptDataDoubleEscapedDash:
                pos++;
                if (c == '-') { emitText('-'); state = State.scriptDataDoubleEscapedDashDash; }
                else if (c == '<') { emitText('<'); state = State.scriptDataDoubleEscapedLessThan; }
                else if (c == '\0') { emitText(replacement); state = State.scriptDataDoubleEscaped; }
                else { emitText(c); state = State.scriptDataDoubleEscaped; }
                return;

            case State.scriptDataDoubleEscapedDashDash:
                pos++;
                if (c == '-') emitText('-');
                else if (c == '<') { emitText('<'); state = State.scriptDataDoubleEscapedLessThan; }
                else if (c == '>') { emitText('>'); state = State.scriptData; }
                else if (c == '\0') { emitText(replacement); state = State.scriptDataDoubleEscaped; }
                else { emitText(c); state = State.scriptDataDoubleEscaped; }
                return;

            case State.scriptDataDoubleEscapedLessThan:
                if (c == '/') { pos++; temp.clear(); emitText('/'); state = State.scriptDataDoubleEscapeEnd; }
                else state = State.scriptDataDoubleEscaped;
                return;

            // Attributes
            case State.beforeAttrName:
                if (isSpace(c)) { pos++; return; }
                if (c == '/' || c == '>') { state = State.afterAttrName; return; }
                startAttribute();
                if (c == '=') { pos++; tokData.put('='); }
                state = State.attrName;
                return;

            case State.attrName:
                while (pos < input.length)
                {
                    size_t start = pos;
                    while (pos < input.length && !(charClass[input[pos]] & endOfAttrName)) pos++;
                    putLower(tokData, input[start .. pos]);
                    if (pos == input.length) return;

                    c = input[pos];
                    if (isSpace(c) || c == '/' || c == '>') { endAttrName(); state = State.afterAttrName; return; }
                    pos++;
                    if (c == '=') { endAttrName(); state = State.beforeAttrValue; return; }
                    tokData.put(replacement);
                }
                return;

            case State.afterAttrName:
                if (isSpace(c)) { pos++; return; }
                if (c == '/') { pos++; state = State.selfClosingStartTag; return; }
                if (c == '=') { pos++; state = State.beforeAttrValue; return; }
                if (c == '>') { pos++; emitTag(); return; }
                startAttribute();
                state = State.attrName;
                return;

            case State.beforeAttrValue:
                if (isSpace(c)) { pos++; return; }
                startValue();
                if (c == '"') { pos++; state = State.attrValueDoubleQuoted; }
                else if (c == '\'') { pos++; state = State.attrValueSingleQuoted; }
                else if (c == '>') { pos++; emitTag(); }
                else state = State.attrValueUnquoted;
                return;

            case State.attrValueDoubleQuoted, State.attrValueSingleQuoted:
            {
                char q = state == State.attrValueDoubleQuoted ? '"' : '\'';
                while (pos < input.length)
                {
                    size_t start = pos;
                    while (pos < input.length && input[pos] != q && input[pos] != '&' && input[pos] != '\0') pos++;
                    tokData.put(input[start .. pos]);
                    if (pos == input.length) return;

                    c = input[pos++];
                    if (c == q) { state = State.afterAttrValueQuoted; return; }
                    if (c == '&') { returnState = state; state = State.charRef; return; }
                    tokData.put(replacement);
                }
                return;
            }

            case State.attrValueUnquoted:
                while (pos < input.length)
                {
                    size_t start = pos;
                    while (pos < input.length && !(charClass[input[pos]] & endOfUnquoted)) pos++;
                    tokData.put(input[start .. pos]);
                    if (pos == input.length) return;

                    c = input[pos];
                    if (isSpace(c)) { pos++; endAttribute(); state = State.beforeAttrName; return; }
                    if (c == '>') { pos++; emitTag(); return; }
                    pos++;
                    if (c == '&') { returnState = State.attrValueUnquoted; state = State.charRef; return; }
                    if (c == '\0') { foreach (r; replacement) tokData.put(r); continue; }
                    tokData.put(c);
                }
                return;

            case State.afterAttrValueQuoted:
                endAttribute();
                if (isSpace(c)) { pos++; state = State.beforeAttrName; }
                else if (c == '/') { pos++; state = State.selfClosingStartTag; }
                else if (c == '>') { pos++; emitTag(); }
                else state = State.beforeAttrName;
                return;

            case State.selfClosingStartTag:
                if (c == '>') { pos++; selfClosing = true; emitTag(); }
                else state = State.beforeAttrName;
                return;

            // Comments
            case State.bogusComment:
                while (pos < input.length)
                {
                    c = input[pos++];
                    if (c == '>') { emitComment(); state = State.data; return; }
                    if (c == '\0') { foreach (r; replacement) tokData.put(r); continue; }
                    tokData.put(c);
                }
                return;

            case State.markupDeclarationOpen:
            {
                auto dashes = lookahead("--", false);
                if (dashes < 0) { holdBack(); return; }
                if (dashes > 0) { pos += 2; startComment(); state = State.commentStart; return; }

                auto dt = lookahead("doctype", true);
                if (dt < 0) { holdBack(); return; }
                if (dt > 0) { pos += 7; state = State.doctype; return; }

                auto cd = lookahead("[CDATA[", false);
                if (cd < 0) { holdBack(); return; }
                if (cd > 0)
                {
                    pos += 7;
                    flushText();
                    if (sink.inForeignContent(sink.context)) state = State.cdataSection;
                    else
                    {
                        startComment();
                        foreach (ch; "[CDATA[") tokData.put(ch);
                        state = State.bogusComment;
                    }
                    return;
                }

                startComment();
                state = State.bogusComment;
                return;
            }

            case State.commentStart:
                if (c == '-') { pos++; state = State.commentStartDash; }
                else if (c == '>') { pos++; emitComment(); state = State.data; }
                else state = State.comment;
                return;

            case State.commentStartDash:
                if (c == '-') { pos++; state = State.commentEnd; }
                else if (c == '>') { pos++; emitComment(); state = State.data; }
                else { tokData.put('-'); state = State.comment; }
                return;

            case State.comment:
                while (pos < input.length)
                {
                    size_t start = pos;
                    while (pos < input.length && input[pos] != '<' && input[pos] != '-' && input[pos] != '\0') pos++;
                    tokData.put(input[start .. pos]);
                    if (pos == input.length) return;

                    c = input[pos++];
                    if (c == '<') { tokData.put('<'); state = State.commentLessThan; return; }
                    if (c == '-') { state = State.commentEndDash; return; }
                    tokData.put(replacement);
                }
                return;

            case State.commentLessThan:
                if (c == '!') { pos++; tokData.put('!'); state = State.commentLessThanBang; }
                else if (c == '<') { pos++; tokData.put('<'); }
                else state = State.comment;
                return;

            case State.commentLessThanBang:
                if (c == '-') { pos++; state = State.commentLessThanBangDash; }
                else state = State.comment;
                return;

            case State.commentLessThanBangDash:
                if (c == '-') { pos++; state = State.commentLessThanBangDashDash; }
                else state = State.commentEndDash;
                return;

            case State.commentLessThanBangDashDash:
                state = State.commentEnd;
                return;

            case State.commentEndDash:
                if (c == '-') { pos++; state = State.commentEnd; }
                else { tokData.put('-'); state = State.comment; }
                return;

            case State.commentEnd:
                if (c == '>') { pos++; emitComment(); state = State.data; }
                else if (c == '!') { pos++; state = State.commentEndBang; }
                else if (c == '-') { pos++; tokData.put('-'); }
                else { tokData.put('-'); tokData.put('-'); state = State.comment; }
                return;

            case State.commentEndBang:
                if (c == '-') { pos++; foreach (ch; "--!") tokData.put(ch); state = State.commentEndDash; }
                else if (c == '>') { pos++; emitComment(); state = State.data; }
                else { foreach (ch; "--!") tokData.put(ch); state = State.comment; }
                return;

            // Doctype
            case State.doctype:
                startDoctype();
                if (isSpace(c)) pos++;
                state = State.beforeDoctypeName;
                return;

            case State.beforeDoctypeName:
                if (isSpace(c)) { pos++; return; }
                if (c == '>') { pos++; forceQuirks = true; emitDoctype(); state = State.data; return; }
                hasName = true;
                nameStart = tokData.length;
                state = State.doctypeName;
                return;

            case State.doctypeName:
                while (pos < input.length)
                {
                    c = input[pos++];
                    if (isSpace(c)) { nameLen = tokData.length - nameStart; state = State.afterDoctypeName; return; }
                    if (c == '>') { nameLen = tokData.length - nameStart; emitDoctype(); state = State.data; return; }
                    if (c == '\0') { foreach (r; replacement) tokData.put(r); continue; }
                    tokData.put(lower(c));
                }
                return;

            case State.afterDoctypeName:
            {
                if (isSpace(c)) { pos++; return; }
                if (c == '>') { pos++; emitDoctype(); state = State.data; return; }

                auto pub = lookahead("public", true);
                if (pub < 0) { holdBack(); return; }
                if (pub > 0) { pos += 6; state = State.afterDoctypePublicKeyword; return; }

                auto sys = lookahead("system", true);
                if (sys < 0) { holdBack(); return; }
                if (sys > 0) { pos += 6; state = State.afterDoctypeSystemKeyword; return; }

                forceQuirks = true;
                state = State.bogusDoctype;
                return;
            }

            case State.afterDoctypePublicKeyword, State.beforeDoctypePublicId:
                if (isSpace(c)) { pos++; state = State.beforeDoctypePublicId; return; }
                if (c == '"' || c == '\'')
                {
                    pos++;
                    hasPublic = true;
                    publicStart = tokData.length;
                    state = c == '"' ? State.doctypePublicIdDoubleQuoted : State.doctypePublicIdSingleQuoted;
                    return;
                }
                if (c == '>') { pos++; forceQuirks = true; emitDoctype(); state = State.data; return; }
                forceQuirks = true;
                state = State.bogusDoctype;
                return;

            case State.doctypePublicIdDoubleQuoted, State.doctypePublicIdSingleQuoted,
                 State.doctypeSystemIdDoubleQuoted, State.doctypeSystemIdSingleQuoted:
            {
                bool pub = state == State.doctypePublicIdDoubleQuoted || state == State.doctypePublicIdSingleQuoted;
                char q = state == State.doctypePublicIdDoubleQuoted || state == State.doctypeSystemIdDoubleQuoted ? '"' : '\'';
                while (pos < input.length)
                {
                    c = input[pos++];
                    if (c == q || c == '>')
                    {
                        if (pub) publicLen = tokData.length - publicStart;
                        else systemLen = tokData.length - systemStart;

                        if (c == q) state = pub ? State.afterDoctypePublicId : State.afterDoctypeSystemId;
                        else { forceQuirks = true; emitDoctype(); state = State.data; }
                        return;
                    }
                    if (c == '\0') { foreach (r; replacement) tokData.put(r); continue; }
                    tokData.put(c);
                }
                return;
            }

            case State.afterDoctypePublicId, State.betweenDoctypePublicAndSystem:
                if (isSpace(c)) { pos++; state = State.betweenDoctypePublicAndSystem; return; }
                if (c == '>') { pos++; emitDoctype(); state = State.data; return; }
                if (c == '"' || c == '\'')
                {
                    pos++;
                    hasSystem = true;
                    systemStart = tokData.length;
                    state = c == '"' ? State.doctypeSystemIdDoubleQuoted : State.doctypeSystemIdSingleQuoted;
                    return;
                }
                forceQuirks = true;
                state = State.bogusDoctype;
                return;

            case State.afterDoctypeSystemKeyword, State.beforeDoctypeSystemId:
                if (isSpace(c)) { pos++; state = State.beforeDoctypeSystemId; return; }
                if (c == '"' || c == '\'')
                {
                    pos++;
                    hasSystem = true;
                    systemStart = tokData.length;
                    state = c == '"' ? State.doctypeSystemIdDoubleQuoted : State.doctypeSystemIdSingleQuoted;
                    return;
                }
                if (c == '>') { pos++; forceQuirks = true; emitDoctype(); state = State.data; return; }
                forceQuirks = true;
                state = State.bogusDoctype;
                return;

            case State.afterDoctypeSystemId:
                if (isSpace(c)) { pos++; return; }
                if (c == '>') { pos++; emitDoctype(); state = State.data; return; }
                state = State.bogusDoctype;
                return;

            case State.bogusDoctype:
                while (pos < input.length)
                    if (input[pos++] == '>') { emitDoctype(); state = State.data; return; }
                return;

            // CDATA sections: the text is emitted as is
            case State.cdataSection:
            {
                size_t start = pos;
                while (pos < input.length && input[pos] != ']') pos++;
                if (pos > start) emitText(input[start .. pos]);
                foreach (ch; input[start .. pos]) if (ch == '\0') { textHasNull = true; break; }
                if (pos == input.length) return;
                pos++;
                state = State.cdataSectionBracket;
                return;
            }

            case State.cdataSectionBracket:
                if (c == ']') { pos++; state = State.cdataSectionEnd; }
                else { emitText(']'); state = State.cdataSection; }
                return;

            case State.cdataSectionEnd:
                if (c == ']') { pos++; emitText(']'); }
                else if (c == '>') { pos++; state = State.data; }
                else { emitText("]]"); state = State.cdataSection; }
                return;

            // Character references
            case State.charRef:
                if (isAlnum(c)) { matcher = EntityMatcher.init; refBuf.clear(); state = State.namedCharRef; }
                else if (c == '#') { pos++; state = State.numericCharRef; }
                else { flushRef("&"); state = returnState; }
                return;

            case State.namedCharRef:
                while (pos < input.length)
                {
                    c = input[pos];
                    if (!matcher.put(c)) { namedRefDone(c, true); return; }
                    refBuf.put(c);
                    pos++;
                }
                return;

            case State.numericCharRef:
                charCode = 0;
                charCodeOverflow = false;
                if (c == 'x' || c == 'X') { pos++; refBuf.clear(); refBuf.put(c); state = State.hexCharRefStart; }
                else state = State.decimalCharRefStart;
                return;

            case State.hexCharRefStart:
                if (isHex(c)) state = State.hexCharRef;
                else { flushRef("&#"); flushRef(refBuf[]); state = returnState; }
                return;

            case State.decimalCharRefStart:
                if (isDigit(c)) state = State.decimalCharRef;
                else { flushRef("&#"); state = returnState; }
                return;

            case State.hexCharRef, State.decimalCharRef:
            {
                bool hex = state == State.hexCharRef;
                while (pos < input.length)
                {
                    c = input[pos];
                    uint d;
                    if (isDigit(c)) d = c - '0';
                    else if (hex && isHex(c)) d = lower(c) - 'a' + 10;
                    else
                    {
                        if (c == ';') pos++;
                        numericRefDone();
                        return;
                    }

                    pos++;
                    if (charCode > 0x10FFFF) charCodeOverflow = true;
                    else charCode = charCode * (hex ? 16 : 10) + d;
                }
                return;
            }

            // Processing instructions (`<?target data?>`)
            case State.processingInstructionOpen:
                if (isAlpha(c) || c == '_') { tokData.clear(); state = State.processingInstructionTarget; }
                else
                {
                    startComment();
                    tokData.put('?');
                    state = State.bogusComment;
                }
                return;

            case State.processingInstructionTarget:
                while (pos < input.length)
                {
                    c = input[pos];
                    if (isSpace(c) || c == '\r' || c == '?' || c == '>')
                    {
                        auto t = tokData[];
                        if (equalsCi(t, "xml") || equalsCi(t, "xml-stylesheet")) { targetToComment(); return; }
                        targetLen = tokData.length;
                        state = State.afterProcessingInstructionTarget;
                        return;
                    }
                    if (!isAlnum(c) && c != '-' && c != '_') { targetToComment(); return; }
                    tokData.put(c);
                    pos++;
                }
                return;

            case State.afterProcessingInstructionTarget:
                if (isSpace(c)) { pos++; return; }
                state = State.processingInstructionData;
                return;

            case State.processingInstructionData:
                while (pos < input.length)
                {
                    c = input[pos++];
                    if (c == '?') { state = State.processingInstructionQuestionable; return; }
                    if (c == '>') { emitProcessingInstruction(); state = State.data; return; }
                    tokData.put(c);
                }
                return;

            case State.processingInstructionQuestionable:
                if (c == '>') { pos++; emitProcessingInstruction(); state = State.data; }
                else { tokData.put('?'); state = State.processingInstructionData; }
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
        state = State.bogusComment;
    }

    // The text state an end tag state goes back to
    static State textStateOf(State s) pure
    {
        switch (s)
        {
            case State.rcdataEndTagOpen, State.rcdataEndTagName: return State.rcdata;
            case State.rawtextEndTagOpen, State.rawtextEndTagName: return State.rawtext;
            case State.scriptDataEndTagOpen, State.scriptDataEndTagName: return State.scriptData;
            default: return State.scriptDataEscaped;
        }
    }

    // The named reference ends before `next` (not consumed). `hasNext` is false at EOF.
    void namedRefDone(char next, bool hasNext)
    {
        auto consumed = refBuf[];

        if (matcher.best == size_t.max)
        {
            // No match: the chars are plain text
            flushRef("&");
            flushRef(consumed);
            state = returnState;
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

        flushRef(e.value);
        flushRef(rest);
        state = returnState;
    }

    void numericRefDone()
    {
        uint cp = charCodeOverflow ? 0x110000 : charCode;

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
        while (!failed)
        {
            final switch (state)
            {
                case State.data, State.rcdata, State.rawtext, State.scriptData, State.plaintext,
                     State.scriptDataEscaped, State.scriptDataEscapedDash, State.scriptDataEscapedDashDash,
                     State.scriptDataDoubleEscaped, State.scriptDataDoubleEscapedDash, State.scriptDataDoubleEscapedDashDash,
                     State.cdataSection:
                    return;

                case State.tagOpen: emitText('<'); return;
                case State.endTagOpen: emitText("</"); return;

                case State.rcdataLessThan, State.rawtextLessThan, State.scriptDataLessThan, State.scriptDataEscapedLessThan:
                    emitText('<'); return;

                case State.rcdataEndTagOpen, State.rawtextEndTagOpen, State.scriptDataEndTagOpen, State.scriptDataEscapedEndTagOpen:
                    emitText("</"); return;

                case State.rcdataEndTagName, State.rawtextEndTagName, State.scriptDataEndTagName, State.scriptDataEscapedEndTagName:
                    emitText("</"); emitText(temp[]); return;

                case State.scriptDataEscapeStart, State.scriptDataEscapeStartDash,
                     State.scriptDataDoubleEscapeStart, State.scriptDataDoubleEscapeEnd, State.scriptDataDoubleEscapedLessThan:
                    return;

                // EOF in a tag: the tag is dropped
                case State.tagName, State.beforeAttrName, State.attrName, State.afterAttrName, State.beforeAttrValue,
                     State.attrValueDoubleQuoted, State.attrValueSingleQuoted, State.attrValueUnquoted,
                     State.afterAttrValueQuoted, State.selfClosingStartTag:
                    return;

                case State.bogusComment, State.commentStart, State.commentStartDash, State.comment, State.commentLessThan,
                     State.commentLessThanBang, State.commentLessThanBangDash, State.commentLessThanBangDashDash,
                     State.commentEndDash, State.commentEnd, State.commentEndBang:
                    emitComment(); return;

                case State.markupDeclarationOpen:
                    startComment(); emitComment(); return;

                case State.doctype, State.beforeDoctypeName:
                    startDoctype(); forceQuirks = true; emitDoctype(); return;

                case State.doctypeName:
                    nameLen = tokData.length - nameStart; forceQuirks = true; emitDoctype(); return;

                case State.doctypePublicIdDoubleQuoted, State.doctypePublicIdSingleQuoted:
                    publicLen = tokData.length - publicStart; forceQuirks = true; emitDoctype(); return;

                case State.doctypeSystemIdDoubleQuoted, State.doctypeSystemIdSingleQuoted:
                    systemLen = tokData.length - systemStart; forceQuirks = true; emitDoctype(); return;

                case State.afterDoctypeName, State.afterDoctypePublicKeyword, State.beforeDoctypePublicId,
                     State.afterDoctypePublicId, State.betweenDoctypePublicAndSystem, State.afterDoctypeSystemKeyword,
                     State.beforeDoctypeSystemId, State.afterDoctypeSystemId:
                    forceQuirks = true; emitDoctype(); return;

                case State.bogusDoctype: emitDoctype(); return;

                case State.cdataSectionBracket: emitText(']'); return;
                case State.cdataSectionEnd: emitText("]]"); return;

                case State.charRef: flushRef("&"); state = returnState; continue;
                case State.namedCharRef: namedRefDone('\0', false); continue;
                case State.numericCharRef: flushRef("&#"); state = returnState; continue;
                case State.hexCharRefStart: flushRef("&#"); flushRef(refBuf[]); state = returnState; continue;
                case State.decimalCharRefStart: flushRef("&#"); state = returnState; continue;
                case State.hexCharRef, State.decimalCharRef: numericRefDone(); continue;

                // EOF in a processing instruction: nothing is emitted (as lexbor does)
                case State.processingInstructionOpen, State.processingInstructionTarget, State.afterProcessingInstructionTarget,
                     State.processingInstructionData, State.processingInstructionQuestionable:
                    return;
            }
        }
    }
}
