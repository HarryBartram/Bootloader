# Bootloader

A NASM bootloader with a very basic example kernel written in c++.

Building:
 - Creates a ready to boot image file of an MBR partitioned disk with a FAT32 filesystem.
 - Building requires a cross compiler (If you need help building one, [this page on OSDev Wiki](https://wiki.osdev.org/GCC_Cross-Compiler) May be of some use).
 - Also once built the Makefile may require some modiciations such as changing the location of the cross compiler binary.
 - When building the kernel you may need root privileges as the Makefile needs to create a loop device to set up the filesystem.
