TITLE Program Assignment2     (assignment2.asm)

; Author: Michael Payne
; Last Modified: 07/21/2019
; OSU email address: paynemi
; Course number/section: cs271
; Project Number: Homework 2           Due Date: 07/21/2019
; Description:  This program prints 1 to 46 fibonacci terms.  It first displays the title of the program and then my name.  It then
; gets a number from 1 to 46 (after explaining that it will print fibonacci terms) from the user.  If the user doesn't enter a number in
; that range, it prompts the user again until they follow the instructions.  The program then calculates ands prints out 5 fibonacci terms per line
; and it aligns the terms so that they are in uniform columns (the process on how this is done is explained later on in the program).  After
; it prints out the fibonacci terms, it says goodbye to the user.

INCLUDE Irvine32.inc
UPPER_LIMIT= 46					; Maximum  number of fibonacci terms that can be printed
LOWER_LIMIT= 1					; minimum number of fibo terms that can be printed



.data
space			BYTE	" ", 0
fiveSpace		BYTE	"     ",0
intro_1			BYTE	"Fibonacci Numbers", 0
intro_2			BYTE	"Programmed by Michael Payne", 0
question_1		BYTE	"What is your name: ", 0
userName		BYTE	33 DUP(0)		
hello			BYTE	"Hello, ",0
goodbye			BYTE	"Goodbye, ",0
period			BYTE	". ",0
instructions_1	BYTE	"Type in how many Fibonacci numbers you want displayed.", 0
instructions_2	BYTE	"Enter an integer greater than or equal to 1 and less than or equal to 46.", 0
instructions_3	BYTE	"How many Fibonacci numbers do you want: ", 0
count			DWORD	1		; this is used to keep track of the fibo terms displayed.  
userNum			DWORD	?		; once the user inputs the number of fibo terms he/she wants displayed, the result is stored in userNum
spacingNum		DWORD	?		; userNum is used to determine how many rows of fibo numbers will be displayed. the result is stored in spacingNum

.code
main PROC

; segment 1 - introduce program - This segment introduces the program by listing the program title and my name
	mov			edx, offset intro_1			; printing title of program (fibonacci numbers)
	call		WriteString
	call		CrLf
	mov			edx, offset intro_2			; printing my (programmer's) name
	call		WriteString
	call		CrLf

; segment 2 - get user name - This segment gets the user's name, stores it in userName, and then prints a statement greeting the user.
; (the greeting obviously includes the user's name)
	mov			edx, OFFSET question_1		; printing question asking user's name	
	call		WriteString			
	mov			edx, OFFSET userName    	; using readstring to store user's input of name
	mov			ecx, 32						; specifying size of 32 bytes
	call		ReadString	
	mov			edx, offset hello			; greeting user (greeting includes user's name)
	call		WriteString
	mov			edx, offset userName
	call		WriteString
	mov			edx, offset period
	call		WriteString
	call		CrLf

; segment 3- user instructions - tells user to input how many fibonacci numbers they want displayed.  then states that user can specify a number in the
; range of 1 to 46
	mov			edx, offset instructions_1	; telling user to get ready to input number of desired fibonacci numbers
	call		WriteString
	call		CrLf
	mov			edx, offset instructions_2	; telling user range of acceptable numbers
	call		WriteString
	call		CrLf

; segment 4 - Fibo number input - asks user to input desired number of fibo numbers.  If they give a number outside of acceptable range
; (1 to 46), it rejects input and instructs user to try again.  This segment also uses the user's input (which is stored in userNum)
; to determine how many rows are ultimately going to be displayed (five terms per row as per the assignment instructions).  This is
; necessary because it allows the program to display all terms in aligned columns (the number of rows is used in the calculation of how much
; space should be between each term -- this will be elaborated on later). this value is stored in spacingNum.
; fiboNumInput is a post-test loop that gets the desired num of displayed terms from the user.  if the input fails validation, the loop starts
; over and asks the user to input the num again
;10 INSTRUCTIONS
fiboNumInput:								
	mov			edx, offset instructions_3	; asking user to input desired number of displayed fibo terms
	call		WriteString
	call		ReadInt	
	cmp			eax, UPPER_LIMIT			; comparing inputted value to constant that has upper limit of range
	jg			fiboNumInput				; if larger than upper limit, loop begins again
	cmp			eax, LOWER_LIMIT			; comparing inputted value to constant that has lower limit of range
	JL			fiboNumInput				; if less than lower limit, loop begins again
	mov			userNum, eax				; if input passes checks, it is stored in userNum
	mov			ebx, 5						; beginning calculation to determine spacingNum.  
	cmp			userNum, ebx
	JlE			divSkip						; if num is less than or equal to 5, program jumps to divskip (reason why is explained in comments for divskip)
	xor			edx, edx					; clearing edx so division can safely be done
	div			ebx							; dividing user's input by 5
	mov			spacingNum, eax				; storing input into spacingNum
	jmp			initFiboLoop				; skipping divskip and jumping to the initialization of the fibo loop
; divskip (it is a part of the fibo number input segment) assigns spacingNum a value of 1.  This is necessary because any number less than
; or equal to 5 produces a result of 0, which breaks some of nested conditionals in the fiboloop section.  While this is an awkward fix to
; the problem, it is the easiest thing I could think of doing.
divSkip:
	mov			spacingNum, 1				; assigning value of 1 to spacingNum

; segment 5 - initializing fibo loop - displays the first value (which is a 1) of the fibonacci terms.  I wasn't clever enough to think of a 
; way to get my fibo loop to display the first 1 (fibo terms go like this: 1 - 1 - 2 - etc.), and the easiest way to get around this was
; to simply display the first 1 outside my fibo loop.
; initFiboLoop exists as a jump point for input values 6 and above from the user (for desired number of displayed fibo terms).  It prints a 
; value of 1 and then copies the value of spacingNum to ecx (so that the appropriate amount of between the first two terms can be calculated).
; also, if the user inputs the value 1 for the desired number of displayed terms, it is unnecessary to print any spaces or run through any of
; the subsequent loops.  initFiboLoop checks for that, and if it is true, it simply skips to goodByeUser and ends the program
; 5 INSTRUCTIONS
initFiboLoop:
	mov			eax, 1						; printing first fibo term.  Beginning initialization of fibo loop
	call		writedec
	cmp			userNum, 1					; checks to see if the user only asked for one term to be displayed
	je			goodbyeUser					; if that is the case, the program jumps to the goodbyeuser segment and ends the program
	mov			ecx, spacingNum				; copying value of spacingNum to ecx so that proper spacing between first two terms can be calculated
; initSpacingLoop calculates the amount of space in between the first two fibonacci terms.  The formula for spacing is simple. 
; It is: (number of rows - (number of digits in term - 1)) + 5            
; 5 is the minimum number of spaces between each term (specified by the assignment)
; Since the first term is always going to have 1 digit, initSpacingLoop simply prints ((value in spacingNum) + 5) number of spaces after 
; the first term.  initSpacingLoop also sets up eax and ebx for fiboLoop by copying 0 to eax and 1 ebx (which allows the program to start
; calculating and printing all of the subsequent fibonacci terms).  It then copies userNum to ecx (the user's desired number of fibo terms
; is the counter for fiboLoop) and decrements it by 1 since 1 term has just been printed
initSpacingLoop:
	mov			edx, offset space			; printing appropriate number of spaces after first term
	call		writestring
	loop		initSpacingLoop			
	mov			edx, offset fiveSpace		; fiveSpace adds the required 5 spaces to the spaces determined by the number of digits in the term
	call		writestring
	mov			eax, 0						; moving 0 to eax to set up fiboLoop
	mov			ebx, 1						; moving 1 to ebx to set up fiboloop
	mov			ecx, userNum				; copying userNum to ecx, so that program can display appropriate number of fibo terms
	dec			ecx							; decrementing ecx by 1, because 1 term was just printed
; segment 6 - Actual Fibo loop - Fibo loop calculates and prints numbers from the fibonacci sequence.  It also has a number of nested
; conditionals that calculate and print the appropriate amount of space between each term (the space scales with userNum)
; the Fiboloop also keeps track (well, a nested conditional does) of how many terms have been printed.  After 5 terms have been printed,
; a line break is printed (for a minimum of 1 line, and a maximum of 10 lines)
; fiboLoop begins by adding ebx to eax (a fibonacci term is found by adding the preceding two terms).  the new term (which is in eax)
; is then printed.  The values in eax (newly printed fibonacci term), ebx (preceding fibonacci term), and ecx (counter for the loop) are
; then pushed onto the stack (so that they can be retrieved later) because ecx, ebx, and eax are needed by columnLoop, printSpaces, and fivePrint
; in order to calculate and print the appropriate amount of spaces to print before the next fibonacci term is calculated and printed.
; spacingNum (the number of rows) is copied to ecx and the value 10 is copied to ebx (columnLoop needs this in order to determine how many
; digits are in the current fibonacci term)
fiboLoop:
	add			eax, ebx					; adding ebx to eax in order to generate new fibonacci term
	call		WriteDec					
	push		ecx							; pushing ecx, and ebx, and eax to stack in order to store values for later use
	push		ebx
	push		eax
	mov			ecx, spacingNum				; copying row count to ecx so that spaces can be calculated
	mov			ebx, 10						; copying 10 to ebx so that spaces can be calculated
; columnLoop begins the work of calculating and printing the appropriate number of spaces to print after the fibonacci term in order to display
; the numbers in aligned columns.  columnLoop determines the number of digits in a number by dividing it by powers of 10.  For example, if the
; value in eax is divided by 10, and it produces a 0, that means it has a single digit.  if it doesn't produce a zero, the value in ebx is multiplied
; by 10, ecx is decremented by 1, and eax has its value restored by copying the top of the stack to it.  Then the process starts all over again
; until either eax equals 0 or ecx hits 0.  When eax is 0 after division, there is a jump to printSpaces where the value in ecx is used to calculate
; the number of spaces to print after the current fibonacci term.  If ecx hits 0, there is a jump to fivePrint (which means that that fibonacci term
; has so many digits that it is only necessary to print the 5 minimum spaces) where only the 5 minimum spaces are printed
columnLoop:
	xor			edx, edx					; edx is cleared so that division can safely be done
	div			ebx							; fibonacci term is divided by 10 to determine how many digits it has
	cmp			eax, 0						; check results of division to see if it equals 0
	je			printSpaces					; jump to printSpaces where number of spaces are calculated
	mov			eax, 10						; if 0 isn't result, it is necessary to generate next power of 10
	mul			ebx							; getting next power of 10
	xchg		eax, ebx					; swapping next power of 10 back into ebx
	mov			eax, [esp]					; restoring fibonacci term to eax from stack
	dec			ecx							; decrementing ecx (which contains row amount)
	cmp			ecx, 0						; if ecx equals 0, jump to fivePrint to print 5 spaces
	
	je			fivePrint
	jmp			columnLoop					; starting loop over
; printSpaces is a loop that uses the value left in ecx to determine how many spaces to print.  It prints a space and decrements ecx
; until ecx is equal to 0.  Once it is finished, it moves on to fivePrint where the five minimum spaces are printed.
printSpaces:
	mov			edx, offset space			; printing a space
	call		writestring
	dec			ecx							; decrementing ecx until it hits 0 (where the loop ends)
	cmp			ecx, 0
	jg			PrintSpaces					; jumping to beginning of loop until ecx equals 0
; fivePrint marks the end of the space printing and calculating loops.  It prints the 5 minimum spaces and then pops eax, ebx, and ecx off of
; the stack.  The values in eax and ebx are swapped so that the newly generated fibonacci term is maintained when they are added again when the
; the loop jumps back to the beginning.  Count (again, which is used to keep track of how many terms have been printed) is incremented.  Once
; it hits a value of 5, a line break is printed (so that there are only 5 fibonacci terms per line)
fivePrint:
	mov			edx, offset fiveSpace		; printing five spaces
	call		writestring
	pop			eax							; restoring fibonacci terms to eax and ebx by popping them off of the stack
	pop			ebx
	pop			ecx							; restoring counter for main fibo loop by popping off of the stack
	xchg		eax, ebx
	inc			count						; incrementing counter since fibonacci term was printed earlier
	cmp			count, 5					; when counter hits 5, a line break is printed.  
	jl			done
; lineBreak prints a line brea when count hits 5 and then resets count to 0, so that the next line of fibonacci terms can be tracked
lineBreak:
	call		CrLf						; printing line break
	mov			count, 0					; resetting count to 0
; done jumps the program back to the top of the loop so that the next fibonacci term can be generated.  Once ecx hits 0, the loop ends, and
; the program moves on to the saying goodbye segment
done:
	loop		fiboLoop					

; segment 7 - saying goodbye - Once the program is finished printing all of the fibonacci terms, it prints a line break, and then says goodbye
; to the user (it uses the user's name when it does this)
goodbyeUser:
	call		CrlF						; printing line break to make sure there is separation between the goodbye and the list of fibo terms
	mov			edx, offset goodbye			; printing first part of goodbye emessage
	call		WriteString
	mov			edx, offset userName		; printing username
	call		WriteString
	mov			edx, offset period			; printing period to end goodbye message
	call		WriteString



	exit	; exit to operating system
main ENDP


END main
