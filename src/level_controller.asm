IF  !DEF(__LEVEL_CONTROLLER_DEF__)
__LEVEL_CONTROLLER_DEF__ SET 1

LC_WAVE_DATA_SIZE	EQU	20

section "level_controller_vars", BSS
v_lc_wave_timer:	DS 1
v_lc_wave_count:	DS 1

section "level_controller", CODE

level_controller_init:
	ld	a,					LC_WAVE_INTERVAL
	ld	[v_lc_wave_timer],	a
	ld	a,					0
	ld	[v_lc_wave_count],	a
	ret

level_controller_update:
	ld	a,	[v_lc_wave_timer]
	cp	0
	jr	z,	.wave_out
	dec	a
	ld	[v_lc_wave_timer],	a
	ret
.wave_out:
	ld	a,	LC_WAVE_INTERVAL
	ld	[v_lc_wave_timer],	a
	ld	a,	[v_lc_wave_count]
	ld	hl,	level
	ld	bc,	LC_WAVE_DATA_SIZE
.wave_find_loop:
	cp	0
	jr	z,	.wave_found
	dec	a
	add	hl,	bc
	jr	.wave_find_loop
.wave_found:
	CP16 hl, level_end
	jr	nz,	.wave_spawn
	ld	hl,	level
	ld	a,	0
	ld	[v_lc_wave_count],	a
.wave_spawn:
	; set next wave value
	ld	a,	[v_lc_wave_count]
	inc	a
	ld	[v_lc_wave_count],	a

	; spon doze enemiz
	ld	a,	0	; iterator
	ld	b,	0	; Y
	ld	c,	8	; X
.spawn_loop:
	cp		LC_WAVE_DATA_SIZE
	jr		z,	.spawn_end
	push	af
	ld		a,	[hl]
	cp		0
	jr		z,	.spawn_next
	push	hl
	call	enemy_create
	pop		hl
.spawn_next:
	ld		a,	c
	add		8
	ld		c,	a
	pop		af
	inc		a
	inc		hl
	
	jp		.spawn_loop
.spawn_end:
	ret

ENDC    ; __LEVEL_CONTROLLER_DEF__
