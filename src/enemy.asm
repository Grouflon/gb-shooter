IF  !DEF(__ENEMY_DEF__)
__ENEMY_DEF__ SET 1


SECTION "enemies", CODE

; hl	- struct address
enemy_init:
	ld		a,		0
	ldi		[hl],	a
	ld		a,		0
	ldi		[hl],	a
	ldi		[hl],	a
	ld		a,		ENEMY_SPRITE
	ld		[hl],	a
	ret

; ret hl	- free enemy address
; ret a		- has found one
enemy_find_free:
	ld	hl,	v_enemy_array
	ld	bc,	s_enemy_SIZEOF
	ld	a,	ENEMIES_MAX
.find_loop:
	cp	0
	jr	z,	.not_found
	push	af
	ld		a,	[hl]
	cp		0
	jr		z,	.found
	pop		af
	add	hl,	bc
	dec	a
	jr	.find_loop
.found:
	pop	af
	ld	a,	1
	ret
.not_found:
	ret

; b	- Y coordinate
; c	- X coordinate
enemy_create:
	push	bc
	call	enemy_find_free
	pop		bc
	cp		0
	jr		z,	.enemy_create_end
	ld		a,		1
	ldi		[hl],	a
	ld		a,		b
	ldi		[hl],	a
	ld		a,		c
	ld		[hl],	a
.enemy_create_end:
	ret

enemies_init:
	FOR		v_enemy_array, ENEMIES_MAX, s_enemy_SIZEOF, enemy_init
	ret


enemies_update:
	FOR		v_enemy_array, ENEMIES_MAX, s_enemy_SIZEOF, enemy_update
	ret


; hl	- struct address
enemy_update:
	push	hl
	ld	bc,	s_enemy_y
	add	hl,	bc
	ld	a,	[hl]
	inc	a
	cp	161
	jr	nc,	.out
	ld	[hl],	a
	pop	hl
	ret
.out:
	pop	hl
	call	enemy_reset
	ret


enemy_draw:
	; don't draw if disabled
	ld		a,		[hl]
	cp		0
	jr		z,		.off

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
	ld		a,		OAMF_PAL1|OAMF_YFLIP
	ld		[de],	a
	ret
.off:
	ld		a,		0
	ld		[de],	a
	inc		de
	ld		[de],	a


; hl	- strcut address
enemy_reset:
	ld	a,		0
	ldi	[hl],	a
	ldi	[hl],	a
	ld	[hl],	a
	ret


enemies_draw:
	OAM_FOR	v_enemy_array, OAM_ENEMIES, ENEMIES_MAX, s_enemy_SIZEOF, enemy_draw
	ret

ENEMIES_DRAW:	MACRO

E_INDEX		SET 0

	REPT	ENEMIES_MAX

E_OFFSET	SET	E_INDEX*s_enemy_SIZEOF
E_DEST		SET	OAM_ENEMIES + E_INDEX*4

	ld	a,	[v_enemy_array + E_OFFSET + s_enemy_on]
	cp	0
	jr	z,	.off\@

	; Y Pos
	ld	a,			[v_enemy_array + E_OFFSET + s_enemy_y]
	ld	[E_DEST],	a

	; X Pos	
	ld	a,			[v_enemy_array + E_OFFSET + s_enemy_x]
	ld	[E_DEST+1],	a

	; Sprite	
	ld	a,			ENEMY_SPRITE
	ld	[E_DEST+2],	a

	; Flags
	ld	a,			OAMF_PAL1|OAMF_YFLIP
	ld	[E_DEST+3],	a
	jr	.end\@

.off\@:
	ld	a,			0
	ld	[E_DEST],	a
	ld	[E_DEST+1],	a
.end\@:

E_INDEX		SET E_INDEX+1
	ENDR
PURGE	E_INDEX, E_OFFSET, E_DEST
ENDM


ENDC    ; __ENEMY_DEF__
