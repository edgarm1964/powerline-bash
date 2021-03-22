#include <stdio.h>

int main (int argc, char **argv)
{
	char p[32];

	p[0] = 'k';
	p[1] = '8';
	p[2] = 'w';
	p[3] = 'c';
	p[4] = 'u';
	p[5] = '1';
	p[6] = 'v';
	p[7] = 'r';
	p[8] = 'i';
	p[9] = 'q';
	p[10] = '~';
	p[11] = 'S';
	p[12] = '%';
	p[13] = '\0';

	printf ("%s\n", p);
	return (0);
}
