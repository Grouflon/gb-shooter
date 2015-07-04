IF	!DEF(__MACROS_DEF__)
__MACROS_DEF__	SET 1

FOR:		MACRO

			ld		hl,	\1	; Start address
			ld		a,	\2	; Iterations count

.for\@		cp		0
			jr		z,	.forend\@

			push	af
			push	hl
			call	\4
			pop		hl
			pop		af

			dec		a
			ld		bc,	\3
			add		hl,	bc
			jr		.for\@
.forend\@	
			ENDM


ENDC	; __MACROS_DEF__
