IF	!DEF(__STRUCTS_DEF__)
__STRUCTS_DEF__	SET 1

	; PLAYER
				RSRESET
s_player_on		RB 1
s_player_y		RB 1
s_player_x		RB 1
s_player_facing	RB 1
s_player_SIZEOF	RB 0


	; BULLET
				RSRESET
s_bullet_on 	RB 1
s_bullet_y		RB 1
s_bullet_x		RB 1
s_bullet_sprite	RB 1
s_bullet_facing	RB 1
s_bullet_SIZEOF	RB 0


	; ENEMY
				RSRESET
s_enemy_on		RB 1
s_enemy_y		RB 1
s_enemy_x		RB 1
s_enemy_sprite	RB 1
s_enemy_SIZEOF	RB 0


ENDC	; __STRUCTS_DEF__
