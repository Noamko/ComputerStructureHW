#	308192871	Noam Koren 

.section    .rodata
.align  8
format_d:	.string "%d"
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

	# --- save %rbp and open a new stack frame --- #
	pushq	%rbp
    movq    %rsp,	%rbp
    # -------------------------------------------- #

    # --- save calle saved registers --- #
    pushq   %r12
	pushq   %r13
	pushq	%r14
	pushq	%r15
	# ---------------------------------- #

	# --- rebase the mem to 0 so we can jmp to the right cas ---#
    leaq    -50(%rdi),  %r12
    cmpq    $10, %r12
    ja      .L9 	# if greater than 10 go to def case
    jmp     *.L10(,%r12,8)
    # --------------------------------------------------------- #

# ------- CASE 50 OR 60 --------- #
    .L4: 

    # --- get the both of the pstrings lengths --- #
	movq    %rsi, %rdi
	call    pstrlen
	movq    %rax, %rsi
	movq    %rdx, %rdi
 	call    pstrlen
	# -------------------------------------------- #

	# --- print & finish --- #
	movq    $format_L4, %rdi
	movq    %rax, %rdx
	movq	$0, %rax
	call    printf
	jmp     .L13
	# ----- end of L4 ----- #

# ----------- CASE 52 ----------- #
	.L5:
	# -- save register fo late use -- #
	pushq	%rsi # p1
	pushq	%rdx # p2 
	# ------------------------------- #

	# -- allocate 8 bytes to the stack and scan for input -- #
	# 1st char
	subq	$0x8, %rsp 
	movq    $format_c, %rdi
	movq    %rsp, %rsi
	xorq    %rax, %rax # zero %rax
	call    scanf
	movzbq	(%rsp), %r12 # save old char

	# 2nd char
	movq    $format_c, %rdi
	movq    %rsp, %rsi
	xorq    %rax, %rax # zero rax
	call    scanf
	movzbq  (%rsp), %r13 # save new char
	addq	$0x8, %rsp
	# ------------------------------------------------------ #

	# -- set args for replaceChar, call it for each string -- #
	# replace in 1st string
	popq    %rdi       # pstring 1 to 3rd arg
	movq    %r12, %rsi # move old char to 2nd arg
	movq    %r13, %rdx # move new char to 3rd arg
	xorq    %rax, %rax # zero %rax
	call    replaceChar

	# replace in 2nd string
	popq    %rdi
	pushq   %rax
	movq    %r12, %rsi # move old char to 2nd arg
	movq    %r13, %rdx # move new char to 3rd arg
	xorq    %rax, %rax # zero %rax
	call    replaceChar
	# ---------------------------------------------------- #

	# -- print both strings with l5 format -- #
	movq    $format_L5, %rdi
	movq    %r12, %rsi
	movq    %r13, %rdx
	popq    %r8
	addq	$1, %r8
	movq    %rax, %rcx
	addq	$1, %rcx # ignore the leadin len
	movq    $0, %rax
	call    printf
	jmp     .L13
	# ----------- end of CASE 52 ------------ #

# ----------- CASE 53 ----------- #
	.L6:

	# -- save p1 & p2 -- #
	movq	%rsi,	%r14
	movq	%rdx,	%r15
	# ------------------ #

	# -- set args for scanf -- #
	subq	$1,	%rsp # allocate 1 byte 
	movq	$format_c,	%rdi
	movq	%rsp,	%rsi
	xorq	%rax,	%rax # zero %rax
	call	scanf
	movzbq	(%rsp), %r12 # start index
	subq	$48, %r12   # subtruct '0' from value to get proper [0,255] value
	# ------------------------ #

	# -- set args for scanf -- #
	movq	$format_c,	%rdi
	movq	%rsp,   %rsi
	xorq	%rax,	%rax # zero rax
	call    scanf
	movzbq	(%rsp),	%r13 # end index
	subq    $48,	%r13 # subtruct '0' from value to get proper [0,255] value
	# ----------------------- #

	addq	$1,		%rsp # deallocate 1 byte

	# -- Set args for pstrijcpy -- #
	movq	%r14,	%rdi
	movq    %r15,	%rsi
	mov     %r12,	%rdx
	mov     %r13,	%rcx
	movq	$0,		%rax
	call    pstrijcpy
	# ---------------------------- #

	# -- get string length for both string and print -- #
	movq	%rax,	%r12
	movq	%rax,	%rdi
	movq	$0,		%rax
	call	pstrlen

	movq	$format_L6, %rdi
	movq	%rax,	%rsi
	movq	%r12,	%rdx
	addq	$1,		%rdx
	movq	$0,		%rax
	call	printf
	
	movq	%r15, %rdi
	movq	$0, %rax
	call	pstrlen
	
	movq    $format_L6,	%rdi
	movq    %rax,	%rsi
	movq    %r15,	%rdx
	addq	$1,		%rdx
	movq    $0,		%rax
	call    printf

	jmp     .L13
	# -------- END OF CASE 53 ------- #

# ----------- CASE 54 ----------- #
	.L7: 
	# -- set args for swapcase -- #
	movq	%rsi, %r12
	movq	%rdx, %r13
	movq	%r12, %rdi;
	call	swapCase
	# ---------------------------- #

	# --  get p1 length and print -- #
	movq	%r12, %rdi
	movq	$0, %rax
	call	pstrlen
	movq    %rax, %rsi
	movq    $format_L6, %rdi
	movq    %r12, %rdx
	addq	$1, %rdx
    movq    %rax, %rsi
    movq    $0, %rax
    call    printf
	# ------------------------------ #

	# -- get p2 length and print -- #
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
	# --------- END OF CASE 54 ------ #

# ----------- CASE 55 ----------- #
    .L8:
	# -- save p1 & p2 -- #
    pushq	%rsi # p1
    pushq	%rdx # p2
    subq	$0x8,	%rsp # allocate 8 bytes 
	# ------------------- #

	# -- set args for scan f and save both results -- #
	movq	$format_d,  %rdi
	movq	%rsp,	%rsi
	xorq	%rax,	%rax # zero %rax
	call	scanf

	movzbq  (%rsp), %r12 # start index

	movq    $format_d,  %rdi
	movq	%rsp,   %rsi
	xorq    %rax,   %rax # zero rax
	call    scanf
	movzbq  (%rsp),	%r13 # end index
	# ----------------------------------------------- #

	# ---- set args for cmp, print and finish -- #
	addq	$0x8,	%rsp 
	popq	%rdi
	popq	%rsi
	movq	%r12,	%rdx
	movq	%r13,	%rcx
	movq	$0,		%rax
	call	pstrijcmp
	movq	$format_L8,	%rdi
	movq	%rax,	%rsi
	movq	$0,		%rax
	call	printf
	jmp 	.L13
	# ---------------- END OF CASE 55 -------------- #

    .L9: # default case
        movq    $format_L9, %rdi
        movq    $0, %rax
        call    printf

# -- restore calle saved register and return -- #
.L13: # end of run_func
	popq	%r15
	popq	%r14
    popq    %r13
    popq    %r12
    popq    %rbp
    xorq    %rax, %rax
    ret
# -------------- END OF RUN_FUNC -------------- #
