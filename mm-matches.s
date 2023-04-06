@ Used the CPUlator to run and debug your code: https://cpulator.01xz.net/?sys=arm-de1soc&d_audio=48000
@ Note, that the CPUlator simulates a DE1-SoC device, and here you should use the HEX displays to show the numbers
@ See the Tutorials on LED, Button, and HEX displays in the F28HS course (Weeks 8 and 9)

@ This ARM Assembler code should implement a matching function, for use in MasterMind program, as
@ described in the CW3 specification. It should produce as output 2 numbers, the first for the
@ exact matches (peg of right colour and in right position) and approximate matches (peg of right
@ color but not in right position). Make sure to count each peg just once!
	
@ Example (first sequence is secret, second sequence is guess):
@ 1 2 1
@ 3 1 3 ==> 0 1
@ Display the result as two digits on the two rightmost HEX displays, from left to right
@

@ -----------------------------------------------------------------------------

.text
.global         _start
_start: 
	LDR  R2, =secret	@ pointer to secret sequence
	LDR  R3, =guess		@ pointer to guess sequence

	@ you probably need to initialise more values here
	LDR R6, =LEN 		@ constant length of the sequence
	
	@ R0 - number of exact matches
	@ R1 - number of approximate matches
    @ R2 - pointer to secret sequence
    @ R3 - pointer to guess sequence
    @ R4 - address of the next word of the secret sequence
    @ R5 - address of the next word of the guess sequence

	@ ... COMPLETE THE CODING BY ADDING YOUR CODE HERE, you may want to use sub-routines to structure your code
		
match:
	@ load the address of the next word of the secret into R4
    LDR R4,[R2]
	@ load the address of the next word of the guess into R5
	LDR R5,[R3]
	@ subroutine for exact matches
	BL exactm
	@ move to the next word address
	ADD R2, #4
	@ move to the next word address
	ADD R3, #4
	SUB R6, #1 @ decrement counter
	CMP R6, #0 @move to the next part when done
	BEQ done
	B match @ loop
	
exactm:
	PUSH {LR} @ save address to return to
	@ compare for exact matches
	CMP R4, R5
	BLEQ increxact @ to increment exact matches counter
	POP {LR}
	B endp @ return

@ to increment exact matches counter
increxact:
	ADD R0, #1
	BX LR @ return
	
@To return to LR instruction
endp:
    BX LR

done:
	MOV R8, #3 @ counter for loop
	MOV R6, #89 @ 2 digit decimal to mark a match between guess and sequence
	MOV R11, #88 @ 2 digit decimal to mark a match between guess and sequence
	
	LDR  R2, =secret	@ reset pointer to secret sequence
	LDR  R3, =guess		@ reset pointer to guess sequence
	B approxm @ branch to count approximate matches part of the program
	
approxm:
	CMP R8, #0 @ move to next iteration when done
	BEQ next1
	@ load the address of the next word of the secret into R4
    LDR R4,[R2]
	@ load the address of the next word of the guess into R5
	LDR R5,[R3]
	CMP R4, R5 @ to increment approximate matches counter
	BLEQ incrapprox
	SUB R8, #1 @ decrement counter
	@ move to the next word address
	ADD R3, #4
	B approxm @ loop
	
next1:
	LDR  R2, =secret	@ reset pointer to secret sequence
	LDR  R3, =guess		@ reset pointer to guess sequence
	MOV R8, #3 			@ reset counter
	@ move to the next word address
	ADD R2, #4
		
loop1: 
	CMP R8, #0 @ move to the next iteration when done
	BEQ next2
	@ load the address of the next word of the secret into R4
    LDR R4,[R2]
	@ load the address of the next word of the guess into R5
	LDR R5,[R3]
	CMP R4, R5 @ to increment approximate matches counter
	BLEQ incrapprox
	SUB R8, #1 @ decrement counter
	@ move to the next word address
	ADD R3, #4
	B loop1 @ loop

next2:
	LDR  R3, =guess		@ reset pointer to guess sequence
	MOV R8, #3 			@ reset counter
	@ move to the next word address
	ADD R2, #4

loop2:
	CMP R8, #0 @ move to the next part when done
	BEQ returnm
	@ load the address of the next word of the secret into R4
    LDR R4,[R2]
	@ load the address of the next word of the guess into R5
	LDR R5,[R3]
	CMP R4, R5 @ to increment approximate matches counter
	BLEQ incrapprox
	SUB R8, #1 @ decrement counter
	@ move to the next word address
	ADD R3, #4
	B loop2 @ loop

@ to increment approximate matches counter
incrapprox:
	ADD R1, #1 @ increment
	STR R11, [R2] @ markdown match in memory to avoid repeat matches
	STR R6, [R3]  @ markdown match in memory to avoid repeat matches
	BX LR @ return

returnm:
	@ subtract exact matches from approximate matches to avoid counting the same matches twice
	SUB R1, R0 
	@ branch to show matches
	B showm 

@ to display exact and approximate matches on the hex display
showm:
	LDR R2, =HEXBASE @ physical address of the HEX
	LDR R3, =digits @ pointer to digits table for hex display
	ADD R3, R0 @ to get the digit in register zero
	LDRB R4, [R3] @ get the bitmask stored at the memory location in r3
	MOV R5, R4, LSL #8 @ display exact matches
	
	LDR R3, =digits @ reset pointer to digits for hex display
	ADD R3, R1 @ to get the digit in register one
	LDRB R4, [R3] @ get the bitmask stored at the memory location in r3
	ORR R5, R4, LSL #0 @ display approximate matches
	STRH R5, [R2] @ display on the hex display

exit:	@MOV	 R0, R4		@ load result to output register
	MOV 	 R7, #1		@ load system call code
	SWI 	 0		@ return this value
	
@ =============================================================================

.data

@ constants about the basic setup of the game: length of sequence and number of colors	
.equ LEN, 3
.equ COL, 3
.equ NAN1, 8
.equ NAN2, 9

@ constants needed to interface with external devices	
.equ BUTTONBASE, 0xFF200050
.equ HEXBASE,	 0xFF200020
.equ BUTTON_NO,  1	

@ you probably want to define a table here, encoding the display of digits on the HEX display	
.align 1	
digits:
	.byte  0b0111111	@ 0
	.byte  0b0000110	@ 1
	.byte  0b1011011	@ 2
	.byte  0b1001111	@ 3
	.byte  0b1100110	@ 4
	.byte  0b1101101	@ 5
	.byte  0b1111101	@ 6
	.byte  0b0000111	@ 7
	.byte  0b1111111	@ 8
	.byte  0b1100111	@ 9
	
@	... COMPLETE THIS TABLE  ...	          	

@ INPUT DATA for the matching function
.align 4
secret: .word 1 
	.word 2
	.word 1

.align 4
guess:	.word 3
	.word 1
	.word 3 

@ Not strictly necessary, but can be used to test the result	
@ Expect Answer: 0 1
.align 4
expect: .byte 0
	.byte 1

.align 4
secret1: .word 1 
	.word 2 
	.word 3 

.align 4
guess1:	.word 1 
	.word 1 
	.word 2 

@ Not strictly necessary, but can be used to test the result	
@ Expect Answer: 1 1
.align 4
expect1: .byte 1
	.byte 1

.align 4
secret2: .word 2 
	.word 3
	.word 2 

.align 4
guess2:	.word 3 
	.word 3 
	.word 1 

@ Not strictly necessary, but can be used to test the result	
@ Expect Answer: 1 0
.align 4
expect2: .byte 1
	.byte 0
