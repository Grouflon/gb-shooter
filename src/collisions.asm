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

	; point to Y coord
	inc		hl
	inc		bc

	;	bullet coordinate in a
	;	enemy coordinate in d
	ld		a,	[bc]
	ld		d,	[hl]
	add		3	; bullet is smaller than 8*8 sprite
	SWP8	a,	d
	add		ENEMY_HEIGHT
	cp		d
	ret		c
	sub		ENEMY_HEIGHT
	SWP8	a,	d
	add		2
	ret		c

	inc		hl
	inc		bc
	ld		a,	[bc]
	ld		d,	[hl]
	add		3	; bullet is smaller than 8*8 sprite
	SWP8	a,	d
	add		ENEMY_WIDTH
	cp		d
	ret		c
	sub		ENEMY_WIDTH
	SWP8	a,	d
	add		2
	ret		c

	dec		hl
	dec		hl
	call 	enemy_reset
	dec		bc
	dec		bc
	push	bc
	pop		hl
	call	bullet_reset

	ret

; hl	- enemy address
player_enemy_collision:
	ld		a,	[hl]
	cp		0
	ret		z	; leave if enemy off

;	inc		hl
;	ld		bc,	v_player_y
	ret

	

ENDC    ; __COLLISIONS_DEF__
