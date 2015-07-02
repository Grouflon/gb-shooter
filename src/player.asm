IF  !DEF(__PLAYER_DEF__)
__PLAYER_DEF__ SET 1


SECTION "player", CODE

player_init:
.init_player
	ld		a,					PLAYER_H_SPRITE
	ld		[v_player_sprite],	a
	ld		a,					40
	ld		[v_player_x],		a
	ld		[v_player_y],		a
	ld		a,					PLAYER_FACING_LEFT
	ld		[v_player_facing],	a
	ret



player_draw:
	ld	hl,	OAM_PLAYER

.update_sprite
	; Y
	ld	a,		[v_player_y]
	ld	[hl],	a

	; X
	inc	hl
	ld	a,		[v_player_x]
	ld	[hl],	a

	; Sprite number
	inc	hl
	ld	a,	[v_player_facing]
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
	ld	[hl], a

	; Attributes
	inc	hl
	ld	b,	OAMF_PAL0
	ld	a,	[v_player_facing]
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

	ld		a,	[INPUT_PRESSED]
	and		PADF_B
	call	nz,	player_fire_bullet

	ret



player_move_right:
	ld		a,					[v_player_x]
	inc		a
	cp		160
	ret		z
	ld		[v_player_x],		a
	ld		a,					PLAYER_FACING_RIGHT
	ld		[v_player_facing],	a
	ret



player_move_left:
	ld		a,					[v_player_x]
	cp		8
	ret		z
	dec		a
	ld		[v_player_x],		a
	ld		a,					PLAYER_FACING_LEFT
	ld		[v_player_facing],	a
	ret



player_move_up:
	ld		a,					[v_player_y]
	cp		16
	ret		z
	dec		a
	ld		[v_player_y],		a
	ld		a,					PLAYER_FACING_UP
	ld		[v_player_facing],	a
	ret

	

player_move_down:
	ld		a,					[v_player_y]
	cp		152
	ret		z
	inc		a
	ld		[v_player_y],		a
	ld		a,					PLAYER_FACING_DOWN
	ld		[v_player_facing],	a
	ret


player_fire_bullet:
	ld		a,	[v_player_x]
	ld		b,	a
	ld		a,	[v_player_y]
	ld		c,	a
	ld		a,	[v_player_facing]
	call	bullet_create
	ret


ENDC    ; __PLAYER_INC_DEF__
