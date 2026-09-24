#!/bin/bash
# Run all the tests of tools/ on the corpus (see tools/corpus/fetch.sh):
#   - dump: everything the public API can observe, compared with tools/difftest/expected/dump.txt
#   - lazytest: lazy and full parsing give the same results
#   - snaptest: round trip of the snapshots (ctDocument)
#   - html5lib: tree construction (WPT) and tokenizer (html5lib-tests) conformance
#
# Usage: tools/check.sh [--update]   (--update rewrites the reference dump instead of comparing)
set -eo pipefail

DIR=$(cd "$(dirname "$0")" && pwd)
DC=${DC:-ldc2}
FILES="$DIR/corpus/files"

[ -d "$FILES" ] || "$DIR/corpus/fetch.sh"

build() { (cd "$1" && dub build -q --single "$2.d" --compiler="$DC" -b "${3:-release}") }

build "$DIR/difftest" dump
build "$DIR/difftest" lazytest
build "$DIR/difftest" snaptest
build "$DIR/html5lib" treetest debug
build "$DIR/html5lib" tokentest debug

echo "== dump"
"$DIR/difftest/dump" "$FILES"/* > /tmp/parserino_dump.txt
if [ "$1" = "--update" ]; then
    cp /tmp/parserino_dump.txt "$DIR/difftest/expected/dump.txt"
    echo "reference dump updated"
elif ! cmp -s /tmp/parserino_dump.txt "$DIR/difftest/expected/dump.txt"; then
    diff "$DIR/difftest/expected/dump.txt" /tmp/parserino_dump.txt | head -40
    echo "the dump differs from tools/difftest/expected/dump.txt (full output in /tmp/parserino_dump.txt)"
    exit 1
else
    echo "same as the reference"
fi

echo "== lazytest"
"$DIR/difftest/lazytest" --quick "$FILES"/* | tail -2

echo "== snaptest"
"$DIR/difftest/snaptest" "$FILES"/*

echo "== html5lib"
"$DIR/html5lib/treetest"
"$DIR/html5lib/tokentest"
