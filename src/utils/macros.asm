IF	!DEF(__MACROS_DEF__)
__MACROS_DEF__	SET 1


; \1	- Start address
; \2	- Iterations count
; \3	- Step size
; \4	- Function to call with hl pointing at the right address
FOR:		MACRO
			push	hl
			push	af
			ld		hl,	\1
			ld		a,	\2

.for\@		cp		0
			jr		z,	.forend\@

			push	af
			push	hl
			call	\4
			pop		hl
			pop		af

			dec		a
			push	bc
			ld		bc,	\3
			add		hl,	bc
			pop		bc
			jr		.for\@
.forend\@
			pop		af
			pop		hl
			ENDM


OAM_FOR:	MACRO

			ld		hl, \1
			ld		de,	\2
			ld		a,	\3

.for\@		cp		0
			jr		z,	.forend\@

			push	af
			push	hl
			push	de
			call	\5
			pop		de
			pop		hl
			pop		af

			dec		a
			ld		bc,	\4
			add		hl,	bc
			inc		de
			inc		de
			inc		de
			inc		de
			jr		.for\@
.forend\@
			ENDM


SWP8:	MACRO
		
		IF	STRCMP("\1", "\2")
			IF STRCMP("\1", "h") && STRCMP("\1", "l") && STRCMP("\2", "h") && STRCMP("\2", "l")
SWP8_REG		EQUS	"h"
SWP8_REG16		EQUS	"hl"
			ENDC
			IF !STRCMP("\1", "h") || !STRCMP("\1", "l") || !STRCMP("\2", "h") || !STRCMP("\2", "l")
				IF !STRCMP("\1", "h") || !STRCMP("\1", "l")
					IF !STRCMP("\2", "h") || !STRCMP("\2", "l")				
SWP8_REG				EQUS	"a"
SWP8_REG16				EQUS	"af"
					ENDC
					IF !STRCMP("\2", "a")
SWP8_REG				EQUS	"b"
SWP8_REG16				EQUS	"bc"
					ENDC
					IF STRCMP("\2", "a")
SWP8_REG				EQUS	"a"
SWP8_REG16				EQUS	"af"
					ENDC
				ENDC
				IF !STRCMP("\2", "h") || !STRCMP("\2", "l")
					IF !STRCMP("\1", "h") || !STRCMP("\1", "l")				
SWP8_REG				EQUS	"a"
SWP8_REG16				EQUS	"af"
					ENDC
					IF !STRCMP("\1", "a")
SWP8_REG				EQUS	"b"
SWP8_REG16				EQUS	"bc"
					ENDC
					IF STRCMP("\1", "a")
SWP8_REG				EQUS	"a"
SWP8_REG16				EQUS	"af"
					ENDC
				ENDC
			ENDC
			push	SWP8_REG16
			ld		SWP8_REG,	\1
			ld		\1,			\2
			ld		\2,			SWP8_REG
			pop		SWP8_REG16

			PURGE	SWP8_REG, SWP8_REG16
		ENDC
		ENDM


SWP16:	MACRO
		push	\1
		push	\2
		pop		\1
		pop		\2
		ENDM

; Define HI LO with the corresponding register of the 16bit register passed as \1
; You should purge HI and LO as soon as you used them in order to be able to reuse this macro
HILO:	MACRO
		IF !STRCMP("\1", "bc")
HI			EQUS	"b"
LO			EQUS	"c"
		ENDC
		IF !STRCMP("\1", "de")
HI			EQUS	"d"
LO			EQUS	"e"
		ENDC
		IF !STRCMP("\1", "hl")
HI			EQUS	"h"
LO			EQUS	"l"
		ENDC
		ENDM


; \1	- 16bit register to compare
; \2	- Number to compare with
; This macro loses the content of a
CP16:	MACRO
		HILO	\1
	
		push	\1
		ld		a,	HI
		ld		\1,	\2
		cp		HI
		jr		nz,	.end\@
		pop		\1
		push	\1
		ld		a,	LO
		ld		\1,	\2
		cp		LO
.end\@:
		pop		\1
		PURGE	HI, LO
		ENDM

ENDC	; __MACROS_DEF__
