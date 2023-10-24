cpmlib: ccpif.o except10.o ccpbdos.o ccpload.o bdosif.o conbdos.o bdosmisc.o\
        dskutil.o fileio.o bdosrw.o bdosmain.o iosys.o pgmld.o except.o\
        filetyps.o stack.o ccp.o
	era cpmlib
	ar68 r cpmlib ccpif.o except10.o ccpbdos.o ccpload.o bdosif.o
	ar68 r cpmlib conbdos.o bdosmisc.o dskutil.o fileio.o bdosrw.o
	ar68 r cpmlib bdosmain.o iosys.o pgmld.o except.o filetyps.o stack.o
	ar68 r cpmlib cppload.o ccp.o

ccpif.o: ccpif.s
	as68 -s 0c: -l -u ccpif.s

except10.o: except10.s
	cp68 -dm68010 exceptn.s except10.s
	as68 -s 0c: -l -u -n except10.s
	era except10.s

except.o: exceptn.s
	cp68  exceptn.s except.s
	as68 -s 0c: -l -u -n except.s
	era except.s

ccpbdos.o:  ccpbdos.s
	as68 -s 0c: -l -u ccpbdos.s

ccpload.o: ccpload.s
	as68 -s 0c: -l -u ccpload.s

bdosif.o: bdosif.s
	as68 -s 0c: -l -u bdosif.s

pgmld.o: pgmld.s
	as68 -s 0c: -l -u pgmld.s

filetyps.o: filetyps.s
	as68 -s 0c: -l -u filetyps.s

stack.o: stack.s
	as68 -s 0c: -l -u stack.s

conbdos.o: conbdos.c bdosinc.h bdosdef.h biosdef.h
	cc -c conbdos.c

bdosmisc.o: bdosmisc.c bdosinc.h bdosdef.h biosdef.h
	cc -c bdosmisc.c

dskutil.o: dskutil.c bdosinc.h bdosdef.h
	cc -c dskutil.c

fileio.o: fileio.c pktio.h
	cc -c fileio.c

bdosrw.o: bdosrw.c bdosdef.h bdosinc.h
	cc -c bdosrw.c

bdosmain.o: bdosmain.c bdosinc.h bdosdef.h biosdef.h
	cc -c bdosmain.c

iosys.o: iosys.c bdosinc.h bdosdef.h biosdef.h pktio.h
	cc -c iosys.c

ccp.o: ccp.c
	cc -c ccp.c
