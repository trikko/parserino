# Benchmark

`bench.d` measures parsing (full and lazy), `ctDocument`, queries and serialization on the real pages
of the corpus (`tools/corpus/fetch.sh` downloads them). Each line is the median of N rounds.

```sh
tools/corpus/fetch.sh
cd tools/bench
dub build --single bench.d --compiler=ldc2 -b release
taskset -c 2 ./bench --rounds 50
```

On CPUs with performance and efficiency cores (hybrid), always run on the same core with `taskset`,
otherwise the results depend on where the scheduler puts the process. Pick a performance core
(`lscpu -e` shows the maximum frequency of each core) and keep the machine idle.
Compare two builds only with the same compiler, flags and core.

`baseline.txt` has the numbers of the version before the work of TODO.md (commit b69982f),
`current.txt` the ones after it; the results of each optimization (kept or discarded) are in the
"Results" section below. All on an AMD Ryzen AI 9 465, core 2, ldc 1.42.

## Profiling

```sh
dub build --single bench.d --compiler=ldc2 -b release-debug
perf record -g taskset -c 2 ./bench --rounds 20
perf report --no-children
```

## Results

| measure                     | before (b69982f) | after    |        |
|-----------------------------|-----------------:|---------:|-------:|
| parse                       |         14.3 ms  | 11.0 ms  |  -23%  |
| parse lazy + 5 links        |          908 us  |  592 us  |  -35%  |
| parse lazy + finish         |         14.3 ms  | 11.1 ms  |  -22%  |
| parse the same 60 KB        |          384 us  |  299 us  |  -22%  |
| ctDocument (60 KB)          |           41 us  |   34 us  |  -17%  |
| selectors                   |          7.0 ms  |  5.4 ms  |  -23%  |
| byTagName + byClass + byId  |          2.3 ms  |  1.7 ms  |  -27%  |
| serialize                   |          5.7 ms  |  4.0 ms  |  -30%  |
| byId x100 (a)               |          2.5 ms  |   16 us  |        |
| Document(snapshot) (a)      |          2.3 ms  |  1.3 ms  |  -46%  |

(a) measured at the beginning of the optimizations (the measure didn't exist before).
The parser also does more than before: it validates UTF-8, removes the BOM, and passes all
the tree construction tests of WPT.

Each change, in order (parse = full parsing of the real pages):

- Buffer: forced inlining of the fast paths (put, opIndex, length, ...). Parse 14.3 -> 11.9 ms.
  After the OOM changes they were no longer inlined (12% slower): inlining fixed it and more.
- UTF-8 validation (decoder of the Encoding standard): +5% at first; merged with the CR
  detection in a single pass (16 bytes at a time for ASCII): +3%. Kept (correctness).
- Tag and attribute names lowercased only when they have uppercase letters: 12.1 -> 11.6 ms.
- SWAR scans (8 bytes) of text, attribute values, comments, script: 11.6 -> 11.5 ms, lazy + 5
  links 730 -> 675 us. Kept (small but steady).
- Arena: blocks zeroed by calloc instead of a memset per allocation: 11.5 -> 11.1 ms.
  Block sizes 16, 32, 64 KB (fixed or growing): not faster within the noise; kept 4 -> 16 KB.
- byId index from the second search on: 100 byId per page 2.5 ms -> 16 us.
- Selectors: ids of the known tag/attribute names at compile time (the lookup was 40% of
  the matching): selectors 7.0 -> 5.0 ms, descendant selectors 6.7 -> 3.9 ms.
- Bloom filter of the ancestors (as in the browsers): -18% on anchored descendant selectors
  (#id p a, .class td a, table td a), +6% on the others (the last compound is tested first,
  the filters are computed lazily; a first version was 40% slower). Kept.
- Lazy parsing: an immutable input is not copied: lazy + 5 links 675 -> 645 us.
  Discarded: chunks ended after a '>' (no gain, also with 256/1024 byte chunks).
  Not done: incremental isStable/refreshVolatile (below 1% of the lazy parsing).
- Serializer: escaping with SWAR: 5.4 -> 3.9 ms.
- Snapshot.restore: all the nodes in one arena block: 2.3 -> 1.25 ms.
- Entities: first char from a table built in CTFE: many references 20 -> 15 ms (1.6 MB);
  the real pages have few. A full trie would save little more: not done.
- Name tables: a cheaper hash (length + 3 chars) was slower (collisions on short names):
  discarded, FNV stays.
- CTFE (ctDocument): half the compiler memory (86 KB of rows: 698 -> 394 MB), same time.

### LTO and PGO (ldc)

LTO (`-flto=full` with the LTO druntime/phobos) doesn't help: parsing is the same, selectors
and serialization are slower. PGO does: parse -22% (10.5 -> 8.2 ms), selectors -17%,
serialization -10%. It needs a run on representative input, so it's for applications:

```sh
ldc2 -O3 -release -fprofile-generate=prof-%p.profraw ... app.d   # instrumented build
./app sample-input                                            # training run
ldc-profdata merge -o app.profdata prof-*.profraw
ldc2 -O3 -release -fprofile-use=app.profdata ... app.d         # optimized build
```
