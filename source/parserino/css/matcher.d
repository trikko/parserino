/++
 Matching of CSS selectors against the DOM.

 Complex selectors are matched right to left, with backtracking on the
 descendant and subsequent-sibling combinators. `:has()` is matched forward.
+/
module parserino.css.matcher;

import parserino.css.selector;

import parserino.dom;
import parserino.names;

@nogc nothrow:

/++ Does the element match any selector of the list?
 + `scope` is the element matched by `:scope` (the root of the query).
 +/
bool matches(const(SelectorList)* list, Node* node, Node* scopeElement = null)
{
    if (node.type != NodeType.element) return false;
    scopeNode = scopeElement;
    return matchList(*list, node);
}

private:

// The element matched by :scope during the current match
Node* scopeNode;

bool matchList(ref const SelectorList list, Node* node)
{
    foreach (ref c; list.items)
        if (matchComplex(c, node, c.compounds.length - 1)) return true;

    return false;
}

bool matchComplex(ref const Complex c, Node* node, size_t i)
{
    if (!matchCompound(c.compounds[i], node)) return false;
    if (i == 0) return true;

    final switch (c.compounds[i].combinator)
    {
        case Combinator.descendant:
            for (auto p = node.parent; p !is null; p = p.parent)
                if (p.type == NodeType.element && matchComplex(c, p, i - 1)) return true;
            return false;

        case Combinator.child:
            auto p = node.parent;
            return p !is null && p.type == NodeType.element && matchComplex(c, p, i - 1);

        case Combinator.nextSibling:
            auto p = prevElement(node);
            return p !is null && matchComplex(c, p, i - 1);

        case Combinator.subsequentSibling:
            for (auto p = prevElement(node); p !is null; p = prevElement(p))
                if (matchComplex(c, p, i - 1)) return true;
            return false;
    }
}

// :has(): the relative selector is matched left to right, starting from the anchor
bool matchForward(ref const Complex c, Node* from, size_t i)
{
    bool tryNode(Node* n)
    {
        return matchCompound(c.compounds[i], n) && (i + 1 == c.compounds.length || matchForward(c, n, i + 1));
    }

    final switch (c.compounds[i].combinator)
    {
        case Combinator.descendant:
            for (auto n = nextInSubtree(from, from, true); n !is null; n = nextInSubtree(n, from, true))
                if (n.type == NodeType.element && tryNode(n)) return true;
            return false;

        case Combinator.child:
            for (auto n = from.firstChild; n !is null; n = n.next)
                if (n.type == NodeType.element && tryNode(n)) return true;
            return false;

        case Combinator.nextSibling:
            auto n = nextElement(from);
            return n !is null && tryNode(n);

        case Combinator.subsequentSibling:
            for (auto n = nextElement(from); n !is null; n = nextElement(n))
                if (tryNode(n)) return true;
            return false;
    }
}

bool matchCompound(ref const Compound comp, Node* node)
{
    foreach (ref s; comp.simples)
        if (!matchSimple(s, node)) return false;

    return true;
}

bool matchSimple(ref const Simple s, Node* node)
{
    auto e = node.as!Element;

    final switch (s.kind)
    {
        case SimpleKind.universal:
            return nsMatches(s.ns, node.ns);

        case SimpleKind.type:
            if (!nsMatches(s.ns, node.ns)) return false;
            auto id = node.document.findTagName(s.name);
            return id != Tag._undef && node.name == id;

        case SimpleKind.never:
            return false;

        case SimpleKind.lang:
            return matchLang(s.ranges, node);

        case SimpleKind.id:
            if (e.idAttr is null) return false;
            return equal(e.idAttr.value, s.name, isQuirks(node));

        case SimpleKind.class_:
            if (e.classAttr is null) return false;
            return containsWord(e.classAttr.value, s.name, isQuirks(node));

        case SimpleKind.attribute:
            return matchAttribute(s, node);

        case SimpleKind.pseudoClass:
            return matchPseudoClass(s.pseudo, node);

        case SimpleKind.not:
            return !matchList(*s.list, node);

        case SimpleKind.is_:
            return matchList(*s.list, node);

        case SimpleKind.has:
            foreach (ref c; s.list.items)
                if (matchForward(c, node, 0)) return true;
            return false;

        case SimpleKind.nthChild, SimpleKind.nthLastChild:
            bool forward = s.kind == SimpleKind.nthLastChild;
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

        case SimpleKind.nthOfType, SimpleKind.nthLastOfType:
            bool forward = s.kind == SimpleKind.nthLastOfType;
            size_t index = 0;

            for (auto n = node; n !is null; n = forward ? nextElement(n) : prevElement(n))
                if (n.name == node.name && n.ns == node.ns) index++;

            return nth(s.a, s.b, index);

        case SimpleKind.contains:
            for (auto n = node.firstChild; n !is null; n = n.next)
            {
                if (n.type != NodeType.text) continue;
                auto text = n.as!CharacterData.data;
                if (containsText(text, s.name, s.insensitive)) return true;
            }
            return false;
    }
}

bool matchAttribute(ref const Simple s, Node* node)
{
    auto id = node.document.findAttrName(s.name);
    if (id == 0) return false;

    Attribute* attr;
    for (attr = node.as!Element.firstAttr; attr !is null; attr = attr.next)
        if (attr.name == id && attrNsMatches(s.ns, attr.ns)) break;
    if (attr is null) return false;
    if (s.match == AttrMatch.exists) return true;

    const(char)[] v = attr.value;
    auto want = s.value;

    bool ci = s.attrCase == AttrCase.insensitive
        || (s.attrCase == AttrCase.auto_ && htmlCaseInsensitive(node, id));

    final switch (s.match)
    {
        case AttrMatch.exists: return true;
        case AttrMatch.equal: return equal(v, want, ci);
        case AttrMatch.includes: return containsWord(v, want, ci);
        case AttrMatch.dash:
            if (v.length == want.length) return equal(v, want, ci);
            return v.length > want.length && equal(v[0 .. want.length], want, ci) && v[want.length] == '-';
        case AttrMatch.prefix: return want.length && v.length >= want.length && equal(v[0 .. want.length], want, ci);
        case AttrMatch.suffix: return want.length && v.length >= want.length && equal(v[$ - want.length .. $], want, ci);
        case AttrMatch.substring: return want.length && containsText(v, want, ci);
    }
}

bool matchPseudoClass(PseudoClass p, Node* node)
{
    final switch (p)
    {
        case PseudoClass.anyLink, PseudoClass.link:
            return isHtml(node, Tag.a, Tag.area) && hasAttr(node, AttrName.href);

        case PseudoClass.blank:
            return node.isBlank;

        case PseudoClass.checked:
            if (isHtml(node, Tag.input))
            {
                auto t = attrById(node, AttrName.type);
                if (t is null || t.value is null) return false;
                auto v = value(t);
                return (equal(v, "checkbox", true) || equal(v, "radio", true)) && hasAttr(node, AttrName.checked);
            }
            return isHtml(node, Tag.option) && isSelectedOption(node);

        case PseudoClass.disabled: return canBeDisabled(node) && isDisabled(node);
        case PseudoClass.enabled: return canBeDisabled(node) && !isDisabled(node);

        case PseudoClass.empty:
            // Only comments inside
            for (auto n = nextInSubtree(node, node, true); n !is null; n = nextInSubtree(n, node, true))
                if (n.name != Tag._comment) return false;
            return true;

        case PseudoClass.firstChild: return prevElement(node) is null;
        case PseudoClass.lastChild: return nextElement(node) is null;
        case PseudoClass.onlyChild: return prevElement(node) is null && nextElement(node) is null;
        case PseudoClass.firstOfType: return firstOfType(node);
        case PseudoClass.lastOfType: return lastOfType(node);
        case PseudoClass.onlyOfType: return firstOfType(node) && lastOfType(node);

        case PseudoClass.optional: return isFormField(node) && !hasAttr(node, AttrName.required);
        case PseudoClass.required: return isFormField(node) && hasAttr(node, AttrName.required);

        case PseudoClass.placeholderShown:
            if (!hasAttr(node, AttrName.placeholder)) return false;
            if (isHtml(node, Tag.input))
            {
                auto v = attrByName(node, "value");
                return v is null || v.value.length == 0;
            }
            if (isHtml(node, Tag.textarea)) return node.firstChild is null;
            return false;

        case PseudoClass.readWrite: return isReadWrite(node);
        case PseudoClass.readOnly: return !isReadWrite(node);

        case PseudoClass.root:
            return node is rootElement(node);

        case PseudoClass.scope_:
            if (scopeNode is null || scopeNode.type != NodeType.element)
                return node is rootElement(node);
            return node is scopeNode;
    }
}

bool isHtml(Node* n, uint a, uint b = Tag._undef, uint c = Tag._undef)
{
    return n.ns == Ns.html && (n.name == a || (b != Tag._undef && n.name == b) || (c != Tag._undef && n.name == c));
}

bool isFormField(Node* n) { return isHtml(n, Tag.input, Tag.select, Tag.textarea); }

// Elements that support the disabled state
bool canBeDisabled(Node* n)
{
    return isHtml(n, Tag.button, Tag.input, Tag.select) || isHtml(n, Tag.textarea, Tag.optgroup, Tag.option)
        || isHtml(n, Tag.fieldset) || (n.name >= Tag._last && hasAttr(n, AttrName.disabled));
}

// HTML: "actually disabled"
bool isDisabled(Node* node)
{
    if (hasAttr(node, AttrName.disabled)) return true;

    if (isHtml(node, Tag.option))
    {
        auto p = node.parent;
        return p !is null && isHtml(p, Tag.optgroup) && hasAttr(p, AttrName.disabled);
    }

    if (isHtml(node, Tag.optgroup)) return false;

    // Inside a disabled fieldset, but not inside its first legend
    Node* child = node;
    for (auto p = node.parent; p !is null; child = p, p = p.parent)
    {
        if (!isHtml(p, Tag.fieldset) || !hasAttr(p, AttrName.disabled)) continue;

        Node* legend = null;
        for (auto c = p.firstChild; c !is null; c = c.next)
            if (c.type == NodeType.element && isHtml(c, Tag.legend)) { legend = c; break; }

        if (child !is legend) return true;
    }

    return false;
}

// HTML: option selectedness (the first option of a single select is selected by default)
bool isSelectedOption(Node* option)
{
    if (hasAttr(option, AttrName.selected)) return true;

    auto select = option.parent;
    if (select !is null && isHtml(select, Tag.optgroup)) select = select.parent;
    if (select is null || !isHtml(select, Tag.select)) return false;
    if (hasAttr(select, AttrName.multiple)) return false;

    auto size = attrById(select, AttrName.size);
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
    Node* first = null;
    for (auto n = nextInSubtree(select, select, true); n !is null; n = nextInSubtree(n, select, true))
    {
        if (!isHtml(n, Tag.option)) continue;
        if (hasAttr(n, AttrName.selected)) return false;
        if (first is null && !isDisabled(n)) first = n;
    }

    return first is option;
}

// HTML: inputs and textareas that can be edited, and contenteditable elements
bool isReadWrite(Node* n)
{
    if (isHtml(n, Tag.input))
    {
        if (hasAttr(n, AttrName.readonly) || isDisabled(n)) return false;

        auto t = attrById(n, AttrName.type);
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

    if (isHtml(n, Tag.textarea)) return !hasAttr(n, AttrName.readonly) && !isDisabled(n);

    // contenteditable is inherited
    for (auto p = n; p !is null && p.type == NodeType.element; p = p.parent)
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
bool matchLang(const(const(char)[])[] ranges, Node* node)
{
    const(char)[] lang;
    bool found = false;

    for (auto p = node; p !is null && p.type == NodeType.element; p = p.parent)
    {
        auto a = attrById(p, AttrName.lang);
        if (a is null) continue;
        lang = a.value is null ? "" : value(a);
        found = true;
        break;
    }

    if (!found) return false;

    foreach (range; ranges)
    {
        const(char)[] r = range;
        if (r == "*") { if (lang.length) return true; continue; }
        if (r.length > 2 && r[0 .. 2] == "*-") r = r[2 .. $];

        if (lang.length == r.length && equal(lang, r, true)) return true;
        if (lang.length > r.length && equal(lang[0 .. r.length], r, true) && lang[r.length] == '-') return true;
    }

    return false;
}

bool nsMatches(NsMatch want, Ns ns)
{
    final switch (want)
    {
        case NsMatch.any: return true;
        case NsMatch.none: return ns == Ns.none;
        case NsMatch.html: return ns == Ns.html;
        case NsMatch.svg: return ns == Ns.svg;
        case NsMatch.math: return ns == Ns.math;
        case NsMatch.xlink: return ns == Ns.xlink;
        case NsMatch.xml: return ns == Ns.xml;
        case NsMatch.xmlns: return ns == Ns.xmlns;
    }
}

// Attributes of html, svg and mathml elements have no namespace
bool attrNsMatches(NsMatch want, Ns ns)
{
    if (want == NsMatch.none) return ns == Ns.none;
    return nsMatches(want, ns);
}

bool firstOfType(Node* n)
{
    for (auto p = prevElement(n); p !is null; p = prevElement(p))
        if (p.name == n.name && p.ns == n.ns) return false;
    return true;
}

bool lastOfType(Node* n)
{
    for (auto p = nextElement(n); p !is null; p = nextElement(p))
        if (p.name == n.name && p.ns == n.ns) return false;
    return true;
}

// Attribute values compared case-insensitively in html documents (as in lexbor and in the html spec)
bool htmlCaseInsensitive(Node* node, uint id)
{
    if (node.ns != Ns.html) return false;

    switch (id)
    {
        case AttrName.accept, AttrName.accept_charset, AttrName.align_, AttrName.alink, AttrName.axis,
             AttrName.bgcolor, AttrName.charset, AttrName.checked, AttrName.clear, AttrName.codetype,
             AttrName.color, AttrName.compact, AttrName.declare, AttrName.defer, AttrName.dir,
             AttrName.direction, AttrName.disabled, AttrName.enctype, AttrName.face, AttrName.frame,
             AttrName.hreflang, AttrName.http_equiv, AttrName.lang, AttrName.language, AttrName.link,
             AttrName.media, AttrName.method, AttrName.multiple, AttrName.nohref, AttrName.noresize,
             AttrName.noshade, AttrName.nowrap, AttrName.readonly, AttrName.rel, AttrName.rev,
             AttrName.rules, AttrName.scope_, AttrName.scrolling, AttrName.selected, AttrName.shape,
             AttrName.target, AttrName.text, AttrName.type, AttrName.valign, AttrName.valuetype,
             AttrName.vlink:
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

Node* prevElement(Node* n)
{
    for (n = n.prev; n !is null; n = n.prev)
        if (n.type == NodeType.element) return n;
    return null;
}

Node* nextElement(Node* n)
{
    for (n = n.next; n !is null; n = n.next)
        if (n.type == NodeType.element) return n;
    return null;
}

// Preorder walk inside `root` (excluded)
Node* nextInSubtree(Node* n, Node* root, bool deep)
{
    if (deep && n.firstChild !is null) return n.firstChild;

    while (n !is root && n.next is null) n = n.parent;
    return n is root ? null : n.next;
}

Node* rootElement(Node* n)
{
    auto e = n.document.documentElement;
    return e is null ? null : &e.node;
}

bool isQuirks(Node* n) { return n.document.compatMode == CompatMode.quirks; }

Attribute* attrById(Node* n, uint id)
{
    for (auto a = n.as!Element.firstAttr; a !is null; a = a.next)
        if (a.name == id) return a;
    return null;
}

bool hasAttr(Node* n, uint id) { return attrById(n, id) !is null; }

Attribute* attrByName(Node* n, const(char)[] name)
{
    auto id = n.document.findAttrName(name);
    return id == 0 ? null : attrById(n, id);
}

const(char)[] value(Attribute* a) { return a.value; }

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
