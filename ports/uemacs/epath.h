/*	PATH:	This file contains certain info needed to locate the
		MicroEMACS files on a system dependant basis.

									*/

/*	possible names and paths of help files under different OSs	*/

char *pathname[] = {

#if	CPM
	"emacs.rc",
	"emacs.hlp",
	"",
	"0:",
	"a:",
	"0a:"
#endif

#if	AMIGA
	".emacsrc",
	"emacs.hlp",
	"",
	":c/",
	":t/"
#endif

#if	MSDOS
	"emacs.rc",
	"emacs.hlp",
	"\\sys\\public\\",
	"\\usr\\bin\\",
	"\\bin\\",
	"\\",
	""
#endif

#if	V7
	".emacsrc",
	"emacs.hlp",
	"/usr/local/",
	"/usr/lib/",
	""
#endif

#if	VMS
	"emacs.rc",
	"emacs.hlp",
	"",
	"sys$sysdevice:[vmstools]"
#endif

};

#define	NPNAMES	(sizeof(pathname)/sizeof(char *))
                                                                                                              