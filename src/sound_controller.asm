IF  !DEF(__SOUND_CONTROLLER_DEF__)
__SOUND_CONTROLLER_DEF__ SET 1

PATTERN_HEADER_SIZE	EQU 1
PATTERN_UNIT_SIZE	EQU 2
SEQUENCE_UNIT_SIZE	EQU 2

MUSIC_TIME_UNIT	EQU 6

				RSRESET
s_note_on		RB 1
s_note_chan		RB 2
s_note_r0		RB 1
s_note_r1		RB 1
s_note_r2		RB 1
s_note_freqlo	RB 1
s_note_freqhi	RB 1
s_note_SIZEOF	RB 0

; \1 - Note Frequency
; \2 - Sweep
; \3 - Length
; \4 - Envelope
; \5 - counter on
CH1_NOTE: MACRO
GB_FREQ		EQU	(2048.0 - DIV(131072.0, \1))>>16
IF \5 == 1
	COUNTER	EQU %01000000
ELSE
	COUNTER	EQU 0
ENDC

	DB		1
	DW		rNR10
	DB		\2
	DB		\3
	DB		\4
	DB		$FF & GB_FREQ
	DB		(GB_FREQ >> 8) | %10000000 | COUNTER
	
PURGE	GB_FREQ, COUNTER
ENDM

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

v_sc_time_counter:			DS 1
v_sc_current_pattern:		DS 1
v_sc_current_pattern_loop:	DS 1
v_sc_current_pattern_time:	DS 1


SECTION "sound_controller", CODE

sound_controller_init:
	ld	a,	0
	ld	[v_sc_time_counter],	a
	ld	[v_sc_current_pattern],	a
	ld	[v_sc_current_pattern_loop],	a
	ld	[v_sc_current_pattern_time],	a
	ret
	
sound_controller_update:
	ld	b,	MUSIC_TIME_UNIT
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
	ld	c,	PATTERN_UNIT_SIZE
	ld	a,	[v_sc_current_pattern_time]
.loop:
	cp	0
	jr	z,	.found
	dec	a
	add hl,	bc
	jr .loop
.found:
	push hl
	pop	 bc

.channel1
	ld	hl, patterns_start + PATTERN_HEADER_SIZE
	add hl, bc
	inc hl
	ld	a, [hl]
	cp	0
	jr	z, .channel2

	dec	hl
	push bc
	ld	de,	rNR13
	ld	bc, PATTERN_UNIT_SIZE
	call mem_copy
	pop bc

.channel2
	ld	hl, patterns_start + PATTERN_HEADER_SIZE
	ld	de, (16 * PATTERN_UNIT_SIZE)
	add hl, de
	add hl, bc
	inc hl
	ld	a, [hl]
	cp	0
	jr	z, .play_end

	dec	hl
	push bc
	ld	de,	rNR23
	ld	bc, PATTERN_UNIT_SIZE
	call mem_copy
	pop bc

.play_end:
	ld	a, [v_sc_current_pattern_time]
	inc	a
	cp	16
	jr	nz,	.end
	ld	a,	0
.end:
	ld	[v_sc_current_pattern_time],	a
	
	ret

sound_controller


sound_shoot:
	ret
	CH1_SWEEP	1, 1, 5
	CH1_LEN		WAVEP_1_8,	63
	CH1_ENV		15, 0, 1
	CH1_PLAY	FREQ_E5, 0
	ret

sound_hit:
	ret
	CH4_LEN 15
	CH4_ENV	10, 0, 1
	CH4_MODE %1010101
	CH4_PLAY 1
	ret

sound_destroy:
	ret
	CH4_ENV	12, 0, 3
	CH4_MODE %1010101
	CH4_PLAY 0
	ret

sound_test:
	ret
	CH3_ON		1
	CH3_MODE	WAVEMODE_SHIFT1
	CH3_PLAY	FREQ_A6, 0
	ret

sound_init:
	; copy wave pattern
	ld	de,	_AUD3WAVERAM
	ld	bc,	wave_end - wave
	ld	hl,	wave
	call mem_copy

	CH1_SWEEP	0, 0, 0
	CH1_LEN		WAVEP_1_2,	63
	CH1_ENV		15, 0, 1

	CH2_LEN		WAVEP_3_4,	20
	CH2_ENV		8, 0, 1

	; enable sound system
	ld	a,			%10000000
	ld	[rNR52],	a
	; init volumes, both max
	ld	a,			%01110111
	ld	[rNR50],	a
	; init outputs
	ld	a,			%11111111
	ld	[rNR51],	a

	ret
	

ENDC    ; __SOUND_CONTROLLER_DEF__
