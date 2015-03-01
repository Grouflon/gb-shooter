INCLUDE "gbhw.inc"
INCLUDE "dma.inc"
INCLUDE "memory.inc"
INCLUDE "time.inc"
INCLUDE "display.inc"
INCLUDE "string.inc"
INCLUDE "player.inc"


PLAYER_SPR	EQU 0

SECTION "text",	DATA
string:
	DB "Hello World 123!",0


SECTION "sprites",	DATA
sprites:
INCLUDE "sprites.asm"
sprites_end:


SECTION	"main_vars",	BSS


SECTION "vblank_interrupt",           HOME[$0040]
    ;call    player_draw
	call	dma
    reti

; Entry point
SECTION "main",	HOME[$0100]
main:
    nop
	jp initialize

	ROM_HEADER	ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE

initialize:
	di
    ld	sp,	$ffff

	; copy dma buffer transfer routine
	call	copy_dma_code

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
	ld		de,		OAM_BUFFER
	ld		bc,		40*4
	ld		l,		0
	call	mem_fill

	; Load sprites data
	ld		de,		_VRAM
	ld		bc,		sprites_end - sprites
	ld		hl,		sprites
	call	mem_copy

	ld		a,		PLAYER_SPR
	call	player_init

	call	initialize_str

	ld		b,		2
	ld		c,		2
	ld		hl,		string
	call	print_str

	; Set LCD
	ld	a,			LCDCF_ON|LCDCF_BG8800|LCDCF_BG9800|LCDCF_OBJ8|LCDCF_BGON|LCDCF_OBJON
	ld	[rLCDC],	a

	; Enable interrupts
	ld	a,		IEF_VBLANK
	ld	[rIE],	a
	ei


loop:
	call	player_update
	call	player_draw

	halt
;	call	wait_vblank
	jp		loop
