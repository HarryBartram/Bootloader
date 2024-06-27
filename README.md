# Bootloader

A NASM bootloader with a basic, partially made kernel example written in c++

To Build:
make -j4 all
When building the kernel you may need root privileges as the Makefile needs to create a loop device to set up the filesystem.
