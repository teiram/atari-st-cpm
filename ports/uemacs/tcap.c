/*	tcap:	Unix V5, V7 and BS4.2 Termcap video driver
		for MicroEMACS
*/

#define	termdef	1			/* don't define "term" external */

#include <stdio.h>
#include	"estruct.h"
#include        "edef.h"

#if TERMCAP

#define NROW    24
#define NCOL    80
#define	MARGIN	8
#define	SCRSIZ	64
#define BEL     0x07
#define ESC     0x1B

extern int      ttopen();
extern int      ttgetc();
extern int      ttputc();
extern int      ttflush();
extern int      ttclose();
extern int      tcapmove();
extern int      tcapeeol();
extern int      tcapeeop();
extern int      tcapbeep();
extern int	tcaprev();
extern int      tcapopen();
extern int      tput();
extern char     *tgoto();

#define TCAPSLEN 315
char tcapbuf[TCAPSLEN];
char *UP, PC, *CM, *CE, *CL, *SO, *SE;

TERM term = {
        NROW-1,
        NCOL,
	MARGIN,
	SCRSIZ,
        tcapopen,
        ttclose,
        ttgetc,
        ttputc,
        ttflush,
        tcapmove,
        tcapeeol,
        tcapeeop,
        tcapbeep,
        tcaprev
};

tcapopen()

{
        char *getenv();
        char *t, *p, *tgetstr();
        char tcbuf[1024];
        char *tv_stype;
        char err_str[72];

        if ((tv_stype = getenv("TERM")) == NULL)
        {
                puts("Environment variable TERM not defined!");
                exit(1);
        }

        if((tgetent(tcbuf, tv_stype)) != 1)
        {
                sprintf(err_str, "Unknown terminal type %s!", tv_stype);
                puts(err_str);
                exit(1);
        }

        p = tcapbuf;
        t = tgetstr("pc", &p);
        if(t)
                PC = *t;

        CL = tgetstr("cl", &p);
        CM = tgetstr("cm", &p);
        CE = tgetstr("ce", &p);
        UP = tgetstr("up", &p);
	SE = tgetstr("se", &p);
	SO = tgetstr("so", &p);
	if (SO != NULL)
		revexist = TRUE;

        if(CL == NULL || CM == NULL || UP == NULL)
        {
                puts("Incomplete termcap entry\n");
                exit(1);
        }

	if (CE == NULL)		/* will we be able to use clear to EOL? */
		eolexist = FALSE;
		
        if (p >= &tcapbuf[TCAPSLEN])
        {
                puts("Terminal description too big!\n");
                exit(1);
        }
        ttopen();
}

tcapmove(row, col)
register int row, col;
{
        putpad(tgoto(CM, col, row));
}

tcapeeol()
{
        putpad(CE);
}

tcapeeop()
{
        putpad(CL);
}

tcaprev(state)		/* change reverse video status */

int state;	/* FALSE = normal video, TRUE = reverse video */

{
	if (state) {
		if (SO != NULL)
			putpad(SO);
	} else {
		if (SE != NULL)
			putpad(SE);
	}
}

tcapbeep()
{
        ttputc(BEL);
}

putpad(str)
char    *str;
{
        tputs(str, 1, ttputc);
}

putnpad(str, n)
char    *str;
{
        tputs(str, n, ttputc);
}

#else

hello()
{
}

#endif TERMCAP
