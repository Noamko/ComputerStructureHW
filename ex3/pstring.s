.section .rodata
format_INV:		.string	"invalid input!\n"
.global pstrlen, replaceChar, pstrijcpy, swapCase, pstrijcmp
.text

.type checkIndex, @function
# checkIndex(pstring *, int i)
checkIndex:
	pushq	%rbp
	movq	%rsp, %rbp

	xorq	%rax, %rax
	call 	pstrlen
	movq	%rax, %rdx

	movq	%rsi, %rdi
	movq	$0,	%rsi
	xorq	%rax, %rax
	call 	checkInRange
	cmp 	$0, %rax
	js		.INVALID
	movq	$1, %rax
	popq	%rbp
	ret
	.INVALID:
		movq	$0, %rax
		popq	%rbp
		ret
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

	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15

	
	movq	%rdi, %r12
	movq	%rsi, %r13
	movq	%rdx, %r14
	movq	%rcx, %r15

	cmp		%r14, %r15
	jl		.ER0

	movq	%r12, %rdi
	movq	%r14, %rsi
	xorq	%rax, %rax
	call 	checkIndex
	cmp		$0, %rax
	je		.ER0

	movq	%r13, %rdi
	movq	%r15, %rsi
	xorq	%rax, %rax
	call 	checkIndex
	cmp		$0, %rax
	je		.ER0

	movq	%r14, %rax
	jmp		.LPS0

	.ER0:
		movq	$format_INV, %rdi
		xorq	%rax, %rax
		call	printf
		movq	%r12, %rax
		popq	%r15
		popq	%r14
		popq	%r13
		popq	%r12
		popq	%rbp
		ret
	.LPS0:
		movzbl	(%r13, %rax,1), %r9
		mov	%r9b, (%r12,%rax,1)
		jmp	.LPS1
	.LPS1:
		inc		%rax	
		cmpq	%rax, %r15
		js		.LPS3
		jmp		.LPS0
	.LPS3:
		movq	%r12, %rax
		popq	%r15
		popq	%r14
		popq	%r13
		popq	%r12
		popq	%rbp
		ret	

.type checkInRange, @function
# checkInRange(int a, int lower, int higher)
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

# int pstrijcmp(Pstring* pstr1, Pstring* pstr2, char i, char j)
.type pstrijcmp, @function
pstrijcmp:
	pushq	%rbp
	movq	%rsp,	%rbp

	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15

	
	movq	%rdi, %r12
	movq	%rsi, %r13
	movq	%rdx, %r14
	movq	%rcx, %r15

	cmp		%r14, %r15
	jl		.ER1

	movq	%r12, %rdi
	movq	%r14, %rsi
	xorq	%rax, %rax
	call 	checkIndex
	cmp		$0, %rax
	je		.ER1

	movq	%r13, %rdi
	movq	%r15, %rsi
	xorq	%rax, %rax
	call 	checkIndex
	cmp		$0, %rax
	je		.ER1


	movq	$0, 	%r11
	movq	%r14,	%rax
	jmp		.PCMP0

	.ER1:
		movq	$format_INV, %rdi
		xorq	%rax, %rax
		call	printf
		movq	$-2, %rax
		popq	%r15
		popq	%r14
		popq	%r13
		popq	%r12
		popq	%rbp
		ret
	.PCMP0:
		movq	$0, 	%r9
		movq	$0, 	%r10
		movzbl	(%r12,	%rax,1), %r9
		movzbl	(%r13,	%rax,1), %r10
		subq	%r9, 	%r10
		addq	%r10,	%r11
		jmp		.PCMP1
	.PCMP1:
		inc		%rax	
		cmpq	%rax, %r15
		js		.PCMP3
		jmp		.PCMP0
	.PCMP3:
		movq	%r11, %rax
		popq	%r15
		popq	%r14
		popq	%r13
		popq	%r12
		popq	%rbp
		ret	
