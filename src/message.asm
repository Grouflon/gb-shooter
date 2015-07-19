IF  !DEF(__MESSAGE_DEF__)
__MESSAGE_DEF__ SET 1

MESSAGE_SIZE	EQU	20

SECTION	"message_vars", BSS
v_message:	DS MESSAGE_SIZE

SECTION "message", CODE

message_init:
	ld	a,	MESSAGE_SIZE
	ld	hl,	v_message
.loop:
	cp	0
	ret	z
	push	af
	ld		a,		0
	ldi		[hl],	a
	pop		af
	dec		a
	jr		.loop

message_draw:
MES_INDEX	SET	0
REPT	MESSAGE_SIZE
	ld	a,						[v_message + MES_INDEX]
	ld	[_SCRN1 + MES_INDEX],	a
MES_INDEX	SET MES_INDEX+1
ENDR
PURGE MES_INDEX
	ret

MESSAGE_SET:	MACRO
MES_IDX	SET	0
REPT	MESSAGE_SIZE
IF	MES_IDX	< STRLEN(\1)
	ld	a,	STRSUB(\1, MES_IDX+1, 1)
ELSE
	ld	a,	" "
ENDC
	ld	[v_message + MES_IDX],	a
MES_IDX	SET MES_IDX+1
ENDR
PURGE	MES_IDX
ENDM

ENDC    ; __MESSAGE_DEF__
