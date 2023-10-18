import std;
import parserino;

void main()
{
	Document doc = Document(`
<html><body>
	<h1>hello</h1>
	<div><a href="https://github.com/trikko/serverino">serverino</a></div>
	<a href="https://github.com/trikko/parserino">parserino</a>
</body></html>`
	);

	// Get the second link using a lazy range
	string link = doc.byTagName("a").drop(1).front.getAttribute("href");

	// ... or convert to array and get the second element
	//string link = doc.byClass("link").array[1].getAttribute("href");

	writeln();
	writeln("Second link: ", link);

	// Get the link inside a div
	string divLink = doc.bySelector("div a").front.getAttribute("href");
	writeln("Link inside div: ", divLink);
}
