/*
 * The routines in this file provide support for VT52 style terminals
 * over a serial line. The serial I/O services are provided by routines in
 * "termio.c". It compiles into nothing if not an VT52 device.
 */

#define	termdef	1			/* don't define "term" external */

#include        <stdio.h>
#include	"estruct.h"
#include        "edef.h"

#if     VT52

#define NROW    25                      /* Screen size.                 */
#define NCOL    80                      /* Edit if you want to.         */
#define	MARGIN	8			/* size of minimim margin and	*/
#define	SCRSIZ	64			/* scroll size for extended lines */
#define BEL     0x07                    /* BEL character.               */
#define ESC     0x1B                    /* ESC character.               */

extern  int     ttopen();               /* Forward references.          */
extern  int     ttgetc();
extern  int     ttputc();
extern  int     ttflush();
extern  int	vt52close();
extern  int     ttclose();
extern  int     vt52move();
extern  int     vt52olee();
extern  int     vt52eeop();
extern  int     vt52beep();
extern  int     vt52open();
extern	int	vt52rev();
/*
 * Standard terminal interface dispatch table. Most of the fields point into
 * "termio" code.
 */
TERM    term    = {
        NROW-1,
        NCOL,
	MARGIN,
	SCRSIZ,
        vt52open,
        vt52close,
        ttgetc,
        ttputc,
        ttflush,
        vt52move,
        vt52olee,
        vt52eeop,
        vt52beep,
	vt52rev
};

vt52move(row, col)
{
        ttputc(ESC);
        ttputc('Y');
        ttputc(row+32);
        ttputc(col+32);
}

vt52olee()
{
        ttputc(ESC);
        ttputc('K');
}

vt52eeop()
{
        ttputc(ESC);
        ttputc('J');
}

vt52rev(state)		/* change reverse video state */

int state;	/* TRUE = reverse, FALSE = normal */

{
	ttputc(ESC);
	ttputc(state ? 'p': 'q');
}

vt52beep()
{
        ttputc(BEL);
        ttflush();
}

vt52open()
{
	revexist = TRUE;
        ttopen();

	ttputc(0x1b);		/* enabel 25th line			*/
	ttputc('x');
	ttputc('1');
	
	ttputc(0x1b);		/* hold screen */
	ttputc('x');
	ttputc('3');

	ttputc(0x1b);		/* discard at end of line	*/
	ttputc('w');
	
}

vt52close()
{
	ttputc(0x1b);		/* reset terminal to power up config	*/
	ttputc('z');
	
	ttclose();
	
}

#endif

