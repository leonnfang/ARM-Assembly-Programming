.text
.global main

main:
	mov r1, #123			/* r1 <- #123 */
	mov r2, #0			/* r2 <- #0 */

loop:
	cmp r1, #1			/* compare r1 with #1 */
	beq end				/* branch to end if equal */
	mov r3, r1			/* r3 <- r1 */
	b mod				/* branch to mod */

mod: 
	cmp r3, #0			/* compare r3 with #0 */
	beq even			/* branch to even if equal */
	cmp r3, #1			/* compare r3 with #1 */
	beq odd				/* branch to odd if equal */
	sub r3, r3, #2			/* r3 <- r3-2 */
	b mod				/* back to mod to check */
	
even:
	add r2, r2, #1			/* increment the counter */
	mov r1, r1, lsr #1		/* r1 <- r1/2 */
	b loop				/* branch back to loop */
		
odd:	
	add r2, r2, #1			/* increment the counter */
	mov r4, r1			/* r4 <- r1 */
	mov r4, r4, lsl #1		/* r4 <- r4 times 2 */
	add r1, r4, r1			/* r1 <- r4+r1 */
	b loop				/* branch back to loop */
	
end:
	mov r0, r2			/* r0 <- r2 */
	bx lr