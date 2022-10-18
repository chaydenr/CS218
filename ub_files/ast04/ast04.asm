;  Name: Chayden Richardson
;  NSHE ID: 2000735977
;  Section: 1001
;  Assignment: Assignment 4
;  Description: This program will iterate through a list and find
;               various sums, averages, minimums, maximums, and
;               medians

; *****************************************************************
;  Static Data Declarations (initialized)

section	.data
; -----
;  Define constants.

NULL		equ	0			; end of string

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation
SYS_exit	equ	60			; call code for terminate

; -----

lst		dd	4224, 1116, 1542, 1240, 1677
		dd	1635, 2420, 1820, 1246, 1333 
		dd	2315, 1215, 2726, 1140, 2565
		dd	2871, 1614, 2418, 2513, 1422 
		dd	1119, 1215, 1525, 1712, 1441
		dd	3622, 1731, 1729, 1615, 2724 
		dd	1217, 1224, 1580, 1147, 2324
		dd	1425, 1816, 1262, 2718, 1192 
		dd	1435, 1235, 2764, 1615, 1310
		dd	1765, 1954, 1967, 1515, 1556 
		dd	1342, 7321, 1556, 2727, 1227
		dd	1927, 1382, 1465, 3955, 1435 
		dd	1225, 2419, 2534, 1345, 2467
		dd	1615, 1959, 1335, 2856, 2553 
		dd	1035, 1833, 1464, 1915, 1810
		dd	1465, 1554, 1267, 1615, 1656 
		dd	2192, 1825, 1925, 2312, 1725
		dd	2517, 1498, 1677, 1475, 2034 
		dd	1223, 1883, 1173, 1350, 2415
		dd	1335, 1125, 1118, 1713, 3025
length		dd	100

lstMin		dd	0
estMed		dd	0
lstMax		dd	0
lstSum		dd	0
lstAve		dd	0

oddCnt		dd	0
oddSum		dd	0
oddAve		dd	0

nineCnt		dd	0
nineSum		dd	0
nineAve		dd	0

; initialize program variables
nineVal     dd  9

section	.bss


; *****************************************************************

section	.text
global _start
_start:

; -----


; Start of list minimum
mov     ecx, dword[length] ; store length into loop counter
mov     ebx, 0             ; clear ebx for list iteration

mov dword[lstMin], 9999

lpMin:
    mov     eax, dword[lst + ebx] ; current list item into eax
    add     ebx, 4                ; increment for next loop
    cmp     dword[lstMin], eax    ; compare current item to current min
    jbe     skipMin               ; if current min <= eax, next loop
    mov     dword[lstMin], eax    ; else, store new value
skipMin:
    loop    lpMin


; Start of list median
mov     eax, 0
mov     edx, 0                      ; clear registers
mov     ecx, 4                      ; divisor

; add middle two values
mov eax, dword[length]  ; save list length
mov r9, 2               ; divde length by 2
div r9d
mov esi, eax

mov eax, dword[lst + rsi*4] ; get 50th item
dec rsi
add eax, dword[lst + rsi*4] ;get 49th item

; add first and last values
add     eax, dword[lst]
mov esi, dword[length]
dec rsi
add eax, dword[lst + rsi*4]  

div     ecx                         ; divide by 4
mov     dword[estMed], eax          ; store value



; Start of list maximum
mov     ecx, dword[length]          ; loop counter
mov     ebx, 0                      ; clear register

lpMax:
    mov     eax, dword[lst + ebx]   ; store current list item
    add     ebx, 4                  ; add 4 for next loop iteration
    cmp     dword[lstMax], eax      ; compare current max to current list item
    jge     skipMax                 ; if lstMax >= current item, next loop
    mov     dword[lstMax], eax      ; else, store new max
skipMax:
    loop    lpMax


; Start of list sum
mov     ecx, dword[length]          ; loop counter
mov     ebx, 0                      ; clear register

lpSum:
    mov     eax, dword[lst + ebx]   ; move current list item into eax for add
    add     ebx, 4                  ; increment for next loop
    add     dword[lstSum], eax      ; add item to sum
    loop    lpSum


; Start of list average
    mov     eax, 0
    mov     edx, 0                  ; clear registers
    mov     eax, dword[lstSum]      ; store sum into eax for div
    div     dword[length]           ; divide eax by list length
    mov     dword[lstAve], eax      ; store result into lstAve


; Start of odd count
mov     ecx, dword[length]          ; loop counter
mov     ebx, 0                      ; clear register
mov     r9, 2

lpOddCnt:
    mov rdx, 0
    mov rax, 0
    mov eax, dword[lst + ebx]
    div r9
    cmp edx, 0
    je notOdd
    add dword[oddCnt], 1
    mov eax, dword[lst + ebx]
    add dword[oddSum], eax

notOdd:
    add ebx, 4
    loop lpOddCnt

; find odd ave
mov edx, 0
mov eax, dword[oddSum]
div dword[oddCnt]
mov dword[oddAve], eax

; Start of divisible by 9 count
mov     ecx, dword[length]          ; loop counter
mov     eax, 0
mov     edx, 0
mov     ebx, 0                      ; reset registers used

lpNineCnt:
    mov     rdx, 0
    mov     rax, 0                  ; reset registers each loop
    mov     eax, dword[lst + ebx]   ; move current list item into eax
    cdq                             ; convert bit
    idiv    dword[nineVal]           ; divide by 6
    add     ebx, 4                  ; increment list
    cmp     edx, 0                  ; compare remainder to 0 to check for even div
    jne     skipNineCnt              ; if remainder != 0, do not count
    inc     dword[nineCnt]           ; if remainder == 0, count
    mov     eax, dword[lst + ebx - 4]   ; move current list item into eax
    add     dword[nineSum], eax       ; finds sum while already incrementing
skipNineCnt:
    loop    lpNineCnt                ; go to start of loop


; Start of 9 average
mov     rdx, 0
mov     rax, 0              ; reset registers
mov     eax, dword[nineSum]  ; move nineSum into eax for division
cdq                         ; extend sign into edx:eax
idiv    dword[nineCnt]       ; divide by count
mov     dword[nineAve], eax  ; move result into nineAve


; *****************************************************************
;	Done, terminate program.

last:
	mov	rax, SYS_exit		; call call for exit (SYS_exit)
	mov	rdi, EXIT_SUCCESS	; return code of 0 (no error)
	syscall
