;  CS 218 - Assignment #11
;  Functions Template

; ***********************************************************************
;  Data declarations
;	Note, the error message strings should NOT be changed.
;	All other variables may changed or ignored...

section	.data

; -----
;  Define standard constants.

LF			equ	10			; line feed
NULL		equ	0			; end of string
SPACE		equ	0x20		; space

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

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

O_CREAT		equ	0x40
O_TRUNC		equ	0x200
O_APPEND	equ	0x400

O_RDONLY	equ	000000q			; file permission - read only
O_WRONLY	equ	000001q			; file permission - write only
O_RDWR		equ	000002q			; file permission - read and write

S_IRUSR		equ	00400q		; owner, read persmission
S_IWUSR		equ	00200q		; owner, write permission
S_IXUSR		equ	00100q		; owner, execute permission

; -----
;  Define program specific constants.

MIN_FILE_LEN	equ	5

; buffer size (part A) - DO NOT CHANGE THE NEXT LINE.
BUFF_SIZE	equ	750000

; -----
;  Variables for getImageFileNames() function.

eof		db	FALSE

usageMsg	db	"Usage: ./makeThumb <inputFile.bmp> "
		db	"<outputFile.bmp>", LF, NULL
errIncomplete	db	"Error, incomplete command line arguments.", LF, NULL
errExtra	db	"Error, too many command line arguments.", LF, NULL
errReadName	db	"Error, invalid source file name.  Must be '.bmp' file.", LF, NULL
errWriteName	db	"Error, invalid output file name.  Must be '.bmp' file.", LF, NULL
errReadFile	db	"Error, unable to open input file.", LF, NULL
errWriteFile	db	"Error, unable to open output file.", LF, NULL

; -----
;  Variables for setImageInfo() function.

HEADER_SIZE	equ	138

errReadHdr	db	"Error, unable to read header from source image file."
		db	LF, NULL
errFileType	db	"Error, invalid file signature.", LF, NULL
errDepth	db	"Error, unsupported color depth.  Must be 24-bit color."
		db	LF, NULL
errCompType	db	"Error, only non-compressed images are supported."
		db	LF, NULL
errSize		db	"Error, bitmap block size inconsistent.", LF, NULL
errWriteHdr	db	"Error, unable to write header to output image file.", LF,
		db	"Program terminated.", LF, NULL

; -----
;  Variables for readRow() function.

buffMax		dq	BUFF_SIZE
curr		dq	BUFF_SIZE
wasEOF		db	FALSE
pixelCount	dq	0

errRead		db	"Error, reading from source image file.", LF,
		db	"Program terminated.", LF, NULL

; -----
;  Variables for writeRow() function.

errWrite	db	"Error, writting to output image file.", LF,
		db	"Program terminated.", LF, NULL

; ------------------------------------------------------------------------
;  Unitialized data

section	.bss

buffer		resb	BUFF_SIZE
header		resb	HEADER_SIZE

; ############################################################################

section	.text

; ***************************************************************
;  Routine to get image file names (from command line)
;	Verify files by atemptting to open the files (to make
;	sure they are valid and available).

;  Command Line format:
;	./makeThumb <inputFileName> <outputFileName>

; -----
;  Arguments:
;	- argc (value)
;	- argv table (address)
;	- read file descriptor (address)
;	- write file descriptor (address)
;  Returns:
;	read file descriptor (via reference)
;	write file descriptor (via reference)
;	TRUE or FALSE


global getImageFileNames
getImageFileNames:
getParams:
push	rbp
mov		rbp, rsp
sub		rsp, 39

push	r9
push	r10
push	r11	
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

; check usageMsg
cmp		r12, 1
je		usageMsg_

; check errIncomplete
cmp		r12, 2
je errIncomplete_

; check errExtra
cmp 	r12, 3
ja		errExtra_

; check errReadName argv[2]
mov		r9, qword[r15 + 8]
mov		r10, 0
; mov r15, 0; !!!!! TESTING ONLY DELETE LATER !!!!!
readNameLp:
; mov 	r15b, byte[r9 + r10]; !!!!! TESTING ONLY DELETE LATER !!!!!
cmp		byte[r9 + r10], 0
je		spaceFound
inc		r10
jmp		readNameLp

spaceFound:
cmp		byte[r9 + r10 - 1], 'p'
jne 	errReadName_
cmp		byte[r9 + r10 - 2], 'm'
jne 	errReadName_
cmp		byte[r9 + r10 - 3], 'b'
jne 	errReadName_
cmp		byte[r9 + r10 - 4], '.'
jne 	errReadName_
cmp		byte[r9 + r10 - 5], '.'
je 		errReadName_

; check errReadName argv[3]
mov		r9, qword[r15 + 16]
mov		r10, 0
readNameLp2:
cmp		byte[r9 + r10], 0
je		spaceFound2
inc		r10
jmp		readNameLp2

spaceFound2:
cmp		byte[r9 + r10 - 1], 'p'
jne 	errWriteName_
cmp		byte[r9 + r10 - 2], 'm'
jne 	errWriteName_
cmp		byte[r9 + r10 - 3], 'b'
jne 	errWriteName_
cmp		byte[r9 + r10 - 4], '.'
jne 	errWriteName_
cmp		byte[r9 + r10 - 5], '.'
je 		errWriteName_

; file names good, check if open success argv[2]
push 	rdi
push	rsi

mov		rax,	SYS_open
mov		rdi,	qword[r15+8]
mov		rsi,	O_RDONLY

push	rcx
push	rdx
syscall
pop		rdx
pop		rcx

pop 	rsi
pop		rdi
cmp		rax,	0
jl		errReadFile_
mov		byte[rdx],	al

; argv[2] good, check if open success argv[3]
push	rdi
push	rsi

; !!!! CHECK THAT THIS PART WORKS PROPERLY !!!!
mov		rax,	SYS_creat
mov		rdi,	qword[r15+16]
mov		rsi,	S_IXUSR
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
push 	rcx
push	rdx
syscall
pop		rdx
pop		rcx

pop		rsi
pop		rdi
cmp		rax,	0
jl		errWriteFile_
mov		byte[rcx],	al

jmp 	doneSuccess

; !!!!!! ERROR SECTION !!!!!!
usageMsg_:
mov		rax, FALSE
mov 	rdi, usageMsg
jmp 	doneError

errIncomplete_:
mov		rax, FALSE
mov 	rdi, errIncomplete
jmp 	doneError

errExtra_:
mov		rax, FALSE
mov 	rdi, errExtra
jmp 	doneError

errReadName_:
mov		rax, FALSE
mov 	rdi, errReadName
jmp 	doneError

errWriteName_:
mov		rax, FALSE
mov 	rdi, errWriteName
jmp 	doneError

errReadFile_:
mov		rax, FALSE
mov 	rdi, errReadFile
jmp 	doneError

errWriteFile_:
mov		rax, FALSE
mov		rdi, errWriteFile
jmp		doneError

doneError:
mov		rax, FALSE
call	printString
mov 	rax, FALSE

doneSuccess:
pop 	rsi
pop 	rdi
pop 	r15
pop 	r13
pop 	r12
pop		r11
pop 	r10
pop 	r9
mov 	rsp, rbp
pop 	rbp
ret

; ***************************************************************
;  Read, verify, and set header information

;  HLL Call:
;	bool = setImageInfo(readFileDesc, writeFileDesc,
;		&picWidth, &picHeight, thumbWidth, thumbHeight)

;  If correct, also modifies header information and writes modified
;  header information to output file (i.e., thumbnail file).

; -----
;  2 -> BM				(+0)
;  4 file size			(+2)			; returns with new file size
;  4 skip				(+6)
;  4 header size		(+10)
;  4 skip				(+14)
;  4 width				(+18)			; returns with new width
;  4 height				(+22)			; returns with new height 
;  2 skip				(+26)
;  2 depth (16/24/32)			(+28)
;  4 compression method code	(+30)
;  4 bytes of pixel data		(+34)
;  skip remaing header entries

; -----
;   Arguments:
;	- read file descriptor (value)		; rdi
;	- write file descriptor (value)		; rsi
;	- old image width (address)			; rdx
;	- old image height (address)		; rcx
;	- new image width (value)			; r8
;	- new image height (value)			; r9

;  Returns:
;	file size (via reference)
;	old image width (via reference)
;	old image height (via reference)
;	TRUE or FALSE


; errReadHdr	db	"Error, unable to read header from source image file."
; 		db	LF, NULL
; errFileType	db	"Error, invalid file signature.", LF, NULL
; errDepth	db	"Error, unsupported color depth.  Must be 24-bit color."
; 		db	LF, NULL
; errCompType	db	"Error, only non-compressed images are supported."
; 		db	LF, NULL
; errSize		db	"Error, bitmap block size inconsistent.", LF, NULL
; errWriteHdr	db	"Error, unable to write header to output image file.", LF,
; 		db	"Program terminated.", LF, NULL


global setImageInfo
setImageInfo:
push	r10
push	r11
push	r12
push	r13

; preserve argument values
mov		r10, rdi		; read file 		(value)
mov		r11, rsi		; write file 		(value)
mov		r12, rdx		; old image width 	(address)
mov		r13, rcx		; old image height 	(address)


; read header from original image
mov		rax, SYS_read
mov		rdi, r10		; !!!! may be able to delete !!!!
mov		rsi, header
mov		rdx, HEADER_SIZE
syscall

; check if file read was successful
cmp		rax, 0
jl		errReadHdr_


; check if file is BMP
cmp		byte[header], 'B'
jne		errFileType_
cmp		byte[header + 1], 'M'
jne		errFileType_


; check file size (width * height * 3 + HEADER_SIZE)
mov		rax, qword[r12]
mul		r13
mov		r14, 3
mul 	r14
add		rax, qword[HEADER_SIZE]

; !!!! Error messages !!!!!
errReadHdr_:
mov		rdi, errReadHdr
jmp		doneError2

errFileType_:
mov		rdi, errFileType
jmp		doneError2

doneError2:
call	printString
mov 	rax, FALSE

pop		r13
pop		r12
pop		r11
pop		r10
ret




; ***************************************************************
;  Return a row from read buffer
;	This routine performs all buffer management

; ----
;  HLL Call:
;	bool = readRow(readFileDesc, picWidth, rowBuffer[]);

;   Arguments:
;	- read file descriptor (value)
;	- image width (value)
;	- row buffer (address)
;  Returns:
;	TRUE or FALSE

; -----
;  This routine returns TRUE when row has been returned
;	and returns FALSE if there is no more data to
;	return (i.e., all data has been read) or if there
;	is an error on read (which would not normally occur).

;  The read buffer itself and some misc. variables are used
;  ONLY by this routine and as such are not passed.


global readRow
readRow:

ret


; ***************************************************************
;  Write image row to output file.
;	Writes exactly (width*3) bytes to file.
;	No requirement to buffer here.

; -----
;  HLL Call:
;	bool = writeRow(writeFileDesc, picWidth, rowBuffer);

;  Arguments are:
;	- write file descriptor (value)
;	- image width (value)
;	- row buffer (address)

;  Returns:
;	N/A

; -----
;  This routine returns TRUE when row has been written
;	and returns FALSE only if there is an
;	error on write (which would not normally occur).

;  The read buffer itself and some misc. variables are used
;  ONLY by this routine and as such are not passed.


global writeRow
writeRow:

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

