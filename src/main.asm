INCLUDE "extern/gbhw.inc"
INCLUDE "utils/dma.asm"
INCLUDE "utils/memory.asm"
INCLUDE "utils/time.asm"
INCLUDE "utils/display.asm"
INCLUDE "utils/input.asm"
INCLUDE "utils/log.asm"
INCLUDE "utils/macros.asm"
INCLUDE "utils/sound.asm"

BREAK:	MACRO
		ld	b,b
		ENDM

INCLUDE "consts.asm"
INCLUDE "structs.asm"
INCLUDE "ram_map.asm"
INCLUDE "message.asm"
INCLUDE "player.asm"
INCLUDE "bullet.asm"
INCLUDE "enemy.asm"
INCLUDE "collisions.asm"
INCLUDE "game_manager.asm"
INCLUDE "level_controller.asm"
INCLUDE "background_controller.asm"
INCLUDE "score_controller.asm"
INCLUDE "sound_controller.asm"

SECTION "graphics",	DATA
graphics:
sprites:
	INCLUDE "data/sprites_tileset.z80"
sprites_end:
background:
	INCLUDE "data/bg_tileset.z80"
background_end:
graphics_end:

SECTION "backgrounds", DATA
cloud_bg:
	INCLUDE "data/cloudsmap.z80"
cloud_bg_end:

SECTION	"levels", DATA
level:
	INCLUDE "data/level.asm"
level_end:

SECTION	"main_vars",	BSS

SECTION "vblank_interrupt",         HOME[$0040]
	call	dma
	call	vblank_stuff
    reti

SECTION "lcdc_status_interrupt",	HOME[$0048]
	call	lcdc_interrupt
	reti

; Entry point
SECTION "main",	HOME[$0100]
main:
	nop
	jp initialize

	ROM_HEADER	"SPACE SHOOTER", ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE

initialize:
	di
    ld	sp,	$ffff

	; copy dma buffer transfer routine
	call	copy_dma_code

	call	disable_lcd

	; Load sprites tileset
	ld		de,		_VRAM
	ld		bc,		sprites_end - sprites
	ld		hl,		sprites
	call	mem_copy

	; Load background & window tileset
	ld		de,		$8800
	ld		bc,		background_end - background
	ld		hl,		background
	call	mem_copy

game_init:	
	di
    ld		sp,	$ffff
	call	disable_lcd

	; Init Palettes
	ld	a,			%11100100
	ld	[rBGP],		a
	ld	a,			%11001000
	ld	[rOBP0],	a
	ld	a,			%11011011
	ld	[rOBP1],	a

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

	; Load background
	ld		de,		_SCRN0
	ld		bc,		cloud_bg_end - cloud_bg
	ld		hl,		cloud_bg
	call	mem_copy

	; Position window
	ld	a,		135
	ld	[rWY],	a
	
	call	message_init
	call	player_init
	call	enemies_init
	call	bullets_init
	call	game_manager_init
	call	level_controller_init
	call	background_controller_init
	call	score_controller_init

startup:
	; Set LCD
	ld	a,			LCDCF_ON|LCDCF_BG8800|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJON|LCDCF_WIN9C00|LCDCF_WINON
	ld	[rLCDC],	a

	; Enable interrupts
	ld	a,		0
	ld	[rIF],	a
	ld	a,		IEF_VBLANK|IEF_LCDC
	ld	[rIE],	a
	ld	a,		STATF_MODE00
	ld	[rSTAT],a
	ei

; MOUSIC
	; enable sound system
	ld	a,			%10000000
	ld	[rNR52],	a
	; init volumes, both max
	ld	a,			%01110111
	ld	[rNR50],	a
	; init outputs
	ld	a,			%00010001
	ld	[rNR51],	a

loop:

	call	update_input

	call	player_update
	ENEMIES_UPDATE
	call	bullets_update
	call	collisions_update

	call	level_controller_update
	call	game_manager_update

	ld		a,	1
	call	score_add
	call	score_update

	call	player_draw
	BULLETS_DRAW
	ENEMIES_DRAW
	call	game_manager_draw

.wait_frame_end:
	halt
	ld	a,	[rLY]
	cp	144
	jr	c,	.wait_frame_end

	jp		loop

lcdc_interrupt:
	push	af
	call	hblank_stuff
	pop		af
	ret

hblank_stuff:
	ld	a,	[rLY]
	cp	135
	ret	c
	ld	a,	[rLCDC]
	res	1,	a
	ld	[rLCDC], a
	ret

vblank_stuff:
	ld	a,	[rLCDC]
	set	1,	a
	ld	[rLCDC], a
	call	background_controller_update
	call	message_draw
	call	score_draw
	ld		a,		8
	ld		[rWX],	a
	ret
