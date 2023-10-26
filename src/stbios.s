*****************************************************************
*           CP/M-68K BIOS for the Atari ST                      *
*****************************************************************
* Version 0.1
* Kinda works, needs improvements
* Known limitations:
*       Disk access seems to be slow, specially writing
*       This is probably caused by
*         Very simple write implementation so far, writes always
*         No interleaving implemented in disk, what would cause 
*         extra rotations to read consecutive sectors
*****************************************************************
* Version 0.2
* Improvements in write algorithm
* Use interleaving in disc A: definition, doesn't seem to 
*   improve much
* Move TPA higher to $a84e to avoid stepping over BIOS stuff
*****************************************************************
* Version 0.3
* Cache complete tracks to improve speed
* 720Kb floppy disk support
*****************************************************************
* Version 0.3.1
* Corrected a bug in cache handling on the write implementation
*****************************************************************
* Version 4
* Support different DPBs dynamically, based on the media byte of the bootsector
*    F0: 720Kb with 5 system tracks
*    F1: 360Kb with 5 system track
*****************************************************************

	.globl	_init			* bios initialization entry point
	.globl	_ccp			* ccp entry point
	.globl	cpm
	.globl	_autost,_usercmd

* Just for testing
	.globl	memrgn

CON			.equ	2
TPASTART		.equ	$8000

	.text

_init:
	move.l		#traphndl, $8c		* set up trap #3 handler
	bsr		inittpa			* discover size of tpa
	move.l		#initmsg,a1		* issue logon message
	bsr		prtstr

	clr.l		d0			* log on disk A, user 0
	rts

traphndl:
	cmpi		#nfuncs,d0
	bcc		trapng
	lsl		#2, d0			* multiply bios function by 4
	movea.l		6(pc, d0), a0		* get handler address
	jsr		(a0)			* call handler
trapng:
	rte

biosbase:
	.dc.l  		_init
	.dc.l  		wboot
	.dc.l  		constat
	.dc.l  		conin
	.dc.l  		conout
	.dc.l  		lstout
	.dc.l  		pun
	.dc.l  		rdr
	.dc.l  		home
	.dc.l  		seldsk
	.dc.l  		settrk
	.dc.l  		setsec
	.dc.l  		setdma
	.dc.l  		read
	.dc.l  		write
	.dc.l  		listst
	.dc.l  		sectran
	.dc.l  		getiob
	.dc.l  		getseg
	.dc.l  		getiob
	.dc.l  		setiob
	.dc.l  		flush
	.dc.l  		setexc

	nfuncs = (*-biosbase) / 4

wboot:
	jsr		flush 
	jmp		_ccp

constat: 
	move.w		#CON, -(sp)
	move.w 		#1, -(sp)			* BIOS 1: BCONSTAT
	trap 		#13				* Call BIOS. Result in D0
	addq.l 		#4, sp 				* Adjust stack
	rts

conin:
	move.w		#CON, -(sp)			* Console device
	move.w 		#2, -(sp)			* BIOS 02: BCONIN
	trap 		#13 				* Call BIOS. Result in D0 (Adjust to get scancode?)
	addq.l 		#4, sp 				* Adjust stack
	rts

conout: 
	move.w		d1, -(sp) 			* ASCII comes in D1
	move.w		#CON, -(sp)			* Console device
	move.w		#3, -(sp)			* BIOS 03: BCONOUT
	trap		#13				* Call GEMDOS
	addq.l		#6, sp				* Adjust stack
	rts

lstout:	
	rts

pun:
	rts

rdr:
	rts

listst:	
	move.b		#$ff, d0
	rts

home:
	clr.w		track
	rts

seldsk:
	and		#$f, d1			* Only 15 drives possible
	asl		#2, d1			* index into dph table
	move.l		#dphtab, a1		* Load DPHTAB on A1			$75340
	move.l		(a1, d1.w), a2		* Offset for selected drive DPH		$75380
	tst.b		d2			* Disk logged in?
	bne		islogged

	move.w		d1, -(sp)		* Save candidate drive

	lea		dskbuffer, a1		* Buffer to read
	move.w		#1, -(sp) 		* Sectors to read
	move.w		#0, -(sp)		* Side to read
	move.w		#0, -(sp)		* Track to read
	move.w		#1, -(sp)		* Sector to read
	move.w		d1, -(sp)		* Set drive
	clr.l		-(sp)			* Unused
	move.l		a1, -(sp)		* Buffer address to stack
	move.w		#8, -(sp)		* XBIOS 8
	trap		#14			* XBIOS trap
	add.l		#20, sp			* Restore stack address
	move.w		(sp)+, d1		* Restore candidate drive

	tst.b		d0
	bne		selerror		* return zero on error reading bs

	lea		dskbuffer, a1		* Bootsector location
	move.l		#dpb0, d0		* Default format (720Kb 5 system tracks)
	move.b		#21(a1), d2		* Media type in bootsector
	cmp.b		#$f0, d2
	bne		fmtss
	move.l		#dpb0, d0
	bra		setdpb
fmtss:
	cmp.b		#$f1, d2
	bne		setdpb
	move.l		#dpb1, d0
setdpb:
	move.l		d0, 14(a2)		* Set DPB on DPH
	move.w		#$ffff, ctrack		* Invalidate cached track
islogged:
	move.w		d1, drive		* Set drive
	move.l		a2, d0			* Return DPH on d0		$753B4
	rts
selerror:
	clr.l		d0			* On error return zero on d0
	rts

settrk:	
	move.w 		d1, track	
	rts

setsec:	
	move.w		d1, sector
	rts

sectran:
*	translate sector in d1 with translate table pointed to by d2
*	result in d0
	movea.l		d2, a0
	ext.l		d1
	tst.l		d2		* if zero, no translate table
	beq		notran
	asl		#1, d1
	move.w		#0(a0, d1.w), d0
	ext.l		d0
	rts
notran:	
	move.l		d1, d0
	rts

setdma:	
	move.l		d1, _dma
	rts

flush:
	clr.l		d0
	move.b		dirtywr, d0
	tst.b		d0
	beq		noflush			* Result is already zero
	bsr		stbioswr		* Write the pending sector
noflush:
	rts


* This is a direct read performed by the unterlying ST BIOS
* This read will transfer a complete track into the dskbuffer
* Output: D0 = 0 success, otherwise error
stbiosrd:
	move.w		#9, -(sp) 		* Sectors to read
	clr.l		d0
	move.w		track, d0
	cmp		#79, d0			* Determine side
	ble		stside0
	move.w		#1, -(sp)		* Set side 1
	sub.w		#80, d0			* Adjust track number
	bra		sttrack
stside0:
	clr.w		-(sp)			* Set side 0
sttrack:
	move.w		d0, -(sp)		* Set track
	move.w		#1, -(sp)		* Set first sector
	move.w		drive, -(sp)		* Set drive
	clr.l		-(sp)			* Unused
	pea		dskbuffer		* Buffer address to stack
	move.w		#8, -(sp)		* XBIOS 8
	trap		#14			* XBIOS trap
	add.l		#20, sp			* Restore stack address
	rts

checkdsk:
	clr.l		d0
	move.w		drive, d0
	cmp.w		ldrive, d0
	beq		samedsk
	move.w		#$ffff, ctrack		* Invalidate cached track
	move.w		d0, ldrive		* Update logged drive
samedsk:
	rts

read:
	bsr		checkdsk		* Check logged disk
	clr.l		d0
	move.w		ctrack, d0		* Check cached track
	cmp.w		track, d0
	beq		xferr			* Track already read
	bsr		stbiosrd		* Otherwise load it
	tst.b		d0
	bne		exitrd			* Exit on failure
	move.w		track, d0
	move.w		d0, ctrack		* Update cached track
xferr:
	move.w		sector, d0		* This is the sector to transfer
	lsl.w		#7, d0			* 128 bytes per sector
	lea		dskbuffer, a0
	add.l		d0, a0
	move.l		_dma, a1
	move.b		#128, d3
xloopr:
	move.b		(a0)+, (a1)+
	subq.b		#1, d3
	bne		xloopr
	clr.l		d0
exitrd:
	rts

write:
	bsr		checkdsk		* Check logged disk
	clr.l		d0
	move.w		d1, -(sp)		* Store write mode
	move.w		ctrack, d0		* Check cached track
	cmp.w		track, d0
	bne		ispendwr
* Same track but can be a different hwsector
* If it is different and we have a pending write
* we need to write now too
	move.w		wsector, d0
	andi.w		#$fffc, d0		* Keep hwsector relevant bits
	move.w		sector, d2
	andi.w		#$fffc, d2
	cmp.w		d0, d2			* Same hardware sector?
	beq		xferw			* Transfer is enough
* If the track or the hardware sector changed and we have a pending write 
* we need to write it now before the new write operation
ispendwr:
	tst.b		dirtywr			* Pending write?
	beq		nopendwr
	bsr		stbioswr
	tst.b		d0
	bne		wrerror			* Exit on error
nopendwr:
	bsr		stbiosrd		* Get the track into the buffer
	tst.b		d0
	bne		wrerror			* Error reading cluster. Out.
	move.w		track, d0
	move.w		d0, ctrack		* Update cached track
xferw:
	move.w		sector, d0		* Sector to write
	lsl.l		#7, d0			* 128 bytes per sector
	lea		dskbuffer, a1		* Track buffer
	add.l		d0, a1			* Sector position in buffer
	move.l		_dma, a0		* Data to copy
	move.b		#128, d0		* Bytes to transfer
xloopw:
	move.b		(a0)+, (a1)+
	subq.b		#1, d0
	bne		xloopw			* Loop on transfer

	move.w		drive, d0
	move.w		d0, wdrive		* Drive to write
	move.w		track, d0
	move.w		d0, wtrack		* Track to write
	move.w		sector, d0
	move.w		d0, wsector		* Sector to write

	move.w		(sp)+, d1		* Restore write mode
	cmp.b		#1, d1			* Write to directory. Now
	beq		stbioswr		* Will return directly

	move.b		#1, dirtywr		* Flag pending write
	clr.w		d0			* Return success
	rts
wrerror:
	addq.l		#2, sp			* Correct stack 
	rts

* This is a direct write performed by the unterlying ST BIOS
* Will write a 512 byte sector from dskbuffer into the sector
* Output: D0 = 0 success, otherwise error
stbioswr:
	move.w		#1, -(sp)		* Write 1 sector
	clr.l		d0
	move.w		wtrack, d0		* Track to D0
	cmp.w		#79, d0
	ble		wrside0
	move.w		#1, -(sp)
	sub.w		#80, d0			* Adjust track
	bra		wrtrack
wrside0:
	clr.w		-(sp)
wrtrack:
	move.w		d0, -(sp)		* Track to write
	move.w		wsector, d0 		* CP/M sector to write
	lsr.w		#2, d0 			* Divide by four
	addq.w		#1, d0			* Sectors are 1-9 
	move.w		d0, -(sp)		* Sector to write (hard)
	move.w		wdrive, -(sp)
	clr.l		-(sp)			* Empty 
	lea		dskbuffer, a0		* Track buffer
	subq.w		#1, d0			* Correct D0 again
	lsl.w		#7, d0			* 512 bytes per hw sector
	lsl.w		#2, d0			* 512 bytes per hw sector
	add.w		d0, a0 			* Add hw sector offset
	move.l		a0, -(sp)		* Buffer address 
	move.w		#9, -(sp)		* XBIOS flopwr
	trap		#14			* XBIOS call
	add.l		#20, sp
	tst.b		d0
	bne		wrerr
	clr.w		dirtywr			* Clear dirtywr flag on success
wrerr:
	rts

getseg:
	move.l	#memrgn,d0			* return address of mem 
*						  region table
	rts

getiob:	
	clr.l	d0
	rts

setiob:
	rts

* Set an exception vector. 

setexc:
	move.l		d2, -(sp)		* Address
	move.w		d1, -(sp)		* Vector number
	move.w		#5, -(sp)		* BIOS 5: setexec
	trap		#13			* Returns in D0 the previous 
* 						  vector address
	addq.l		#8, sp
	rts

* Utility function to print a null-terminated string using the BIOS

prtstr:	
	move.b		(a1)+, d1
	move.l		d1, -(sp)
	move.l		a1, -(sp)
	bsr		conout
	move.l		(sp)+, a1
	move.l		(sp)+, d1
	cmp.b		#0, d1
	bne		prtstr
	rts

inittpa:
	lea		memrgn, a0		* pointer to memory region table
	move.w		#1, (a0)+		* one region
	move.l		#TPASTART, (a0)+	* TPA Start
	move.l		#cpm, d0 		* CPM Start
	sub.l		#TPASTART, d0		* Substract the start of the TPA
	move.l		d0, (a0)

	move.w		#10, d1			* divide size by 1024 to show
	lsr.l		d1, d0
	lea		tpasizem, a0
	bsr		num2dec
	lea		tpaaddrm, a0
	move.l		#TPASTART, d0
	bsr		num2hex
	rts

num2dec:
	divu		#10, d0
	swap		d0
	add.b		#'0', d0
	move.b		d0, -(a0)
	clr.w		d0
	swap		d0
	tst.w		d0
	bne		num2dec
	rts

num2hex:
	move.b		d0, d1
	andi		#$f, d1
	cmp.b		#9, d1
	ble		offsetn
	add.b		#'A'-10, d1
	bra		puth
offsetn:
	add.b		#'0', d1
puth:
	move.b		d1, -(a0)
	lsr.l		#4, d0
	tst.l		d0
	bne		num2hex
	rts

	.data
initmsg:
	.dc.b   'CP/M-68K(tm) Version 1.2 03/20/84', 13, 10
	.dc.b   'Copyright (c) 1984 Digital Research, Inc.', 13, 10
	.dc.b	'Atari ST BIOS Version 0.5-rc0', 13, 10
	.dc.b	'TPA starts at $00000000'
tpaaddrm:
	.dc.b	13, 10
	.dc.b	'TPA size =        '
tpasizem:
	.dc.b	' KB', 13, 10, 0

drive:		.dc.w	0
track:		.dc.w	0
sector:		.dc.w	0
_dma:		.dc.l	0
dirtywr:	.dc.b	0
wdrive: 	.dc.w	$ffff
wtrack: 	.dc.w	$ffff
wsector:	.dc.w	$ffff

ctrack: .dc.w   $ffff	* Cached track
ldrive: .dc.w	$ffff	* The drive in use

memrgn:	ds.w	1	* filled in by inittpa at boot
	ds.l	2

* Table of pointers to dph structures
* A zero entry indicates that the drive doesn't exist
dphtab:	.dc.l	dph0	* A
	.dc.l	dph1	* B
	.dc.l	0
	.dc.l	0
	.dc.l	0
	.dc.l	0
	.dc.l	0
	.dc.l	0
	.dc.l	0
	.dc.l	0
	.dc.l	0
	.dc.l	0
	.dc.l	0
	.dc.l	0
	.dc.l	0
	.dc.l	0

* disk parameter headers
dph0:	.dc.l	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.l	dirbuf	* ptr to directory buffer (can be changed dynamically)
	.dc.l	dpb0	* ptr to disk parameter block
	.dc.l	ckv0	* ptr to check vector
	.dc.l	alv0	* ptr to allocation vector

dph1:	.dc.l	0
	.dc.w	0
	.dc.w	0
	.dc.w	0
	.dc.l	dirbuf	* ptr to directory buffer
	.dc.l	dpb0	* ptr to disk parameter block  (can be changed dynamically)
	.dc.l	ckv1	* ptr to check vector
	.dc.l	alv1	* ptr to allocation vector

* disk parameter blocks

* Media $F0. 720Kb with system tracks
dpb0:	.dc.w	36	* sectors per track
	.dc.b	4	* block shift (2K)
	.dc.b	15	* block mask
	.dc.b	0	* extent mask
	.dc.b	0	* dummy fill
	.dc.w	359	* disk size
	.dc.w	191	* 192 directory entries
	.dc.w	$0000	* directory mask
	.dc.w	16	* directory check size
	.dc.w	5	* track offset

* Media $F1. 360Kb with system tracks
dpb1:	.dc.w	36	* sectors per track
	.dc.b	4	* block shift (2K)
	.dc.b	15	* block mask
	.dc.b	0	* extent mask
	.dc.b	0	* dummy fill
	.dc.w	179	* disk size
	.dc.w	191	* 192 directory entries
	.dc.w	$0000	* directory mask
	.dc.w	16	* directory check size
	.dc.w	5	* track offset

	.bss

dirbuf:	.ds.b	128				* directory buffer

ckv0:	.ds.b	18				* check vectors
ckv1:	.ds.b	48

alv0:	.ds.b	64				* allocation vector
alv1:	.ds.b	64
alv2:	.ds.b	1024
alvM:	.ds.b	1024

dskbuffer:					* Physical sector buffer
	.ds.b	4608

	.end
