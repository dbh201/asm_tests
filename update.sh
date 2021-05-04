#!/bin/bash
as boot.S -o boot.o &&
ld -Ttext 0x7c00 --oformat binary -o boot.bin boot.o &&
if [ $1  ]; then
	sudo dd if=boot.bin of=/dev/fd0 
else
	echo "compilation was successful but no floppy was written."
fi
