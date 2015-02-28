IF	!DEF(__INPUT_INC_DEF__)
__INPUT_INC_DEF__	SET 1

INCLUDE	"gbhw.inc"


INPUT_DOWN      EQU %10000000
INPUT_UP        EQU %01000000
INPUT_LEFT      EQU %00100000
INPUT_RIGHT     EQU %00010000
INPUT_START     EQU %00001000
INPUT_SELECT    EQU %00000100
INPUT_B         EQU %00000010
INPUT_A         EQU %00000001

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

