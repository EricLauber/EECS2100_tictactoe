;  Filename:	Project3.asm
;  Program Name:	"Tic-Tac-Toe"
;  Author:	Wes Vollmar and Eric Lauber
;  Class:	EECS 2100 - Comp. Org. and Assembly
;  Creation Date:  11/24/07
;  Revisions:  
;  Date:			Modified By:
;  Program Description:	The program will control the play and action of a game of Tic-Tac-Toe with a computer player.

INCLUDE	ASM.INC
INCLUDE PCMAC.INC

	.MODEL MEDIUM
	.586
	.STACK 100h
	.DATA
	
	EXTRN	drawmode:byte, PlayerTurn:word, board:byte, win:byte, valid:byte	
	msg		DB	'Play Again? (Y/N)', 0				; Message displayed after someone wins
	emsg	DB	'Exiting Program...', 0				; Message if choice is 'N'
	tmsg	DB	'Tie Game!!', 0						; Message for a tie game
	wcmsg	DB	'Computer Wins!!', 0				; Message saying the computer won
	wpmsg	DB	'Player Wins!!', 0					; Message saying the player won
	
	character 	DB	?								; Holds the character the player is using
	PUBLIC	character
	
	movCount	DB	0								; Counts the number of moves made
	PUBLIC	movCount
		
	.CODE
	EXTRN	dboard:far, gmode:far, textmode:far, printmsg:far
	EXTRN	checkvalid:far, boardClear:far, makemove:far, Complete:far, Algorithm:far
	EXTRN   dTitle:far, WAH:far, castle:far, nbc:far
	
ENGINE	PROC
		_Begin										; Load the data segment
		
		call	gmode								; Start graphics mode
Init:	
		call	boardClear							; Clears the board for new game
		mov		PlayerTurn, 0						; Sets to start as player's turn
		mov		win, 0								; Resets that no one won
		mov		movCount, 0							; No moves made
		
		call	dTitle								; Display the title screen
		_getCh	noecho								; Wait for a button press to continue
		
		call	dboard								; Display the begining board
		
	
Whoturn:
		cmp		PlayerTurn, 0						; Checks who's turn it is	
		jne		CompTurn
		
PlayerGoes:
		mov		character, 'x' 						; Sets the character for player 1 to x
		
		inc		movCount							; One more move has been made
		cmp		movCount, 10						; If the board is full
		je		tieGame								; jump to tie game
		
		_getCh	noecho								; Get players choice of square
		sub		al, 30h								; Convert hex value to number entered in the numpad
		
		call	checkvalid							; Make sure its a correct choice, along with not being already chosen
		cmp		valid, 1							
		jne		PlayerGoes							; If invalid, return for another choice until it is valid
		
		call	makemove							; Make the move to the board
		call	nbc									; Play a sound to indicate a move was made.
		mov		PlayerTurn, 1						; Set to opposite player's turn
		call	dboard								; Display the board after the move
		call	Complete							; Check for win
		
		
		cmp		win, 1								; If player won, display message as such, otherwise 
		jne		Whoturn								; with no win, go back for other player's turn

		lea		bx, wpmsg
		call	printmsg
		call	castle
		_getCh	noecho
		jmp		End_p								; Go to end, after win, to play again		
		
CompTurn:
		mov		character, 'o' 						; Sets the character for player 1 to o
		
		inc		movCount							; One more move has been made
		cmp		movCount, 10						; If the board is full
		je		tieGame
		
		call	Algorithm							; Computer chooses where to go
		
		mov		PlayerTurn, 0						; Set to opposite player's turn
		call	dboard								; Displays board after computer turn
		call	Complete							; Check for win
		
		cmp		win, 2								; If computer won, display message as such, otherwise
		jne		Whoturn								; with no win, go back for other player's turn
	
		lea		bx, wcmsg							; Print the message that the computer won
		call	printmsg
		
		call	WAH									; Play the losing sound
		_getCh	noecho
		
		jmp		End_p								; Go to end, after win, to play again
		
tieGame:
		lea		bx, tmsg							; Print the message for a tie
		call	printmsg
		call	WAH
		_getCh	noecho								; Wait for a character press to continue
		
End_p:
		lea		bx, msg								; Asks to play again?
		call	printmsg

closeGame:		
		_getCh	noecho								; Get selection
		cmp		al, 'Y'								; Checks for uppercase Y to play again
		je		Init
		cmp		al, 'y'								; Checks for lowercase y to play again
		je		Init								; Jumps to init if play again to clear board and reset variables.
		cmp		al, 'N'								; Compares to capital N for quit
		je 		final
		cmp		al, 'n'								; Compares to lowercase n for quit
		jne		closeGame							; Otherwise invalid keystroke...
		
final:		
		lea		bx, emsg							; Display exit message if not chosen to play again
		call	printmsg
		_getCh	noecho								; Wait for keypress to continued
		
		call 	textmode							; Revert back to text mode

		_Exit 	0									; Exit program
ENGINE	ENDP

	END	ENGINE										; End Main procedure of ENGINE
