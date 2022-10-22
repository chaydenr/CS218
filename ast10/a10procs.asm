; *****************************************************************
;  Name: Chayden Richardson
;  NSHE ID: 2000735977
;  Section: 1002
;  Assignment: 10
;  Description:  This program will use an external library OpenGL
;  and will plot points to create a moving image. The user will type in
;  commands on the command line to specify color, speed, and image size. 
;  This is all done through various calculations using floating point 
;  registers and multiple function calls. 


; -----
;  Function: getParams
;	Gets, checks, converts, and returns command line arguments.

;  Function drawWheels()
;	Plots functions

; ---------------------------------------------------------

;	MACROS (if any) GO HERE


; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Define program specific constants.

SPD_MIN		equ	1
SPD_MAX		equ	50			; 101(7) = 50

CLR_MIN		equ	0
CLR_MAX		equ	0xFFFFFF		; 0xFFFFFF = 262414110(7)

SIZ_MIN		equ	100			; 202(7) = 100
SIZ_MAX		equ	2000			; 5555(7) = 2000

; -----
;  Local variables for getParams functions.

STR_LENGTH	equ	12

errUsage	db	"Usage: ./wheels -sp <septNumber> -cl <septNumber> "
		db	"-sz <septNumber>"
		db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line argument."
		db	LF, NULL

errSpdSpec	db	"Error, speed specifier incorrect."
		db	LF, NULL
errSpdValue	db	"Error, speed value must be between 1 and 101(7)."
		db	LF, NULL

errClrSpec	db	"Error, color specifier incorrect."
		db	LF, NULL
errClrValue	db	"Error, color value must be between 0 and 262414110(7)."
		db	LF, NULL

errSizSpec	db	"Error, size specifier incorrect."
		db	LF, NULL
errSizValue	db	"Error, size value must be between 202(7) and 5555(7)."
		db	LF, NULL

; -----
;  Local variables for drawWheels routine.

t		dq	0.0			; loop variable
s		dq	0.0
tStep		dq	0.001			; t step
sStep		dq	0.0
x		dq	0			; current x
y		dq	0			; current y
scale		dq	7500.0			; speed scale

fltZero		dq	0.0
fltOne		dq	1.0
fltTwo		dq	2.0
fltThree	dq	3.0
fltFour		dq	4.0
fltSix		dq	6.0
fltTwoPiS	dq	0.0

pi		dq	3.14159265358

fltTmp1		dq	0.0
fltTmp2		dq	0.0

red		dd	0			; 0-255
green		dd	0			; 0-255
blue		dd	0			; 0-255


; ------------------------------------------------------------

section  .text

; -----
; Open GL routines.

extern	glutInit, glutInitDisplayMode, glutInitWindowSize, glutInitWindowPosition
extern	glutCreateWindow, glutMainLoop
extern	glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern	glutSwapBuffers, gluPerspective, glutPostRedisplay
extern	glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern	glClear, glLoadIdentity, glMatrixMode, glViewport
extern	glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern	glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d

extern	cos, sin


; ******************************************************************
;  Function getParams()
;	Gets draw speed, draw color, and screen size
;	from the command line arguments.

;	Performs error checking, converts ASCII/septenary to integer.
;	Command line format (fixed order):
;	  "-sp <septNumber> -cl <septNumber> -sz <septyNumber>"

; -----
;  Arguments:
;	ARGC, double-word, value		- rdi
;	ARGV, double-word, address		- rsi
;	speed, double-word, address		- rdx
;	color, double-word, address		- rcx
;	size, double-word, address 		- r8

; Returns:
;	speed, color, and size via reference (of all valid)
;	TRUE or FALSE


global getParams
getParams:
push	rbp
mov		rbp, rsp
sub		rsp, 39

push	r9
push	r10
push	r12
push	r13
push	r15

; r12 holds argc value
mov		r12, rdi
; r9 setup to hold argv value
mov		r9, 0
; r15 holds argv[] address
mov		r15, rsi

push 	rdi
push	rsi

; check errUsage
cmp		r12, 1				; check if argc = 1
je		errUsage_			; jump to errUsage

; check errBadCL
cmp		r12, 7
jne		errBadCL_

; check errSpdSpec: argv[1] contains "-sp"
mov		r9, qword[r15 + 8]
cmp		byte[r9], '-'
jne		errSpdSpec_
cmp		byte[r9 + 1], 's'
jne		errSpdSpec_
cmp		byte[r9 + 2], 'p'
jne		errSpdSpec_
cmp		byte[r9 + 3], NULL
jne		errSpdSpec_

; check errSpdValue
mov		rax, 0
mov		r10, 0
lea		r13, byte[rbp - 17] ; grab address
mov		r9, qword[r15 + 16] ; grab value

arg2Lp:
cmp		byte[r9 + r10], NULL ; check if null
je		arg2Convert			; if null, end of string. convert
mov		al, byte[r9 + r10]  ; else, save character
mov		byte[r13 + r10], al
inc		r10
jmp		arg2Lp

arg2Convert:
mov		byte[r13 + r10], NULL ; add null to end of string
mov		rdi, r13			; setup conversion function
mov		rsi, rdx
call	aSept2int

; check if string converted properly
cmp		rax, FALSE
je		errSpdValue_

; check to see if value in range
cmp		rax, SPD_MIN
jl		errSpdValue_

cmp		rax, SPD_MAX
jg		errSpdValue_

; if good, save speed value
mov		qword[speed], rax



; check errClrSpec
mov		r9, qword[r15 + 24]
; check argv[3] for -cl
cmp		byte[r9], '-'
jne		errClrSpec_
cmp		byte[r9 + 1], 'c'
jne		errClrSpec_
cmp		byte[r9 + 2], 'l'
jne		errClrSpec_
cmp		byte[r9 + 3], NULL
jne		errClrSpec_

; check errClrValue
mov		rax, 0
mov		r10, 0
lea		r13, byte[rbp - 28] ; grab address
mov		r9, qword[r15 + 32] ; grab value

arg4Lp:
cmp		byte[r9 + r10], NULL
je		arg4Convert
mov		al, byte[r9 + r10]
mov		byte[r13 + r10], al
inc		r10
jmp		arg4Lp

arg4Convert:
mov		byte[r13 + r10], NULL
mov		rdi, r13
mov		rsi, rdx
call	aSept2int

;check if number converted properly
cmp		rax, FALSE
je		errClrValue_

; check if value is in range
cmp		rax, CLR_MIN
jl		errClrValue_

cmp		rax, CLR_MAX
jg		errClrValue_

; if successful, store color
mov		qword[color], rax




; check errSizSpec
mov		r9, qword[r15 + 40]
; check argv[3] for "-sz"
cmp		byte[r9], '-'
jne		errSizSpec_
cmp		byte[r9 + 1], 's'
jne		errSizSpec_
cmp		byte[r9 + 2], 'z'
jne		errSizSpec_
cmp 	byte[r9 + 3], NULL
jne 	errSizSpec_

;check errSizValue
mov 	rax, 0
mov 	r10, 0
lea 	r13, byte[rbp - 39]
mov 	r9, qword[r15 + 48]

arg6Lp:
cmp 	byte[r9 + r10], NULL
je 		arg6Convert
mov 	al, byte[r9 + r10]
mov 	byte[r13 + r10], al
inc 	r10
jmp 	arg6Lp

arg6Convert:
mov		byte[r13 + r10], NULL
mov 	rdi, r13
mov 	rsi, rdx
call 	aSept2int

; check if value converted properly
cmp 	rax, FALSE
je		errSizValue_

;check if value in range
cmp 	rax, SIZ_MIN
jl 		errSizValue_

cmp 	rax, SIZ_MAX
jg 		errSizValue_

mov 	rax, TRUE
jmp 	doneSuccess

; if good, save size
mov 	qword[size], rax

; !!!!!! ERROR SECTION !!!!!!!!
errUsage_:
mov 	rdi, errUsage
jmp 	doneError

errBadCL_:
mov 	rdi, errBadCL
jmp 	doneError

errSpdSpec_:
mov 	rdi, errSpdSpec
jmp 	doneError

errSpdValue_:
mov 	rdi, errSpdValue
jmp 	doneError

errClrSpec_:
mov 	rdi, errClrSpec
jmp 	doneError

errClrValue_:
mov 	rdi, errClrValue
jmp 	doneError

errSizSpec_:
mov 	rdi, errSizSpec
jmp 	doneError

errSizValue_:
mov 	rdi, errSizValue
jmp 	doneError

doneError:
call	printString
mov 	rax, FALSE

doneSuccess:
pop 	rsi
pop 	rdi
pop 	r15
pop 	r13
pop 	r12
pop 	r10
pop 	r9
mov 	rsp, rbp
pop 	rbp

ret





; ******************************************************************
;  Draw wheels function.
;	Plot the provided functions (see PDF).

; -----
;  Arguments:
;	none -> accesses global variables.
;	nothing -> is void

; -----
;  Gloabl variables Accessed:

common	speed		1:4			; draw speed, dword, integer value
common	color		1:4			; draw color, dword, integer value
common	size		1:4			; screen size, dword, integer value

global drawWheels
drawWheels:
	push	rbp

; do NOT push any additional registers.
; If needed, save regitser to quad variable...

; -----
;  Set draw speed step
;	sStep = speed / scale

cvtsi2sd 	xmm0, dword[speed]
divsd 		xmm0, qword[scale]
movsd 		qword[sStep], xmm0

; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin
 
; -----
;  Set draw color(r,g,b)
;	uses glColor3ub(r,g,b)

mov 	r9d, dword[color]
movzx 	rdx, r9b
shr 	r9, 8
movzx 	rsi, r9b
shr 	r9, 8
movzx 	rdi, r9b
 
call glColor3ub

; -----
;  main plot loop
;	iterate t from 0.0 to 2*pi by tStep
;	uses glVertex2d(x,y) for each formula

movsd 	xmm0, qword[fltZero]
movsd 	qword[t], xmm0

; for (t = 0; t <= 2pi; t += tStep) {}
mainPlotLp:
; calculate 2pi
movsd 	xmm0, qword[pi]
mulsd 	xmm0, qword[fltTwo]

; t <= 2pi
ucomisd xmm0, qword[t]
jb 		mainPlotEnd

xy1:
; find x1 = cos(t)
movsd 	xmm0, qword[t]
call 	cos
movsd 	qword[x], xmm0

; find y1 = sin(t)
movsd 	xmm0, qword[t]
call 	sin
movsd 	qword[y], xmm0

; plot points
movsd 	xmm0, qword[x]
movsd 	xmm1, qword[y]
call 	glVertex2d


xy2:
; find x
movsd 	xmm0, qword[t]
call 	cos
divsd 	xmm0, qword[fltThree]		; fltTmp1 = cos(t) / 3
movsd 	qword[fltTmp1], xmm0

; 2piS
movsd 	xmm0, qword[pi]
mulsd 	xmm0, qword[fltTwo]
mulsd 	xmm0, qword[s]
; save to 2piS for later
movsd 	qword[fltTwoPiS], xmm0
; cos(2piS)
call 	cos
; 2 * cos(2piS)
mulsd 	xmm0, qword[fltTwo]
; /3 
divsd 	xmm0, qword[fltThree]

; add together then save to x
addsd 	xmm0, qword[fltTmp1]
movsd 	qword[x], xmm0

; find y
movsd 	xmm0, qword[t]
call 	sin
divsd 	xmm0, qword[fltThree]		; fltTmp1 = cos(t) / 3
movsd 	qword[fltTmp1], xmm0

; 2piS
movsd 	xmm0, qword[pi]
mulsd 	xmm0, qword[fltTwo]
mulsd 	xmm0, qword[s]
; save to 2piS for later
movsd 	qword[fltTwoPiS], xmm0
; sin(2piS)
call 	sin
; 2 * sin(2piS)
mulsd 	xmm0, qword[fltTwo]
; /3 
divsd 	xmm0, qword[fltThree]

; add together then save to y
addsd 	xmm0, qword[fltTmp1]
movsd 	qword[y], xmm0

; plot x2 and y2
movsd	xmm0, qword[x]
movsd 	xmm1, qword[y]
call 	glVertex2d


xy3:
; X calc first number, save to fltTmp1
; 2piS
movsd 	xmm0, qword[fltTwoPiS]
; cos(2piS)
call 	cos
; 2 * cos(2piS)
mulsd 	xmm0, qword[fltTwo]
; /3 
divsd 	xmm0, qword[fltThree]
movsd 	qword[fltTmp1], xmm0

;calc second number, save to xmm0
; numerator - tcos(4piS)
movsd 	xmm0, qword[fltTwoPiS]
mulsd 	xmm0, qword[fltTwo]
call 	cos
mulsd	xmm0, qword[t]
; denominator - 6pi
movsd 	xmm1, qword[pi]
mulsd 	xmm1, qword[fltSix]
movsd 	qword[fltTmp2], xmm1
;num / den
divsd	xmm0, qword[fltTmp2]

; num1 + num2, save to x
addsd 	xmm0, qword[fltTmp1]
movsd 	qword[x], xmm0

; Y calc first number, save to fltTmp1
; 2piS
movsd 	xmm0, qword[fltTwoPiS]
; sin(2piS)
call 	sin
; 2 * sin(2piS)
mulsd 	xmm0, qword[fltTwo]
; /3 
divsd 	xmm0, qword[fltThree]
movsd 	qword[fltTmp1], xmm0

;calc second number, save to xmm0
; numerator - tsin(4piS)
movsd 	xmm0, qword[fltTwoPiS]
mulsd 	xmm0, qword[fltTwo]
call 	sin
mulsd 	xmm0, qword[t]
; denominator - 6pi
movsd 	xmm1, qword[pi]
mulsd 	xmm1, qword[fltSix]
movsd 	qword[fltTmp2], xmm1
;num / den
divsd 	xmm0, qword[fltTmp2]

; num1 - num2, save to y
movsd 	xmm1, xmm0
movsd 	xmm0, qword[fltTmp1]
subsd 	xmm0, xmm1
movsd 	qword[y], xmm0

; plot xy3
movsd 	xmm0, qword[x]
movsd 	xmm1, qword[y]
call 	glVertex2d


xy4:
; X calc first number, save to fltTmp1
; 2piS
movsd 	xmm0, qword[fltTwoPiS]
; cos(2piS)
call 	cos
; 2 * cos(2piS)
mulsd 	xmm0, qword[fltTwo]
; /3 
divsd 	xmm0, qword[fltThree]
movsd 	qword[fltTmp1], xmm0

; calc second number
; numerator to xmm0: 4piS
movsd 	xmm0, qword[fltTwoPiS]
mulsd 	xmm0, qword[fltTwo]
; 2pi/3
movsd 	xmm1, qword[pi]
mulsd 	xmm1, qword[fltTwo]
divsd 	xmm1, qword[fltThree]
; movsd qword[fltTmp2], xmm1
; tcos(4piS + 2pi/3)
addsd 	xmm0, xmm1
call 	cos
mulsd 	xmm0, qword[t]
; denominator to xmm1: 6pi
movsd 	xmm1, qword[pi]
mulsd 	xmm1, qword[fltSix]
; movsd qword[fltTmp2], xmm1
; num/den
divsd 	xmm0, xmm1

; add together, save to x
addsd 	xmm0, qword[fltTmp1]
movsd 	qword[x], xmm0

; Y calc first number, save to fltTmp1
; 2piS
movsd 	xmm0, qword[fltTwoPiS]
; sin(2piS)
call 	sin
; 2 * sin(2piS)
mulsd 	xmm0, qword[fltTwo]
; /3 
divsd 	xmm0, qword[fltThree]
movsd 	qword[fltTmp1], xmm0

; calc second number
; numerator to xmm0: 4piS
movsd 	xmm0, qword[fltTwoPiS]
mulsd 	xmm0, qword[fltTwo]
; 2pi/3
movsd 	xmm1, qword[pi]
mulsd 	xmm1, qword[fltTwo]
divsd 	xmm1, qword[fltThree]
; movsd qword[fltTmp2], xmm1
; tsin(4piS + 2pi/3)
addsd 	xmm0, xmm1
call 	sin
mulsd 	xmm0, qword[t]
; denominator to xmm1: 6pi
movsd 	xmm1, qword[pi]
mulsd 	xmm1, qword[fltSix]
; movsd qword[fltTmp2], xmm1
; num/den
divsd 	xmm0, xmm1

; num1 - num2, save to y
movsd 	xmm1, xmm0
movsd 	xmm0, qword[fltTmp1]
subsd 	xmm0, xmm1
movsd 	qword[y], xmm0

; plot xy4
movsd 	xmm0, qword[x]
movsd 	xmm1, qword[y]
call 	glVertex2d


xy5:
; X calc first number, save to fltTmp1
; 2piS
movsd 	xmm0, qword[fltTwoPiS]
; cos(2piS)
call 	cos
; 2 * cos(2piS)
mulsd 	xmm0, qword[fltTwo]
; /3 
divsd 	xmm0, qword[fltThree]
movsd 	qword[fltTmp1], xmm0

; calc second number
; numerator to xmm0: 4piS
movsd 	xmm0, qword[fltTwoPiS]
mulsd 	xmm0, qword[fltTwo]
; 2pi/3
movsd 	xmm1, qword[pi]
mulsd 	xmm1, qword[fltTwo]
divsd 	xmm1, qword[fltThree]
; movsd qword[fltTmp2], xmm1
; tcos(4piS + 2pi/3)
subsd 	xmm0, xmm1
call 	cos
mulsd 	xmm0, qword[t]
; denominator to xmm1: 6pi
movsd 	xmm1, qword[pi]
mulsd 	xmm1, qword[fltSix]
; movsd qword[fltTmp2], xmm1
; num/den
divsd 	xmm0, xmm1

; add together, save to x
addsd 	xmm0, qword[fltTmp1]
movsd 	qword[x], xmm0

; Y calc first number, save to fltTmp1
; 2piS
movsd 	xmm0, qword[fltTwoPiS]
; sin(2piS)
call 	sin
; 2 * sin(2piS)
mulsd 	xmm0, qword[fltTwo]
; /3 
divsd 	xmm0, qword[fltThree]
movsd 	qword[fltTmp1], xmm0

; calc second number
; numerator to xmm0: 4piS
movsd 	xmm0, qword[fltTwoPiS]
mulsd 	xmm0, qword[fltTwo]
; 2pi/3
movsd 	xmm1, qword[pi]
mulsd 	xmm1, qword[fltTwo]
divsd 	xmm1, qword[fltThree]
; movsd qword[fltTmp2], xmm1
; tsin(4piS + 2pi/3)
subsd 	xmm0, xmm1
call 	sin
mulsd 	xmm0, qword[t]
; denominator to xmm1: 6pi
movsd 	xmm1, qword[pi]
mulsd 	xmm1, qword[fltSix]
; movsd qword[fltTmp2], xmm1
; num/den
divsd 	xmm0, xmm1

; num1 - num2, save to y
movsd 	xmm1, xmm0
movsd 	xmm0, qword[fltTmp1]
subsd 	xmm0, xmm1
movsd 	qword[y], xmm0

; plot xy4
movsd 	xmm0, qword[x]
movsd 	xmm1, qword[y]
call 	glVertex2d

; t += tStep
movsd 	xmm0, qword[t]
addsd 	xmm0, qword[tStep]
movsd 	qword[t], xmm0
jmp 	mainPlotLp
; }

mainPlotEnd:

; -----
;  Display image

	call	glEnd
	call	glFlush

; -----
;  Update s, s += sStep;
;  if (s > 1.0)
;	s = 0.0;

	movsd	xmm0, qword [s]			; s+= sStep
	addsd	xmm0, qword [sStep]
	movsd	qword [s], xmm0

	movsd	xmm0, qword [s]
	movsd	xmm1, qword [fltOne]
	ucomisd	xmm0, xmm1			; if (s > 1.0)
	jbe	resetDone

	movsd	xmm0, qword [fltZero]
	movsd	qword [sStep], xmm0
resetDone:

	call	glutPostRedisplay

; -----

	pop	rbp
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
