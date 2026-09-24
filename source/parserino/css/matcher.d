/++
 Matching of CSS selectors against the DOM.

 Complex selectors are matched right to left, with backtracking on the
 descendant and subsequent-sibling combinators. `:has()` is matched forward.
+/
module parserino.css.matcher;

import parserino.css.selector;

import parserino.dom;
import parserino.names;

@nogc nothrow pure @safe:

/++ Does the element match any selector of the list?
 + `scope` is the element matched by `:scope` (the root of the query).
 +/
bool matches(const(SelectorList)* list, DomNode* node, DomNode* scopeElement = null)
{
    if (node.type != NodeType.Element) return false;
    return Matcher(scopeElement).matchList(*list, node);
}

/// Does the element match the last compound of the selector `item` of the list? (a quick test)
bool matchesLastCompound(const(SelectorList)* list, size_t item, DomNode* node, DomNode* scopeElement = null)
{
    auto cs = list.items[item].compounds;
    return Matcher(scopeElement).matchCompound(cs[$ - 1], node);
}

private:

// The state of a match
struct Matcher
{
@nogc nothrow pure @safe:

    // The element matched by :scope
    DomNode* scopeNode;

    bool matchList(ref const SelectorList list, DomNode* node)
    {
        foreach (ref c; list.items)
            if (matchComplex(c, node, c.compounds.length - 1)) return true;

        return false;
    }

    bool matchComplex(ref const Complex c, DomNode* node, size_t i)
    {
        if (!matchCompound(c.compounds[i], node)) return false;
        if (i == 0) return true;

        final switch (c.compounds[i].combinator)
        {
            case Combinator.Descendant:
                for (auto p = node.parent; p !is null; p = p.parent)
                    if (p.type == NodeType.Element && matchComplex(c, p, i - 1)) return true;
                return false;

            case Combinator.Child:
                auto p = node.parent;
                return p !is null && p.type == NodeType.Element && matchComplex(c, p, i - 1);

            case Combinator.NextSibling:
                auto p = prevElement(node);
                return p !is null && matchComplex(c, p, i - 1);

            case Combinator.SubsequentSibling:
                for (auto p = prevElement(node); p !is null; p = prevElement(p))
                    if (matchComplex(c, p, i - 1)) return true;
                return false;
        }
    }

    // :has(): the relative selector is matched left to right, starting from the anchor
    bool matchForward(ref const Complex c, DomNode* from, size_t i)
    {
        bool tryNode(DomNode* n)
        {
            return matchCompound(c.compounds[i], n) && (i + 1 == c.compounds.length || matchForward(c, n, i + 1));
        }

        final switch (c.compounds[i].combinator)
        {
            case Combinator.Descendant:
                for (auto n = nextInSubtree(from, from, true); n !is null; n = nextInSubtree(n, from, true))
                    if (n.type == NodeType.Element && tryNode(n)) return true;
                return false;

            case Combinator.Child:
                for (auto n = from.firstChild; n !is null; n = n.next)
                    if (n.type == NodeType.Element && tryNode(n)) return true;
                return false;

            case Combinator.NextSibling:
                auto n = nextElement(from);
                return n !is null && tryNode(n);

            case Combinator.SubsequentSibling:
                for (auto n = nextElement(from); n !is null; n = nextElement(n))
                    if (tryNode(n)) return true;
                return false;
        }
    }

    bool matchCompound(ref const Compound comp, DomNode* node)
    {
        foreach (ref s; comp.simples)
            if (!matchSimple(s, node)) return false;

        return true;
    }

    bool matchSimple(ref const Simple s, DomNode* node)
    {
        auto e = node.as!DomElement;

        final switch (s.kind)
        {
            case SimpleKind.Universal:
                return nsMatches(s.ns, node.ns);

            case SimpleKind.Type:
                if (!nsMatches(s.ns, node.ns)) return false;
                // HTML elements: the selector in lowercase; the others: as written (`clipPath`)
                if (node.ns != Ns.Html) return e.fullName == s.rawName;
                auto id = s.knownId ? s.knownId : node.document.findTagName(s.name);
                return id != Tag.Undef && node.name == id;

            case SimpleKind.Never:
                return false;

            case SimpleKind.Lang:
                return matchLang(s.ranges, node);

            case SimpleKind.Dir:
                return s.name == (isRtl(node) ? "rtl" : "ltr");

            case SimpleKind.Id:
                if (e.idAttr is null) return false;
                return equal(e.idAttr.value, s.name, isQuirks(node));

            case SimpleKind.Class:
                if (e.classAttr is null) return false;
                return containsWord(e.classAttr.value, s.name, isQuirks(node));

            case SimpleKind.Attribute:
                return matchAttribute(s, node);

            case SimpleKind.PseudoClass:
                return matchPseudoClass(s.pseudo, node);

            case SimpleKind.Not:
                return !matchList(*s.list, node);

            case SimpleKind.Is:
                return matchList(*s.list, node);

            case SimpleKind.Has:
                foreach (ref c; s.list.items)
                    if (matchForward(c, node, 0)) return true;
                return false;

            case SimpleKind.NthChild, SimpleKind.NthLastChild:
                bool forward = s.kind == SimpleKind.NthLastChild;
                size_t index = 0;

                if (s.list !is null)
                {
                    // `of S`: count the siblings matching S (the element itself must match)
                    if (!matchList(*s.list, node)) return false;
                    for (auto n = node; n !is null; n = forward ? nextElement(n) : prevElement(n))
                        if (matchList(*s.list, n)) index++;
                }
                else
                {
                    for (auto n = node; n !is null; n = forward ? nextElement(n) : prevElement(n)) index++;
                }

                return nth(s.a, s.b, index);

            case SimpleKind.NthOfType, SimpleKind.NthLastOfType:
                bool forward = s.kind == SimpleKind.NthLastOfType;
                size_t index = 0;

                for (auto n = node; n !is null; n = forward ? nextElement(n) : prevElement(n))
                    if (n.name == node.name && n.ns == node.ns) index++;

                return nth(s.a, s.b, index);

            case SimpleKind.Contains:
                for (auto n = node.firstChild; n !is null; n = n.next)
                {
                    if (n.type != NodeType.Text) continue;
                    auto text = n.as!DomCharacterData.data;
                    if (containsText(text, s.name, s.insensitive)) return true;
                }
                return false;
        }
    }

    bool matchAttribute(ref const Simple s, DomNode* node)
    {
        auto id = s.knownId ? s.knownId : node.document.findAttrName(s.name);
        if (id == 0) return false;

        // The names of the attributes of HTML elements are lowercase; for the other elements, and
        // for the attributes with a namespace, the name is compared as written (`viewBox`)
        DomAttribute* attr;
        for (attr = node.as!DomElement.firstAttr; attr !is null; attr = attr.next)
        {
            if (attr.name != id || !attrNsMatches(s.ns, attr.ns)) continue;
            if ((node.ns == Ns.Html && attr.ns == Ns.None) || localPart(attr.fullName) == s.rawName) break;
        }
        if (attr is null) return false;
        if (s.match == AttrMatch.Exists) return true;

        const(char)[] v = attr.value;
        auto want = s.value;

        bool ci = s.attrCase == AttrCase.Insensitive
            || (s.attrCase == AttrCase.Auto && attr.ns == Ns.None && htmlCaseInsensitive(node, id));

        final switch (s.match)
        {
            case AttrMatch.Exists: return true;
            case AttrMatch.Equal: return equal(v, want, ci);
            case AttrMatch.Includes: return containsWord(v, want, ci);
            case AttrMatch.Dash:
                if (v.length == want.length) return equal(v, want, ci);
                return v.length > want.length && equal(v[0 .. want.length], want, ci) && v[want.length] == '-';
            case AttrMatch.Prefix: return want.length && v.length >= want.length && equal(v[0 .. want.length], want, ci);
            case AttrMatch.Suffix: return want.length && v.length >= want.length && equal(v[$ - want.length .. $], want, ci);
            case AttrMatch.Substring: return want.length && containsText(v, want, ci);
        }
    }

    bool matchPseudoClass(PseudoClass p, DomNode* node)
    {
        final switch (p)
        {
            case PseudoClass.AnyLink, PseudoClass.Link:
                return isHtml(node, Tag.A, Tag.Area) && hasAttr(node, AttrName.Href);

            case PseudoClass.Blank:
                return node.isBlank;

            case PseudoClass.Checked:
                if (isHtml(node, Tag.Input))
                {
                    auto t = attrById(node, AttrName.Type);
                    if (t is null || t.value is null) return false;
                    auto v = value(t);
                    return (equal(v, "checkbox", true) || equal(v, "radio", true)) && hasAttr(node, AttrName.Checked);
                }
                return isHtml(node, Tag.Option) && isSelectedOption(node);

            case PseudoClass.Disabled: return canBeDisabled(node) && isDisabled(node);
            case PseudoClass.Enabled: return canBeDisabled(node) && !isDisabled(node);

            case PseudoClass.Empty:
                return node.isEmpty;

            case PseudoClass.FirstChild: return prevElement(node) is null;
            case PseudoClass.LastChild: return nextElement(node) is null;
            case PseudoClass.OnlyChild: return prevElement(node) is null && nextElement(node) is null;
            case PseudoClass.FirstOfType: return firstOfType(node);
            case PseudoClass.LastOfType: return lastOfType(node);
            case PseudoClass.OnlyOfType: return firstOfType(node) && lastOfType(node);

            case PseudoClass.Optional: return isFormField(node) && !hasAttr(node, AttrName.Required);
            case PseudoClass.Required: return isFormField(node) && hasAttr(node, AttrName.Required);

            case PseudoClass.PlaceholderShown:
                if (!hasAttr(node, AttrName.Placeholder)) return false;
                if (isHtml(node, Tag.Input))
                {
                    auto v = attrByName(node, "value");
                    return v is null || v.value.length == 0;
                }
                if (isHtml(node, Tag.Textarea)) return node.firstChild is null;
                return false;

            case PseudoClass.ReadWrite: return isReadWrite(node);
            case PseudoClass.ReadOnly: return !isReadWrite(node);

            case PseudoClass.Root:
                return node is rootElement(node);

            case PseudoClass.Scope:
                if (scopeNode is null || scopeNode.type != NodeType.Element)
                    return node is rootElement(node);
                return node is scopeNode;
        }
    }

}

bool isHtml(DomNode* n, uint a, uint b = Tag.Undef, uint c = Tag.Undef)
{
    return n.ns == Ns.Html && (n.name == a || (b != Tag.Undef && n.name == b) || (c != Tag.Undef && n.name == c));
}

bool isFormField(DomNode* n) { return isHtml(n, Tag.Input, Tag.Select, Tag.Textarea); }

// Elements that support the disabled state
bool canBeDisabled(DomNode* n)
{
    return isHtml(n, Tag.Button, Tag.Input, Tag.Select) || isHtml(n, Tag.Textarea, Tag.Optgroup, Tag.Option)
        || isHtml(n, Tag.Fieldset) || (n.name >= Tag.Last && hasAttr(n, AttrName.Disabled));
}

// HTML: "actually disabled"
bool isDisabled(DomNode* node)
{
    if (hasAttr(node, AttrName.Disabled)) return true;

    if (isHtml(node, Tag.Option))
    {
        auto p = node.parent;
        return p !is null && isHtml(p, Tag.Optgroup) && hasAttr(p, AttrName.Disabled);
    }

    if (isHtml(node, Tag.Optgroup)) return false;

    // Inside a disabled fieldset, but not inside its first legend
    DomNode* child = node;
    for (auto p = node.parent; p !is null; child = p, p = p.parent)
    {
        if (!isHtml(p, Tag.Fieldset) || !hasAttr(p, AttrName.Disabled)) continue;

        DomNode* legend = null;
        for (auto c = p.firstChild; c !is null; c = c.next)
            if (c.type == NodeType.Element && isHtml(c, Tag.Legend)) { legend = c; break; }

        if (child !is legend) return true;
    }

    return false;
}

// HTML: option selectedness (the first option of a single select is selected by default)
bool isSelectedOption(DomNode* option)
{
    if (hasAttr(option, AttrName.Selected)) return true;

    auto select = option.parent;
    if (select !is null && isHtml(select, Tag.Optgroup)) select = select.parent;
    if (select is null || !isHtml(select, Tag.Select)) return false;
    if (hasAttr(select, AttrName.Multiple)) return false;

    auto size = attrById(select, AttrName.Size);
    if (size !is null && size.value !is null)
    {
        long n = 0;
        foreach (c; value(size))
        {
            if (c < '0' || c > '9') break;
            n = n * 10 + (c - '0');
            if (n > 1) return false;
        }
    }

    // No option selected: the first one that is not disabled
    DomNode* first = null;
    for (auto n = nextInSubtree(select, select, true); n !is null; n = nextInSubtree(n, select, true))
    {
        if (!isHtml(n, Tag.Option)) continue;
        if (hasAttr(n, AttrName.Selected)) return false;
        if (first is null && !isDisabled(n)) first = n;
    }

    return first is option;
}

// HTML: inputs and textareas that can be edited, and contenteditable elements
bool isReadWrite(DomNode* n)
{
    if (isHtml(n, Tag.Input))
    {
        if (hasAttr(n, AttrName.Readonly) || isDisabled(n)) return false;

        auto t = attrById(n, AttrName.Type);
        if (t is null || t.value is null) return true;

        static immutable string[] editable = [
            "text", "search", "url", "tel", "email", "password", "date", "month", "week", "time",
            "datetime-local", "number",
        ];

        auto v = value(t);
        foreach (e; editable) if (equal(v, e, true)) return true;

        // Invalid types are text inputs
        static immutable string[] other = [
            "hidden", "range", "color", "checkbox", "radio", "file", "submit", "image", "reset", "button",
        ];
        foreach (o; other) if (equal(v, o, true)) return false;
        return true;
    }

    if (isHtml(n, Tag.Textarea)) return !hasAttr(n, AttrName.Readonly) && !isDisabled(n);

    // contenteditable is inherited
    for (auto p = n; p !is null && p.type == NodeType.Element; p = p.parent)
    {
        auto ce = attrByName(p, "contenteditable");
        if (ce is null) continue;
        auto v = ce.value is null ? "" : value(ce);
        if (v.length == 0 || equal(v, "true", true) || equal(v, "plaintext-only", true)) return true;
        if (equal(v, "false", true)) return false;
    }

    return false;
}

// :lang(): the language of the element comes from the closest `lang` attribute
bool matchLang(const(const(char)[])[] ranges, DomNode* node)
{
    const(char)[] lang;
    if (!language(node, lang)) return false;

    foreach (range; ranges)
        if (extendedFilter(range, lang)) return true;

    return false;
}

/+ The language of an element (HTML "the language of a node"): the nearest `xml:lang` (it wins
 + over `lang` on the same element) or `lang`, else the default language of the document
 + (`<meta http-equiv="content-language">`). False if unknown.
 +/
bool language(DomNode* node, out const(char)[] lang)
{
    for (auto p = node; p !is null && p.type == NodeType.Element; p = p.parent)
    {
        DomAttribute* plain = null;
        for (auto a = p.as!DomElement.firstAttr; a !is null; a = a.next)
        {
            if (a.name != AttrName.Lang) continue;
            if (a.ns == Ns.Xml) { lang = a.value is null ? "" : a.value; return true; }
            if (a.ns == Ns.None && (p.ns == Ns.Html || p.ns == Ns.Svg)) plain = a;
        }
        if (plain !is null) { lang = plain.value is null ? "" : plain.value; return true; }
    }

    return defaultLanguage(node.document, lang);
}

// The "pragma-set default language": the last valid <meta http-equiv="content-language">
bool defaultLanguage(DomDocument* doc, out const(char)[] lang)
{
    bool found = false;
    for (auto n = doc.node.firstChild; n !is null; n = n.nextInTree(&doc.node))
    {
        if (!n.isHtml(Tag.Meta)) continue;
        auto equiv = attrById(n, AttrName.HttpEquiv);
        auto content = attrById(n, AttrName.Content);
        if (equiv is null || content is null || !equal(value(equiv), "content-language", true)) continue;

        auto v = value(content);
        bool comma = false;
        foreach (c; v) if (c == ',') { comma = true; break; }
        if (comma) continue;

        // Strip the whitespace
        size_t a = 0, b = v.length;
        while (a < b && isSpace(v[a])) a++;
        while (b > a && isSpace(v[b - 1])) b--;
        if (a == b) continue;

        lang = v[a .. b];
        found = true;
    }
    return found;
}

bool isSpace(char c) { return c == ' ' || c == '\t' || c == '\n' || c == '\f' || c == '\r'; }

/+ The "extended filtering" of RFC 4647 (3.3.2), used by :lang() in Selectors 4:
 + `de-DE` matches `de-DE`, `de-Latn-DE`, `de-DE-1996`; `*-CH` matches `fr-CH`, `de-CH`.
 + An empty language matches nothing (and `*` matches any non-empty language).
 +/
bool extendedFilter(const(char)[] range, const(char)[] tag)
{
    if (tag.length == 0 || range.length == 0) return false;

    // The next subtag of `s` from `i` (and `i` after its '-')
    static const(char)[] subtag(const(char)[] s, ref size_t i)
    {
        size_t start = i;
        while (i < s.length && s[i] != '-') i++;
        auto r = s[start .. i];
        if (i < s.length) i++;
        return r;
    }

    size_t ri = 0, ti = 0;
    auto r = subtag(range, ri);
    auto t = subtag(tag, ti);
    if (r != "*" && !equal(r, t, true)) return false;

    while (ri < range.length)
    {
        r = subtag(range, ri);
        if (r == "*") continue;
        while (true)
        {
            if (ti >= tag.length) return false;
            t = subtag(tag, ti);
            if (equal(r, t, true)) break;
            if (t.length == 1) return false;    // a singleton (`x`, `u`, ...) ends the search
        }
    }

    return true;
}

/+ Is the directionality of the element "rtl"? (HTML "directionality"): the `dir` attribute
 + (`auto`: from the first strong character of the text), else `<bdi>` is auto, else the parent's.
 +/
bool isRtl(DomNode* node)
{
    for (auto n = node; n !is null && n.type == NodeType.Element; n = n.parent)
    {
        auto dir = n.ns == Ns.Html ? attrById(n, AttrName.Dir) : null;
        auto v = dir is null ? null : value(dir);

        if (dir !is null && equal(v, "ltr", true)) return false;
        if (dir !is null && equal(v, "rtl", true)) return true;
        if ((dir !is null && equal(v, "auto", true)) || (dir is null && n.isHtml(Tag.Bdi)))
        {
            int strong = autoDirection(n);
            return strong == 0 ? false : strong > 0;
        }
        if (n.isHtml(Tag.Input) && dir is null)
        {
            auto type = attrById(n, AttrName.Type);
            if (type !is null && equal(value(type), "tel", true)) return false;
        }
    }
    return false;
}

// The first strong character of the text of an element with dir=auto: 1 rtl, -1 ltr, 0 none.
// The text of <bdi>, <script>, <style>, <textarea> and of the elements with a valid dir is skipped.
int autoDirection(DomNode* element)
{
    for (auto n = element.firstChild; n !is null; )
    {
        if (n.type == NodeType.Element)
        {
            bool skip = false;
            if (n.ns == Ns.Html)
            {
                switch (n.name)
                {
                    case Tag.Bdi, Tag.Script, Tag.Style, Tag.Textarea: skip = true; break;
                    default:
                        auto d = attrById(n, AttrName.Dir);
                        if (d !is null)
                        {
                            auto v = value(d);
                            skip = equal(v, "ltr", true) || equal(v, "rtl", true) || equal(v, "auto", true);
                        }
                        break;
                }
            }
            n = skip ? n.nextSkippingChildren(element) : n.nextInTree(element);
            continue;
        }

        if (n.type == NodeType.Text || n.type == NodeType.CDataSection)
            if (auto d = strongDirection(n.as!DomCharacterData.data)) return d;

        n = n.nextInTree(element);
    }
    return 0;
}

// The first strong character of the text: 1 rtl (bidi class R or AL), -1 ltr (L), 0 none.
// The classes come from the Unicode blocks: an approximation of the Unicode data, good for text.
int strongDirection(const(char)[] s)
{
    size_t i = 0;
    while (i < s.length)
    {
        uint c = cast(ubyte) s[i];
        size_t len = 1;
        if (c >= 0x80)
        {
            len = c >= 0xF0 ? 4 : c >= 0xE0 ? 3 : 2;
            if (i + len > s.length) break;
            c &= 0x7F >> len;
            foreach (k; 1 .. len) c = (c << 6) | (s[i + k] & 0x3F);
        }
        i += len;

        if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')) return -1;
        if (c < 0xC0 || c == 0xD7 || c == 0xF7) continue;

        // Hebrew, Arabic, Syriac, Thaana, NKo, Samaritan, Mandaic, Arabic extended, the presentation
        // forms and the right-to-left scripts of the other planes (the Arabic digits are not strong)
        if ((c >= 0x0590 && c <= 0x08FF) || (c >= 0xFB1D && c <= 0xFDFF) || (c >= 0xFE70 && c <= 0xFEFF)
            || (c >= 0x10800 && c <= 0x10FFF) || (c >= 0x1E800 && c <= 0x1EFFF))
        {
            if ((c >= 0x0660 && c <= 0x0669) || (c >= 0x06F0 && c <= 0x06F9) || (c >= 0x0600 && c <= 0x0605)) continue;
            if ((c >= 0x0591 && c <= 0x05BD) || (c >= 0x064B && c <= 0x065F)) continue;   // combining marks
            return 1;
        }

        // Punctuation, symbols, combining marks, spaces: not strong
        if ((c >= 0x0300 && c <= 0x036F) || (c >= 0x2000 && c <= 0x2BFF) || (c >= 0x3000 && c <= 0x303F)
            || (c >= 0xFE00 && c <= 0xFE6F) || (c >= 0xFF00 && c <= 0xFF20) || (c >= 0xFFF0 && c <= 0xFFFF)
            || (c >= 0x1F000 && c <= 0x1FFFF))
            continue;

        return -1;
    }
    return 0;
}

bool nsMatches(NsMatch want, Ns ns)
{
    final switch (want)
    {
        case NsMatch.Any: return true;
        case NsMatch.None: return ns == Ns.None;
        case NsMatch.Html: return ns == Ns.Html;
        case NsMatch.Svg: return ns == Ns.Svg;
        case NsMatch.Math: return ns == Ns.Math;
        case NsMatch.Xlink: return ns == Ns.Xlink;
        case NsMatch.Xml: return ns == Ns.Xml;
        case NsMatch.Xmlns: return ns == Ns.Xmlns;
    }
}

// Attributes of html, svg and mathml elements have no namespace
bool attrNsMatches(NsMatch want, Ns ns)
{
    if (want == NsMatch.None) return ns == Ns.None;
    return nsMatches(want, ns);
}

bool firstOfType(DomNode* n)
{
    for (auto p = prevElement(n); p !is null; p = prevElement(p))
        if (p.name == n.name && p.ns == n.ns) return false;
    return true;
}

bool lastOfType(DomNode* n)
{
    for (auto p = nextElement(n); p !is null; p = nextElement(p))
        if (p.name == n.name && p.ns == n.ns) return false;
    return true;
}

// Attribute values compared case-insensitively in html documents (as in lexbor and in the html spec)
// The local part of a qualified name: `href` for `xlink:href`
const(char)[] localPart(const(char)[] name)
{
    foreach (i, c; name) if (c == ':') return name[i + 1 .. $];
    return name;
}

bool htmlCaseInsensitive(DomNode* node, uint id)
{
    if (node.ns != Ns.Html) return false;

    switch (id)
    {
        case AttrName.Accept, AttrName.AcceptCharset, AttrName.Align, AttrName.Alink, AttrName.Axis,
             AttrName.Bgcolor, AttrName.Charset, AttrName.Checked, AttrName.Clear, AttrName.Codetype,
             AttrName.Color, AttrName.Compact, AttrName.Declare, AttrName.Defer, AttrName.Dir,
             AttrName.Direction, AttrName.Disabled, AttrName.Enctype, AttrName.Face, AttrName.Frame,
             AttrName.Hreflang, AttrName.HttpEquiv, AttrName.Lang, AttrName.Language, AttrName.Link,
             AttrName.Media, AttrName.Method, AttrName.Multiple, AttrName.Nohref, AttrName.Noresize,
             AttrName.Noshade, AttrName.Nowrap, AttrName.Readonly, AttrName.Rel, AttrName.Rev,
             AttrName.Rules, AttrName.Scope, AttrName.Scrolling, AttrName.Selected, AttrName.Shape,
             AttrName.Target, AttrName.Text, AttrName.Type, AttrName.Valign, AttrName.Valuetype,
             AttrName.Vlink:
            return true;

        default:
            return false;
    }
}

// ---------------------------------------------------------------- helpers

bool nth(long a, long b, size_t index)
{
    long i = cast(long) index;
    if (a == 0) return b >= 0 && b == i;

    long d = i - b;
    return d % a == 0 && d / a >= 0;
}

DomNode* prevElement(DomNode* n)
{
    for (n = n.prev; n !is null; n = n.prev)
        if (n.type == NodeType.Element) return n;
    return null;
}

DomNode* nextElement(DomNode* n)
{
    for (n = n.next; n !is null; n = n.next)
        if (n.type == NodeType.Element) return n;
    return null;
}

// Preorder walk inside `root` (excluded)
DomNode* nextInSubtree(DomNode* n, DomNode* root, bool deep)
{
    if (deep && n.firstChild !is null) return n.firstChild;

    while (n !is root && n.next is null) n = n.parent;
    return n is root ? null : n.next;
}

DomNode* rootElement(DomNode* n)
{
    auto e = n.document.documentElement;
    return e is null ? null : &e.node;
}

bool isQuirks(DomNode* n) { return n.document.compatMode == CompatMode.Quirks; }

DomAttribute* attrById(DomNode* n, uint id)
{
    for (auto a = n.as!DomElement.firstAttr; a !is null; a = a.next)
        if (a.name == id) return a;
    return null;
}

bool hasAttr(DomNode* n, uint id) { return attrById(n, id) !is null; }

DomAttribute* attrByName(DomNode* n, const(char)[] name)
{
    auto id = n.document.findAttrName(name);
    return id == 0 ? null : attrById(n, id);
}

const(char)[] value(DomAttribute* a) { return a.value; }

char lower(char c) { return (c >= 'A' && c <= 'Z') ? cast(char) (c | 0x20) : c; }

bool equal(const(char)[] a, const(char)[] b, bool ci)
{
    if (a.length != b.length) return false;
    if (!ci) return a == b;
    foreach (i; 0 .. a.length) if (lower(a[i]) != lower(b[i])) return false;
    return true;
}

bool containsText(const(char)[] where, const(char)[] what, bool ci)
{
    if (what.length > where.length) return false;
    foreach (i; 0 .. where.length - what.length + 1)
        if (equal(where[i .. i + what.length], what, ci)) return true;
    return false;
}

// Is `word` one of the whitespace separated words of `list`?
bool containsWord(const(char)[] list, const(char)[] word, bool ci)
{
    if (word.length == 0 || list.length < word.length) return false;

    static bool space(char c) { return c == ' ' || c == '\t' || c == '\n' || c == '\f' || c == '\r'; }

    size_t i = 0;
    while (i < list.length)
    {
        while (i < list.length && space(list[i])) i++;
        size_t start = i;
        while (i < list.length && !space(list[i])) i++;
        if (i > start && equal(list[start .. i], word, ci)) return true;
    }

    return false;
}
