; *****************************************************************
;  Name: Chayden Richardson
;  NSHE ID: 2000735977
;  Section: 1002
;  Assignment: 9
;  Description: 

;  -----------------------------------------------------------------------------
;  Write assembly language functions.

;  Function, shellSort(), sorts the numbers into ascending
;  order (small to large).  Uses the shell sort algorithm
;  modified to sort in ascending order.

;  Function lstSum() to return the sum of a list.

;  Function lstAverage() to return the average of a list.
;  Must call the lstSum() function.

;  Fucntion basicStats() finds the minimum, median, and maximum,
;  sum, and average for a list of numbers.
;  The median is determined after the list is sorted.
;  Must call the lstSum() and lstAverage() functions.

;  Function linearRegression() computes the linear regression.
;  for the two data sets.  Must call the lstAverage() function.

;  Function readSeptNum() should read a septenary number
;  from the user (STDIN) and perform apprpriate error checking.


; ******************************************************************************

section	.data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  Define program specific constants.

SUCCESS 	    equ	0
NOSUCCESS	    equ	1
OUTOFRANGEMIN	equ	2
OUTOFRANGEMAX	equ	3
INPUTOVERFLOW	equ	4
ENDOFINPUT	    equ	5

LIMIT		equ	1510

MIN		equ	-100000
MAX		equ	100000

BUFFSIZE	equ	50			; 50 chars including NULL

; -----
;  NO static local variables allowed...


; ******************************************************************************

section	.text

; -----------------------------------------------------------------------------
;  Read an ASCII septenary number from the user.

;   Return codes:
;	SUCCESS			Successful conversion
;	NOSUCCESS		Invalid input entered
;	OUTOFRANGEMIN		Input below minimum value
;	OUTOFRANGEMAX		Input above maximum value
;	INPUTOVERFLOW		User entry character count exceeds maximum length
;	ENDOFINPUT		End of the input

; -----
;  Call:
;	status = readSeptNum(&numberRead);

;  Arguments Passed:
;	1) numberRead, addr - rdi

;  Returns:
;	number read (via reference)
;	status code (as above)


global readSeptNum
readSeptNum:

mov qword[rdi], 0
mov rax, SUCCESS

ret

; -----------------------------------------------------------------------------
;  Shell sort function.

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
push rbp
mov rbp, rsp
sub rsp, 20
; rbp - 0  = h
; rbp - 4  = i
; rbp - 8  = j
; rbp - 12 = tmp
; rbp - 16 = len

push r11
push r12
push r13
push r14
push r15
; push rax ; NEW!!!!
push rdx

mov dword[rbp - 16], esi

;	h = 1;
mov dword[rbp - 0], 1
;   while ( (h*3+1) < a.length) {
;	    h = 3 * h + 1;
;	}

whileLp1:
	mov eax, dword[rbp - 0]
	mov r14, 3
	imul r14d
	inc rax
	cmp eax, dword[rbp - 16]
	jg whileLp2
	mov dword[rbp - 0], eax
	jmp whileLp1
 
whileLp2:
;while( h > 0 ) {

	;for (i = h-1; i < a.length; i++) {
		mov r10d, dword[rbp - 0]
		dec r10
		mov dword[rbp - 4], r10d ; i = h - 1
	forLp1:
		mov r14, 0			; clear r14 each loop
		mov r14d, dword[rbp - 4]
		cmp r14d, dword[rbp - 16] ; i < a.length
		jge divH

	;   tmp = a[i];
	movsxd r11, dword[rdi + (r14 * 4)]
	mov dword[rbp - 12], r11d
	;   j = i;
	mov dword[rbp - 8], r14d

		;for( j = i; (j >= h) && (a[j-h] > tmp); j -= h) {
		forLp2:
			mov r14, 0
			mov r14d, dword[rbp - 8]
			cmp r14d, dword[rbp - 0]
			jl breakForLp2 		; (j>=h)

			sub r14d, dword[rbp - 0]
			mov r12d, dword[rdi + (r14 * 4)] 
			cmp r12d, dword[rbp - 12]
			jle	breakForLp2		; && (a[j-h] > tmp), sorts in ascending order

		;   a[j] = a[j-h];
			mov r13d, dword[rbp - 8]
			mov dword[rdi + r13 * 4], r12d

			; j = j-h
			mov dword[rbp - 8], r14d
			jmp forLp2
		;}

	breakForLp2:

	;   a[j] = tmp;
	movsxd r11, dword[rbp - 12]
	mov r14d, dword[rbp - 8]
	mov dword[rdi + r14*4], r11d

	add dword[rbp - 4], 1 ; i++ for loop requirements
	jmp forLp1
	;}

divH:
;h = h / 3;
mov rax, 0
mov rdx, 0
mov eax, dword[rbp - 0]
mov r15, 3
idiv r15d
mov dword[rbp - 0], eax

; !!!!!!! COMPARE H TO 0 FOR INITIAL LOOP !!!!!!!
cmp eax, 0  ; while h > 0, go to whileLp2
jg whileLp2 ; else, break
;}

; shellSort closing callframe
pop rdx
; pop rax ; !!!! NEW !!!!
pop r15
pop r14
pop r13
pop r12
pop r11

mov rsp, rbp
; add rbp, 8160
pop rbp
ret 

; -----------------------------------------------------------------------------
;  Find basic statistical information for a list of integers:
;	minimum, median, maximum, sum, and average

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  This function must call the lstSum() and lstAvergae() functions
;  to get the corresponding values.

;  Note, assumes the list is already sorted.

; -----
;  HLL Call:
;	call basicStats(list, len, min, med, max, sum, ave)

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


; -----------------------------------------------------------------------------
;  Function to calculate the sum of a list.

; -----
;  Call:
;	ans = lstSum(lst, len)

;  Arguments Passed:
;	1) list, address
;	2) length, value

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


; -----------------------------------------------------------------------------
;  Function to calculate the average of a list.
;  Note, must call the lstSum() fucntion.

; -----
;  Call:
;	ans = lstAve(lst, len)

;  Arguments Passed:
;	1) list, address
;	2) length, value

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


; -----------------------------------------------------------------------------
;  Function to calculate the linear regression
;  between two lists (of equal size).

; -----
;  Call:
;	linearRegression(xList, yList, len, xAve, yAve, b0, b1)

;  Arguments Passed:
;	1) xList, address
;	2) yList, address
;	3) length, value
;	4) xList average, value
;	5) yList average, value
;	6) b0, address
;	7) b1, address

;  Returns:
;	b0 and b1 via reference



global linearRegression
linearRegression:
push rax

push rbp
mov rbp, rsp
sub rsp, 32
; rbp - 0  = tmpXAve
; rbp - 8  = tmpYAve
; rbp - 16 = lrDen
; rbp - 24 = lrNum


; reset variables
mov qword[rbp - 0], 0
mov qword[rbp - 8], 0
mov qword[rbp - 16], 0
mov qword[rbp - 24], 0

mov dword[rbp - 0], ecx
mov dword[rbp - 8], r8d

mov ecx, edx ; save length
dec rcx 

b1Lp:
;denominator calculations
movsxd rax, dword[rdi + rcx * 4]
sub rax, qword[rbp - 0]
imul eax
add dword[rbp - 16], eax

;numerator calculations
; (xi - x)
movsxd rax, dword[rdi + rcx * 4]
sub rax, qword[rbp - 0]
; (yi - x)
movsxd r11, dword[rsi + rcx * 4]
sub r11, qword[rbp - 8]
; (xi-x)(yi-y)
imul r11d
; sum
add dword[rbp - 24], eax
adc dword[rbp - 28], edx

dec rcx
cmp rcx, 0
jge b1Lp
; loop b1Lp

; setup numerator for division
mov eax, dword[rbp - 24]
mov edx, dword[rbp - 28]

idiv dword[rbp - 16]

mov r11, 0
mov r11d, eax
pop rax
mov dword[rax], r11d

;b0 calculations
mov eax, r11d
imul dword[rbp - 0]
sub dword[rbp - 8], eax
mov r11d, dword[rbp - 8]
mov dword[r9], r11d

ret

; -----------------------------------------------------------------------------
