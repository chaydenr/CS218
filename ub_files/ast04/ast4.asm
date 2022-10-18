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

EXIT_SUCCESS	equ	0			; Successful operation
SYS_exit	equ	60			; call code for terminate

; -----

lst		dd	 4224, -1116,  1542,  1240,  1677
		dd	-1635,  2420,  1820,  1246,  -333 
		dd	 2315,  -215,  2726,  1140,  2565
		dd	 2871,  1614,  2418,  2513,  1422 
		dd	 -119,  1215, -1525,  -712,  1441
		dd	-3622,  -731, -1729,  1615,  2724 
		dd	 1217,  -224,  1580,  1147,  2324
		dd	 1425,  1816,  1262, -2718,  1192 
		dd	-1435,   235,  2764, -1615,  1310
		dd	 1765,  1954,  -967,  1515,  1556 
		dd	 1342,  7321,  1556,  2727,  1227
		dd	-1927,  1382,  1465,  3955,  1435 
		dd	 -225, -2419, -2534, -1345,  2467
		dd	 1615,  1959,  1335,  2856,  2553 
		dd	-1035,  1833,  1464,  1915, -1810
		dd	 1465,  1554,  -267,  1615,  1656 
		dd	 2192,  -825,  1925,  2312,  1725
		dd	-2517,  1498,  -677,  1475,  2034 
		dd	 1223,  1883, -1173,  1350,  2415
		dd	 -335,  1125,  1118,  1713,  3025
length		dd	100

lstMin		dd	0
estMed		dd	0
lstMax		dd	0
lstSum		dd	0
lstAve		dd	0

negCnt		dd	0
negSum		dd	0
negAve		dd	0

sixCnt		dd	0
sixSum		dd	0
sixAve		dd	0

; initialize program variables
sixVal      dd  6

section	.bss


; *****************************************************************

section	.text
global _start
_start:

; -----


; Start of list minimum
mov     ecx, dword[length] ; store length into loop counter
mov     ebx, 0             ; clear ebx for list iteration

lpMin:
    mov     eax, dword[lst + ebx] ; current list item into eax
    add     ebx, 4                ; increment for next loop
    cmp     dword[lstMin], eax    ; compare current item to current min
    jle     skipMin               ; if current min <= eax, next loop
    mov     dword[lstMin], eax    ; else, store new value
skipMin:
    loop    lpMin


; Start of list median
mov     eax, 0
mov     edx, 0                      ; clear registers
mov     ecx, 4                      ; divisor
add     eax, dword[lst]             
add     eax, dword[lst + 4 * 49]
add     eax, dword[lst + 4 * 50]
add     eax, dword[lst + 4 * 99]    ; add necessary values
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


; Start of negative count
mov     ecx, dword[length]          ; loop counter
mov     ebx, 0                      ; clear register

lpNegCnt:
    mov     rdx, 0                  ; clear register each loop
    mov     eax, dword[lst + ebx]   ; store current item
    add     ebx, 4                  ; increment for next loop
    cdqe                            ; convert eax to quad in rax
    cqo                             ; convert rax to rdx:rax
    cmp     rdx, 0                  ; compare sign to 0
    je      skipNegCnt              ; if sign is positive (0), skip
    inc     dword[negCnt]           ; else, increment negCnt
    add     dword[negSum], eax      ; add item to sum
skipNegCnt:
    loop    lpNegCnt


; Start of negative average
mov     eax, 0
mov     edx, 0                      ; clear registers
mov     eax, dword[negSum]          ; store sum into eax for div
cdq                                 ; convert eax to edx:eax
idiv    dword[negCnt]               ; divide sum by count
mov     dword[negAve], eax          ; store result into negAve


; Start of divisible by 6 count
mov     ecx, dword[length]          ; loop counter
mov     eax, 0
mov     edx, 0
mov     ebx, 0                      ; reset registers used

lpSixCnt:
    mov     rdx, 0
    mov     rax, 0                  ; reset registers each loop
    mov     eax, dword[lst + ebx]   ; move current list item into eax
    cdq                             ; convert bit
    idiv    dword[sixVal]           ; divide by 6
    add     ebx, 4                  ; increment list
    cmp     edx, 0                  ; compare remainder to 0 to check for even div
    jne     skipSixCnt              ; if remainder != 0, do not count
    inc     dword[sixCnt]           ; if remainder == 0, count
    mov     eax, dword[lst + ebx - 4]   ; move current list item into eax
    add     dword[sixSum], eax       ; finds sum while already incrementing
skipSixCnt:
    loop    lpSixCnt                ; go to start of loop


; Start of 6 average
mov     rdx, 0
mov     rax, 0              ; reset registers
mov     eax, dword[sixSum]  ; move sixSum into eax for division
cdq                         ; extend sign into edx:eax
idiv    dword[sixCnt]       ; divide by count
mov     dword[sixAve], eax  ; move result into sixAve


; *****************************************************************
;	Done, terminate program.

last:
	mov	rax, SYS_exit		; call call for exit (SYS_exit)
	mov	rdi, EXIT_SUCCESS	; return code of 0 (no error)
	syscall
