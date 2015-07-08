IF  !DEF(__LOG_DEF__)
__LOG_DEF__ SET 1


LOG:	MACRO
I		SET		0
		push	af
		REPT	STRLEN(\1)
		ld		a,			STRSUB(\1, I+1, 1)
		ld		[_SCRN0+I],	a
I		SET		I+1
		ENDR
		pop		af
		ENDM


LOGR8:	MACRO
CB		SET		0
		REPT	8

		bit		CB,		\1
		push	af
		jr		z,		.zero\@
.one\@	ld		a,		"1"
		jr		.draw\@
.zero\@	ld		a,		"0"
.draw\@	ld		[_SCRN0+7-CB],	a
		pop		af
		
CB		SET		CB+1
		ENDR
PURGE	CB
		ENDM


LOGR8I:	MACRO

		; Save everything
		push	af
		push	bc
		push	de
		push	hl

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
		ld		[_SCRN0],	a
		ld		a,			"0"
		add		a,			c
		ld		[_SCRN0+1],	a
		ld		a,			"0"
		add		a,			b
		ld		[_SCRN0+2],	a

		; Restore everything
		pop		hl
		pop		de
		pop		bc
		pop		af

		ENDM


ENDC    ; __LOG_DEF__
