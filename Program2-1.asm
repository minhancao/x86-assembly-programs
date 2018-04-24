TITLE Program2           (Program2.asm)
; This program adds and subtracts the values in X and Y
; and displays the c-flag and o-flag for the arithmetic operation(8-bit).
;
; Programmer : Minh An Cao
; Last date modified : 8/8/2017

INCLUDE Irvine32.inc

.data
counter BYTE 0h ; for looping
valX BYTE 0CAh, 046h, 0CBh
valY BYTE 0EBh, 074h, 037h
xIs BYTE "X is ", 0
yIs BYTE "Y is ", 0
strToPrint BYTE "X+Y is ??", 0
strToPrint2 BYTE " with c-flag(?) and o-flag(?)", 0 ; c and o-flags are defaultly 0, will change if needed
strToPrint3 BYTE "X-Y is ??", 0

.code
main PROC
	mov counter,LENGTHOF valX
	mov esi,0 ; to traverse the numbers in valX and valY

	MYLOOP:
		mov edx,OFFSET xIs
		call WriteString
		mov ebx,1 ; 1 is byte and is put here so when WriteHexB is called it'll print in byte
		mov al, valX[esi]
		call WriteHexB ; prints whatever is in eax

		call crlf	; newline

		mov edx,OFFSET yIs
		call WriteString
		mov al, valY[esi]
		call WriteHexB ; prints whatever is in eax

		call crlf	; newline
	
		mov eax,0
		mov ebx,0
		mov al,valX[esi]
		mov bl,valY[esi]
		adc eax,ebx ; adds with carry if there is a carry

		mov bl,al
		shr al,4  ; to get the left 8-bit number
		and bl,00Fh ; to get the right 8-bit number

		cmp al,0Ah ; comparing the left 8-bit number to see if need to add +37h or +30h
		jb ELSE1 ; jump if below(unsigned)
		add eax,37h 
		mov strToPrint+7,al
		jmp COMPARE2 ; jumps to the next compare for the right 8-bit number

		ELSE1:
			add eax,30h
			mov strToPrint+7,al

		COMPARE2:
			cmp bl,0Ah ; comparing the right 8-bit number to see if need to add +37h or +30h
			jb ELSE2
			add ebx,37h
			mov strToPrint+8,bl
			mov edx,OFFSET strToPrint
			call WriteString
			jmp END1
		
		
		ELSE2:
			add ebx,30h
			mov strToPrint+8,bl
			mov edx,OFFSET strToPrint
			call WriteString
			jmp END1
	
		END1:
			cmp ah,00h ; compares to see if there was carry flag set
			jg SETCARRY ; jumps to SETCARRY statement if there was something in ah(ah>0)
			mov strToPrint2+13, "0" ; puts 0 because there was not a carry
			jmp OVERFLOWTEST

		SETCARRY:
			mov strToPrint2+13, "1" ; puts 1 because there was a carry
			jmp OVERFLOWTEST

		OVERFLOWTEST:
			mov cl,valX[esi]
			mov dl,valY[esi]
			cmp cl,80h
			jb POSITIVENUMBER1 ; X is positive
			cmp dl,80h
			jb POSITIVENUMBER2 ; X is negative, Y is positive
			add cl,dl
			cmp cl,80h
			jb SETOVERFLOW ; jumps to SETOVERFLOW because X,Y are negative and X+Y is positive
			mov strToPrint2+27, "0" 
			jmp NOOVERFLOWEND


		POSITIVENUMBER1:
			cmp dl,80h
			jb POSITIVENUMBERXY ; X and Y are both positive
			jmp NOOVERFLOWEND ; no overflow flag because X is positive and Y is negative

		POSITIVENUMBER2:
			jmp NOOVERFLOWEND

		POSITIVENUMBERXY:
			add cl,dl
			cmp cl,80h
			jge SETOVERFLOW
			jmp NOOVERFLOWEND

		SETOVERFLOW:
			mov strToPrint2+27,"1"
			jmp NOOVERFLOWEND
	
		NOOVERFLOWEND:
			mov edx,OFFSET strToPrint2
			call WriteString
			jmp SUBSTRACTION
	

	
		SUBSTRACTION:
		call crlf	; newline

		mov strToPrint2+27,"0" ; sets o-flag back to 0
		mov eax,0
		mov ebx,0
		mov al,valX[esi]
		mov bl,valY[esi]
		not bl ; getting 2's complement for Y
		add bl,1 ; getting 2's complement for Y
		adc eax,ebx

		mov bl,al
		shr al,4  ; to get the left 8-bit number
		and bl,00Fh ; to get the right 8-bit number

		cmp al,0Ah ; comparing the left 8-bit number to see if need to add +37h or +30h
		jb ELSES1 ; jump if below(compares unsigned)
		add eax,37h
		mov strToPrint3+7,al
		jmp COMPARES2 ; jumps to the next compare for the right 8-bit number

		ELSES1:
			add eax,30h
			mov strToPrint3+7,al

		COMPARES2:
			cmp bl,0Ah ; comparing the right 8-bit number to see if need to add +37h or +30h
			jb ELSES2 
			add ebx,37h 
			mov strToPrint3+8,bl
			mov edx,OFFSET strToPrint3
			call WriteString
			jmp END2
		
		
		ELSES2:
			add ebx,30h
			mov strToPrint3+8,bl
			mov edx,OFFSET strToPrint3
			call WriteString
			jmp END2
	
		END2:
			cmp strToPrint2+13,030h ; compares the carry flag from addition earlier with ascii value "0"
			je SETCARRY2 ; jumps to set the carry flag to "1" if addition's flag was "0"
			mov strToPrint2+13,"0" ; else if addition's flag was "1" we set it to "0" for substraction here
			jmp OVERFLOWTEST2

		SETCARRY2:
			mov strToPrint2+13, "1"
			jmp OVERFLOWTEST2

		OVERFLOWTEST2:
			mov cl,valX[esi]
			mov dl,valY[esi]
			not dl ; getting 2's complement for Y
			add dl,1 ; getting 2's complement for Y
			cmp cl,80h
			jb POSITIVENUMBER1S ; X is positive
			cmp dl,80h
			jb POSITIVENUMBER2S ; X is negative, Y is positive
			add cl,dl
			cmp cl,80h
			jb SETOVERFLOW2 ; jumps to SETOVERFLOW because X,Y are negative and X+Y is positive
			mov strToPrint2+27, "0" 
			jmp NOOVERFLOWEND2


		POSITIVENUMBER1S:
			cmp dl,80h
			jb POSITIVENUMBERXYS ; X and Y are both positive
			jmp NOOVERFLOWEND2 ; no overflow flag because X is positive and Y is negative

		POSITIVENUMBER2S:
			jmp NOOVERFLOWEND2

	
		POSITIVENUMBERXYS:
			add cl,dl
			cmp cl,80h
			jge SETOVERFLOW2
			jmp NOOVERFLOWEND2

		SETOVERFLOW2:
			mov strToPrint2+27,"1"
			jmp NOOVERFLOWEND2
	
		NOOVERFLOWEND2:
			mov edx,OFFSET strToPrint2
			call WriteString
			call crlf	; newline
			call crlf	; newline

			inc esi
			dec counter
			mov ecx,0
			mov cl, counter ; puts counter back into cl(ecx)
	jne MYLOOP ; jump if not equal

	exit

main endp

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



