.code16
.section .text
.global _start
_start:
	// Interrupt 0x10 with AH=0x00 is the command to set VGA video mode
	// AL is a numerical code for the video mode.
	// AL=0x00 is text mode, 40 columns by 25 rows, 16 colours, and 8 display pages
	// The exact pixel count for this mode depends on the video card used, but for
	// VGA cards is 360x400 with 9x16 pixel boxes.

	mov $0x0000,%ax
	int $0x10

	// create a stack, so we can push, pop, call, and ret
	// This stack is arbitrarily set at 1000:FFFF, and grows downward
	mov $0x1000,%ax
	mov %ax,%ss
	or $0xFFFF,%sp

	// set the string-move source to our custom keyboard interrupt
	// 07C0:0000 is the location of our boot sector (0x7C00)
	mov $0x07C0,%ax
	mov %ax,%ds
	mov $kbd_int,%si

	//set destination to 2000:0000 (0x20000)
	mov $0x2000,%ax
	mov %ax,%es
	xor %di,%di

	// set the rep instruction to repeat for the number of bytes in the keyboard interrupt
	mov kbd_int_len,%cx
	
	//move, byte by byte, the code within our keyboard interrupt to 2000:0000
	//TODO: make this 2 byte aligned w/ movsw
	// It should also be noted that this is *actually unnecessary* - we could simply use
	// the boot sector's copy of the interrupt code
	// This just shows that yes, you can move code around and call it arbitrarily

	rep movsb %ds:(%si),%es:(%di)
	
	// get current keyboard interrupt vector	
	// keyboard vector is at 0000:0024
	xor %ax,%ax
	mov %ax,%es
	mov $0x0024,%di
	

	//store segment in %cx, offset in %bx
	//2-byte offset is stored first, then 2-byte segment
	movw %es:(%di),%bx
	movw %es:2(%di),%cx
	
	//print the segment:offset found
	//This is expected to be F000:E987
	push %di
	mov $160,%di
	call print_keyboard_vector
	pop %di
	
	//change segment:offset to 2000:0000

	//%cx is segment, %bx is offset
	mov $0x2000,%cx
	mov $0x0000,%bx

	// Move it into the interrupt vector table
	// offset first, then segment
	movw %bx,%es:(%di)
	movw %cx,%es:2(%di)

	//retrieve it again and check if it's correct
	// If our move worked, then this should print 2000:0000
	movw %es:(%di),%bx
	movw %es:2(%di),%cx
	mov $320,%di
	call print_keyboard_vector

	// do my favourite thing
	__panic:
	cmp %ds
	jmp __panic

	// We're done now, and can just wait for an interrupt to come
	
	//what happens if we press a key now?
	//TODO: how can we override the CPU-generated INT 09 (co-processor segment overrun), since the APIC takes over INT 09?

// This prints %cx:%bx as  xxxx:xxxx
// Not necessarily a keyboard vector; simply dumps the two registers in seg:off format
print_keyboard_vector:
	push %es

	push %bx
	mov $0xB800,%bx
	mov %bx,%es
	pop %bx
	
	//print segment which is in %cx
	mov %ch,%al
	lcall $0x07C0, $printnum
	add $4, %di

	mov %cl,%al
	lcall $0x07C0, $printnum
	add $4, %di
	
	//print segment-offset separator
	movb $':,%es:0(%di)
	movb $'?,%es:1(%di)
	add $2, %di

	//print offset which is in %bx
	mov %bh,%al
	lcall $0x07C0, $printnum
	add $4, %di

	mov %bl,%al
	lcall $0x07C0, $printnum

	pop %es
	ret
// Prints %al as a 2 digit hex to %es:(%di),with a specific colour code
printnum:
	push %bx
	mov %al,%ah

	shr $4,%al
	cmp $0x09,%al
	cmova hex_char,%bx
	cmovbe digit,%bx
	add %bl,%al
	movb %al,%es:(%di)
	movb $'?,%es:1(%di)
	
	mov %ah,%al

	and $0x0F,%al
	cmp $0x09,%al
	cmova hex_char,%bx
	cmovbe digit,%bx
	add %bl,%al
	movb %al,%es:2(%di)
	movb $'?,%es:3(%di)

	pop %bx
	retf

kbd_int:
	push %di
	push %bx
	push %ax
	push %es

	// Set up extended segment to point to video memory
	// this lets us use the printnum subroutine
	mov $0xB800, %bx
	mov %bx,%es

	// Interrupt count should be located right after the retf in this subroutine
	// Since this code is relocated, can we assume that the offset is relative to the first
	// Instruction? 

	// If the CS:IP state is 2000:0000 on entry, then yes! It ought to be as well, since 
	// our IVT entry is 2000:0000. 
	// Increment the interrupt count
	incw interrupt_count

	// Can we actually read the interrupt count?
	mov %ds:interrupt_count, %bx
	// If it's zero, then something's wrong with the memory
	cmp $0,%bx
	je __kbd_err

	// The 'S' stands for 'success'
	mov $20,%di
	mov $'S,%al
	mov $'?,%ah
	mov %ax, %es:(%di)
	add $2, %di

	// write the interrupt count to screen
	
	// HO byte
	mov %bh,%al
	lcall $0x07C0, $printnum
	add $4, %di

	// LO byte
	mov %bl,%al
	lcall $0x07C0, $printnum
	add $4, %di



	// skip error code
	jmp __kbd_no_err

	__kbd_err:	
	// if we're executing this, we have no idea what the 
	// processor state is. re-set up %es, then call
	// printnum to give an error code
	mov $0xB800, %bx
	mov %bx,%es
	mov $0xEE,%al
	mov $20,%di
	lcall $0x07C0, $printnum

	__kbd_no_err:

	// The original BIOS keyboard handler doesn't seem to return properly...
	// TODO: see if we can actually call this and have it return
	/*
	push %di
	push %es
	lcall $0xF000, $0xE987
	pop %es
	pop %di
	*/

	// The 'F' stands for 'Finito'
	mov $'F,%al
	mov $'?,%ah
	mov %ax, %es:(%di)

	// restore processor state
	pop %es
	pop %ax
	pop %bx
	pop %di
	// return to wherever we were before
	retf
	interrupt_count:
		.word 0x0000
kbd_int_len:
	.word (. - kbd_int)
hex_char:
	.word 0x0037
digit:
	.word 0x0030
error_disp:
	.word 0x4545
.space 510 - (. - _start), 0
.word 0xAA55
