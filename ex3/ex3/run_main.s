#	308192871	Noam Koren

# -- read only data -- #
.section .rodata
format_s:   .string "%s"
format_d:   .string "%d"

# -- code -- #
.text
.global run_main
.type run_main, @function
run_main:
	# -- open a new stack frame -- #
	pushq	%rbp
	movq	%rsp,	%rbp
	# ----------------------------- #

	# -- save calle saved registers -- #
	pushq	%r12
	pushq	%r13
	pushq	%r14
	# -------------------------------- #

	# -- we use r14 to later rebase the stack so we save the amount need to add later
	movq	$4,		%r14 # add 4 for string len and \0 of both strings
	subq	$0x4,	%rsp # allocate 4 bytes for input

	# -- get the input from use -- #
    movq	$format_d,	%rdi
	movq	%rsp,	%rsi
    xorq	%rax,	%rax
    call	scanf
	movzbq	(%rsp),	%r12
	# -------------------------- #

	addq	%r12,	%r14 # add the string len to r14
	addq	$0x4,	%rsp # deallocate
	subq	%r12,	%rsp # allocate string len
	subq	$2,		%rsp # alocate space for str len and null char

	# -- scan the string  -- #
	movq	$format_s,	%rdi
	leaq	1(%rsp),	%rsi # place the rsp above the string len
	xor		%rax,	%rax
	call	scanf
	movb	%r12b,	(%rsp)
	movq	%rsp,	%r12
	# --------------------------------- #

	# -- reapeat for the second string -- #
	subq	$0x4,	%rsp

	movq	$format_d,	%rdi
	movq	%rsp,	%rsi
	xorq	%rax,	%rax
	call	scanf
	movzbq	(%rsp),	%r13
	addq	%r13,	%r14
	addq	$0x4,	%rsp
	subq	%r13,	%rsp
	subq	$2,		%rsp

	leaq	1(%rsp),	%rsi
	movq	$format_s,	%rdi
	xorq	%rax,	%rax
	call	scanf
	movb	%r13b,	(%rsp)
	movq	%rsp,	%r13
	# ---------------------------------- #

	# -- scan case number and execute run func -- #
	subq	$0x4,	%rsp
	movq	$format_d,	%rdi
	movq	%rsp,	%rsi
	xorq	%rax,	%rax
	call	scanf
	movzbq	(%rsp),	%rdi
	add		$0x4,	%rsp	
	movq	%r12,	%rsi
	movq	%r13,	%rdx
	call	run_func	
	# ---------------------------------- #

	# -- finish -- #
	addq	%r14,	%rsp
	popq	%r14
	popq 	%r13
	popq 	%r12
	popq	%rbp
	xorq	%rax,	%rax
	ret
# ------------------------------------- #
