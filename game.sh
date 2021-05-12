as game.S -o game.o && ld -Ttext 0 --oformat binary -o game.bin game.o && rm game.o && qemu-system-i386 game.bin
