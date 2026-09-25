import std.stdio;
import parserino;

void main()
{
	Document doc = Document(`<html><body><h1>Shopping list</h1><ul id="list"><li>Bread</li></ul></body></html>`);
	Element list = doc.byId("list");

	// Parse a fragment of HTML and add it to the document
	// If you don't use asFragment, the string will be added as a text node
	list.append("<li>Milk <small>(2 litres)</small></li>".asFragment);

	// Create a new element and add it to the document
	// Its text is escaped: "<" and ">" stay text, they don't become tags
	Element li = doc.createElement("li");
	li.textContent = "Eggs <organic>";
	list.append(li);

	// Print the document, indented to read it (toString gives the html as it is)
	writeln(doc.toPrettyString);
}
