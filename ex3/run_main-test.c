#include <stdio.h>
#include "pstring.h"
extern int run_func();
void run_main() {

	Pstring p1 = {6, "97AAAB"};
	Pstring p2 = {6, "A1B2C3"};
	int len;
	int opt = 52;
	// initialize first pstring
	// scanf("%d", &len);
	// scanf("%s", p1.str);
	// p1.len = len;

	// // initialize second pstring
	// scanf("%d", &len);
	// scanf("%s", p2.str);
	// p2.len = len;

	// // select which function to run
	// scanf("%d", &opt);
	run_func(opt, &p1, &p2);
}
