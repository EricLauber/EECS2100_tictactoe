;  Filename:	extra.asm
;  Program Name:	"Tic-Tac-Toe"
;  Author:	Wes Vollmar and Eric Lauber
;  Class:	EECS 2100 - Comp. Org. and Assembly
;  Creation Date:  11/24/07
;  Revisions:  
;  Date:			Modified By:
;  Program Description:  This file is to externally to check for correct choices, check who wins, and the do the computer algorithm.

INCLUDE ASM.INC
INCLUDE PCMAC.INC

	.MODEL MEDIUM
	.586
	.DATA
	
	EXTRN	character:byte, board:byte, movCount:byte
	
	win DB ?										; Variable: 1-player won, 2-computer won
	PUBLIC win

	valid DB ?										; Variable: 0-invalid choice, 1-valid choice
	PUBLIC valid
		
	movedone DB ?									; Variable: 0-Comp has not made a move, 1-Comp has made a move
	checker  DB ?
	
	.CODE
boardClear 		PROC
		pusha										; Store Registers
		
		mov bx, 0

clearLoop:
		mov [board + bx], ' '						; Set a certain square to space
		inc bx										; Go to the next square
		cmp bx, 9									; Check if it's done
		jne clearLoop
		
		popa										; Restore registers
		ret											; Returns to parent process
boardClear		ENDP


checkvalid 		PROC
		pusha										; Store Registers
	
		cmp al, 1h									; See if below range, invalid if so
		jl Nonvalid
		cmp al, 9h									; See if above range, invalid if so
		jg Nonvalid
		
													; Check if already chosen, invalid if so...the long way...
												
					cmp al, 9h
					je nine
					cmp al, 8h
					je eight
					cmp al, 7h
					je seven
					cmp al, 6h
					je six
					cmp al, 5h
					je five
					cmp al, 4h
					je four
					cmp al, 3h
					je three
					cmp al, 2h
					je two
					cmp al, 1h
					jmp one 
		
			nine:
					cmp [board + 2], ' '
					jne Nonvalid
					jmp TrueValid
			eight:	
					cmp [board + 1], ' '
					jne Nonvalid
					jmp TrueValid
			seven:
					cmp board, ' '
					jne Nonvalid
					jmp TrueValid
			six:	
					cmp [board + 3], ' '
					jne Nonvalid
					jmp TrueValid
			five:
					cmp [board + 8], ' '
					jne Nonvalid
					jmp TrueValid
			four:
					cmp [board + 7], ' '
					jne Nonvalid
					jmp TrueValid
			three:
					cmp [board + 4], ' '
					jne Nonvalid
					jmp TrueValid
			two:
					cmp [board + 5], ' '
					jne Nonvalid
					jmp TrueValid
			one:	
					cmp [board + 6], ' '
					jne Nonvalid						
	
TrueValid:	
		mov valid, 1								; Valid entry if all checks passed, sets valid to 1
		jmp FinValid
	
Nonvalid:
		mov valid, 0								; Invalid entry sets valid to 0
		dec movCount
		
FinValid:	
		popa										; Restores registers
		ret											; Returns to parent process
checkvalid 		ENDP


Rotation		PROC								; Rotate the board 90 degrees clockwise
		pusha										; Store Registers
		
		mov	ah, board								; Move board values 0 through 7 into
		mov	al, [board+1]							; the registers so they can be reordered.
		
		mov	bh, [board+2]
		mov	bl, [board+3]

		mov	ch, [board+4]
		mov	cl, [board+5]

		mov	dh, [board+6]
		mov	dl, [board+7]

		mov board, dh								; Move board values 0 through 7 back
		mov [board+1], dl							; into the board.

		mov [board+6], ch
		mov [board+7], cl

		mov [board+4], bh
		mov [board+5], bl

		mov [board+2], ah
		mov [board+3], al
		
		popa										; Restore Registers
		ret											; Returns to parent process						
Rotation		ENDP


makemove 		PROC								; Places moves made into the board array.
		pusha										; Store Registers
	
		mov bl, character							; Moves character into bl for placement into memory
		
		cmp al, 9h									; Checks which selection was made
		je nine
		cmp al, 8h
		je eight
		cmp al, 7h
		je seven
		cmp al, 6h
		je six
		cmp al, 5h
		je five
		cmp al, 4h
		je four
		cmp al, 3h
		je three
		cmp al, 2h
		je two
		cmp al, 1h
		jmp one 
		
nine:												; And puts the character in that correct box
		mov [board + 2], bl
		jmp PlacedChar
eight:	
		mov [board + 1], bl
		jmp PlacedChar
seven:
		mov board, bl
		jmp PlacedChar
six:	
		mov [board + 3], bl
		jmp PlacedChar
five:
		mov [board + 8], bl
		jmp PlacedChar
four:
		mov [board + 7], bl
		jmp PlacedChar
three:
		mov [board + 4], bl
		jmp PlacedChar
two:
		mov [board + 5], bl
		jmp PlacedChar
one:	
		mov [board + 6], bl
		
PlacedChar:		
		popa											; Restores registers
		ret												; Return to parent process
makemove 		ENDP


Complete 		PROC									; Run checks to see if someone won
		pusha											; Store Registers	
		
		mov bx, 0
		mov	al, character
		
DIAG:													; Check Diaganol ULC to LRC
;	-Bytes 0, 8, and 4 are all set to X or O (ULC MID LRC)
		cmp al, board									; Check byte 0
		jne	MIDC
		
		cmp al, [board+8]								; Check byte 8
		jne LEFTC
		
		cmp al, [board+4]								; Check byte 4
		jne LEFTC
		
		jmp THEWIN										; Else, we have a winner
LEFTC:
;	-Bytes o (Already checked) 6, and 7 are all set to X or O (LEFT COLUMN)
		cmp al, [board+7]								; Check byte 7
		jne MIDC
		
		cmp al, [board+6]								; Check byte 6
		jne RHTC
		
		jmp THEWIN										; Else, we have a winner
		
MIDC:
;	-Bytes 1, 5, and 8 are all set to X or O (MIDDLE COLUMN)
		cmp al, [board+1]
		jne RHTC
		
		cmp al, [board+5]								; Check byte 5
		jne RHTC
		
		cmp al, [board+8]
		jne RHTC

		jmp THEWIN										; Else, we have a winner
		
RHTC:
;	-Bytes 2, 3, and 4 are all set to X or O (RIGHT COLUMN)
		cmp al, [board+2]
		jne NADA
		
		cmp al, [board+3]
		jne NADA
		
		cmp al, [board+4]
		jne NADA
	
THEWIN:													; A winner has been found
		cmp al, 'x'
		je P1wins
		mov win, 2
		cmp bx, 2										; Check how many run throughs have been done
		jne RORS										; and rotate 2 or 3 times accordingly.
		call Rotation
		jmp RORS
		
P1wins:
		mov win, 1
		cmp bx, 2										; Check how many run throughs have been done
		jne RORS										; and rotate 2 or 3 times accordingly.
		call Rotation
		jmp RORS		
		
NADA:
		inc bx											; If no winner was found, rotate the board
		call Rotation									; 90 degrees and look again.
		cmp bx, 2										; Otherwise, note that no one won.
		jne DIAG		
		mov win, 0
RORS:
		call Rotation									; Move board back into place with 2 rotations.
		call Rotation
		popa											; Restores all registers
		ret
		
Complete 		ENDP


THECHECK		PROC
		; Check to see if there is a possible move and if so, take it.
		mov cx, 0										; Counting loop
		mov	bl, checker
DECHECK:
		; Pattern 1/6, fill in 0 if available and bytes 1 and 2 are 'O'/'x'
		cmp board, ' '
		jne PAT4
		cmp [board+1], bl
		jne PAT2
		cmp [board+2], bl
		jne PAT2
		mov board, 'o'									; Computer has a move and will take it.
		mov movedone, 1									; Computer has made a move.
		ret

PAT2:	; Pattern 2/7, fill in 0 if available and bytes 6 and 7 are 'o'/'x'
		cmp [board+6], bl
		jne PAT3
		cmp [board+7], bl
		jne PAT3
		mov board, 'o'									; Computer has a move and will take it.
		mov movedone, 1									; Computer has made a move.
		ret

PAT3:	; Pattern 3/8, fill in 0 if available and bytes 8 and 4 are 'o'/'x'	
		cmp [board+8], bl
		jne PAT4
		cmp [board+4], bl
		jne PAT4
		mov board, 'o'									; Computer has a move and will take it.
		mov movedone, 1									; Computer has made a move.
		ret

PAT4:	; Pattern 4/9, fill in 1 if available and bytes 0 and 2 are 'o'/'x'
		cmp [board+1], ' '
		jne REDUX
		cmp board, bl
		jne PAT5
		cmp [board+2], bl
		jne PAT5
		mov [board+1], 'o'								; Computer has a move and will take it.
		mov movedone, 1									; Computer has made a move.
		ret

PAT5:	; Pattern 5/10, fill in 1 if available and bytes 5 and 8 are 'o'/'x'
		cmp [board+5], bl
		jne REDUX
		cmp [board+8], bl
		jne REDUX
		mov [board+1], 'o'								; Computer has a move and will take it.
		mov movedone, 1									; Computer has made a move.
		ret

REDUX:													; Will rotate board 3 times and keep checking to win.
		inc cx
		cmp cx, 4
		call Rotation
		jne DECHECK										; Keep checking until 4th rotation, fall into 2MOV PROC.
		ret												; Return to parent process

THECHECK		ENDP


Algorithm 		PROC									; This algorithm is the Artificial Intellegence for
		pusha	; Store Registers							; the computer opponent. It will follow a minimzed
														; version of the pattern given to students in class.
		
		mov movedone, 0									; Default the computer to having not done a move yet.
		mov	checker, 'o'								; Call the winning/blocking checking procedure for
		call THECHECK									; Character 'o', check to see if a move was done, and
		cmp movedone, 1									; if not, repeat the process for 'x'. Otherwise, predict
		je FIXBRD1										; two moves ahead.
		mov checker, 'x'
		call THECHECK
		cmp movedone, 1
		je FIXBRD1

	; Computer predicting the future, planning 2 moves ahead
		mov cx, 0										; Restart Counting loop
TWOMOVCHK:
	; Pattern 11, if  bytes 0, 1, 3, 4, 5, and 7 are available,
	; 2 and 6 are X and 8 is o, hit byte 1 with o.
		cmp board, ' '
		jne PAT15
		cmp [board+8], 'o'
		jne PAT15
		cmp [board+1], ' '
		jne PAT12
		cmp [board+2], 'x'
		jne PAT12
		cmp [board+3], ' '
		jne PAT12
		cmp [board+4], ' '
		jne PAT12
		cmp [board+5], ' '
		jne PAT12
		cmp [board+6], 'x'
		jne PAT12
		cmp [board+7], ' '
		jne PAT12
		mov [board+1], 'o'								; Computer has a blocking move and will take it.
		mov movedone, 1									; Computer has made a move.
		jmp FIXBRD1

PAT12:	; Pattern 12, if bytes 0, 2, and 6 are available, 8 is o
		; and 1 and 7 are x, move o into byte 0.
		cmp [board+7], 'x'
		jne PAT14
		cmp [board+6], ' '
		jne PAT14
		cmp [board+1], 'x'
		jne PAT13
		cmp [board+2], ' '
		jne PAT13
		mov board, 'o'									; Computer has a blocking move and will take it.
		mov movedone, 1									; Computer has made a move.
		jmp FIXBRD1

PAT13:	; Pattern 13, if bytes 0, 1 and 6 are available, 8 is o, 
		; and 7 and 2 are x, move o into byte 0
		cmp [board+1], ' '
		jne PAT16
		cmp [board+2], 'x'
		jne PAT15
		mov board, 'o'									; Computer has a blocking move and will take it.
		mov movedone, 1									; Computer has made a move.
		jmp FIXBRD1

PAT14:	; Pattern 14, if bytes 0, 1, and 7 are available, 8 is o,
	; and 6 and 2 are x, move o into byte 0.
		cmp [board+6], 'x'
		jne PAT15
		cmp [board+7], ' '
		jne PAT15
		mov board, 'o'									; Computer has a blocking move and will take it.
		mov movedone, 1									; Computer has made a move.
		jmp FIXBRD1

PAT15:	; Pattern 15, if bytes 1 and 5 are available and 8 is x,
	; move o into byte 0.
		cmp [board+8], 'x'
		jne TWOMOVREDUX
		cmp [board+5], ' '							
		jne PAT16
		mov [board+1], 'o'								; Computer has a blocking move and will take it.			
		mov movedone, 1									; Computer has made a move.
		jmp FIXBRD1

PAT16:	; Pattern 16, is byte 1 and 5 are available and 8 is x,
	; move o into byte 5.
		cmp board, ' '										
		jne TWOMOVREDUX
		cmp [board+4], ' '							
		jne TWOMOVREDUX
		mov board, 'o'									; Computer has a blocking move and will take it.
		mov movedone, 1									; Computer has made a move.
		jmp FIXBRD1

TWOMOVREDUX:
		inc cx
		cmp cx, 4
		call Rotation
		jne TWOMOVCHK									; Keep checking until 4th rotation, fall into Fixing Board PROC.
	
FIXBRD1:
		cmp cx, 4
		jne FIXBRD2
		cmp movedone, 1
		jne RNDMOV
		jmp COMPDONE
		
FIXBRD2:
		inc cx
		call Rotation
		jmp FIXBRD1
		
	; If the computer cannot win, and cannot block a move, it will attempt
	; to fill in a space on the board starting with byte 8 and rotating
	; around to byte 0.
		
RNDMOV:	
		mov bx, 9										; Prep counting loop to check for free spaces on board.
REDO:		
		dec bx
		cmp [board+bx], ' '								; Make sure that the box is a space
		jne REDO
		mov [board+bx], 'o'								; Puts an o in that spot
		mov movedone, 1

COMPDONE:
		popa											; Restores registers
		ret
Algorithm 	ENDP

			END
