.text
.global main

main:
	mov r1, #0 /* set the initial value */
	mov r2, #1 /*set the initial value */
	mov r3, #0 /*r3 used as a counter to count the number of iterations */

loop:	add r1, r1, r2  /* add two values together */
	mov r0, r1 /* move the value of r1 to r0*/
	add r3, r3, #1 /* increment the counter by 1*/
	cmp r3, #9 /* check how many times have been added */
	beq end
	b cont

cont:	add r2, r1, r2 /* adding two values */
	mov r0, r2
	add r3, r3, #1 /* increment the counter */
	cmp r3, #9 /* check conditions */
	beq end /* branch */
	b loop /* branch */

end:
	bx lr
