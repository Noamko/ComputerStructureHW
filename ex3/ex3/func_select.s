.section    .rodata
.align  8
format_d:	.string "%d"
format_s:	.string "%s"
format_c:	.string " %c"
format_L4:	.string "first pstring length: %d, second pstring length: %d\n"
format_L5:	.string "old char: %c, new char: %c, first string: %s, second string: %s\n"
format_L6:	.string "length: %d, string: %s\n"
format_L8:	.string "compare result: %d\n"
format_L9:	.string "invalid option!\n"

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
	pushq %r14
	pushq	%r15

    movq    %rsp,       %rbp
    leaq    -50(%rdi),  %r12
    cmpq    $10, %r12

    ja      .L9 # if greaters then 10 go to def case
    jmp     *.L10(,%r12,8)

    .L4: # case 50 || 60
        movq    %rsi, %rdi
        call    pstrlen
        movq    %rax, %rsi

        movq    %rdx, %rdi
        call    pstrlen

        movq    $format_L4, %rdi
        movq    %rax, %rdx
	movq	$0, %rax
        call    printf
        jmp     .L13

    .L5: # case 52
        pushq   %rsi # p1
        pushq   %rdx # p2 
        subq    $0x8, %rsp  

        movq    $format_c, %rdi
        movq    %rsp, %rsi
        xorq    %rax, %rax # zero %rax
        call    scanf

        
        movzbq	(%rsp), %r12 # save old char

        movq    $format_c, %rdi
        movq    %rsp, %rsi
        xorq    %rax, %rax # zero rax
        call    scanf
        movzbq  (%rsp), %r13 # save new char
	addq	$0x8, %rsp
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
	addq	$1, %r8
        movq    %rax, %rcx
	addq	$1, %rcx
        movq    $0, %rax
        call    printf
        jmp     .L13

    .L6: # case 53
	movq	%rsi,	%r14
	movq	%rdx,	%r15
        subq    $1,	%rsp 
        movq    $format_c,  %rdi
        movq	%rsp,	%rsi
        xorq    %rax,	%rax # zero %rax
        call    scanf

        movzbq    (%rsp), %r12 # start index

        subq    $48, %r12   # subtruct '0' from value to get proper [0,255] value

        movq    $format_c,  %rdi
        movq	%rsp,   %rsi
        xorq    %rax,	%rax # zero rax
        call    scanf
        movzbq	(%rsp),	%r13 # end index
        subq    $48,	%r13 # subtruct '0' from value to get proper [0,255] value

      	addq	$1,%rsp 

        movq	%r14, %rdi
        movq    %r15, %rsi
        mov     %r12, %rdx
        mov     %r13, %rcx
        movq    $0, %rax
        call    pstrijcpy
        movq    %rax, %r12

        movq    %rax,	%rdi
        movq    $0,	%rax
        call    pstrlen

        movq    $format_L6, %rdi
        movq    %rax, %rsi
        movq    %r12, %rdx
	addq	$1, %rdx
        movq    $0, %rax
        call    printf
	
	movq	%r15, %rdi
	mov	$0, %rax
	call 	pstrlen
	
        movq    $format_L6, %rdi
        movq    %rax, %rsi
        movq    %r15, %rdx
	addq	$1, %rdx
        movq    $0, %rax
        call    printf

        jmp     .L13

    .L7: # case 54
	movq	%rsi, %r12
	movq	%rdx, %r13
        movq    %r12, %rdi;
        call    swapCase

        movq    %r12, %rdi
        movq    $0, %rax
        call    pstrlen

        movq    %rax, %rsi
        movq    $format_L6, %rdi
        movq    %r12, %rdx
	addq	$1, %rdx
        movq    %rax, %rsi
        movq    $0, %rax
        call    printf
        # end of p1
        movq   	%r13, %rdi;
        call    swapCase

        movq    %r13, %rdi
        movq    $0, %rax
        call    pstrlen

        movq    %rax, %rsi
        movq    $format_L6, %rdi
        movq    %r13, %rdx
	addq	$1,	%rdx
        movq    %rax, %rsi
        movq    $0, %rax
        call    printf

        jmp     .L13
    .L8: # case 55
        pushq   %rsi # p1
        pushq   %rdx # p2
        subq    $0x8,	%rsp 

        movq    $format_d,  %rdi
        movq	%rsp,	%rsi
        xorq    %rax,	%rax # zero %rax
        call    scanf

        movzbq  (%rsp), %r12 # start index

        movq    $format_d,  %rdi
        movq	%rsp,   %rsi
        xorq    %rax,   %rax # zero rax
        call    scanf
        movzbq  (%rsp),	%r13 # end index

      	addq	$0x8, %rsp 
        popq    %rdi
        popq    %rsi
        movq     %r12,       %rdx
        movq     %r13,       %rcx
        movq    $0,         %rax
        call    pstrijcmp
        movq    $format_L8, %rdi
        movq    %rax, %rsi
        movq    $0, %rax
        call    printf
        jmp     .L13
    .L9: # default case
        movq    $format_L9, %rdi
        movq    $0, %rax
        call    printf

.L13: # end of run_func
	popq	%r15
	popq	%r14
    popq    %r13
    popq    %r12
    popq    %rbp
    xorq    %rax, %rax
    ret
