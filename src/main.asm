INCLUDE "gbhw.inc"
INCLUDE "memory.inc"
INCLUDE "display.inc"
INCLUDE "string.inc"

INCLUDE "player.inc"


PLAYER_SPR	EQU _OAMRAM


SECTION "text",	DATA
string:
	DB "Hello World 123!",0


SECTION "sprites",	DATA
sprites:
INCLUDE "sprites.asm"
sprites_end:


SECTION	"main_vars",	BSS


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

	ld		a,		0
	call	player_init

	call	initialize_str

	ld		b,		2
	ld		c,		2
	ld		hl,		string
	call	print_str

	; Set LCD
	ld	a,			LCDCF_ON|LCDCF_BG8800|LCDCF_BG9800|LCDCF_OBJ8|LCDCF_BGON|LCDCF_OBJON
	ld	[rLCDC],	a

loop:
	call	player_update

	call	wait_vblank
	jp		loop

