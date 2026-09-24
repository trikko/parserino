/++
 HTML tree construction (HTML Living Standard, "Tree construction").

 Derived from lexbor (https://github.com/lexbor/lexbor), Apache-2.0: see NOTICE-lexbor.
+/
module parserino.html.treebuilder;

import parserino.arena;
import parserino.names;
import parserino.dom;
import parserino.html.tokenizer;

@nogc nothrow pure @safe:

enum Mode : ubyte
{
    Initial, BeforeHtml, BeforeHead, InHead, InHeadNoscript, AfterHead, InBody, Text,
    InTable, InTableText, InCaption, InColumnGroup, InTableBody, InRow, InCell, InTemplate,
    AfterBody, InFrameset, AfterFrameset, AfterAfterBody, AfterAfterFrameset,
}

// Element flags
enum : ubyte
{
    FlagSelected = 1,           // option selectedness
    FlagContentDisabled = 2,    // selectedcontent not in a select
}

struct TreeBuilder
{
@nogc nothrow pure @safe:
    @disable this(this);

    DomDocument* doc;
    Tokenizer* tokenizer;

    /// The stack of open elements and the list of active formatting elements (null = marker)
    Buffer!(DomNode*) openElements;
    Buffer!(DomNode*) activeFormatting;

    bool framesetOk = true;
    DomElement* head;
    DomElement* body;
    CompatMode compatMode;

    /// Fragment parsing: the context element and the root of the result
    DomNode* context;
    DomElement* fragmentRoot;

    /// Out of memory
    bool failed;

    /// Start parsing a document
    void beginDocument(DomDocument* d, Tokenizer* t)
    {
        doc = d;
        tokenizer = t;
        mode = Mode.Initial;
        compatMode = CompatMode.NoQuirks;
    }

    /// Start parsing a fragment in the context of `contextElement` (an element of `d`)
    bool beginFragment(DomDocument* d, Tokenizer* t, DomElement* contextElement)
    {
        doc = d;
        tokenizer = t;
        compatMode = d.compatMode;
        context = &contextElement.node;

        auto tag = context.name;
        if (context.ns == Ns.Html)
        {
            switch (tag)
            {
                case Tag.Title, Tag.Textarea: t.switchTo(State.Rcdata); break;
                case Tag.Style, Tag.Xmp, Tag.Iframe, Tag.Noembed, Tag.Noframes: t.switchTo(State.Rawtext); break;
                case Tag.Script: t.switchTo(State.ScriptData); break;
                case Tag.Noscript: if (d.scripting) t.switchTo(State.Rawtext); break;
                case Tag.Plaintext: t.switchTo(State.Plaintext); break;
                default: break;
            }
        }

        fragmentRoot = d.createElement(Tag.Html, Ns.Html);
        if (fragmentRoot is null) return false;
        push(&fragmentRoot.node);

        if (context.isHtml(Tag.Template)) templateModes.put(Mode.InTemplate);

        resetInsertionMode();

        // The form element pointer: the nearest form ancestor of the context
        for (auto n = context; n !is null; n = n.parent)
            if (n.isHtml(Tag.Form)) { form = n.as!DomElement; break; }

        return true;
    }

    /// Process a token (the tokenizer calls it)
    bool process(ref Token t)
    {
        if (failed) return false;

        if (skipNewline)
        {
            skipNewline = false;
            if (t.type == TokenType.Text && t.data.length && t.data[0] == '\n')
            {
                t.data = t.data[1 .. $];
                if (t.data.length == 0) return true;
            }
        }

        while (!failed && !dispatch(t)) {}
        if (buffersFailed()) failed = true;
        return !failed;
    }

    // Did a buffer run out of memory?
    bool buffersFailed() const
    {
        return openElements.failed || activeFormatting.failed || templateModes.failed || pendingText.failed
            || scratch.failed;
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
    DomElement* form;
    bool fosterParenting;
    bool skipNewline;

    // Pending characters in "in table text"
    Buffer!char pendingText;
    bool pendingNonSpace;

    // Attribute adjustments for foreign elements
    enum Adjust : ubyte { None, Svg, Math }
    Adjust adjust;

    static bool processCallback(void* ctx, ref Token t) @trusted { return (cast(TreeBuilder*) ctx).process(t); }

    static bool foreignCallback(void* ctx) @trusted
    {
        auto tb = cast(TreeBuilder*) ctx;
        auto n = tb.adjustedCurrent();
        return n !is null && n.ns != Ns.Html;
    }

    // ------------------------------------------------------------ stack of open elements

    DomNode* current() { return openElements.length ? openElements[openElements.length - 1] : null; }

    DomNode* adjustedCurrent()
    {
        if (context !is null && openElements.length == 1) return context;
        return current();
    }

    void push(DomNode* n) { openElements.put(n); }

    DomNode* pop()
    {
        if (openElements.length == 0) return null;
        auto n = openElements[openElements.length - 1];
        openElements.removeLast();
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
    void popUntilNode(DomNode* node)
    {
        while (openElements.length)
            if (pop() is node) return;
    }

    void popUntilHeading()
    {
        while (openElements.length)
        {
            auto n = pop();
            if (n.ns == Ns.Html && isHeading(n.name)) return;
        }
    }

    void popUntilCell()
    {
        while (openElements.length)
        {
            auto n = pop();
            if (n.isHtml(Tag.Td) || n.isHtml(Tag.Th)) return;
        }
    }

    void removeFromStack(DomNode* n)
    {
        foreach_reverse (i; 0 .. openElements.length)
        {
            if (openElements[i] is n)
            {
                foreach (j; i .. openElements.length - 1) openElements[j] = openElements[j + 1];
                openElements.removeLast();
                return;
            }
        }
    }

    bool stackIndex(DomNode* n, out size_t idx)
    {
        foreach_reverse (i; 0 .. openElements.length)
            if (openElements[i] is n) { idx = i; return true; }
        return false;
    }

    bool inStack(DomNode* n) { size_t i; return stackIndex(n, i); }

    // The last html element `tag` in the stack
    DomNode* findInStack(uint tag, out size_t idx)
    {
        foreach_reverse (i; 0 .. openElements.length)
            if (openElements[i].isHtml(tag)) { idx = i; return openElements[i]; }
        return null;
    }

    DomNode* findInStack(uint tag) { size_t i; return findInStack(tag, i); }

    // An element popped from the stack: <option> updates <selectedcontent>
    void popped(DomNode* n)
    {
        if (n.isHtml(Tag.Option)) maybeCloneToSelectedContent(n.as!DomElement);
    }

    static bool isHeading(uint tag) pure
    {
        return tag == Tag.H1 || tag == Tag.H2 || tag == Tag.H3 || tag == Tag.H4 || tag == Tag.H5 || tag == Tag.H6;
    }

    static bool hasCategory(const(DomNode)* n, ubyte cat) pure
    {
        if (n.name >= Tag.Last) return (Category.Ordinary & cat) != 0;
        return (tagCategories[n.name][n.ns] & cat) != 0;
    }

    // "has an element in scope"
    DomNode* inScope(uint tag, ubyte scope_)
    {
        foreach_reverse (i; 0 .. openElements.length)
        {
            auto n = openElements[i];
            if (n.isHtml(tag)) return n;
            if (hasCategory(n, scope_)) return null;
        }
        return null;
    }

    DomNode* inScopeNode(DomNode* target, ubyte scope_)
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
    DomNode* inScopeAny(alias pred)(ubyte scope_)
    {
        foreach_reverse (i; 0 .. openElements.length)
        {
            auto n = openElements[i];
            if (n.type == NodeType.Element && n.ns == Ns.Html && pred(n.name)) return n;
            if (hasCategory(n, scope_)) return null;
        }
        return null;
    }

    static bool isTableSection(uint t) pure { return t == Tag.Tbody || t == Tag.Thead || t == Tag.Tfoot; }
    static bool isCell(uint t) pure { return t == Tag.Td || t == Tag.Th; }
    static bool isTable(uint t) pure { return t == Tag.Table; }
    static bool isRow(uint t) pure { return t == Tag.Tr; }

    DomNode* headingInScope() { return inScopeAny!isHeading(Category.Scope); }
    DomNode* tableSectionInScope() { return inScopeAny!isTableSection(Category.ScopeTable); }
    DomNode* cellInScope() { return inScopeAny!isCell(Category.ScopeTable); }

    static bool impliedEndTag(uint tag) pure
    {
        switch (tag)
        {
            case Tag.Dd, Tag.Dt, Tag.Li, Tag.Optgroup, Tag.Option, Tag.P, Tag.Rb, Tag.Rp, Tag.Rt, Tag.Rtc: return true;
            default: return false;
        }
    }

    void generateImpliedEndTags(uint except = Tag.Undef)
    {
        while (openElements.length)
        {
            auto n = current();
            if (n.ns != Ns.Html || !impliedEndTag(n.name) || n.name == except) return;
            pop();
        }
    }

    void generateImpliedEndTagsThoroughly()
    {
        while (openElements.length)
        {
            auto n = current();
            if (n.ns != Ns.Html) return;
            switch (n.name)
            {
                case Tag.Caption, Tag.Colgroup, Tag.Dd, Tag.Dt, Tag.Li, Tag.Optgroup, Tag.Option, Tag.P, Tag.Rb, Tag.Rp,
                     Tag.Rt, Tag.Rtc, Tag.Tbody, Tag.Td, Tag.Tfoot, Tag.Th, Tag.Thead, Tag.Tr:
                    pop();
                    break;
                default:
                    return;
            }
        }
    }

    void closePElement()
    {
        generateImpliedEndTags(Tag.P);
        popUntil(Tag.P);
    }

    void closePIfInButtonScope()
    {
        if (inScope(Tag.P, Category.ScopeButton) !is null) closePElement();
    }

    void clearStackBackTo(alias pred)()
    {
        while (openElements.length)
        {
            auto n = current();
            if (n.ns == Ns.Html && (pred(n.name) || n.name == Tag.Template || n.name == Tag.Html)) return;
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

            if (node.ns != Ns.Html)
            {
                if (last) { mode = Mode.InBody; return; }
                continue;
            }

            switch (node.name)
            {
                case Tag.Td, Tag.Th: if (!last) { mode = Mode.InCell; return; } break;
                case Tag.Tr: mode = Mode.InRow; return;
                case Tag.Tbody, Tag.Thead, Tag.Tfoot: mode = Mode.InTableBody; return;
                case Tag.Caption: mode = Mode.InCaption; return;
                case Tag.Colgroup: mode = Mode.InColumnGroup; return;
                case Tag.Table: mode = Mode.InTable; return;
                case Tag.Template: mode = templateModes.length ? templateModes[templateModes.length - 1] : Mode.InBody; return;
                case Tag.Head: if (!last) { mode = Mode.InHead; return; } break;
                case Tag.Body: mode = Mode.InBody; return;
                case Tag.Frameset: mode = Mode.InFrameset; return;
                case Tag.Html: mode = head is null ? Mode.BeforeHead : Mode.AfterHead; return;
                default: break;
            }

            if (last) { mode = Mode.InBody; return; }
        }
    }

    // ------------------------------------------------------------ active formatting elements

    void pushMarker() { activeFormatting.put(cast(DomNode*) null); }

    void clearToLastMarker()
    {
        while (activeFormatting.length)
        {
            activeFormatting.removeLast();
            if (activeFormatting[activeFormatting.length] is null) return;
        }
    }

    bool afeIndex(DomNode* n, out size_t idx)
    {
        foreach_reverse (i; 0 .. activeFormatting.length)
            if (activeFormatting[i] is n) { idx = i; return true; }
        return false;
    }

    void removeFromAfe(DomNode* n)
    {
        size_t i;
        if (afeIndex(n, i)) removeAfeAt(i);
    }

    void removeAfeAt(size_t i)
    {
        foreach (j; i .. activeFormatting.length - 1) activeFormatting[j] = activeFormatting[j + 1];
        activeFormatting.removeLast();
    }

    void insertAfeAt(size_t i, DomNode* n)
    {
        activeFormatting.put(cast(DomNode*) null);
        foreach_reverse (j; i + 1 .. activeFormatting.length) activeFormatting[j] = activeFormatting[j - 1];
        activeFormatting[i] = n;
    }

    // The last element `tag` after the last marker
    DomNode* afeAfterLastMarker(uint tag)
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
    void pushFormatting(DomNode* node)
    {
        size_t count = 0;
        size_t earliest = activeFormatting.length ? activeFormatting.length - 1 : 0;

        foreach_reverse (i; 0 .. activeFormatting.length)
        {
            auto n = activeFormatting[i];
            if (n is null) break;
            if (n.name == node.name && n.ns == node.ns && sameAttributes(n.as!DomElement, node.as!DomElement))
            {
                count++;
                earliest = i;
            }
        }

        if (count >= 3) removeAfeAt(earliest);
        activeFormatting.put(node);
    }

    static bool sameAttributes(DomElement* a, DomElement* b)
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
            auto src = activeFormatting[i].as!DomElement;
            auto e = insertClone(src);
            if (e is null) return;
            activeFormatting[i] = &e.node;
        }
    }

    // ------------------------------------------------------------ insertion

    // The appropriate place for inserting a node: the parent, or the node to insert before
    DomNode* appropriatePlace(DomNode* overrideTarget, out bool before)
    {
        DomNode* target = overrideTarget !is null ? overrideTarget : current();
        DomNode* location;

        if (fosterParenting && target.ns == Ns.Html
            && (target.name == Tag.Table || target.name == Tag.Tbody || target.name == Tag.Tfoot
                || target.name == Tag.Thead || target.name == Tag.Tr))
        {
            size_t ti, tbi;
            auto lastTemplate = findInStack(Tag.Template, ti);
            auto lastTable = findInStack(Tag.Table, tbi);

            if (lastTemplate !is null && (lastTable is null || ti > tbi))
                return &lastTemplate.as!DomElement.templateContent.node;

            if (lastTable is null) location = openElements[0];
            else if (lastTable.parent !is null) { location = lastTable; before = true; }
            else location = openElements[tbi - 1];
        }
        else location = target;

        if (location is null) return null;

        if (!before && location.isHtml(Tag.Template))
            location = &location.as!DomElement.templateContent.node;

        return location;
    }

    void insertAt(DomNode* pos, bool before, DomNode* node)
    {
        if (before) pos.insertBefore(node);
        else
        {
            pos.appendChild(node);
            insertionSteps(node);
        }
    }

    DomElement* createElementForToken(ref Token t, Ns ns)
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

        if (e.isHtml(Tag.Option) && e.attribute(AttrName.Selected) !is null) e.flags |= FlagSelected;
        return e;
    }

    // A new element with the same tag and attributes (for the formatting elements)
    DomElement* cloneForFormatting(DomElement* src)
    {
        auto e = doc.createElement(src.name, Ns.Html);
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

    DomElement* insertClone(DomElement* src)
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

    DomElement* insertElement(ref Token t, Ns ns = Ns.Html, bool onlyPush = false)
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
    DomElement* insertImplied(uint tag)
    {
        Token t;
        t.type = TokenType.StartTag;
        t.tag = tag;
        return insertElement(t);
    }

    DomElement* insertForeign(ref Token t, Ns ns)
    {
        adjust = ns == Ns.Math ? Adjust.Math : ns == Ns.Svg ? Adjust.Svg : Adjust.None;
        auto e = insertElement(t, ns);
        adjust = Adjust.None;
        return e;
    }

    void insertText(scope const(char)[] data)
    {
        if (data.length == 0) return;

        bool before;
        auto pos = appropriatePlace(null, before);
        if (pos is null || pos.type == NodeType.Document) return;

        DomNode* sibling = before ? pos.prev : pos.lastChild;
        if (sibling !is null && sibling.type == NodeType.Text)
        {
            if (!sibling.as!DomCharacterData.appendData(data)) failed = true;
            return;
        }

        auto t = doc.createText(data);
        if (t is null) { failed = true; return; }
        insertAt(pos, before, &t.node);
    }

    // A comment as last child of `parent`, or at the appropriate place
    void insertComment(ref Token t, DomNode* parent = null)
    {
        bool before;
        DomNode* pos = parent !is null ? parent : appropriatePlace(null, before);
        if (pos is null) return;

        auto c = doc.createComment(t.data);
        if (c is null) { failed = true; return; }
        insertAt(pos, before, &c.node);
    }

    void insertProcessingInstruction(ref Token t, DomNode* overrideTarget = null)
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
        mode = Mode.Text;
    }

    void setHead(DomElement* e) { head = e; }
    void setBody(DomElement* e) { body = e; }

    // ------------------------------------------------------------ foreign attributes

    void adjustAttribute(DomAttribute* a, scope const(char)[] name)
    {
        final switch (adjust)
        {
            case Adjust.None: return;
            case Adjust.Math:
                if (name == "definitionurl") a.qualifiedName = "definitionURL";
                break;
            case Adjust.Svg:
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

    void insertionSteps(DomNode* n)
    {
        if (n.type != NodeType.Element || n.ns != Ns.Html) return;

        if (n.name == Tag.Option)
        {
            if (auto sel = nearestSelect(n)) selectednessSetting(sel);
        }
        else if (n.name == Tag.Select) selectednessSetting(n.as!DomElement);
        else if (n.name == Tag.Selectedcontent)
        {
            auto e = n.as!DomElement;
            if (n.parent is null || !n.parent.isHtml(Tag.Select)) { e.flags |= FlagContentDisabled; return; }
            e.flags &= ~FlagContentDisabled;
            selectednessSetting(n.parent.as!DomElement);
        }
    }

    static DomElement* nearestSelect(DomNode* option)
    {
        DomNode* optgroup = null;
        for (auto n = option.parent; n !is null; n = n.parent)
        {
            if (n.ns != Ns.Html) continue;
            switch (n.name)
            {
                case Tag.Datalist, Tag.Hr, Tag.Option: return null;
                case Tag.Optgroup:
                    if (optgroup !is null) return null;
                    optgroup = n;
                    break;
                case Tag.Select: return n.as!DomElement;
                default: break;
            }
        }
        return null;
    }

    static bool optionDisabled(DomNode* option)
    {
        if (option.as!DomElement.attribute(AttrName.Disabled) !is null) return true;
        for (auto n = option.parent; n !is null; n = n.parent)
        {
            if (n.ns != Ns.Html) continue;
            switch (n.name)
            {
                case Tag.Select, Tag.Datalist, Tag.Hr, Tag.Option: return false;
                case Tag.Optgroup: return n.as!DomElement.attribute(AttrName.Disabled) !is null;
                default: break;
            }
        }
        return false;
    }

    // The options of a select: its option descendants, not inside nested select/datalist/option or optgroup/optgroup
    static void forEachOption(DomElement* select, scope void delegate(DomElement*) @nogc nothrow pure @safe dg)
    {
        auto root = &select.node;
        for (auto n = root.firstChild; n !is null; )
        {
            bool descend = true;
            if (n.type == NodeType.Element && n.ns == Ns.Html)
            {
                switch (n.name)
                {
                    case Tag.Option: dg(n.as!DomElement); descend = false; break;
                    case Tag.Select, Tag.Datalist, Tag.Hr: descend = false; break;
                    case Tag.Optgroup:
                        for (auto p = n.parent; p !is root; p = p.parent)
                            if (p.isHtml(Tag.Optgroup)) { descend = false; break; }
                        break;
                    default: break;
                }
            }
            else if (n.type != NodeType.Element) descend = false;

            n = descend && n.firstChild !is null ? n.firstChild : n.nextSkippingChildren(root);
        }
    }

    // HTML "selectedness setting algorithm"
    static void selectednessSetting(DomElement* select)
    {
        if (select.attribute(AttrName.Multiple) !is null) return;

        size_t displaySize = 1;
        if (auto size = select.attribute(AttrName.Size))
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

        DomElement* first = null;
        DomElement* lastSelected = null;
        size_t selected = 0;

        forEachOption(select, (DomElement* o) {
            if (o.flags & FlagSelected) { selected++; lastSelected = o; }
            if (first is null && !optionDisabled(&o.node)) first = o;
        });

        if (selected == 0) { if (first !is null) first.flags |= FlagSelected; return; }
        if (selected >= 2)
            forEachOption(select, (DomElement* o) { if (o !is lastSelected) o.flags &= ~FlagSelected; });
    }

    // An option popped from the stack: its content goes in the <selectedcontent> of its select
    void maybeCloneToSelectedContent(DomElement* option)
    {
        if (!(option.flags & FlagSelected)) return;

        auto select = nearestSelect(&option.node);
        if (select is null || select.attribute(AttrName.Multiple) !is null) return;

        DomElement* sc = null;
        for (auto n = select.node.firstChild; n !is null; n = n.nextInTree(&select.node))
            if (n.isHtml(Tag.Selectedcontent)) { sc = n.as!DomElement; break; }

        if (sc is null || (sc.flags & FlagContentDisabled)) return;

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

    bool isStart(ref Token t) { return t.type == TokenType.StartTag; }
    bool isEnd(ref Token t) { return t.type == TokenType.EndTag; }

    static bool mathTextIntegrationPoint(const(DomNode)* n) pure
    {
        return n.ns == Ns.Math && (n.name == Tag.Mi || n.name == Tag.Mo || n.name == Tag.Mn || n.name == Tag.Ms || n.name == Tag.Mtext);
    }

    static bool htmlIntegrationPoint(DomNode* n)
    {
        if (n.ns == Ns.Math && n.name == Tag.AnnotationXml)
        {
            auto a = n.as!DomElement.attribute("encoding");
            if (a is null) return false;
            return equalsCi(a.value, "text/html") || equalsCi(a.value, "application/xhtml+xml");
        }

        return n.ns == Ns.Svg && (n.name == Tag.Foreignobject || n.name == Tag.Desc || n.name == Tag.Title);
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
        if (adjusted is null || adjusted.ns == Ns.Html) return run(mode, t);

        if (mathTextIntegrationPoint(adjusted))
        {
            if (isStart(t) && t.tag != Tag.Mglyph && t.tag != Tag.Malignmark) return run(mode, t);
            if (t.type == TokenType.Text) return run(mode, t);
        }

        if (adjusted.ns == Ns.Math && adjusted.name == Tag.AnnotationXml && isStart(t) && t.tag == Tag.Svg)
            return run(mode, t);

        if (htmlIntegrationPoint(adjusted) && (isStart(t) || t.type == TokenType.Text))
            return run(mode, t);

        if (t.type == TokenType.Eof) return run(mode, t);

        return foreignContent(t);
    }

    bool run(Mode m, ref Token t)
    {
        final switch (m)
        {
            case Mode.Initial: return initialMode(t);
            case Mode.BeforeHtml: return beforeHtml(t);
            case Mode.BeforeHead: return beforeHead(t);
            case Mode.InHead: return inHead(t);
            case Mode.InHeadNoscript: return inHeadNoscript(t);
            case Mode.AfterHead: return afterHead(t);
            case Mode.InBody: return inBody(t);
            case Mode.Text: return textMode(t);
            case Mode.InTable: return inTable(t);
            case Mode.InTableText: return inTableText(t);
            case Mode.InCaption: return inCaption(t);
            case Mode.InColumnGroup: return inColumnGroup(t);
            case Mode.InTableBody: return inTableBody(t);
            case Mode.InRow: return inRow(t);
            case Mode.InCell: return inCell(t);
            case Mode.InTemplate: return inTemplate(t);
            case Mode.AfterBody: return afterBody(t);
            case Mode.InFrameset: return inFrameset(t);
            case Mode.AfterFrameset: return afterFrameset(t);
            case Mode.AfterAfterBody: return afterAfterBody(t);
            case Mode.AfterAfterFrameset: return afterAfterFrameset(t);
        }
    }

    // ------------------------------------------------------------ initial

    bool initialMode(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.Comment: insertComment(t, &doc.node); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t, &doc.node); return true;
            case TokenType.Doctype:
                mode = Mode.BeforeHtml;
                insertDoctype(t);
                return true;
            case TokenType.Text:
                leadingSpace(t);
                if (t.data.length == 0) return true;
                goto default;
            default:
                compatMode = CompatMode.Quirks;
                if (context is null) doc.compatMode = compatMode;
                mode = Mode.BeforeHtml;
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
        if (t.forceQuirks || t.name != "html") return CompatMode.Quirks;

        auto pub = t.publicId;
        auto sys = t.systemId;

        if (t.hasPublicId)
        {
            foreach (s; quirksPublicIs) if (equalsCi(pub, s)) return CompatMode.Quirks;
            foreach (s; quirksPublicStart) if (startsCi(pub, s)) return CompatMode.Quirks;
        }

        if (t.hasSystemId && equalsCi(sys, "http://www.ibm.com/data/dtd/v11/ibmxhtml1-transitional.dtd")) return CompatMode.Quirks;

        if (t.hasPublicId && !t.hasSystemId)
            foreach (s; quirksHtml401) if (startsCi(pub, s)) return CompatMode.Quirks;

        if (t.hasPublicId)
        {
            foreach (s; limitedXhtml) if (startsCi(pub, s)) return CompatMode.LimitedQuirks;
            if (t.hasSystemId) foreach (s; quirksHtml401) if (startsCi(pub, s)) return CompatMode.LimitedQuirks;
        }

        return CompatMode.NoQuirks;
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
            case TokenType.Doctype: return true;
            case TokenType.Comment: insertComment(t, &doc.node); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t, &doc.node); return true;
            case TokenType.Text:
                leadingSpace(t);
                if (t.data.length == 0) return true;
                break;
            case TokenType.StartTag:
                if (t.tag == Tag.Html)
                {
                    auto e = createElementForToken(t, Ns.Html);
                    if (e is null) return true;
                    insertHtml(e);
                    mode = Mode.BeforeHead;
                    return true;
                }
                break;
            case TokenType.EndTag:
                if (t.tag != Tag.Head && t.tag != Tag.Body && t.tag != Tag.Html && t.tag != Tag.Br) return true;
                break;
            default: break;
        }

        auto e = doc.createElement(Tag.Html, Ns.Html);
        if (e is null) { failed = true; return true; }
        insertHtml(e);
        mode = Mode.BeforeHead;
        return false;
    }

    void insertHtml(DomElement* e)
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
            case TokenType.Comment: insertComment(t); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.Doctype: return true;
            case TokenType.Text:
                leadingSpace(t);
                if (t.data.length == 0) return true;
                break;
            case TokenType.StartTag:
                if (t.tag == Tag.Html) return inBody(t);
                if (t.tag == Tag.Head)
                {
                    setHead(insertElement(t));
                    mode = Mode.InHead;
                    return true;
                }
                break;
            case TokenType.EndTag:
                if (t.tag != Tag.Head && t.tag != Tag.Body && t.tag != Tag.Html && t.tag != Tag.Br) return true;
                break;
            default: break;
        }

        setHead(insertImplied(Tag.Head));
        mode = Mode.InHead;
        return false;
    }

    // ------------------------------------------------------------ in head

    bool inHead(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.Comment: insertComment(t); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.Doctype: return true;

            case TokenType.Text:
                insertText(leadingSpace(t));
                if (t.data.length == 0) return true;
                break;

            case TokenType.StartTag:
                switch (t.tag)
                {
                    case Tag.Html: return inBody(t);
                    case Tag.Base, Tag.Basefont, Tag.Bgsound, Tag.Link, Tag.Meta:
                        if (insertElement(t)) pop();
                        return true;
                    case Tag.Title: genericText(t, State.Rcdata); return true;
                    case Tag.Noscript:
                        if (doc.scripting) genericText(t, State.Rawtext);
                        else { insertElement(t); mode = Mode.InHeadNoscript; }
                        return true;
                    case Tag.Noframes, Tag.Style: genericText(t, State.Rawtext); return true;
                    case Tag.Script:
                    {
                        bool before;
                        auto pos = appropriatePlace(null, before);
                        if (pos is null) return true;
                        auto e = createElementForToken(t, Ns.Html);
                        if (e is null) return true;
                        push(&e.node);
                        insertAt(pos, before, &e.node);
                        tokenizer.switchTo(State.ScriptData);
                        originalMode = mode;
                        mode = Mode.Text;
                        return true;
                    }
                    case Tag.Template:
                        if (insertElement(t) is null) return true;
                        pushMarker();
                        framesetOk = false;
                        mode = Mode.InTemplate;
                        templateModes.put(Mode.InTemplate);
                        return true;
                    case Tag.Head: return true;
                    default: break;
                }
                break;

            case TokenType.EndTag:
                switch (t.tag)
                {
                    case Tag.Head:
                        pop();
                        mode = Mode.AfterHead;
                        return true;
                    case Tag.Body, Tag.Html, Tag.Br: break;
                    case Tag.Template: templateEnd(); return true;
                    default: return true;
                }
                break;

            default: break;
        }

        pop();
        mode = Mode.AfterHead;
        return false;
    }

    void templateEnd()
    {
        if (findInStack(Tag.Template) is null) return;
        generateImpliedEndTagsThoroughly();
        popUntil(Tag.Template);
        clearToLastMarker();
        if (templateModes.length) templateModes.removeLast();
        resetInsertionMode();
    }

    bool inHeadNoscript(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.Doctype: return true;
            case TokenType.Comment, TokenType.ProcessingInstruction: return inHead(t);
            case TokenType.Text:
                insertText(leadingSpace(t));
                if (t.data.length == 0) return true;
                break;
            case TokenType.StartTag:
                switch (t.tag)
                {
                    case Tag.Html: return inBody(t);
                    case Tag.Basefont, Tag.Bgsound, Tag.Link, Tag.Meta, Tag.Noframes, Tag.Style: return inHead(t);
                    case Tag.Head, Tag.Noscript: return true;
                    default: break;
                }
                break;
            case TokenType.EndTag:
                if (t.tag == Tag.Noscript) { pop(); mode = Mode.InHead; return true; }
                if (t.tag != Tag.Br) return true;
                break;
            default: break;
        }

        pop();
        mode = Mode.InHead;
        return false;
    }

    // ------------------------------------------------------------ after head

    bool afterHead(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.Comment: insertComment(t); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.Doctype: return true;
            case TokenType.Text:
                insertText(leadingSpace(t));
                if (t.data.length == 0) return true;
                break;
            case TokenType.StartTag:
                switch (t.tag)
                {
                    case Tag.Html: return inBody(t);
                    case Tag.Body:
                        setBody(insertElement(t));
                        framesetOk = false;
                        mode = Mode.InBody;
                        return true;
                    case Tag.Frameset:
                        insertElement(t);
                        mode = Mode.InFrameset;
                        return true;
                    case Tag.Base, Tag.Basefont, Tag.Bgsound, Tag.Link, Tag.Meta, Tag.Noframes, Tag.Script,
                         Tag.Style, Tag.Template, Tag.Title:
                        if (head is null) { failed = true; return true; }
                        push(&head.node);
                        inHead(t);
                        removeFromStack(&head.node);
                        return true;
                    case Tag.Head: return true;
                    default: break;
                }
                break;
            case TokenType.EndTag:
                if (t.tag == Tag.Template) return inHead(t);
                if (t.tag != Tag.Body && t.tag != Tag.Html && t.tag != Tag.Br) return true;
                break;
            default: break;
        }

        setBody(insertImplied(Tag.Body));
        mode = Mode.InBody;
        return false;
    }

    // ------------------------------------------------------------ in body

    bool inBody(ref Token t)
    {
        final switch (t.type)
        {
            case TokenType.Text:
            {
                auto data = cleanText(t, false);
                if (data.length) bodyText(data);
                return true;
            }
            case TokenType.Comment: insertComment(t); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.Doctype: return true;
            case TokenType.Eof:
                if (templateModes.length) return inTemplate(t);
                return true;
            case TokenType.StartTag: return inBodyStart(t);
            case TokenType.EndTag: return inBodyEnd(t);
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
            case Tag.Html:
                if (findInStack(Tag.Template) !is null) return true;
                mergeAttributes(openElements[0].as!DomElement, t);
                return true;

            case Tag.Base, Tag.Basefont, Tag.Bgsound, Tag.Link, Tag.Meta, Tag.Noframes, Tag.Script, Tag.Style,
                 Tag.Template, Tag.Title:
                return inHead(t);

            case Tag.Body:
            {
                if (openElements.length < 2) return true;
                auto n = openElements[1];
                if (!n.isHtml(Tag.Body) || findInStack(Tag.Template) !is null) return true;
                framesetOk = false;
                mergeAttributes(n.as!DomElement, t);
                return true;
            }

            case Tag.Frameset:
            {
                if (openElements.length < 2) return true;
                auto n = openElements[1];
                if (!n.isHtml(Tag.Body) || !framesetOk) return true;
                n.remove();
                while (openElements.length > 1) pop();
                insertElement(t);
                mode = Mode.InFrameset;
                return true;
            }

            case Tag.Address, Tag.Article, Tag.Aside, Tag.Blockquote, Tag.Center, Tag.Details, Tag.Dialog, Tag.Dir,
                 Tag.Div, Tag.Dl, Tag.Fieldset, Tag.Figcaption, Tag.Figure, Tag.Footer, Tag.Header, Tag.Hgroup,
                 Tag.Main, Tag.Menu, Tag.Nav, Tag.Ol, Tag.P, Tag.Search, Tag.Section, Tag.Summary, Tag.Ul:
                closePIfInButtonScope();
                insertElement(t);
                return true;

            case Tag.H1, Tag.H2, Tag.H3, Tag.H4, Tag.H5, Tag.H6:
            {
                closePIfInButtonScope();
                auto n = current();
                if (n.ns == Ns.Html && isHeading(n.name)) pop();
                insertElement(t);
                return true;
            }

            case Tag.Pre, Tag.Listing:
                closePIfInButtonScope();
                insertElement(t);
                skipNewline = true;
                framesetOk = false;
                return true;

            case Tag.Form:
            {
                auto tmpl = findInStack(Tag.Template);
                if (form !is null && tmpl is null) return true;
                closePIfInButtonScope();
                auto e = insertElement(t);
                if (tmpl is null) form = e;
                return true;
            }

            case Tag.Li, Tag.Dd, Tag.Dt:
            {
                framesetOk = false;
                foreach_reverse (i; 0 .. openElements.length)
                {
                    auto n = openElements[i];
                    uint match = Tag.Undef;
                    if (t.tag == Tag.Li) { if (n.isHtml(Tag.Li)) match = Tag.Li; }
                    else if (n.isHtml(Tag.Dd)) match = Tag.Dd;
                    else if (n.isHtml(Tag.Dt)) match = Tag.Dt;

                    if (match != Tag.Undef)
                    {
                        generateImpliedEndTags(match);
                        popUntil(match);
                        break;
                    }

                    if (hasCategory(n, Category.Special) && !n.isHtml(Tag.Address) && !n.isHtml(Tag.Div) && !n.isHtml(Tag.P))
                        break;
                }
                closePIfInButtonScope();
                insertElement(t);
                return true;
            }

            case Tag.Plaintext:
                closePIfInButtonScope();
                insertElement(t);
                tokenizer.switchTo(State.Plaintext);
                return true;

            case Tag.Button:
                if (inScope(Tag.Button, Category.Scope) !is null)
                {
                    generateImpliedEndTags();
                    popUntil(Tag.Button);
                }
                reconstructFormatting();
                insertElement(t);
                framesetOk = false;
                return true;

            case Tag.A:
            {
                if (auto n = afeAfterLastMarker(Tag.A))
                {
                    adoptionAgency(t);
                    removeFromAfe(n);
                    removeFromStack(n);
                }
                reconstructFormatting();
                if (auto e = insertElement(t)) pushFormatting(&e.node);
                return true;
            }

            case Tag.B, Tag.Big, Tag.Code, Tag.Em, Tag.Font, Tag.I, Tag.S, Tag.Small, Tag.Strike, Tag.Strong, Tag.Tt, Tag.U:
                reconstructFormatting();
                if (auto e = insertElement(t)) pushFormatting(&e.node);
                return true;

            case Tag.Nobr:
                reconstructFormatting();
                if (inScope(Tag.Nobr, Category.Scope) !is null)
                {
                    if (adoptionAgency(t)) anyOtherEndTag(t);
                    reconstructFormatting();
                }
                if (auto e = insertElement(t)) pushFormatting(&e.node);
                return true;

            case Tag.Applet, Tag.Marquee, Tag.Object:
                reconstructFormatting();
                insertElement(t);
                pushMarker();
                framesetOk = false;
                return true;

            case Tag.Table:
                if (compatMode != CompatMode.Quirks) closePIfInButtonScope();
                insertElement(t);
                framesetOk = false;
                mode = Mode.InTable;
                return true;

            case Tag.Area, Tag.Br, Tag.Embed, Tag.Img, Tag.Keygen, Tag.Wbr:
                reconstructFormatting();
                if (insertElement(t)) pop();
                framesetOk = false;
                return true;

            case Tag.Input:
            {
                if (context !is null && context.isHtml(Tag.Select)) return true;
                if (auto sel = inScope(Tag.Select, Category.Scope)) popUntilNode(sel);
                reconstructFormatting();
                auto e = insertElement(t);
                if (e is null) return true;
                pop();
                auto type = e.attribute(AttrName.Type);
                if (type is null || type.value != "hidden") framesetOk = false;
                return true;
            }

            case Tag.Param, Tag.Source, Tag.Track:
                if (insertElement(t)) pop();
                return true;

            case Tag.Hr:
                closePIfInButtonScope();
                if (inScope(Tag.Select, Category.Scope) !is null) generateImpliedEndTags();
                if (insertElement(t)) pop();
                framesetOk = false;
                return true;

            case Tag.Image:
                t.tag = Tag.Img;
                t.name = "img";
                return false;

            case Tag.Textarea:
                insertElement(t);
                tokenizer.switchTo(State.Rcdata);
                framesetOk = false;
                skipNewline = true;
                originalMode = mode;
                mode = Mode.Text;
                return true;

            case Tag.Xmp:
                closePIfInButtonScope();
                reconstructFormatting();
                framesetOk = false;
                genericText(t, State.Rawtext);
                return true;

            case Tag.Iframe:
                framesetOk = false;
                genericText(t, State.Rawtext);
                return true;

            case Tag.Noembed:
                genericText(t, State.Rawtext);
                return true;

            case Tag.Noscript:
                if (!doc.scripting) goto default;
                genericText(t, State.Rawtext);
                return true;

            case Tag.Select:
                if (context !is null && context.isHtml(Tag.Select)) return true;
                if (auto sel = inScope(Tag.Select, Category.Scope)) { popUntilNode(sel); return true; }
                reconstructFormatting();
                insertElement(t);
                framesetOk = false;
                return true;

            case Tag.Option:
                if (inScope(Tag.Select, Category.Scope) !is null) generateImpliedEndTags(Tag.Optgroup);
                else if (current().isHtml(Tag.Option)) pop();
                reconstructFormatting();
                insertElement(t);
                return true;

            case Tag.Optgroup:
                if (inScope(Tag.Select, Category.Scope) !is null) generateImpliedEndTags();
                else if (current().isHtml(Tag.Option)) pop();
                reconstructFormatting();
                insertElement(t);
                return true;

            case Tag.Rb, Tag.Rtc:
                if (inScope(Tag.Ruby, Category.Scope) !is null) generateImpliedEndTags();
                insertElement(t);
                return true;

            case Tag.Rp, Tag.Rt:
                if (inScope(Tag.Ruby, Category.Scope) !is null) generateImpliedEndTags(Tag.Rtc);
                insertElement(t);
                return true;

            case Tag.Math, Tag.Svg:
                reconstructFormatting();
                if (insertForeign(t, t.tag == Tag.Math ? Ns.Math : Ns.Svg) && t.selfClosing) pop();
                return true;

            case Tag.Caption, Tag.Col, Tag.Colgroup, Tag.Frame, Tag.Head, Tag.Tbody, Tag.Td, Tag.Tfoot, Tag.Th,
                 Tag.Thead, Tag.Tr:
                return true;

            default:
                reconstructFormatting();
                insertElement(t);
                return true;
        }
    }

    // Add the attributes that the element doesn't have (<html> and <body> seen again)
    void mergeAttributes(DomElement* e, ref Token t)
    {
        foreach (ref a; t.attributes)
        {
            auto id = doc.attrId(a.name);
            if (id == 0) { failed = true; return; }

            bool exists = false;
            for (auto x = e.firstAttr; x !is null; x = x.next)
                if (x.name == id && (x.ns == Ns.None || x.ns == e.ns)) { exists = true; break; }
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
            case Tag.Template: return inHead(t);

            case Tag.Body:
                if (inScope(Tag.Body, Category.Scope) is null) return true;
                mode = Mode.AfterBody;
                return true;

            case Tag.Html:
                if (inScope(Tag.Body, Category.Scope) is null) return true;
                mode = Mode.AfterBody;
                return false;

            case Tag.Address, Tag.Article, Tag.Aside, Tag.Blockquote, Tag.Button, Tag.Center, Tag.Details, Tag.Dialog,
                 Tag.Dir, Tag.Div, Tag.Dl, Tag.Fieldset, Tag.Figcaption, Tag.Figure, Tag.Footer, Tag.Header, Tag.Hgroup,
                 Tag.Listing, Tag.Main, Tag.Menu, Tag.Nav, Tag.Ol, Tag.Pre, Tag.Search, Tag.Section, Tag.Select,
                 Tag.Summary, Tag.Ul:
                if (inScope(t.tag, Category.Scope) is null) return true;
                generateImpliedEndTags();
                popUntil(t.tag);
                return true;

            case Tag.Form:
            {
                if (findInStack(Tag.Template) is null)
                {
                    DomNode* node = form is null ? null : &form.node;
                    form = null;
                    if (node is null || inScopeNode(node, Category.Scope) is null) return true;
                    generateImpliedEndTags();
                    removeFromStack(node);
                    return true;
                }

                if (inScope(Tag.Form, Category.Scope) is null) return true;
                generateImpliedEndTags();
                popUntil(Tag.Form);
                return true;
            }

            case Tag.P:
                if (inScope(Tag.P, Category.ScopeButton) is null) insertImplied(Tag.P);
                closePElement();
                return true;

            case Tag.Li:
                if (inScope(Tag.Li, Category.ScopeListItem) is null) return true;
                generateImpliedEndTags(Tag.Li);
                popUntil(Tag.Li);
                return true;

            case Tag.Dd, Tag.Dt:
                if (inScope(t.tag, Category.Scope) is null) return true;
                generateImpliedEndTags(t.tag);
                popUntil(t.tag);
                return true;

            case Tag.H1, Tag.H2, Tag.H3, Tag.H4, Tag.H5, Tag.H6:
                if (headingInScope() is null) return true;
                generateImpliedEndTags();
                popUntilHeading();
                return true;

            case Tag.A, Tag.B, Tag.Big, Tag.Code, Tag.Em, Tag.Font, Tag.I, Tag.Nobr, Tag.S, Tag.Small, Tag.Strike,
                 Tag.Strong, Tag.Tt, Tag.U:
                if (adoptionAgency(t)) anyOtherEndTag(t);
                return true;

            case Tag.Applet, Tag.Marquee, Tag.Object:
                if (inScope(t.tag, Category.Scope) is null) return true;
                generateImpliedEndTags();
                popUntil(t.tag);
                clearToLastMarker();
                return true;

            case Tag.Br:
                // </br> is <br>
                t.type = TokenType.StartTag;
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
            if (hasCategory(n, Category.Special)) return;
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
            DomNode* formatting = null;
            foreach_reverse (i; 0 .. activeFormatting.length)
            {
                auto n = activeFormatting[i];
                if (n is null) return true;
                if (n.name == subject) { formattingIndex = i; formatting = n; break; }
            }
            if (formatting is null) return true;

            size_t stackIdx;
            if (!stackIndex(formatting, stackIdx)) { removeFromAfe(formatting); return false; }
            if (inScopeNode(formatting, Category.Scope) is null) return false;

            // The furthest block: the topmost special element after the formatting element
            DomNode* furthestBlock = null;
            size_t furthestIdx = 0;
            foreach (i; stackIdx .. openElements.length)
            {
                if (hasCategory(openElements[i], Category.Special)) { furthestBlock = openElements[i]; furthestIdx = i; break; }
            }

            if (furthestBlock is null)
            {
                popUntilNode(formatting);
                removeFromAfe(formatting);
                return false;
            }

            auto commonAncestor = openElements[stackIdx - 1];
            size_t bookmark = formattingIndex;
            DomNode* last = furthestBlock;
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

                auto e = cloneForFormatting(node.as!DomElement);
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

            auto e = cloneForFormatting(formatting.as!DomElement);
            if (e is null) return false;

            furthestBlock.moveChildrenTo(&e.node);
            furthestBlock.appendChild(&e.node);

            removeAfeAt(formattingIndex);
            if (bookmark > activeFormatting.length) bookmark = activeFormatting.length;
            insertAfeAt(bookmark, &e.node);

            removeFromStack(formatting);
            stackIndex(furthestBlock, furthestIdx);

            // Insert after the furthest block
            openElements.put(cast(DomNode*) null);
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
            case TokenType.Text:
                insertText(t.data);
                return true;
            case TokenType.Eof:
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
        return n.ns == Ns.Html && (n.name == Tag.Table || n.name == Tag.Tbody || n.name == Tag.Tfoot || n.name == Tag.Thead || n.name == Tag.Tr);
    }

    bool inTable(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.Text:
                if (currentIsTableContext())
                {
                    pendingText.clear();
                    pendingNonSpace = false;
                    originalMode = mode;
                    mode = Mode.InTableText;
                    return false;
                }
                return tableAnythingElse(t);

            case TokenType.Comment: insertComment(t); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.Doctype: return true;
            case TokenType.Eof: return inBody(t);

            case TokenType.StartTag:
                switch (t.tag)
                {
                    case Tag.Caption:
                        clearToTableContext();
                        pushMarker();
                        insertElement(t);
                        mode = Mode.InCaption;
                        return true;
                    case Tag.Colgroup:
                        clearToTableContext();
                        insertElement(t);
                        mode = Mode.InColumnGroup;
                        return true;
                    case Tag.Col:
                        clearToTableContext();
                        insertImplied(Tag.Colgroup);
                        mode = Mode.InColumnGroup;
                        return false;
                    case Tag.Tbody, Tag.Tfoot, Tag.Thead:
                        clearToTableContext();
                        insertElement(t);
                        mode = Mode.InTableBody;
                        return true;
                    case Tag.Td, Tag.Th, Tag.Tr:
                        clearToTableContext();
                        insertImplied(Tag.Tbody);
                        mode = Mode.InTableBody;
                        return false;
                    case Tag.Table:
                    {
                        auto n = inScope(Tag.Table, Category.ScopeTable);
                        if (n is null) return true;
                        popUntilNode(n);
                        resetInsertionMode();
                        return false;
                    }
                    case Tag.Style, Tag.Script, Tag.Template: return inHead(t);
                    case Tag.Input:
                    {
                        bool hidden = false;
                        foreach (ref a; t.attributes)
                            if (a.name == "type") { hidden = equalsCi(a.value, "hidden"); break; }
                        if (!hidden) return tableAnythingElse(t);
                        auto e = insertElement(t);
                        if (e !is null) popUntilNode(&e.node);
                        return true;
                    }
                    case Tag.Form:
                    {
                        if (form !is null || findInStack(Tag.Template) !is null) return true;
                        auto e = insertElement(t);
                        if (e is null) return true;
                        form = e;
                        popUntilNode(&e.node);
                        return true;
                    }
                    default: return tableAnythingElse(t);
                }

            case TokenType.EndTag:
                switch (t.tag)
                {
                    case Tag.Table:
                    {
                        auto n = inScope(Tag.Table, Category.ScopeTable);
                        if (n is null) return true;
                        popUntilNode(n);
                        resetInsertionMode();
                        return true;
                    }
                    case Tag.Body, Tag.Caption, Tag.Col, Tag.Colgroup, Tag.Html, Tag.Tbody, Tag.Td, Tag.Tfoot, Tag.Th,
                         Tag.Thead, Tag.Tr:
                        return true;
                    case Tag.Template: return inHead(t);
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
        if (t.type == TokenType.Text)
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
        if (t.type == TokenType.EndTag)
        {
            switch (t.tag)
            {
                case Tag.Caption: closeCaption(); return true;
                case Tag.Table: return !closeCaption();
                case Tag.Body, Tag.Col, Tag.Colgroup, Tag.Html, Tag.Tbody, Tag.Td, Tag.Tfoot, Tag.Th, Tag.Thead, Tag.Tr:
                    return true;
                default: return inBody(t);
            }
        }

        if (t.type == TokenType.StartTag)
        {
            switch (t.tag)
            {
                case Tag.Caption, Tag.Col, Tag.Colgroup, Tag.Tbody, Tag.Td, Tag.Tfoot, Tag.Th, Tag.Thead, Tag.Tr:
                    return !closeCaption();
                default: break;
            }
        }

        return inBody(t);
    }

    // It returns true if the caption was closed
    bool closeCaption()
    {
        if (inScope(Tag.Caption, Category.ScopeTable) is null) return false;
        generateImpliedEndTags();
        popUntil(Tag.Caption);
        clearToLastMarker();
        mode = Mode.InTable;
        return true;
    }

    bool inColumnGroup(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.Text:
                insertText(leadingSpace(t));
                if (t.data.length == 0) return true;
                break;
            case TokenType.Comment: insertComment(t); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.Doctype: return true;
            case TokenType.Eof: return inBody(t);
            case TokenType.StartTag:
                switch (t.tag)
                {
                    case Tag.Html: return inBody(t);
                    case Tag.Col:
                        if (insertElement(t)) pop();
                        return true;
                    case Tag.Template: return inHead(t);
                    default: break;
                }
                break;
            case TokenType.EndTag:
                switch (t.tag)
                {
                    case Tag.Colgroup:
                        if (!current().isHtml(Tag.Colgroup)) return true;
                        pop();
                        mode = Mode.InTable;
                        return true;
                    case Tag.Col: return true;
                    case Tag.Template: return inHead(t);
                    default: break;
                }
                break;
            default: break;
        }

        if (!current().isHtml(Tag.Colgroup)) return true;
        pop();
        mode = Mode.InTable;
        return false;
    }

    bool inTableBody(ref Token t)
    {
        if (t.type == TokenType.StartTag)
        {
            switch (t.tag)
            {
                case Tag.Tr:
                    clearToTableBodyContext();
                    insertElement(t);
                    mode = Mode.InRow;
                    return true;
                case Tag.Th, Tag.Td:
                    clearToTableBodyContext();
                    insertImplied(Tag.Tr);
                    mode = Mode.InRow;
                    return false;
                case Tag.Caption, Tag.Col, Tag.Colgroup, Tag.Tbody, Tag.Tfoot, Tag.Thead:
                    if (tableSectionInScope() is null) return true;
                    clearToTableBodyContext();
                    pop();
                    mode = Mode.InTable;
                    return false;
                default: break;
            }
        }
        else if (t.type == TokenType.EndTag)
        {
            switch (t.tag)
            {
                case Tag.Tbody, Tag.Tfoot, Tag.Thead:
                    if (inScope(t.tag, Category.ScopeTable) is null) return true;
                    clearToTableBodyContext();
                    pop();
                    mode = Mode.InTable;
                    return true;
                case Tag.Table:
                    if (tableSectionInScope() is null) return true;
                    clearToTableBodyContext();
                    pop();
                    mode = Mode.InTable;
                    return false;
                case Tag.Body, Tag.Caption, Tag.Col, Tag.Colgroup, Tag.Html, Tag.Td, Tag.Th, Tag.Tr:
                    return true;
                default: break;
            }
        }

        return inTable(t);
    }

    bool inRow(ref Token t)
    {
        if (t.type == TokenType.StartTag)
        {
            switch (t.tag)
            {
                case Tag.Th, Tag.Td:
                    clearToTableRowContext();
                    insertElement(t);
                    mode = Mode.InCell;
                    pushMarker();
                    return true;
                case Tag.Caption, Tag.Col, Tag.Colgroup, Tag.Tbody, Tag.Tfoot, Tag.Thead, Tag.Tr:
                    if (inScope(Tag.Tr, Category.ScopeTable) is null) return true;
                    clearToTableRowContext();
                    pop();
                    mode = Mode.InTableBody;
                    return false;
                default: break;
            }
        }
        else if (t.type == TokenType.EndTag)
        {
            switch (t.tag)
            {
                case Tag.Tr:
                    if (inScope(Tag.Tr, Category.ScopeTable) is null) return true;
                    clearToTableRowContext();
                    pop();
                    mode = Mode.InTableBody;
                    return true;
                case Tag.Table:
                    if (inScope(Tag.Tr, Category.ScopeTable) is null) return true;
                    clearToTableRowContext();
                    pop();
                    mode = Mode.InTableBody;
                    return false;
                case Tag.Tbody, Tag.Tfoot, Tag.Thead:
                    if (inScope(t.tag, Category.ScopeTable) is null) return true;
                    if (inScope(Tag.Tr, Category.ScopeTable) is null) return true;
                    clearToTableRowContext();
                    pop();
                    mode = Mode.InTableBody;
                    return false;
                case Tag.Body, Tag.Caption, Tag.Col, Tag.Colgroup, Tag.Html, Tag.Td, Tag.Th:
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
        mode = Mode.InRow;
    }

    bool inCell(ref Token t)
    {
        if (t.type == TokenType.EndTag)
        {
            switch (t.tag)
            {
                case Tag.Td, Tag.Th:
                    if (inScope(t.tag, Category.ScopeTable) is null) return true;
                    generateImpliedEndTags();
                    popUntil(t.tag);
                    clearToLastMarker();
                    mode = Mode.InRow;
                    return true;
                case Tag.Body, Tag.Caption, Tag.Col, Tag.Colgroup, Tag.Html:
                    return true;
                case Tag.Table, Tag.Tbody, Tag.Tfoot, Tag.Thead, Tag.Tr:
                    if (inScope(t.tag, Category.ScopeTable) is null) return true;
                    closeCell();
                    return false;
                default: return inBody(t);
            }
        }

        if (t.type == TokenType.StartTag)
        {
            switch (t.tag)
            {
                case Tag.Caption, Tag.Col, Tag.Colgroup, Tag.Tbody, Tag.Td, Tag.Tfoot, Tag.Th, Tag.Thead, Tag.Tr:
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
        if (templateModes.length) templateModes.removeLast();
        templateModes.put(m);
        mode = m;
    }

    bool inTemplate(ref Token t)
    {
        final switch (t.type)
        {
            case TokenType.Text, TokenType.Comment, TokenType.ProcessingInstruction, TokenType.Doctype:
                return inBody(t);

            case TokenType.EndTag:
                if (t.tag == Tag.Template) return inHead(t);
                return true;

            case TokenType.Eof:
                if (findInStack(Tag.Template) is null) return true;
                popUntil(Tag.Template);
                clearToLastMarker();
                if (templateModes.length) templateModes.removeLast();
                resetInsertionMode();
                return false;

            case TokenType.StartTag:
                switch (t.tag)
                {
                    case Tag.Base, Tag.Basefont, Tag.Bgsound, Tag.Link, Tag.Meta, Tag.Noframes, Tag.Script, Tag.Style,
                         Tag.Template, Tag.Title:
                        return inHead(t);
                    case Tag.Caption, Tag.Colgroup, Tag.Tbody, Tag.Tfoot, Tag.Thead:
                        switchTemplateMode(Mode.InTable); return false;
                    case Tag.Col: switchTemplateMode(Mode.InColumnGroup); return false;
                    case Tag.Tr: switchTemplateMode(Mode.InTableBody); return false;
                    case Tag.Td, Tag.Th: switchTemplateMode(Mode.InRow); return false;
                    default: switchTemplateMode(Mode.InBody); return false;
                }
        }
    }

    // ------------------------------------------------------------ after body, frameset

    bool afterBody(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.Comment: insertComment(t, openElements[0]); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t, openElements[0]); return true;
            case TokenType.Doctype: return true;
            case TokenType.Eof: return true;
            case TokenType.Text:
                if (allSpace(t.data)) return inBody(t);
                break;
            case TokenType.StartTag:
                if (t.tag == Tag.Html) return inBody(t);
                break;
            case TokenType.EndTag:
                if (t.tag == Tag.Html)
                {
                    if (context is null) mode = Mode.AfterAfterBody;
                    return true;
                }
                break;
            default: break;
        }

        mode = Mode.InBody;
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
            case TokenType.Comment: insertComment(t); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.Doctype: return true;
            case TokenType.Eof: return true;
            case TokenType.Text: framesetText(t); return true;
            case TokenType.StartTag:
                switch (t.tag)
                {
                    case Tag.Html: return inBody(t);
                    case Tag.Frameset: insertElement(t); return true;
                    case Tag.Frame: if (insertElement(t)) pop(); return true;
                    case Tag.Noframes: return inHead(t);
                    default: return true;
                }
            case TokenType.EndTag:
                if (t.tag == Tag.Frameset)
                {
                    if (current() is openElements[0]) return true;
                    pop();
                    if (context is null && !current().isHtml(Tag.Frameset)) mode = Mode.AfterFrameset;
                }
                return true;
            default: return true;
        }
    }

    bool afterFrameset(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.Comment: insertComment(t); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.Text: framesetText(t); return true;
            case TokenType.StartTag:
                if (t.tag == Tag.Html) return inBody(t);
                if (t.tag == Tag.Noframes) return inHead(t);
                return true;
            case TokenType.EndTag:
                if (t.tag == Tag.Html) mode = Mode.AfterAfterFrameset;
                return true;
            default: return true;
        }
    }

    bool afterAfterBody(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.Comment: insertComment(t, &doc.node); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t, &doc.node); return true;
            case TokenType.Doctype: return inBody(t);
            case TokenType.Eof: return true;
            case TokenType.Text:
                if (allSpace(t.data)) return inBody(t);
                break;
            case TokenType.StartTag:
                if (t.tag == Tag.Html) return inBody(t);
                break;
            default: break;
        }

        mode = Mode.InBody;
        return false;
    }

    bool afterAfterFrameset(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.Comment: insertComment(t, &doc.node); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t, &doc.node); return true;
            case TokenType.Doctype: return inBody(t);
            case TokenType.Eof: return true;
            case TokenType.Text:
                if (allSpace(t.data)) return inBody(t);
                return true;
            case TokenType.StartTag:
                if (t.tag == Tag.Html) return inBody(t);
                if (t.tag == Tag.Noframes) return inHead(t);
                return true;
            default: return true;
        }
    }

    // ------------------------------------------------------------ foreign content

    bool foreignContent(ref Token t)
    {
        switch (t.type)
        {
            case TokenType.Text:
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
            case TokenType.Comment: insertComment(t); return true;
            case TokenType.ProcessingInstruction: insertProcessingInstruction(t); return true;
            case TokenType.Doctype: return true;

            case TokenType.StartTag:
                switch (t.tag)
                {
                    case Tag.B, Tag.Big, Tag.Blockquote, Tag.Body, Tag.Br, Tag.Center, Tag.Code, Tag.Dd, Tag.Div, Tag.Dl,
                         Tag.Dt, Tag.Em, Tag.Embed, Tag.H1, Tag.H2, Tag.H3, Tag.H4, Tag.H5, Tag.H6, Tag.Head, Tag.Hr, Tag.I,
                         Tag.Img, Tag.Li, Tag.Listing, Tag.Menu, Tag.Meta, Tag.Nobr, Tag.Ol, Tag.P, Tag.Pre, Tag.Ruby, Tag.S,
                         Tag.Small, Tag.Span, Tag.Strong, Tag.Strike, Tag.Sub, Tag.Table, Tag.Tt, Tag.U, Tag.Ul, Tag.Var:
                        return breakOutOfForeign(t);
                    case Tag.Font:
                        foreach (ref a; t.attributes)
                            if (a.name == "color" || a.name == "face" || a.name == "size") return breakOutOfForeign(t);
                        return foreignStartTag(t);
                    default:
                        return foreignStartTag(t);
                }

            case TokenType.EndTag:
                if (t.tag == Tag.P || t.tag == Tag.Br) return breakOutOfForeign(t);
                if (t.tag == Tag.Script)
                {
                    auto n = current();
                    if (n.name == Tag.Script && n.ns == Ns.Svg) { pop(); return true; }
                }
                return foreignEndTag(t);

            default: return true;
        }
    }

    // Pop the foreign elements and process the token as html
    bool breakOutOfForeign(ref Token t)
    {
        auto n = current();
        while (n !is null && !(mathTextIntegrationPoint(n) || htmlIntegrationPoint(n) || n.ns == Ns.Html))
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

        if (ns == Ns.Svg)
            if (auto fixed = svgTagName(e.name)) e.qualifiedName = fixed;

        if (!t.selfClosing) return true;

        if (t.tag == Tag.Script && current().ns == Ns.Svg) { pop(); return true; }
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
            if (openElements[idx].ns == Ns.Html) break;
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
        case Tag.Altglyph: return "altGlyph";
        case Tag.Altglyphdef: return "altGlyphDef";
        case Tag.Altglyphitem: return "altGlyphItem";
        case Tag.Animatecolor: return "animateColor";
        case Tag.Animatemotion: return "animateMotion";
        case Tag.Animatetransform: return "animateTransform";
        case Tag.Clippath: return "clipPath";
        case Tag.Feblend: return "feBlend";
        case Tag.Fecolormatrix: return "feColorMatrix";
        case Tag.Fecomponenttransfer: return "feComponentTransfer";
        case Tag.Fecomposite: return "feComposite";
        case Tag.Feconvolvematrix: return "feConvolveMatrix";
        case Tag.Fediffuselighting: return "feDiffuseLighting";
        case Tag.Fedisplacementmap: return "feDisplacementMap";
        case Tag.Fedistantlight: return "feDistantLight";
        case Tag.Fedropshadow: return "feDropShadow";
        case Tag.Feflood: return "feFlood";
        case Tag.Fefunca: return "feFuncA";
        case Tag.Fefuncb: return "feFuncB";
        case Tag.Fefuncg: return "feFuncG";
        case Tag.Fefuncr: return "feFuncR";
        case Tag.Fegaussianblur: return "feGaussianBlur";
        case Tag.Feimage: return "feImage";
        case Tag.Femerge: return "feMerge";
        case Tag.Femergenode: return "feMergeNode";
        case Tag.Femorphology: return "feMorphology";
        case Tag.Feoffset: return "feOffset";
        case Tag.Fepointlight: return "fePointLight";
        case Tag.Fespecularlighting: return "feSpecularLighting";
        case Tag.Fespotlight: return "feSpotLight";
        case Tag.Fetile: return "feTile";
        case Tag.Feturbulence: return "feTurbulence";
        case Tag.Foreignobject: return "foreignObject";
        case Tag.Glyphref: return "glyphRef";
        case Tag.Lineargradient: return "linearGradient";
        case Tag.Radialgradient: return "radialGradient";
        case Tag.Textpath: return "textPath";
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
    ForeignAttribute("xlink:actuate", "xlink", "actuate", Ns.Xlink),
    ForeignAttribute("xlink:arcrole", "xlink", "arcrole", Ns.Xlink),
    ForeignAttribute("xlink:href", "xlink", "href", Ns.Xlink),
    ForeignAttribute("xlink:role", "xlink", "role", Ns.Xlink),
    ForeignAttribute("xlink:show", "xlink", "show", Ns.Xlink),
    ForeignAttribute("xlink:title", "xlink", "title", Ns.Xlink),
    ForeignAttribute("xlink:type", "xlink", "type", Ns.Xlink),
    ForeignAttribute("xml:lang", "xml", "lang", Ns.Xml),
    ForeignAttribute("xml:space", "xml", "space", Ns.Xml),
    ForeignAttribute("xmlns", "", "xmlns", Ns.Xmlns),
    ForeignAttribute("xmlns:xlink", "xmlns", "xlink", Ns.Xmlns),
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
