IF	!DEF(__INPUT_DEF__)
__INPUT_DEF__	SET 1

INCLUDE	"extern/gbhw.inc"


SECTION "input_data",	BSS
INPUT:	DS 1
INPUT_PRESSED:	DS 1


SECTION "input",	CODE

; Read button inputs and store the states byte in the a register
read_input:
	; read D-pad
	ld		a,		P1F_5
	ld		[rP1],	a
	ld		a,		[rP1]
	ld		a,		[rP1]
	ld		a,		[rP1]
	ld		a,		[rP1]
	and		$0F
	swap	a
	ld		b,			a

	; read Buttons
	ld      a,		P1F_4
	ld      [rP1],	a
	ld      a,		[rP1]
	ld      a,		[rP1]
	ld      a,		[rP1]
	ld      a,		[rP1]
	and     $0F
	or      b
	cpl
	ret


; Updates input global vars
update_input:
	ld		a,			[INPUT]
	ld		b,			a
	push	bc
	call	read_input
	pop		bc
	ld		[INPUT],	a
	xor		b
	ld		c,	a
	ld		a,	b
	cpl
	and		c
	ld		[INPUT_PRESSED],	a
	ret

	


; Initialize input global vars
init_input:
	ld		a,					$00
	ld		[INPUT],			a
	ld		[INPUT_PRESSED],	a


ENDC	; __INPUT_DEF__
