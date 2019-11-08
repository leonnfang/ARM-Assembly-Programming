.data

/* First message */
.balign 4
msg_1: .asciz "Please enter the name of the input file:"	

/* Second message */
.balign 4
msg_2: .asciz "Please enter the name of the output file:"	

/* Error message for invalid input file name */
.balign 4
msg_error: .asciz "Error!Input file name not found!\n"		

/* Error message for too many numbers */
.balign 4
msg_error_1: .asciz "Error! Too many numbers!\n"

/* Format pattern for scanf */
.balign 4
scan_pattern_1: .asciz "%s"					

/* Format pattern for fscanf */
.balign 4
scan_pattern_2: .asciz "%d"					

/* Format pattern for fprintf */
.balign 4
scan_pattern_3: .asciz "%d\n"					

/* Allocate 20 bytes for input file name */
.balign 4
in_file: .skip 20						

/* Read mode for fopen */
.balign 4
read_mode: .asciz "r"						

/* Allocate 20 bytes for output file name */
.balign 4
out_file: .skip 20						

/* Write mode for fopen */
.balign 4
write_mode: .asciz "w"						

/* Allocate 4 bytes for each number read */
.balign 4
num_read: .skip 4						

/* Allocate 400 bytes for an array of max 100 integers */
.balign 4
num_array: .skip 404						 

/* Return value */
.balign 4
return: .word 0							

.text

.global main

main:
	ldr r1, address_of_return				// r1<-&address_of_return 
	str lr, [r1]						// *r1<-lr

	ldr r0, address_of_msg_1				// r0<-&msg_1
	bl printf						// call to printf

	ldr r0, address_of_scan_pattern_1			// r0<-&scan_pattern_1
	ldr r1, address_of_in_file				// r1<-&in_file
	bl scanf						// call to scanf

	ldr r0, address_of_in_file				// r0<-&in_file
	ldr r1, address_of_read_mode				// r1<-&read_mode
	bl fopen						// call to fopen in read mode
	cmp r0,#0x00						// compare the output of fopen to null
	beq error						// if equal to null->input file name doesn't exit->exit with error msg
	mov r4, r0						// r4<-r0, store the file pointer in another register for future use

	ldr r0, address_of_msg_2				// r0<-&msg_2
	bl printf						// call to printf

	ldr r0, address_of_scan_pattern_1			// r0<-&scan_pattern_1
	ldr r1, address_of_out_file				// r1<-&out_file
	bl scanf						// call to scanf

	ldr r0, address_of_out_file				// r0<-&out_file
	ldr r1, address_of_write_mode				// r1<-&write_mode
	bl fopen						// call to fopen in write mode
	mov r5, r0						// r5<-r0, store the file pointer in another register for future use
	
	ldr r6, address_of_num_array				// r6<-&num_array
	mov r9, #0						// r9<-#0, keeps track of number of lines read and the ith element in the array

/* read section */
read:
	mov r0, r4						// r0<-r4
	ldr r1, address_of_scan_pattern_2			// r1<-&scan_pattern_2
	ldr r2, address_of_num_read				// r2<-&num_read
	bl fscanf						// call to fscanf
	cmp r0,#1						// compare the return value(number of items successfully scanned) of fscanf with #1
	bne next						// if not equal to 1, end of line reached, exit read loop
	
	ldr r0, address_of_num_read				// load the address of number read
	ldr r1,[r0] 						// load the value of number into r1
	lsl r9,r9,#2						// r9*4,offset bytes to get the element in the array 
	str r1,[r6,r9]						// store the value of number read into the ith element of the array 
	lsr r9,r9,#2						// divide r9 by 4 to obtain original value of r9
	add r9,r9,#1						// increment r9 by 1 
	cmp r9, #101						// compare the value of counter with number 100
	beq error_1						// if the number of elements exceeds 100, the program will branch to error
	b read							// branch to read

next:
	mov r0,#0						// set iterator i(r0) to 0

/* sort section */
sort_1:
	mov r2,#0						// set flag(r2) to 0, for checking if any swaps occurred
	sub r3,r9,#1						// r3 = # of elements-1
	cmp r0,r3						// compare i(r0) with n-1(r3)
	bge write						// if i>=n-1, sorting loop ends and branch to loop
	mov r1,#0						// set iterator j(r1) to 0
	sub r3,r3,r0						// r3 = n-j-1

sort_2:
	cmp r1,r3						// comapare j(r1) with n-j-1(r3)
	bge check_flag						// if j>=n-j-1, branch to check flag
	mov r7,r1						// r7=j(r1)
	lsl r7,r7,#2						// j(r7)*4, offset bytes to get the address of jth element in the array
	ldr r8,[r6,r7]						// r8 = the value of jth element into r8
	add r10,r7,#4						// r10 = address of (j+1)th element
	ldr r11,[r6,r10]					// r11 = the value of (j+1)th element
	cmp r8,r11						// compare jth element(r8) with (j+1)th element(r11)
	bgt swap						// if r8>r11, branch to swap
	add r1,r1,#1						// increment j(r1) by 1
	b sort_2						// branch back to sort_2 loop
  
swap:
	str r8,[r6,r10]						// store jth element into position j+1 in the array
	str r11,[r6,r7]						// store (j+1)th element into position j in the array
	add r1,r1,#1						// j(r1) = j+1
	add r2,r2,#1						// increment flag(r2) by 1
	b sort_2						// branch back to sort_2 loop

check_flag:
	cmp r2,#0						// compare flag(r2) with 0
	beq write						// if equal to 0, no swaps occurred so array is sorted, branch to write
	add r0,r0,#1						// i(r0) = i+1
	b sort_1						// branch back to sort_1 loop

/* write section */
write:
	mov r8,#0						// iterator(r8) = 0 
write_loop:
	cmp r8,r9						// compare r8 with # of elements in sorted array (r9)
	bge close_file						// if r8>=r9, all elements in sorted array has been written, branch to close file
	lsl r8,r8,#2						// r8=r8*4, offset bytes to get the address of ith element

	mov r0,r5						// r0=output file pointer(r5)
	ldr r1,address_of_scan_pattern_3			// r1<-&scan_pattern_3
	ldr r2,[r6,r8]						// r2 = ith element in sorted array
	bl fprintf						// call to fprintf

	lsr r8,r8,#2						// r8=r8/4, obtain original value of r8
	add r8,r8,#1						// r8=r8+1
	b write_loop						// branch back to write loop

/* close file section */
close_file:
	mov r0, r4						// r0=input file pointer(r4)
	bl fclose						// call to fclose

	mov r0, r5						// r0=output file pointer(r5)
	bl fclose						// call to fclose

	ldr lr, address_of_return				// lr<-&return
	ldr lr, [lr]						// lr<-*lr
	bx lr

/* error branch */
error:
	ldr r0,address_of_msg_error				// r0<-&msg_error
	bl printf						// call to printf

	ldr lr,address_of_return				// lr<-&return
	ldr lr,[lr]						// lr<-*lr
	bx lr

error_1:
	ldr r0,address_of_msg_error_1				// r0<-&msg_error_1
	bl printf						// call to printf

	ldr lr,address_of_return				// lr<-&return
	ldr lr,[lr]						// lr<- *lr
	bx lr

/* Addresses */
address_of_msg_1: .word msg_1
address_of_msg_2: .word msg_2
address_of_msg_error_1: .word msg_error_1
address_of_msg_error: .word msg_error
address_of_scan_pattern_1: .word scan_pattern_1
address_of_scan_pattern_2: .word scan_pattern_2
address_of_scan_pattern_3: .word scan_pattern_3
address_of_in_file: .word in_file
address_of_out_file: .word out_file
address_of_num_read: .word num_read
address_of_read_mode: .word read_mode
address_of_write_mode: .word write_mode
address_of_num_array: .word num_array
address_of_return: .word return

/* External */
.global printf
.global scanf
.global fopen
.global fclose
.global fputs
.global fscanf
.global fprintf
