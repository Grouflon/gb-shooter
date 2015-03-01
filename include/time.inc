IF	!DEF(__TIME_INC_DEF__)
__TIME_INC_DEF__	SET 1

INCLUDE "gbhw.inc"

; Wait for the next vertical blank frame
wait_vblank:
.wait_vblank_start:
    ld      a               , [rLY]
    cp      145
    jr      nz              , .wait_vblank_start ; loop here while not in vertical blank
    ret


; Wait the amount of cycles stored in %de
; de    -   wait duration
wait:
.wait_start:
    dec     de
    ld      a               , d
    or      e
    jr      z               , .wait_end
    nop
    jr      .wait_start
.wait_end:
    ret

ENDC	; __TIME_INC_DEF__
