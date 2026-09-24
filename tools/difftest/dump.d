/+ dub.sdl:
    name "dump"
    dependency "parserino" path="../.."
+/
/++
 Dumps everything the public API can observe on each file (serialization, queries,
 selectors, mutations, fragments). Used as an oracle while refactoring the internals:
 the dump of the new code must be identical to the dump of the reference commit.

 Usage: dump files... > out.txt
+/
module dump;

import parserino;
import std.stdio, std.file, std.algorithm, std.array, std.conv, std.range, std.path, std.format;

enum string[] selectors = [
    "*", "p", "div p", "div > p", "a + b", "p ~ p", "#main", ".mw-body", "a[href]",
    "a[href^=\"http\"]", "a[href$=\".html\"]", "a[href*=\"wiki\"]", "[class~=\"a\"]",
    "[lang|=\"en\"]", "[type=\"text\" i]", "li:first-child", "li:last-child", "li:only-child",
    "tr:nth-child(2n+1)", "tr:nth-child(odd)", "td:nth-last-child(2)", "p:nth-of-type(2)",
    "p:nth-last-of-type(1)", "span:first-of-type", "span:last-of-type", "b:only-of-type",
    "p:empty", ":root", "div:not(.x)", "a:not([href])", "div:has(> p)", "div:has(a)",
    ":is(h1, h2, h3)", ":where(ul, ol) li", "li:nth-child(2 of .x)", "input:checked",
    "input:disabled", "input:enabled", "option:checked", "p:lang(en)", "html body div",
    "body > *", "table tr td", "head title", "script", "meta[charset]", "link[rel=\"stylesheet\"]",
    "h1, h2, h3, h4, h5, h6", "ul li a", "div.a.b", "div#x.y", "::before", "p::first-line",
    "a:hover", "*|*", "svg|rect", "img[alt=\"\"]", "[data-x]", "div:nth-child(-n+3)",
    ":first-child:last-child", "a:any-link", "a:link", "p:lexbor-contains(x)", "1bad", "a[", "div >",
    ":nth-child(", "p:nth-child(n)", "p:nth-child(0n+0)", "span:nth-child(3n-1)",
    "A[HREF]", "DIV", "[id=main]", "[class=\"a b\"]", "p:not(:first-child)", "td:has(+ td)",
    "b:blank", "input:read-only", "input:read-write", "input:required", "input:optional",
    "input:placeholder-shown", ":not(*)", "div, div", "a:is(.x, [href])", "li:nth-last-child(odd of .y)",
    "p:first-line", "svg rect", "math mi", "tbody > tr", "select option", "a[href|=\"x\"]",
    "[title~=\"\"]", "[x=\"a\\\"b\"]", "\\64 iv", "#\\31 23", ".\\.x",
];

// The name printed by the old API: lowercase tag, "#text", "!--", "!doctype", PI target
string oldName(Node n)
{
    import std.uni : toLower;
    switch (n.nodeType)
    {
        case NodeType.Element: return n.asElement.localName.toLower;
        case NodeType.Comment: return "!--";
        case NodeType.DocumentType: return "!doctype";
        default: return n.nodeName;
    }
}

string ident(Node e)
{
    size_t[] path;
    for (auto n = e; n.isValid; )
    {
        size_t i = 0;
        for (auto p = n.previousSibling!(Show.All); p.isValid; p = p.previousSibling!(Show.All)) i++;
        path ~= i;
        auto par = n.parent!(Show.All);
        if (!par.isValid) break;
        n = par;
    }
    return format("%(%s.%) %s", path.retro, e.isElement ? e.asElement.startTag : e.toString);
}

string summary(string[] items)
{
    return format("%s %s %s", items.length, hashOf(items.join("\x01")), items.take(3).join(" | ").replace("\n", "\\n").take(300));
}

string tryIt(lazy string s)
{
    try return s;
    catch (Exception e) return "EXC " ~ typeid(e).name;
}

void main(string[] args)
{
    foreach (fname; args[1 .. $].sort)
    {
        auto html = cast(string) read(fname);
        writeln("=== ", fname.baseName);

        auto doc = Document(html);
        auto full = doc.toString;
        writeln("doc ", full.length, " ", hashOf(full));
        if (full.length < 3000) writeln(full);
        writeln("title [", doc.title, "] raw [", doc.rawTitle, "]");
        writeln("body ", tryIt(doc.body.isValid ? hashOf(doc.body.textContent).to!string ~ " " ~ hashOf(doc.body.innerHTML).to!string : "none"));
        writeln("head ", tryIt(doc.head.isValid ? hashOf(doc.head.outerHTML).to!string : "none"));

        auto all = doc.descendants!(Show.All).map!ident.array;
        writeln("all ", summary(all));

        foreach (t; ["a", "p", "td", "b", "div", "html", "body", "title", "!--", "#text", "svg", "select", "template", "X-Y"])
        {
            string[] found = t == "!--" ? doc.descendants!(Show.Comment).map!ident.array
                : t == "#text" ? doc.descendants!(Show.Text).map!ident.array
                : doc.byTagName(t).map!(e => ident(e)).array;
            writeln("tag ", t, " ", summary(found));
        }

        auto classes = doc.descendants.map!(e => e.classes.array).joiner.array.sort.uniq.take(10).array;
        foreach (c; classes)
            writeln("class ", c, " ", summary(doc.byClass(c).map!ident.array));

        auto ids = doc.descendants.map!(e => e.id).filter!(x => x.length).take(5).array;
        foreach (i; ids)
            writeln("id ", i, " ", tryIt(ident(doc.byId(i).node)));

        foreach (s; selectors)
            writeln("sel ", s, " ", tryIt(summary(doc.bySelector(s).map!(e => ident(e)).array)));

        // matches() on the first elements
        foreach (e; doc.descendants.take(30))
        {
            string bits;
            foreach (s; selectors) bits ~= tryIt(e.matches(s) ? "1" : "0")[0];
            writeln("match ", ident(e).take(80), " ", bits);
        }

        // attributes, texts, outerHTML of the first elements
        foreach (n; doc.descendants!(Show.All).take(40))
        {
            if (n.isElement)
            {
                auto e = n.asElement;
                writeln("el ", oldName(e), " ", e.attributes.map!(a => a.name ~ "=" ~ a.value).join(" ").take(200),
                    " inner ", hashOf(e.innerHTML), " text ", hashOf(e.textContent), " empty ", e.isBlank,
                    " fc ", e.firstChild.isValid ? oldName(e.firstChild) : "-",
                    " lc ", e.lastChild!(Show.All).isValid ? oldName(e.lastChild!(Show.All)) : "-",
                    " nx ", e.nextSibling.isValid ? oldName(e.nextSibling) : "-");
            }
            else
                writeln("node ", oldName(n), " ", hashOf(n.textContent));
        }

        // fragment parsing, innerHTML
        writeln("fragment ", tryIt(hashOf("<html>" ~ doc.fragment(html, "div").toString ~ "</html>").to!string));
        {
            auto d2 = Document("<html><body>");
            d2.body.innerHTML = html;
            writeln("innerhtml ", hashOf(d2.toString));
        }

        // mutations
        {
            auto d = Document(html);
            auto first = d.body.isValid ? d.body.firstChild : Element.init;
            if (first.isValid && first.localName != "template")
            {
                auto c = first.dup;
                c.setAttribute("data-t", "v");
                first.after(c);
                c.textContent = "<x>";
                first.before("text&");
                first.append(d.fragment("<i>frag</i>", "div"));
                auto shallow = first.shallowDup;
                d.body.prepend(shallow);
                first.remove();
                writeln("mutate ", hashOf(d.toString));
                if (d.body.lastChild.isValid) { d.body.lastChild.outerHTML = "<p>o</p><p>p</p>"; writeln("outer ", hashOf(d.toString)); }
                if (d.body.firstChild.isValid) { d.body.firstChild.copyFrom(d.body.lastChild); writeln("copy ", hashOf(d.toString)); }
            }
            d.title = "T&<";
            writeln("titleset ", hashOf(d.toString));
            foreach (e; d.bySelector("*").take(20).array) e.removeAttribute("class");
            writeln("rmattr ", hashOf(d.toString));
        }
    }
}
