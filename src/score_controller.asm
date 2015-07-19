IF  !DEF(__SCORE_CONTROLLER_DEF__)
__SCORE_CONTROLLER_DEF__ SET 1

SECTION "score_controller_vars", BSS
v_score:			DS 3
v_score_chars:		DS 6
v_score_changed:	DS 1

SECTION "score_controller", CODE

score_controller_init:
	ld	a,	0
	ld	[v_score],		a
	ld	[v_score+1],	a
	ld	[v_score+2],	a
	ld	[v_score_changed],a
	ld	a,	"0"
	ld	[v_score_chars+0],a
	ld	[v_score_chars+1],a
	ld	[v_score_chars+2],a
	ld	[v_score_chars+3],a
	ld	[v_score_chars+4],a
	ld	[v_score_chars+5],a
	ret

; a	- value to add
score_add:
	ld		a,					1
	ld		[v_score_changed],	a

	ld		hl,	v_score
	add		a,	[hl]
	cp		100
	jr		nc,	.overflow1
	ld		[hl],	a
	ret
.overflow1:
	sub		a,	100
	ld		[hl],	a
	ld		a,	1
	ld		hl,	v_score+1
	add		a,	[hl]
	cp		100
	jr		nc,	.overflow2
	ld		[hl],	a
	ret
.overflow2:
	sub		a,	100
	ld		[hl],	a
	ld		a,	1
	ld		hl,	v_score+2
	add		a,	[hl]
	cp		100
	jr		nc,	.overflow3
	ld		[hl],	a
	ret
.overflow3:
	ld		a,	0
	ld		[v_score+1],	a
	ld		[v_score+2],	a
	ret

score_update:
	ld	a,	[v_score_changed]
	cp	0
	ret	z

	ld	a,	0
	ld	[v_score_changed],	a
	ld	b,	"0"

SCR_INDEX	SET 0
REPT	3
	ld		a,	[v_score+SCR_INDEX]
	add		a,	0
	daa
	res		4,a
	res		5,a
	res		6,a
	res		7,a
	add		a,	b
	ld		[v_score_chars+(SCR_INDEX*2)], a
	ld		a,	[v_score+SCR_INDEX]
	add		a,	0
	daa
	res		0,a
	res		1,a
	res		2,a
	res		3,a
	swap	a
	add		a,	b
	ld		[v_score_chars+(SCR_INDEX*2)+1], a
	
SCR_INDEX	SET SCR_INDEX+1
ENDR
PURGE	SCR_INDEX

	ret

score_draw:
	ld	hl,	_SCRN1+19

SCR_INDEX	SET 0
REPT	6

	ld	a,		[v_score_chars+SCR_INDEX]
	ldd	[hl],	a

SCR_INDEX	SET SCR_INDEX+1
ENDR
PURGE SCR_INDEX
	ret

ENDC    ; __SCORE_CONTROLLER_DEF__
