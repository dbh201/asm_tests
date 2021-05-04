.code16
.section .text
.global _start
_start:

	mov $0x07C0,%ax
	mov %ax,%es

	mov %cs,%si
	call DumpSI
	call Newline

	mov %ds,%si
	call DumpSI
	call Newline

	mov %es,%si
	call DumpSI
	call Newline

	mov %ss,%si
	call DumpSI
	call Newline


/*
	mov $0x0000,%ax
	mov %ax,%ss
	mov $0xF000,%bp
	mov %bp,%sp
*/

	movb $'P,%al
	call PrintChar

	mov $_const_label,%si
	call PrintString
	mov _string,%si
	call DumpSI
	call Newline
	mov $_const_label,%si
	call PrintString
	mov _string2,%si
	call DumpSI
	call Newline

	mov $_const_dseg_offset,%si
	call PrintString
	mov %es:_string,%si
	call DumpSI
	call Newline
	mov $_const_dseg_offset,%si
	call PrintString
	mov %es:_string2,%si
	call DumpSI
	call Newline

	mov $_const_cseg_offset,%si
	call PrintString
	mov %cs:_string,%si
	call DumpSI
	call Newline
	mov $_const_cseg_offset,%si
	call PrintString
	mov %cs:_string2,%si
	call DumpSI
	call Newline

	mov $_const_variable,%si
	call PrintString
	mov $_string,%si
	call DumpSI
	call Newline
	mov $_const_variable,%si
	call PrintString
	mov $_string2,%si
	call DumpSI
	call Newline

	call WaitKeypress
	call Shutdown

	movb $'E,%al
	mov $0x000F,%bx
	mov $0x0E,%ah
	int $0x10
	hlt
	__panic:
		jmp __panic

	Newline:
		mov $0x000F,%bx
		mov $0x0E0A,%ax
		int $0x10
		mov $0x0D,%al
		int $0x10
		ret 

	PrintChar:
		mov $0x000F,%bx
		mov $0x0E,%ah
		int $0x10
		ret

	DumpSI:
		push %cx
		mov $16, %cl
		__DumpSI_loop:
		mov %si, %ax
		sub $4,%cl
		shr %cl, %ax
		and $0x0F, %al
		cmp $10, %al
		jb __DumpSI_digit
		add $7,%al
		__DumpSI_digit:
		add $0x30, %al
		call PrintChar
		cmp $0,%cl
		ja __DumpSI_loop
		pop %cx
		ret
		
	PrintString:
		movb (%si),%al
		cmp $0,%al
		je __PrintString_ret
		call PrintChar
		inc %si
		jmp PrintString
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

_string:
.asciz "Test string"
_string2:
.asciz "Another string"
_const_variable:
.asciz "mov $_string, %si: "
_const_label:
.asciz "mov _string, %si: "
_const_cseg_offset:
.asciz "mov %cs:_string, %si: "
_const_dseg_offset:
.asciz "mov %es:_string, %si: "
.space 510 - (. - _start), 0
.word 0xAA55
