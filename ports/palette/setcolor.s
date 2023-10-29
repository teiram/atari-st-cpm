	.globl	_setcolor

_setcolor:
	link 	a6, #0
	movem.l d3-d7/a3-a6, -(sp)
	move.w 	10(a6), -(sp)
	move.w 	8(a6), -(sp)
	move.w 	#7, -(sp)
	trap 	#14
	addq.l	#6, sp
	movem.l (sp)+, d3-d7/a3-a6
	unlk	a6
	rts
