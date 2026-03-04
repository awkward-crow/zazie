# zazie -- exercises in zig programming style

## latest

 - straightforward working version

And, 

 - not yet playing nicely with this directory structure, but see ./things/tf.zig

## next steps

 - ??

## usage

After

```sh
zig build
```

try

```sh
./zig-out/bin/zazie war-and-peace.txt
```
=>
    one - 2134
    pierre - 1963
    prince - 1928
    up - 1583
    now - 1332
    sha - 1273
    out - 1240
    nat - 1215
    man - 1189
    andrew - 1143
    more - 1058
    himself - 1020
    rost - 965
    time - 929
    princess - 916
    face - 893
    french - 881
    went - 862
    know - 847
    before - 835
    old - 835
    eyes - 827
    very - 804
    men - 792
    room - 771

## performance

After simple `zig build`,

```sh
hyperfine --shell=none "./zig-out/bin/zazie war-and-peace.txt"
```
=>
    Benchmark 1: ./zig-out/bin/zazie war-and-peace.txt
      Time (mean ± σ):     863.1 ms ±  15.6 ms    [User: 860.0 ms, System: 2.1 ms]
      Range (min … max):   848.0 ms … 900.4 ms    10 runs

but after `zig build --release=fast` hyperfine gives

    Benchmark 1: ./zig-out/bin/zazie war-and-peace.txt
      Time (mean ± σ):      21.8 ms ±   0.4 ms    [User: 19.9 ms, System: 1.7 ms]
      Range (min … max):    21.0 ms …  24.8 ms    121 runs
     
      Warning: The first benchmarking run for this command was significantly slower than 
    the rest (24.8 ms). This could be caused by (filesystem) caches that were not filled 
    until after the first run. You should consider using the '--warmup' option to fill th
    ose caches before the actual benchmark. Alternatively, use the '--prepare' option to 
    clear the caches before each timing run.



### end
