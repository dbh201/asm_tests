.code16
.section .text
.global _start
_start:
	movb $'S,%al
	mov $0x000F,%bx
	mov $0x0E,%ah
	int $0x10

/*
	mov $0x0000, %ax
	mov %ax, %ss
	mov $0xF000,%bp
	mov %bp,%sp
*/

	movb $'P,%al
	call PrintChar

	mov _const_init,%si
	call PrintString

	movb $'W,%al
	call PrintChar
	call WaitKeypress

	movb $'S,%al
	mov $0x000F,%bx
	mov $0x0E,%ah
	int $0x10
	call Shutdown

	movb $'E,%al
	mov $0x000F,%bx
	mov $0x0E,%ah
	int $0x10
	ret

	__panic:
		jmp __panic

	PrintChar:
		mov $0x000F,%bx
		mov $0x0E,%ah
		int $0x10
		ret
		
	PrintString:
		__PrintString_iter:
		movb %cs:(%si),%al
		cmp $0,%al
		je __PrintString_ret
		call PrintChar
		call WaitKeypress
		inc %si
		jmp __PrintString_iter
		__PrintString_ret:
		mov %si,%ax
		add $0x30,%al
		int $0x10
		ret

	WaitKeypress:
		xor %ah,%ah
		int $0x16
		ret

	Shutdown:
		mov $0x1000, %ax
		mov %ax, %ss
		mov $0xF000, %sp
		mov $0x5307, %ax
		mov $0x0001, %bx
		mov $0x0003, %cx
		int $0x15

_const_init:
.asciz "INIT"
_const_success:
.asciz "VBE OK"
_const_error:
.asciz "VBE ERR"
_const_signature:
.ascii "VESA"
.space 510 - (. - _start), 0
.word 0xAA55
