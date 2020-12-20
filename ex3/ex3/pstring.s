#	308192871	Noam Koren

.section .rodata
format_INV:		.string	"invalid input!\n"
.global pstrlen, replaceChar, pstrijcpy, swapCase, pstrijcmp
.text

# -- checks of an index is within string bounds -- #
.type checkIndex, @function
checkIndex:
	# -- open a stack frame -- #
	pushq	%rbp
	movq	%rsp, %rbp
	# ------------------------ #

	# -- get the string length using pstreln -- #
	xorq	%rax, %rax
	call 	pstrlen
	movq	%rax, %rdx
	subq	$1, %rdx # we reduce 1 since last index is len - 1
	# ----------------------------------------- #

	# -- checks if the give index is within 0 and sting length -- #
	movq	%rsi, %rdi
	movq	$0,	%rsi
	xorq	%rax, %rax
	call 	checkInRange # return 1 if in bound 0 o.w
	cmp 	$0, %rax
	js		.INVALID # return error is index is not out of bound
	movq	$1, %rax # return 1 o.w

	popq	%rbp
	ret
	# ----------------------------------------- #

	.INVALID:
	movq	$0, %rax
	popq	%rbp
	ret

# ------------------------------------------------ #

# -- pstrlen gets pstring length -- #
# since pstring store the len at the first byte
# we just return it as the return value
.type pstrlen, @function
pstrlen:
	xorq	%rax,	%rax
	movzbq	(%rdi), %rax # look at the first byte of the addres and return it
	ret
# ----------------------------------------------- #

# -- replace char replace all oc of a given char for another -- #
# gets 3 args : (Pstring* pstr, char oldChar, char newChar)
.type replaceChar, @function
replaceChar:
	# -- open a new stack frame -- #
	pushq	%rbp
	movq	%rsp,	%rbp
	# ---------------------------- #

	# -- gets the first string length -- #
	call 	pstrlen
	mov		$0,		%rbx
	mov		%al,	%bl  # save the strin length
	inc		%bl
	mov		$0,		%al  # init a counter to 0
	jmp		.LRC0
	# ---------------------------------- #

	# -- iterate through the string & replace each mathing char -- #
	.LRC0:
	xorq	%rcx,	%rcx # resets rcx
	movzbq	(%rdi,	%rax, 1), %rcx # get p[i]
	cmp		%rsi,	%rcx # check is p[i] == char
	je		.LRC1
	jmp		.LRC2
	.LRC1: # if a match is found replace it
	mov		%dl,	(%rdi, %rax, 1)
	jmp		.LRC2

	.LRC2: # inc the counter and start over
	inc		%al
	cmp		%al,	%bl
	je		.LRC3

	jmp 	.LRC0

	.LRC3: # finish
	movq	%rdi,	%rax
	popq 	%rbp
	ret
	# ------------------------------------------------------------ #

# -- copy a substring p1 to p2 at the same index interval -- #
# Pstring* pstrijcpy(Pstring* dst, Pstring* src, char i, char j)
.type pstrijcpy, @function
pstrijcpy:
	# -- open a new stack frame -- #
	pushq	%rbp
	movq	%rsp,	%rbp
	# ---------------------------- #

	# -- save called saved registers -- #
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	# --------------------------------- #

	# -- store the given params -- #
	movq	%rdi,	%r12
	movq	%rsi,	%r13
	movq	%rdx,	%r14
	movq	%rcx,	%r15
	# ---------------------------- #

	# -- checks if j < i retuen an error if true -- #
	cmp		%r14,	%r15
	jl		.ER0
	# --------------------------------------------- #

	# -- check if the input is valid -- #
	movq	%r12,	%rdi
	movq	%r14,	%rsi
	xorq	%rax,	%rax
	call 	checkIndex # check if i is in bounds
	cmp		$0,		%rax
	je		.ER0

	movq	%r13,	%rdi
	movq	%r15,	%rsi
	xorq	%rax,	%rax
	call 	checkIndex # check if j is in bounds
	cmp		$0,		%rax
	je		.ER0
	# ---------------------------------- #


	movq	%r14,	%rax # inti a count to i
	addq	$1,		%rax # inc i
	addq	$1,		%r15 # inc j
	jmp		.LPS0

	# -- if we got an invalid input print an error -- #
	.ER0:
	movq	$format_INV,	%rdi
	xorq	%rax,	%rax
	call	printf
	movq	%r12,	%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rbp
	ret
	# ----------------------------------------------- #

	# -- iterate both p1 and p2 -- #
	.LPS0:
	movq	$0,		%r9
	movzbq	(%r13, %rax,1), %r9
	movb	%r9b, (%r12,%rax,1)
	jmp	.LPS1
	
	.LPS1:
	inc		%rax	# inc the counter
	cmpq	%rax,	%r15 # check if we reached end of string
	js		.LPS3
	jmp		.LPS0

	.LPS3: # finish
	movq	%r12,	%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rbp
	ret	
	# -------------------------------------- #

# -------------------- Check In Range ----------------------- #

# *** this is a simple method I figured out to check if a positive number
# is in a given positive range with only 1 condition check! ** 

# assume we have num c and we want to see it belogs to some range [a, b] | a <= b
# a,b,c >= 0 
# we do the following:
# (c - a) * (b - c) = x
# if x is positive or 0 we return true
# if x < 0 we return false

.type checkInRange, @function
# checkInRange(int a, int lower, int higher)
checkInRange:
	# -- open a new stack frame -- #
	pushq	%rbp
	movq	%rsp,	%rbp
	# ---------------------------- #

	movq	%rdi,	%rcx # c

	# c - b = x	
	subq	%rdx, 	%rcx #   

	# a - c = y
	subq	%rsi, 	%rdi
	imul	$-1, 	%rdi # x * y

	# check sign(x*y)
	imul	%rcx, 	%rdi
	movq	%rdi, 	%rax
	popq	%rbp
	ret
# ------------------------------- #

# ---- swap case ------ #
.type swapCase, @function
 # Pstring* swapCase(Pstring* pstr)
swapCase:

	# -- open a new stack frame -- #
	pushq 	%rbp
	movq	%rsp,	%rbp
	# ---------------------------- #

	# -- save calle saved registers -- #
	pushq	%r12
	pushq	%r13
	# -------------------------------- #

	# -- get string lenth -- #
	movq	$0,		%rax
	call	pstrlen
	# ---------------------- #

	
	add 	$1,		%rdi # we skip the first byte of the string since it is holde the len
	movq	%rdi,	%r12 # save it for later
	movq	%rax,	%r9 # store the string len
	movq	$0,		%rbx # init a count to 0
	jmp 	.SWC0

	# -- check if p[i] is a char from a to z or A to Z -- #
	.SWC0:
	movq	$0,		%rdi
	movzbq	(%r12,%rbx,1), %rdi
	movq	%rdi,	%r13
	movq	$65,	%rsi
	movq	$90,	%rdx
	movq	$0,		%rax
	call 	checkInRange

	cmp	$0, %rax
	jge	.SWC1

	movq	%r13,	%rdi
	movq	$97,	%rsi
	movq	$122, 	%rdx
	movq	$0,		%rax
	call 	checkInRange

	cmp	$0,	%rax
	jge	.SWC2
	# ---------------------------------------------------- #

	# -- swape the case and continue -- #
	jle	.SWC3
	.SWC1: # char is in bound 
	add		$32,	%r13 # we add 32 to swap the case acorrding to ascii table
	mov		%r13b, (%r12,%rbx,1)
	jmp		.SWC3

	.SWC2:
	sub		$32,	%r13 # we reduce 32 to swap case acoriing to ascii table
	mov		%r13b,	(%r12,%rbx,1)
	jmp		.SWC3

	.SWC3: # inc the counter
	inc		%rbx
	cmp		%rbx,	%r9
	js		.SWC4
	jmp		.SWC0

	.SWC4:
	movq	%r12,	%rax # finish

	popq	%r13
	popq	%r12
	popq	%rbp
	ret
	# -------------------------------- #


# -- compare 2 substring and return 1 if one is bigger lixugrapgy from another -1 if less
# 0 if equal and -2 if invalid

# int pstrijcmp(Pstring* pstr1, Pstring* pstr2, char i, char j)
.type pstrijcmp, @function
pstrijcmp:

	# -- open a new stack frame -- #
	pushq	%rbp
	movq	%rsp,	%rbp
	# ---------------------------- #

	# -- saved calle saved registers -- #
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	# --------------------------------- #

	# -- save params -- #	
	movq	%rdi,	%r12
	movq	%rsi,	%r13
	movq	%rdx,	%r14
	movq	%rcx,	%r15
	# ---------------- #

	# -- check if j < i -- #
	cmp		%r14,	%r15
	jl		.ER1
	# -------------------- #

	# -- check if the indexes are valid -- #
	movq	%r12,	%rdi
	movq	%r14,	%rsi
	xorq	%rax,	%rax
	call 	checkIndex # see checkIndex for more info
	cmp		$0,		%rax
	je		.ER1

	movq	%r13,	%rdi
	movq	%r15,	%rsi
	xorq	%rax,	%rax
	call 	checkIndex  # see checkIndex for more info
	cmp		$0,		%rax
	je		.ER1
	# ------------------------------------- #

	# init a counter to i
	movq	%r14,	%rax
	addq	$1,		%r12
	addq	$1,		%r13
	jmp		.PCMP0

	# -- invalid input - abort -- #
	.ER1: 
	movq	$format_INV,	%rdi
	xorq	%rax,	%rax
	call	printf
	movq	$-2,	%rax
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rbp
	ret
	# -------------------------- #

	# -- iterate trough i to j -- #
	.PCMP0:
	movq	$0, 	%r9
	movq	$0, 	%r10
	movzbq	(%r12,	%rax,1), %r9 # get p1[i]
	movzbq	(%r13,	%rax,1), %r10 # get p2[i]
	cmp		%r9, 	%r10 # check witch is bigger

	jg		.PCPOS # p1[i] > p2[i]
	jl		.PCNEG # p1[i] < p2[i]
	jmp		.PCMP1 # p1[i] = p2[i]

	.PCMP1: # equal
	inc		%rax	# inc counter to continue
	cmpq	%rax,	%r15
	js		.PCMP2
	jmp		.PCMP0

	.PCMP2:
	movq	$0,		%rax # equal - return 0 
	jmp 	.PCMP3

	.PCPOS: # bigger - return 1
	movq	$1,		%rax
	jmp 	.PCMP3

	.PCNEG: # smaller return -1
	movq	$-1,	%rax
	jmp 	.PCMP3
	# ------------------------- #

	.PCMP3: # finish
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%rbp
	ret	
# ------------------------------------------------ #
