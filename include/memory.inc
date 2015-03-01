IF	!DEF(__MEMORY_INC_DEF__)
__MEMORY_INC_DEF__	SET 1


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


; Finds the adress corresponding to the nth element of an array of structures
; hl	-	start of array's address
; bc	-	structure size
; a		-	searched index
;
; ret hl	-	return address
find_address:
.find_address_loop
	cp		0
	jr		z,		.find_address_end
	add		hl,		bc
	dec		a
	jr		.find_address_loop
.find_address_end
	ret


ENDC	; __MEMORY_INC_DEF__
