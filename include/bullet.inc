IF  !DEF(__BULLET_INC_DEF__)
__BULLET_INC_DEF__ SET 1

INCLUDE "gbhw.inc"
INCLUDE "dma.inc"
INCLUDE "memory.inc"

B_FACING_LEFT	EQU	%00000001
B_FACING_RIGHT	EQU	%00000010
B_FACING_UP		EQU	%00000100
B_FACING_DOWN	EQU	%00001000

B_SPRITE		EQU 2

			RSRESET
B_ENABLED	RB 1
B_SPR		RB 1
B_Y			RB 1
B_X			RB 1
B_FACING	RB 1
B_SIZEOF	RB 0
		


SECTION "bullet", CODE

; hl	- Bullet struct address
; b		- Sprite index
bullet_init:
.b_enabled
	ld		a,		0
	ld		[hl],	a
.b_sprite_index
	inc		hl
	ld		a,		b
	ld		[hl],	a
.b_coords
	inc		hl
	ld		a,		0
	ld		[hl],	a
	inc		hl
	ld		[hl],	a
.b_facing
	inc		hl
	ld		a,		B_FACING_UP
	ld		[hl],	a
.b_init_end
	ret


; hl	- Bullet struct address
; a		- y
; b		- x
bullet_set_position:
	inc		hl
	inc		hl
	ld		[hl],	a
	inc		hl
	ld		a,		b
	ld		[hl],	a
	ret



; hl	- Bullet struct address
; a		- enabled value
bullet_set_enabled:
	ld	[hl],	a
	ret



; hl	- Bullet struct address
; a		- return value
bullet_is_enabled:
	ld	a,	[hl]
	ret



; hl	- Bullet struct address
; a		- facing value
bullet_set_facing:
	ld	de,		B_FACING
	add	hl,		de
	ld	[hl],	a
	ret



; hl	- Bullet struct address
bullet_update:
	; do not update if disabled
	ld		a,		[hl]
	cp		0
	ret		z

	push	hl
	inc		hl
	inc		hl
	ld		a,	[hl]
	ld		b,	a
	inc		hl
	ld		a,	[hl]
	ld		c,	a
	inc		hl
	ld		a,	[hl]
	cp		B_FACING_LEFT
	jr		z,	.b_move_left
	cp		B_FACING_RIGHT
	jr		z,	.b_move_right
	cp		B_FACING_UP
	jr		z,	.b_move_up
	cp		B_FACING_DOWN
	jr		z,	.b_move_down
.b_move_left
	dec		c
	jr		.b_apply_movement
.b_move_right
	inc		c
	jr		.b_apply_movement
.b_move_up
	dec		b
	jr		.b_apply_movement
.b_move_down
	inc		b

.b_apply_movement	
	pop		hl
	push	hl
	inc		hl
	inc		hl
	ld		a,		b
	ld		[hl],	a
	inc		hl
	ld		a,		c
	ld		[hl],	a

	pop		hl
	call	bullet_check_death

	ret

; hl	- Bullet struct address
bullet_check_death:
	; Do nothing if disabled
	ld		a,	[hl]
	cp		0
	ret		z

	push	hl
	inc		hl
	inc		hl
	ld		a,	[hl]
	cp		8
	jr		c,	.b_dead
	cp		161
	jr		nc,	.b_dead
	inc		hl
	ld		a,	[hl]
	cp		0
	jr		c,	.b_dead
	cp		169
	jr		nc,	.b_dead
	pop		hl
	ret
.b_dead
	pop		hl
	ld		a,		0
	ld		[hl],	a
	inc		hl
	inc		hl
	ld		a,		0
	ld		[hl],	0
	inc		hl
	ld		[hl],	0
	ret



; hl	- Bullet struct address
bullet_draw:
	; don't draw if disabled
	ld		a,		[hl]
	cp		0
	ret		z

	push	hl
	pop		de
	inc		de
	ld		hl,		OAM_BUFFER
	ld		bc,		4
	ld		a,		[de]
	call	find_address
	
	inc		de
	; Y
	ld		a,		[de]
	ld		[hl],	a
	; X
	inc		de
	inc		hl
	ld		a,		[de]
	ld		[hl],	a
	; Sprite num
	inc		hl
	ld		a,		B_SPRITE
	ld		[hl],	a

	ret



ENDC    ; __BULLET_INC_DEF__
