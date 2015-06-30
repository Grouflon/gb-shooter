IF	!DEF(__DISPLAY_DEF__)
__DISPLAY_DEF__	SET 1

INCLUDE "extern/gbhw.inc"
INCLUDE "utils/time.asm"

SECTION "display",	CODE

; Wait for the next vertical blank, then disable LCD
disable_lcd:
	ld		a,	[rLCDC]
	rlca					; move LCD enable bit into carry flag
	ret		nc				; exit function if LCD disabled
	call	wait_vblank

	ld		a,			[rLCDC]	; vertical scan is over, we can disable LCD
	res		7,			a		; Reset bit 7 (LCD enable)
	ld		[rLCDC],	a
	ret


ENDC	; __DISPLAY_DEF__
