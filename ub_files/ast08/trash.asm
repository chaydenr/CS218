global	shellSort
shellSort:
push r11
push r12
push r13
push r14
push r15
push rdx

mov dword[len], esi

;	h = 1;
mov dword[h], 1
;   while ( (h*3+1) < a.length) {
;	    h = 3 * h + 1;
;	}

whileLp1:
	mov eax, dword[h]
	mov r14, 3
	imul r14d
	inc rax
	cmp eax, dword[len]
	jg whileLp2
	mov dword[h], eax
	jmp whileLp1
 
whileLp2:
;while( h > 0 ) {

	;for (i = h-1; i < a.length; i++) {
		mov r10d, dword[h]
		dec r10
		mov dword[i], r10d ; i = h - 1
	forLp1:
		mov r14, 0			; clear r14 each loop
		mov r14d, dword[i]
		cmp r14d, dword[len] ; i < a.length
		jge divH

	;   tmp = a[i];
	movsxd r11, dword[rdi + (r14 * 4)]
	mov dword[tmp], r11d
	;   j = i;
	mov dword[j], r14d

		;for( j = i; (j >= h) && (a[j-h] < tmp); j -= h) {
		forLp2:
			mov r14, 0
			mov r14d, dword[j]
			cmp r14d, dword[h]
			jl breakForLp2 		; (j>=h)

			sub r14d, dword[h]
			mov r12d, dword[rdi + (r14 * 4)] 
			cmp r12d, dword[tmp]
			jge	breakForLp2		; && (a[j-h] < tmp)

		;   a[j] = a[j-h];
			mov r13d, dword[j]
			mov dword[rdi + r13 * 4], r12d

			; j = j-h
			mov dword[j], r14d
			jmp forLp2
		;}

	breakForLp2:

	;   a[j] = tmp;
	movsxd r11, dword[tmp]
	mov r14d, dword[j]
	mov dword[rdi + r14*4], r11d

	inc dword[i] ; i++ for loop requirements
	jmp forLp1
	;}

divH:
;h = h / 3;
mov rax, 0
mov rdx, 0
mov eax, dword[h]
mov r15, 3
idiv r15d
mov dword[h], eax

; !!!!!!! COMPARE H TO 0 FOR INITIAL LOOP !!!!!!!
cmp eax, 0  ; while h > 0, go to whileLp2
jg whileLp2 ; else, break
;}

; shellSort closing callframe
pop rdx
pop r15
pop r14
pop r13
pop r12
pop r11

ret