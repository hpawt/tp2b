default rel
section .bss
    tape_size   equ 30000
    code_size   equ 65536
    tape        resb tape_size
    code_buf    resb code_size

section .text
    global _start

_start:
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    lea rsi, [code_buf]
    mov rdx, code_size
    syscall
    
    test rax, rax
    jle .exit
    
    lea r12, [code_buf]       ; PC
    lea r13, [code_buf + rax] ; End
    xor r14, r14              ; Ptr
    xor r15, r15              ; State
    lea rbp, [tape]           ; Tape Base

.loop:
    cmp r12, r13
    jge .exit
    mov al, byte [r12]
    cmp al, '('
    je .do_open
    cmp al, 'L'
    je .do_L
    inc r12
    jmp .loop

.do_open:
    cmp r15, 1
    je .s1_open
    cmp r15, 2
    je .s2_open
    cmp r15, 3
    je .s3_open

    ; S0 -> S1 (P++)
    inc r14
    call .wrap_ptr
    mov r15, 1
    jmp .next

.s1_open: ; S1 -> S2 (If 0 Skip)
    mov r15, 2
    cmp byte [rbp + r14], 0
    jnz .next
    call .find_close
    jmp .next

.s2_open: ; S2 -> S0 (Loop Start: If 0 Skip)
    mov r15, 0
    cmp byte [rbp + r14], 0
    jnz .next
    call .find_close
    jmp .next

.s3_open: ; S3 -> S0 (Reset)
    mov r15, 0
    jmp .next

.do_L:
    cmp r15, 1
    je .s1_L
    cmp r15, 2
    je .s2_L
    cmp r15, 3
    je .s3_L

    ; S0 -> S2 (P--)
    dec r14
    call .wrap_ptr
    mov r15, 2
    jmp .next

.s1_L: ; S1 -> S3 (Val++)
    inc byte [rbp + r14]
    mov r15, 3
    jmp .next

.s2_L: ; S2 -> S1 (Loop End: If !0 Jump Back)
    mov r15, 1
    cmp byte [rbp + r14], 0
    jz .next
    call .find_open
    jmp .next

.s3_L: ; S3 -> S0 (Output)
    mov rax, 1
    mov rdi, 1
    lea rsi, [rbp + r14]
    mov rdx, 1
    syscall
    mov r15, 0
    jmp .next

.next:
    inc r12
    jmp .loop

.exit:
    mov rax, 60
    xor rdi, rdi
    syscall

.wrap_ptr:
    cmp r14, 30000
    jl .check_neg
    sub r14, 30000
    ret
.check_neg:
    cmp r14, 0
    jge .ret
    add r14, 30000
.ret: ret

.find_close:
    push rcx
    mov rcx, 1
.fc_loop:
    inc r12
    cmp r12, r13
    jge .fc_err       ; Error: Unexpected EOF
    cmp byte [r12], '('
    je .fc_inc
    cmp byte [r12], 'L'
    je .fc_dec
    jmp .fc_loop
.fc_inc: inc rcx; jmp .fc_loop
.fc_dec: dec rcx; jnz .fc_loop
    pop rcx; ret
.fc_err:
    pop rcx; jmp .exit

.find_open:
    push rcx
    mov rcx, 1
.fo_loop:
    cmp r12, code_buf ; Check BEFORE decrement
    jle .fo_err       ; Error: Unexpected Start of File
    dec r12
    
    cmp byte [r12], 'L'
    je .fo_inc
    cmp byte [r12], '('
    je .fo_dec
    jmp .fo_loop
.fo_inc: inc rcx; jmp .fo_loop
.fo_dec: dec rcx; jnz .fo_loop
    dec r12           ; Adjust to point BEFORE '(' so .next increments to '('
    pop rcx; ret
.fo_err:
    pop rcx; jmp .exit
