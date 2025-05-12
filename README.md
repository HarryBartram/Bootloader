# Bootloader

A NASM bootloader with a very basic example kernel written in c++

Building:
 - Building requires a cross compiler (If you need help building one, [this page on OSDev Wiki](https://wiki.osdev.org/GCC_Cross-Compiler) may be of some use).
 - Also once built the makefile may require some modifications such as changing the location of the cross compiler binary.
 - When building the kernel you may need root privileges as the Makefile needs to create a loop device to set up the filesystem.
