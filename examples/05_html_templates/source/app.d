/++
 Parserino as a template engine.

 The usual template engines mix code into the html ({{ }}, {% for %}, <?php ?>, ...): the
 templates are no longer valid html, designers must learn the template language, and moving
 an element around easily breaks the page.

 Here the templates (views/*.html) are plain html, with example content, that anyone can open
 in a browser and edit. The code only relies on ids and classes:
 - it fills an element by id, whatever tag it is and wherever it is in the page;
 - it repeats a "row" by cloning the first example (a <tr> or a <div>, it doesn't care) and
   removes the other examples;
 - it removes the parts of the page that are not needed in a given case;
 - it sets texts and attributes: the escaping is automatic, so the data is never read as html.

 views/table.html and views/cards.html have completely different markup (a table, a grid of
 divs) but the same ids and classes: the same `render` function fills both.

 Run with `dub` and open http://localhost:8080
 Run with `dub -c live` to reload the templates from disk at each request (edit, then refresh).
+/
module app;

import std;
import serverino;
import parserino;

mixin ServerinoMain;

struct Book
{
    string title;
    string author;
    double price;
    string[] tags;
    bool available;
}

// Some data (from a database, in a real application). Note the `&` and `<` in the titles.
immutable Book[] catalogue = [
    Book("Pride & Prejudice", "Jane Austen", 9.90, ["novel", "classic"], true),
    Book("Moby-Dick", "Herman Melville", 12.50, ["novel", "classic", "sea"], true),
    Book("Les Misérables", "Victor Hugo", 15.00, ["novel", "classic", "france"], false),
    Book("The Art of War", "Sun Tzu", 7.20, ["essay", "strategy"], true),
    Book("Leaves of Grass", "Walt Whitman", 11.00, ["poetry", "classic"], true),
    Book("Frankenstein; or, <The Modern Prometheus>", "Mary Shelley", 8.40, ["novel", "horror"], false),
];

@onServerInit ServerinoConfig configure()
{
    return ServerinoConfig.create().addListener("0.0.0.0", 8080).setWorkers(2);
}

// The home page: two links to the same data with two different templates
@endpoint @route!"/"
void home(Request request, Output output) { respond(load!"index.html", output); }

@endpoint @route!"/table"
void table(Request request, Output output) { respond(load!"table.html", request, output); }

@endpoint @route!"/cards"
void cards(Request request, Output output) { respond(load!"cards.html", request, output); }

// The raw templates, as they are before the code fills them
@endpoint @route!"/views/table.html" @route!"/views/cards.html"
void raw(Request request, Output output)
{
    output.addHeader("content-type", "text/html; charset=utf-8");
    output ~= request.path.endsWith("table.html") ? import("table.html") : import("cards.html");
}

// A new copy of a template, parsed at compile time: no parsing at runtime.
// With `dub -c live` it's read from disk at each request: edit the html and refresh.
version (LiveTemplates) Document load(string file)() { return Document(readText("views/" ~ file)); }
else Document load(string file)() { return ctDocument!(import(file)); }

// Fill a bookshop template and send it
void respond(Document page, Request request, Output output)
{
    auto start = MonoTime.currTime;
    render(page, request.get.read("q").strip);
    page.byId("elapsed").innerText = (MonoTime.currTime - start).total!"usecs".to!string;
    respond(page, output);
}

void respond(Document page, Output output)
{
    output.addHeader("content-type", "text/html; charset=utf-8");
    output ~= page.toString;
}

// Fill a template (any layout) with the books matching `query`
void render(Document page, string query)
{
    auto found = catalogue.filter!(b => matches(b, query)).array;

    // 1. Texts by id. The designer can move these elements or change their tags: it still works.
    page.title = "Parserino Books";
    page.byId("shop-name").innerText = "Parserino Books";
    page.byId("count").innerText = found.length.to!string;

    // 2. Attributes: keep the search in the form and in the layout links
    page.byId("search").setAttribute("value", query);
    page.byId("layout-table").setAttribute("href", "/table?q=" ~ encodeComponent(query));
    page.byId("layout-cards").setAttribute("href", "/cards?q=" ~ encodeComponent(query));

    // 3. Automatic escaping: this is what the user typed, and it's set as text.
    //    Search for <script>alert(1)</script>: it is shown, not executed. No escape function to remember.
    page.byId("query").innerText = query;

    // 4. Remove what is not needed in this case
    if (query.length > 0) page.byId("offer").remove();          // the offer only on the home page
    if (found.length == 0) page.byId("results").remove();       // no results: no table (or grid)
    else page.byId("no-results").remove();                      // results: no "nothing found" message

    // 5. Repeat a row. The template contains some example books: the first is the model,
    //    all of them are removed at the end. A <tr>, a <div>, an <article>: it doesn't matter.
    auto examples = page.byClass("book").array;
    if (examples.length == 0) return;
    auto model = examples[0];

    foreach (book; found)
    {
        auto row = model.dup;                   // a deep copy, not yet in the page

        row.byClass("title").front.innerText = book.title;
        row.byClass("author").front.innerText = book.author;
        row.byClass("price").front.innerText = format("€ %.2f", book.price);

        // A list inside the row: the same trick, one level down
        auto tags = row.byClass("tag").array;
        foreach (t; book.tags)
        {
            auto tag = tags[0].dup;
            tag.innerText = t;
            tag.setAttribute("href", "?q=" ~ encodeComponent(t));
            tags[0].prependSibling(tag);        // insert the copies where the examples are
        }
        foreach (t; tags) t.remove();

        // Keep "Details" or "Sold out", whatever elements the designer used for them
        if (book.available)
        {
            row.byClass("sold-out").front.remove();
            row.byClass("details").front.setAttribute("href",
                "https://en.wikipedia.org/wiki/Special:Search?search=" ~ encodeComponent(book.title));
        }
        else row.byClass("details").front.remove();

        model.prependSibling(row);              // the new rows go before the examples, in order
    }

    foreach (e; examples) e.remove();
}

bool matches(ref const Book b, string query)
{
    if (query.length == 0) return true;
    auto q = query.toLower;
    return b.title.toLower.canFind(q) || b.author.toLower.canFind(q) || b.tags.canFind!(t => t == q);
}
