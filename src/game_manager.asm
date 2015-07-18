IF	!DEF(__GAME_MANAGER_DEF__)
__GAME_MANAGER_DEF__	SET 1

END_TIMEOUT			EQU	100
GAME_STATE_RUNNING	EQU 0
GAME_STATE_WIN		EQU 1
GAME_STATE_LOST		EQU 2

section "game_manager_vars", BSS
v_game_end_timer:	DS	1
v_game_state:		DS	1
v_game_enemy_count:	DS	1

section "game_manager", CODE

game_manager_init:
	ld	a,				END_TIMEOUT
	ld	[v_game_end_timer],	a
	ld	a,				0
	ld	[v_game_state],	a
	ld	[v_game_enemy_count],	a
	ret

game_manager_update:
	ld	a,	[v_game_state]
	cp	GAME_STATE_RUNNING
	jp	nz,	.game_end

	ld	a,	[v_player + s_player_on]
	cp	0
	jr	z,	.lose

;	ld	a,	0
;	ld	[v_game_enemy_count],	a
;	FOR	v_enemy_array, ENEMIES_MAX, s_enemy_SIZEOF, game_manager_check_enemy
;	ld	a,	[v_game_enemy_count]
;	cp	0
;	jr	z,	.win
	ret

.lose:
	ld	a,				GAME_STATE_LOST
	ld	[v_game_state],	a
	ret
.win:
	ld	a,				GAME_STATE_WIN
	ld	[v_game_state],	a	
	ret
.game_end:
	ld	a,	[v_game_end_timer]
	dec	a
	cp	0
	jr	z,	.restart
	ld	[v_game_end_timer],	a
	ret
.restart:
	jp	game_init

game_manager_draw:
	ld	a,	[v_game_state]
	cp	GAME_STATE_WIN
	jr	z,	.win
	cp	GAME_STATE_LOST
	jr	z,	.lose
	ret
.win:
	LOG	"YOU WIN", _SCRN0 + (32*8) + 6
	ret
.lose
	LOG	"YOU LOSE", _SCRN0 + (32*8) + 6
	ret
	

game_manager_check_enemy:
	ld	a,	[v_game_enemy_count]
	add [hl]
	ld	[v_game_enemy_count],	a
	ret

ENDC	; __GAME_MANAGER_DEF__
