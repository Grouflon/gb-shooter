IF  !DEF(__BULLET_DEF__)
__BULLET_DEF__ SET 1


SECTION "bullet", CODE

bullets_init:
	ld		hl,	v_bullet_array
	ld		a,	BULLETS_MAX
.bullets_loop:
	cp		0
	jr		z,	.bullets_init_end
	push	af

	ld		a,		0				; Bullet on
	ld		[hl],	a
	inc		hl
	ld		a,		0				; Bullet coords
	ld		[hl],	a
	inc		hl
	ld		[hl],	a
	inc		hl
	ld		a,		BULLET_SPRITE	; Bullet sprite number
	ld		[hl],	a
	inc		hl
	ld		a,		BULLET_FACING_UP ; Bullet Facing
	ld		[hl],	a

	inc		hl
	pop		af
	dec		a
	jr		.bullets_loop
.bullets_init_end:
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
	ld		[hl],	a
	;	Y
	inc		hl
	ld		a,		c
	ld		[hl],	a
	;	X
	inc		hl
	ld		a,		b
	ld		[hl],	a
	;	Facing
	inc		hl
	inc		hl
	pop		af
	ld		[hl],	a
	ret

.bullet_not_found
	pop		af
	ret


bullets_update:
	ld		hl,	v_bullet_array
	ld		a,	BULLETS_MAX
.bullets_update_loop:
	cp		0
	jr		nz,	.bullet_update
	ret

.bullet_update
	push	af
	;		Skip if disabled
	ld		a,		[hl]
	cp		0
	jr		z,		.bullet_update_end

	push	hl
	inc		hl
	ld		a,	[hl]
	ld		b,	a		; Y Position in b
	inc		hl
	ld		a,	[hl]
	ld		c,	a		; X Position in c
	inc		hl
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
	ld		[hl],	a
	inc		hl
	ld		a,		c
	ld		[hl],	a

	pop		hl
	push	hl
	call	bullet_check_death
	pop		hl
	push	hl
	call	z,	bullet_reset
	pop		hl

.bullet_update_end
	pop		af
	dec		a
	ld		bc,		s_bullet_SIZEOF
	add		hl,		bc
	jr		.bullets_update_loop

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
