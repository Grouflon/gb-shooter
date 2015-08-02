IF  !DEF(__PLAYER_DEF__)
__PLAYER_DEF__ SET 1


SECTION "player", CODE

player_init:
.init_player
	ld		hl,		v_player
	ld		a,		1
	ldi		[hl],	a
	ld		a,		140
	ldi		[hl],	a
	ld		a,		88
	ldi		[hl],	a
	ld		a,		0
	ldi		[hl],	a
	ldi		[hl],	a
	ld		a,		PLAYER_FACING_UP
	ldi		[hl],	a
	ld		a,		PLAYER_SHOOTINTERVAL
	ld		[hl],	a
	ret


player_reset:
	ld		hl,		v_player
	ld		a,		0
	ldi		[hl],	a
	ldi		[hl],	a
	ldi		[hl],	a
	ldi		[hl],	a
	ldi		[hl],	a
	ld		[hl],	a
	ret


player_draw:
	ld	hl,	OAM_PLAYER

.update_sprite
	; Y
	ld	a,		[v_player + s_player_y]
	ldi	[hl],	a

	; X
	ld	a,		[v_player + s_player_x]
	ldi	[hl],	a

	; Sprite number
	ld	a,	[v_player + s_player_facing]
	cp	PLAYER_FACING_LEFT
	jr	z, .sprite_horizontal
	cp	PLAYER_FACING_RIGHT
	jr	z, .sprite_horizontal
	cp	PLAYER_FACING_UP
	jr	z, .sprite_vertical
	cp	PLAYER_FACING_DOWN
	jr	z, .sprite_vertical
.sprite_horizontal
	ld	a,	PLAYER_H_SPRITE
	jr	.sprite_number_end
.sprite_vertical
	ld	a,	PLAYER_V_SPRITE
.sprite_number_end
	ldi	[hl], a

	; Attributes
	ld	b,	OAMF_PAL0
	ld	a,	[v_player + s_player_facing]
	ld	c,	a
	cp  PLAYER_FACING_LEFT
	jr	nz,	.attr_vertical
	ld	a,	b
	or	OAMF_XFLIP
	ld	b,	a
.attr_vertical
	ld	a,	c
	cp	PLAYER_FACING_UP
	jr	z,	.attr_end
	ld	a,	b
	or OAMF_YFLIP
	ld	b,	a
.attr_end
	ld	a,	b
	ld	[hl],	a

	ret



player_update:
	ld		a,	[v_player]
	cp		0
	ret		z	; leave if player off

	ld		a,	[INPUT]
	and		PADF_RIGHT
	call	nz,	player_move_right
	
	ld		a,	[INPUT]
	and		PADF_LEFT
	call	nz,	player_move_left

	ld		a,	[INPUT]
	and		PADF_UP
	call	nz,	player_move_up

	ld		a,	[INPUT]
	and		PADF_DOWN
	call	nz,	player_move_down

	ld		a,	[v_player + s_player_firedelay]
	cp		PLAYER_SHOOTINTERVAL
	jr		nc,	.fire_input
	inc		a
	ld		[v_player + s_player_firedelay],	a
	jr		.update_end

.fire_input:
	ld		a,	[INPUT]
	and		PADF_B
	call	nz,	player_fire_bullet

.update_end
	ret



player_move_right:
	ld		a,	[v_player + s_player_hcarry]
	add		PLAYER_HSPEED
	ld		d,	a
	res		0,	a
	SWP8	d,	a
	sub		a,	d
	ld		[v_player + s_player_hcarry],	a
	rr		d

	ld		a,	[v_player + s_player_x]
	add		a,	d
	cp		160
	jr		nc,	.out
	ld		[v_player + s_player_x],	a
	ret
.out:
	ld		a,	160
	ld		[v_player + s_player_x],	a
	ret



player_move_left:
	ld		a,	[v_player + s_player_hcarry]
	add		PLAYER_HSPEED
	ld		d,	a
	res		0,	a
	SWP8	d,	a
	sub		a,	d
	ld		[v_player + s_player_hcarry],	a
	rr		d

	ld		a,	[v_player + s_player_x]
	sub		a,	d
	cp		8
	jr		c,	.out
	ld		[v_player + s_player_x],	a
	ret
.out:
	ld		a,	8
	ld		[v_player + s_player_x],	a
	ret



player_move_up:
	ld		a,	[v_player + s_player_vcarry]
	add		PLAYER_VSPEED
	ld		d,	a
	res		0,	a
	SWP8	d,	a
	sub		a,	d
	ld		[v_player + s_player_vcarry],	a
	rr		d

	ld		a,	[v_player + s_player_y]
	sub		a,	d
	cp		16
	jr		c,	.out
	ld		[v_player + s_player_y],	a
	ret
.out:
	ld		a,	16
	ld		[v_player + s_player_y],	a
	ret

	

player_move_down:
	ld		a,	[v_player + s_player_y]
	cp		143
	ret		z
	inc		a
	ld		[v_player + s_player_y],		a
;	ld		a,								PLAYER_FACING_DOWN
;	ld		[v_player + s_player_facing],	a
	ret


player_fire_bullet:
	ld		a,	0
	ld		[v_player + s_player_firedelay],	a
	ld		a,	[v_player + s_player_x]
	ld		b,	a
	ld		a,	[v_player + s_player_y]
	ld		c,	a
	ld		a,	[v_player + s_player_facing]
	call	bullet_create
	ret


ENDC    ; __PLAYER_INC_DEF__
