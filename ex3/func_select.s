.section    .rodata
.align  8
format_d:	.string "%d"
format_s:   .string "%s"
format_c:   .string " %c"
format_L4:  .string "first pstring length: %d, second pstring length: %d\n"
format_L5:  .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
format_L6:  .string "length: %d, string: %s\n"
format_L8:  .string "compare result: %d\n"
format_L9:  .string "invalid option!\n"

.L10:
    .quad .L4   #case 50
    .quad .L9   #case 51 def
    .quad .L5   #case 52
    .quad .L6   #case 53
    .quad .L7   #case 54
    .quad .L8   #case 55
    .quad .L9   #case 56 def
    .quad .L9   #case 57 def
    .quad .L9   #case 58 def
    .quad .L9   #case 59 def
    .quad .L4   #case 60 same as 50

.text
.global run_func
.type run_func, @function
run_func:
    pushq   %rbp
    pushq   %r12
    pushq   %r13

    movq    %rsp,       %rbp
    leaq    -50(%rdi),  %r12
    cmpq    $10, %r12

    ja      .L9 # if greaters then 10 go to def case
    jmp     *.L10(,%r12,8)

    .L4: # case 50 || 60
        subq    $16, %rsp
        movq    %rsi, %rdi
        call    pstrlen
        movl    %eax, %esi

        movq    %rdx, %rdi
        call    pstrlen

        movq    $format_L4, %rdi
        movl    %eax, %edx
        call    printf
        addq     $16, %rsp
        jmp     .L13

    .L5: # case 52
        subq    $16, %rsp # 16-aligned 
        pushq   %rdx # p2 
        pushq   %rsi # p1

        movq    $format_c, %rdi
        leaq    -8(%rbp), %rsi
        xorq    %rax, %rax # zero %rax
        call    scanf

        
        movq    %rsi, %r12 # save old char

        movq    $format_c, %rdi
        leaq    -8(%rbp), %rsi
        xorq    %rax, %rax # zero rax
        call    scanf
        movq    %rsi, %r13 # save new char

        popq    %rdi       # pstring 1 to 3rd arg
        movq    %r12, %rsi # move old char to 2nd arg
        movq    %r13, %rdx # move new char to 3rd arg
        xorq    %rax, %rax # zero %rax
        call    replaceChar

        popq    %rdi
        pushq   %rax

        movq    %r12, %rsi # move old char to 2nd arg
        movq    %r13, %rdx # move new char to 3rd arg
        xorq    %rax, %rax # zero %rax
        call    replaceChar

       
        movq    $format_L5, %rdi
        movq    %r12, %rsi
        movq    %r13, %rdx
        popq    %r8
        movq    %rax, %rcx
        movq    $0, %rax
        call    printf
        addq    $16,    %rsp # 16-aligned 
        jmp     .L13

    .L6: # case 53
        subq    $16,        %rsp # 16-aligned 
        pushq   %rdx # p2
        pushq   %rsi # p1
        
        movq    $format_c,  %rdi
        leaq    -8(%rbp),   %rsi
        xorq    %rax,       %rax # zero %rax
        call    scanf

        movq    %rsi, %r12 # start index
        subq    $48, %r12   # subtruct '0' from value to get proper [0,255] value

        movq    $format_c,  %rdi
        leaq    -8(%rbp),   %rsi
        xorq    %rax,       %rax # zero rax
        call    scanf
        movq    %rsi,       %r13 # end index
        subq    $48,        %r13 # subtruct '0' from value to get proper [0,255] value

        popq    %rsi
        popq    %rdi

        mov     %r12,       %rdx
        mov     %r13,       %rcx
        movq    $0, %rax
        call    pstrijcpy

        movq    %rax, %r12
        movq    %rax, %rdi
        movq    $0, %rax
        call    pstrlen
        movq    $format_L6, %rdi
        movq    %rax, %rsi
        movq    %r12, %rdx
        movq    $0, %rax
        call    printf
        add     $16, %rsp
        jmp     .L13

    .L7: # case 54s
        subq    $16, %rsp
        movq    %rsi, -8(%rbp)
        movq    %rdx, -16(%rbp)

        movq    -8(%rbp), %rdi;
        call    swapCase

        movq    -8(%rbp), %rdi
        movq    $0, %rax
        call    pstrlen

        movq    %rax, %rsi
        movq    $format_L6, %rdi
        movq    -8(%rbp), %rdx
        movq    %rax, %rsi
        movq    $0, %rax
        call    printf
        # end of p1
        movq    -16(%rbp), %rdi;
        call    swapCase

        movq    -16(%rbp), %rdi
        movq    $0, %rax
        call    pstrlen

        movq    %rax, %rsi
        movq    $format_L6, %rdi
        movq    -16(%rbp), %rdx
        movq    %rax, %rsi
        movq    $0, %rax
        call    printf

        addq    $16, %rsp
        jmp     .L13
    .L8: # case 55
        subq    $16, %rsp # 16-aligned 
        pushq   %rdx # p2
        pushq   %rsi # p1
        
        movq    $format_c,  %rdi
        leaq    -8(%rbp),   %rsi
        xorq    %rax,       %rax # zero %rax
        call    scanf

        movq    %rsi, %r12 # start index
        subq    $48, %r12   # subtruct '0' from value to get proper [0,255] value

        movq    $format_c,  %rdi
        leaq    -8(%rbp),   %rsi
        xorq    %rax,       %rax # zero rax
        call    scanf
        movq    %rsi,       %r13 # end index
        subq    $48,        %r13 # subtruct '0' from value to get proper [0,255] value

        popq    %rsi
        popq    %rdi

        mov     %r12,       %rdx
        mov     %r13,       %rcx
        movq    $0,         %rax
        call    pstrijcmp
        movq    $format_L8, %rdi
        movq    %rax, %rsi
        movq    $0, %rax
        call    printf
        addq    $16, %rsp
        jmp     .L13
    .L9: # default case
        movq    $format_L9, %rdi
        movq    $0, %rax
        call    printf

.L13: # end of run_func
    popq    %r13
    popq    %r12
    popq    %rbp
    xorq    %rax, %rax
    ret
