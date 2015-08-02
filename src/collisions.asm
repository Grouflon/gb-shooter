IF  !DEF(__COLLISIONS_DEF__)
__COLLISIONS_DEF__ SET 1


collisions_update:
	FOR	v_bullet_array, BULLETS_MAX, s_bullet_SIZEOF, bullet_enemies_loop
	FOR	v_enemy_array, ENEMIES_MAX, s_enemy_SIZEOF, player_enemy_collision
	ret

; hl	- bullet address
bullet_enemies_loop:
	ld		a,	[hl]
	cp		0
	ret		z	; leave if bullet off

	push	hl
	pop		bc
	FOR		v_enemy_array, ENEMIES_MAX, s_enemy_SIZEOF, bullet_enemy_collision
	ret


; bc	- bullet address
; hl	- enemy address
bullet_enemy_collision:
	ld		a,	[hl]
	cp		0
	ret		z	; leave if enemy off

	push	bc
	; point to Y coord
	inc		hl
	inc		bc

	;	bullet coordinate in a
	;	enemy coordinate in d
	ld		a,	[bc]
	ld		d,	[hl]
	add		3	; bullet is smaller than 8*8 sprite
	SWP8	a,	d
	add		ENEMY_HEIGHT-1
	cp		d
	jr		c,	.end
	sub		ENEMY_HEIGHT-2
	SWP8	a,	d
	add		2
	cp		d
	jr		c,	.end

	inc		hl
	inc		bc
	ld		a,	[bc]
	ld		d,	[hl]
	add		3	; bullet is smaller than 8*8 sprite
	SWP8	a,	d
	add		ENEMY_WIDTH-1
	cp		d
	jr		c,	.end
	sub		ENEMY_WIDTH-2
	SWP8	a,	d
	add		2
	cp		d
	jr		c,	.end

	dec		hl
	dec		hl
	call 	enemy_reset
	dec		bc
	dec		bc
	push	bc
	pop		hl
	call	bullet_reset

.end:
	pop		bc
	ret


; hl	- enemy address
player_enemy_collision:
	ld		a,	[v_player + s_player_on]
	and		[hl]
	cp		0
	ret		z	; leave if enemy or player off

	inc		hl
	ld		a,	[v_player + s_player_y]
	ld		b,	a
	ld		a,	[hl]
	add		ENEMY_HEIGHT-1
	cp		b
	ret		c
	sub		ENEMY_HEIGHT-2
	SWP8	a,	b
	add		PLAYER_HEIGHT
	cp		b
	ret		c
	
	inc		hl
	ld		a,	[v_player + s_player_x]
	ld		b,	a
	ld		a,	[hl]
	add		ENEMY_WIDTH-1
	cp		b
	ret		c
	sub		ENEMY_WIDTH-2
	SWP8	a,	b
	add		PLAYER_WIDTH
	cp		b
	ret		c

	dec		hl
	dec		hl
	call	enemy_reset
	call	player_reset

	ret
	

ENDC    ; __COLLISIONS_DEF__
