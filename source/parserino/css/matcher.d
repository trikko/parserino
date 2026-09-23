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

@nogc nothrow:

alias Node = lxb_dom_node_t;

/// Does the element match any selector of the list?
bool matches(const(SelectorList)* list, Node* node)
{
    if (node.type != LXB_DOM_NODE_TYPE_ELEMENT) return false;
    return matchList(*list, node);
}

private:

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
            return true;

        case SimpleKind.type:
            auto id = lxb_tag_id_by_name(node.owner_document.tags, cast(const(ubyte)*) s.name.ptr, s.name.length);
            return id != LXB_TAG__UNDEF && node.local_name == id;

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
                for (auto n = node; n !is null; n = forward ? n.next : n.prev)
                    if (n.local_name != LXB_TAG__TEXT && n.local_name != LXB_TAG__EM_COMMENT) index++;
            }

            return nth(s.a, s.b, index);

        case SimpleKind.nthOfType, SimpleKind.nthLastOfType:
            bool forward = s.kind == SimpleKind.nthLastOfType;
            size_t index = 0;

            for (auto n = node; n !is null; n = forward ? n.next : n.prev)
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

    auto attr = attrById(node, data.attr_id);
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
        case PseudoClass.active: return hasAttr(node, LXB_DOM_ATTR_ACTIVE);
        case PseudoClass.focus: return hasAttr(node, LXB_DOM_ATTR_FOCUS);
        case PseudoClass.hover: return hasAttr(node, LXB_DOM_ATTR_HOVER);

        case PseudoClass.anyLink:
            return (node.local_name == LXB_TAG_A || node.local_name == LXB_TAG_AREA || node.local_name == LXB_TAG_MAP)
                && hasAttr(node, LXB_DOM_ATTR_HREF);

        case PseudoClass.link:
            return (node.local_name == LXB_TAG_A || node.local_name == LXB_TAG_AREA || node.local_name == LXB_TAG_LINK)
                && hasAttr(node, LXB_DOM_ATTR_HREF);

        case PseudoClass.blank:
            return lxb_dom_node_is_empty(node);

        case PseudoClass.checked:
            if (node.local_name == LXB_TAG_INPUT)
            {
                auto t = attrById(node, LXB_DOM_ATTR_TYPE);
                if (t is null || t.value is null) return false;
                auto v = value(t);
                if (!equal(v, "checkbox", true) && !equal(v, "radio", true)) return false;
                return hasAttr(node, LXB_DOM_ATTR_CHECKED);
            }
            if (node.local_name == LXB_TAG_OPTION) return hasAttr(node, LXB_DOM_ATTR_SELECTED);
            if (node.local_name >= LXB_TAG__LAST_ENTRY) return hasAttr(node, LXB_DOM_ATTR_CHECKED);
            return false;

        case PseudoClass.disabled: return isDisabled(node);
        case PseudoClass.enabled: return !isDisabled(node);

        case PseudoClass.empty:
            // Only comments inside
            for (auto n = nextInSubtree(node, node, true); n !is null; n = nextInSubtree(n, node, true))
                if (n.local_name != LXB_TAG__EM_COMMENT) return false;
            return true;

        case PseudoClass.firstChild: return firstChild(node);
        case PseudoClass.lastChild: return lastChild(node);
        case PseudoClass.onlyChild: return firstChild(node) && lastChild(node);
        case PseudoClass.firstOfType: return firstOfType(node);
        case PseudoClass.lastOfType: return lastOfType(node);
        case PseudoClass.onlyOfType: return firstOfType(node) && lastOfType(node);

        case PseudoClass.optional: return isFormField(node) && !hasAttr(node, LXB_DOM_ATTR_REQUIRED);
        case PseudoClass.required: return isFormField(node) && hasAttr(node, LXB_DOM_ATTR_REQUIRED);

        case PseudoClass.placeholderShown:
            return (node.local_name == LXB_TAG_INPUT || node.local_name == LXB_TAG_TEXTAREA)
                && hasAttr(node, LXB_DOM_ATTR_PLACEHOLDER);

        case PseudoClass.readWrite: return isReadWrite(node);
        case PseudoClass.readOnly: return !isReadWrite(node);

        case PseudoClass.root:
            return node is lxb_dom_document_root(node.owner_document);
    }
}

bool isFormField(Node* n)
{
    return n.local_name == LXB_TAG_INPUT || n.local_name == LXB_TAG_SELECT || n.local_name == LXB_TAG_TEXTAREA;
}

bool isReadWrite(Node* n)
{
    if (n.local_name != LXB_TAG_INPUT && n.local_name != LXB_TAG_TEXTAREA) return false;
    return !hasAttr(n, LXB_DOM_ATTR_READONLY) && !isDisabled(n);
}

bool isDisabled(Node* node)
{
    if (!hasAttr(node, LXB_DOM_ATTR_DISABLED)) return false;

    auto t = node.local_name;
    if (t == LXB_TAG_BUTTON || t == LXB_TAG_INPUT || t == LXB_TAG_SELECT || t == LXB_TAG_TEXTAREA || t >= LXB_TAG__LAST_ENTRY)
        return true;

    for (auto p = node.parent; p !is null; p = p.parent)
        if (p.local_name == LXB_TAG_FIELDSET && p.first_child !is null && p.first_child.local_name != LXB_TAG_LEGEND)
            return true;

    return false;
}

bool firstChild(Node* n)
{
    for (auto p = n.prev; p !is null; p = p.prev)
        if (p.local_name != LXB_TAG__TEXT && p.local_name != LXB_TAG__EM_COMMENT) return false;
    return true;
}

bool lastChild(Node* n)
{
    for (auto p = n.next; p !is null; p = p.next)
        if (p.local_name != LXB_TAG__TEXT && p.local_name != LXB_TAG__EM_COMMENT) return false;
    return true;
}

bool firstOfType(Node* n)
{
    for (auto p = n.prev; p !is null; p = p.prev)
        if (p.local_name == n.local_name && p.ns == n.ns) return false;
    return true;
}

bool lastOfType(Node* n)
{
    for (auto p = n.next; p !is null; p = p.next)
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
