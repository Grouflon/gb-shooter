IF  !DEF(__ENEMY_DEF__)
__ENEMY_DEF__ SET 1


SECTION "enemies", CODE

; hl	- struct address
enemy_init:
	ld		a,		1
	ldi		[hl],	a
	ld		a,		50
	ld		[hl],	a
	ldi		[hl],	a
	ld		a,		ENEMY_SPRITE
	ld		[hl],	a
	ret


enemies_init:
	FOR		v_enemy_array, ENEMIES_MAX, s_enemy_SIZEOF, enemy_init
	ret


enemy_draw:
	; don't draw if disabled
	ld		a,		[hl]
	cp		0
	ret		z

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

	; Flags
	inc		de
	ld		a,		OAMF_PAL0
	ld		[de],	a
	ret


enemies_draw:
	OAM_FOR	v_enemy_array, OAM_ENEMIES, ENEMIES_MAX, s_enemy_SIZEOF, enemy_draw
	ret


ENDC    ; __ENEMY_DEF__
