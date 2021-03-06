IF  !DEF(__BULLET_DEF__)
__BULLET_DEF__ SET 1


SECTION "bullet", CODE

;	hl - struct address
bullet_init:
	ld		a,		0				; Bullet on
	ldi		[hl],	a
	ld		a,		0				; Bullet coords
	ldi		[hl],	a
	ldi		[hl],	a
	ld		a,		BULLET_SPRITE	; Bullet sprite number
	ldi		[hl],	a
	ld		a,		0
	ldi		[hl],	a	; Speed carry
	ld		a,		BULLET_FACING_UP ; Bullet Facing
	ld		[hl],	a
	ret

bullets_init:
	FOR		v_bullet_array, BULLETS_MAX, s_bullet_SIZEOF, bullet_init
	ret


; a		- facing
; b		- x
; c		- y
bullet_create:
	push	af
	ld		hl,	v_bullet_array
	ld		a,	BULLETS_MAX
.bullet_find:
	cp		0
	jr		z,	.bullet_not_found
	push	af

	ld		a,	[hl]
	cp 		0
	jr		z,	.bullet_found
	ld		de,	s_bullet_SIZEOF
	add		hl,	de
	pop		af
	dec		a
	jr		.bullet_find

.bullet_found:
	pop		af
	;	Enabled
	ld		a,		1
	ldi		[hl],	a
	;	Y
	ld		a,		c
	ldi		[hl],	a
	;	X
	ld		a,		b
	ldi		[hl],	a
	;	Carry
	inc	hl
	ld		a,		0
	ldi		[hl],	a
	;	Facing
	pop		af
	ld		[hl],	a
	ret

.bullet_not_found
	pop		af
	ret


; hl	- struct address
bullet_update:
	ld		a,		[hl]
	cp		0
	ret		z

	push	hl
	inc		hl
	ld		a,	[hl]
	inc		hl
	ld		b,	a		; Y Position in b
	ld		a,	[hl]
	inc		hl
	ld		c,	a		; X Position in c
	inc		hl
; carry
	ld		a,	[hl]
	add		BULLET_SPEED
	ld		d,	a		; Carry in d
	res		0,	a
	SWP8	d,	a
	sub		a,	d
	ld		[hl],	a
	rr		d
	inc		hl
; Facing
	ld		a,	[hl]
	cp		BULLET_FACING_LEFT
	jr		z,	.b_move_left
	cp		BULLET_FACING_RIGHT
	jr		z,	.b_move_right
	cp		BULLET_FACING_UP
	jr		z,	.b_move_up
	cp		BULLET_FACING_DOWN
	jr		z,	.b_move_down
.b_move_left
	ld		a,	c
	sub		d
	ld		c,	a
	jr		.b_apply_movement
.b_move_right
	ld		a,	c
	add		d
	ld		c,	a
	jr		.b_apply_movement
.b_move_up
	ld		a,	b
	sub		d
	ld		b,	a
	jr		.b_apply_movement
.b_move_down
	ld		a,	b
	add		d
	ld		b,	a

.b_apply_movement	
	pop		hl
	push	hl
	inc		hl
	ld		a,		b
	ldi		[hl],	a
	ld		a,		c
	ld		[hl],	a

	pop		hl
	push	hl
	call	bullet_check_death
	pop		hl
	call	z,	bullet_reset
	ret
	

bullets_update:
	FOR		v_bullet_array, BULLETS_MAX, s_bullet_SIZEOF, bullet_update
	ret

; hl	- Bullet struct address
; f		- z if dead, nz if not
bullet_check_death:
	; Do nothing if disabled
	ld		a,	[hl]
	cp		0
	ret		z

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

	ld		a,	1
	cp		0
	ret

.b_dead
	ld		a,	0
	cp		0
	ret

; hl	- Bullet struct address
bullet_reset:
	ld		a,		0
	ldi		[hl],	a
	ldi		[hl],	a
	ldi		[hl],	a
	inc		hl
	ld		[hl],	a
	ret


; hl	- Struct address
; de	- OAM buffer struct address
bullet_draw:
	; don't draw if disabled
	ld		a,		[hl]
	cp		0
	jp		z,	.off

	; Y pos
	inc		hl
	ld		a,		[hl]
	ld		[de],	a

	; X pos
	inc		hl
	inc		de
	ld		a,		[hl]
	ld		[de],	a

	; Sprite number
	inc		hl
	inc		de
	ld		a,		[hl]
	ld		[de],	a

	; Flags (Skipped)
	inc		de
	ld		a,		0
	ld		[de],	a
	ret
.off:
	ld		a,		0
	ld		[de],	a
	inc		de
	ld		[de],	a
	ret


bullets_draw:
	OAM_FOR	v_bullet_array, OAM_BULLETS, BULLETS_MAX, s_bullet_SIZEOF, bullet_draw
	ret

BULLETS_DRAW:	MACRO

B_INDEX		SET	0

	REPT	BULLETS_MAX

B_OFFSET	SET	B_INDEX*s_bullet_SIZEOF
B_DEST		SET OAM_BULLETS + B_INDEX*4

	ld	a,	[v_bullet_array + B_OFFSET + s_bullet_on]
	cp	0
	jp	z,	.off\@

	; Y pos
	ld	a,			[v_bullet_array + B_OFFSET + s_bullet_y]
	ld	[B_DEST],	a

	; X pos
	ld	a,			[v_bullet_array + B_OFFSET + s_bullet_x]
	ld	[B_DEST+1],	a

	; Sprite
	ld	a,			BULLET_SPRITE
	ld	[B_DEST+2],	a

	; Flags
	ld	a,			0
	ld	[B_DEST+3],	a
	jr	.end\@

.off\@:
	ld	a,			0
	ld	[B_DEST],	a
	ld	[B_DEST+1],	a
.end\@:
	
B_INDEX		SET B_INDEX+1	

	ENDR	
PURGE	B_INDEX, B_OFFSET, B_DEST
ENDM


ENDC    ; __BULLET_DEF__
