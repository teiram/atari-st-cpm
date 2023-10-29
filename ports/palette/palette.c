#include <stdio.h>

extern int setcolor();

main(argc, argv)
int argc;
char *argv[];
{
	int color;
	int value;
	if (argc < 3) {
		printf("Usage: palette color value\n");
		exit(255);
	}
	sscanf(argv[1], "%d", &color);
	sscanf(argv[2], "%x", &value);
	setcolor(color, value);
}
