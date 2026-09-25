# parserino [![Build & Test](https://github.com/trikko/parserino/actions/workflows/d.yml/badge.svg)](https://github.com/trikko/parserino/actions/workflows/d.yml)
* HTML5 parser and DOM editor written in pure D, born as a D port of [lexbor](https://github.com/lexbor/lexbor)
* No 3rd-party dependencies
* Fast parsing; lazy parsing reads only what your queries need
* CSS selectors (Selectors 4), DOM names and behaviour (`textContent`, `before`, `children`, ...)
* HTML parsed exactly as browsers do: it passes all the tree construction tests of the
  [web-platform-tests](https://github.com/web-platform-tests/wpt/tree/master/html/syntax/parsing)
  and the tokenizer tests of [html5lib](https://github.com/html5lib/html5lib-tests)
* Documents can be parsed at compile time, for fast html templates
* Safe memory management: documents are reference counted, nodes keep them alive
* The parser core (`parserino.html`, `parserino.dom`, `parserino.css`) is `@nogc nothrow` and works with `-betterC`

# lexbor
Up to 0.2.x parserino was a D wrapper of [lexbor](https://github.com/lexbor/lexbor), the C
HTML engine by Alexander Borisov. Version 1.0 started as a translation of lexbor to D; that
port was then rewritten piece by piece in idiomatic D, using it as the reference to test the
new code against. What still comes from lexbor:

* the HTML tree construction (`source/parserino/html/treebuilder.d`)
* the tables of tag/attribute names and of character references (`source/parserino/names.d`,
  `source/parserino/html/entities.d`)
* for compatibility with parserino 0.2.x, which used the lexbor selectors: the `:lexbor-contains()`
  pseudo-class and the way An+B (`:nth-child(2n+1)`) is read

Thanks to Alexander Borisov and to the lexbor contributors: parserino owes them a lot.

# license
Parserino is licensed under `MIT AND Apache-2.0`: the code derived from lexbor keeps its
Apache 2.0 license (Copyright (C) 2018-2026 Alexander Borisov, see `LICENSE-lexbor` and
`NOTICE-lexbor`), the rest is MIT.

# documentation
* [The API reference](https://trikko.github.io/parserino/parserino.html), generated from the
  documentation in the source (`source/parserino/package.d`).
* The [examples](examples) folder: hello world, searches, editing, a lazy scraper, a template engine.

# using parserino with an AI agent

Parserino is rare in the training data of the models, and its API changed with 1.0: a model left
to guess writes old or invented code. Give it the reference instead:

* [SKILL.md](https://trikko.github.io/parserino/SKILL.md): the rules that are easiest to get
  wrong, as a skill. [AGENTS.md](https://trikko.github.io/parserino/AGENTS.md) is the same text
  without the front matter, for tools that want a rules file (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, ...).
* [llms-full.txt](https://trikko.github.io/parserino/llms-full.txt): the whole API;
  [llms.txt](https://trikko.github.io/parserino/llms.txt): a short overview.

The easiest way: ask your agent to do it.

> Install the skill at https://trikko.github.io/parserino/SKILL.md. It is the reference for
> parserino, the D html parser I am using.

Or by hand: a skill is a folder with `SKILL.md` in it (`llms-full.txt` next to it saves a download).

| Tool | For all projects | For one project |
|---|---|---|
| Claude Code | `~/.claude/skills/parserino/` | `.claude/skills/parserino/` |
| Antigravity (IDE, 2.0) | `~/.gemini/config/skills/parserino/` | `.agents/skills/parserino/` |
| Antigravity CLI | `~/.gemini/antigravity-cli/skills/parserino/` | `.agents/skills/parserino/` |
| Gemini CLI | `~/.gemini/skills/parserino/` | `.gemini/skills/parserino/` |
| Codex | `~/.agents/skills/parserino/` | `.agents/skills/parserino/` |

For example, for Claude Code:

```sh
mkdir -p ~/.claude/skills/parserino && cd ~/.claude/skills/parserino
curl -fsSLO https://trikko.github.io/parserino/SKILL.md
curl -fsSLO https://trikko.github.io/parserino/llms-full.txt
```

The skill is loaded when the task is about parserino or html in D; in Claude Code you can also
call it with `/parserino`.

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

# parsing options

```d
// <noscript>: parsed as html by default (good for scraping), as text with scripting
ParseOptions options = { scripting: true };
auto doc = Document(html, options);

// A piece of html parsed in the context of an element: here <td> is valid
auto cells = doc.fragment("<td>1</td><td>2</td>", "tr");

auto copy = doc.dup;            // an independent deep copy
```

# templates: snapshots and compile time

A page that is filled again and again (a template, for each request of a web server) doesn't
need to be parsed each time. `doc.snapshot` takes a compact, immutable copy of the tree, and
`Document(snapshot)` rebuilds from it a new, independent document, without parsing and
much faster:

```d
immutable Snapshot page;
shared static this() { page = Document(readText("views/page.html")).snapshot; }

string render(string user)
{
    auto doc = Document(page);          // a fresh copy of the template: no parsing
    doc.byId("user").textContent = user;
    return doc.toString;
}
```

A snapshot never changes, so it can be shared between threads, and the documents made from it
borrow its strings instead of copying them (it stays alive as long as they need it). It's also a
cheap way to save a document and go back to it later: `doc = Document(saved)`.

`ctDocument` does the same at compile time: the html is parsed by the compiler and the snapshot
is stored in the program, so at runtime there is no parsing at all:

```d
auto doc = ctDocument!(import("page.html"));   // needs the path of page.html in stringImportPaths (-J)
doc.byId("user").textContent = "guest";
```

Each call returns a new document. Parsing at compile time needs compiler memory and time: some
tens of KB take about 1 s, a 600 KB page about 1 GB and 10 s (dmd). See
[example 05](examples/05_html_templates) for a template engine built this way.

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
