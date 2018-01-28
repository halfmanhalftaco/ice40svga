ice40svga
---------

This is a very simple project to demonstrate generation of 800x600@60 SVGA video using a [myStorm](https://forum.mystorm.uk/) BlackIce-II FPGA board (Lattice ICE40HX4K) and a [Digilent VGA PMOD adapter](https://store.digilentinc.com/pmod-vga-video-graphics-array/).

A PLL block is used to generate 160MHz, which is then divided by 4 to arrive at the 40MHz clock for 800x600@60 SVGA.

Build on MacOS/Linux with [Icestorm](http://www.clifford.at/icestorm/) toolchain
and included Makefile or on Windows with 
[APIO](http://apiodoc.readthedocs.io/en/stable/).
