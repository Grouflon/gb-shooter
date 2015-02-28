INCLUDE "gbhw.inc"
INCLUDE "memory.inc"
INCLUDE "input.inc"
INCLUDE "display.inc"
INCLUDE "string.inc"

PAD		EQU	_RAM

SPR_Y	EQU _OAMRAM
SPR_X	EQU _OAMRAM+1
SPR_NUM	EQU _OAMRAM+2
SPR_ATT	EQU _OAMRAM+3


SECTION "text",	CODE
string:
	DB "Hello World 123!",0


SECTION "sprites",	CODE
sprites:
INCLUDE "sprites.asm"
sprites_end:


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
	ld	a,			%11001000
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

	; Load sprites data
	ld		de,		_VRAM
	ld		bc,		sprites_end - sprites
	ld		hl,		sprites
	call	mem_copy

	ld		a,			40
	ld		[SPR_X],	a
	ld		[SPR_Y],	a
	ld		a,			0
	ld		[SPR_NUM],	a
	ld		a,			OAMF_PAL0
	ld		[SPR_ATT],	a
	

	call	initialize_str

	ld		b,		2
	ld		c,		2
	ld		hl,		string
	call	print_str

	; Set LCD
	ld	a,			LCDCF_ON|LCDCF_BG8800|LCDCF_BG9800|LCDCF_OBJ8|LCDCF_BGON|LCDCF_OBJON
	ld	[rLCDC],	a

loop:
	call	read_input
	ld		[PAD],	a

	ld		a,	[PAD]
	and		PADF_LEFT
	call	nz,		move_left

	ld		a,	[PAD]
	and		PADF_RIGHT
	call	nz,		move_right

	ld		a,	[PAD]
	and		PADF_UP
	call	nz,		move_up

	ld		a,	[PAD]
	and		PADF_DOWN
	call	nz,		move_down

	call	wait_vblank
	jp		loop


move_left:
	ld		a,	[SPR_X]
	cp		8
	ret		z
	dec		a
	ld		[SPR_X],	a

	ld		a,			[SPR_ATT]
	set		5,			a
	ld		[SPR_ATT],	a
	ld		a,			0
	ld		[SPR_NUM],	a
	ret

move_right:
	ld		a,	[SPR_X]
	cp		160
	ret		z
	inc		a
	ld		[SPR_X],	a

	ld		a,			[SPR_ATT]
	res		5,			a
	ld		[SPR_ATT],	a
	ld		a,			0
	ld		[SPR_NUM],	a
	ret

move_up:
	ld		a,	[SPR_Y]
	cp		16
	ret		z
	dec		a
	ld		[SPR_Y],	a

	ld		a,			[SPR_ATT]
	res		6,			a
	ld		[SPR_ATT],	a
	ld		a,			1
	ld		[SPR_NUM],	a
	ret

move_down:
	ld		a,	[SPR_Y]
	cp		152
	ret		z
	inc		a
	ld		[SPR_Y],	a

	ld		a,			[SPR_ATT]
	set		6,			a
	ld		[SPR_ATT],	a
	ld		a,			1
	ld		[SPR_NUM],	a
	ret


