---
name: parserino
description: Official reference for parserino, the HTML5 parser and DOM editor for the D programming language (pure D, CSS selectors, lazy parsing, compile-time templates). Use it whenever the user asks about parserino, or about parsing, scraping or editing HTML in D.
---

# Parserino

Parserino is an HTML5 parser and DOM editor for the D programming language, in pure D,
with no dependencies. Version 1.0.0.

Read the reference before writing parserino code. It is two files:

- **`llms-full.txt`** — the whole API in one file: `Document`, `Node`, `Element`, `Show`,
  selectors, parse errors, encodings, worked examples. This is the one to read.
  <https://trikko.github.io/parserino/llms-full.txt>
- **`llms.txt`** — a page of overview, when the full one is more than you need.
  <https://trikko.github.io/parserino/llms.txt>

In the packaged skill both sit next to this file; installed from the web, fetch
them from the addresses above.

Versions before 1.0 had a different API (`next`, `appendChild` of strings,
`children(true)`, ...): if you remember that one, forget it. What follows are the
rules that are easiest to get wrong.

## Shape of a program

```d
import parserino;

void main()
{
    Document doc = `<ul id="menu"><li><a href="/a">A</a></li><li><a href="/b">B</a></li></ul>`;

    foreach (a; doc.bySelector("#menu a"))
        writeln(a.getAttribute("href"), " ", a.textContent);

    doc.byId("menu").append(`<li><a href="/c">C</a></li>`.asFragment);
    writeln(doc.toString);
}
```

`dub add parserino`. Any html is accepted and fixed as a browser would: there is
no "invalid html" exception.

## Nodes and elements

- `Node` is any node (element, text, comment, doctype, document, fragment).
  `Element` is a node that is an element: only it has attributes, `innerHTML`,
  `matches`, `localName`, ... An `Element` converts to `Node` by itself;
  `node.asElement` goes back (an invalid element if it isn't one).
- Navigation sees **elements only** by default. `children`, `firstChild`,
  `nextSibling`, `descendants`, ... take a `Show` filter:
  `p.firstChild!(Show.Text)`, `div.children!(Show.All)`,
  `doc.descendants!(Show.Comment)`. With a filter other than `Show.Element` you
  get `Node`s, not `Element`s.
- Use `localName` (`"div"`) to compare names: `tagName` is uppercase for html
  elements (`"DIV"`), as in the DOM.
- `textContent` is the text; `innerText` is the very same thing (no layout,
  no CSS).

## Nothing found

- `byId`, `firstChild`, `parent`, ... return an **invalid node** (`== null`)
  when there is nothing: check it before using it. Calling a method on an
  invalid node throws `ParserinoException`.
- Searches return ranges. `.front` on an empty range throws: check `.empty`,
  or use `frontOrInit` (an invalid node), `frontOr(fallback)`, `frontOrThrow`.
- `getAttribute` returns `null` for a missing attribute and `""` for an empty
  one: `hasAttribute` tells them apart.

## Changing the tree

- A `string` given to `append`, `prepend`, `before`, `after`, `replaceWith` is
  **text**, and it is escaped: `append("<b>x</b>")` shows `<b>x</b>` on the
  page. For html use `"<b>x</b>".asFragment`, or set `innerHTML`/`outerHTML`.
- The ranges are live. Removing or moving nodes while iterating one skips
  nodes: take them first with `.array`, then change them:
  `foreach (e; doc.byClass("ad").array) e.remove();`
- `remove()` detaches a node; it stays valid and can be inserted again. Nodes
  can't be moved to another document: `dup` them there with `createElement` +
  `copyFrom`, or insert their html.
- `el = "<b>html</b>";` replaces the element with the one parsed from the
  string.
- `toString` (and `outerHTML`, `innerHTML`) gives the html as it is;
  `toPrettyString` indents it, to show it to a person. It changes the
  whitespace between the nodes: don't store or send it.

## Parsing

- `Document(html, Parsing.Lazy)` parses only as far as the queries need (good
  for scraping the top of big pages); results are the same as a full parse.
- The input is UTF-8. For bytes in another encoding use
  `parserino.encoding.toUtf8(bytes)`, which finds the encoding as browsers do.
- `ParseOptions.collectErrors` and `doc.parseErrors` report what is wrong with
  the html; nothing is thrown.

## Templates

- A page filled many times: parse it once, keep `doc.snapshot` (immutable,
  shareable between threads), make each copy with `Document(snapshot)`: no
  parsing, much faster.
- `ctDocument!(import("page.html"))` parses at compile time: each call returns
  a new document. It needs `"stringImportPaths": ["views"]` (or `-J`). With
  `ParseOptions.collectErrors` broken html is a compile error.
- Fill templates by `id` and `class` with `textContent` (escaped) and
  `setAttribute`; repeat rows with `model.dup` + `model.before(row)`, then
  `model.remove()`.

## Selectors

- `bySelector("css")`, `matches("css")`, `Selector("css")` to reuse one,
  `bySelector!"css"` / `ctSelector!"css"` to check it at compile time.
  `isValidSelector(css)` checks without throwing; an invalid selector at
  runtime throws `ParserinoException`.
- Selectors 4 on a static document: `:hover`, `:focus`, `:visited`, ... and
  pseudo-elements (`::before`) are valid but never match. `:has()`, `:is()`,
  `:where()`, `:not()`, `:nth-child(An+B of S)`, `:lang()`, `:dir()` work.

## Common mistakes

| Wrong | Right |
|---|---|
| `e.next`, `e.prev` | `e.nextSibling`, `e.previousSibling` |
| `e.children(true)` | `e.children!(Show.All)` |
| `byTagName("#text")` | `descendants!(Show.Text)` |
| `e.name`, `e.tagName == "div"` | `e.localName == "div"` |
| `e.appendChild("<b>x</b>")` | `e.append("<b>x</b>".asFragment)` |
| `e.prependSibling(x)`, `e.appendSibling(x)` | `e.before(x)`, `e.after(x)` |
| `try doc.byId("x") catch ...`, `if (auto e = doc.byId("x"))` | `auto e = doc.byId("x"); if (e != null) ...` (or `e.isValid`) |
| `doc.byTagName("p").front` on a page that may have none | `.frontOrInit`, or check `.empty` |
| `foreach (e; doc.byClass("x")) e.remove();` | `foreach (e; doc.byClass("x").array) e.remove();` |
| `e.dup(false)`, `toString(false)` | `e.shallowDup`, `e.startTag` |
