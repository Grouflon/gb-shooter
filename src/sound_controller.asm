IF  !DEF(__SOUND_CONTROLLER_DEF__)
__SOUND_CONTROLLER_DEF__ SET 1

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


SECTION "sound_controller",	CODE

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
