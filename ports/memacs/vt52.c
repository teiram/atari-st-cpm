/* ENIC CP/M-68K 8.4.1997.
 * The routines in this file
 * provide support for VT52 style terminals
 * over a serial line. The serial I/O services are
 * provided by routines in "termio.c". It compiles
 * into nothing if not a VT52 style device. The
 * bell on the VT52 is terrible, so the "beep"
 * routine is conditionalized on defining BEL.
 */
#include	<stdio.h>
#include	"ed.h"

#if	VT52

#define	NROW	24			/* Screen size.			*/
#define	NCOL	80			/* Edit if you want to.		*/
#define	BIAS	0x20			/* Origin 0 coordinate bias.	*/
#define	ESC	0x1B			/* ESC character.		*/
#define	BEL	0x07			/* ascii bell character		*/

extern	int	ttopen();		/* Forward references.		*/
extern	int	ttgetc();
extern	int	ttputc();
extern	int	ttflush();
extern	int	ttclose();
extern	int	movevt52();
extern	int	eeolvt52();
extern	int	eeopvt52();
extern	int	beepvt52();
extern	int	openvt52();

/*
 * Dispatch table. All the
 * hard fields just point into the
 * terminal I/O code.
 */
TERM	term	= {
	NROW-1,
	NCOL,
	&openvt52,
	&ttclose,
	&ttgetc,
	&ttputc,
	&ttflush,
	&movevt52,
	&eeolvt52,
	&eeopvt52,
	&beepvt52
};

movevt52(row, col)
{
	ttputc(ESC);
	ttputc('Y');
	ttputc(row+BIAS);
	ttputc(col+BIAS);
}

eeolvt52()
{
	ttputc(ESC);
	ttputc('K');
}

eeopvt52()
{
	ttputc(ESC);
	ttputc('J');
}

beepvt52()
{
#ifdef	BEL
	ttputc(BEL);
	ttflush();
#endif
}

#endif

openvt52()
{
#if	V7
	register char *cp;
	char *getenv();

	if ((cp = getenv("TERM")) == NULL) {
		puts("Shell variable TERM not defined!");
		exit(1);
	}
	if (strcmp(cp, "vt52") != 0 && strcmp(cp, "z19") != 0) {
		puts("Terminal type not 'vt52'or 'z19' !");
		exit(1);
	}
#endif
	ttopen();
}
