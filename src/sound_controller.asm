IF  !DEF(__SOUND_CONTROLLER_DEF__)
__SOUND_CONTROLLER_DEF__ SET 1


				RSRESET
s_note_on		RB 1
s_note_freq		RB 2
s_note_SIZEOF	RB 0

MUSIC_TIME_UNIT	EQU 8


WRITE_NOTE:	MACRO
NOTE_FREQ EQU (2048.0 - DIV(131072.0, \1))>>16
	DB 1
	DB $FF & NOTE_FREQ
	DB NOTE_FREQ >> 8
PURGE NOTE_FREQ
ENDM


SECTION "sound_controller_data", DATA

wave:
IT	SET		0
	REPT	16
		IF	IT < 8
			DB	$FF
		ELSE
			DB	$00
		ENDC
IT		SET	IT+1
		ENDR
PURGE	IT
wave_end:

INCLUDE "data/music.asm"

SECTION "sound_controller_vars", BSS

v_sc_time_unit:		DS 1
v_sc_time_counter:	DS 1
v_sc_current_time:	DS 1


SECTION "sound_controller", CODE

sound_controller_init:
	ld	a,	MUSIC_TIME_UNIT
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
	
	ld	hl,	0
	ld	b,	0
	ld	c,	s_note_SIZEOF
	ld	a,	[v_sc_current_time]
.loop:
	cp	0
	jr	z,	.found
	dec	a
	add hl,	bc
	jr .loop
.found:
	push hl
	pop	 bc

; Bass
	ld	hl,	bass
	add	hl,	bc
	ld	a,	[hl]
	cp	0
	jr	z,	.play_lead
	CH2_LEN		WAVEP_3_4,	20
	CH2_ENV		8, 0, 1
	inc hl
	ld	a,	[hl]
	ld	[rNR23],	a
	inc	hl
	ld	a,	[hl]
	or	%11000000
	ld	[rNR24],	a

; Lead
.play_lead:
	ld	hl,	lead
	add	hl,	bc
	ld	a,	[hl]
	cp	0
	jr	z, .play_end
	CH3_ON		1
	CH3_LEN		50
	CH3_MODE	WAVEMODE_SHIFT2
	inc hl
	ld	a,	[hl]
	ld	[rNR33],	a
	inc	hl
	ld	a,	[hl]
	or	%11000000
	ld	[rNR34],	a

	
.play_end:
	ld	a, [v_sc_current_time]
	inc	a
	cp	64
	jr	nz,	.end
	ld	a,	0
.end:
	ld	[v_sc_current_time],	a
	
	ret

sound_controller


sound_shoot:
	CH1_SWEEP	1, 1, 5
	CH1_LEN		WAVEP_1_8,	63
	CH1_ENV		15, 0, 1
	CH1_PLAY	NOTE_E5, 0
	ret

sound_test:
	CH3_ON		1
	CH3_MODE	WAVEMODE_SHIFT1
	CH3_PLAY	NOTE_A6, 0
	ret

sound_init:
	; copy wave pattern
	ld	de,	_AUD3WAVERAM
	ld	bc,	wave_end - wave
	ld	hl,	wave
	call mem_copy

	; enable sound system
	ld	a,			%10000000
	ld	[rNR52],	a
	; init volumes, both max
	ld	a,			%01110111
	ld	[rNR50],	a
	; init outputs
	ld	a,			%01110111
	ld	[rNR51],	a

	ret
	

ENDC    ; __SOUND_CONTROLLER_DEF__
