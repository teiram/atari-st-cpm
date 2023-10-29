*****************************************************************
*		CP/M Bootsector for the Atari ST		*
*****************************************************************
* Version 0.1
* Just works
*****************************************************************
* Version 0.2
* Some hardware initialization
* 	Screen resolution
* 	Colors
* 	Cursor
*****************************************************************
* Version 0.3
*	Parameterized version
*	Remove unused boot variables
*	Parameters
* Offset     Size     Description
* -------------------------------
* $1E		4	ldaddr
* $22		2	start sector
* $24		2	Number of sectors
* $26		2	Foreground color
* $28		2	Background color
*****************************************************************

BSSOFFS			.equ	$545A
BSSSIZ			.equ	$26f8
	.text
	bra.s		bootit
oem:
	.ds.b		6
serial:
	.dc.b		$ff, $ff, $ff
bps:
	.dc.b		0, 2
spc:
	.dc.b		1
ressec:
	.dc.b		0, 0
nfats:
	.dc.b		0
ndirs:
	.dc.b		0, 0
nsects:
	.dc.b		$A0, $05
media:
	.dc.b		$f0
spf:
	.dc.b		0, 0
spt:
	.dc.b		9, 0
nheads:
	.dc.b		2, 0
nhid:
	.dc.b		0, 0
**************************************************
* Custom section
**************************************************
ldaddr:
	.dc.l		$67f00
ssect:
	.dc.w		1			* Load from sector 1
sectcnt:
	.dc.w		45			* Sectors to load
fgcolor:
	.dc.w		$060			* Foreground color
bgcolor:
	.dc.w		$000			* Background color

bootit:
	btst		#7, $fffa01		* Monochrome monitor?
	beq		loadcpm

	move.w		#1, -(sp)		* Resolution
	move.l		#-1, -(sp)		* Paddress, no change
	move.l		#-1, -(sp)		* Laddress, no change
	move.w		#5,-(sp)		* xbios: Set screen
	trap		#14			* call xbios
	add.l		#12, sp			* Correct stack

	move.w		fgcolor(pc), -(sp) 	* Color
	move.w		#3, -(sp)		* Color number
	move.w		#7,-(sp)		* xbios: Set color
	trap		#14			* call xbios
	addq.l		#6, sp			* Correct stack

	move.w		bgcolor(pc), -(sp) 	* Color
	move.w		#0, -(sp)		* Color number
	move.w		#7,-(sp)		* xbios: Set color
	trap		#14			* call xbios
	addq.l		#6, sp			* Correct stack

loadcpm:

	move.w		#20, -(sp)		* Cursor blink rate
	move.w		#1, -(sp)		* Enable cursor
	move.w		#21, -(sp)		* xbios: cursor
	trap		#14
	addq.l		#6, sp

	pea		banner(pc)		* Boot message
	move.w		#9, -(sp)		* gemdos: print message
	trap		#1
	addq.l		#6, sp

	pea		loadmsg(pc)
	move.w		#9, -(sp)
	trap		#1
	addq.l		#6, sp

	move.w		#0, -(sp)		* Drive number
	move.w		ssect(pc), -(sp)	* Start sector
	move.w		sectcnt(pc), -(sp)	* Sector count
	move.l		ldaddr(pc), -(sp)	* Destination address
	move.w		#8, -(sp)		* Physical mode (512 bytes, no trans)
	move.w		#4, -(sp)
	trap		#13
	add.l		#14, sp

	pea		clsscr(pc)
	move.w		#9, -(sp)
	trap		#1
	addq.l		#6, sp
	move.l		ldaddr(pc), a0

	movea.l		a0, a1
	add.l		#BSSOFFS, a1
	clr.l		d0
	move.w		#BSSSIZ, d0
cloop:
	clr.b		(a1)+
	dbra		d0, cloop

	jmp		(a0)

banner:
	.dc.b		27, 'b', 1, 'Atari Bootloader 0.4', 13, 10, 27, 'b', 3, 0
loadmsg:
	.dc.b		'Loading CP/M-68K...', 13, 10, 0
clsscr:
	.dc.b		27, 'E'

	.org		$01fe
checksum:
	.dc.w		$ffff			* Write externally upon calculation

	.end
