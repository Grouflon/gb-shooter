IF	!DEF(__STRING_INC_DEF__)
__STRING_INC_DEF__	SET 1

INCLUDE "gbhw.inc"
INCLUDE "display.inc"
INCLUDE "memory.inc"

_FONT_TILES		EQU $9200

SECTION "font",		CODE
font_data:
INCLUDE "font.asm"
font_data_end:

SECTION "string",	CODE

initialize_str:
	; Save LCD_CONTROL state
	ld		a,			[rLCDC]
	push	af

	call	disable_lcd
	; Load font
	ld		hl,	font_data
	ld		de,	_FONT_TILES
	ld		bc,	font_data_end - font_data
	call	mem_copy

	; Restore LCD_CONTROL state
	pop		af
	ld		[rLCDC],	a
	ret

; Print a string on the backgound layer
; b 	- x Position
; c		- y Position
; hl	- Adresse of the null terminated string to print
print_str:
	push	hl
	ld		hl,	_SCRN0

	ld		a,	c
	cp		0
	jr		z,	.end_y
	ld	de,	32
.advance_y
	add	hl,	de
	dec	a
	jr	nz,	.advance_y
.end_y

	ld		a,	b
	cp		0
	jr		z,	.end_x
.advance_x
	inc		hl
	dec		a
	jr		nz,	.advance_x
.end_x

	push	hl
	pop		de
	pop		hl
.print_char
	ld		a,	[hl]
	cp		0
	ret 	z
	
	ld		[de],	a
	inc		de
	inc		hl
	jr		.print_char


ENDC	; __STRING_INC_DEF__
