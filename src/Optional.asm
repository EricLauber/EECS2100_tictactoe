;  Filename: Optional.asm
;  Program Name:  "Tic-Tac-Toe"
;  Author:  Wes Vollmar and Eric Lauber
;  Class:  EECS 2100 - Comp. Org. and Assembly
;  Creation Date:  11/24/07
;  Revisions:  
;  Date:			Modified By:
;  Program Description:  This is for the optional stuff in the game.

INCLUDE ASM.INC
INCLUDE PCMAC.INC

	.MODEL MEDIUM
	.586
	.DATA
	
		extrn drawmode:byte
		
bTitle DB "In an Unrelenting Hellfire:", 0
omsg DB "Be Afraid, Be Very Afraid...", 0
		
		;Main Title Display Location
btitlex		DW	33
btitley		DW	2
		;Subtitle Variables
stitle		DB	"Tic-Tac-Toe", 0				
		;Subtitle Display Location
stitlex		DW	116
stitley		DW	18
		;Turn Message Display Location
turnx		DW	4
turny		DW	223

		;Variables for Drawing the Board
bgcolor		DB	red
bkg0		DW 	0,0
bkg1		DW 	319,239

		;Constants used in Sound Production
PPI_B		EQU	61h	;I/O Port Address of the Programmable Peripheral Interface Chip 8254 Timer Chip
PIT_CW		EQU	43h	;PPI Control Word Port Address
PIT_CH2		EQU	42h	;PPI Frequency Value Port Address
		;Information regarding what the PPI is, its purpose, how it works,
		;and other details of how to generate sound in Assembly language for
		;the IBM PC family was found at Solution Tech Systems, Inc.
		;at http://www.solutiontech.com/set/year1/embedded/intel/sound.html
		;and on a course guide from Yale University located at
		;http://flint.cs.yale.edu/cs421/papers/art-of-asm/pdf/CH10.PDF
		;To create sound, one must first determine the pitch desired and find
		;the frequency of the pitch. The PPI operates at about 1,192,180 or
		;1.19 MHz. Dividing the PPI's frequency by the desired frequency gives
		;the number of cycles the computer must wait before 'plucking' the
		;speaker. Repeating this for the number of cycles continuously results
		;in the desired frequency of sound and a pitch is heard. The number of
		;cycles must be written as hexidecimal to the lower and upper bytes of
		;the PPI's frequency value port address.
	
	.CODE
		extrn  	fillbox:far				;Used for filled rectangles
		extrn  	gcolor:far				;Setting foreground and background colors
		extrn	gprint:far				;We like text 
		extrn	gclear:far				;yay, wipe the screen

WAH			PROC
		pusha							;Store registers
		
		in al, PPI_B 					;Move in the PPI address
		or al, 03h 						;Turn on the speaker by setting bits 0 and 1
		out PPI_B, al					
		
		mov al, 086h					;The neccesary Control word code is moved
		out PIT_CW, al					;into address 43h
		
		mov al, 5Dh					;Write "Concert F" to port 42h and Play
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 0Dh
		out PIT_Ch2, al 				;Write Upper Byte

		mov ebx, 7FFFFh
wastetime1:								;Hold the note for a bit of time
		dec ebx
		jnz wastetime1

		in al, PPI_B 					;Move in the PPI address
		AND al, 0FCh					;Turn of the speaker by clearing bits 0 and 1
		out PPI_B, al
		
		mov al, 086h					;The neccesary Control word code is moved
		out PIT_CW, al					;into address 43h
		
		mov al, 0E9h					;Write "Concert B" to port 42h and Play
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 012h
		out PIT_Ch2, al 				;Write Upper Byte
	
		in al, PPI_B 					;Move in the PPI address
		or al, 03h 						;Turn on the speaker by setting bits 0 and 1
		out PPI_B, al		

		mov ebx, 0FFFFFh
wastetime2:								;Hold the note for a bit of time
		dec ebx
		jnz wastetime2	
		
		in al, PPI_B 					;Move in the PPI address
		AND al, 0FCh					;Turn of the speaker by clearing bits 0 and 1
		out PPI_B, al
		
		popa							;Restore Registers
		ret
WAH			ENDP
	
	
trip		PROC
		mov ebx, 33FFEh
loop1:									;Triplet 8th note length
		dec ebx
		jnz loop1
		ret
trip		ENDP


half		PROC
		mov ebx, 19FFFh
loop2:									;1/2 Triplet 8th note length
		dec ebx
		jnz loop2
		ret
half		ENDP


quart		PROC
		mov ebx, 9BFFAh
loop3:									;Quarter note length

		dec ebx
		jnz loop3
		ret
quart		ENDP	
	

castle		PROC

		pusha							;Store registers
		
		in al, PPI_B 					;Move in the PPI address
		or al, 03h 						;Turn on the speaker by setting bits 0 and 1
		out PPI_B, al					
		
		mov al, 086h					;The neccesary Control word code is moved
		out PIT_CW, al					;into address 43h
		
		mov al, 0DCh					;Write and Play G0
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 17h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip

		mov al, 0C6h					;Write and Play C1
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 011h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip		
		
		mov al, 01Bh					;Write and Play E1
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 00Eh					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip		
		
		mov al, 0EEh					;Write and Play G1
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 00Bh					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip	

		mov al, 0E3h					;Write and Play C2
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 008h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip	

		mov al, 00Eh					;Write and Play E2
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 007h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip	

		mov al, 0F7h					;Write and Play G3
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 005h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call quart
		
		mov al, 00Eh					;Write and Play C2
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 007h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call quart	
		;-----------------

		mov al, 0C3h					;Write and Play G0#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 017h					;
		out PIT_Ch2, al				;Write Upper Byte

		call trip

		mov al, 0C6h					;Write and Play C1
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 011h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip		
		
		mov al, 0F9h					;Write and Play D1#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 00Eh					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip		
		
		mov al, 039h					;Write and Play G1#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 00Bh					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip	

		mov al, 0E7h					;Write and Play C2
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 008h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip	

		mov al, 07Dh					;Write and Play D2#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 007h					;Write and Play
		out PIT_Ch2, al 				;Write Upper Byte

		call trip	

		mov al, 09Bh					;Write and Play G3#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 005h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call quart
		
		mov al, 07Dh					;Write and Play D2#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 007h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call quart	
		;-----------------
		
		mov al, 0FDh					;Write and Play A0#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 013h					;
		out PIT_Ch2, al				;Write Upper Byte

		call trip

		mov al, 0D7h					;Write and Play D1
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 00Fh					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip		
		
		mov al, 058h					;Write and Play F1
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 00Dh					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip		
		
		mov al, 0FEh					;Write and Play A1#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 009h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip	

		mov al, 0EEh					;Write and Play D2
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 007h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip	

		mov al, 0ACh					;Write and Play F2
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 006h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip	

		mov al, 0FFh					;Write and Play A2#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 004h					;
		out PIT_Ch2, al 				;Write Upper Byte

		call trip
		call trip
		
		in al, PPI_B 					;Move in the PPI address
		AND al, 0FCh					;Turn off the speaker by clearing bits 0 and 1
		out PPI_B, al					;This is a rest
		
		call trip

		in al, PPI_B 					;Move in the PPI address
		or al, 03h 						;Turn on the speaker by setting bits 0 and 1
		out PPI_B, al	

		mov al, 0FFh					;Write and Play A2#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 004h					;
		out PIT_Ch2, al 				;Write Upper Byte
		
		call half
		
		in al, PPI_B 					;Move in the PPI address
		AND al, 0FCh					;Turn off the speaker by clearing bits 0 and 1
		out PPI_B, al
		
		call half

		in al, PPI_B 					;Move in the PPI address
		or al, 03h 						;Turn on the speaker by setting bits 0 and 1
		out PPI_B, al	
		
		mov al, 0FFh					;Write and Play A2#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 004h					;
		out PIT_Ch2, al 				;Write Upper Byte
		
		call half	

		in al, PPI_B 					;Move in the PPI address
		AND al, 0FCh					;Turn off the speaker by clearing bits 0 and 1
		out PPI_B, al
		
		call half

		in al, PPI_B 					;Move in the PPI address
		or al, 03h 						;Turn on the speaker by setting bits 0 and 1
		out PPI_B, al	
		
		mov al, 0FFh					;Write and Play A2#
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 004h					;
		out PIT_Ch2, al 				;Write Upper Byte
		
		call half		

		in al, PPI_B 					;Move in the PPI address
		AND al, 0FCh					;Turn off the speaker by clearing bits 0 and 1
		out PPI_B, al
		
		call half

		in al, PPI_B 					;Move in the PPI address
		or al, 03h 						;Turn on the speaker by setting bits 0 and 1
		out PPI_B, al					
		
		mov al, 073h					;Write and Play C3
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 004h					;
		out PIT_Ch2, al 				;Write Upper Byte
		
		call quart	
		call quart
		
		
		in al, PPI_B 					;Move in the PPI address
		AND al, 0FCh					;Turn off the speaker by clearing bits 0 and 1
		out PPI_B, al
		
		popa							;Restore registers
		
		ret								;Returns to parent process
castle		ENDP	
	
	
nbc			PROC
		pusha							;Save Registers
		
		in al, PPI_B 					;Move in the PPI address
		or al, 03h 						;Turn on the speaker by setting bits 0 and 1
		out PPI_B, al					
		
		mov al, 086h					;The neccesary Control word code is moved
		out PIT_CW, al					;into address 43h
		
		mov al, 0C6h					;Write and Play C1
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 011h					;
		out PIT_Ch2, al 				;Write Upper Byte
		
		call half
		
		mov al, 096h					;Write and Play A2
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 00Ah					;
		out PIT_Ch2, al 				;Write Upper Byte
		
		call half
		
		mov al, 058h					;Write and Play F1
		out PIT_Ch2, al 				;Write Lower Byte
		mov al, 00Dh					;
		out PIT_Ch2, al 				;Write Upper Byte
		
		call half
		
		in al, PPI_B 					;Move in the PPI address
		AND al, 0FCh					;Turn off the speaker by clearing bits 0 and 1
		out PPI_B, al

		popa							;Restore Registers
		
		ret								;Returns to parent process

nbc			ENDP
	
	
dTitle 		PROC						; Procedure for a game Title
		pusha
		
		call gclear						; Clear the screen
		
				;Draw background
		mov   	ah,bgcolor      		; background color
		mov   	al,hiwhite     			; any color here
		call  	gcolor	     			; Set Color
		mov   	drawmode,-1				; Use Background color
		call  	fillbox
		
		
				;Display Text (Titles)
		mov   	ah, bgcolor    			; background color
		mov   	al, black 				; foreground color
		call  	gcolor					; Set Color
		lea	SI, btitle
		lea	dx, btitlex
		call 	gprint					; Print for the main title
		lea	SI, stitle
		lea	dx, stitlex
		call 	gprint					; Print the subtitle text
				
				;Display Bottom Text
		lea	SI, omsg
		lea	dx, turnx		
		call	gprint					; Print the bottom text
		
		popa
		ret
dTitle 		ENDP

		END
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		