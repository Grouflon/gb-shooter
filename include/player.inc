IF  !DEF(__PLAYER_INC_DEF__)
__PLAYER_INC_DEF__ SET 1

INCLUDE "gbhw.inc"
INCLUDE "input.inc"

P_FACING_LEFT	EQU	0
P_FACING_RIGHT	EQU	1
P_FACING_UP		EQU	2
P_FACING_DOWN	EQU	3

P_H_SPRITE		EQU 0
P_V_SPRITE		EQU 1

SECTION "player_vars",	BSS
P_SPR:		DS 1
P_X:		DS 1
P_Y:		DS 1
P_FACING:	DS 1


SECTION "player", CODE
; a		- Player sprite number
player_init:
	ld		[P_SPR],	a
	ld		a,			40
	ld		[P_X],		a
	ld		[P_Y],		a
	ld		a,			P_FACING_LEFT
	ld		[P_FACING],	a

	call	player_update_sprite
	ret

player_update_sprite:
	ld	hl,	_OAMRAM
	ld	bc,	4
	ld	a,	[P_SPR]

.find_sprite
	cp	0
	jr	z,	.update_sprite
	add	hl,	bc
	dec	a
	jr	.find_sprite

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

	call	player_update_sprite
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
