;shell sort
    ;save length into rdi
    mov rdi, 0
    mov edi, dword[len]

    ;eax holds h
    mov eax, dword[h]
    ;ebx holds i
    mov ebx, dword[i]
    ;ecx holds j
    mov ecx, dword[j]

    mov r10d, dword[tmp]
    ;h = 1
    add eax, 1

    whileHLessLength:
        ;h = h * 3 + 1
        mov r8d, 3
        imul eax, r8d
        add eax, 1

        ;(h3+1) < length
        cmp eax, dword[len]
        ;if above condition is false done
        jge whileHLessLengthDone
        ;otherwise true so go back up
        jmp whileHLessLength

    whileHLessLengthDone:

    whileHGreaterZero:
        ;i = h-1
        mov ebx, dword[eax]
        sub ebx, 1

        forLoop1:
            mov r10d, dword[lst + ebx * 4]
            mov dword[tmp], r10d

            mov dword[j], ebx
            mov ecx, dword[j]

            mov r12d, dword[j]
            sub r12d, h
            forLoop2:
                mov r13d, dword[lst + r12d * 4]
                mov dword[lst + ecx], r13d

                ;increment j for second loop
                inc ecx

                ;check loop 2 condition
                cmp ecx, eax
                jl forLoop2Done
                cmp dword[lst + r12d * 4], tmp
            forLoop2Done:
                ;increment i for first loop
                inc ebx
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