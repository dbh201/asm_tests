.code16
.section .text
.global _start
_start:
	
	push %ds
	push %ax
	mov $0x07C0,%ax
	mov %ax,%ds
	pop %ax

	mov %ax,0xF000
	pop %ax
	mov %bx,0xF002
	mov %cx,0xF004
	mov %dx,0xF006
	
	mov %si,0xF008
	mov %di,0xF00A
	
	mov %bp,0xF00C
	mov %sp,0xF00E

	mov %cs,0xF010
	mov %ax,0xF012
	mov %es,0xF014
	mov %fs,0xF016
	mov %gs,0xF018
	mov %ss,0xF01A

	mov $_str_AX,%si
	call PrintString
	mov 0xF000,%bx
	call DumpBX
	call Tab

	movb $'B,_str_AX
	call PrintString
	mov 0xF002,%bx
	call DumpBX
	call Newline
	call WaitKeypress

	movb $'C,_str_AX
	call PrintString
	mov 0xF004,%bx
	call DumpBX
	call Tab

	movb $'D,_str_AX
	call PrintString
	mov 0xF006,%bx
	call DumpBX
	call Newline
	call WaitKeypress

	mov $_str_SI,%si
	call PrintString
	mov 0xF008,%bx
	call DumpBX
	call Tab

	mov $_str_DI,%si
	call PrintString
	mov 0xF00A,%bx
	call DumpBX
	call Newline
	call WaitKeypress

	mov $_str_BP,%si
	call PrintString
	mov 0xF00C,%bx
	call DumpBX
	call Tab

	mov $_str_SP,%si
	call PrintString
	mov 0xF00E,%bx
	call DumpBX
	call Newline
	call WaitKeypress

	mov $_str_CS,%si
	call PrintString
	mov 0xF010,%bx
	call DumpBX
	call Tab

	movb $'D,_str_CS
	call PrintString
	mov 0xF012,%bx
	call DumpBX
	call Newline
	call WaitKeypress

	movb $'E,_str_CS
	call PrintString
	mov 0xF014,%bx
	call DumpBX
	call Tab

	movb $'F,_str_CS
	call PrintString
	mov 0xF016,%bx
	call DumpBX
	call Newline
	call WaitKeypress

	movb $'G,_str_CS
	call PrintString
	mov 0xF018,%bx
	call DumpBX
	call Tab

	mov $_str_SS,%si
	call PrintString
	mov 0xF01A,%bx
	call DumpBX
	call Newline
	call WaitKeypress


	mov $_str_press_any_key,%si
	call PrintString
	call WaitKeypress
	mov $_str_shutting_down,%si
	call PrintString
	call Shutdown

	Tab:
		mov $' ,%al
		call PrintChar	
		call PrintChar
		call PrintChar
		call PrintChar
		ret

	Newline:
		mov $0x0A,%al
		call PrintChar
		mov $0x0D,%al
		call PrintChar
		ret 

	PrintChar:
		mov $0x000F,%bx
		mov $0x0E,%ah
		int $0x10
		ret

	DumpBX:
		mov $16, %cl
		__DumpBX_loop:
		mov %bx, %ax
		sub $4,%cl
		shr %cl, %ax
		and $0x0F, %al
		cmp $10, %al
		jb __DumpBX_digit
		add $7,%al
		__DumpBX_digit:
		add $0x30, %al
		call PrintChar
		cmp $0,%cl
		ja __DumpBX_loop
		ret
		
	PrintString:
		mov %si, %bx
		__PrintString_loop:
		movb (%bx),%al
		cmp $0,%al
		je __PrintString_ret
		call PrintChar
		inc %bx
		jmp __PrintString_loop
		__PrintString_ret:
		ret

	WaitKeypress:
		xor %ah,%ah
		int $0x16
		ret

	Shutdown:
		mov $0xF000, %sp
		mov $0x5307, %ax
		mov $0x0001, %bx
		mov $0x0003, %cx
		int $0x15
		hlt

_str_AX:
.asciz "AX: "
_str_SI:
.asciz "SI: "
_str_DI:
.asciz "DI: "
_str_BP:
.asciz "BP: "
_str_SP:
.asciz "SP: "
_str_CS:
.asciz "CS: "
_str_SS:
.asciz "SS: "
_str_press_any_key:
.asciz "Press any key\r\n"
_str_shutting_down:
.asciz "ACPI shutdown\r\n"
.space 510 - (. - _start), 0
.word 0xAA55
