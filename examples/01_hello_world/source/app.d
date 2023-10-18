import std.stdio;
import parserino;

void main()
{
	// This is a valid html document, by the way.
	string html = "<html><body>Hello, world!";

	// Parserino can handle it.
	Document doc = Document(html);
	writeln("Document before edit: ", doc);

	// Let's change the text inside the body tag.
	doc.body.innerText = "Hello, Parserino!";
	writeln(" Document after edit: ", doc);
}
