IF  !DEF(__SOUND_CONTROLLER_DEF__)
__SOUND_CONTROLLER_DEF__ SET 1


				RSRESET
s_note_on		RB 1
s_note_freq		RB 2
s_note_SIZEOF	RB 0

SECTION "sound_controller_vars", BSS

v_sc_time_unit:		DS 1
v_sc_time_counter:	DS 1
v_sc_current_time:	DS 1


SECTION "sound_controller_data", DATA

wave:
ANGLE	SET		0.0
		REPT	16

DATA1	SET		(MUL(7.0,SIN(ANGLE))+8.0)>>16
DATA2	SET		(MUL(7.0,SIN(ANGLE+2048.0))+8.0)>>16
		DB		(DATA1<<4) | DATA2

ANGLE	SET		ANGLE+4096.0
		ENDR
PURGE	ANGLE, DATA1, DATA2
wave_end:

WRITE_NOTE:	MACRO
NOTE_FREQ EQU (2048.0 - DIV(131072.0, \1))>>16

DB 1
DB $FF & NOTE_FREQ
DB NOTE_FREQ >> 8

PURGE NOTE_FREQ
ENDM

bass_line:
	WRITE_NOTE NOTE_E1
	DB 0, $00, $00
	WRITE_NOTE NOTE_E1
	WRITE_NOTE NOTE_E1
	WRITE_NOTE NOTE_E1
	DB 0, $00, $00
	WRITE_NOTE NOTE_E1
	WRITE_NOTE NOTE_E1
	WRITE_NOTE NOTE_E1
	DB 0, $00, $00
	WRITE_NOTE NOTE_E1
	WRITE_NOTE NOTE_E1
	WRITE_NOTE NOTE_E1
	DB 0, $00, $00
	WRITE_NOTE NOTE_E1
	WRITE_NOTE NOTE_E1


SECTION "sound_controller", CODE

sound_controller_init:
	ld	a,	6
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
	
	ld	hl,	bass_line
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

	ld	a,	[hl]
	cp	0
	jr	z,	.play_end

	CH2_LEN		WAVEP_3_4,	20
	CH2_ENV		8, 0, 1
	inc hl
	ld	a,	[hl]
	ld	[rNR23],	a
	inc	hl
	ld	a,	[hl]
	or	%11000000
	ld	[rNR24],	a

	
.play_end:
	ld	a, [v_sc_current_time]
	inc	a
	cp	16
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
