IF  !DEF(__PLAYER_INC_DEF__)
__PLAYER_INC_DEF__ SET 1

INCLUDE "gbhw.inc"
INCLUDE "input.inc"
INCLUDE "memory.inc"
INCLUDE "bullet.inc"


P_FACING_LEFT	EQU	%00000001
P_FACING_RIGHT	EQU	%00000010
P_FACING_UP		EQU	%00000100
P_FACING_DOWN	EQU	%00001000

P_H_SPRITE		EQU 0
P_V_SPRITE		EQU 1

P_BULLET_COUNT	EQU	5

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
	call	player_update_sprite

.init_bullets
	ld		hl,		P_BULLETS
	ld		de,		B_SIZEOF
	ld		a,		[P_SPR]
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
	pop		af
	inc		b
	add		hl,		de
	dec		a
	jr		.bullet_loop_start

.init_player_end
	ret



player_update_sprite:
	ld		hl,	_OAMRAM
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
	jr	z,	.end
	ld	a,	b
	or OAMF_YFLIP
	ld	b,	a
.end
	ld	a,	b
	ld	[hl],	a
	ret



player_update:
	call	read_input
	push	af
	
	and		PADF_RIGHT
	call	nz,	player_move_right
	
	pop		af
	push	af
	and		PADF_LEFT
	call	nz,	player_move_left

	pop		af
	push	af
	and		PADF_UP
	call	nz,	player_move_up

	pop		af
	and		PADF_DOWN
	call	nz,	player_move_down

	call	player_update_bullets
	call	player_update_sprite
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
	call	bullet_update
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


	
ENDC    ; __PLAYER_INC_DEF__
