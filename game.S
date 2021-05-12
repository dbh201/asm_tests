.code16
.section .text
.global _start
_start:
	// Set 8 bit palettized 320x200 video mode
	mov $0x0013,%ax
	int $0x10

	// Create custom palette
	xor %di,%di
	xor %ax,%ax
	xor %bx,%bx

	mov $0x03c8, %dx
	out %al, %dx
	inc %dx
	__next_entry:
	mov %ah, %al
	out %al, %dx
	mov %bl, %al
	out %al, %dx
	mov %bh, %al
	out %al, %dx
	inc %di
	cmp $256,%di
	jae __palette_done

	add $10,%ah
	cmp $60,%ah
	jae __add_bl
	jmp __next_entry
	__add_bl:
	xor %ah,%ah
	add $10,%bl
	cmp $70,%bl
	jae __add_bh
	jmp __next_entry
	__add_bh:
	xor %bl,%bl
	add $10,%bh
	jmp __next_entry

	__palette_done:

	// Set custom palette via BIOS - doesn't work?
/*
	mov $0x4F09, %ax
	mov $0x02,%bl
	mov $256,%cx
	
	xor %dx,%dx
	xor %di,%di
	int $0x10
*/

/* This interrupt allegedly sets the secondary palette...
TODO: find out about "set palette on vertical retrace"
	mov $0x4F09, %ax
	mov $0x80, %bl
	mov $256,%cx
	xor %bx,%bx
	xor %di,%di
	int $0x10
*/
	__col_setup:
	mov $0xA000,%ax
	mov %ax,%es
	xor %bx,%bx
	xor %ax,%ax
	__col:
	mov %al, %es:(%bx,%di)

	__redinc:
	cmp $0x06,%al
	ja __greeninc

	inc %al
	jmp __nextcol

	__greeninc:
	cmp $0x2A,%al
	ja __blueinc

	add $0x06,%al
	jmp __nextcol

	__blueinc:
	add $0x2A,%al
	jc __nextline

	__nextcol:
	inc %di
	cmp $0xFF,%di
	ja __nextline	
	jmp __col

	__nextline:
	cmp $0x7D00,%bx
	jae __ret
	__rightfill:
	mov $0, %es:(%bx,%di)
	inc %di
	cmp $320,%di
	jb __rightfill
	add $320,%bx
	xor %di,%di
	jmp __col
		
	__ret:
	jmp __ret
	
.ascii "0123456789ABCDEF"
.space 510 - (. - _start), 0
.word 0xAA55
