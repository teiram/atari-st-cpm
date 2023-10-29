	.globl _bios1,_bios2,_bios3

_bios1:
	link	a6,#0
	movem.l	d3-d7/a3-a6,-(a7)
	move.w	8(a6),d0
	trap	#3
	movem.l	(a7)+,d3-d7/a3-a6
	unlk	a6
	rts

_bios2:
	link	a6,#0
	movem.l	d3-d7/a3-a6,-(a7)
	move.w	8(a6),d0
	move.l	10(a6),d1
	trap	#3
	movem.l	(a7)+,d3-d7/a3-a6
	unlk	a6
	rts

_bios3:
	link	a6,#0
	movem.l	d3-d7/a3-a6,-(a7)
	move.w	8(a6),d0
	move.l	10(a6),d1
	move.l	14(a6),d2
	trap	#3
	movem.l	(a7)+,d3-d7/a3-a6
	unlk	a6
	rts
                                                   