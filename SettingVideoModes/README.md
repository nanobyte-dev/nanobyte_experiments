# nanobyte_os - graphics introduction
Forked from https://github.com/chibicitiberiu/nanobyte_os/tree/Live_2022_07_14



Some experiments with setting a graphic mode using VBE, and displaying some pretty colors.

Points of interest:

* src/bootloader/stage2/mainc
* src/bootloader/stage2/vbe.h
* src/bootloader/stage2/vbe.c
* src/bootloader/stage2/x86.h
* src/bootloader/stage2/x86.asm



This repo contains the code from the ["Building an OS"](https://www.youtube.com/watch?v=9t-SPC7Tczc&list=PLFjM7v6KGMpiH2G-kT781ByCNC_0pKpPN) tutorial on the ["Nanobyte"](https://www.youtube.com/channel/UCSPIuWADJIMIf9Erf--XAsA) YouTube channel.

## Building
First, install the following dependencies:

```
# Ubuntu, Debian:
$ sudo apt install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo \
                   nasm mtools qemu-system-x86
           
# Fedora:
$ sudo dnf install gcc gcc-c++ make bison flex gmp-devel libmpc-devel mpfr-devel texinfo \
                   nasm mtools qemu-system-x86
```

After that, run `make toolchain`, this should download and build the required tools (binutils and GCC). If you encounter errors during this step, you might have to modify `build_scripts/config.mk` and try a different version of **binutils** and **gcc**. Using the same version as the one bundled with your distribution is your best bet.

Finally, you should be able to run `make`. Use `./run.sh` to test your OS using qemu.
