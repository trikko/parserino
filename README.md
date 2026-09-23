# parserino [![Build & Test](https://github.com/trikko/parserino/actions/workflows/d.yml/badge.svg)](https://github.com/trikko/parserino/actions/workflows/d.yml)
* HTML5 parser written in pure D, based on a port of [Lexbor](https://github.com/lexbor/lexbor)
* No C dependencies: no cmake, no prebuilt libraries, no DLLs
* Super-fast parsing & dom editing
* Lazy ranges to browse dom faster.
* Every method is unit-tested on Linux, MacOS, Windows

# license
Parserino is MIT licensed. The D port of lexbor in `source/parserino/lexbor` is
derived from lexbor and keeps its Apache 2.0 license: see `LICENSE-lexbor` and
`NOTICE-lexbor`.

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

