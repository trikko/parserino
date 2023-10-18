import std;
import parserino;

void main()
{
	// Get the html of a random wikipedia page
	auto data = "https://en.wikipedia.org/wiki/Special:Random".get.to!string;

	// Parse the html
	Document doc = Document(data);

	// Get the canonical url of the page
	// We use a CSS selector to get the first element that matches the filter
	auto canonicalUrl = doc.head.bySelector("link[rel=canonical]").front.getAttribute("href");

	writeln();
	writeln("Page: ", doc.title, " => ", canonicalUrl);
	writeln();

	// The following lines of code take the first 5 internal links in the article lazily
	// without parsing the whole page but stopping after the first 5 links are found
	auto internalLinks = doc.byId("mw-content-text") // Get the div with the article
		.byTagName("a")	// Get all the elements <a> inside the div
		.filter!(x => x.getAttribute("href").startsWith("/wiki/"))			// Search for links that start with /wiki/
		.filter!(x => !x.getAttribute("href").startsWith("/wiki/File:")) 	// Exclude links that start with /wiki/File:
		.take(5);	// Take the first 5 links


	writeln("First 5 internal links in the article:");

	// Print the title and the link of each element
	foreach(l; internalLinks)
		writeln(" - ", l.getAttribute("title"), " => https://en.wikipedia.org", l.getAttribute("href"));
}
