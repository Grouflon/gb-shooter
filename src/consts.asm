IF	!DEF(__CONSTS_DEF__)
__CONSTS_DEF__	SET 1

PLAYER_H_SPRITE		EQU 0
PLAYER_V_SPRITE		EQU 1
PLAYER_FACING_LEFT	EQU	%00000001
PLAYER_FACING_RIGHT	EQU	%00000010
PLAYER_FACING_UP	EQU	%00000100
PLAYER_FACING_DOWN	EQU	%00001000
PLAYER_WIDTH		EQU	8
PLAYER_HEIGHT		EQU	8
PLAYER_HSPEED		EQU %00000011
PLAYER_VSPEED		EQU %00000001
PLAYER_SHOOTINTERVAL EQU 25


BULLETS_MAX			EQU 4
BULLET_SPRITE		EQU 2
BULLET_SPEED		EQU %00000100
BULLET_FACING_LEFT	EQU	%00000001
BULLET_FACING_RIGHT	EQU	%00000010
BULLET_FACING_UP	EQU	%00000100
BULLET_FACING_DOWN	EQU	%00001000

ENEMIES_MAX			EQU 10
ENEMY_SPRITE		EQU 1
ENEMY_WIDTH			EQU	8
ENEMY_HEIGHT		EQU	8
ENEMY_XSPEED		EQU 0
ENEMY_YSPEED		EQU	4

ENEMY_TYPE_STD		EQU 1
ENEMY_TYPE_SLOW		EQU 2
ENEMY_TYPE_DASH		EQU 3

ENEMY_STD_YSPEED	EQU 4
ENEMY_SLOW_YSPEED	EQU 1
ENEMY_DASH_THRESHOLD EQU 32
ENEMY_DASH_BASESPEED EQU 1
ENEMY_DASH_DASHSPEED EQU 5

LC_WAVE_INTERVAL	EQU 20

FONT_TILES			EQU $9200
OAM_PLAYER			EQU $C000
OAM_BULLETS			EQU OAM_PLAYER + 4
OAM_ENEMIES			EQU OAM_BULLETS + (4*BULLETS_MAX)

ENDC	; __CONSTS_DEF__
