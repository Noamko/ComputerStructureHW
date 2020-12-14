.section    .rodata
.align  8
format_s:   .string "%s"
format_L4:  .string "first pstring length: %d, second pstring length: %d\n"

.L10:
    .quad .L4   #case 50
    .quad .L9   #case 51
    .quad .L5   #case 52
    .quad .L6   #case 53
    .quad .L7   #case 54
    .quad .L8   #case 55
    .quad .L9   #case 56
    .quad .L9   #case 57
    .quad .L9   #case 58
    .quad .L9   #case 59
    .quad .L4   #case 60


.text
.global run_func
run_func:
    pushq   %rbx
    leaq    -50(%rdi), %rbx
    cmpq    $10, %rbx
    ja      .L9 #if greated then 10 go to def case
    jmp     *.L10(,%rbx,8)

    .L4:    #case 50 || 60
    movq    $format_s, %rsi
    call    pstrlen
    movq    %rax,%rsi

    .L5:
    .L6:
    .L7:
    .L8:
    .L9:
