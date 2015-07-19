IF  !DEF(__BACKGROUND_CONTROLLER_DEF__)
ENDC    ; __BACKGROUND_CONTROLLER_DEF__

SECTION "background_controller_vars", BSS

SECTION "background_controller", CODE

background_controller_init:
	ret


background_controller_update:
	ld	a,	[rSCY]
	dec	a
	ld	[rSCY],	a

	ld	a,	[v_player + s_player_on] 
	cp	0
	ret	z
	ld	a,	[v_player + s_player_x]
	srl	a
	srl	a
	srl	a
	ld	[rSCX],	a
	ret

__BACKGROUND_CONTROLLER_DEF__ SET 1
