.section .rodata
format_s:   .string "%s"
format_d:   .string "%s"

.text
.global run_main
run_main:
    pushq   %rbp
    movq    %rsp,       %rbp
    subq    $16,        %rsp

    movq    $format_d,  %rdi
    leaq    -8(%rbp),       %rsi
    xorq    %rax,       %rax
    call    scanf


    inc     %rax
    subq    %rax, %rsp

    movq    $format_s, %rdi
    movq    %rsp, %rsi
    xorq    %rax, %rax
    call    scanf
    movq    %rax,%rax


