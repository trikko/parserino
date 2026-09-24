#!/bin/sh
# Download the test data and build the corpus used by tools/difftest, tools/html5lib and tools/bench.
#
#   tools/corpus/html5lib-tests/   html5lib-tests (tokenizer tests)
#   tools/corpus/wpt/              web-platform-tests html/syntax/parsing (tree construction .dat files)
#   tools/corpus/files/            the corpus: h5_* (the #data of each tree construction test),
#                                  doc_* (the ddox pages of this repo) and real_* (real web pages)
#
# Everything is pinned (commits and web.archive.org timestamps), so the corpus is reproducible
# and the reference outputs in tools/difftest/expected can be versioned.
# Usage: tools/corpus/fetch.sh   (from any directory; it does nothing for what is already there)
set -e

HTML5LIB_COMMIT=224991ec10db04f056a89eed8b0bd8695fd2950e
WPT_COMMIT=d0e58242b68ca8513bb2375e2d00c147cd7481b9
DOCS_COMMIT=2a2752c

DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$DIR/../.." && pwd)
cd "$DIR"

# $1 = url, $2 = dir, $3 = commit, $4 = sparse path (optional)
fetch_repo()
{
    [ -d "$2" ] && return
    git init -q "$2.tmp"
    git -C "$2.tmp" remote add origin "$1"
    if [ -n "$4" ]; then
        git -C "$2.tmp" config core.sparseCheckout true
        echo "$4" > "$2.tmp/.git/info/sparse-checkout"
    fi
    git -C "$2.tmp" fetch -q --depth 1 --filter=blob:none origin "$3"
    git -C "$2.tmp" checkout -q FETCH_HEAD
    mv "$2.tmp" "$2"
}

fetch_repo https://github.com/html5lib/html5lib-tests html5lib-tests $HTML5LIB_COMMIT
fetch_repo https://github.com/web-platform-tests/wpt wpt $WPT_COMMIT html/syntax/parsing/resources/

mkdir -p files

# h5_*: the input of each tree construction test
if [ ! -f files/.h5done ]; then
    python3 "$DIR/extract_dat.py" wpt/html/syntax/parsing/resources files
    touch files/.h5done
fi

# doc_*: the ddox pages, at a fixed commit
if [ ! -f files/.docsdone ]; then
    git -C "$ROOT" ls-tree -r --name-only $DOCS_COMMIT docs | grep '\.html$' | while read -r f; do
        name=$(echo "$f" | sed 's|^docs/||; s|/|_|g')
        git -C "$ROOT" show "$DOCS_COMMIT:$f" > "files/doc_$name"
    done
    touch files/.docsdone
fi

# real_*: real pages, from web.archive.org (the id_ suffix gives the original bytes)
while read -r ts url; do
    [ -z "$ts" ] && continue
    name=real_$(echo "$url" | sed 's|[^A-Za-z0-9]|_|g').html
    [ -s "files/$name" ] && continue
    echo "Downloading $url"
    for try in 1 2 3 4 5; do
        if curl -sfL --compressed -o "files/$name.tmp" "https://web.archive.org/web/${ts}id_/$url"; then
            mv "files/$name.tmp" "files/$name"
            break
        fi
        sleep $((try * 10))
    done
    [ -s "files/$name" ] || { echo "Can't download $url" >&2; exit 1; }
    sleep 2
done < "$DIR/pages.txt"

echo "Corpus: $(ls files | wc -l) files in $DIR/files"
