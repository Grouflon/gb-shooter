IF						!DEF(__MEMORY_INC_DEF__)
__FUNCTIONS_INC_DEF__	SET 1


SECTION "memory",	CODE

; Copy one memory location to another
; hl    -   adress to copy from
; de    -   adress to copy to
; bc    -   number of bytes to copy
mem_copy:
	ld		a,		[hl]
	ld		[de],	a
	dec		bc
	ld		a,		c
	or		b
	ret		z
	inc		hl
	inc		de
	jr		mem_copy


; Fill a memory location with a specified byte
; de    -   adress where to start fill
; bc    -   number of bytes to fill
; l     -   byte used for fill
mem_fill:
	ld		a,		l
	ld		[de],	a
	dec		bc
	ld		a,		c
	or		b
	ret		z
	inc		de
	jr		mem_fill


ENDC    				; __MEMORY_INC_DEF__

