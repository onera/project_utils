# Debug with address sanitizer #

Sanitizer is a powerful tool to find out memory problems such segmentation violation and memory leaks.

To use it, you need to pass specific flags to the compiler. For that you can just use the `Sanitize` cmake build type :

```bash
cmake ... -DCMAKE_BUILD_TYPE=Sanitize
```


Now the created binaries need to be launched with a replacement of `libc` in order to track the memory accesses.
For that, you need to use `LD_PRELOAD`:

```bash
export LD_PRELOAD=$(gcc -print-file-name=libasan.so)
# Launch the program you want to debug here
unset LD_PRELOAD
```

Beware that changing `LD_PRELOAD` heavily affects the shell environment. So only launch the program you want to debug, and do *everything* else (including compilation, edition...) in another shell.
