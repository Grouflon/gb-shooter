IF	!DEF(__DMA_DEF__)
__DMA_DEF__	SET 1

INCLUDE "extern/gbhw.inc"
INCLUDE "utils/memory.asm"


SECTION "oam_buffer",	BSS[$C000]
OAM_BUFFER:	DS	40*4


SECTION "dma_code", CODE
dma_code:
	push	af
	push	hl
	ld		hl,		OAM_BUFFER
	ld		a,		h
	ld		[rDMA], a
	ld		a,		$28

.wait:
	dec		a
	jr		nz,		.wait
	pop		af
	pop		hl
	ret
dma_code_end:

copy_dma_code:
	ld		hl,		dma_code
	ld		de,		dma
	ld		bc,		dma_code_end-dma_code
	call	mem_copy
	ret


SECTION "dma", HRAM
dma:	DS	dma_code-dma_code_end

ENDC	; __DMA_DEF__
