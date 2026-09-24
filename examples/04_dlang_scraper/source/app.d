/++
 What's new in the latest version of D, read from dlang.org.

 The pages are parsed lazily (`Parsing.Lazy`): the tree is built only as far as the queries
 need, so the parser stops a little after the last thing we read.
+/
import std.stdio;
import std.net.curl : get;
import std.path : baseName, stripExtension;
import std.range : take;
import std.string : strip;
import parserino;

void main()
{
	// The home page: "Latest version: 2.113.0 – Changelog"
	auto homeHtml = get("https://dlang.org/");
	auto home = Document(homeHtml, Parsing.Lazy);

	auto changelogLink = home.bySelector(".download .smallprint a").front.getAttribute("href");
	auto latest = changelogLink.baseName.stripExtension;   // "changelog/2.113.0.html" -> "2.113.0"

	writeln("Latest version of D: ", latest);
	writeln("(", home.bytesParsed, " of ", homeHtml.length, " bytes of the home page parsed)");
	writeln();

	// The changelog of that version
	auto changelogHtml = get("https://dlang.org/" ~ changelogLink);
	auto changelog = Document(changelogHtml, Parsing.Lazy);

	writeln(changelog.title);
	writeln(changelog.bySelector(".version small").front.textContent);   // "released Aug 17, 2026"

	// The page starts with a summary of the changes, one list for each section (compiler,
	// runtime, library, dub); the details come after, and they are never parsed
	foreach (section; changelog.byClass("bugsfixed").take(4))
	{
		writeln();
		writeln(section.byTagName("h4").front.textContent, ":");

		foreach (change; section.bySelector("li a").take(3))
			writeln(" - ", change.textContent.strip);
	}

	writeln();
	writeln("(", changelog.bytesParsed, " of ", changelogHtml.length, " bytes of the changelog parsed)");
}
