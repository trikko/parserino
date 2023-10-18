import std.stdio;
import parserino;

void main()
{
	Document doc = Document("<html><body><h1>Hello, world!</h1></body></html>");

	// Parse a fragment of HTML and add it to the document
	// If you don't use asFragment, the string will be added as a text node
	doc.body.appendChild("<p>How are you?</p>".asFragment);

	// Create another new element and add it to the document
	Element p = doc.createElement("p");
	p.innerText = "I'm fine, thanks!";

	doc.body.appendChild(p);

	// Print the document
	writeln(doc);
}
