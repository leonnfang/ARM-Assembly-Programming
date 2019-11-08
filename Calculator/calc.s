.data

.balign 4
null: .asciz "\0"

.balign 4
msg: .asciz "%lf\n"

.balign 4
string_r: .skip 400

.balign 4
op_stack: .skip 20

.balign 4
char_read: .skip 12

.balign 4
num_read: .skip 12

.balign 4
val_count: .word 0

.balign 4
op_count: .word 0

.balign 4
fpattern: .asciz "%f"

.balign 4
return: .word 0

.text
.global main

main:
	ldr r2, addr_return	// load the address of the return value
	str lr, [r2]		// deref

	ldr r2, [r1, #4]	// load the second element in the command line
	ldr r0, addr_string_r	// load the add of the string

store:
	ldrb r3, [r2], #1	// r2 <- [r2]
	cmp r3, #0x00		// compare with null
	beq next		// branch to "next" section
	strb r3, [r0], #1	// store the user input into r0
	b store			// branch to "store" section
	
next:
	ldr r9, addr_string_r
	
start:
	mov r5, #0		// set counter = 0 of number char	
	ldr r1, addr_char_read	// set r1 as the array of temporary number-char array

read:	
	ldrb r4, [r9], #1	// load the user input byte by byte
	cmp r4, #0x00		// compare r4 with null
	beq convert		// if r4 is null, end the loop 
	cmp r4, #46		// compare r4 with "."
	beq strnum		// branch to store the char to num-char array
	cmp r4, #42		// compare r4 with "*"
	beq convert		// branch to convert the num-char to number and store it to stack
	cmp r4, #47		// compare r4 with "/"
	beq convert		// branch to convert the num-char to number and store it to stack
	cmp r4, #43		// compare r4 with "+"
	beq convert		// branch to convert the num-char to number and store it to stack
	cmp r4, #45		// compare r4 with "-"
	beq convert		// branch to convert the num-char to number and store it to stack
	cmp r4, #40		// compare r4 with "("
	beq pushop		// branch to push operator onto op
	cmp r4, #41		// compare r4 with ")"
	beq convert		// branch to convert the num-char to number and store it to stack

strnum:
	strb r4, [r1], #1	// store the num-char read into num-char array
	add r5, r5, #1		// increment # of char
	b read			// branch back to read

// convert the number read to a float
convert:
	cmp r5, #0
	beq two_op_check

	ldr r0, addr_char_read 	// load the address of num-char array
	ldr r1, addr_fpattern	// load the address of float pattern
	ldr r2, addr_num_read	// load the address of num-read
	bl sscanf		// call sscanf to convert to float

	ldr r1, addr_val_count	// load the address of counter
	ldr r0, [r1]		// deref
	cmp r0, #0		// check the value of the counter
	beq str0		// branch to the right section to store value read
	cmp r0, #1
	beq str1
	cmp r0, #2
	beq str2
	cmp r0, #3
	beq str3
	cmp r0, #4
	beq str4

str0:
	ldr r2, addr_num_read	// load the address of num-read
	vldr s10, [r2]		// load to the right register
	add r0,r0,#1		// increment the counter
	str r0,[r1]
	b clear
str1:
	ldr r2, addr_num_read	// load the address of num-read
	vldr s11, [r2]		// load to the right register
	add r0,r0,#1		// increment the counter
	str r0,[r1]
	b clear
str2:
	ldr r2, addr_num_read	// load the address of num-read
	vldr s12, [r2]		// load to the right register
	add r0,r0,#1		// increment the counter
	str r0,[r1]
	b clear
str3:
	ldr r2, addr_num_read	// load the address of num-read
	vldr s13, [r2]		// load to the right register
	add r0,r0,#1		// increment the counter
	str r0,[r1]
	b clear
str4:
	ldr r2, addr_num_read	// load the address of num-read
	vldr s14, [r2]		// load to the right register
	add r0,r0,#1		// increment the counter
	str r0,[r1]
	b clear

clear:
	ldr r0, addr_char_read	// load the address of num-char array
	mov r1, #0x00		// r1 = null

// loop to clear the char-array for future use
clearloop:
	cmp r5, #0		// compare r5 with 0
	beq compare		// branch to find the type of the operation
	strb r1, [r0], #1	// store null byte by byte
	sub r5, r5, #1		// decrement the counter by 1
	b clearloop		// branch back to clear

// check current character and branch to correct operation
compare:
	cmp r4, #42		// compare r4(current char) with "*"
	beq mulcheck		// branch to mul
	cmp r4, #47		// compare r4(current char) with "/"
	beq divcheck		// branch to divide
	cmp r4, #43		// compare r4(current char) with "+"
	beq addcheck		// branch to addition
	cmp r4, #45		// compare r4(current char) with "-"
	beq subcheck		// branch to sub
	cmp r4, #41		// compare r4(current char) with ")"
	beq right		// branch to right
	cmp r4, #0x00		// compare with null
	beq stackcheck		// branch to stackcheck

// compare current operator with the operator on top of the stack, perform op on top of stack if same or greater precidence
mulcheck:
	ldr r0, addr_op_count	// load the add of op-counter
	ldr r0, [r0]		// deref
	cmp r0, #0		// compare with 0
	beq pushop		
	sub r0, r0, #1		// decrement the counter
	lsl r0, r0, #2		
	ldr r1, addr_op_stack
	ldr r2, [r1, r0]	// load the op at top of stack
	cmp r2, #42		// compare with "*"
	beq multiply
	cmp r2, #47		// compare with "/"
	beq divide
	b pushop	

// compare current operator with the operator on top of the stack, perform op on top of stack if same or greater precidence
divcheck:
	ldr r0, addr_op_count	// load the add of op-counter
	ldr r0, [r0]		// deref
	cmp r0, #0		// compare with 0
	beq pushop
	sub r0, r0, #1		// decrement the counter
	lsl r0, r0, #2
	ldr r1, addr_op_stack
	ldr r2, [r1, r0]	// load the op at top of stack
	cmp r2, #42		// compare with "*"
	beq multiply
	cmp r2, #47		// compare with "/"
	beq divide		
	b pushop	

// compare current operator with the operator on top of the stack, perform op on top of stack if same or greater precidence
addcheck:
	ldr r0, addr_op_count	// load the add of op-counter
	ldr r0, [r0]
	cmp r0, #0		// compare with 0
	beq pushop
	sub r0, r0, #1		// decrement the counter
	lsl r0, r0, #2
	ldr r1, addr_op_stack
	ldr r2, [r1, r0]	// load the op at top of stack
	cmp r2, #42		// compare with "*"
	beq multiply
	cmp r2, #47		// compare with "/"
	beq divide
	cmp r2, #43
	beq addition		// compare with "+"
	cmp r2, #45
	beq subtract		// compare with "-"
	b pushop	

// compare current operator with the operator on top of the stack, perform op on top of stack if same or greater precidence 	
subcheck:
	ldr r0, addr_op_count	// load the add of op-counter
	ldr r0, [r0]
	cmp r0, #0		// compare with 0
	beq pushop
	sub r0, r0, #1		// decrement the counter
	lsl r0, r0, #2
	ldr r1, addr_op_stack
	ldr r2, [r1, r0]	// load the op at top of stack
	cmp r2, #42		// compare with "*"
	beq multiply
	cmp r2, #47		// compare with "/"
	beq divide
	cmp r2, #43		// compare with "+"
	beq addition
	cmp r2, #45		// compare with "-"
	beq subtract
	b pushop

// if right parenthesis is read, perform all operations on the op stack until left parenthesis is reached
right:
	ldr r0, addr_op_stack	// load the add of op-stack 
	ldr r1, addr_op_count	// load the add of op-counter
	ldr r1, [r1]
	sub r1, r1, #1		// decrement the counter
	lsl r1, r1, #2
	ldr r2, [r0, r1]	// load the op at top of stack
	cmp r2, #40		// compare with "("
	beq popleftpar		
	cmp r2, #42		// compare with "*"
	beq multiply			
	cmp r2, #47	
	beq divide		// compare with "/"	
	cmp r2, #43		
	beq addition		// compare with "+"
	cmp r2, #45	
	beq subtract		// compare with "-"

stackcheck:
	ldr r0, addr_op_count	// load the add of op-count
	ldr r0, [r0]		
	cmp r0, #0		// compare with 0
	beq getresult		// branch to get results
	ldr r1, addr_op_stack
	sub r0, r0, #1		// decrement the counter
	lsl r0, r0, #2
	ldr r2, [r1, r0]	// load the op at top of stack
	cmp r2, #42		// compare with "*"
	beq multiply
	cmp r2, #47		// compare with "/"
	beq divide
	cmp r2, #43		// compare with "+"
	beq addition
	cmp r2, #45		// compare with "-"
	beq subtract

// corner-case check: when two operators in a row. for example (5)+1
two_op_check:
	cmp r4, #0x00
	beq stackcheck	
	cmp r4, #42		
	beq mulcheck		
	cmp r4, #47		
	beq divcheck		
	cmp r4, #43		
	beq addcheck		
	cmp r4, #45		
	beq subcheck		

// check how many elements in the val-array and find the right register
multiply:
	ldr r1, addr_val_count
	ldr r2, [r1]
	cmp r2, #2
	beq mul1
	cmp r2, #3
	beq mul2
	cmp r2, #4
	beq mul3
	cmp r2, #5	
	beq mul4

// mul1-mul4: implement the mul operation
mul1:
	vmul.f32 s10, s10, s11
	b decre_count

mul2:
	vmul.f32 s11, s11, s12
	b decre_count

mul3:
	vmul.f32 s12, s12, s13
	b decre_count

mul4:
	vmul.f32 s13, s13, s14
	b decre_count	

// check how many elements in the val-array and find the right register
divide:
	ldr r1, addr_val_count
	ldr r2, [r1]
	cmp r2, #2
	beq div1
	cmp r2, #3
	beq div2
	cmp r2, #4
	beq div3
	cmp r2, #5	
	beq div4

// div1-div4: implement the divsion operation
div1:
	vdiv.f32 s10, s10, s11	
	b decre_count

div2:
	vdiv.f32 s11, s11, s12
	b decre_count

div3:
	vdiv.f32 s12, s12, s13
	b decre_count

div4:
	vdiv.f32 s13, s13, s14
	b decre_count

// check how many elements in the val-array and find the right register
addition:
	ldr r1, addr_val_count
	ldr r2, [r1]
	cmp r2, #2
	beq add1
	cmp r2, #3
	beq add2
	cmp r2, #4
	beq add3
	cmp r2, #5	
	beq add4

// add1-add4: implement the addition operation
add1:
	vadd.f32 s10, s10, s11
	b decre_count

add2:
	vadd.f32 s11, s11, s12
	b decre_count

add3:
	vadd.f32 s12, s12, s13
	b decre_count

add4:
	vadd.f32 s13, s13, s14
	b decre_count
	
// check how many elements in the val-array and find the right register
subtract:
	ldr r1, addr_val_count
	ldr r2, [r1]
	cmp r2, #2
	beq sub1
	cmp r2, #3
	beq sub2
	cmp r2, #4
	beq sub3
	cmp r2, #5	
	beq sub4

// sub1-sub4: implement the subtraction operation
sub1:				
	vsub.f32 s10, s10, s11
	b decre_count

sub2:
	vsub.f32 s11, s11, s12
	b decre_count

sub3:
	vsub.f32 s12, s12, s13
	b decre_count

sub4:
	vsub.f32 s13, s13, s14
	b decre_count	

// pop the left parenthesis
popleftpar:
	ldr r0, addr_op_count
	ldr r1, [r0]
	sub r1, r1, #1		// decrement the counter by 1
	str r1, [r0]
	b start

// push an operator
pushop:
	ldr r0, addr_op_stack
	ldr r1, addr_op_count
	ldr r2, [r1]
	lsl r2, r2, #2
	str r4, [r0, r2]
	lsr r2, r2, #2
	add r2, r2, #1
	str r2, [r1]
	b start

decre_count:
	ldr r0, addr_op_count
	ldr r1, [r0]
	sub r1, r1, #1		// decrement the op_counter by 1
	str r1, [r0]
	ldr r0, addr_val_count
	ldr r1, [r0]
	sub r1, r1, #1		// decrement the val_counter by 1
	str r1, [r0]
	cmp r4, #42		// compare with "*"
	beq mulcheck
	cmp r4, #47		// compare with "/"
	beq divcheck
	cmp r4, #43		// compare with "+"
 	beq addcheck
	cmp r4, #45		// compare with "-"
	beq subcheck
	cmp r4, #41		// compare with ")"
	beq right
	cmp r4, #0x00		// compare with null
	beq stackcheck	


getresult:
	fcvtds d0, s10		// convert the float to the double
	vmov r2, r3, d0		// convert the double to two registers
	ldr r0, addr_msg	// load the address of the message
	bl printf		// call the function
	
end:
	ldr r2, addr_return
	ldr lr, [r2]
	bx lr

addr_msg: .word msg
addr_null: .word null
addr_string_r: .word string_r
addr_op_stack: .word op_stack
addr_char_read: .word char_read
addr_num_read: .word num_read
addr_val_count: .word val_count
addr_op_count: .word op_count
addr_fpattern: .word fpattern
addr_return: .word return

.global printf
.global sscanf
