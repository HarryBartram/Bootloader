LD=/home/vboxuser/opt/gcc/bin/ld
GCC=/home/vboxuser/opt/gcc/bin/g++

BOOTSRC=boot/mbr.asm
BOOTSRCINC=boot/utils.asm boot/stage2.asm

INITASMSRC=kernel/init.asm
INITASMOBJ=kernel/init.asm.o

INITCPPSRC=$(wildcard kernel/*.cpp)
INITCPPOBJ=$(patsubst %.cpp,%.cpp.o,${INITCPPSRC})

DISPLAYSRC=$(wildcard kernel/display/*.cpp)
DISPLAYOBJ=$(patsubst %.cpp,%.cpp.o,${DISPLAYSRC})

HARDWARESRC=$(wildcard kernel/hardware/*.cpp)
HARDWAREOBJ=$(patsubst %.cpp,%.cpp.o,${HARDWARESRC})

KERNELBIN=kernel/init.bin

ISO=drive.iso

all: ${KERNELBIN} ${ISO} run 

${INITASMOBJ}: ${INITASMSRC}
	nasm -felf64 $^ -o $@

${INITCPPOBJ}: kernel/%.cpp.o : kernel/%.cpp
	${GCC} -fno-pie -ffreestanding -c $< -o $@

${DISPLAYOBJ}: kernel/display/%.cpp.o : kernel/display/%.cpp
	${GCC} -fno-pie -ffreestanding -c $< -o $@

${HARDWAREOBJ}: kernel/hardware/%.cpp.o : kernel/hardware/%.cpp
	${GCC} -fno-pie -ffreestanding -c $< -o $@

${KERNELBIN}: ${INITASMOBJ} ${INITCPPOBJ} ${DISPLAYOBJ} ${HARDWAREOBJ}
	${LD} -m elf_x86_64 -Ttext 0x8000 --oformat binary $^ -o $@

${ISO}: ${BOOTSRC} ${KERNELBIN} ${BOOTSRCINC}
	nasm -fbin $< -o $@
	dd if=/dev/zero bs=512 count=1046528 >> $@	
	losetup /dev/loop100 -o 1048576 $@
	mkfs.fat -F 32 /dev/loop100
	mount /dev/loop100 /mnt/osdev
	cp ${KERNELBIN} /mnt/osdev
	umount /mnt/osdev
	losetup -d /dev/loop100

run: ${ISO}
	qemu-system-x86_64 -hda $^

clean:
	rm ${ISO} ${KERNELBIN} ${INITCPPOBJ} ${INITASMOBJ} ${DISPLAYOBJ}
