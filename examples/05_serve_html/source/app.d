module app;

import serverino;
import parserino;
import std;

mixin ServerinoMain;


// Create a server with serverino on port 8080
// more info about serverino: https://github.com/trikko/serverino
@onServerInit ServerinoConfig configure()
{
	return ServerinoConfig
		.create()
		.addListener("0.0.0.0", 8282)
		.setWorkers(4);
}

// Handle incoming requests
@endpoint @route!"/"
void dump(Request request, Output output)
{
	// Load the html file, template html created by https://www.shapingrain.com
	Document doc = Document("html/index.html".readText());

	// Replace the title
	doc.byTagName("h1").frontOrThrow.innerText = "Parserino";

	// Replace the description
	doc.byTagName("h2").frontOrThrow.innerText = "Hello from parserino! This is a simple example of how to use parserino to parse html files and replace their content.";

	// Change button link to point to parserino github page
	doc.bySelector("a.button").frontOrThrow.setAttribute("href", "https://github.com/trikko/parserino");

	// Remove the pricing section of the template
	doc.bySelector("section#pricing").frontOrThrow.remove();

	// Remove all the social link except twitter
	// You should avoid removing elements while iterating over them with a range
	// but in this case it's safe because we are converting it to an array
	foreach(e; doc.bySelector("ul.social-icons > li").array)
	{
		if(e.firstChild.getAttribute("title") != "Twitter") e.remove();
		else e.firstChild.setAttribute("href", "https://twitter.com/twittatore");
	}

	// Output the modified document
	output ~= doc;

	// Try to navigate to http://localhost:8282
}

// Serve static files
@endpoint
@route!(x => x.uri.startsWith("/css/"))	 	// Serve files in the css folder and ...
@route!(x => x.uri.startsWith("/js/"))		 	// ... in the js folder and ...
@route!(x => x.uri.startsWith("/fonts/"))  	// ... in the fonts folder and ...
@route!(x => x.uri.startsWith("/images/")) 	// ... in the images folder
void static_serve(Request request, Output output)
{
	output.serveFile("html" ~ request.uri);
}
