IF	!DEF(__INPUT_INC_DEF__)
__INPUT_INC_DEF__	SET 1

INCLUDE	"gbhw.inc"


SECTION "input",	CODE

; Read button inputs and store the states byte in register %a
; a    -   Return register
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


ENDC	; __INPUT_INC_DEF__

