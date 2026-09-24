/++
 Matching of CSS selectors against the DOM.

 Complex selectors are matched right to left, with backtracking on the
 descendant and subsequent-sibling combinators. `:has()` is matched forward.
+/
module parserino.css.matcher;

import parserino.css.selector;

import parserino.lexbor.dom.interfaces.node;
import parserino.lexbor.dom.interfaces.element;
import parserino.lexbor.dom.interfaces.attr;
import parserino.lexbor.dom.interfaces.attr_const;
import parserino.lexbor.dom.interfaces.document;
import parserino.lexbor.dom.interfaces.character_data;
import parserino.lexbor.tag.tag;
import parserino.lexbor.tag.const_;
import parserino.lexbor.ns.const_;
import parserino.lexbor.core.base : uintptr_t;

@nogc nothrow:

alias Node = lxb_dom_node_t;

/++ Does the element match any selector of the list?
 + `scope` is the element matched by `:scope` (the root of the query).
 +/
bool matches(const(SelectorList)* list, Node* node, Node* scopeElement = null)
{
    if (node.type != LXB_DOM_NODE_TYPE_ELEMENT) return false;
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
                if (p.type == LXB_DOM_NODE_TYPE_ELEMENT && matchComplex(c, p, i - 1)) return true;
            return false;

        case Combinator.child:
            auto p = node.parent;
            return p !is null && p.type == LXB_DOM_NODE_TYPE_ELEMENT && matchComplex(c, p, i - 1);

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
                if (n.type == LXB_DOM_NODE_TYPE_ELEMENT && tryNode(n)) return true;
            return false;

        case Combinator.child:
            for (auto n = from.first_child; n !is null; n = n.next)
                if (n.type == LXB_DOM_NODE_TYPE_ELEMENT && tryNode(n)) return true;
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
    auto e = cast(lxb_dom_element_t*) node;

    final switch (s.kind)
    {
        case SimpleKind.universal:
            return nsMatches(s.ns, node.ns);

        case SimpleKind.type:
            if (!nsMatches(s.ns, node.ns)) return false;
            auto id = lxb_tag_id_by_name(node.owner_document.tags, cast(const(ubyte)*) s.name.ptr, s.name.length);
            return id != LXB_TAG__UNDEF && node.local_name == id;

        case SimpleKind.never:
            return false;

        case SimpleKind.lang:
            return matchLang(s.ranges, node);

        case SimpleKind.id:
            if (e.attr_id is null || e.attr_id.value is null) return false;
            return equal(value(e.attr_id), s.name, isQuirks(node));

        case SimpleKind.class_:
            if (e.attr_class is null || e.attr_class.value is null) return false;
            return containsWord(value(e.attr_class), s.name, isQuirks(node));

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
                if (n.local_name == node.local_name && n.ns == node.ns) index++;

            return nth(s.a, s.b, index);

        case SimpleKind.contains:
            for (auto n = node.first_child; n !is null; n = n.next)
            {
                if (n.type != LXB_DOM_NODE_TYPE_TEXT) continue;
                auto cd = cast(lxb_dom_character_data_t*) n;
                auto text = cast(const(char)[]) cd.data.data[0 .. cd.data.length];
                if (containsText(text, s.name, s.insensitive)) return true;
            }
            return false;
    }
}

bool matchAttribute(ref const Simple s, Node* node)
{
    auto data = lxb_dom_attr_data_by_local_name(node.owner_document.attrs, cast(const(ubyte)*) s.name.ptr, s.name.length);
    if (data is null) return false;

    lxb_dom_attr_t* attr;
    for (attr = (cast(lxb_dom_element_t*) node).first_attr; attr !is null; attr = attr.next)
        if (attr.node.local_name == data.attr_id && attrNsMatches(s.ns, attr.node.ns)) break;
    if (attr is null) return false;
    if (s.match == AttrMatch.exists) return true;

    const(char)[] v = attr.value is null ? "" : value(attr);
    auto want = s.value;

    bool ci = s.attrCase == AttrCase.insensitive
        || (s.attrCase == AttrCase.auto_ && htmlCaseInsensitive(node, data.attr_id));

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
            return isHtml(node, LXB_TAG_A, LXB_TAG_AREA) && hasAttr(node, LXB_DOM_ATTR_HREF);

        case PseudoClass.blank:
            return lxb_dom_node_is_empty(node);

        case PseudoClass.checked:
            if (isHtml(node, LXB_TAG_INPUT))
            {
                auto t = attrById(node, LXB_DOM_ATTR_TYPE);
                if (t is null || t.value is null) return false;
                auto v = value(t);
                return (equal(v, "checkbox", true) || equal(v, "radio", true)) && hasAttr(node, LXB_DOM_ATTR_CHECKED);
            }
            return isHtml(node, LXB_TAG_OPTION) && isSelectedOption(node);

        case PseudoClass.disabled: return canBeDisabled(node) && isDisabled(node);
        case PseudoClass.enabled: return canBeDisabled(node) && !isDisabled(node);

        case PseudoClass.empty:
            // Only comments inside
            for (auto n = nextInSubtree(node, node, true); n !is null; n = nextInSubtree(n, node, true))
                if (n.local_name != LXB_TAG__EM_COMMENT) return false;
            return true;

        case PseudoClass.firstChild: return prevElement(node) is null;
        case PseudoClass.lastChild: return nextElement(node) is null;
        case PseudoClass.onlyChild: return prevElement(node) is null && nextElement(node) is null;
        case PseudoClass.firstOfType: return firstOfType(node);
        case PseudoClass.lastOfType: return lastOfType(node);
        case PseudoClass.onlyOfType: return firstOfType(node) && lastOfType(node);

        case PseudoClass.optional: return isFormField(node) && !hasAttr(node, LXB_DOM_ATTR_REQUIRED);
        case PseudoClass.required: return isFormField(node) && hasAttr(node, LXB_DOM_ATTR_REQUIRED);

        case PseudoClass.placeholderShown:
            if (!hasAttr(node, LXB_DOM_ATTR_PLACEHOLDER)) return false;
            if (isHtml(node, LXB_TAG_INPUT))
            {
                auto v = attrByName(node, "value");
                return v is null || v.value is null || v.value.length == 0;
            }
            if (isHtml(node, LXB_TAG_TEXTAREA)) return node.first_child is null;
            return false;

        case PseudoClass.readWrite: return isReadWrite(node);
        case PseudoClass.readOnly: return !isReadWrite(node);

        case PseudoClass.root:
            return node is lxb_dom_document_root(node.owner_document);

        case PseudoClass.scope_:
            if (scopeNode is null || scopeNode.type != LXB_DOM_NODE_TYPE_ELEMENT)
                return node is lxb_dom_document_root(node.owner_document);
            return node is scopeNode;
    }
}

bool isHtml(Node* n, lxb_tag_id_t a, lxb_tag_id_t b = LXB_TAG__UNDEF, lxb_tag_id_t c = LXB_TAG__UNDEF)
{
    return n.ns == LXB_NS_HTML && (n.local_name == a || (b != LXB_TAG__UNDEF && n.local_name == b) || (c != LXB_TAG__UNDEF && n.local_name == c));
}

bool isFormField(Node* n) { return isHtml(n, LXB_TAG_INPUT, LXB_TAG_SELECT, LXB_TAG_TEXTAREA); }

// Elements that support the disabled state
bool canBeDisabled(Node* n)
{
    return isHtml(n, LXB_TAG_BUTTON, LXB_TAG_INPUT, LXB_TAG_SELECT) || isHtml(n, LXB_TAG_TEXTAREA, LXB_TAG_OPTGROUP, LXB_TAG_OPTION)
        || isHtml(n, LXB_TAG_FIELDSET) || (n.local_name >= LXB_TAG__LAST_ENTRY && hasAttr(n, LXB_DOM_ATTR_DISABLED));
}

// HTML: "actually disabled"
bool isDisabled(Node* node)
{
    if (hasAttr(node, LXB_DOM_ATTR_DISABLED)) return true;

    if (isHtml(node, LXB_TAG_OPTION))
    {
        auto p = node.parent;
        return p !is null && isHtml(p, LXB_TAG_OPTGROUP) && hasAttr(p, LXB_DOM_ATTR_DISABLED);
    }

    if (isHtml(node, LXB_TAG_OPTGROUP)) return false;

    // Inside a disabled fieldset, but not inside its first legend
    Node* child = node;
    for (auto p = node.parent; p !is null; child = p, p = p.parent)
    {
        if (!isHtml(p, LXB_TAG_FIELDSET) || !hasAttr(p, LXB_DOM_ATTR_DISABLED)) continue;

        Node* legend = null;
        for (auto c = p.first_child; c !is null; c = c.next)
            if (c.type == LXB_DOM_NODE_TYPE_ELEMENT && isHtml(c, LXB_TAG_LEGEND)) { legend = c; break; }

        if (child !is legend) return true;
    }

    return false;
}

// HTML: option selectedness (the first option of a single select is selected by default)
bool isSelectedOption(Node* option)
{
    if (hasAttr(option, LXB_DOM_ATTR_SELECTED)) return true;

    auto select = option.parent;
    if (select !is null && isHtml(select, LXB_TAG_OPTGROUP)) select = select.parent;
    if (select is null || !isHtml(select, LXB_TAG_SELECT)) return false;
    if (hasAttr(select, LXB_DOM_ATTR_MULTIPLE)) return false;

    auto size = attrById(select, LXB_DOM_ATTR_SIZE);
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
        if (!isHtml(n, LXB_TAG_OPTION)) continue;
        if (hasAttr(n, LXB_DOM_ATTR_SELECTED)) return false;
        if (first is null && !isDisabled(n)) first = n;
    }

    return first is option;
}

// HTML: inputs and textareas that can be edited, and contenteditable elements
bool isReadWrite(Node* n)
{
    if (isHtml(n, LXB_TAG_INPUT))
    {
        if (hasAttr(n, LXB_DOM_ATTR_READONLY) || isDisabled(n)) return false;

        auto t = attrById(n, LXB_DOM_ATTR_TYPE);
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

    if (isHtml(n, LXB_TAG_TEXTAREA)) return !hasAttr(n, LXB_DOM_ATTR_READONLY) && !isDisabled(n);

    // contenteditable is inherited
    for (auto p = n; p !is null && p.type == LXB_DOM_NODE_TYPE_ELEMENT; p = p.parent)
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

    for (auto p = node; p !is null && p.type == LXB_DOM_NODE_TYPE_ELEMENT; p = p.parent)
    {
        auto a = attrById(p, LXB_DOM_ATTR_LANG);
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

bool nsMatches(NsMatch want, uintptr_t ns)
{
    final switch (want)
    {
        case NsMatch.any: return true;
        case NsMatch.none: return ns == LXB_NS__UNDEF;
        case NsMatch.html: return ns == LXB_NS_HTML;
        case NsMatch.svg: return ns == LXB_NS_SVG;
        case NsMatch.math: return ns == LXB_NS_MATH;
        case NsMatch.xlink: return ns == LXB_NS_XLINK;
        case NsMatch.xml: return ns == LXB_NS_XML;
        case NsMatch.xmlns: return ns == LXB_NS_XMLNS;
    }
}

// Attributes of html elements have no namespace (lexbor stores them as html)
bool attrNsMatches(NsMatch want, uintptr_t ns)
{
    if (want == NsMatch.none) return ns == LXB_NS__UNDEF || ns == LXB_NS_HTML;
    return nsMatches(want, ns);
}

bool firstOfType(Node* n)
{
    for (auto p = prevElement(n); p !is null; p = prevElement(p))
        if (p.local_name == n.local_name && p.ns == n.ns) return false;
    return true;
}

bool lastOfType(Node* n)
{
    for (auto p = nextElement(n); p !is null; p = nextElement(p))
        if (p.local_name == n.local_name && p.ns == n.ns) return false;
    return true;
}

// Attribute values compared case-insensitively in html documents (as in lexbor and in the html spec)
bool htmlCaseInsensitive(Node* node, lxb_dom_attr_id_t id)
{
    if (node.ns != LXB_NS_HTML || node.owner_document.type != LXB_DOM_DOCUMENT_DTYPE_HTML) return false;

    switch (id)
    {
        case LXB_DOM_ATTR_ACCEPT, LXB_DOM_ATTR_ACCEPT_CHARSET, LXB_DOM_ATTR_ALIGN, LXB_DOM_ATTR_ALINK, LXB_DOM_ATTR_AXIS,
             LXB_DOM_ATTR_BGCOLOR, LXB_DOM_ATTR_CHARSET, LXB_DOM_ATTR_CHECKED, LXB_DOM_ATTR_CLEAR, LXB_DOM_ATTR_CODETYPE,
             LXB_DOM_ATTR_COLOR, LXB_DOM_ATTR_COMPACT, LXB_DOM_ATTR_DECLARE, LXB_DOM_ATTR_DEFER, LXB_DOM_ATTR_DIR,
             LXB_DOM_ATTR_DIRECTION, LXB_DOM_ATTR_DISABLED, LXB_DOM_ATTR_ENCTYPE, LXB_DOM_ATTR_FACE, LXB_DOM_ATTR_FRAME,
             LXB_DOM_ATTR_HREFLANG, LXB_DOM_ATTR_HTTP_EQUIV, LXB_DOM_ATTR_LANG, LXB_DOM_ATTR_LANGUAGE, LXB_DOM_ATTR_LINK,
             LXB_DOM_ATTR_MEDIA, LXB_DOM_ATTR_METHOD, LXB_DOM_ATTR_MULTIPLE, LXB_DOM_ATTR_NOHREF, LXB_DOM_ATTR_NORESIZE,
             LXB_DOM_ATTR_NOSHADE, LXB_DOM_ATTR_NOWRAP, LXB_DOM_ATTR_READONLY, LXB_DOM_ATTR_REL, LXB_DOM_ATTR_REV,
             LXB_DOM_ATTR_RULES, LXB_DOM_ATTR_SCOPE, LXB_DOM_ATTR_SCROLLING, LXB_DOM_ATTR_SELECTED, LXB_DOM_ATTR_SHAPE,
             LXB_DOM_ATTR_TARGET, LXB_DOM_ATTR_TEXT, LXB_DOM_ATTR_TYPE, LXB_DOM_ATTR_VALIGN, LXB_DOM_ATTR_VALUETYPE,
             LXB_DOM_ATTR_VLINK:
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
        if (n.type == LXB_DOM_NODE_TYPE_ELEMENT) return n;
    return null;
}

Node* nextElement(Node* n)
{
    for (n = n.next; n !is null; n = n.next)
        if (n.type == LXB_DOM_NODE_TYPE_ELEMENT) return n;
    return null;
}

// Preorder walk inside `root` (excluded)
Node* nextInSubtree(Node* n, Node* root, bool deep)
{
    if (deep && n.first_child !is null) return n.first_child;

    while (n !is root && n.next is null) n = n.parent;
    return n is root ? null : n.next;
}

bool isQuirks(Node* n) { return n.owner_document.compat_mode == LXB_DOM_DOCUMENT_CMODE_QUIRKS; }

lxb_dom_attr_t* attrById(Node* n, lxb_dom_attr_id_t id)
{
    for (auto a = (cast(lxb_dom_element_t*) n).first_attr; a !is null; a = a.next)
        if (a.node.local_name == id) return a;
    return null;
}

bool hasAttr(Node* n, lxb_dom_attr_id_t id) { return attrById(n, id) !is null; }

lxb_dom_attr_t* attrByName(Node* n, const(char)[] name)
{
    auto data = lxb_dom_attr_data_by_local_name(n.owner_document.attrs, cast(const(ubyte)*) name.ptr, name.length);
    return data is null ? null : attrById(n, data.attr_id);
}

const(char)[] value(lxb_dom_attr_t* a) { return cast(const(char)[]) a.value.data[0 .. a.value.length]; }

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
