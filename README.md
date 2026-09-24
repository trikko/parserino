# parserino [![Build & Test](https://github.com/trikko/parserino/actions/workflows/d.yml/badge.svg)](https://github.com/trikko/parserino/actions/workflows/d.yml)
* HTML5 parser and DOM editor written in pure D (tree construction derived from [Lexbor](https://github.com/lexbor/lexbor))
* No C dependencies: no cmake, no prebuilt libraries, no DLLs
* Fast parsing; lazy parsing reads only what your queries need
* CSS selectors (Selectors 4), DOM names and behaviour (`textContent`, `before`, `children`, ...)
* HTML parsed exactly as browsers do: it passes all the tree construction tests of the
  [web-platform-tests](https://github.com/web-platform-tests/wpt/tree/master/html/syntax/parsing)
  and the tokenizer tests of [html5lib](https://github.com/html5lib/html5lib-tests)
* Documents parsed at compile time, for fast html templates
* Safe memory management: documents are reference counted, nodes keep them alive
* The parser core (`parserino.html`, `parserino.dom`, `parserino.css`) is `@nogc nothrow` and works with `-betterC`

# license
Parserino is MIT licensed. The HTML tree construction (`source/parserino/html/treebuilder.d`)
and the tables of names and character references are derived from lexbor and keep its
Apache 2.0 license: see `LICENSE-lexbor` and `NOTICE-lexbor`.

# documentation
* The documentation of each symbol is in the source (`source/parserino/package.d`).
* [docs/llms-full.txt](docs/llms-full.txt): the whole API in one page, with examples; also good
  for LLMs (Claude, Gemini, ChatGPT, ...). [docs/llms.txt](docs/llms.txt) is the short version.
* The [examples](examples) folder: hello world, searches, editing, a lazy scraper, a template engine.

# how it works

Parse a page and take what you need from it:

```d
import parserino;
import std.algorithm : map;
import std.array : array;

void main()
{
    Document doc = `
        <html><head><title>Fresh fruit</title></head>
        <body>
            <h1>Today's offers</h1>
            <ul id="offers">
                <li><a href="/apples">Apples</a> <span class="price">2.50</span></li>
                <li><a href="/pears">Pears</a> <span class="price">3.10</span></li>
            </ul>
        </body></html>`;

    assert(doc.title == "Fresh fruit");
    assert(doc.byTagName("h1").front.textContent == "Today's offers");

    // CSS selectors
    auto links = doc.bySelector("#offers a");
    assert(links.map!(a => a.getAttribute("href")).array == ["/apples", "/pears"]);
    assert(doc.bySelector(".price").map!(p => p.textContent).array == ["2.50", "3.10"]);
}
```

Change it and write it back:

```d
Document doc = `<ul id="offers"><li>Apples</li></ul>`;

// Add an element: the text is escaped, so it can't break the html
auto item = doc.createElement("li");
item.textContent = "Pears & peaches";
item.setAttribute("class", "new");
doc.byId("offers").append(item);

// Or add a piece of html
doc.byId("offers").append(`<li>Plums <b>-20%</b></li>`.asFragment);

assert(doc.byId("offers").outerHTML ==
    `<ul id="offers"><li>Apples</li><li class="new">Pears &amp; peaches</li><li>Plums <b>-20%</b></li></ul>`);
```

The html doesn't need to be valid: it's fixed as a browser would.

```d
Document doc = "<p>Hello <b>world</p>";
assert(doc.toString == "<html><head></head><body><p>Hello <b>world</b></p></body></html>");
```

# nodes and navigation

A `Node` is any node of the tree (element, text, comment, ...). An `Element` is a node that
is an element: it adds attributes, `innerHTML`, `matches`, ... It converts to `Node`, and
`node.asElement` goes back.

Each navigation has one method. A template parameter `Show` says which nodes to see (the
`whatToShow` of the DOM). The default is elements, and then you get `Element`s:

```d
Document doc = `<div id="box"><!-- ad --><p>First</p> text <p>Second</p></div>`;
auto box = doc.byId("box");

assert(box.children.walkLength == 2);              // the elements: <p>, <p>
assert(box.children!(Show.All).walkLength == 4);   // also the comment and the text
assert(box.firstChild.textContent == "First");     // the first element
assert(box.firstChild!(Show.All).isComment);       // the first node of any kind
assert(box.firstChild.nextSibling.textContent == "Second");

// All the texts, or all the comments, of the document
assert(doc.descendants!(Show.Text).map!(t => t.textContent).join("|") == "First| text |Second");
assert(doc.descendants!(Show.Comment).front.textContent == " ad ");

// Ranges work in both directions
assert(box.children.retro.front.textContent == "Second");
```

When nothing is found you get an invalid node (`== null`) or an empty range; operations that
make no sense (on an invalid node, a child of a text, ...) throw `ParserinoException`.

```d
assert(doc.byId("missing") == null);
assert(doc.bySelector("table").empty);
```

# lazy parsing

With `Parsing.Lazy` the tree is built chunk by chunk, only as far as your queries need. To
read the headlines at the top of a big page, parsing stops right after them:

```d
string page = downloadSomeBigPage();                 // for example 1 MB of html

auto doc = Document(page, Parsing.Lazy);
auto headlines = doc.bySelector("h2 a").take(5).array;

writeln(doc.bytesParsed, " of ", page.length, " bytes parsed");   // e.g. 16384 of 1048576
```

The results are always the same as for a fully parsed page: elements that the parser could
still move (in open tables, misnested tags, ...) are returned only when they are final.

# templates

A template is plain html, with example content, that you fill by ids and classes. With
`ctDocument` it's parsed at compile time: at runtime each call gives a new document, without
parsing it again.

```d
// views/card.html: <div class="card"><h2 id="name">Name</h2><p id="price">0.00</p></div>
auto card = ctDocument!(import("card.html"));        // dub: "stringImportPaths": ["views"]

card.byId("name").textContent = "Apples";
card.byId("price").textContent = "2.50";
writeln(card.body.innerHTML);   // <div class="card"><h2 id="name">Apples</h2><p id="price">2.50</p></div>
```

For templates known only at runtime (read from a file, a database, ...) parse them once and
keep a `Snapshot`: `Document(snapshot)` makes a new copy much faster than parsing.

```d
auto template_ = Document(readText("card.html")).snapshot;

foreach (fruit; ["Apples", "Pears"])
{
    auto card = Document(template_);
    card.byId("name").textContent = fruit;
}
```

Repeated rows: clone the first example and remove the examples.

```d
Document page = `<table><tr class="row"><td class="name">Example</td></tr></table>`;
auto model = page.byClass("row").front;

foreach (fruit; ["Apples", "Pears"])
{
    auto row = model.dup;
    row.byClass("name").front.textContent = fruit;
    model.before(row);
}
model.remove();

assert(page.byTagName("td").map!(td => td.textContent).array == ["Apples", "Pears"]);
```

Parsing at compile time needs compiler memory and time: it's meant for templates, big pages
make the build slower.

# parsing options

```d
// <noscript>: parsed as html by default (good for scraping), as text with scripting
ParseOptions options = { scripting: true };
auto doc = Document(html, options);

// A piece of html parsed in the context of an element: here <td> is valid
auto cells = doc.fragment("<td>1</td><td>2</td>", "tr");

auto copy = doc.dup;            // an independent deep copy
```

# checking the html

The parser accepts any html, as browsers do. To know what's wrong with it, collect the parse
errors (the codes of the HTML standard, with line and column):

```d
ParseOptions options = { collectErrors: true };
auto doc = Document("<!DOCTYPE html>\n<p>Hello</b>\n<div id=a id=b>", options);

foreach (e; doc.parseErrors)
    writeln(e);
// 2:13: unexpected-end-tag
// 3:14: duplicate-attribute
// 3:16: unclosed-element-at-eof
```

With `ctDocument` the errors become compile errors, so a broken template doesn't compile:

```d
enum ParseOptions strict = { collectErrors: true };
auto page = ctDocument!(import("page.html"), strict);
```

# encodings

The input must be UTF-8 (a BOM is removed, invalid bytes become U+FFFD, as in browsers).
For old pages in other encodings, `parserino.encoding` finds the encoding as browsers do (BOM,
`<meta charset>`) and converts it:

```d
import parserino.encoding : toUtf8;
import std.file : read;

// <meta charset="windows-1252"><p>café € 10   (saved as windows-1252)
auto doc = Document(toUtf8(cast(const(ubyte)[]) read("old-page.html")));
assert(doc.body.textContent == "café € 10");
```

UTF-16, windows-1252 (also as `latin1`, `iso-8859-1`), ISO-8859-2, windows-1250 and 1251 are supported.

# memory

* `Document` is reference counted: copies are cheap, the tree is freed with the last copy.
* Every `Node` keeps its document alive, so it is always safe to use.
* Removed nodes stay valid (they are freed with their document) and can be inserted again.
* Getters return copies (`string`); the `...View` variants (`getAttributeView`, `localNameView`,
  `idView`, `classesView`, `attributesView`, `dataView`) return slices of the document memory.
* `toString` can write to any output range or delegate, without building a string.
* Different documents can be used from different threads.
