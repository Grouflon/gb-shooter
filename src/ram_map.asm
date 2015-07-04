IF	!DEF(__RAM_MAP_DEF__)
__RAM_MAP_DEF__	SET 1

SECTION "player_vars",	BSS
v_player_sprite:	DS 1
v_player_x:			DS 1
v_player_y:			DS 1
v_player_facing:	DS 1

SECTION "bullet_vars",	BSS
v_bullet_array:
REPT	BULLETS_MAX
DS		s_bullet_SIZEOF
ENDR

SECTION "enemy_vars", BSS
v_enemy_array
REPT	ENEMIES_MAX
DS		s_bullet_SIZEOF
ENDR

ENDC	; __RAM_MAP_DEF__
