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


LOGR:	MACRO
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


ENDC    ; __LOG_DEF__
