; *****************************************************************
;  Name: Chayden Richardson
;  NSHE ID: 2000735977
;  Section: 1002
;  Assignment: 8
;  Description: This program will use several functions to sort a list,
;  find the max, min, median, sum, average, and the linear regression
;  between two lists.


; -----------------------------------------------------------------
;  Write some assembly language functions.

;  The function, shellSort(), sorts the numbers into descending
;  order (large to small).  Uses the shell sort algorithm from
;  assignment #7 (modified to sort in descending order).

;  The function, basicStats(), finds the minimum, median, and maximum,
;  sum, and average for a list of numbers.
;  Note, the median is determined after the list is sorted.
;	This function must call the lstSum() and lstAvergae()
;	functions to get the corresponding values.
;	The lstAvergae() function must call the lstSum() function.

;  The function, linearRegression(), computes the linear regression of
;  the two data sets.  Summation and division performed as integer.

; *****************************************************************

section	.data

; -----
;  Define constants.

TRUE		equ	1
FALSE		equ	0

; -----
;  Local variables for shellSort() function (if any).

h		dd	0
i		dd	0
j		dd	0
tmp		dd	0
len		dd 	0

; -----
;  Local variables for basicStats() function (if any).

tmpXAve	dq	0
tmpYAve dq  0
lrNum	dq	0
lrDen   dq  0

; -----------------------------------------------------------------

section	.bss

; -----
;  Local variables for linearRegression() function (if any).

qSum		resq	1
dSum		resd	1


; *****************************************************************

section	.text

; --------------------------------------------------------
;  Shell sort function (form asst #7).
;	Updated to sort in descending order.

; -----
;  HLL Call:
;	call shellSort(list, rsi)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi

;  Returns:
;	sorted list (list passed by reference)

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


; global	shellSort
; shellSort:
; push rbp
; mov rbp, rsp
; sub rsp, 20
; rbp - 0  = h
; rbp - 4  = i
; rbp - 8  = j
; rbp - 12 = tmp
; rbp - 16 = len

; push r11
; push r12
; push r13
; push r14
; push r15
; push rdx

; mov dword[rbp - 16], esi

; ;	h = 1;
; mov dword[rbp - 0], 1
; ;   while ( (h*3+1) < a.length) {
; ;	    h = 3 * h + 1;
; ;	}

; whileLp1:
; 	mov eax, dword[rbp - 0]
; 	mov r14, 3
; 	imul r14d
; 	inc rax
; 	cmp eax, dword[rbp - 16]
; 	jg whileLp2
; 	mov dword[rbp - 0], eax
; 	jmp whileLp1
 
; whileLp2:
; ;while( h > 0 ) {

; 	;for (i = h-1; i < a.length; i++) {
; 		mov r10d, dword[rbp - 0]
; 		dec r10
; 		mov dword[rbp - 4], r10d ; i = h - 1
; 	forLp1:
; 		mov r14, 0			; clear r14 each loop
; 		mov r14d, dword[rbp - 4]
; 		cmp r14d, dword[rbp - 16] ; i < a.length
; 		jge divH

; 	;   tmp = a[i];
; 	movsxd r11, dword[rdi + (r14 * 4)]
; 	mov dword[rbp - 12], r11d
; 	;   j = i;
; 	mov dword[rbp - 8], r14d

; 		;for( j = i; (j >= h) && (a[j-h] < tmp); j -= h) {
; 		forLp2:
; 			mov r14, 0
; 			mov r14d, dword[rbp - 8]
; 			cmp r14d, dword[rbp - 0]
; 			jl breakForLp2 		; (j>=h)

; 			sub r14d, dword[rbp - 0]
; 			mov r12d, dword[rdi + (r14 * 4)] 
; 			cmp r12d, dword[rbp - 12]
; 			jle	breakForLp2		; && (a[j-h] < tmp)

; 		;   a[j] = a[j-h];
; 			mov r13d, dword[rbp - 8]
; 			mov dword[rdi + r13 * 4], r12d

; 			; j = j-h
; 			mov dword[rbp - 8], r14d
; 			jmp forLp2
; 		;}

; 	breakForLp2:

; 	;   a[j] = tmp;
; 	movsxd r11, dword[rbp - 12]
; 	mov r14d, dword[rbp - 8]
; 	mov dword[rdi + r14*4], r11d

; 	add dword[rbp - 4], 1 ; i++ for loop requirements
; 	jmp forLp1
; 	;}

; divH:
; ;h = h / 3;
; mov rax, 0
; mov rdx, 0
; mov eax, dword[rbp - 0]
; mov r15, 3
; idiv r15d
; mov dword[rbp - 0], eax

; ; !!!!!!! COMPARE H TO 0 FOR INITIAL LOOP !!!!!!!
; cmp eax, 0  ; while h > 0, go to whileLp2
; jg whileLp2 ; else, break
; ;}

; ; shellSort closing callframe
; pop rdx
; pop r15
; pop r14
; pop r13
; pop r12
; pop r11

; mov rsp, rbp
; pop rbp
; ret 

; --------------------------------------------------------
;  Find basic statistical information for a list of integers:
;	minimum, median, maximum, sum, and average

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  This function must call the lstSum() and lstAvergae() functions
;  to get the corresponding values.

;  Note, assumes the list is already sorted.

; -----
;  Call:
;	call basicStats(list, rsi, min, med, max, sum, ave)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi
;	3) minimum, addr - rdx
;	4) median, addr - rcx
;	5) maximum, addr - r8
;	6) sum, addr - r9
;	7) ave, addr - rcx

;  Returns:
;	minimum, median, maximum, sum, and average
;	via pass-by-reference (addresses on stack)

global basicStats
basicStats:
; get sum
push rax
call lstSum
mov dword[r9], eax
pop rax

; get ave
push rax
call lstAve
mov r9d, eax
pop rax
mov dword[rax], r9d

; get max
movsxd r10, dword[rdi]
add qword[r8], r10

; get min
mov r11, rsi
dec r11
movsxd r10, dword[rdi + (r11 * 4)]
add qword[rdx], r10

; get median
push rax
push rdx

mov rdx, 0
mov rax, rsi
mov r11, 2
idiv r11
cmp rdx, 0
je evenList

movsxd r10, dword[rdi + (rax * 4)]
mov dword[rcx], r10d
jmp medDone

evenList:
mov r10, rax
movsxd rax, dword[rdi + (r10 * 4)]
dec r10
add eax, dword[rdi + (r10 * 4)]
mov r10, 2
mov rdx, 0
idiv r10d
mov dword[rcx], eax

medDone:
pop rdx
pop rax

ret

; --------------------------------------------------------
;  Function to calculate the sum of a list.

; -----
;  Call:
;	ans = lstSum(rdi, rsi)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	sum (in eax)


global	lstSum
lstSum:
push rcx
push r10
push r11

mov rax, 0
; Start of list sum
mov     ecx, esi          ; loop counter
mov     r10, 0                      ; clear register

lpSum:
    movsxd     r11, dword[rdi + r10]   ; move current list item into eax for add
    add     r10, 4                  ; increment for next loop
    add     eax, r11d      ; add item to sum
    loop    lpSum

pop r11
pop r10
pop rcx

ret

; --------------------------------------------------------
;  Function to calculate the average of a list.
;  Note, must call the lstSum() fucntion.

; -----
;  Call:
;	ans = lstAve(rdi, rsi)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	average (in eax)


global	lstAve
lstAve:
push rdx
push r12
push r13

push rax
call lstSum
mov rdx, 0
movsxd r12, esi
idiv r12d
mov r13d, eax
pop rax

mov eax, r13d

pop r13
pop r12
pop rdx
ret

; --------------------------------------------------------
;  Function to calculate the linear regression
;  between two lists (of equal size).
;  Due to the data sizes, the summation for the dividend (top)
;  MUST be performed as a quad-word.

; -----
;  Call:
;	linearRegression(xList, yList, rsi, xAve, yAve, b0, b1)

;  Arguments Passed:
;	1) xList, address - rdi
;	2) yList, address - rsi
;	3) length, value - edx
;	4) xList average, value - ecx
;	5) yList average, value - r8d
;	6) b0, address - r9
;	7) b1, address - rax

;  Returns:
;	b0 and b1 via reference

global linearRegression
linearRegression:
push rax

; reset variables
mov qword[tmpXAve], 0
mov qword[tmpYAve], 0
mov qword[lrDen], 0
mov qword[lrNum], 0

mov dword[tmpXAve], ecx
mov dword[tmpYAve], r8d

mov ecx, edx ; save length
dec rcx 

b1Lp:
;denominator calculations
movsxd rax, dword[rdi + rcx * 4]
sub rax, qword[tmpXAve]
imul eax
add dword[lrDen], eax

;numerator calculations
; (xi - x)
movsxd rax, dword[rdi + rcx * 4]
sub rax, qword[tmpXAve]
; (yi - x)
movsxd r11, dword[rsi + rcx * 4]
sub r11, qword[tmpYAve]
; (xi-x)(yi-y)
imul r11d
; sum
add dword[lrNum], eax
adc dword[lrNum + 4], edx

dec rcx
cmp rcx, 0
jge b1Lp
; loop b1Lp

; setup numerator for division
mov eax, dword[lrNum]
mov edx, dword[lrNum + 4]

idiv dword[lrDen]

mov r11, 0
mov r11d, eax
pop rax
mov dword[rax], r11d

;b0 calculations
mov eax, r11d
imul dword[tmpXAve]
sub dword[tmpYAve], eax
mov r11d, dword[tmpYAve]
mov dword[r9], r11d

ret

; ********************************************************************************

