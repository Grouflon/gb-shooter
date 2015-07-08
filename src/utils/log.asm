IF  !DEF(__LOG_DEF__)
__LOG_DEF__ SET 1

; Log macros write the ascii code of each character of your string/number,
; starting at the given memory location

; \1	- String to log
; \2	- Log starting address
LOG:	MACRO
I		SET		0
		push	af
		REPT	STRLEN(\1)
		ld		a,			STRSUB(\1, I+1, 1)
		ld		[\2+I],	a
I		SET		I+1
		ENDR
		pop		af
		ENDM


; \1	- 8bit Register to log
; \2	- Log starting address
LOGR8:	MACRO
CB		SET		0
		REPT	8

		bit		CB,		\1
		push	af
		jr		z,		.zero\@
.one\@	ld		a,		"1"
		jr		.draw\@
.zero\@	ld		a,		"0"
.draw\@	ld		[\2+7-CB],	a
		pop		af
		
CB		SET		CB+1
		ENDR
PURGE	CB
		ENDM


; \1	- 8bit Register to log
; \2	- Log starting address
LOGR8I:	MACRO

		; Save everything
		push	af
		push	bc
		push	de

		; init
		ld		a,	\1
		ld		b,	0
		ld		c,	0
		ld		d,	0

.loop\@ cp		0
		jr		z,	.draw\@
		dec		a
		inc		b
		SWP8	a,	b
		cp		10
		SWP8	a,	b
		jr		nz,	.loop\@
		ld		b,	0
		inc		c
		SWP8	a,	c
		cp		10
		SWP8	a,	c
		jr		nz, .loop\@
		ld		c,	0
		inc		d
		jr		.loop\@

.draw\@	ld		a,			"0"
		add		a,			d
		ld		[\2],	a
		ld		a,			"0"
		add		a,			c
		ld		[\2 + 1],	a
		ld		a,			"0"
		add		a,			b
		ld		[\2 + 2],	a

		; Restore everything
		pop		de
		pop		bc
		pop		af

		ENDM


; \1	- 8bit Register to log
; \2	- Log starting address
LOGR8H:	MACRO

		; Save everything
		push	af
		push	bc

		; init
		ld		a,	\1
		ld		b,	0
		ld		c,	0

.loop\@ cp		0
		jr		z,	.draw\@
		dec		a
		inc		b
		SWP8	a,	b
		cp		16
		SWP8	a,	b
		jr		nz,	.loop\@
		ld		b,	0
		inc		c
		jr		.loop\@

.draw\@	ld		a,			c
		cp		9
		jr		nc,			.chex\@
		ld		a,			"0"
		jr		.drw0\@
.chex\@	ld		a,			c
		sub		10
		ld		c,			a
		ld		a,			"A"
.drw0\@	add		a,			c
		ld		[\2],	a
		ld		a,			b
		cp		9
		jr		nc,			.bhex\@
		ld		a,			"0"
		jr		.drw1\@
.bhex\@	ld		a,			b
		sub		10
		ld		b,			a
		ld		a,			"A"
.drw1\@	add		a,			b
		ld		[\2+1],	a

		; Restore everything
		pop		bc
		pop		af

		ENDM

; \1	- 8bit Register to log
; \2	- Log starting address

LOGR16H:MACRO
		IF !STRCMP("\1", "bc")
			LOGR8H	b,	\2
			LOGR8H	c,	(\2+2)
		ENDC
		IF !STRCMP("\1", "de")
			LOGR8H	d,	\2
			LOGR8H	e,	(\2+2)
		ENDC
		IF !STRCMP("\1", "hl")
			LOGR8H	h,	\2
			LOGR8H	l,	(\2+2)
		ENDC
		IF !STRCMP("\1", "sp")
			push	hl
			ld		hl, 2
			add		hl, sp
			LOGR16H	hl,	\2
			pop		hl
		ENDC
		ENDM


ENDC    ; __LOG_DEF__
