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

string ident(Element e)
{
    size_t[] path;
    for (auto n = e; n.isValid; )
    {
        size_t i = 0;
        for (auto p = n.prev(true); p.isValid; p = p.prev(true)) i++;
        path ~= i;
        auto par = n.parent;
        if (!par.isValid) break;
        n = par;
    }
    return format("%(%s.%) %s", path.retro, e.toString(false));
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
        writeln("body ", tryIt(doc.body.isValid ? hashOf(doc.body.innerText).to!string ~ " " ~ hashOf(doc.body.innerHTML).to!string : "none"));
        writeln("head ", tryIt(doc.head.isValid ? hashOf(doc.head.outerHTML).to!string : "none"));

        auto all = doc.descendants(true).map!ident.array;
        writeln("all ", summary(all));

        foreach (t; ["a", "p", "td", "b", "div", "html", "body", "title", "!--", "#text", "svg", "select", "template", "X-Y"])
            writeln("tag ", t, " ", summary(doc.byTagName(t).map!ident.array));

        auto classes = doc.descendants.map!(e => e.classes.array).joiner.array.sort.uniq.take(10).array;
        foreach (c; classes)
            writeln("class ", c, " ", summary(doc.byClass(c).map!ident.array));

        auto ids = doc.descendants.map!(e => e.id).filter!(x => x.length).take(5).array;
        foreach (i; ids)
            writeln("id ", i, " ", tryIt(ident(doc.byId(i))));

        foreach (s; selectors)
            writeln("sel ", s, " ", tryIt(summary(doc.bySelector(s).map!ident.array)));

        // matches() on the first elements
        foreach (e; doc.descendants.take(30))
        {
            string bits;
            foreach (s; selectors) bits ~= tryIt(e.matches(s) ? "1" : "0")[0];
            writeln("match ", ident(e).take(80), " ", bits);
        }

        // attributes, texts, outerHTML of the first elements
        foreach (e; doc.descendants(true).take(40))
        {
            if (e.isElement)
                writeln("el ", e.name, " ", e.attributes.map!(a => a.name ~ "=" ~ a.value).join(" ").take(200),
                    " inner ", hashOf(e.innerHTML), " text ", hashOf(e.innerText), " empty ", e.isEmpty,
                    " fc ", e.firstChild.isValid ? e.firstChild.name : "-", " lc ", e.lastChild(true).isValid ? e.lastChild(true).name : "-",
                    " nx ", e.next.isValid ? e.next.name : "-");
            else
                writeln("node ", e.name, " ", hashOf(e.innerText));
        }

        // fragment parsing, innerHTML
        writeln("fragment ", tryIt(hashOf(doc.fragment(html).toString).to!string));
        {
            auto d2 = Document("<html><body>");
            d2.body.innerHTML = html;
            writeln("innerhtml ", hashOf(d2.toString));
        }

        // mutations
        {
            auto d = Document(html);
            auto first = d.body.isValid ? d.body.firstChild : Element.init;
            if (first.isValid && first.name != "template")
            {
                auto c = first.dup;
                c.setAttribute("data-t", "v");
                first.appendSibling(c);
                c.innerText = "<x>";
                first.prependSibling("text&");
                first.appendChild("<i>frag</i>".asFragment);
                auto shallow = first.dup(false);
                d.body.prependChild(shallow);
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
