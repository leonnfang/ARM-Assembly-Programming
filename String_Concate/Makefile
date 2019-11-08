all: concat

concat: concat.o
	gcc -o concat concat.o

concat.o: concat.s
	as -o concat.o concat.s
	
clean:
	rm -vf concat concat.o
