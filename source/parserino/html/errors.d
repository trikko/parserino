/++
 The parse errors of the HTML parser.

 The tokenizer uses the codes of the HTML standard (`unexpected-null-character`, ...). The
 standard doesn't name the errors of the tree construction: they have the codes after
 `MissingDoctype`, with names in the same style.
+/
module parserino.html.errors;

@nogc nothrow pure @safe:

/// The code of a parse error
enum ParseErrorCode : ubyte
{
    AbruptClosingOfEmptyComment,
    AbruptDoctypePublicIdentifier,
    AbruptDoctypeSystemIdentifier,
    AbsenceOfDigitsInNumericCharacterReference,
    CDataInHtmlContent,
    CharacterReferenceOutsideUnicodeRange,
    ControlCharacterInInputStream,
    ControlCharacterReference,
    DisallowedProcessingInstructionTarget,
    DuplicateAttribute,
    EndTagWithAttributes,
    EndTagWithTrailingSolidus,
    EofBeforeTagName,
    EofInCData,
    EofInComment,
    EofInDoctype,
    EofInProcessingInstruction,
    EofInScriptHtmlCommentLikeText,
    EofInTag,
    IncorrectlyClosedComment,
    IncorrectlyOpenedComment,
    InvalidCharacterSequenceAfterDoctypeName,
    InvalidFirstCharacterOfProcessingInstructionTarget,
    InvalidFirstCharacterOfTagName,
    InvalidProcessingInstructionTarget,
    MissingAttributeValue,
    MissingDoctypeName,
    MissingDoctypePublicIdentifier,
    MissingDoctypeSystemIdentifier,
    MissingEndTagName,
    MissingQuoteBeforeDoctypePublicIdentifier,
    MissingQuoteBeforeDoctypeSystemIdentifier,
    MissingSemicolonAfterCharacterReference,
    MissingWhitespaceAfterDoctypePublicKeyword,
    MissingWhitespaceAfterDoctypeSystemKeyword,
    MissingWhitespaceBeforeDoctypeName,
    MissingWhitespaceBetweenAttributes,
    MissingWhitespaceBetweenDoctypePublicAndSystemIdentifiers,
    NestedComment,
    NoncharacterCharacterReference,
    NoncharacterInInputStream,
    NonVoidHtmlElementStartTagWithTrailingSolidus,
    NullCharacterReference,
    SurrogateCharacterReference,
    SurrogateInInputStream,
    UnexpectedCharacterAfterDoctypeSystemIdentifier,
    UnexpectedCharacterInAttributeName,
    UnexpectedCharacterInUnquotedAttributeValue,
    UnexpectedEqualsSignBeforeAttributeName,
    UnexpectedNullCharacter,
    UnexpectedSolidusInTag,
    UnknownNamedCharacterReference,

    // Tree construction (not named by the standard)
    MissingDoctype, /// the document doesn't start with `<!DOCTYPE html>`
    NonConformingDoctype, /// a doctype other than `<!DOCTYPE html>` (legacy or quirks)
    UnexpectedDoctype, /// a doctype after the beginning
    UnexpectedStartTag, /// a start tag not allowed here (ignored or moved)
    UnexpectedEndTag, /// an end tag without a matching open element, or not allowed here
    UnexpectedText, /// text not allowed here (for example directly inside a table)
    MisnestedTag, /// an element closed while other elements inside it are still open
    UnclosedElementAtEof, /// elements still open at the end of the input
}

/// The name of a code, as in the standard: `"unexpected-null-character"`
string errorName(ParseErrorCode code) { return errorNames[code]; }

private immutable string[ParseErrorCode.max + 1] errorNames = [
    "abrupt-closing-of-empty-comment",
    "abrupt-doctype-public-identifier",
    "abrupt-doctype-system-identifier",
    "absence-of-digits-in-numeric-character-reference",
    "cdata-in-html-content",
    "character-reference-outside-unicode-range",
    "control-character-in-input-stream",
    "control-character-reference",
    "disallowed-processing-instruction-target",
    "duplicate-attribute",
    "end-tag-with-attributes",
    "end-tag-with-trailing-solidus",
    "eof-before-tag-name",
    "eof-in-cdata",
    "eof-in-comment",
    "eof-in-doctype",
    "eof-in-processing-instruction",
    "eof-in-script-html-comment-like-text",
    "eof-in-tag",
    "incorrectly-closed-comment",
    "incorrectly-opened-comment",
    "invalid-character-sequence-after-doctype-name",
    "invalid-first-character-of-processing-instruction-target",
    "invalid-first-character-of-tag-name",
    "invalid-processing-instruction-target",
    "missing-attribute-value",
    "missing-doctype-name",
    "missing-doctype-public-identifier",
    "missing-doctype-system-identifier",
    "missing-end-tag-name",
    "missing-quote-before-doctype-public-identifier",
    "missing-quote-before-doctype-system-identifier",
    "missing-semicolon-after-character-reference",
    "missing-whitespace-after-doctype-public-keyword",
    "missing-whitespace-after-doctype-system-keyword",
    "missing-whitespace-before-doctype-name",
    "missing-whitespace-between-attributes",
    "missing-whitespace-between-doctype-public-and-system-identifiers",
    "nested-comment",
    "noncharacter-character-reference",
    "noncharacter-in-input-stream",
    "non-void-html-element-start-tag-with-trailing-solidus",
    "null-character-reference",
    "surrogate-character-reference",
    "surrogate-in-input-stream",
    "unexpected-character-after-doctype-system-identifier",
    "unexpected-character-in-attribute-name",
    "unexpected-character-in-unquoted-attribute-value",
    "unexpected-equals-sign-before-attribute-name",
    "unexpected-null-character",
    "unexpected-solidus-in-tag",
    "unknown-named-character-reference",
    "missing-doctype",
    "non-conforming-doctype",
    "unexpected-doctype",
    "unexpected-start-tag",
    "unexpected-end-tag",
    "unexpected-text",
    "misnested-tag",
    "unclosed-element-at-eof",
];

/// A parse error found by the parser: the position is a line and a column (1-based, in characters)
struct RawParseError
{
    ParseErrorCode code;
    uint line;
    uint column;
}

unittest
{
    assert(errorName(ParseErrorCode.UnexpectedNullCharacter) == "unexpected-null-character");
    assert(errorName(ParseErrorCode.CDataInHtmlContent) == "cdata-in-html-content");
    assert(errorName(ParseErrorCode.MissingDoctype) == "missing-doctype");
}
