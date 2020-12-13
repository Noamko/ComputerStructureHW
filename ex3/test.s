	.section .rodata
format_id: 	.string "%s\n"
helloworld:	.string "Hello, World!"

	.text
.global main
main:
	pushq	%rbp
	pushq	%rbx
	movq	%rsp, %rbp
	subq	$8, %rsp

	movq	format_id, %rdi
	movq	$helloworld, %rsi

	call	printf
	xorq	%rax,rax

	ret
