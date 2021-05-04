.code16
.section .text
.global _start
_start:
	push %bp
	mov _const_init,%bp
	call PrintString
	pop %bp
	call SetDisplayMode
	call WaitKeypress
	call Shutdown
	__panic:
		jmp __panic

	SetDisplayMode:
		mov $0x4F00,%ax
		push %es
		mov $0x1000,%dx
		mov %dx,%es
		mov $0x0000,%di
		int $0x10
		mov %di,%dx
		push %bp
		cmp $0x004F,%ax
		cmovne _const_error,%bp
		cmove _const_success,%bp
		pop %bp
		pop %es
		call PrintString
		
	PrintString:
		push %ax
		push %bx
		push %cx
		push %dx
		mov $0x000F,%bx
		mov $0x1301,%ax
		call GetStringLength
		xor %dx,%dx
		int $0x10
		pop %dx
		pop %cx
		pop %bx
		pop %ax
		ret

	GetStringLength:
		xor %cx,%cx
		push %di
		__GetStringLength_iter:
		cmpb $0x00,%es:(%di)
		je __GetStringLength_ret
		inc %cx
		inc %di
		jmp __GetStringLength_iter
		__GetStringLength_ret:
		pop %di
		ret

	WaitKeypress:
		push %ax
		xor %ah,%ah
		int $0x16
		pop %ax
		ret

	Shutdown:
		mov $0x1000, %ax
		mov %ss, %ax
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
