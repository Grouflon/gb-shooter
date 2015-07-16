IF	!DEF(__ENEMY_SPAWNER_DEF__)
__ENEMY_SPAWNER_DEF__	SET 1

SPAWN_RATE	EQU	100

section "enemy_spawner_vars", BSS

section "enemy_spawner", CODE

enemy_spawner_init:
	ret

ENDC	; __ENEMY_SPAWNER_DEF__
