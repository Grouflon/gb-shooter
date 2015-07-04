INCLUDE "extern/gbhw.inc"
INCLUDE "utils/dma.asm"
INCLUDE "utils/memory.asm"
INCLUDE "utils/time.asm"
INCLUDE "utils/display.asm"
INCLUDE "utils/input.asm"
INCLUDE "utils/macros.asm"

INCLUDE "consts.asm"
INCLUDE "structs.asm"
INCLUDE "ram_map.asm"


LOG:	MACRO
I		SET		0
		push	af
		REPT	STRLEN(\1)
		ld		a,			STRSUB(\1, I+1, 1)
		ld		[_SCRN0+I],	a
I		SET		I+1
		ENDR
		pop		af
		ENDM


INCLUDE "player.asm"
INCLUDE "bullet.asm"


SECTION "graphics",	DATA
graphics:
sprites:
INCLUDE "data/sprites.asm"
sprites_end:
tiles:
INCLUDE "data/tiles.asm"
tiles_end:
font:
INCLUDE "data/font.asm"
font_end:
graphics_end:


SECTION	"main_vars",	BSS


SECTION "vblank_interrupt",           HOME[$0040]
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

	call	disable_lcd

	; Init scroll
	ld	a,		0
	ld	[rSCX],	a
	ld	[rSCY],	a

	; Init window
	ld	a,		0
	ld	[rWX],	a
	ld	[rWY],	a

	; Empty background & window
	ld		de,		_SCRN0
	ld		bc,		32*32
	ld		l,		0
	call	mem_fill
	ld		de,		_SCRN1
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

	; Load tiles data
	ld		de,		$8800
	ld		bc,		tiles_end - tiles
	ld		hl,		tiles
	call	mem_copy

	; Load font data
	ld		de,		FONT_TILES
	ld		bc,		font_end - font
	ld		hl,		font
	call	mem_copy

game_init:
	LOG		"LOG TEST"

	call	player_init
	call	bullets_init

startup:
	; Set LCD
	ld	a,			LCDCF_ON|LCDCF_BG8800|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJON
	ld	[rLCDC],	a

	; Enable interrupts
	ld	a,		IEF_VBLANK
	ld	[rIE],	a
	ei

loop:
	call	update_input

	call	player_update
	call	bullets_update

	call	player_draw
	call	bullets_draw

	halt
	jp		loop
