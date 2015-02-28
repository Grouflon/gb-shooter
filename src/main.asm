INCLUDE "gbhw.inc"
INCLUDE "memory.inc"
INCLUDE "input.inc"
INCLUDE "display.inc"
INCLUDE "string.inc"


SECTION "text",	CODE
string:
	DB "Hello World 123!",0


; Entry point
SECTION "main",	HOME[$0100]
main:
    nop
	jp initialize

	ROM_HEADER	ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE

initialize:
	di
    ld	sp,	$ffff

	; Init Palettes
	ld	a,			%11100100
	ld	[rBGP],		a
	ld	[rOBP0],	a
	ld	a,			%00011011
	ld	[rOBP1],	a

	; Init scroll
	ld	a,		0
	ld	[rSCX],	a
	ld	[rSCY],	a

	call	disable_lcd

	; Empty background
	ld		de,		_SCRN0
	ld		bc,		32*32
	ld		l,		0
	call	mem_fill

	; Empty sprites
	ld		de,		_OAMRAM
	ld		bc,		40*4
	ld		l,		0
	call	mem_fill

	call	initialize_str

	ld		b,		2
	ld		c,		2
	ld		hl,		string
	call	print_str

	; Set LCD
	ld	a,			LCDCF_ON|LCDCF_BG8800|LCDCF_BG9800|LCDCF_OBJ8|LCDCF_BGON
	ld	[rLCDC],	a

loop:
	nop
	jp	loop



