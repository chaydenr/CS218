global	shellSort
shellSort:
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


;shell sort

; !!!!!!! Probably don't need this !!!!!!!!!!
    ;eax holds h
    mov eax, dword[h]
    ;ebx holds i
    mov ebx, dword[i]
    ;ecx holds j
    mov ecx, dword[j]
; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    ; ;eax holds h
    ; lea rax, dword[h]
    ; ;ebx holds i
    ; lea rbx, dword[i]
    ; ;ecx holds j
    ; lea rcx, dword[j]

	mov dword[len], esi

    mov r10d, dword[tmp]
    ;h = 1
    add eax, 1
	; inc dword[rax]

    whileHLessLength:
        ;h = h * 3 + 1
        mov r8d, 3
        imul rax, r8
        add rax, 1

        ;(h3+1) < length
        cmp eax, dword[len]
        ;if above condition is false done
        jge whileHLessLengthDone
        ;otherwise true so go back up
        jmp whileHLessLength

    whileHLessLengthDone:

    whileHGreaterZero:
        ;i = h-1
        mov ebx, eax
        sub ebx, 1

        forLoop1:
			; tmp = lst[1]
            ; mov r10d, dword[rdi + rbx * 4]
			movsxd r10, dword[rdi + rbx * 4]
            mov dword[tmp], r10d

			; j = i
            mov dword[j], ebx
            mov ecx, dword[j]

			
			mov dword[h], eax
            ; mov r12d, dword[j]
            movsxd r12, dword[j]
			mov	dword[jMinH], r12d
            sub dword[jMinH], eax

			movsxd r12, dword[jMinH]

            forLoop2:
;                mov r13d, dword[rdi + r12 * 4]
                movsxd r13, dword[rdi + r12 * 4]
                ; mov dword[rdi + rcx], r13d
                mov dword[rdi + rcx * 4], r13d

                ;increment j for second loop
                inc rcx

                ;check loop 2 condition
                cmp rcx, rax
                jl forLoop2Done
                cmp dword[rdi + r12 * 4], tmp
            forLoop2Done:
                ;increment i for first loop
                inc rbx
                ;check loop 1 condition
                cmp ebx, dword[len]
                ;if bigger forloop1 is done
                jge forLoop1Done
                ;if less jmp back to for loop 1
                jmp forLoop1
        forLoop1Done:
        cmp eax, 0
        jle whileHGreaterZeroDone
        jmp whileHGreaterZero

    whileHGreaterZeroDone:

; shellSort closing callframe
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