#!/bin/sh
# Generate the html documentation in docs/ (served by GitHub Pages) with scod, the same skin
# as serverino. dub always uses a module tree for the menu on the left: the pages are generated
# again with the declarations (Document, Node, Element, ...) in it.
# docs/llms.txt, docs/llms-full.txt, docs/AGENTS.md and docs/SKILL.md are written by hand.
# Usage: tools/docs.sh
set -e
cd "$(dirname "$0")/.."

dub build -q -b ddox
dub run -q scod -- generate-html --navigation-type=DeclarationTree \
    --sitemap-url=https://trikko.github.io/parserino/ docs.json docs
rm -f docs.json __dummy.html

# SKILL.md is AGENTS.md with the front matter that makes it an installable skill
{
    printf -- '---\nname: parserino\n'
    printf 'description: Official reference for parserino, the HTML5 parser and DOM editor for the D programming language (pure D, CSS selectors, lazy parsing, compile-time templates). Use it whenever the user asks about parserino, or about parsing, scraping or editing HTML in D.\n'
    printf -- '---\n\n'
    cat docs/AGENTS.md
} > docs/SKILL.md
echo "docs/ updated"
