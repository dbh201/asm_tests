as kbd.S -o kbd.o && ld -Ttext 0 --oformat binary -o kbd.bin kbd.o && rm kbd.o && qemu-system-i386 kbd.bin
