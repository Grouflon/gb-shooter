IF  !DEF(__SOUND_DEF__)
__SOUND_DEF__ SET 1

WAVEP_1_8	EQU %00
WAVEP_1_4	EQU %01
WAVEP_1_2	EQU %10
WAVEP_3_4	EQU %11

WAVEMODE_MUTE	EQU	%00
WAVEMODE_NOP	EQU	%01
WAVEMODE_SHIFT1	EQU	%10
WAVEMODE_SHIFT2	EQU	%11


;****************************
;*         CHANNEL 1        *
;****************************

CH1_SWEEP:	MACRO
	ld	a,	(\1*16) | (\2*8) | \3
	ld	[rNR10],	a
ENDM

CH1_LEN:	MACRO
	ld	a,	(\1*64) | -(\2-63)
	ld	[rNR11],	a
ENDM

CH1_ENV:	MACRO
	ld	a,	(\1*16) | (\2*8) | \3
	ld	[rNR12],	a
ENDM

CH1_PLAY:	MACRO
GB_FREQ		EQU	(2048.0 - DIV(131072.0, \1))>>16

	ld	a,	$FF & GB_FREQ
	ld	[rNR13],	a
	ld	a,	(GB_FREQ >> 8) | (\2 * 64) | %10000000
	ld	[rNR14],	a

PURGE	GB_FREQ
ENDM

;****************************
;*         CHANNEL 2        *
;****************************

CH2_LEN:	MACRO
	ld	a,	(\1*64) | -(\2-63)
	ld	[rNR21],	a
ENDM

CH2_ENV:	MACRO
	ld	a,	(\1*16) | (\2*8) | \3
	ld	[rNR22],	a
ENDM

CH2_PLAY:	MACRO
GB_FREQ		EQU	(2048.0 - DIV(131072.0, \1))>>16

	ld	a,	$FF & GB_FREQ
	ld	[rNR23],	a
	ld	a,	(GB_FREQ >> 8) | (\2 * 64) | %10000000
	ld	[rNR24],	a

PURGE	GB_FREQ
ENDM



;****************************
;*         CHANNEL 3        *
;****************************

CH3_ON:		MACRO
	ld	a,			\1*128
	ld	[rNR30],	a
ENDM

CH3_LEN:	MACRO
	ld	a,			\1
	ld	[rNR31],	a
ENDM

CH3_MODE:	MACRO
	ld		a,			\1*32
	ld		[rNR32],	a
ENDM

CH3_PLAY:	MACRO
GB_FREQ		EQU	(2048.0 - DIV(131072.0, \1))>>16

	ld	a,	$FF & GB_FREQ
	ld	[rNR33],	a
	ld	a,			(GB_FREQ >> 8) | (\2 * 64) | %10000000
	ld	[rNR34],	a

PURGE	GB_FREQ
ENDM


;****************************
;*        NOTES FREQS       *
;****************************

NOTE_C0		EQU	16.352
NOTE_Db0	EQU	17.324
NOTE_D0		EQU	18.351
NOTE_Eb0	EQU 19.445
NOTE_E0		EQU	20.602
NOTE_F0		EQU	21.827
NOTE_Gb0	EQU	23.125
NOTE_G0		EQU	24.500
NOTE_Ab0	EQU	25.957
NOTE_A0		EQU	27.500
NOTE_Bb0	EQU	29.135
NOTE_B0		EQU	30.868

NOTE_C1		EQU	32.703
NOTE_Db1	EQU	34.648
NOTE_D1		EQU	36.708
NOTE_Eb1	EQU 38.891
NOTE_E1		EQU	41.203
NOTE_F1		EQU	43.654
NOTE_Gb1	EQU	46.249
NOTE_G1		EQU	48.999
NOTE_Ab1	EQU	51.913
NOTE_A1		EQU	55.000
NOTE_Bb1	EQU	58.270
NOTE_B1		EQU	61.735

NOTE_C2		EQU 65.406
NOTE_Db2	EQU 69.296
NOTE_D2		EQU 73.416
NOTE_Eb2	EQU 77.782
NOTE_E2		EQU 82.407
NOTE_F2		EQU 87.307
NOTE_Gb2	EQU 92.499
NOTE_G2		EQU 97.999
NOTE_Ab2	EQU 103.83
NOTE_A2		EQU 110.00
NOTE_Bb2	EQU 116.57
NOTE_B2		EQU 123.47

NOTE_C3		EQU 130.81
NOTE_Db3	EQU 138.59
NOTE_D3		EQU 146.83
NOTE_Eb3	EQU 155.56
NOTE_E3		EQU 164.81
NOTE_F3		EQU 174.61
NOTE_Gb3	EQU 185.00
NOTE_G3		EQU 196.00
NOTE_Ab3	EQU 207.65
NOTE_A3		EQU 220.00
NOTE_Bb3	EQU 233.08
NOTE_B3		EQU 246.94

NOTE_C4		EQU 261.63
NOTE_Db4	EQU 277.18
NOTE_D4		EQU 293.66
NOTE_Eb4	EQU 311.13
NOTE_E4		EQU 329.63
NOTE_F4		EQU 349.23
NOTE_Gb4	EQU 369.99
NOTE_G4		EQU 392.00
NOTE_Ab4	EQU 415.30
NOTE_A4		EQU 440.00
NOTE_Bb4	EQU 466.16
NOTE_B4		EQU 493.88

NOTE_C5		EQU 523.25
NOTE_Db5	EQU 554.37
NOTE_D5		EQU 587.33
NOTE_Eb5	EQU 622.25
NOTE_E5		EQU 659.26
NOTE_F5		EQU 698.46
NOTE_Gb5	EQU 739.99
NOTE_G5		EQU 783.99
NOTE_Ab5	EQU 830.61
NOTE_A5		EQU 880.00
NOTE_Bb5	EQU 932.33
NOTE_B5		EQU 987.77

NOTE_C6		EQU 1046.5
NOTE_Db6	EQU 1108.7
NOTE_D6		EQU 1174.7
NOTE_Eb6	EQU 1244.5
NOTE_E6		EQU 1318.5
NOTE_F6		EQU 1396.9
NOTE_Gb6	EQU 1480.0
NOTE_G6		EQU 1568.0
NOTE_Ab6	EQU 1661.2
NOTE_A6		EQU 1760.0
NOTE_Bb6	EQU 1864.7
NOTE_B6		EQU 1975.5

NOTE_C7		EQU 2093.0
NOTE_Db7	EQU 2217.5
NOTE_D7		EQU 2349.3
NOTE_Eb7	EQU 2489.0
NOTE_E7		EQU 2637.0
NOTE_F7		EQU 2793.8
NOTE_Gb7	EQU 2960.0
NOTE_G7		EQU 3136.0
NOTE_Ab7	EQU 3322.4
NOTE_A7		EQU 3520.0
NOTE_Bb7	EQU 3729.3
NOTE_B7		EQU 3951.1

NOTE_C8		EQU 4186.0
NOTE_Db8	EQU 4434.9
NOTE_D8		EQU 4698.6
NOTE_Eb8	EQU 4978.0
NOTE_E8		EQU 5274.0
NOTE_F8		EQU 5587.7
NOTE_Gb8	EQU 5919.9
NOTE_G8		EQU 6271.9
NOTE_Ab8	EQU 6644.9
NOTE_A8		EQU 7040.0
NOTE_Bb8	EQU 7458.6
NOTE_B8		EQU 7902.1

ENDC    ; __SOUND_DEF__