# parserino [![Build & Test](https://github.com/trikko/parserino/actions/workflows/d.yml/badge.svg)](https://github.com/trikko/parserino/actions/workflows/d.yml)
* HTML5 parser based on [Lexbor](https://github.com/lexbor/lexbor)
* Super-fast parsing & dom editing
* Every method is unit-tested on Linux and MacOS

# how it works

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

