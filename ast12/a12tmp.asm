; *****************************************************************
;  Name: Chayden Richardson
;  NSHE ID: 2000735977
;  Section: 1002
;  Assignment: 12
;  Description: 

; -----
;  Narcissistic Numbers
;	0, 1, 2, 3, 4, 5,
;	6, 7, 8, 9, 153,
;	370, 371, 407, 1634, 8208,
;	9474, 54748, 92727, 93084, 548834,
;	1741725, 4210818, 9800817, 9926315, 24678050,
;	24678051, 88593477, 146511208, 472335975, 534494836,
;	912985153, 4679307774, 32164049650, 32164049651

; ***************************************************************

section	.data

; -----
;  Define standard constants.

LF		equ	10			; line feed
NULL		equ	0			; end of string
ESC		equ	27			; escape key

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; call code for read
SYS_write	equ	1			; call code for write
SYS_open	equ	2			; call code for file open
SYS_close	equ	3			; call code for file close
SYS_fork	equ	57			; call code for fork
SYS_exit	equ	60			; call code for terminate
SYS_creat	equ	85			; call code for file open/create
SYS_time	equ	201			; call code for get time

; -----
;  Globals (used by threads)

currentIndex	dq	0
myLock		dq	0
BLOCK_SIZE	dq	1000

; -----
;  Local variables for thread function(s).

msgThread1	db	" ...Thread starting...", LF, NULL

; -----
;  Local variables for getUserArgs function

LIMITMIN	equ	1000
LIMITMAX	equ	4000000000

errUsage	db	"Usgae: ./narCounter -t <1|2|3|4|5|6> ",
		db	"-l <septNumber>", LF, NULL
errOptions	db	"Error, invalid command line options."
		db	LF, NULL
errLSpec	db	"Error, invalid limit specifier."
		db	LF, NULL
errLValue	db	"Error, limit out of range."
		db	LF, NULL
errTSpec	db	"Error, invalid thread count specifier."
		db	LF, NULL
errTValue	db	"Error, thread count out of range."
		db	LF, NULL
		
; -----
;  Local variables for sept2int function

qSeven		dq	7
tmpNum		dq	0

; ***************************************************************

section	.text

; ******************************************************************
;  Thread function, numberTypeCounter()
;	Detemrine if narcissisticCount for all numbers between
;	1 and userLimit (gloabally available)

; -----
;  Arguments:
;	N/A (global variable accessed)
;  Returns:
;	N/A (global variable accessed)

common	userLimit	1:8
common	narcissisticCount	1:8
common	narcissisticNumbers	100:8

global numberTypeCounter
numberTypeCounter:


ret






; ******************************************************************
;  Mutex lock
;	checks lock (shared gloabl variable)
;		if unlocked, sets lock
;		if locked, lops to recheck until lock is free

global	spinLock
spinLock:
	mov	rax, 1			; Set the EAX register to 1.

lock	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
					; This will always store 1 to the lock, leaving
					;  the previous value in the RAX register.

	test	rax, rax	        ; Test RAX with itself. Among other things, this will
					;  set the processor's Zero Flag if RAX is 0.
					; If RAX is 0, then the lock was unlocked and
					;  we just locked it.
					; Otherwise, RAX is 1 and we didn't acquire the lock.

	jnz	spinLock		; Jump back to the MOV instruction if the Zero Flag is
					;  not set; the lock was previously locked, and so
					; we need to spin until it becomes unlocked.
	ret

; ******************************************************************
;  Mutex unlock
;	unlock the lock (shared global variable)

global	spinUnlock
spinUnlock:
	mov	rax, 0			; Set the RAX register to 0.

	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
	ret

; ******************************************************************
;  Function getUserArgs()
;	Get, check, convert, verify range, and return the
;	sequential/parallel option and the limit.

;  Example HLL call:
;	stat = getUserArgs(argc, argv, &parFlag, &numberLimit)

;  This routine performs all error checking, conversion of ASCII/septenary
;  to integer, verifies legal range.
;  For errors, applicable message is displayed and FALSE is returned.
;  For good data, all values are returned via addresses with TRUE returned.

;  Command line format (fixed order):
;	-t <1|2|3|4|5|6> -l <septNumber>

; -----
;  Arguments:
;	1) ARGC, value						- rdi
;	2) ARGV, address					- rsi
;	3) thread count (dword), address	- rdx
;	4) user limit (qword), address		- rcx

; errUsage	db	"Usgae: ./narCounter -t <1|2|3|4|5|6> ",
; 		db	"-l <septNumber>", LF, NULL
; errOptions	db	"Error, invalid command line options."
; 		db	LF, NULL
; errLSpec	db	"Error, invalid limit specifier."
; 		db	LF, NULL
; errLValue	db	"Error, limit out of range."
; 		db	LF, NULL
; errTSpec	db	"Error, invalid thread count specifier."
; 		db	LF, NULL
; errTValue	db	"Error, thread count out of range."
; 		db	LF, NULL

global getUserArgs
getUserArgs:
push	rbp
mov		rbp, rsp
sub		rsp, 8

push	r12
push	r13
push	r14
push	r15

mov		r12, rdi	; holds argc
mov		r13, rsi	; holds argv
push	rcx
push	rdx			; push current addresses to stack

; check errUsage
cmp		r12, 1				; check if argc = 1
je		errUsage_			; jump to errUsage

; check errOptions
cmp		r12, 5
jne		errOptions_

; check errTSpec: argv[1] contains "-t"
mov		r14, qword[r13 + 8]
cmp		byte[r14], '-'
jne		errTSpec_
cmp		byte[r14 + 1], 't'
jne		errTSpec_
cmp		byte[r14 + 2], NULL
jne		errTSpec_

; check errTValue
mov		rax, 0		; clear return value
; mov		r10, 0		; set counter to 0
mov		r14, qword[r13 + 16]
sub		r14, '0'
cmp		r14, 1
jl		errTValue_
cmp		r14, 6
jg		errTValue_

; if successful, save thread count
pop		rdx
mov		qword[rdx], r14
push	rdx

; check errLSpec: argv[3] contains "-l"
mov		r14, qword[r13 + 24]
cmp		byte[r14], '-'
jne		errLSpec_
cmp		byte[r14 + 1], 'l'
jne		errLSpec_
cmp		byte[r14 + 2], NULL
jne		errLSpec_

; check errLValue
mov		rax, 0		; clear return value
mov		r10, 0		; set counter to 0
lea		r15, byte[rbp - 8]
mov		r9, qword[r13 + 32]

arg4Lp:
cmp		byte[r9 + r10], NULL
je		arg4Convert
mov		al, byte[r9 + r10]
mov		byte[r15 + r10], al
inc		r10
jmp		arg4Lp

arg4Convert:
mov		byte[r15 + r10], NULL
mov		rdi, r13
mov		rsi, rdx
call	aSept2int

;check if number converted properly
cmp		rax, FALSE
je		errLValue_

; check if value is in range
cmp		rax, LIMITMIN
jl		errLValue_

mov		r10, LIMITMAX
cmp		rax, r10
jg		errLValue_

; if successful, return limit
pop		rdx
pop		rcx
mov		qword[rcx], rax
push	rcx
push	rdx

; !!!!!! ERROR SECTION !!!!!!!!
errUsage_:
mov		rdi, errUsage
jmp		doneError

errOptions_:
mov		rdi, errOptions
jmp		doneError

errTSpec_:
mov		rdi, errTSpec
jmp		doneError

errTValue_:
mov		rdi, errTValue

errLSpec_:
mov		rdi, errLSpec
jmp		doneError

errLValue_:
mov		rdi, errLValue
; jmp		doneError

doneError:
call	printString
mov		rax, FALSE

doneSuccess:
pop		rdx
pop		rcx

pop		r15
pop		r14
pop		r13
pop		r12
mov		rsp, rbp
pop		rbp
ret






; ******************************************************************
;  Function: Check and convert ASCII/septenary to integer.

;  Example HLL Call:
;	bool = aSept2int(septStr, &num);



global aSept2int
aSept2int:
push 	rbx
push 	rcx
push 	rdx
push 	r12
push 	r13
push 	r14

mov 	r10, 0
mov 	r14, 0
mov 	rax, 0

jmp 	checkLength

spaces:
	cmp 	rax, 0		; ignore beginning whitespace
	jne 	convFail	; no whitespace, empty string
	inc 	r10

checkLength:
	mov 	r9, 0
	cmp 	r14, 50		; checks if string in range <50 chars
	je 		convFail	; if over, fail string

	mov 	r9b, byte[rdi + r10]	; grab current char
	mov 	rdx, 7		; base 7 multiplication
	cmp 	r9b, NULL	; check if null, 
	je 		convEnd		; if null, end of string

conv2Int:
	cmp 	r9b, ' '	
	je 		spaces
	sub 	r9b, '0'	; subtract 0 to get actual value of char
	cmp 	r9b, 0		; < 0, fail string, bad character
	jl 		convFail
	cmp 	r9b, 7		; > 7 fail string, over range. not base 7
	jg 		convFail
	mul 	rdx			; multiply current sum
	add 	rax, r9		; add value to sum
	inc 	r14			; setup next loop
	inc 	r10
	jmp 	checkLength

convSuccess:
	mov 	dword[rsi], eax	; return value of septnum
	mov 	rax, TRUE		; true flag
	jmp 	convEnd

convFail:
	mov 	rax, FALSE		; fail flag, string failed

convEnd:
	pop 	r14
	pop 	r13
	pop 	r12
	pop 	rdx
	pop 	rcx
	pop 	rbx

ret






; ******************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:
	push	rbx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; EDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rbx
	ret

; ******************************************************************

