; *****************************************************************
;  Name: Grace Gabrielson
;  NSHE ID: 2001528396
;  Section: 1002
;  Assignment: 8
;  Description: Learn assembly language procedures.  Additionally, become more familiar with program control instructions, function handling, and stacks.


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
h dd 0
i dd 0
j dd 0
tmp dd 0
len dd 0
jMinH dd 0
three dw 3

; -----
;  Local variables for basicStats() function (if any).


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
;	call shellSort(list, len)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi

;  Returns:
;	sorted list (list passed by reference)

global	shellSort
shellSort:

;h = 1;
;while ( (h*3+1) < length ) {
;   h = 3 * h + 1;
;}
;while ( h>0 ) {
;   for (i = h-1; i < length; i++) {
;       tmp = lst[i];
;       j = i;
;       for ( j=i; (j >= h) && (lst[j-h] >
; tmp); j = j-h) {
;          lst[j] = lst[j-h];
;       }
;       lst[j] = tmp;
;   }
;   h = h / 3;
;}
;	YOUR CODE GOES HERE
	push rdi
	push rsi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push rax
	push rbx
	push rcx
	push rdx

	;eax for h
	;ebx for i
	;ecx for j
	mov dword[len], esi 
	mov r10d, dword[tmp]

	add eax, 1

	whileHLessLength:
		cmp eax, dword[len]
		jge whileHLessLengthDone
		; jmp whileHLessLengthDone
		mov r8d, 3
		imul rax, r8
		add rax, 1
		jmp whileHLessLength
	
	whileHLessLengthDone:
		mov dword[h], r15d
		jmp whileHGreaterZero
	whileHGreaterZero:
		mov r14d, r15d
		; sub r14d, 1
		dec r14
		mov dword[i], r14d

		forLoop1:
			cmp r14d, esi  ;i > length
			jg forLoop1Done

			movsxd r10, dword[rdi + r14 * 4]
			mov dword[tmp], r10d
			mov r13d, dword[i]
			mov dword[j], r13d ;j = i
			mov r13d, dword[j]

		forLoop2:
			cmp r13d, dword[h] ;j>=h
			jl forLoop2Done

			;j-h
			mov dword[h], eax
			movsxd r12, dword[j]
			mov dword[jMinH], r12d
			sub dword[jMinH], r15d
			mov r11d, dword[jMinH]

			movsxd r12, dword[rdi+r11*4]
			cmp r10d, dword[rdi+r11*4] ;compare lst[j-h] and temp
			jl forLoop2Done

			mov dword[rdi + r13 * 4], r12d

			sub dword[j], eax ;j = j-h
			mov r13d, dword[j]

			jmp forLoop2
		forLoop2Done:
			mov dword[rdi+r13*4], r10d
			inc rbx
			mov dword[i], r14d
			jmp forLoop1
		
		forLoop1Done:
			mov eax, 0
			mov edx, 0
			mov eax,  r15d
			idiv word[three]
			mov r15d, eax
			mov dword[h], r15d
			jmp whileHGreaterZero 
	whileHGreaterZeroDone:

	pop rdx
	pop rcx
	pop rbx
	pop rax
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop rsi
	pop rdi
	ret

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
;	call basicStats(list, len, min, med, max, sum, ave)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi
;	3) minimum, addr - rdx
;	4) median, addr - rcx
;	5) maximum, addr - r8
;	6) sum, addr - r9
;	7) ave, addr - stack, rbp+16

;  Returns:
;	minimum, median, maximum, sum, and average
;	via pass-by-reference (addresses on stack)

global basicStats
basicStats:

;	YOUR CODE GOES HERE
	push rbp
	mov rbp, rsp

	push rbx
	push r12
	push r13
	push r14

	;calculate the minimum
	mov eax, dword[rdi]
	mov dword[rdx], eax

	;calculate the maximum
	mov r10, 0
	mov r10, rsi
	dec r10
	mov eax, dword[rdi + r10 * 4]
	mov dword[r8], eax

	mov rbx, rdi  ;for the list
	mov r12d, esi ;for the length
	mov r13, r9   ;for the sum
	mov r14, rcx  ;for the average

	;calculate the sum
		;registers
	mov rdi, rbx
	mov esi, r12d
		;function call
	call lstSum
	mov dword[r13], eax


	;calculate the average
		;registers
	mov rdi, rbx
	mov esi, r12d

	call lstAve
	mov dword[r14], eax


	;calculate the median
	mov rcx, 2
	mov edx, 0
	mov rax, rsi 
	div rcx

	cmp edx, 0
	jne odd

	mov r8d, dword[rdi + rax * 4]
	dec eax

	odd:
		mov r9d, dword[rdi + rax * 4]
		mov eax, r9d
		cmp edx, 0
		jne odd2
		add r8d, r9d
		mov eax, r8d
		cdq
		idiv rcx
	odd2:


	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
ret
; --------------------------------------------------------
;  Function to calculate the sum of a list.

; -----
;  Call:
;	ans = lstSum(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	sum (in eax)


global	lstSum
lstSum:


;	YOUR CODE GOES HERE
	mov rdx, rdi
	mov rcx, rsi
	mov eax, 0
	
	sumLoop:
		mov r8d, dword[rdx]
		add eax, r8d
		add rdx, 4
	loop sumLoop


	ret

; --------------------------------------------------------
;  Function to calculate the average of a list.
;  Note, must call the lstSum() fucntion.

; -----
;  Call:
;	ans = lstAve(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	average (in eax)


global	lstAve
lstAve:


;	YOUR CODE GOES HERE
	mov rdx, rdi
	mov rcx, rsi
	mov eax, 0

	aveLoop:
		mov r8d, dword[rdx]
		add eax, r8d
		add rdx, 4
	loop aveLoop
	cdq
	idiv esi

	ret

; --------------------------------------------------------
;  Function to calculate the linear regression
;  between two lists (of equal size).
;  Due to the data sizes, the summation for the dividend (top)
;  MUST be performed as a quad-word.

; -----
;  Call:
;	linearRegression(xList, yList, len, xAve, yAve, b0, b1)

;  Arguments Passed:
;	1) xList, address - rdi
;	2) yList, address - rsi
;	3) length, value - edx
;	4) xList average, value - ecx
;	5) yList average, value - r8d
;	6) b0, address - r9
;	7) b1, address - stack, rpb+16

;  Returns:
;	b0 and b1 via reference

global linearRegression
linearRegression:


;	YOUR CODE GOES HERE
	

	ret

; ********************************************************************************

