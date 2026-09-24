# parserino [![Build & Test](https://github.com/trikko/parserino/actions/workflows/d.yml/badge.svg)](https://github.com/trikko/parserino/actions/workflows/d.yml)
* HTML5 parser written in pure D (tree construction derived from [Lexbor](https://github.com/lexbor/lexbor))
* No C dependencies: no cmake, no prebuilt libraries, no DLLs
* Super-fast parsing & dom editing
* Lazy parsing: `Document(html, Parsing.Lazy).byClass("x").take(3)` parses only the beginning of the page
* Lazy ranges to browse dom faster, reusable compiled css `Selector`s
* Safe memory management: documents are reference counted, nodes keep them alive
* Standard names and behaviour (DOM, HTML5, Selectors 4), checked with the web-platform-tests
* The parser core (`parserino.html`, `parserino.dom`, `parserino.css`) is `@nogc nothrow` and works with `-betterC`
* Every method is unit-tested on Linux, MacOS, Windows

# license
Parserino is MIT licensed. The HTML tree construction (`source/parserino/html/treebuilder.d`)
and the tables of names and character references are derived from lexbor and keep its
Apache 2.0 license: see `LICENSE-lexbor` and `NOTICE-lexbor`.

# documentation
All docs are available [here](https://trikko.github.io/parserino/)

### LLM-Friendly Documentation
If you are using an LLM (like Gemini, Claude, or ChatGPT) to help you write code with Parserino, you can point it to these files for a concise API overview:
- [docs/llms.txt](docs/llms.txt) - Core API overview and quick start.
- [docs/llms-full.txt](docs/llms-full.txt) - Detailed API reference with examples.

# how it works

<sub>Check also the [examples](https://github.com/trikko/parserino/tree/master/examples) folder</sub>

```d
import parserino;

void main()
{
   // Parserino will fix your html5
   Document doc = "<html>my html";
   assert(doc.toString() == "<html><head></head><body>my html</body></html>");

   // Set a title for your page
   doc.title = "Hello world";
   assert(doc.toString() == "<html><head><title>Hello world</title></head><body>my html</body></html>");

   // Append a html fragment
   doc.body.append(`
   <a href="/first.html">first</a>
   <div>
      <a id="tochange" href="/second.html">second</a>
   </div>
   `.asFragment // without .asFragment pure text is appended
   );

   // Create and fill an html element
   auto newElement = doc.createElement("a");
   newElement.setAttribute("href", "third.html");
   newElement.textContent = "third";
   doc.body.append(newElement);

   // You can use selector to select an element
   doc
   .bySelector("div a")       // Select all <a> inside a <div>
   .frontOrThrow              // Take the first element of the range or throw an exception
   .textContent = "changed!"; // Change the text

   assert(doc.body.byId("tochange").textContent == "changed!");
}
```

# nodes and navigation

A `Node` is any node of the tree (element, text, comment, doctype, ...); an `Element` is a node
that is an element, with attributes, `innerHTML`, `matches`, ... (it converts to `Node`, and
`node.asElement` goes back).

Each navigation has one method, and a template parameter `Show` says which nodes to see (the
bits of `whatToShow` in the DOM). The default is elements only, and then you get `Element`s:

```d
p.children                              // the child elements
p.children!(Show.All)                   // all the child nodes
p.firstChild!(Show.Text)                // the first text child
p.nextSibling!(Show.Comment)            // the next comment
doc.descendants!(Show.Comment)          // all the comments of the document
doc.body.descendants!(Show.Text)        // all the texts, as lazy ranges
    .filter!(t => t.textContent.canFind("price"));
doc.body.descendants.retro              // reverse document order
doc.byComment("marker")                 // the comments with this text
```

Searches and navigation give an invalid node (`== null`) or an empty range when nothing is found;
invalid operations (on an invalid node, a child of a text, a node inside itself, ...) throw
`ParserinoException`.

# parsing options

```d
auto doc = Document(html);                      // everything at once
auto lazyDoc = Document(html, Parsing.Lazy);    // only as far as the queries need

ParseOptions options = { scripting: true };     // <noscript> is text, as in a browser
auto scripted = Document(html, options);

auto part = doc.fragment("<td>x", "tr");        // parse in the context of an element
auto copy = doc.dup;                            // a deep copy
auto snap = doc.snapshot;                       // parse once...
auto fast = Document(snap);                     // ...and make many documents quickly
```

# parse errors and encodings

The parser recovers from any html, as browsers do. To know what was wrong, collect the errors
(the codes of the HTML standard, with line and column):

```d
ParseOptions options = { collectErrors: true };
auto doc = Document(html, options);
foreach (e; doc.parseErrors) writeln(e);        // 3:12: duplicate-attribute, ...

enum ParseOptions strict = { collectErrors: true };
auto page = ctDocument!(import("page.html"), strict);   // invalid html doesn't compile
```

The input is UTF-8 (a BOM is removed, invalid bytes become U+FFFD). For other encodings,
`parserino.encoding` finds the encoding as browsers do (BOM, `<meta charset>`) and converts:

```d
import parserino.encoding;
auto doc = Document(toUtf8(cast(const(ubyte)[]) read("old-page.html")));
```

# lazy parsing

`Document(html, Parsing.Lazy)` builds the tree chunk by chunk, only as far as your queries need.
Results are always identical to a fully parsed document: nodes that the HTML5 algorithm
could still move (open tables, misnested formatting tags, ...) are returned only when they are final.

```d
auto doc = Document(hugeHtml, Parsing.Lazy);

// Parses only until the third link is found
auto links = doc.byTagName("a").take(3).array;
writeln(doc.bytesParsed, " of ", hugeHtml.length, " bytes parsed");

// Accessors wait until the element is complete, mutations complete the parsing
writeln(links[0].innerHTML);
doc.finishParsing();
```

# compile-time parsing

`ctDocument!html` parses the document at compile time. At runtime each call returns a new
(mutable) document rebuilt from the stored tree, without parsing it again: useful for templates.
Parsing in CTFE needs a lot of compiler memory: fine for templates of some tens of KB
(about 1 s to compile), not for whole big pages (a 400 KB page needs several GB).

```d
auto page = ctDocument!(import("page.html"));   // dub: "stringImportPaths": ["views"]
page.byId("title").textContent = "Hello";
```

# memory

* `Document` is reference counted: copies are cheap, the tree is freed with the last copy.
* Every `Node` keeps its document alive, so it is always safe to use.
* Removed nodes stay valid (they are freed with their document) and can be inserted again.
* Getters return copies (`string`); the `*View` variants (`getAttributeView`, `localNameView`, `idView`,
  `classesView`, `attributesView`, `dataView`) return slices of the document memory instead.
* `toString` can write to any output range or delegate, without building a string.
* Different documents can be used from different threads.

# upgrading from 0.x

The API now follows the DOM names and behaviour:

* `Element` was any node: now `Node` is any node and `Element` only an element.
* The boolean parameters are gone: `children(true)` is `children!(Show.All)`, `next(true)` is
  `nextSibling!(Show.All)`, `firstChild(true)` is `firstChild!(Show.All)`, ...;
  `next`/`prev` are `nextSibling`/`previousSibling`.
* `descendants!(VisitOrder.Reverse)` is `descendants.retro` (true reverse document order).
* `byTagName("#text")`/`byTagName("!--")` are `descendants!(Show.Text)`/`descendants!(Show.Comment)`;
  `byTagName("*")` gives all the elements; `byComment(text, false)` is `byCommentExact(text)`.
* `prependSibling`/`appendSibling` are `before`/`after`, `prependChild` is `prepend`,
  `appendChild` of strings and fragments is `append`.
* `innerText` is `textContent` (`innerText` is still there, the same); `name` is `localName`
  (`"foreignObject"`), `tagName` is uppercase for html elements, `nodeName` as in the DOM.
* `dup(false)` is `shallowDup`, `copyFrom(e, false)` is `shallowCopyFrom`, `toString(false)` is `startTag`.
* `contains` includes the node itself (as in the DOM); `isAncestorOf`, `isDescendantOf`, `canFind` are gone.
* `owner` is `ownerDocument`; `Parsing.lazy_` is `Parsing.Lazy` (all the enum members are PascalCase).
* `fragment(html)` returns a `DocumentFragment` node, parsed in the context of `<body>` (or of the
  given element); inserting it moves its children. Fragments given to `append`, `before`, ... are
  parsed in the context of their parent.
* `doc.body` of a frameset document is the `<frameset>` (as in the DOM).
* `isEmpty` is `:empty` (whitespace text counts), `isBlank` is `:blank`.
* `innerHTML` of a `<template>` is its content.

From 0.x:

* `byId` returns an invalid element (`== null`) instead of throwing.
* `getAttribute` returns `null` for missing attributes.
* Ranges are structs (forward ranges); `bySelector` returns each element once.
* Elements can't be moved between documents.
* CSS selectors follow the standard (Selectors 4 and HTML) for a static document:
  * `:hover`, `:focus`, `:active`, `:visited`, `:target`, ... are valid but never match
    (before they matched elements with a `hover`/`focus`/`active` attribute);
  * pseudo-elements (`::before`) are valid but never match;
  * `:lang()`, `:scope` and namespace prefixes (`svg|rect`, `[xlink|href]`, `*|*`) are supported;
  * `:disabled`, `:enabled`, `:checked`, `:read-write`, `:placeholder-shown`, `:link` follow the HTML spec;
  * `:is()`/`:where()` are forgiving, `:has()` is not (and can't be nested), extra tokens after `An+B` are an error;
  * `:first-child`, `:nth-child()`, ... count elements only.
* Selectors can be parsed at compile time: `doc.bySelector!"div > a"` or `ctSelector!"div > a"`.

