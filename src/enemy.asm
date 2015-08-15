IF  !DEF(__ENEMY_DEF__)
__ENEMY_DEF__ SET 1


SECTION "enemies", CODE

; hl	- struct address
enemy_init:
	ld		a,		0
	ldi		[hl],	a	;On
	ldi		[hl],	a	;Y
	ldi		[hl],	a	;X
	ldi		[hl],	a	;type
	ldi		[hl],	a	;ycarry
	ld		[hl],	a	;xcarry
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
; d - type
enemy_create:
	push	bc
	call	enemy_find_free
	pop		bc
	cp		0
	jr		z,	.enemy_create_end
	ld		a,		1
	ldi		[hl],	a	; On
	ld		a,		b
	ldi		[hl],	a	; Y
	ld		a,		c
	ldi		[hl],	a	; X
	ld		a,		d
	ldi		[hl],	a	; enemy_type
	cp		ENEMY_TYPE_STD
	jr		z,		.enemy_type_std
	cp		ENEMY_TYPE_SLOW
	jr		z,		.enemy_type_slow
.enemy_type_dash:
	ld		a,		ENEMY_DASH_BASESPEED
	ldi		[hl],	a
	ld		a,		0
	ldi		[hl],	a
.enemy_type_slow:
	ld		a,		ENEMY_SLOW_YSPEED
	ldi		[hl],	a
	ld		a,		0
	ldi		[hl],	a

.enemy_type_std:
	ld		a,		ENEMY_STD_YSPEED
	ldi		[hl],	a
	ld		a,		0
	ldi		[hl],	a

.enemy_create_carry:
	ld		a,		0
	ldi		[hl],	a	; enemy_ycarry
	ld		[hl],	a	; enemy_xcarry
.enemy_create_end:
	ret

enemies_init:
	FOR		v_enemy_array, ENEMIES_MAX, s_enemy_SIZEOF, enemy_init
	ret


;enemies_update:
;	FOR		v_enemy_array, ENEMIES_MAX, s_enemy_SIZEOF, enemy_update
;	ret


; hl	- struct address
;enemy_update:
;	push	hl
;	ld	bc,	s_enemy_y
;	add	hl,	bc
;	ld	a,	[hl]
;	inc	a
;	cp	161
;	jr	nc,	.out
;	ld	[hl],	a
;	pop	hl
;	ret
;.out:
;	pop	hl
;	call	enemy_reset
;	ret

ENEMIES_UPDATE:	MACRO

E_INDEX		SET 0

	REPT	ENEMIES_MAX

E_OFFSET	SET	E_INDEX*s_enemy_SIZEOF
E_DEST		SET	OAM_ENEMIES + E_INDEX*4

; Skip if off
	ld		a,	[v_enemy_array + E_OFFSET + s_enemy_on]
	cp		0
	jr		z,	.enemy_update_end\@

	ld		a,	[v_enemy_array + E_OFFSET + s_enemy_type]
	cp		ENEMY_TYPE_DASH
	jr		z,	.enemy_dash_update\@
	jr		.enemy_update_common\@

.enemy_dash_update\@
; cant dash until reached y threshold
	ld		a,	[v_enemy_array + E_OFFSET + s_enemy_y]
	cp		ENEMY_DASH_THRESHOLD
	jr		c,	.enemy_update_common\@

; Ignite dash when player is in front of him
	ld		a,	[v_player + s_player_x]
	add		PLAYER_WIDTH
	ld		b,	a
	ld		a,	[v_enemy_array + E_OFFSET + s_enemy_x]
	cp		b
	jp		nc,	.enemy_update_common\@
	add		ENEMY_WIDTH
	SWP8	a,	b
	sub		PLAYER_WIDTH
	cp		b
	jp		nc,	.enemy_update_common\@
	ld		a,	ENEMY_DASH_DASHSPEED
	ld		[v_enemy_array + E_OFFSET + s_enemy_yspeed], a

.enemy_update_common\@
; Apply Y movement
	ld		a,	[v_enemy_array + E_OFFSET + s_enemy_yspeed]
	ld		c,	a
	ld		a,	[v_enemy_array + E_OFFSET + s_enemy_ycarry]
	add		c
	ld		b,	a
	res		0,	a
	SWP8	b,	a
	sub		a,	b
	ld		[v_enemy_array + E_OFFSET + s_enemy_ycarry],	a
	rr		b
	ld		a,	[v_enemy_array + E_OFFSET + s_enemy_y]
	add		a,	b
	cp		161
	jr		nc,	.enemy_out\@
	ld		[v_enemy_array + E_OFFSET + s_enemy_y],	a
	jr		.enemy_update_end\@

; Apply X movement
	ld		a,	[v_enemy_array + E_OFFSET + s_enemy_xspeed]
	ld		c,	a
	ld		a,	[v_enemy_array + E_OFFSET + s_enemy_xcarry]
	add		c
	ld		b,	a
	res		0,	a
	SWP8	b,	a
	sub		a,	b
	ld		[v_enemy_array + E_OFFSET + s_enemy_xcarry],	a
	rr		b
	ld		a,	[v_enemy_array + E_OFFSET + s_enemy_x]
	add		a,	b
	ld		[v_enemy_array + E_OFFSET + s_enemy_y],	a
	jr		.enemy_update_end\@

.enemy_out\@
	ld		hl,	v_enemy_array+E_OFFSET
	call	enemy_reset

.enemy_update_end\@

E_INDEX		SET E_INDEX+1
	ENDR
PURGE	E_INDEX, E_OFFSET, E_DEST
ENDM


;enemy_draw:
	; don't draw if disabled
;	ld		a,		[hl]
;	cp		0
;	jr		z,		.off

	; Y pos
;	inc		hl
;	ld		a,		[hl]
;	ld		[de],	a

	; X pos
;	inc		hl
;	inc		de
;	ld		a,		[hl]
;	ld		[de],	a

	; Sprite number
;	inc		hl
;	inc		de
;	ld		a,		[hl]
;	ld		[de],	a

	; Flags
;	inc		de
;	ld		a,		OAMF_PAL1|OAMF_YFLIP
;	ld		[de],	a
;	ret
;.off:
;	ld		a,		0
;	ld		[de],	a
;	inc		de
;	ld		[de],	a


; hl	- strcut address
enemy_hit:
	call enemy_reset
	call sound_hit
	ret


; hl	- strcut address
enemy_reset:
	ld	a,		0
	ldi	[hl],	a
	ldi	[hl],	a
	ld	[hl],	a
	ret


;enemies_draw:
;	OAM_FOR	v_enemy_array, OAM_ENEMIES, ENEMIES_MAX, s_enemy_SIZEOF, enemy_draw
;	ret

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
