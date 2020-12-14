.section .rodata

.global pstrlen
.text
pstrlen:
    xorq %rax, %rax
    movq (%rdi),%rax
    ret
