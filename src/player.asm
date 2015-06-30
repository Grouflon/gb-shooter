IF  !DEF(__PLAYER_DEF__)
__PLAYER_DEF__ SET 1

INCLUDE "extern/gbhw.inc"
INCLUDE "utils/dma.asm"
INCLUDE "utils/input.asm"
INCLUDE "utils/memory.asm"
INCLUDE "bullet.asm"


P_FACING_LEFT	EQU	%00000001
P_FACING_RIGHT	EQU	%00000010
P_FACING_UP		EQU	%00000100
P_FACING_DOWN	EQU	%00001000

P_H_SPRITE		EQU 0
P_V_SPRITE		EQU 1

P_BULLET_COUNT	EQU	15

SECTION "player_vars",	BSS
P_SPR:		DS 1
P_X:		DS 1
P_Y:		DS 1
P_FACING:	DS 1
P_BULLETS:
REPT P_BULLET_COUNT		
DS B_SIZEOF
ENDR



SECTION "player", CODE


; a		- Player sprite number
player_init:
.init_player
	ld		[P_SPR],	a
	ld		a,			40
	ld		[P_X],		a
	ld		[P_Y],		a
	ld		a,			P_FACING_LEFT
	ld		[P_FACING],	a

.init_bullets
	ld		hl,		P_BULLETS
	ld		de,		B_SIZEOF
	ld		a,		[P_SPR]
	ld		c,		0
	ld		b,		a
	inc		b
	ld		a,		P_BULLET_COUNT
.bullet_loop_start
	cp		0
	jr		z,		.init_player_end
	push	af
	push	de
	push	bc
	push	hl
	call	bullet_init
	pop		hl
	pop		bc
	pop		de

	ld		a,	c
	add		a, 	10
	ld		c,	a

	pop		af
	push	bc
	push	hl
	push	af
	ld		a,	c
	ld		b,	a
	call	bullet_set_position
	pop		af
	pop		hl
	pop		bc

	inc		b
	add		hl,		de
	dec		a
	jr		.bullet_loop_start

.init_player_end
	ret



player_draw:
	call	player_draw_bullets

	ld		hl,	OAM_BUFFER
	ld		bc,	4
	ld		a,	[P_SPR]
	call	find_address

.update_sprite
	; Y
	ld	a,		[P_Y]
	ld	[hl],	a

	; X
	inc	hl
	ld	a,		[P_X]
	ld	[hl],	a

	; Sprite number
	inc	hl
	ld	a,	[P_FACING]
	cp	P_FACING_LEFT
	jr	z, .sprite_horizontal
	cp	P_FACING_RIGHT
	jr	z, .sprite_horizontal
	cp	P_FACING_UP
	jr	z, .sprite_vertical
	cp	P_FACING_DOWN
	jr	z, .sprite_vertical
.sprite_horizontal
	ld	a,	P_H_SPRITE
	jr	.sprite_number_end
.sprite_vertical
	ld	a,	P_V_SPRITE
.sprite_number_end
	ld	[hl], a

	; Attributes
	inc	hl
	ld	b,	OAMF_PAL0
	ld	a,	[P_FACING]
	ld	c,	a
	cp  P_FACING_LEFT
	jr	nz,	.attr_vertical
	ld	a,	b
	or	OAMF_XFLIP
	ld	b,	a
.attr_vertical
	ld	a,	c
	cp	P_FACING_UP
	jr	z,	.attr_end
	ld	a,	b
	or OAMF_YFLIP
	ld	b,	a
.attr_end
	ld	a,	b
	ld	[hl],	a

	ret


player_draw_bullets:
	ld		hl,	P_BULLETS
	ld		de,	B_SIZEOF
	ld		a,	P_BULLET_COUNT
.p_draw_bullets_loop
	cp		0
	jr		z,	.p_draw_bullets_end
	push	hl
	push	de
	push	af
	call	bullet_draw
	pop		af
	pop		de
	pop		hl
	add		hl,	de
	dec		a
	jr		.p_draw_bullets_loop
.p_draw_bullets_end	
	ret



player_update:
	ld		a,	[INPUT]
	and		PADF_RIGHT
	call	nz,	player_move_right
	
	ld		a,	[INPUT]
	and		PADF_LEFT
	call	nz,	player_move_left

	ld		a,	[INPUT]
	and		PADF_UP
	call	nz,	player_move_up

	ld		a,	[INPUT]
	and		PADF_DOWN
	call	nz,	player_move_down

	ld		a,	[INPUT_PRESSED]
	and		PADF_B
	call	nz,	player_fire_bullet

	call	player_update_bullets
	ret



player_update_bullets:
	ld		a,		P_BULLET_COUNT
	ld		hl,		P_BULLETS
	ld		de,		B_SIZEOF
.p_bullet_update_loop
	cp		0
	jr		z,	.p_bullet_update_end
	push	af
	push	de
	push	hl
	call	bullet_update
	pop		hl
	pop		de
	pop		af
	dec		a
	add		hl,		de
	jr		.p_bullet_update_loop
.p_bullet_update_end
	ret



player_move_right:
	ld		a,			[P_X]
	inc		a
	cp		160
	ret		z
	ld		[P_X],		a
	ld		a,			P_FACING_RIGHT
	ld		[P_FACING],	a
	ret



player_move_left:
	ld		a,			[P_X]
	cp		8
	ret		z
	dec		a
	ld		[P_X],		a
	ld		a,			P_FACING_LEFT
	ld		[P_FACING],	a
	ret



player_move_up:
	ld		a,			[P_Y]
	cp		16
	ret		z
	dec		a
	ld		[P_Y],		a
	ld		a,			P_FACING_UP
	ld		[P_FACING],	a
	ret

	

player_move_down:
	ld		a,			[P_Y]
	cp		152
	ret		z
	inc		a
	ld		[P_Y],		a
	ld		a,			P_FACING_DOWN
	ld		[P_FACING],	a
	ret


player_fire_bullet:
	ld		hl,		P_BULLETS
	ld		a,		P_BULLET_COUNT
	ld		de,		B_SIZEOF
.p_bullet_fire_loop
	cp		0
	jr		z,	.p_bullet_fire_end
	push	af
	push	de
	push	hl

	call	bullet_is_enabled
	cp		0
	jr		nz,	.p_bullet_fire_continue

	pop		hl
	push	hl
	ld		a,	[P_X]
	ld		b,	a
	ld		a,	[P_Y]
	call	bullet_set_position

	pop		hl
	push	hl
	ld		a,	[P_FACING]
	call	bullet_set_facing

	pop		hl
	push	hl
	ld		a,	1
	call	bullet_set_enabled

	pop		hl
	pop		de
	pop		af
	jr		.p_bullet_fire_end

.p_bullet_fire_continue
	pop		hl
	pop		de
	pop		af
	dec		a
	add		hl,		de
	jr		.p_bullet_fire_loop
.p_bullet_fire_end
	ret


	
ENDC    ; __PLAYER_INC_DEF__
