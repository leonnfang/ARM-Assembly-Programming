# ARM-Assembly-calculator
a calculator was implemented in ARM assembly

To run the program:

1. Type command ìmake cleanî in the terminal. **This command will clean all previous executables**.

2. Type ìmakeî in the terminal. **this command will create a .s file and compile it**.

3. Type ì./calc <operations>î, where <operation> = <operand> <arithmetic operation> <operand> , ... **this command will run the file**. 

IMPORTANT: The number of operations should not exceed 4. The correct operation input could be addition (+), subtraction (-), multiplication (*), and division (/). The input can also contain parentheses. Since parenthesis has other uses in the terminal, the user will need to type ì \ î before any parenthesis. For example: 5*\(1+1\).

4. The program will show the final answer in the terminal.

Extra functionality: 
The original requirements stated that the input can have at most four operation. However, this program can take an large amount of operations as long as not too many parentheses are used within another. 
