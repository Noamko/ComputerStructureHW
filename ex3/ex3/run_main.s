.section .rodata
format_s:   .string "%s"
format_d:   .string "%d"

.text
.global run_main
.type run_main, @function
run_main:
	pushq   %rbp
    	movq    %rsp,		%rbp
	pushq	%r12
	pushq	%r13
	pushq	%r14
	movq	$4, %r14
	subq	$0x4,		%rsp

    	movq    $format_d, 	%rdi
	movq	%rsp, 		%rsi
    	xorq    %rax,      	%rax
    	call    scanf
	
	movzbq	(%rsp),	%r12
	addq	%r12,	%r14
	addq	$0x4, %rsp
	subq	%r12, %rsp
	subq	$2, %rsp

	movq	$format_s,%rdi
	leaq	1(%rsp), %rsi
	xor	%rax,%rax
	call	scanf
	movb	%r12b, (%rsp)
	movq	%rsp, %r12
	######## second pstring ########
	subq	$0x4,		%rsp

    	movq    $format_d, 	%rdi
	movq	%rsp, 		%rsi
    	xorq    %rax,      	%rax
    	call    scanf
	movzbq	(%rsp), 	%r13
	addq	%r13,  %r14
	addq	$0x4, %rsp
	subq	%r13, %rsp
	subq	$2, %rsp

	leaq	1(%rsp),%rsi
	movq	$format_s,	%rdi
	xor	%rax,%rax
	call	scanf
	movb	%r13b, (%rsp)
	movq	%rsp, %r13
	
	subq 	$0x4, %rsp
	movq	$format_d, %rdi
	movq	%rsp,%rsi
	xor	%rax, %rax
	call 	scanf
	movzbq	(%rsp), %rdi
	add	$0x4, %rsp	
	movq	%r12, %rsi
	movq	%r13, %rdx
	call	run_func	
	addq	%r14, %rsp
	popq	%r14
	popq 	%r13
	popq 	%r12
	popq	%rbp
	xor	%rax, %rax
	ret
