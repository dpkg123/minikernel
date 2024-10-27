all: os-image.bin

boot.o: boot.asm
	nasm -f elf boot.asm -o boot.o

kernel.o: kernel.c
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o

os-image.bin: boot.o kernel.o
	ld -m elf_i386 -T linker.ld -Ttext 0x7c00 --oformat binary boot.o kernel.o -o os-image.bin

run: os-image.bin
	qemu-system-i386 -drive format=raw,file=os-image.bin -serial stdio

clean:
	rm -f *.o os-image.bin

