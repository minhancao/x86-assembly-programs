TITLE Program3           (Program3.asm)
; This program adds and subtracts the values in X and Y
; and displays the c-flag and o-flag for the arithmetic operation(8-bit).
; This program also includes procedures that converts 8-bit number to ASCII value, display output,
; and check for overflow in addition and substraction operations.
;
; Programmer : Minh An Cao
; Last date modified : 8/10/2017

INCLUDE Irvine32.inc

.data
counter BYTE 0h ; for looping
valX BYTE 0CAh, 046h, 0CBh
valY BYTE 0EBh, 074h, 037h
xIs BYTE "X is ??", 0Dh, 0Ah, 0
yIs BYTE "Y is ??", 0Dh, 0Ah, 0
strToPrint BYTE "X+Y is ??", 0
strToPrint2 BYTE " with c-flag(?) and o-flag(?)", 0 ; c and o-flags are defaultly 0, will change if needed
strToPrint3 BYTE "X-Y is ??", 0

.code
main PROC
	mov counter,LENGTHOF valX
	mov esi,0 ; to traverse the numbers in valX and valY

	MYLOOP:
		mov al,valX[esi] 
		call ConvertToASCII ; converts whatever is in al into its ASCII value in the al and bl register
		mov xIs+5,al ; puts the left 4-bit number into the string
		mov xIs+6,bl ; puts the right 4-bit number into the string
		mov edx,OFFSET xIs
		call DisplayOutput
		mov al,valY[esi] 
		call ConvertToASCII ; converts whatever is in al into its ASCII value in the al and bl register
		mov yIs+5,al ; puts the left 4-bit number into the string
		mov yIs+6,bl ; puts the right 4-bit number into the string
		mov edx,OFFSET yIs
		call DisplayOutput
	
		;ADDITION
		mov eax,0
		mov ebx,0
		mov al,valX[esi]
		mov bl,valY[esi]
		adc eax,ebx ; adds with carry if there is a carry

		call ConvertToASCII ; receives what is in al and converts it to ASCII value returned in al and bl
		mov strToPrint+7,al ; putting left 4-bit number in for the sum to print
		mov strToPrint+8,bl ; putting right 4-bit number in for the sum to print
		mov edx,OFFSET strToPrint
		call DisplayOutput ; calls this procedure to print whatever is in EDX

		;CarryTest
		cmp ah,00h ; compares to see if there was carry flag set
		jg SETCARRY ; jumps to SETCARRY statement if there was something in ah(ah>0)
		mov strToPrint2+13, "0" ; puts 0 because there was not a carry
		jmp END1

		SETCARRY:
			mov strToPrint2+13, "1" ; puts 1 because there was a carry
			jmp END1
		
		END1:
		mov cl,valX[esi]
		mov dl,valY[esi]
		call OverflowTest ; calls this procedure to check for overflow in the arithmetic
		mov edx,OFFSET strToPrint2 ; puts the string with the overflow flag in edx
		call DisplayOutput ; displays whatever is in edx
	

		;SUBSTRACTION
		call crlf	; newline
		mov eax,0
		mov ebx,0
		mov al,valX[esi]
		mov bl,valY[esi]
		sbb eax,ebx

		call ConvertToASCII ; receives what is in eax and converts it to ASCII value returned in al and bl
		mov strToPrint+7,al ; putting left 4-bit number in for the sum to print
		mov strToPrint+8,bl ; putting right 4-bit number in for the sum to print
		mov edx,OFFSET strToPrint
		call DisplayOutput ; calls this procedure to print whatever is in EDX

		;CarryTest
		cmp strToPrint2+13,030h ; compares the carry flag from addition earlier with ascii value "0"
		je SETCARRY2 ; jumps to set the carry flag to "1" if addition's flag was "0"
		mov strToPrint2+13,"0" ; else if addition's flag was "1" we set it to "0" for substraction here
		jmp END2

		SETCARRY2:
			mov strToPrint2+13, "1"
			jmp END2

		END2:	
		mov cl,valX[esi]
		mov dl,valY[esi]
		not dl ; to get 2's complement of y value
		inc dl ; to get 2's complement of y value
		call OverflowTest ; calls this procedure to check for overflow in the arithmetic
		mov edx,OFFSET strToPrint2 ; puts the string with the overflow flag in edx
		call DisplayOutput ; displays whatever is in edx	

		call crlf	; newline
		call crlf	; newline

		inc esi
		dec counter
		mov ecx,0
		mov cl, counter ; puts counter back into cl(ecx)
	jne MYLOOP ; jump if not equal

	exit

main endp

;---------------------------------------------------------------------------------------------------
ConvertToASCII PROC
;
; This procedure converts whatever is in al into their respective ASCII value.
; Receives: EAX
; unsigned
; Returns: left 4-bit number in EAX(al), right 4-bit number in EBX(bl)
; Requires: nothing
;---------------------------------------------------------------------------------------------------
	mov bl,al
	shr al,4  ; to get the left 8-bit number
	and bl,00Fh ; to get the right 8-bit number

	cmp al,0Ah ; comparing the left 8-bit number to see if need to add +37h or +30h
	jb ELSE1 ; jump if below(unsigned)
	add eax,37h 
	jmp COMPARE2 ; jumps to the next compare for the right 8-bit number

	ELSE1:
		add eax,30h

	COMPARE2:
		cmp bl,0Ah ; comparing the right 8-bit number to see if need to add +37h or +30h
		jb ELSE2
		add ebx,37h
		ret
	
	ELSE2:
		add ebx,30h
		ret
ConvertToASCII ENDP


;---------------------------------------------------------------------------------------------------
DisplayOutput PROC
;
; This procedure displays the output that is needed for this program(X, Y, sum, difference, flags).
; Receives: EDX
; unsigned
; Returns: nothing
; Requires: nothing
;---------------------------------------------------------------------------------------------------
	call WriteString
	ret
DisplayOutput ENDP


;---------------------------------------------------------------------------------------------------
OverflowTest PROC
;
; This procedure checks for the sum and difference if there was any  overflow flags.
; Receives: cl, dl
; unsigned
; Returns: Puts corresponding 0 or 1 to respective overflow flags in the strToPrint2 string
; Requires: nothing
;---------------------------------------------------------------------------------------------------
	;OVERFLOWTEST
		cmp cl,80h
		jb POSITIVENUMBER1 ; X is positive
		cmp dl,80h
		jb POSITIVENUMBER2 ; X is negative, Y is positive
		add cl,dl
		cmp cl,80h
		jb SETOVERFLOW ; jumps to SETOVERFLOW because X,Y are negative and X+Y is positive
		mov strToPrint2+27, "0" 
		ret

	POSITIVENUMBER1:
		cmp dl,80h
		jb POSITIVENUMBERXY ; X and Y are both positive
		mov strToPrint2+27, "0" 
		ret

	POSITIVENUMBER2:
		mov strToPrint2+27, "0" 
		ret

	POSITIVENUMBERXY:
		add cl,dl
		cmp cl,80h
		jge SETOVERFLOW
		mov strToPrint2+27, "0" 
		ret

	SETOVERFLOW:
		mov strToPrint2+27,"1"
		ret
OverflowTest ENDP

end main



;Output results:
;X is CA
;Y is EB
;X+Y is B5 with c-flag(1) and o-flag(0)
;X-Y is DF with c-flag(0) and o-flag(0)
;
;X is 46
;Y is 74
;X+Y is BA with c-flag(0) and o-flag(1)
;X-Y is D2 with c-flag(1) and o-flag(0)
;
;X is CB
;Y is 37
;X+Y is 02 with c-flag(1) and o-flag(0)
;X-Y is 94 with c-flag(0) and o-flag(0)
