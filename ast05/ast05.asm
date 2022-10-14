;  Name: Chayden Richardson
;  NSHE ID: 2000735977
;  Section: 1001
;  Assignment: Assignment 4
;  Description: This program will iterate through a list and find
;               various sums, averages, minimums, maximums, and
;               medians

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

lp1:
	mov rax, 0
	movsx eax, byte[heights + r9]
	;cbw							 ; convert al to ax
	imul ax, word[widths + r9*2] ; multiply ax by width dx:ax
	; mov word[eax + 2], dx
	imul eax, dword[lengths + r9*4]

	mov dword[volumes + r9*4], eax
; setup next iteration
	inc r9
	loop lp1



; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! START OF OLD CODE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

; ; Start of list minimum
; mov     ecx, dword[length] ; store length into loop counter
; mov     ebx, 0             ; clear ebx for list iteration

; mov dword[lstMin], 9999

; lpMin:
;     mov     eax, dword[lst + ebx] ; current list item into eax
;     add     ebx, 4                ; increment for next loop
;     cmp     dword[lstMin], eax    ; compare current item to current min
;     jbe     skipMin               ; if current min <= eax, next loop
;     mov     dword[lstMin], eax    ; else, store new value
; skipMin:
;     loop    lpMin


; ; Start of list median
; mov     eax, 0
; mov     edx, 0                      ; clear registers
; mov     ecx, 4                      ; divisor

; ; add middle two values
; mov eax, dword[length]  ; save list length
; mov r9, 2               ; divde length by 2
; div r9d
; mov esi, eax

; mov eax, dword[lst + rsi*4] ; get 50th item
; dec rsi
; add eax, dword[lst + rsi*4] ;get 49th item

; ; add first and last values
; add     eax, dword[lst]
; mov esi, dword[length]
; dec rsi
; add eax, dword[lst + rsi*4]  

; div     ecx                         ; divide by 4
; mov     dword[estMed], eax          ; store value


; ; Start of list maximum
; mov     ecx, dword[length]          ; loop counter
; mov     ebx, 0                      ; clear register

; lpMax:
;     mov     eax, dword[lst + ebx]   ; store current list item
;     add     ebx, 4                  ; add 4 for next loop iteration
;     cmp     dword[lstMax], eax      ; compare current max to current list item
;     jge     skipMax                 ; if lstMax >= current item, next loop
;     mov     dword[lstMax], eax      ; else, store new max
; skipMax:
;     loop    lpMax


; ; Start of list sum
; mov     ecx, dword[length]          ; loop counter
; mov     ebx, 0                      ; clear register

; lpSum:
;     mov     eax, dword[lst + ebx]   ; move current list item into eax for add
;     add     ebx, 4                  ; increment for next loop
;     add     dword[lstSum], eax      ; add item to sum
;     loop    lpSum


; ; Start of list average
;     mov     eax, 0
;     mov     edx, 0                  ; clear registers
;     mov     eax, dword[lstSum]      ; store sum into eax for div
;     div     dword[length]           ; divide eax by list length
;     mov     dword[lstAve], eax      ; store result into lstAve


; ; Start of odd count
; mov     ecx, dword[length]          ; loop counter
; mov     ebx, 0                      ; clear register
; mov     r9, 2

; lpOddCnt:
;     mov rdx, 0
;     mov rax, 0
;     mov eax, dword[lst + ebx]
;     div r9
;     cmp edx, 0
;     je notOdd
;     add dword[oddCnt], 1
;     mov eax, dword[lst + ebx]
;     add dword[oddSum], eax

; notOdd:
;     add ebx, 4
;     loop lpOddCnt

; ; find odd ave
; mov edx, 0
; mov eax, dword[oddSum]
; div dword[oddCnt]
; mov dword[oddAve], eax

; ; Start of divisible by 9 count
; mov     ecx, dword[length]          ; loop counter
; mov     eax, 0
; mov     edx, 0
; mov     ebx, 0                      ; reset registers used

; lpNineCnt:
;     mov     rdx, 0
;     mov     rax, 0                  ; reset registers each loop
;     mov     eax, dword[lst + ebx]   ; move current list item into eax
;     cdq                             ; convert bit
;     idiv    dword[nineVal]           ; divide by 6
;     add     ebx, 4                  ; increment list
;     cmp     edx, 0                  ; compare remainder to 0 to check for even div
;     jne     skipNineCnt              ; if remainder != 0, do not count
;     inc     dword[nineCnt]           ; if remainder == 0, count
;     mov     eax, dword[lst + ebx - 4]   ; move current list item into eax
;     add     dword[nineSum], eax       ; finds sum while already incrementing
; skipNineCnt:
;     loop    lpNineCnt                ; go to start of loop


; ; Start of 9 average
; mov     rdx, 0
; mov     rax, 0              ; reset registers
; mov     eax, dword[nineSum]  ; move nineSum into eax for division
; cdq                         ; extend sign into edx:eax
; idiv    dword[nineCnt]       ; divide by count
; mov     dword[nineAve], eax  ; move result into nineAve


; *****************************************************************
;	Done, terminate program.

last:
	mov	rax, SYS_exit		; call call for exit (SYS_exit)
	mov	rdi, EXIT_SUCCESS	; return code of 0 (no error)
	syscall
