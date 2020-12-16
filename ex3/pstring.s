.section .rodata
.global pstrlen, replaceChar
.text

.type pstrlen, @function
pstrlen:
	xorq	%rax, %rax
	movzbl	(%rdi), %rax
	ret

# gets 3 args : (Pstring* pstr, char oldChar, char newChar)
.type replaceChar, @function
replaceChar:
	pushq 		%rbp
	movq		%rsp, %rbp

	pushq		%rbx
	subq		$16, %rsp

	call 		pstrlen
	mov			$0, %rbx
	mov			%al, %bl
	inc			%bl
	mov			$0, %al 
	jmp			.LRC0

	.LRC0:
		xorq	%rcx, %rcx
		movzbl	(%rdi, %rax, 1), %rcx
		cmp		%rsi, %rcx
		je		.LRC1
		jmp		.LRC2
	
	.LRC1:
		mov		%dl, (%rdi, %rax, 1)
		jmp 	.LRC2

	.LRC2:
		inc		%al
		cmp		%al, %bl
		je		.LRC3

		jmp 	.LRC0

	.LRC3:
		add		$16, %rsp
		popq 	%rbx
		popq 	%rbp
		movq 	%rdi, %rax
		ret
