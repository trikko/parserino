/++
 HTML tree construction (HTML Living Standard, "Tree construction").

 Derived from lexbor (https://github.com/lexbor/lexbor), Apache-2.0: see NOTICE-lexbor.
+/
module parserino.html.treebuilder;

import parserino.arena;
import parserino.names;
import parserino.dom;
import parserino.html.tokenizer;

@nogc nothrow pure:

enum Mode : ubyte
{
    initial, beforeHtml, beforeHead, inHead, inHeadNoscript, afterHead, inBody, text,
    inTable, inTableText, inCaption, inColumnGroup, inTableBody, inRow, inCell, inTemplate,
    afterBody, inFrameset, afterFrameset, afterAfterBody, afterAfterFrameset,
}

// Element flags
enum : ubyte
{
    flagSelected = 1,           // option selectedness
    flagContentDisabled = 2,    // selectedcontent not in a select
}

struct TreeBuilder
{
@nogc nothrow pure:
    @disable this(this);

    Document* doc;
    Tokenizer* tokenizer;

    /// The stack of open elements and the list of active formatting elements (null = marker)
    Buffer!(Node*) openElements;
    Buffer!(Node*) activeFormatting;

    bool framesetOk = true;
    Element* head;
    Element* body;
    CompatMode compatMode;

    /// Fragment parsing: the context element and the root of the result
    Node* context;
    Element* fragmentRoot;

    /// Out of memory
    bool failed;

    /// Start parsing a document
    void beginDocument(Document* d, Tokenizer* t)
    {
        doc = d;
        tokenizer = t;
        mode = Mode.initial;
        compatMode = CompatMode.noQuirks;
    }

    /// Start parsing a fragment in the context of `contextElement` (an element of `d`)
    bool beginFragment(Document* d, Tokenizer* t, Element* contextElement)
    {
        doc = d;
        tokenizer = t;
        compatMode = d.compatMode;
        context = &contextElement.node;

        auto tag = context.name;
        if (context.ns == Ns.html)
        {
            switch (tag)
            {
                case Tag.title, Tag.textarea: t.switchTo(State.rcdata); break;
                case Tag.style, Tag.xmp, Tag.iframe, Tag.noembed, Tag.noframes: t.switchTo(State.rawtext); break;
                case Tag.script: t.switchTo(State.scriptData); break;
                case Tag.noscript: if (d.scripting) t.switchTo(State.rawtext); break;
                case Tag.plaintext: t.switchTo(State.plaintext); break;
                default: break;
            }
        }

        fragmentRoot = d.createElement(Tag.html, Ns.html);
        if (fragmentRoot is null) return false;
        push(&fragmentRoot.node);

        if (context.isHtml(Tag.template_)) templateModes.put(Mode.inTemplate);

        resetInsertionMode();

        // The form element pointer: the nearest form ancestor of the context
        for (auto n = context; n !is null; n = n.parent)
            if (n.isHtml(Tag.form)) { form = n.as!Element; break; }

        return true;
    }

    /// Process a token (the tokenizer calls it)
    bool process(ref Token t)
    {
        if (failed) return false;

        if (skipNewline)
        {
            skipNewline = false;
            if (t.type == TokenType.text && t.data.length && t.data[0] == '\n')
            {
                t.data = t.data[1 .. $];
                if (t.data.length == 0) return true;
            }
        }

        while (!failed && !dispatch(t)) {}
        return !failed;
    }

    /// The end of the input: pop everything
    void finish()
    {
        while (openElements.length) pop();
    }

    /// The sink for the tokenizer
    TokenSink sink() return
    {
        TokenSink s;
        s.context = &this;
        s.process = &processCallback;
        s.inForeignContent = &foreignCallback;
        return s;
    }

    ~this() {}

    private:

    Mode mode, originalMode;
    Buffer!Mode templateModes;
    Element* form;
    bool fosterParenting;
    bool skipNewline;

    // Pending characters in "in table text"
    Buffer!char pendingText;
    bool pendingNonSpace;

    // Attribute adjustments for foreign elements
    enum Adjust : ubyte { none, svg, math }
    Adjust adjust;

    static bool processCallback(void* ctx, ref Token t) { return (cast(TreeBuilder*) ctx).process(t); }

    static bool foreignCallback(void* ctx)
    {
        auto tb = cast(TreeBuilder*) ctx;
        auto n = tb.adjustedCurrent();
        return n !is null && n.ns != Ns.html;
    }

    // ------------------------------------------------------------ stack of open elements

    Node* current() { return openElements.length ? openElements[openElements.length - 1] : null; }

    Node* adjustedCurrent()
    {
        if (context !is null && openElements.length == 1) return context;
        return current();
    }

    void push(Node* n) { openElements.put(n); }

    Node* pop()
    {
        if (openElements.length == 0) return null;
        auto n = openElements[openElements.length - 1];
        openElements.length--;
        popped(n);
        return n;
    }

    // Pop up to the html element `tag` (included)
    void popUntil(uint tag)
    {
        while (openElements.length)
            if (pop().isHtml(tag)) return;
    }

    // Pop up to `node` (included)
    void popUntilNode(Node* node)
    {
        while (openElements.length)
            if (pop() is node) return;
    }

    void popUntilHeading()
    {
        while (openElements.length)
        {
            auto n = pop();
            if (n.ns == Ns.html && isHeading(n.name)) return;
        }
    }

    void popUntilCell()
    {
        while (openElements.length)
        {
            auto n = pop();
            if (n.isHtml(Tag.td) || n.isHtml(Tag.th)) return;
        }
    }

    void removeFromStack(Node* n)
    {
        foreach_reverse (i; 0 .. openElements.length)
        {
            if (openElements[i] is n)
            {
                foreach (j; i .. openElements.length - 1) openElements[j] = openElements[j + 1];
                openElements.length--;
                return;
            }
        }
    }

    bool stackIndex(Node* n, out size_t idx)
    {
        foreach_reverse (i; 0 .. openElements.length)
            if (openElements[i] is n) { idx = i; return true; }
        return false;
    }

    bool inStack(Node* n) { size_t i; return stackIndex(n, i); }

    // The last html element `tag` in the stack
    Node* findInStack(uint tag, out size_t idx)
    {
        foreach_reverse (i; 0 .. openElements.length)
            if (openElements[i].isHtml(tag)) { idx = i; return openElements[i]; }
        return null;
    }

    Node* findInStack(uint tag) { size_t i; return findInStack(tag, i); }

    // An element popped from the stack: <option> updates <selectedcontent>
    void popped(Node* n)
    {
        if (n.isHtml(Tag.option)) maybeCloneToSelectedContent(n.as!Element);
    }

    static bool isHeading(uint tag) pure
    {
        return tag == Tag.h1 || tag == Tag.h2 || tag == Tag.h3 || tag == Tag.h4 || tag == Tag.h5 || tag == Tag.h6;
    }

    static bool hasCategory(const(Node)* n, ubyte cat) pure
    {
        if (n.name >= Tag._last) return (Category.ordinary & cat) != 0;
        return (tagCategories[n.name][n.ns] & cat) != 0;
    }

    // "has an element in scope"
    Node* inScope(uint tag, ubyte scope_)
    {
        foreach_reverse (i; 0 .. openElements.length)
        {
            auto n = openElements[i];
            if (n.isHtml(tag)) return n;
            if (hasCategory(n, scope_)) return null;
        }
        return null;
    }

    Node* inScopeNode(Node* target, ubyte scope_)
    {
        foreach_reverse (i; 0 .. openElements.length)
        {
            auto n = openElements[i];
            if (n is target) return n;
            if (hasCategory(n, scope_)) return null;
        }
        return null;
    }

    // In scope, any of the html tags accepted by `pred`
    Node* inScopeAny(alias pred)(ubyte scope_)
    {
        foreach_reverse (i; 0 .. openElements.length)
        {
            auto n = openElements[i];
            if (n.type == NodeType.element && n.ns == Ns.html && pred(n.name)) return n;
            if (hasCategory(n, scope_)) return null;
        }
        return null;
    }

    static bool isTableSection(uint t) pure { return t == Tag.tbody || t == Tag.thead || t == Tag.tfoot; }
    static bool isCell(uint t) pure { return t == Tag.td || t == Tag.th; }
    static bool isTable(uint t) pure { return t == Tag.table; }
    static bool isRow(uint t) pure { return t == Tag.tr; }

    Node* headingInScope() { return inScopeAny!isHeading(Category.scope_); }
    Node* tableSectionInScope() { return inScopeAny!isTableSection(Category.scopeTable); }
    Node* cellInScope() { return inScopeAny!isCell(Category.scopeTable); }

    static bool impliedEndTag(uint tag) pure
    {
        switch (tag)
        {
            case Tag.dd, Tag.dt, Tag.li, Tag.optgroup, Tag.option, Tag.p, Tag.rb, Tag.rp, Tag.rt, Tag.rtc: return true;
            default: return false;
        }
    }

    void generateImpliedEndTags(uint except = Tag._undef)
    {
        while (openElements.length)
        {
            auto n = current();
            if (n.ns != Ns.html || !impliedEndTag(n.name) || n.name == except) return;
            pop();
        }
    }

    void generateImpliedEndTagsThoroughly()
    {
        while (openElements.length)
        {
            auto n = current();
            if (n.ns != Ns.html) return;
            switch (n.name)
            {
                case Tag.caption, Tag.colgroup, Tag.dd, Tag.dt, Tag.li, Tag.optgroup, Tag.option, Tag.p, Tag.rb, Tag.rp,
                     Tag.rt, Tag.rtc, Tag.tbody, Tag.td, Tag.tfoot, Tag.th, Tag.thead, Tag.tr:
                    pop();
                    break;
                default:
                    return;
            }
        }
    }

    void closePElement()
    {
        generateImpliedEndTags(Tag.p);
        popUntil(Tag.p);
    }

    void closePIfInButtonScope()
    {
        if (inScope(Tag.p, Category.scopeButton) !is null) closePElement();
    }

    void clearStackBackTo(alias pred)()
    {
        while (openElements.length)
        {
            auto n = current();
            if (n.ns == Ns.html && (pred(n.name) || n.name == Tag.template_ || n.name == Tag.html)) return;
            pop();
        }
    }

    void clearToTableContext() { clearStackBackTo!isTable(); }
    void clearToTableBodyContext() { clearStackBackTo!isTableSection(); }
    void clearToTableRowContext() { clearStackBackTo!isRow(); }

    void resetInsertionMode()
    {
        foreach_reverse (i; 0 .. openElements.length)
        {
            auto node = openElements[i];
            bool last = i == 0;
            if (last && context !is null) node = context;

            if (node.ns != Ns.html)
            {
                if (last) { mode = Mode.inBody; return; }
                continue;
            }

            switch (node.name)
            {
                case Tag.td, Tag.th: if (!last) { mode = Mode.inCell; return; } break;
                case Tag.tr: mode = Mode.inRow; return;
                case Tag.tbody, Tag.thead, Tag.tfoot: mode = Mode.inTableBody; return;
                case Tag.caption: mode = Mode.inCaption; return;
                case Tag.colgroup: mode = Mode.inColumnGroup; return;
                case Tag.table: mode = Mode.inTable; return;
                case Tag.template_: mode = templateModes.length ? templateModes[templateModes.length - 1] : Mode.inBody; return;
                case Tag.head: if (!last) { mode = Mode.inHead; return; } break;
                case Tag.body: mode = Mode.inBody; return;
                case Tag.frameset: mode = Mode.inFrameset; return;
                case Tag.html: mode = head is null ? Mode.beforeHead : Mode.afterHead; return;
                default: break;
            }

            if (last) { mode = Mode.inBody; return; }
        }
    }

    // ------------------------------------------------------------ active formatting elements

    void pushMarker() { activeFormatting.put(cast(Node*) null); }

    void clearToLastMarker()
    {
        while (activeFormatting.length)
        {
            activeFormatting.length--;
            if (activeFormatting[activeFormatting.length] is null) return;
        }
    }

    bool afeIndex(Node* n, out size_t idx)
    {
        foreach_reverse (i; 0 .. activeFormatting.length)
            if (activeFormatting[i] is n) { idx = i; return true; }
        return false;
    }

    void removeFromAfe(Node* n)
    {
        size_t i;
        if (afeIndex(n, i)) removeAfeAt(i);
    }

    void removeAfeAt(size_t i)
    {
        foreach (j; i .. activeFormatting.length - 1) activeFormatting[j] = activeFormatting[j + 1];
        activeFormatting.length--;
    }

    void insertAfeAt(size_t i, Node* n)
    {
        activeFormatting.put(cast(Node*) null);
        foreach_reverse (j; i + 1 .. activeFormatting.length) activeFormatting[j] = activeFormatting[j - 1];
        activeFormatting[i] = n;
    }

    // The last element `tag` after the last marker
    Node* afeAfterLastMarker(uint tag)
    {
        foreach_reverse (i; 0 .. activeFormatting.length)
        {
            auto n = activeFormatting[i];
            if (n is null) return null;
            if (n.isHtml(tag)) return n;
        }
        return null;
    }

    // Push, keeping at most 3 equal elements after the last marker (Noah's Ark)
    void pushFormatting(Node* node)
    {
        size_t count = 0;
        size_t earliest = activeFormatting.length ? activeFormatting.length - 1 : 0;

        foreach_reverse (i; 0 .. activeFormatting.length)
        {
            auto n = activeFormatting[i];
            if (n is null) break;
            if (n.name == node.name && n.ns == node.ns && sameAttributes(n.as!Element, node.as!Element))
            {
                count++;
                earliest = i;
            }
        }

        if (count >= 3) removeAfeAt(earliest);
        activeFormatting.put(node);
    }

    static bool sameAttributes(Element* a, Element* b)
    {
        size_t na, nb;
        for (auto x = a.firstAttr; x !is null; x = x.next) na++;
        for (auto x = b.firstAttr; x !is null; x = x.next) nb++;
        if (na != nb) return false;

        for (auto x = a.firstAttr; x !is null; x = x.next)
        {
            bool found = false;
            for (auto y = b.firstAttr; y !is null; y = y.next)
                if (x.name == y.name && x.ns == y.ns && x.value == y.value) { found = true; break; }
            if (!found) return false;
        }
        return true;
    }

    void reconstructFormatting()
    {
        if (activeFormatting.length == 0) return;

        size_t i = activeFormatting.length - 1;
        auto last = activeFormatting[i];
        if (last is null || inStack(last)) return;

        while (i > 0)
        {
            i--;
            auto e = activeFormatting[i];
            if (e is null || inStack(e)) { i++; break; }
        }

        for (; i < activeFormatting.length; i++)
        {
            auto src = activeFormatting[i].as!Element;
            auto e = insertClone(src);
            if (e is null) return;
            activeFormatting[i] = &e.node;
        }
    }

    // ------------------------------------------------------------ insertion

    // The appropriate place for inserting a node: the parent, or the node to insert before
    Node* appropriatePlace(Node* overrideTarget, out bool before)
    {
        Node* target = overrideTarget !is null ? overrideTarget : current();
        Node* location;

        if (fosterParenting && target.ns == Ns.html
            && (target.name == Tag.table || target.name == Tag.tbody || target.name == Tag.tfoot
                || target.name == Tag.thead || target.name == Tag.tr))
        {
            size_t ti, tbi;
            auto lastTemplate = findInStack(Tag.template_, ti);
            auto lastTable = findInStack(Tag.table, tbi);

            if (lastTemplate !is null && (lastTable is null || ti > tbi))
                return &lastTemplate.as!Element.templateContent.node;

            if (lastTable is null) location = openElements[0];
            else if (lastTable.parent !is null) { location = lastTable; before = true; }
            else location = openElements[tbi - 1];
        }
        else location = target;

        if (location is null) return null;

        if (!before && location.isHtml(Tag.template_))
            location = &location.as!Element.templateContent.node;

        return location;
    }

    void insertAt(Node* pos, bool before, Node* node)
    {
        if (before) pos.insertBefore(node);
        else
        {
            pos.appendChild(node);
            insertionSteps(node);
        }
    }

    Element* createElementForToken(ref Token t, Ns ns)
    {
        auto e = doc.createElement(t.tag, ns);
        if (e is null) { failed = true; return null; }

        foreach (ref a; t.attributes)
        {
            auto attr = doc.createAttribute(a.name, a.value);
            if (attr is null) { failed = true; return null; }
            adjustAttribute(attr, a.name);
            e.appendAttribute(attr);
        }

        if (e.isHtml(Tag.option) && e.attribute(AttrName.selected) !is null) e.flags |= flagSelected;
        return e;
    }

    // A new element with the same tag and attributes (for the formatting elements)
    Element* cloneForFormatting(Element* src)
    {
        auto e = doc.createElement(src.name, Ns.html);
        if (e is null) { failed = true; return null; }

        for (auto a = src.firstAttr; a !is null; a = a.next)
        {
            auto na = doc.createAttribute(a.name, a.value, a.ns);
            if (na is null) { failed = true; return null; }
            na.qualifiedName = a.qualifiedName;
            e.appendAttribute(na);
        }
        return e;
    }

    Element* insertClone(Element* src)
    {
        bool before;
        auto pos = appropriatePlace(null, before);
        if (pos is null) return null;
        auto e = cloneForFormatting(src);
        if (e is null) return null;
        insertAt(pos, before, &e.node);
        push(&e.node);
        return e;
    }

    Element* insertElement(ref Token t, Ns ns = Ns.html, bool onlyPush = false)
    {
        bool before;
        auto pos = appropriatePlace(null, before);
        if (pos is null) return null;

        auto e = createElementForToken(t, ns);
        if (e is null) return null;

        if (!onlyPush) insertAt(pos, before, &e.node);
        push(&e.node);
        return e;
    }

    // An html element without attributes (implied by the parser)
    Element* insertImplied(uint tag)
    {
        Token t;
        t.type = TokenType.startTag;
        t.tag = tag;
        return insertElement(t);
    }

    Element* insertForeign(ref Token t, Ns ns)
    {
        adjust = ns == Ns.math ? Adjust.math : ns == Ns.svg ? Adjust.svg : Adjust.none;
        auto e = insertElement(t, ns);
        adjust = Adjust.none;
        return e;
    }

    void insertText(scope const(char)[] data)
    {
        if (data.length == 0) return;

        bool before;
        auto pos = appropriatePlace(null, before);
        if (pos is null || pos.type == NodeType.document) return;

        Node* sibling = before ? pos.prev : pos.lastChild;
        if (sibling !is null && sibling.type == NodeType.text)
        {
            if (!sibling.as!CharacterData.appendData(data)) failed = true;
            return;
        }

        auto t = doc.createText(data);
        if (t is null) { failed = true; return; }
        insertAt(pos, before, &t.node);
    }

    // A comment as last child of `parent`, or at the appropriate place
    void insertComment(ref Token t, Node* parent = null)
    {
        bool before;
        Node* pos = parent !is null ? parent : appropriatePlace(null, before);
        if (pos is null) return;

        auto c = doc.createComment(t.data);
        if (c is null) { failed = true; return; }
        insertAt(pos, before, &c.node);
    }

    void insertProcessingInstruction(ref Token t, Node* overrideTarget = null)
    {
        bool before;
        auto pos = appropriatePlace(overrideTarget, before);
        if (pos is null) return;

        auto pi = doc.createProcessingInstruction(t.target, t.data);
        if (pi is null) { failed = true; return; }
        insertAt(pos, before, &pi.node);
    }

    void genericText(ref Token t, State state)
    {
        if (insertElement(t) is null) return;
        tokenizer.switchTo(state);
        originalMode = mode;
        mode = Mode.text;
    }

    void setHead(Element* e) { head = e; if (context is null) doc.head = e; }
    void setBody(Element* e) { body = e; if (context is null) doc.body = e; }

    // ------------------------------------------------------------ foreign attributes

    void adjustAttribute(Attribute* a, scope const(char)[] name)
    {
        final switch (adjust)
        {
            case Adjust.none: return;
            case Adjust.math:
                if (name == "definitionurl") a.qualifiedName = "definitionURL";
                break;
            case Adjust.svg:
                foreach (ref m; svgAttributes)
                    if (m[0] == name) { a.qualifiedName = m[1]; break; }
                break;
        }

        foreach (ref f; foreignAttributes)
        {
            if (f.name != name) continue;
            if (f.prefix.length)
            {
                a.qualifiedName = f.name;
                a.name = doc.attrId(f.local);
                if (a.name == 0) failed = true;
            }
            a.ns = f.ns;
            return;
        }
    }

    // ------------------------------------------------------------ select, option, selectedcontent

    void insertionSteps(Node* n)
    {
        if (n.type != NodeType.element || n.ns != Ns.html) return;

        if (n.name == Tag.option)
        {
            if (auto sel = nearestSelect(n)) selectednessSetting(sel);
        }
        else if (n.name == Tag.select) selectednessSetting(n.as!Element);
        else if (n.name == Tag.selectedcontent)
        {
            auto e = n.as!Element;
            if (n.parent is null || !n.parent.isHtml(Tag.select)) { e.flags |= flagContentDisabled; return; }
            e.flags &= ~flagContentDisabled;
            selectednessSetting(n.parent.as!Element);
        }
    }

    static Element* nearestSelect(Node* option)
    {
        Node* optgroup = null;
        for (auto n = option.parent; n !is null; n = n.parent)
        {
            if (n.ns != Ns.html) continue;
            switch (n.name)
            {
                case Tag.datalist, Tag.hr, Tag.option: return null;
                case Tag.optgroup:
                    if (optgroup !is null) return null;
                    optgroup = n;
                    break;
                case Tag.select: return n.as!Element;
                default: break;
            }
        }
        return null;
    }

    static bool optionDisabled(Node* option)
    {
        if (option.as!Element.attribute(AttrName.disabled) !is null) return true;
        for (auto n = option.parent; n !is null; n = n.parent)
        {
            if (n.ns != Ns.html) continue;
            switch (n.name)
            {
                case Tag.select, Tag.datalist, Tag.hr, Tag.option: return false;
                case Tag.optgroup: return n.as!Element.attribute(AttrName.disabled) !is null;
                default: break;
            }
        }
        return false;
    }

    // The options of a select: its option descendants, not inside nested select/datalist/option or optgroup/optgroup
    static void forEachOption(Element* select, scope void delegate(Element*) @nogc nothrow pure dg)
    {
        auto root = &select.node;
        for (auto n = root.firstChild; n !is null; )
        {
            bool descend = true;
            if (n.type == NodeType.element && n.ns == Ns.html)
            {
                switch (n.name)
                {
                    case Tag.option: dg(n.as!Element); descend = false; break;
                    case Tag.select, Tag.datalist, Tag.hr: descend = false; break;
                    case Tag.optgroup:
                        for (auto p = n.parent; p !is root; p = p.parent)
                            if (p.isHtml(Tag.optgroup)) { descend = false; break; }
                        break;
                    default: break;
                }
            }
            else if (n.type != NodeType.element) descend = false;

            n = descend && n.firstChild !is null ? n.firstChild : n.nextSkippingChildren(root);
        }
    }

    // HTML "selectedness setting algorithm"
    static void selectednessSetting(Element* select)
    {
        if (select.attribute(AttrName.multiple) !is null) return;

        size_t displaySize = 1;
        if (auto size = select.attribute(AttrName.size))
        {
            size_t v = 0;
            bool digits = false;
            foreach (c; size.value)
            {
                if (c == ' ' || c == '\t' || c == '\n' || c == '\f' || c == '\r') { if (digits) break; continue; }
                if (c < '0' || c > '9') break;
                digits = true;
                v = v * 10 + (c - '0');
                if (v > 1000) break;
            }
            if (digits) displaySize = v;
        }
        if (displaySize != 1) return;

        Element* first = null;
        Element* lastSelected = null;
        size_t selected = 0;

        forEachOption(select, (Element* o) {
            if (o.flags & flagSelected) { selected++; lastSelected = o; }
            if (first is null && !optionDisabled(&o.node)) first = o;
        });

        if (selected == 0) { if (first !is null) first.flags |= flagSelected; return; }
        if (selected >= 2)
            forEachOption(select, (Element* o) { if (o !is lastSelected) o.flags &= ~flagSelected; });
    }

    // An option popped from the stack: its content goes in the <selectedcontent> of its select
    void maybeCloneToSelectedContent(Element* option)
    {
        if (!(option.flags & flagSelected)) return;

        auto select = nearestSelect(&option.node);
        if (select is null || select.attribute(AttrName.multiple) !is null) return;

        Element* sc = null;
        for (auto n = select.node.firstChild; n !is null; n = n.nextInTree(&select.node))
            if (n.isHtml(Tag.selectedcontent)) { sc = n.as!Element; break; }

        if (sc is null || (sc.flags & flagContentDisabled)) return;

        while (sc.node.firstChild !is null) sc.node.firstChild.remove();
        for (auto c = option.node.firstChild; c !is null; c = c.next)
        {
            auto copy = doc.importNode(c, true);
            if (copy is null) { failed = true; return; }
            sc.node.appendChild(copy);
        }
    }

    // ------------------------------------------------------------ text helpers

    static bool isSpace(char c) pure { return c == ' ' || c == '\t' || c == '\n' || c == '\f' || c == '\r'; }

    // Split the leading whitespace of a text token
    static const(char)[] leadingSpace(ref Token t) pure
    {
        size_t i = 0;
        while (i < t.data.length && isSpace(t.data[i])) i++;
        auto ws = t.data[0 .. i];
        t.data = t.data[i .. $];
        return ws;
    }

    static bool allSpace(scope const(char)[] s) pure
    {
        foreach (c; s) if (!isSpace(c)) return false;
        return true;
    }

    // The text without U+0000 (in body) or with U+FFFD (in foreign content)
    const(char)[] cleanText(ref Token t, bool replace)
    {
        if (!t.hasNull) return t.data;

        scratch.clear();
        foreach (c; t.data)
        {
            if (c != '\0') scratch.put(c);
            else if (replace) foreach (r; "\xEF\xBF\xBD") scratch.put(r);
        }
        return scratch[];
    }

    Buffer!char scratch;

    // ------------------------------------------------------------ dispatcher

    bool isStart(ref Token t) { return t.type == TokenType.startTag; }
    bool isEnd(ref Token t) { return t.type == TokenType.endTag; }

    static bool mathTextIntegrationPoint(const(Node)* n) pure
    {
        return n.ns == Ns.math && (n.name == Tag.mi || n.name == Tag.mo || n.name == Tag.mn || n.name == Tag.ms || n.name == Tag.mtext);
    }

    static bool htmlIntegrationPoint(Node* n)
    {
        if (n.ns == Ns.math && n.name == Tag.annotation_xml)
        {
            auto a = n.as!Element.attribute("encoding");
            if (a is null) return false;
            return equalsCi(a.value, "text/html") || equalsCi(a.value, "application/xhtml+xml");
        }

        return n.ns == Ns.svg && (n.name == Tag.foreignobject || n.name == Tag.desc || n.name == Tag.title);
    }

    static bool equalsCi(scope const(char)[] a, string b) pure
    {
        if (a.length != b.length) return false;
        foreach (i, c; a) if ((c >= 'A' && c <= 'Z' ? cast(char) (c | 0x20) : c) != b[i]) return false;
        return true;
    }

    // "tree construction dispatcher". It returns false to reprocess the token.
    bool dispatch(ref Token t)
    {
        auto adjusted = adjustedCurrent();
        if (adjusted is null || adjusted.ns == Ns.html) return run(mode, t);

        if (mathTextIntegrationPoint(adjusted))
        {
            if (isStart(t) && t.tag != Tag.mglyph && t.tag != Tag.malignmark) return run(mode, t);
            if (t.type == TokenType.text) return run(mode, t);
        }

        if (adjusted.ns == Ns.math && adjusted.name == Tag.annotation_xml && isStart(t) && t.tag == Tag.svg)
            return run(mode, t);

        if (htmlIntegrationPoint(adjusted) && (isStart(t) || t.type == TokenType.text))
            return run(mode, t);

        if (t.type == TokenType.eof) return run(mode, t);

        return foreignContent(t);
    }

    bool run(Mode m, ref Token t)
    {
        final switch (m)
        {
            case Mode.initial: return initialMode(t);
            case Mode.beforeHtml: return beforeHtml(t);
            case Mode.beforeHead: return beforeHead(t);
            case Mode.inHead: return inHead(t);
            case Mode.inHeadNoscript: return inHeadNoscript(t);
            case Mode.afterHead: return afterHead(t);
            case Mode.inBody: return inBody(t);
            case Mode.text: return textMode(t);
            case Mode.inTable: return inTable(t);
            case Mode.inTableText: return inTableText(t);
            case Mode.inCaption: return inCaption(t);
            case Mode.inColumnGroup: return inColumnGroup(t);
            case Mode.inTableBody: return inTableBody(t);
            case Mode.inRow: return inRow(t);
            case Mode.inCell: return inCell(t);
            case Mode.inTemplate: return inTemplate(t);
            case Mode.afterBody: return afterBody(t);
            case Mode.inFrameset: return inFrameset(t);
            case Mode.afterFrameset: return afterFrameset(t);
            case Mode.afterAfterBody: return afterAfterBody(t);
            case Mode.afterAfterFrameset: return afterAfterFrameset(t);
        }
    }

    // ------------------------------------------------------------ initial

    bool initialMode(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.comment: insertComment(t, &doc.node); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t, &doc.node); return true;
            case TokenType.doctype:
                mode = Mode.beforeHtml;
                insertDoctype(t);
                return true;
            case TokenType.text:
                leadingSpace(t);
                if (t.data.length == 0) return true;
                goto default;
            default:
                compatMode = CompatMode.quirks;
                if (context is null) doc.compatMode = compatMode;
                mode = Mode.beforeHtml;
                return false;
        }
    }

    void insertDoctype(ref Token t)
    {
        auto d = doc.createDocumentType(t.name, t.publicId, t.systemId);
        if (d is null) { failed = true; return; }

        compatMode = doctypeMode(t);
        if (context is null)
        {
            doc.compatMode = compatMode;
            doc.doctype = d;
        }
        doc.node.appendChild(&d.node);
    }

    static CompatMode doctypeMode(ref Token t)
    {
        if (t.forceQuirks || t.name != "html") return CompatMode.quirks;

        auto pub = t.publicId;
        auto sys = t.systemId;

        if (t.hasPublicId)
        {
            foreach (s; quirksPublicIs) if (equalsCi(pub, s)) return CompatMode.quirks;
            foreach (s; quirksPublicStart) if (startsCi(pub, s)) return CompatMode.quirks;
        }

        if (t.hasSystemId && equalsCi(sys, "http://www.ibm.com/data/dtd/v11/ibmxhtml1-transitional.dtd")) return CompatMode.quirks;

        if (t.hasPublicId && !t.hasSystemId)
            foreach (s; quirksHtml401) if (startsCi(pub, s)) return CompatMode.quirks;

        if (t.hasPublicId)
        {
            foreach (s; limitedXhtml) if (startsCi(pub, s)) return CompatMode.limitedQuirks;
            if (t.hasSystemId) foreach (s; quirksHtml401) if (startsCi(pub, s)) return CompatMode.limitedQuirks;
        }

        return CompatMode.noQuirks;
    }

    static bool startsCi(scope const(char)[] a, string prefix) pure
    {
        return a.length >= prefix.length && equalsCi(a[0 .. prefix.length], prefix);
    }

    // ------------------------------------------------------------ before html

    bool beforeHtml(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.doctype: return true;
            case TokenType.comment: insertComment(t, &doc.node); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t, &doc.node); return true;
            case TokenType.text:
                leadingSpace(t);
                if (t.data.length == 0) return true;
                break;
            case TokenType.startTag:
                if (t.tag == Tag.html)
                {
                    auto e = createElementForToken(t, Ns.html);
                    if (e is null) return true;
                    insertHtml(e);
                    mode = Mode.beforeHead;
                    return true;
                }
                break;
            case TokenType.endTag:
                if (t.tag != Tag.head && t.tag != Tag.body && t.tag != Tag.html && t.tag != Tag.br) return true;
                break;
            default: break;
        }

        auto e = doc.createElement(Tag.html, Ns.html);
        if (e is null) { failed = true; return true; }
        insertHtml(e);
        mode = Mode.beforeHead;
        return false;
    }

    void insertHtml(Element* e)
    {
        push(&e.node);
        doc.node.appendChild(&e.node);
        insertionSteps(&e.node);
    }

    // ------------------------------------------------------------ before head

    bool beforeHead(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.comment: insertComment(t); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.doctype: return true;
            case TokenType.text:
                leadingSpace(t);
                if (t.data.length == 0) return true;
                break;
            case TokenType.startTag:
                if (t.tag == Tag.html) return inBody(t);
                if (t.tag == Tag.head)
                {
                    setHead(insertElement(t));
                    mode = Mode.inHead;
                    return true;
                }
                break;
            case TokenType.endTag:
                if (t.tag != Tag.head && t.tag != Tag.body && t.tag != Tag.html && t.tag != Tag.br) return true;
                break;
            default: break;
        }

        setHead(insertImplied(Tag.head));
        mode = Mode.inHead;
        return false;
    }

    // ------------------------------------------------------------ in head

    bool inHead(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.comment: insertComment(t); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.doctype: return true;

            case TokenType.text:
                insertText(leadingSpace(t));
                if (t.data.length == 0) return true;
                break;

            case TokenType.startTag:
                switch (t.tag)
                {
                    case Tag.html: return inBody(t);
                    case Tag.base, Tag.basefont, Tag.bgsound, Tag.link, Tag.meta:
                        if (insertElement(t)) pop();
                        return true;
                    case Tag.title: genericText(t, State.rcdata); return true;
                    case Tag.noscript:
                        if (doc.scripting) genericText(t, State.rawtext);
                        else { insertElement(t); mode = Mode.inHeadNoscript; }
                        return true;
                    case Tag.noframes, Tag.style: genericText(t, State.rawtext); return true;
                    case Tag.script:
                    {
                        bool before;
                        auto pos = appropriatePlace(null, before);
                        if (pos is null) return true;
                        auto e = createElementForToken(t, Ns.html);
                        if (e is null) return true;
                        push(&e.node);
                        insertAt(pos, before, &e.node);
                        tokenizer.switchTo(State.scriptData);
                        originalMode = mode;
                        mode = Mode.text;
                        return true;
                    }
                    case Tag.template_:
                        if (insertElement(t) is null) return true;
                        pushMarker();
                        framesetOk = false;
                        mode = Mode.inTemplate;
                        templateModes.put(Mode.inTemplate);
                        return true;
                    case Tag.head: return true;
                    default: break;
                }
                break;

            case TokenType.endTag:
                switch (t.tag)
                {
                    case Tag.head:
                        pop();
                        mode = Mode.afterHead;
                        return true;
                    case Tag.body, Tag.html, Tag.br: break;
                    case Tag.template_: templateEnd(); return true;
                    default: return true;
                }
                break;

            default: break;
        }

        pop();
        mode = Mode.afterHead;
        return false;
    }

    void templateEnd()
    {
        if (findInStack(Tag.template_) is null) return;
        generateImpliedEndTagsThoroughly();
        popUntil(Tag.template_);
        clearToLastMarker();
        if (templateModes.length) templateModes.length--;
        resetInsertionMode();
    }

    bool inHeadNoscript(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.doctype: return true;
            case TokenType.comment, TokenType.processingInstruction: return inHead(t);
            case TokenType.text:
                insertText(leadingSpace(t));
                if (t.data.length == 0) return true;
                break;
            case TokenType.startTag:
                switch (t.tag)
                {
                    case Tag.html: return inBody(t);
                    case Tag.basefont, Tag.bgsound, Tag.link, Tag.meta, Tag.noframes, Tag.style: return inHead(t);
                    case Tag.head, Tag.noscript: return true;
                    default: break;
                }
                break;
            case TokenType.endTag:
                if (t.tag == Tag.noscript) { pop(); mode = Mode.inHead; return true; }
                if (t.tag != Tag.br) return true;
                break;
            default: break;
        }

        pop();
        mode = Mode.inHead;
        return false;
    }

    // ------------------------------------------------------------ after head

    bool afterHead(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.comment: insertComment(t); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.doctype: return true;
            case TokenType.text:
                insertText(leadingSpace(t));
                if (t.data.length == 0) return true;
                break;
            case TokenType.startTag:
                switch (t.tag)
                {
                    case Tag.html: return inBody(t);
                    case Tag.body:
                        setBody(insertElement(t));
                        framesetOk = false;
                        mode = Mode.inBody;
                        return true;
                    case Tag.frameset:
                        insertElement(t);
                        mode = Mode.inFrameset;
                        return true;
                    case Tag.base, Tag.basefont, Tag.bgsound, Tag.link, Tag.meta, Tag.noframes, Tag.script,
                         Tag.style, Tag.template_, Tag.title:
                        if (head is null) { failed = true; return true; }
                        push(&head.node);
                        inHead(t);
                        removeFromStack(&head.node);
                        return true;
                    case Tag.head: return true;
                    default: break;
                }
                break;
            case TokenType.endTag:
                if (t.tag == Tag.template_) return inHead(t);
                if (t.tag != Tag.body && t.tag != Tag.html && t.tag != Tag.br) return true;
                break;
            default: break;
        }

        setBody(insertImplied(Tag.body));
        mode = Mode.inBody;
        return false;
    }

    // ------------------------------------------------------------ in body

    bool inBody(ref Token t)
    {
        final switch (t.type)
        {
            case TokenType.text:
            {
                auto data = cleanText(t, false);
                if (data.length) bodyText(data);
                return true;
            }
            case TokenType.comment: insertComment(t); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.doctype: return true;
            case TokenType.eof:
                if (templateModes.length) return inTemplate(t);
                return true;
            case TokenType.startTag: return inBodyStart(t);
            case TokenType.endTag: return inBodyEnd(t);
        }
    }

    void bodyText(scope const(char)[] data)
    {
        reconstructFormatting();
        if (framesetOk && !allSpace(data)) framesetOk = false;
        insertText(data);
    }

    bool inBodyStart(ref Token t)
    {
        switch (t.tag)
        {
            case Tag.html:
                if (findInStack(Tag.template_) !is null) return true;
                mergeAttributes(openElements[0].as!Element, t);
                return true;

            case Tag.base, Tag.basefont, Tag.bgsound, Tag.link, Tag.meta, Tag.noframes, Tag.script, Tag.style,
                 Tag.template_, Tag.title:
                return inHead(t);

            case Tag.body:
            {
                if (openElements.length < 2) return true;
                auto n = openElements[1];
                if (!n.isHtml(Tag.body) || findInStack(Tag.template_) !is null) return true;
                framesetOk = false;
                mergeAttributes(n.as!Element, t);
                return true;
            }

            case Tag.frameset:
            {
                if (openElements.length < 2) return true;
                auto n = openElements[1];
                if (!n.isHtml(Tag.body) || !framesetOk) return true;
                n.remove();
                while (openElements.length > 1) pop();
                insertElement(t);
                mode = Mode.inFrameset;
                return true;
            }

            case Tag.address, Tag.article, Tag.aside, Tag.blockquote, Tag.center, Tag.details, Tag.dialog, Tag.dir,
                 Tag.div, Tag.dl, Tag.fieldset, Tag.figcaption, Tag.figure, Tag.footer, Tag.header, Tag.hgroup,
                 Tag.main, Tag.menu, Tag.nav, Tag.ol, Tag.p, Tag.search, Tag.section, Tag.summary, Tag.ul:
                closePIfInButtonScope();
                insertElement(t);
                return true;

            case Tag.h1, Tag.h2, Tag.h3, Tag.h4, Tag.h5, Tag.h6:
            {
                closePIfInButtonScope();
                auto n = current();
                if (n.ns == Ns.html && isHeading(n.name)) pop();
                insertElement(t);
                return true;
            }

            case Tag.pre, Tag.listing:
                closePIfInButtonScope();
                insertElement(t);
                skipNewline = true;
                framesetOk = false;
                return true;

            case Tag.form:
            {
                auto tmpl = findInStack(Tag.template_);
                if (form !is null && tmpl is null) return true;
                closePIfInButtonScope();
                auto e = insertElement(t);
                if (tmpl is null) form = e;
                return true;
            }

            case Tag.li, Tag.dd, Tag.dt:
            {
                framesetOk = false;
                foreach_reverse (i; 0 .. openElements.length)
                {
                    auto n = openElements[i];
                    uint match = Tag._undef;
                    if (t.tag == Tag.li) { if (n.isHtml(Tag.li)) match = Tag.li; }
                    else if (n.isHtml(Tag.dd)) match = Tag.dd;
                    else if (n.isHtml(Tag.dt)) match = Tag.dt;

                    if (match != Tag._undef)
                    {
                        generateImpliedEndTags(match);
                        popUntil(match);
                        break;
                    }

                    if (hasCategory(n, Category.special) && !n.isHtml(Tag.address) && !n.isHtml(Tag.div) && !n.isHtml(Tag.p))
                        break;
                }
                closePIfInButtonScope();
                insertElement(t);
                return true;
            }

            case Tag.plaintext:
                closePIfInButtonScope();
                insertElement(t);
                tokenizer.switchTo(State.plaintext);
                return true;

            case Tag.button:
                if (inScope(Tag.button, Category.scope_) !is null)
                {
                    generateImpliedEndTags();
                    popUntil(Tag.button);
                }
                reconstructFormatting();
                insertElement(t);
                framesetOk = false;
                return true;

            case Tag.a:
            {
                if (auto n = afeAfterLastMarker(Tag.a))
                {
                    adoptionAgency(t);
                    removeFromAfe(n);
                    removeFromStack(n);
                }
                reconstructFormatting();
                if (auto e = insertElement(t)) pushFormatting(&e.node);
                return true;
            }

            case Tag.b, Tag.big, Tag.code, Tag.em, Tag.font, Tag.i, Tag.s, Tag.small, Tag.strike, Tag.strong, Tag.tt, Tag.u:
                reconstructFormatting();
                if (auto e = insertElement(t)) pushFormatting(&e.node);
                return true;

            case Tag.nobr:
                reconstructFormatting();
                if (inScope(Tag.nobr, Category.scope_) !is null)
                {
                    if (adoptionAgency(t)) anyOtherEndTag(t);
                    reconstructFormatting();
                }
                if (auto e = insertElement(t)) pushFormatting(&e.node);
                return true;

            case Tag.applet, Tag.marquee, Tag.object:
                reconstructFormatting();
                insertElement(t);
                pushMarker();
                framesetOk = false;
                return true;

            case Tag.table:
                if (compatMode != CompatMode.quirks) closePIfInButtonScope();
                insertElement(t);
                framesetOk = false;
                mode = Mode.inTable;
                return true;

            case Tag.area, Tag.br, Tag.embed, Tag.img, Tag.keygen, Tag.wbr:
                reconstructFormatting();
                if (insertElement(t)) pop();
                framesetOk = false;
                return true;

            case Tag.input:
            {
                if (context !is null && context.isHtml(Tag.select)) return true;
                if (auto sel = inScope(Tag.select, Category.scope_)) popUntilNode(sel);
                reconstructFormatting();
                auto e = insertElement(t);
                if (e is null) return true;
                pop();
                auto type = e.attribute(AttrName.type);
                if (type is null || type.value != "hidden") framesetOk = false;
                return true;
            }

            case Tag.param, Tag.source, Tag.track:
                if (insertElement(t)) pop();
                return true;

            case Tag.hr:
                closePIfInButtonScope();
                if (inScope(Tag.select, Category.scope_) !is null) generateImpliedEndTags();
                if (insertElement(t)) pop();
                framesetOk = false;
                return true;

            case Tag.image:
                t.tag = Tag.img;
                t.name = "img";
                return false;

            case Tag.textarea:
                insertElement(t);
                tokenizer.switchTo(State.rcdata);
                framesetOk = false;
                skipNewline = true;
                originalMode = mode;
                mode = Mode.text;
                return true;

            case Tag.xmp:
                closePIfInButtonScope();
                reconstructFormatting();
                framesetOk = false;
                genericText(t, State.rawtext);
                return true;

            case Tag.iframe:
                framesetOk = false;
                genericText(t, State.rawtext);
                return true;

            case Tag.noembed:
                genericText(t, State.rawtext);
                return true;

            case Tag.noscript:
                if (!doc.scripting) goto default;
                genericText(t, State.rawtext);
                return true;

            case Tag.select:
                if (context !is null && context.isHtml(Tag.select)) return true;
                if (auto sel = inScope(Tag.select, Category.scope_)) { popUntilNode(sel); return true; }
                reconstructFormatting();
                insertElement(t);
                framesetOk = false;
                return true;

            case Tag.option:
                if (inScope(Tag.select, Category.scope_) !is null) generateImpliedEndTags(Tag.optgroup);
                else if (current().isHtml(Tag.option)) pop();
                reconstructFormatting();
                insertElement(t);
                return true;

            case Tag.optgroup:
                if (inScope(Tag.select, Category.scope_) !is null) generateImpliedEndTags();
                else if (current().isHtml(Tag.option)) pop();
                reconstructFormatting();
                insertElement(t);
                return true;

            case Tag.rb, Tag.rtc:
                if (inScope(Tag.ruby, Category.scope_) !is null) generateImpliedEndTags();
                insertElement(t);
                return true;

            case Tag.rp, Tag.rt:
                if (inScope(Tag.ruby, Category.scope_) !is null) generateImpliedEndTags(Tag.rtc);
                insertElement(t);
                return true;

            case Tag.math, Tag.svg:
                reconstructFormatting();
                if (insertForeign(t, t.tag == Tag.math ? Ns.math : Ns.svg) && t.selfClosing) pop();
                return true;

            case Tag.caption, Tag.col, Tag.colgroup, Tag.frame, Tag.head, Tag.tbody, Tag.td, Tag.tfoot, Tag.th,
                 Tag.thead, Tag.tr:
                return true;

            default:
                reconstructFormatting();
                insertElement(t);
                return true;
        }
    }

    // Add the attributes that the element doesn't have (<html> and <body> seen again)
    void mergeAttributes(Element* e, ref Token t)
    {
        foreach (ref a; t.attributes)
        {
            auto id = doc.attrId(a.name);
            if (id == 0) { failed = true; return; }

            bool exists = false;
            for (auto x = e.firstAttr; x !is null; x = x.next)
                if (x.name == id && (x.ns == Ns.none || x.ns == e.ns)) { exists = true; break; }
            if (exists) continue;

            auto attr = doc.createAttribute(id, a.value);
            if (attr is null) { failed = true; return; }
            e.appendAttribute(attr);
        }
    }

    bool inBodyEnd(ref Token t)
    {
        switch (t.tag)
        {
            case Tag.template_: return inHead(t);

            case Tag.body:
                if (inScope(Tag.body, Category.scope_) is null) return true;
                mode = Mode.afterBody;
                return true;

            case Tag.html:
                if (inScope(Tag.body, Category.scope_) is null) return true;
                mode = Mode.afterBody;
                return false;

            case Tag.address, Tag.article, Tag.aside, Tag.blockquote, Tag.button, Tag.center, Tag.details, Tag.dialog,
                 Tag.dir, Tag.div, Tag.dl, Tag.fieldset, Tag.figcaption, Tag.figure, Tag.footer, Tag.header, Tag.hgroup,
                 Tag.listing, Tag.main, Tag.menu, Tag.nav, Tag.ol, Tag.pre, Tag.search, Tag.section, Tag.select,
                 Tag.summary, Tag.ul:
                if (inScope(t.tag, Category.scope_) is null) return true;
                generateImpliedEndTags();
                popUntil(t.tag);
                return true;

            case Tag.form:
            {
                if (findInStack(Tag.template_) is null)
                {
                    Node* node = form is null ? null : &form.node;
                    form = null;
                    if (node is null || inScopeNode(node, Category.scope_) is null) return true;
                    generateImpliedEndTags();
                    removeFromStack(node);
                    return true;
                }

                if (inScope(Tag.form, Category.scope_) is null) return true;
                generateImpliedEndTags();
                popUntil(Tag.form);
                return true;
            }

            case Tag.p:
                if (inScope(Tag.p, Category.scopeButton) is null) insertImplied(Tag.p);
                closePElement();
                return true;

            case Tag.li:
                if (inScope(Tag.li, Category.scopeListItem) is null) return true;
                generateImpliedEndTags(Tag.li);
                popUntil(Tag.li);
                return true;

            case Tag.dd, Tag.dt:
                if (inScope(t.tag, Category.scope_) is null) return true;
                generateImpliedEndTags(t.tag);
                popUntil(t.tag);
                return true;

            case Tag.h1, Tag.h2, Tag.h3, Tag.h4, Tag.h5, Tag.h6:
                if (headingInScope() is null) return true;
                generateImpliedEndTags();
                popUntilHeading();
                return true;

            case Tag.a, Tag.b, Tag.big, Tag.code, Tag.em, Tag.font, Tag.i, Tag.nobr, Tag.s, Tag.small, Tag.strike,
                 Tag.strong, Tag.tt, Tag.u:
                if (adoptionAgency(t)) anyOtherEndTag(t);
                return true;

            case Tag.applet, Tag.marquee, Tag.object:
                if (inScope(t.tag, Category.scope_) is null) return true;
                generateImpliedEndTags();
                popUntil(t.tag);
                clearToLastMarker();
                return true;

            case Tag.br:
                // </br> is <br>
                t.type = TokenType.startTag;
                t.attributes = null;
                reconstructFormatting();
                if (insertElement(t)) pop();
                framesetOk = false;
                return true;

            default:
                anyOtherEndTag(t);
                return true;
        }
    }

    void anyOtherEndTag(ref Token t)
    {
        foreach_reverse (i; 0 .. openElements.length)
        {
            auto n = openElements[i];
            if (n.isHtml(t.tag))
            {
                generateImpliedEndTags(t.tag);
                popUntilNode(n);
                return;
            }
            if (hasCategory(n, Category.special)) return;
        }
    }

    // The adoption agency algorithm. It returns true to act as "any other end tag".
    bool adoptionAgency(ref Token t)
    {
        auto subject = t.tag;

        auto node = current();
        if (node.isHtml(subject))
        {
            size_t i;
            if (!afeIndex(node, i)) { pop(); return false; }
        }

        foreach (outer; 0 .. 8)
        {
            // The last formatting element with this tag after the last marker
            size_t formattingIndex = 0;
            Node* formatting = null;
            foreach_reverse (i; 0 .. activeFormatting.length)
            {
                auto n = activeFormatting[i];
                if (n is null) return true;
                if (n.name == subject) { formattingIndex = i; formatting = n; break; }
            }
            if (formatting is null) return true;

            size_t stackIdx;
            if (!stackIndex(formatting, stackIdx)) { removeFromAfe(formatting); return false; }
            if (inScopeNode(formatting, Category.scope_) is null) return false;

            // The furthest block: the topmost special element after the formatting element
            Node* furthestBlock = null;
            size_t furthestIdx = 0;
            foreach (i; stackIdx .. openElements.length)
            {
                if (hasCategory(openElements[i], Category.special)) { furthestBlock = openElements[i]; furthestIdx = i; break; }
            }

            if (furthestBlock is null)
            {
                popUntilNode(formatting);
                removeFromAfe(formatting);
                return false;
            }

            auto commonAncestor = openElements[stackIdx - 1];
            size_t bookmark = formattingIndex;
            Node* last = furthestBlock;
            size_t nodeIdx = furthestIdx;
            size_t inner = 0;

            while (true)
            {
                inner++;
                if (nodeIdx == 0) return false;
                nodeIdx--;
                node = openElements[nodeIdx];
                if (node is formatting) break;

                size_t afeIdx;
                bool inAfe = afeIndex(node, afeIdx);
                if (inner > 3 && inAfe)
                {
                    removeAfeAt(afeIdx);
                    inAfe = false;
                }

                if (!inAfe)
                {
                    removeFromStack(node);
                    continue;
                }

                auto e = cloneForFormatting(node.as!Element);
                if (e is null) return false;
                node = &e.node;
                activeFormatting[afeIdx] = node;
                openElements[nodeIdx] = node;

                if (last is furthestBlock) bookmark = afeIdx + 1;

                if (last.parent !is null) last.remove();
                node.appendChild(last);
                last = node;
            }

            if (last.parent !is null) last.remove();

            bool before;
            auto pos = appropriatePlace(commonAncestor, before);
            if (pos is null) return false;
            insertAt(pos, before, last);

            auto e = cloneForFormatting(formatting.as!Element);
            if (e is null) return false;

            furthestBlock.moveChildrenTo(&e.node);
            furthestBlock.appendChild(&e.node);

            removeAfeAt(formattingIndex);
            if (bookmark > activeFormatting.length) bookmark = activeFormatting.length;
            insertAfeAt(bookmark, &e.node);

            removeFromStack(formatting);
            stackIndex(furthestBlock, furthestIdx);

            // Insert after the furthest block
            openElements.put(cast(Node*) null);
            foreach_reverse (j; furthestIdx + 2 .. openElements.length) openElements[j] = openElements[j - 1];
            openElements[furthestIdx + 1] = &e.node;
        }

        return false;
    }

    // ------------------------------------------------------------ text

    bool textMode(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.text:
                insertText(t.data);
                return true;
            case TokenType.eof:
                pop();
                mode = originalMode;
                return false;
            default:
                pop();
                mode = originalMode;
                return true;
        }
    }

    // ------------------------------------------------------------ tables

    bool currentIsTableContext()
    {
        auto n = current();
        return n.ns == Ns.html && (n.name == Tag.table || n.name == Tag.tbody || n.name == Tag.tfoot || n.name == Tag.thead || n.name == Tag.tr);
    }

    bool inTable(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.text:
                if (currentIsTableContext())
                {
                    pendingText.clear();
                    pendingNonSpace = false;
                    originalMode = mode;
                    mode = Mode.inTableText;
                    return false;
                }
                return tableAnythingElse(t);

            case TokenType.comment: insertComment(t); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.doctype: return true;
            case TokenType.eof: return inBody(t);

            case TokenType.startTag:
                switch (t.tag)
                {
                    case Tag.caption:
                        clearToTableContext();
                        pushMarker();
                        insertElement(t);
                        mode = Mode.inCaption;
                        return true;
                    case Tag.colgroup:
                        clearToTableContext();
                        insertElement(t);
                        mode = Mode.inColumnGroup;
                        return true;
                    case Tag.col:
                        clearToTableContext();
                        insertImplied(Tag.colgroup);
                        mode = Mode.inColumnGroup;
                        return false;
                    case Tag.tbody, Tag.tfoot, Tag.thead:
                        clearToTableContext();
                        insertElement(t);
                        mode = Mode.inTableBody;
                        return true;
                    case Tag.td, Tag.th, Tag.tr:
                        clearToTableContext();
                        insertImplied(Tag.tbody);
                        mode = Mode.inTableBody;
                        return false;
                    case Tag.table:
                    {
                        auto n = inScope(Tag.table, Category.scopeTable);
                        if (n is null) return true;
                        popUntilNode(n);
                        resetInsertionMode();
                        return false;
                    }
                    case Tag.style, Tag.script, Tag.template_: return inHead(t);
                    case Tag.input:
                    {
                        bool hidden = false;
                        foreach (ref a; t.attributes)
                            if (a.name == "type") { hidden = equalsCi(a.value, "hidden"); break; }
                        if (!hidden) return tableAnythingElse(t);
                        auto e = insertElement(t);
                        if (e !is null) popUntilNode(&e.node);
                        return true;
                    }
                    case Tag.form:
                    {
                        if (form !is null || findInStack(Tag.template_) !is null) return true;
                        auto e = insertElement(t);
                        if (e is null) return true;
                        form = e;
                        popUntilNode(&e.node);
                        return true;
                    }
                    default: return tableAnythingElse(t);
                }

            case TokenType.endTag:
                switch (t.tag)
                {
                    case Tag.table:
                    {
                        auto n = inScope(Tag.table, Category.scopeTable);
                        if (n is null) return true;
                        popUntilNode(n);
                        resetInsertionMode();
                        return true;
                    }
                    case Tag.body, Tag.caption, Tag.col, Tag.colgroup, Tag.html, Tag.tbody, Tag.td, Tag.tfoot, Tag.th,
                         Tag.thead, Tag.tr:
                        return true;
                    case Tag.template_: return inHead(t);
                    default: return tableAnythingElse(t);
                }

            default: return true;
        }
    }

    bool tableAnythingElse(ref Token t)
    {
        fosterParenting = true;
        inBody(t);
        fosterParenting = false;
        return true;
    }

    bool inTableText(ref Token t)
    {
        if (t.type == TokenType.text)
        {
            auto data = cleanText(t, false);
            if (data.length == 0) return true;
            foreach (c; data) pendingText.put(c);
            if (!pendingNonSpace && !allSpace(data)) pendingNonSpace = true;
            return true;
        }

        if (pendingNonSpace)
        {
            fosterParenting = true;
            bodyText(pendingText[]);
            fosterParenting = false;
        }
        else insertText(pendingText[]);

        pendingText.clear();
        mode = originalMode;
        return false;
    }

    bool inCaption(ref Token t)
    {
        if (t.type == TokenType.endTag)
        {
            switch (t.tag)
            {
                case Tag.caption: closeCaption(); return true;
                case Tag.table: return !closeCaption();
                case Tag.body, Tag.col, Tag.colgroup, Tag.html, Tag.tbody, Tag.td, Tag.tfoot, Tag.th, Tag.thead, Tag.tr:
                    return true;
                default: return inBody(t);
            }
        }

        if (t.type == TokenType.startTag)
        {
            switch (t.tag)
            {
                case Tag.caption, Tag.col, Tag.colgroup, Tag.tbody, Tag.td, Tag.tfoot, Tag.th, Tag.thead, Tag.tr:
                    return !closeCaption();
                default: break;
            }
        }

        return inBody(t);
    }

    // It returns true if the caption was closed
    bool closeCaption()
    {
        if (inScope(Tag.caption, Category.scopeTable) is null) return false;
        generateImpliedEndTags();
        popUntil(Tag.caption);
        clearToLastMarker();
        mode = Mode.inTable;
        return true;
    }

    bool inColumnGroup(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.text:
                insertText(leadingSpace(t));
                if (t.data.length == 0) return true;
                break;
            case TokenType.comment: insertComment(t); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.doctype: return true;
            case TokenType.eof: return inBody(t);
            case TokenType.startTag:
                switch (t.tag)
                {
                    case Tag.html: return inBody(t);
                    case Tag.col:
                        if (insertElement(t)) pop();
                        return true;
                    case Tag.template_: return inHead(t);
                    default: break;
                }
                break;
            case TokenType.endTag:
                switch (t.tag)
                {
                    case Tag.colgroup:
                        if (!current().isHtml(Tag.colgroup)) return true;
                        pop();
                        mode = Mode.inTable;
                        return true;
                    case Tag.col: return true;
                    case Tag.template_: return inHead(t);
                    default: break;
                }
                break;
            default: break;
        }

        if (!current().isHtml(Tag.colgroup)) return true;
        pop();
        mode = Mode.inTable;
        return false;
    }

    bool inTableBody(ref Token t)
    {
        if (t.type == TokenType.startTag)
        {
            switch (t.tag)
            {
                case Tag.tr:
                    clearToTableBodyContext();
                    insertElement(t);
                    mode = Mode.inRow;
                    return true;
                case Tag.th, Tag.td:
                    clearToTableBodyContext();
                    insertImplied(Tag.tr);
                    mode = Mode.inRow;
                    return false;
                case Tag.caption, Tag.col, Tag.colgroup, Tag.tbody, Tag.tfoot, Tag.thead:
                    if (tableSectionInScope() is null) return true;
                    clearToTableBodyContext();
                    pop();
                    mode = Mode.inTable;
                    return false;
                default: break;
            }
        }
        else if (t.type == TokenType.endTag)
        {
            switch (t.tag)
            {
                case Tag.tbody, Tag.tfoot, Tag.thead:
                    if (inScope(t.tag, Category.scopeTable) is null) return true;
                    clearToTableBodyContext();
                    pop();
                    mode = Mode.inTable;
                    return true;
                case Tag.table:
                    if (tableSectionInScope() is null) return true;
                    clearToTableBodyContext();
                    pop();
                    mode = Mode.inTable;
                    return false;
                case Tag.body, Tag.caption, Tag.col, Tag.colgroup, Tag.html, Tag.td, Tag.th, Tag.tr:
                    return true;
                default: break;
            }
        }

        return inTable(t);
    }

    bool inRow(ref Token t)
    {
        if (t.type == TokenType.startTag)
        {
            switch (t.tag)
            {
                case Tag.th, Tag.td:
                    clearToTableRowContext();
                    insertElement(t);
                    mode = Mode.inCell;
                    pushMarker();
                    return true;
                case Tag.caption, Tag.col, Tag.colgroup, Tag.tbody, Tag.tfoot, Tag.thead, Tag.tr:
                    if (inScope(Tag.tr, Category.scopeTable) is null) return true;
                    clearToTableRowContext();
                    pop();
                    mode = Mode.inTableBody;
                    return false;
                default: break;
            }
        }
        else if (t.type == TokenType.endTag)
        {
            switch (t.tag)
            {
                case Tag.tr:
                    if (inScope(Tag.tr, Category.scopeTable) is null) return true;
                    clearToTableRowContext();
                    pop();
                    mode = Mode.inTableBody;
                    return true;
                case Tag.table:
                    if (inScope(Tag.tr, Category.scopeTable) is null) return true;
                    clearToTableRowContext();
                    pop();
                    mode = Mode.inTableBody;
                    return false;
                case Tag.tbody, Tag.tfoot, Tag.thead:
                    if (inScope(t.tag, Category.scopeTable) is null) return true;
                    if (inScope(Tag.tr, Category.scopeTable) is null) return true;
                    clearToTableRowContext();
                    pop();
                    mode = Mode.inTableBody;
                    return false;
                case Tag.body, Tag.caption, Tag.col, Tag.colgroup, Tag.html, Tag.td, Tag.th:
                    return true;
                default: break;
            }
        }

        return inTable(t);
    }

    void closeCell()
    {
        generateImpliedEndTags();
        popUntilCell();
        clearToLastMarker();
        mode = Mode.inRow;
    }

    bool inCell(ref Token t)
    {
        if (t.type == TokenType.endTag)
        {
            switch (t.tag)
            {
                case Tag.td, Tag.th:
                    if (inScope(t.tag, Category.scopeTable) is null) return true;
                    generateImpliedEndTags();
                    popUntil(t.tag);
                    clearToLastMarker();
                    mode = Mode.inRow;
                    return true;
                case Tag.body, Tag.caption, Tag.col, Tag.colgroup, Tag.html:
                    return true;
                case Tag.table, Tag.tbody, Tag.tfoot, Tag.thead, Tag.tr:
                    if (inScope(t.tag, Category.scopeTable) is null) return true;
                    closeCell();
                    return false;
                default: return inBody(t);
            }
        }

        if (t.type == TokenType.startTag)
        {
            switch (t.tag)
            {
                case Tag.caption, Tag.col, Tag.colgroup, Tag.tbody, Tag.td, Tag.tfoot, Tag.th, Tag.thead, Tag.tr:
                    if (cellInScope() is null) return true;
                    closeCell();
                    return false;
                default: break;
            }
        }

        return inBody(t);
    }

    // ------------------------------------------------------------ template

    void switchTemplateMode(Mode m)
    {
        if (templateModes.length) templateModes.length--;
        templateModes.put(m);
        mode = m;
    }

    bool inTemplate(ref Token t)
    {
        final switch (t.type)
        {
            case TokenType.text, TokenType.comment, TokenType.processingInstruction, TokenType.doctype:
                return inBody(t);

            case TokenType.endTag:
                if (t.tag == Tag.template_) return inHead(t);
                return true;

            case TokenType.eof:
                if (findInStack(Tag.template_) is null) return true;
                popUntil(Tag.template_);
                clearToLastMarker();
                if (templateModes.length) templateModes.length--;
                resetInsertionMode();
                return false;

            case TokenType.startTag:
                switch (t.tag)
                {
                    case Tag.base, Tag.basefont, Tag.bgsound, Tag.link, Tag.meta, Tag.noframes, Tag.script, Tag.style,
                         Tag.template_, Tag.title:
                        return inHead(t);
                    case Tag.caption, Tag.colgroup, Tag.tbody, Tag.tfoot, Tag.thead:
                        switchTemplateMode(Mode.inTable); return false;
                    case Tag.col: switchTemplateMode(Mode.inColumnGroup); return false;
                    case Tag.tr: switchTemplateMode(Mode.inTableBody); return false;
                    case Tag.td, Tag.th: switchTemplateMode(Mode.inRow); return false;
                    default: switchTemplateMode(Mode.inBody); return false;
                }
        }
    }

    // ------------------------------------------------------------ after body, frameset

    bool afterBody(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.comment: insertComment(t, openElements[0]); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t, openElements[0]); return true;
            case TokenType.doctype: return true;
            case TokenType.eof: return true;
            case TokenType.text:
                if (allSpace(t.data)) return inBody(t);
                break;
            case TokenType.startTag:
                if (t.tag == Tag.html) return inBody(t);
                break;
            case TokenType.endTag:
                if (t.tag == Tag.html)
                {
                    if (context is null) mode = Mode.afterAfterBody;
                    return true;
                }
                break;
            default: break;
        }

        mode = Mode.inBody;
        return false;
    }

    // Only the whitespace of the text is inserted. It returns true if nothing else is left.
    bool framesetText(ref Token t)
    {
        scratch.clear();
        bool other = false;
        foreach (c; t.data)
        {
            if (isSpace(c)) scratch.put(c);
            else other = true;
        }
        if (scratch.length) insertText(scratch[]);
        return !other;
    }

    bool inFrameset(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.comment: insertComment(t); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.doctype: return true;
            case TokenType.eof: return true;
            case TokenType.text: framesetText(t); return true;
            case TokenType.startTag:
                switch (t.tag)
                {
                    case Tag.html: return inBody(t);
                    case Tag.frameset: insertElement(t); return true;
                    case Tag.frame: if (insertElement(t)) pop(); return true;
                    case Tag.noframes: return inHead(t);
                    default: return true;
                }
            case TokenType.endTag:
                if (t.tag == Tag.frameset)
                {
                    if (current() is openElements[0]) return true;
                    pop();
                    if (context is null && !current().isHtml(Tag.frameset)) mode = Mode.afterFrameset;
                }
                return true;
            default: return true;
        }
    }

    bool afterFrameset(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.comment: insertComment(t); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.text: framesetText(t); return true;
            case TokenType.startTag:
                if (t.tag == Tag.html) return inBody(t);
                if (t.tag == Tag.noframes) return inHead(t);
                return true;
            case TokenType.endTag:
                if (t.tag == Tag.html) mode = Mode.afterAfterFrameset;
                return true;
            default: return true;
        }
    }

    bool afterAfterBody(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.comment: insertComment(t, &doc.node); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t, &doc.node); return true;
            case TokenType.doctype: return inBody(t);
            case TokenType.eof: return true;
            case TokenType.text:
                if (allSpace(t.data)) return inBody(t);
                break;
            case TokenType.startTag:
                if (t.tag == Tag.html) return inBody(t);
                break;
            default: break;
        }

        mode = Mode.inBody;
        return false;
    }

    bool afterAfterFrameset(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.comment: insertComment(t, &doc.node); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t, &doc.node); return true;
            case TokenType.doctype: return inBody(t);
            case TokenType.eof: return true;
            case TokenType.text:
                if (allSpace(t.data)) return inBody(t);
                return true;
            case TokenType.startTag:
                if (t.tag == Tag.html) return inBody(t);
                if (t.tag == Tag.noframes) return inHead(t);
                return true;
            default: return true;
        }
    }

    // ------------------------------------------------------------ foreign content

    bool foreignContent(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.text:
            {
                auto data = cleanText(t, true);
                if (data.length == 0) return true;
                if (framesetOk)
                {
                    // Not only whitespace and U+FFFD
                    for (size_t i = 0; i < data.length; )
                    {
                        if (data[i] == '\xEF' && i + 2 < data.length && data[i + 1] == '\xBF' && data[i + 2] == '\xBD') { i += 3; continue; }
                        if (!isSpace(data[i])) { framesetOk = false; break; }
                        i++;
                    }
                }
                insertText(data);
                return true;
            }
            case TokenType.comment: insertComment(t); return true;
            case TokenType.processingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.doctype: return true;

            case TokenType.startTag:
                switch (t.tag)
                {
                    case Tag.b, Tag.big, Tag.blockquote, Tag.body, Tag.br, Tag.center, Tag.code, Tag.dd, Tag.div, Tag.dl,
                         Tag.dt, Tag.em, Tag.embed, Tag.h1, Tag.h2, Tag.h3, Tag.h4, Tag.h5, Tag.h6, Tag.head, Tag.hr, Tag.i,
                         Tag.img, Tag.li, Tag.listing, Tag.menu, Tag.meta, Tag.nobr, Tag.ol, Tag.p, Tag.pre, Tag.ruby, Tag.s,
                         Tag.small, Tag.span, Tag.strong, Tag.strike, Tag.sub, Tag.table, Tag.tt, Tag.u, Tag.ul, Tag.var:
                        return breakOutOfForeign(t);
                    case Tag.font:
                        foreach (ref a; t.attributes)
                            if (a.name == "color" || a.name == "face" || a.name == "size") return breakOutOfForeign(t);
                        return foreignStartTag(t);
                    default:
                        return foreignStartTag(t);
                }

            case TokenType.endTag:
                if (t.tag == Tag.p || t.tag == Tag.br) return breakOutOfForeign(t);
                if (t.tag == Tag.script)
                {
                    auto n = current();
                    if (n.name == Tag.script && n.ns == Ns.svg) { pop(); return true; }
                }
                return foreignEndTag(t);

            default: return true;
        }
    }

    // Pop the foreign elements and process the token as html
    bool breakOutOfForeign(ref Token t)
    {
        auto n = current();
        while (n !is null && !(mathTextIntegrationPoint(n) || htmlIntegrationPoint(n) || n.ns == Ns.html))
        {
            pop();
            n = current();
        }
        return run(mode, t);
    }

    bool foreignStartTag(ref Token t)
    {
        auto adjusted = adjustedCurrent();
        auto ns = adjusted.ns;

        auto e = insertForeign(t, ns);
        if (e is null) return true;

        if (ns == Ns.svg)
            if (auto fixed = svgTagName(e.name)) e.qualifiedName = fixed;

        if (!t.selfClosing) return true;

        if (t.tag == Tag.script && current().ns == Ns.svg) { pop(); return true; }
        pop();
        return true;
    }

    bool foreignEndTag(ref Token t)
    {
        if (openElements.length == 0) return run(mode, t);

        size_t idx = openElements.length - 1;
        while (idx != 0)
        {
            auto n = openElements[idx];
            if (n.name == t.tag) { popUntilNode(n); return true; }
            idx--;
            if (openElements[idx].ns == Ns.html) break;
        }

        return run(mode, t);
    }
}

// ------------------------------------------------------------ tables of names

private:

string svgTagName(uint tag) pure
{
    switch (tag)
    {
        case Tag.altglyph: return "altGlyph";
        case Tag.altglyphdef: return "altGlyphDef";
        case Tag.altglyphitem: return "altGlyphItem";
        case Tag.animatecolor: return "animateColor";
        case Tag.animatemotion: return "animateMotion";
        case Tag.animatetransform: return "animateTransform";
        case Tag.clippath: return "clipPath";
        case Tag.feblend: return "feBlend";
        case Tag.fecolormatrix: return "feColorMatrix";
        case Tag.fecomponenttransfer: return "feComponentTransfer";
        case Tag.fecomposite: return "feComposite";
        case Tag.feconvolvematrix: return "feConvolveMatrix";
        case Tag.fediffuselighting: return "feDiffuseLighting";
        case Tag.fedisplacementmap: return "feDisplacementMap";
        case Tag.fedistantlight: return "feDistantLight";
        case Tag.fedropshadow: return "feDropShadow";
        case Tag.feflood: return "feFlood";
        case Tag.fefunca: return "feFuncA";
        case Tag.fefuncb: return "feFuncB";
        case Tag.fefuncg: return "feFuncG";
        case Tag.fefuncr: return "feFuncR";
        case Tag.fegaussianblur: return "feGaussianBlur";
        case Tag.feimage: return "feImage";
        case Tag.femerge: return "feMerge";
        case Tag.femergenode: return "feMergeNode";
        case Tag.femorphology: return "feMorphology";
        case Tag.feoffset: return "feOffset";
        case Tag.fepointlight: return "fePointLight";
        case Tag.fespecularlighting: return "feSpecularLighting";
        case Tag.fespotlight: return "feSpotLight";
        case Tag.fetile: return "feTile";
        case Tag.feturbulence: return "feTurbulence";
        case Tag.foreignobject: return "foreignObject";
        case Tag.glyphref: return "glyphRef";
        case Tag.lineargradient: return "linearGradient";
        case Tag.radialgradient: return "radialGradient";
        case Tag.textpath: return "textPath";
        default: return null;
    }
}

static immutable string[2][] svgAttributes = [
    ["attributename", "attributeName"], ["attributetype", "attributeType"], ["basefrequency", "baseFrequency"],
    ["baseprofile", "baseProfile"], ["calcmode", "calcMode"], ["clippathunits", "clipPathUnits"],
    ["diffuseconstant", "diffuseConstant"], ["edgemode", "edgeMode"], ["filterunits", "filterUnits"],
    ["glyphref", "glyphRef"], ["gradienttransform", "gradientTransform"], ["gradientunits", "gradientUnits"],
    ["kernelmatrix", "kernelMatrix"], ["kernelunitlength", "kernelUnitLength"], ["keypoints", "keyPoints"],
    ["keysplines", "keySplines"], ["keytimes", "keyTimes"], ["lengthadjust", "lengthAdjust"],
    ["limitingconeangle", "limitingConeAngle"], ["markerheight", "markerHeight"], ["markerunits", "markerUnits"],
    ["markerwidth", "markerWidth"], ["maskcontentunits", "maskContentUnits"], ["maskunits", "maskUnits"],
    ["numoctaves", "numOctaves"], ["pathlength", "pathLength"], ["patterncontentunits", "patternContentUnits"],
    ["patterntransform", "patternTransform"], ["patternunits", "patternUnits"], ["pointsatx", "pointsAtX"],
    ["pointsaty", "pointsAtY"], ["pointsatz", "pointsAtZ"], ["preservealpha", "preserveAlpha"],
    ["preserveaspectratio", "preserveAspectRatio"], ["primitiveunits", "primitiveUnits"], ["refx", "refX"],
    ["refy", "refY"], ["repeatcount", "repeatCount"], ["repeatdur", "repeatDur"],
    ["requiredextensions", "requiredExtensions"], ["requiredfeatures", "requiredFeatures"],
    ["specularconstant", "specularConstant"], ["specularexponent", "specularExponent"],
    ["spreadmethod", "spreadMethod"], ["startoffset", "startOffset"], ["stddeviation", "stdDeviation"],
    ["stitchtiles", "stitchTiles"], ["surfacescale", "surfaceScale"], ["systemlanguage", "systemLanguage"],
    ["tablevalues", "tableValues"], ["targetx", "targetX"], ["targety", "targetY"], ["textlength", "textLength"],
    ["viewbox", "viewBox"], ["viewtarget", "viewTarget"], ["xchannelselector", "xChannelSelector"],
    ["ychannelselector", "yChannelSelector"], ["zoomandpan", "zoomAndPan"],
];

struct ForeignAttribute { string name, prefix, local; Ns ns; }

static immutable ForeignAttribute[] foreignAttributes = [
    ForeignAttribute("xlink:actuate", "xlink", "actuate", Ns.xlink),
    ForeignAttribute("xlink:arcrole", "xlink", "arcrole", Ns.xlink),
    ForeignAttribute("xlink:href", "xlink", "href", Ns.xlink),
    ForeignAttribute("xlink:role", "xlink", "role", Ns.xlink),
    ForeignAttribute("xlink:show", "xlink", "show", Ns.xlink),
    ForeignAttribute("xlink:title", "xlink", "title", Ns.xlink),
    ForeignAttribute("xlink:type", "xlink", "type", Ns.xlink),
    ForeignAttribute("xml:lang", "xml", "lang", Ns.xml),
    ForeignAttribute("xml:space", "xml", "space", Ns.xml),
    ForeignAttribute("xmlns", "", "xmlns", Ns.xmlns),
    ForeignAttribute("xmlns:xlink", "xmlns", "xlink", Ns.xmlns),
];

// Doctypes (compared ASCII case-insensitively, the tables are lowercase)
static immutable string[] quirksPublicIs = [
    "-//w3o//dtd w3 html strict 3.0//en//", "-/w3c/dtd html 4.0 transitional/en", "html",
];

static immutable string[] quirksPublicStart = [
    "+//silmaril//dtd html pro v0r11 19970101//", "-//as//dtd html 3.0 aswedit + extensions//",
    "-//advasoft ltd//dtd html 3.0 aswedit + extensions//", "-//ietf//dtd html 2.0 level 1//",
    "-//ietf//dtd html 2.0 level 2//", "-//ietf//dtd html 2.0 strict level 1//", "-//ietf//dtd html 2.0 strict level 2//",
    "-//ietf//dtd html 2.0 strict//", "-//ietf//dtd html 2.0//", "-//ietf//dtd html 2.1e//", "-//ietf//dtd html 3.0//",
    "-//ietf//dtd html 3.2 final//", "-//ietf//dtd html 3.2//", "-//ietf//dtd html 3//", "-//ietf//dtd html level 0//",
    "-//ietf//dtd html level 1//", "-//ietf//dtd html level 2//", "-//ietf//dtd html level 3//",
    "-//ietf//dtd html strict level 0//", "-//ietf//dtd html strict level 1//", "-//ietf//dtd html strict level 2//",
    "-//ietf//dtd html strict level 3//", "-//ietf//dtd html strict//", "-//ietf//dtd html//",
    "-//metrius//dtd metrius presentational//", "-//microsoft//dtd internet explorer 2.0 html strict//",
    "-//microsoft//dtd internet explorer 2.0 html//", "-//microsoft//dtd internet explorer 2.0 tables//",
    "-//microsoft//dtd internet explorer 3.0 html strict//", "-//microsoft//dtd internet explorer 3.0 html//",
    "-//microsoft//dtd internet explorer 3.0 tables//", "-//netscape comm. corp.//dtd html//",
    "-//netscape comm. corp.//dtd strict html//", "-//o'reilly and associates//dtd html 2.0//",
    "-//o'reilly and associates//dtd html extended 1.0//", "-//o'reilly and associates//dtd html extended relaxed 1.0//",
    "-//sq//dtd html 2.0 hotmetal + extensions//",
    "-//softquad software//dtd hotmetal pro 6.0::19990601::extensions to html 4.0//",
    "-//softquad//dtd hotmetal pro 4.0::19971010::extensions to html 4.0//", "-//spyglass//dtd html 2.0 extended//",
    "-//sun microsystems corp.//dtd hotjava html//", "-//sun microsystems corp.//dtd hotjava strict html//",
    "-//w3c//dtd html 3 1995-03-24//", "-//w3c//dtd html 3.2 draft//", "-//w3c//dtd html 3.2 final//",
    "-//w3c//dtd html 3.2//", "-//w3c//dtd html 3.2s draft//", "-//w3c//dtd html 4.0 frameset//",
    "-//w3c//dtd html 4.0 transitional//", "-//w3c//dtd html experimental 19960712//",
    "-//w3c//dtd html experimental 970421//", "-//w3c//dtd w3 html//", "-//w3o//dtd w3 html 3.0//",
    "-//webtechs//dtd mozilla html 2.0//", "-//webtechs//dtd mozilla html//",
];

static immutable string[] quirksHtml401 = ["-//w3c//dtd html 4.01 frameset//", "-//w3c//dtd html 4.01 transitional//"];
static immutable string[] limitedXhtml = ["-//w3c//dtd xhtml 1.0 frameset//", "-//w3c//dtd xhtml 1.0 transitional//"];
