.section .rodata
format_s:   .string "%s"
format_d:   .string "%d"

.text
.global run_main
run_main:
    pushq   %rbp
    pushq   %rbx
    movq    %rbp, %rsp

    #allocate memory for local variables
    movq    -24(%rsp), %rsp
    movq    $format_d, %rsi
    movq    -16(%rsp), %rdi
    call    scanf



    pop     %rbx
    pop     %rbp
    xorq    %rax, %rax
    ret
    