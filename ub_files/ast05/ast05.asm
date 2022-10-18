;  Name: Chayden Richardson
;  NSHE ID: 2000735977
;  Section: 1001
;  Assignment: Assignment 5
;  Description: This program will iterate through multiple sized lists,
;  and use that data to calculate various volumes and surface areas.
;  It will then save the V and SAs to their respective arrays, and find
;  the min, estmed, max, sum and average of both lists. 

; --------------------------------------------------------------

section	.data

; -----
;  Define constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation
SYS_exit	equ	60			; call code for terminate

; -----
;  Provided Data

lengths		dd	 1355,  1037,  1123,  1024,  1453
		dd	 1115,  1135,  1123,  1123,  1123
		dd	 1254,  1454,  1152,  1164,  1542
		dd	-1353,  1457,  1182, -1142,  1354
		dd	 1364,  1134,  1154,  1344,  1142
		dd	 1173, -1543, -1151,  1352, -1434
		dd	 1134,  2134,  1156,  1134,  1142
		dd	 1267,  1104,  1134,  1246,  1123
		dd	 1134, -1161,  1176,  1157, -1142
		dd	-1153,  1193,  1184,  1142

widths		dw	  367,   316,   542,   240,   677
		dw	  635,   426,   820,   146,  -333
		dw	  317,  -115,   226,   140,   565
		dw	  871,   614,   218,   313,   422	
		dw	 -119,   215,  -525,  -712,   441
		dw	 -622,  -731,  -729,   615,   724
		dw	  217,  -224,   580,   147,   324
		dw	  425,   816,   262,  -718,   192
		dw	 -432,   235,   764,  -615,   310
		dw	  765,   954,  -967,   515

heights		db	   42,    21,    56,    27,    35
		db	  -27,    82,    65,    55,    35
		db	  -25,   -19,   -34,   -15,    67
		db	   15,    61,    35,    56,    53
  		db	  -32,    35,    64,    15,   -10
		db	   65,    54,   -27,    15,    56
		db	   92,   -25,    25,    12,    25
		db	  -17,    98,   -77,    75,    34
		db	   23,    83,   -73,    50,    15
		db	   35,    25,    18,    13

count		dd	49

vMin		dd	0
vEstMed		dd	0
vMax		dd	0
vSum		dd	0
vAve		dd	0

saMin		dd	0
saEstMed	dd	0
saMax		dd	0
saSum		dd	0
saAve		dd	0

; -----
; Additional variables (if any)

; --------------------------------------------------------------
; Uninitialized data

section	.bss

volumes		resd	49
surfaceAreas	resd	49

section	.bss


; *****************************************************************

section	.text
global _start
_start:

; -----

; Start of volumes calculations
mov ecx, dword[count]
mov r9, 0				; used for list iteration
mov r10, 0				; used to hold multiplication value

calcVol:
	mov rax, 0
	movsx rax, byte[heights + r9] 	; hold heights value in rax
	movsx r10, word[widths + r9*2]	; hold widths value in r10
	imul rax, r10					; height * width
	movsxd r10, dword[lengths + r9*4]	; hold lenghts value in r10
	imul rax, r10					; (height * width) * length

	mov dword[volumes + r9*4], eax	; move result into volumes array

; setup next iteration
	inc r9
	loop calcVol


; start of volumes min
mov rcx, 0
mov ecx, dword[count]
mov r9, 0

findMin:
	mov eax, dword[volumes + r9]	; grab current vol
	add r9, 4						; setup next iteration
	cmp dword[vMin], eax			; check if vMin < current vol
	jle	skipMin						; if less, next loop
	mov dword[vMin], eax			; else, swap values
skipMin:
	loop findMin


; start of volumes median
mov rax, 0
mov rdx, 0		; clear registers
mov eax, dword[count]
mov r10, 0

; add first value to r10
add r10d, dword[volumes]

; add last value to r10
dec rax
add r10d, dword[volumes + rax*4]

; add middle value to rax
mov r9, 2
div r9								; rax / 2 to get middle val
add r10d, dword[volumes + rax*4]

; div by 3 to find average
mov r9, 3							; (first + mid + last) / 3
mov rax, r10
div r9

; save val
mov dword[vEstMed], eax


; start of find max
mov ecx, dword[count]
mov r9, 0

lpMax:
	mov eax, dword[volumes + r9]	; grab current vol
	add r9, 4						; setup next loop
	cmp dword[vMax], eax			; check if vMax > current vol
	jge skipMax						; if vMax > current vol, next loop
	mov dword[vMax], eax			; else, vMax = current vol
skipMax:
	loop lpMax


; start of find sum
mov ecx, dword[count]
mov rax, 0
mov r9, 0

lpSum:
	mov eax, dword[volumes + r9]	; grab current vol
	add r9, 4						; setup next loop
	add dword[vSum], eax			; add current vol to running sum
	loop lpSum


; start of volume average
mov rax, 0
mov rdx, 0
mov eax, dword[vSum]				; eax = vSum
div dword[count]					; vSum / count
mov dword[vAve], eax				; save result into vAve


; start of surface area calculations
mov ecx, dword[count]
mov r9, 0				; used for list iteration
mov r10, 0				; used to hold multiplication values
mov r11, 2
mov r12, 0				; running sum

calcSA:
	mov rax, 0
	movsx rax, byte[heights + r9]		; curr heights value in rax
	movsx r10, word[widths + r9*2]		; curr width in r10
	imul rax, r10						; height * width
	imul rax, r11						; 2 * (height * width)
	add r12, rax

	movsx rax, byte[heights + r9]		; rax = height
	movsxd r10, dword[lengths + r9*4]	; r10 = length
	imul rax, r10						; height * length
	imul rax, r11						; 2 * (height * length)
	add r12, rax

	movsx rax, word[widths + r9*2]		; rax = width
	movsxd r10, dword[lengths + r9*4]	; r10 = length
	imul rax, r10						; width * length
	imul rax, r11						; 2 * (width * length)
	add r12, rax

	mov dword[surfaceAreas + r9*4], r12d	; save result to SA array

; setup next iteration
	mov r12, 0
	inc r9
	loop calcSA


; start of SA list stats
; start of SA min
mov rcx, 0
mov ecx, dword[count]
mov r9, 0

findSAMin:
	mov eax, dword[surfaceAreas + r9]	; grab current SA
	add r9, 4							; setup next loop
	cmp dword[saMin], eax				; check if saMin < current SA
	jle	skipSAMin						; if saMin < current SA, next loop
	mov dword[saMin], eax				; else, saMin = current SA
skipSAMin:
	loop findSAMin


; start of SA median
mov rax, 0
mov rdx, 0		; clear registers
mov eax, dword[count]
mov r10, 0

; add first value to r10
add r10d, dword[surfaceAreas]

; add last value to r10
dec rax
add r10d, dword[surfaceAreas + rax*4]

; add middle value to rax
mov r9, 2
div r9
add r10d, dword[surfaceAreas + rax*4]

; div by 3 to find average
mov r9, 3
mov rax, r10
div r9

; save val
mov dword[saEstMed], eax


; start of find max
mov ecx, dword[count]
mov r9, 0

lpSAMax:
	mov eax, dword[surfaceAreas + r9]	; grab current SA
	add r9, 4							; setup next loop
	cmp dword[saMax], eax				; check if saMax > current SA
	jge skipSAMax						; if saMax > current SA, next loop
	mov dword[saMax], eax				; else, saMax = current SA
skipSAMax:
	loop lpSAMax


; start of find sum
mov ecx, dword[count]
mov rax, 0
mov r9, 0

lpSASum:
	mov eax, dword[surfaceAreas + r9]	; grab current SA
	add r9, 4							; setup next loop
	add dword[saSum], eax				; add current SA to sum
	loop lpSASum


; start of SA average
	mov rax, 0
	mov rdx, 0
	mov eax, dword[saSum]				; eax = saSum
	div dword[count]					; saSum / count = ave
	mov dword[saAve], eax				; save ave

; *****************************************************************
;	Done, terminate program.

last:
	mov	rax, SYS_exit		; call call for exit (SYS_exit)
	mov	rdi, EXIT_SUCCESS	; return code of 0 (no error)
	syscall
