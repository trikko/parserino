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

`baseline.txt` has the numbers of the version before the optimizations of TODO.md; the results
of each optimization (kept or discarded) are in the "Results" section below.

## Profiling

```sh
dub build --single bench.d --compiler=ldc2 -b release-debug
perf record -g taskset -c 2 ./bench --rounds 20
perf report --no-children
```

## Results
