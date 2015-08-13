IF  !DEF(__SOUND_CONTROLLER_DEF__)
__SOUND_CONTROLLER_DEF__ SET 1

SECTION "sound_controller_vars", BSS

v_sc_time_unit:		DS 1
v_sc_time_counter:	DS 1
v_sc_current_time:	DS 1


SECTION "sound_controller", CODE

sound_controller_init:
	ld	a,	10
	ld	[v_sc_time_unit],		a
	ld	a,	0
	ld	[v_sc_time_counter],	a
	ld	[v_sc_current_time],	a
	ret
	
sound_controller_update:
	ld	a,	[v_sc_time_unit]
	ld	b,	a
	ld	a,	[v_sc_time_counter]
	cp	b
	jr	z,	.play
	inc	a
	ld	[v_sc_time_counter],	a
	ret
	
.play:
	ld	a,	0
	ld	[v_sc_time_counter],	a
	
	; LA MUSIQUE
	
	ret

sound_shoot:
	CH1_SWEEP	1, 1, 5
	CH1_LEN		WAVEP_1_8,	63
	CH1_ENV		15, 0, 1
	CH1_PLAY	NOTE_E5, 0
	ret

ENDC    ; __SOUND_CONTROLLER_DEF__