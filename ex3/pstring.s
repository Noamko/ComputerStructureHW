.section .rodata
.global pstrlen, replaceChar, pstrijcpy, swapCase
.text

.type pstrlen, @function
pstrlen:
	xorq	%rax,		%rax
	movzbl	(%rdi), 	%rax
	ret

# gets 3 args : (Pstring* pstr, char oldChar, char newChar)
.type replaceChar, @function
replaceChar:
	pushq 		%rbp
	movq		%rsp,	%rbp

	pushq		%rbx
	subq		$16, 	%rsp

	call 		pstrlen
	mov			$0,		%rbx
	mov			%al,	%bl
	inc			%bl
	mov			$0,		%al 
	jmp			.LRC0

	.LRC0:
		xorq	%rcx,	%rcx
		movzbl	(%rdi,	%rax, 1),	%rcx
		cmp		%rsi,	%rcx
		je		.LRC1
		jmp		.LRC2
	
	.LRC1:
		mov		%dl,	(%rdi, %rax, 1)
		jmp 	.LRC2

	.LRC2:
		inc		%al
		cmp		%al,	%bl
		je		.LRC3

		jmp 	.LRC0

	.LRC3:
		add		$16,	%rsp
		popq 	%rbx
		popq 	%rbp
		movq 	%rdi,	%rax
		ret

# Pstring* pstrijcpy(Pstring* dst, Pstring* src, char i, char j)

.type pstrijcpy, @function
pstrijcpy:
	pushq	%rbp
	movq	%rsp,	%rbp

	movq	%rdx, %rax
	jmp		.LPS0
	.LPS0:
		movzbl	(%rsi, %rax,1), %r9
		mov	%r9b, (%rdi,%rax,1)
		jmp	.LPS1
	.LPS1:
		inc		%rax	
		cmpq	%rax, %rcx
		js		.LPS3
		jmp		.LPS0
	.LPS3:
		movq	%rdi, %rax
		popq	%rbp
		ret	


checkInRange:
	pushq	%rbp
	movq	%rsp, %rbp

	movq	%rdi ,%rcx

	# a - 90 = x	
	subq	%rdx, 	%rcx
	imul	$-1, 	%rcx

	# 65 - a = y
	subq	%rsi, 	%rdi

	# check sign(x*y)
	imul	%rcx, 	%rdi
	movq	%rdi, 	%rax
	popq	%rbp
	ret

.type swapCase, @function
 # Pstring* swapCase(Pstring* pstr)

swapCase:
	pushq 	%rbp
	pushq	%r12
	pushq	%r13
	pushq	%rbx

	movq	%rsp,	%rbp
	movq	$0,		%rax
	call	pstrlen
	movq	%rdi, %r12
	movq	%rax, %r9
	movq	$0, %rbx
	jmp 	.SWC0

	.SWC0:
	movq	$0, %rdi
	movzbl	(%r12,%rbx,1), %rdi
	movq	%rdi, %r13
	movq	$65, %rsi
	movq	$90, %rdx
	movq	$0, %rax
	call 	checkInRange

	cmp		$0, %rax
	jge		.SWC1

	movq	%r13, %rdi
	movq	$97, %rsi
	movq	$122, %rdx
	movq	$0, %rax
	call 	checkInRange

	cmp		$0, %rax
	jge		.SWC2

	jle		.SWC3
	.SWC1: # char is in bound 
		add	$32, %r13
		mov	%r13b, (%r12,%rbx,1)
		jmp		.SWC3

	.SWC2:
		sub	$32, %r13
		mov	%r13b, (%r12,%rbx,1)
		jmp		.SWC3
	.SWC3:
		inc		%rbx
		cmp		%rbx,	%r9
		js		.SWC4
		jmp 	.SWC0
	.SWC4:
		movq	%r12, %rax

		popq	%rbx
		popq	%r13
		popq	%r12
		popq	%rbp
		ret
		#done

