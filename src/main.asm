INCLUDE "gbhw.inc"
INCLUDE "memory.inc"


; Entry point
SECTION "main"  , HOME[$0100]
main:
    nop
	jp initialize

	ROM_HEADER	ROM_NOMBC,	ROM_SIZE_32KBYTE,	RAM_SIZE_0KBYTE

initialize:
	di
    ld	sp      , $ffff

loop:
	nop
	jp	loop
