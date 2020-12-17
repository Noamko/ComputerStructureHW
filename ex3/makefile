a.out: main.o run_main.o func_select.o pstring.o
	gcc -g -no-pie  -o a.out main.o run_main.o func_select.o pstring.o

main.o: main.c pstring.h
	gcc -g -no-pie  -c -o main.o main.c

run_main.o: run_main.s pstring.h
	gcc -g -no-pie  -c -o run_main.o run_main.s

func_select.o: func_select.s pstring.h
	gcc -g -no-pie  -c -o func_select.o func_select.s

pstring.o: pstring.s
	gcc -g -no-pie  -c -o pstring.o pstring.s	

clean:
	rm -f *.o a.out
