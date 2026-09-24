# parserino [![Build & Test](https://github.com/trikko/parserino/actions/workflows/d.yml/badge.svg)](https://github.com/trikko/parserino/actions/workflows/d.yml)
* HTML5 parser written in pure D (tree construction derived from [Lexbor](https://github.com/lexbor/lexbor))
* No C dependencies: no cmake, no prebuilt libraries, no DLLs
* Super-fast parsing & dom editing
* Lazy parsing: `Document.parseLazy(html).byClass("x").take(3)` parses only the beginning of the page
* Lazy ranges to browse dom faster, reusable compiled css `Selector`s
* Safe memory management: documents are reference counted, elements keep them alive
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
   doc.body.appendChild(`
   <a href="/first.html">first</a>
   <div>
      <a id="tochange" href="/second.html">second</a>
   </div>
   `.asFragment // without .asFragment pure text is appended
   );

   // Create and fill an html element
   auto newElement = doc.createElement("a");
   newElement.setAttribute("href", "third.html");
   newElement.innerText("third");
   doc.body.appendChild(newElement);

   // You can use selector to select an element
   doc
   .bySelector("div a")    // Select all <a> inside a <div>
   .frontOrThrow           // Take the first element of the range or throw an exception
   .innerText="changed!";  // Change the inner text

   assert(doc.body.byId("tochange").innerText == "changed!");
}
```

# lazy parsing

`Document.parseLazy` builds the tree chunk by chunk, only as far as your queries need.
Results are always identical to a fully parsed document: nodes that the HTML5 algorithm
could still move (open tables, misnested formatting tags, ...) are returned only when they are final.

```d
auto doc = Document.parseLazy(hugeHtml);

// Parses only until the third link is found
auto links = doc.byTagName("a").take(3).array;
writeln(doc.bytesParsed, " of ", hugeHtml.length, " bytes parsed");

// Accessors wait until the element is complete, mutations complete the parsing
writeln(links[0].innerHTML);
doc.finishParsing();
```

# memory

* `Document` is reference counted: copies are cheap, the tree is freed with the last copy.
* Every `Element` keeps its document alive, so it is always safe to use.
* Removed elements stay valid (they are freed with their document) and can be inserted again.
* Getters return copies (`string`), `*View` variants (`getAttributeView`, `nameView`) avoid them.
* `toString` can write to any output range or delegate, without building a string.
* Different documents can be used from different threads.

# upgrading from 0.x

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

