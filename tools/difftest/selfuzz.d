/+ dub.sdl:
    name "selfuzz"
    dependency "parserino" path="../.."
+/
/++
 Selector oracle: compiles thousands of generated selectors (valid and invalid)
 and prints what they match on a few documents. Compare the output of two builds.
+/
module selfuzz;

import parserino;
import std.stdio, std.file, std.algorithm, std.array, std.conv, std.range, std.random, std.format;

enum string[] simples = [
    "*", "div", "p", "DIV", "span", "li", "a", "b", "i", "td", "tr", "input", "option", "svg|rect", "|p", "*|p", "a|*", "rect", "x-y", "svg", "math",
    "#main", "#x", "#1x", "#MAIN", ".a", ".A", ".b", ".\\61", ".x", ".y", "[href]", "[HREF]", "[id=x]", "[class~=a]", "[lang|=en]",
    "[href^='http']", "[href$=\".html\"]", "[title*=o]", "[type=TEXT]", "[type=text i]", "[type=text s]", "[x=\"\"]",
    "[class^=a]", "[class*=\"\"]", "[class$=b]", "[data-x]", "[svg|href]", "[|href]", "[title = \"o k\"]", "[ lang |= en ]",
    ":first-child", ":last-child", ":only-child", ":first-of-type", ":last-of-type", ":only-of-type", ":empty", ":blank",
    ":root", ":checked", ":disabled", ":enabled", ":link", ":any-link", ":hover", ":focus", ":active", ":required",
    ":optional", ":read-only", ":read-write", ":placeholder-shown", ":visited", ":scope", ":default",
    ":nth-child(2n+1)", ":nth-child(odd)", ":nth-child(even)", ":nth-child(-n+2)", ":nth-child(3)", ":nth-child( 2n - 1 )",
    ":nth-child(n)", ":nth-child(+n)", ":nth-child(-2n+5)", ":nth-child(0n+1)", ":nth-child(1 of .a)", ":nth-child(2n of p, .b)",
    ":nth-last-child(2)", ":nth-last-child(odd of .y)", ":nth-of-type(2n)", ":nth-of-type(1)", ":nth-last-of-type(1)", ":nth-child(-n-1)",
    ":not(.a)", ":not(p, div)", ":not(:first-child)", ":not(div p)", ":is(p, .a)", ":where(div > p)", ":is(1bad, p)", ":is()",
    ":has(> p)", ":has(+ p)", ":has(~ div)", ":has(p span)", ":has(.a)", ":has(> li:last-child)", ":lexbor-contains(x)", ":lexbor-contains(\"X\" i)",
    ":lang(en)", "::before", ":NTH-CHILD(2)", ":First-Child", ":current(p)", ":not(:has(a))", ":is(ul, ol) > li",
];

enum string[] combinators = [" ", " > ", ">", " + ", "+", "~", " ~ ", ", ", ","];

enum string[] extra = [
    "", " ", ",", "a,", "a >", "> a", "a > > b", "a[", "a[x", "a[x=", "a[x=]", "[x=a b]", ":", "::", "#", ".", ".1", "a..b",
    "a/**/b", "a /**/ b", "a/**/ b", "\\", "a\\", ":not(", ":not()", ":nth-child()", ":nth-child(2 x)", ":nth-child(2n+)",
    ":nth-child(2.5)", ":nth-child(n-1)", ":nth-child(- n)", "p:nth-child(2n +1)", "p:nth-child(2n+ 1)", "p:nth-child(2n + 1)",
    "p:nth-child(2n -1)", "p:nth-child(+ 2n)", "p:nth-child(+2n)", "p:nth-child(-n)", "p:nth-child(N)", "p:nth-child(-N+3)",
    "p:nth-child(2N+1)", "p:nth-child(ODD)", "p:nth-child(1e1)", "p:nth-child(n+1e1)", "a || b", "a|b", "*|*", "|*", "a[b|c]",
    "a[b|=c]", "a[b|c=d]", "a[*|c]", "a[b~c]", "a[b=c", "a[b='c", "a[b=\"c\"", "a[b=c i", "a[b=c x]", "a[b=c ii]", "a[b=1]",
    "a[b=#c]", "a:not(.a", "a:is(p", "a:has(p", ":has()", ":has(,p)", ":is(,p)", ":is(p,)", ":not(p,)", ":where()", "p ,",
    ", p", "p ,, q", "p\t>\nq", "p\f+\rq", "\\64 iv", "#\\31 23", ".\\.x", "\\70", "p\\2e a", ".a\\ b", "#\\", "'p'", "\"p\"", "p:first-line",
    "p::first-line", ":before", "p:hover:focus", "p:lexbor-contains()", "p:lexbor-contains(a b)", "p:lexbor-contains('a' I)",
    ":nth-child(2 of)", ":nth-child(2 of 1bad)", ":nth-child(2 of p, 1bad)", ":nth-of-type(2 of p)", "p:nth-child(2n+1 of .a, .b)",
    "--x", "-x", "-", "-1", "_a", "a1", "é", ".é", "#é", "p#", "p.", "p[", "p]", "p)", "(p)", "p{", "p;", "@p", "p!", "p$", "p%", "&p",
    "div:not(.x)", "a:not([href])", "div:has(> p)", "div:has(a)", ":is(h1, h2, h3)", ":where(ul, ol) li", "li:nth-child(2 of .x)",
    "h1, h2, h3, h4, h5, h6", "html body div", "body > *", "table tr td", "head title", "tbody > tr", "select option",
    ":root > body", ":root:first-child", "html:root", "*:not(*)", ":not(*)", "a:not(b):not(c)", ":not(:not(p))", ":is(:is(p))",
    "p:has(+ p):has(~ p)", ":has(> :has(> p))", "li:has(+ li:last-child)", "div :first-child", "div :last-child",
];

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
    return format("%(%s.%)", path.retro);
}

void main(string[] args)
{
    string[] sels = simples ~ extra;

    auto rnd = Random(42);
    foreach (a; simples) foreach (b; [".a", "[href]", ":first-child", ":not(.a)", "#x", ":nth-child(2n+1)"]) sels ~= a ~ b;
    foreach (i; 0 .. 4000)
    {
        string s;
        auto n = uniform(1, 4, rnd);
        foreach (k; 0 .. n)
        {
            if (k) s ~= combinators[uniform(0, combinators.length, rnd)];
            auto m = uniform(1, 3, rnd);
            foreach (j; 0 .. m) s ~= simples[uniform(0, simples.length, rnd)];
        }
        sels ~= s;
    }

    string[] docs = [
        `<!doctype html><html lang="en"><head><title>t</title></head><body class="A">
         <div id="main" class="a b"><p class="a">x one</p><p>two <span class="b">X</span></p><!--c--><p></p> <p> </p></div>
         <ul><li class="x">1</li><li class="y x">2</li><li>3</li><li class="y">4</li></ul>
         <ol><li>only</li></ol>
         <a href="http://e.com/a.html" title="ok" lang="en-US">l1</a><a name="n">l2</a><area href="x"><link href="y">
         <input type="TEXT" required placeholder="p"><input type="checkbox" checked disabled><input readonly>
         <select><option selected>o1</option><option>o2</option></select>
         <fieldset disabled><legend>l</legend><input id="f1"></fieldset><fieldset disabled><input id="f2"></fieldset>
         <table><tr><td>a</td><td>b</td><td>c</td></tr><tr><td>d</td></tr></table>
         <svg><rect/><rect class="a"/></svg><math><mi>x</mi></math><x-y data-x="1"></x-y>
         <b><i><b>n</b></i></b><div><div><p>deep</p></div></div>
         </body></html>`,
        // quirks mode: class and id are case-insensitive
        `<html><body><div class="A" id="MAIN"><p CLASS="a B">q</p><span hover focus active>s</span></div>
         <p>1</p><p>2</p><p>3</p><p>4</p><p>5</p><div><p>i</p><b>j</b><p>k</p></div></body></html>`,
    ];
    foreach (f; args[1 .. $]) docs ~= readText(f);

    Document[] parsed = docs.map!(d => Document(d)).array;

    foreach (s; sels)
    {
        Selector sel;
        try sel = Selector(s);
        catch (Exception e) { writeln("[", s, "] ERR"); continue; }

        string line = format("[%s] ok", s);
        foreach (d; parsed)
        {
            string r;
            try r = d.bySelector(sel).map!ident.join(",");
            catch (Exception e) r = "EXC";
            line ~= format(" %s", r.length > 200 ? format("%s#%s", r.count(",") + 1, hashOf(r)) : r);
        }
        writeln(line);
    }
}
