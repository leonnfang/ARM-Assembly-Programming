all: sort

sort: sort.o
	gcc -o sort sort.o
sort.o: sort.s
	as -o sort.o sort.s
clean:
	rm -vf sort sort.o
