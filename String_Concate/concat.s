.data

.balign 4
msg1: .asciz "Pls enter the first string(less then 10 char):"	 /*precallocate first prompt */

.balign 4
msg2: .asciz "Pls enter the second string(less than 10 char):"	 /*precallocate second prompt*/

.balign 4
scan_pattern: .asciz "%s"			/*preallocate input pattern*/

.balign 4
string_read1: .skip 11				/*preallocate first user input*/

.balign 4
string_read2: .skip 11				/*preallocate second user input*/

.balign 4
result: .skip 21				/*preallocate final result array*/

.balign 4
error_1: .asciz "Error 21\n"			/*preallocate error code 1*/

.balign 4
error_2: .asciz "Error 22\n"			/*preallocate error code 2*/

.balign 4
return: .word 0 				/*preallocate return value*/

.text

.global main

main:
	ldr r1, address_of_return		/* r1 <- &address_of_return*/		
	str lr, [r1]				/* *r1 <- lr */

	ldr r0, address_of_msg1			/* r0 <- &msg1 */
	bl printf				/* call to printf */

	ldr r0, address_of_scan_pattern		/* r0 <- &scan_pattern */
	ldr r1, address_of_string_read1		/* r1 <- &string_read1 */
	bl scanf				/* call to scanf */

	ldr r0, address_of_string_read1		/* r0 <- &string_read1 */
	mov r1, #0				/* r1 <- #0 */

check1:	ldrb r2, [r0], #1			/* load one byte from r0 to r2 and increment the address by 1   */
	cmp r2, #0x00				/* check if the loop has reached the end of input string by comparing the current byte to null */
	beq next1				/* branch to next1 if equal */
	add r1, r1, #1				/* r1 <- r1+1 */
	b check1				/* loop back to check1 */

next1:	cmp r1, #10				/* compare the length of string to 10 */
	bgt error1				/* if greater than 10, branch to error1 */

	ldr r0, address_of_msg2			/* r0 <- &msg2 */
	bl printf				/* call to printf */

	ldr r0, address_of_scan_pattern		/* r0 <- &scan_pattern */
	ldr r1, address_of_string_read2		/* r1 <- &string_read2 */
	bl scanf				/* call to scanf */

	ldr r0, address_of_string_read2		/* r0 <- &string_read2 */
	mov r1, #0				/* r1 <- #0 */

check2:	ldrb r2, [r0], #1			/* load one byte from r0 to r2 and increment the address by 1 */
	cmp r2, #0x00				/* check if the loop has reached the end of input stirng by comparing the current byte to null */
	beq next2				/* branch to next2 if equal */
	add r1, r1, #1				/* r1 <- r1+1 */
	b check2				/* loop back to check2 */

next2:	cmp r1, #10				/* compare the length of the string to 10 */
	bgt error2 				/* if greater than 10, branch to error3 */
	
	ldr r0, address_of_string_read1		/* r0 <- &string_read1 */
	ldr r1, address_of_string_read2		/* r1 <- &string_read2 */
	ldr r3, address_of_result		/* r3 <- &result */
	
loop1:	ldrb r4, [r0], #1			/* load one byte from r0 to r4 and increment the address by 1 */
	cmp r4, #0x00				/* check if the loop has reached the end input string by comparing the current byte to null */
	beq loop2				/* branch to loop2 if equal */
	strb r4, [r3], #1			/* store the byte in r4 to r3 and increment the address by 1 */
	b loop1					/* branch back to loop1 */

	/* this loop does the exact same thing as loop1 */
loop2:	ldrb r4, [r1], #1			
	cmp r4, #0x00
	beq end
	strb r4, [r3], #1
	b loop2

end:	mov r4, #0x00				/* r4 <- null */
	strb r4, [r3]				/* put null to end of r3 */

	ldr r0, address_of_result		/* r0 <- &result */
	bl puts					/* call to puts */
	
	ldr lr, address_of_return		/* lr <- &return */
	ldr lr, [lr]				/* lr <- *lr */
	bx lr					/* return from main using lr */

error1:	ldr r0, address_of_error_1		/* r0 <- &error_1 */
	bl printf				/* call to printf */
	
	ldr lr, address_of_return	
	ldr lr, [lr]
	bx lr

error2:	ldr r0,address_of_error_2		/*r0 <- &error_2*/
	bl printf				/*call to printf*/

	ldr lr, address_of_return
	ldr lr, [lr]
	bx lr	

address_of_msg1: .word msg1
address_of_msg2: .word msg2
address_of_scan_pattern: .word scan_pattern
address_of_string_read1: .word string_read1
address_of_string_read2: .word string_read2
address_of_return: .word return
address_of_result: .word result
address_of_error_1: .word error_1
address_of_error_2: .word error_2

/* External */
.global printf
.global scanf
.global puts
