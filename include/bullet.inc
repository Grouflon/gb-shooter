IF  !DEF(__BULLET_INC_DEF__)
__BULLET_INC_DEF__ SET 1

INCLUDE "gbhw.inc"
INCLUDE "memory.inc"

B_FACING_LEFT	EQU	%00000001
B_FACING_RIGHT	EQU	%00000010
B_FACING_UP		EQU	%00000100
B_FACING_DOWN	EQU	%00001000

B_SPRITE		EQU 2

			RSRESET
B_SPR		RB 1
B_Y			RB 1
B_X			RB 1
B_FACING	RB 1
B_SIZEOF	RB 0

		


SECTION "bullet", CODE


; hl	- Bullet struct address
; b		- Sprite index
bullet_init:
.b_sprite_index
	ld		a,		b
	ld		[hl],	a
.b_coords
	inc		hl
	ld		a,		100
	ld		[hl],	a
	inc		hl
	ld		[hl],	a
.b_facing
	inc		hl
	ld		a,		B_FACING_RIGHT
	ld		[hl],	a
.b_init_end
	call	bullet_update_sprite
	ret


; hl	- Bullet struct address
bullet_update_sprite:
	push	hl
	pop		de
	ld		hl,		_OAMRAM
	ld		bc,		4
	ld		a,		[de]
	call	find_address
	
	inc		de
	; Y
	ld		a,		[de]
	ld		[hl],	a
	; X
	inc		de
	inc		hl
	ld		a,		[de]
	ld		[hl],	a
	; Sprite num
	inc		hl
	ld		a,		B_SPRITE
	ld		[hl],	a

	ret



ENDC    ; __BULLET_INC_DEF__
