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

 Run with `dub` and open http://localhost:8080 and http://localhost:8080/cards
 Run with `dub -c live` to reload the templates from disk at each request (edit, then refresh).
+/
module app;

import serverino;
import parserino;

import std.algorithm : canFind, filter;
import std.array : array;
import std.conv : to;
import std.datetime.stopwatch : AutoStart, StopWatch;
import std.format : format;
import std.string : strip;
import std.uni : toLower;
import std.uri : encodeComponent;

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

@endpoint @route!"/"
void tableLayout(Request request, Output output) { respond(template_!"table.html", request, output); }

@endpoint @route!"/cards"
void cardsLayout(Request request, Output output) { respond(template_!"cards.html", request, output); }

/++ A new copy of a template.
 + By default the template is parsed at compile time (`ctDocument`): each request gets its own
 + document, rebuilt from the stored tree without parsing. With `dub -c live` it is read from
 + disk every time, so the changes are visible without recompiling.
 +/
Document template_(string file)()
{
    version (LiveTemplates)
    {
        import std.file : readText;
        return Document(readText("views/" ~ file));
    }
    else return ctDocument!(import(file));
}

void respond(Document page, Request request, Output output)
{
    auto sw = StopWatch(AutoStart.yes);

    render(page, request.get.read("q").strip);
    page.byId("elapsed").innerText = sw.peek.total!"usecs".to!string;

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
    page.byId("layout-table").setAttribute("href", "/?q=" ~ encodeComponent(query));
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
