import std.stdio;
import parserino;
import serverino;
import std.experimental.logger;

void main()
{
	Document d = "<!doctype html><html><p><!--commento-->";

	Element par = d.byTagName("p").frontOrThrow;

	Element first = par.firstChild;
	writeln(first.name);

	par.prependChild("Testo");

	writeln("HERE");
	warning("HMM", par.children(false));
	writeln("POST");

	warning("HMM2", par.children(true).front.name);
	//par.children.front.children;

	par.prependChild(d.createComment("hellohello!"));

	d.byComment("commento").front.prev(true).writeln;


	//.prev.toString(false).writeln;
	writeln(d);
}


