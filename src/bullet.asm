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
	ld		a,		BULLET_FACING_UP ; Bullet Facing
	ldi		[hl],	a
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
	;	Facing
	inc		hl
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
	ld		a,	[hl]	; Facing
	cp		BULLET_FACING_LEFT
	jr		z,	.b_move_left
	cp		BULLET_FACING_RIGHT
	jr		z,	.b_move_right
	cp		BULLET_FACING_UP
	jr		z,	.b_move_up
	cp		BULLET_FACING_DOWN
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
	ld		[hl],	a
	inc		hl
	ld		[hl],	a
	inc		hl
	ld		[hl],	a
	ret


bullets_draw:
	ld		hl,		v_bullet_array
	ld		de,		OAM_BULLETS
	ld		a,		BULLETS_MAX
.bullets_draw_loop:
	cp		0
	jr		z,		.bullets_draw_end
	push	af
	; don't draw if disabled
	ld		a,		[hl]
	cp		0
	jr		z,		.bullets_draw_continue

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
	inc		hl
	inc		de
	ld		a,		0
	ld		[de],	a

	inc 	hl
	inc 	de
	jr		.bullets_draw_next

.bullets_draw_continue:
	ld		bc,	s_bullet_SIZEOF
	add		hl,	bc
	inc		de
	inc		de
	inc		de
	inc		de
.bullets_draw_next:
	pop		af
	dec		a
	jr		.bullets_draw_loop

.bullets_draw_end:
	ret


ENDC    ; __BULLET_DEF__
