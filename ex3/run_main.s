.section .rodata
format_s:   .string "%s"
format_d:   .string "%d"

.text
.global run_main
.type run_main, @function
run_main:
	pushq   %rbp
	pushq	%r12
	pushq	%r13
    	movq    %rsp,		%rbp
	subq	$0x8,		%rsp

    	movq    $format_d, 	%rdi
	movq	%rsp, 		%rsi
    	xorq    %rax,      	%rax
    	call    scanf
	
	movzbq	(%rsp), 	%r12

	subq	%rax, %rsp

	movq	%rsp,%rsi
	movq	$format_s,	%rdi
	xor	%rax,%rax
	call	scanf

	subq	$1, %rsp
	movb	%r12b, (%rsp)
	movq	%rsp, %r12
	######## second pstring ########
	subq	$0x8,		%rsp

    	movq    $format_d, 	%rdi
	movq	%rsp, 		%rsi
    	xorq    %rax,      	%rax
    	call    scanf
	movzbq	(%rsp), 	%r13
	subq	%rax, %rsp

	movq	%rsp,%rsi
	movq	$format_s,	%rdi
	xor	%rax,%rax
	call	scanf

	subq	$1, %rsp
	movb	%r13b, (%rsp)
	movq	%rsp, %r13
	subq	$8, %rsp	
	movq	$format_d, %rdi
	movq	%rsp,		%rsi
	xor	%rax, %rax
	call 	scanf
	movq	(%rsp), %rdi
	movq	%r12, %rsi
	movq	%r13, %rdx
	call	run_func	
	add 	$28, %rsp
	pop 	%r13
	pop 	%r12
	pop	%rbp
	xor	%rax, %rax
	ret
