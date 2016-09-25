patterns_start:
; pattern 1
DB	16	;	size of the pattern
DW	C4,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	B3,	0	; CH1
DW	C2,	0,	C2,	C2,	C2,	0,	C2, C2,	C2,	0,	C2,	C2,	C2,	0,	C2,	0	; CH2

; pattern 2
DB	8	;	size of the pattern
DW	0,	0,	0,	0,	0,	0,	0,	0	; CH1
DW	G2,	0,	G2,	G2,	G2,	0,	G2,	G2	; CH2
patterns_end:


sequence_start:
DB	1,2,	2,1
sequence_end:

