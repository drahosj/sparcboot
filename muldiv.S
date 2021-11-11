    .section ".text"
    .align 32
    .global .div
.div:
    mov     0, %o2
    ba      2f
    nop
1:
    inc     %o2
    sub     %o0, %o1, %o0
2:
    cmp     %o0, %o1
    bge     1b
    nop
    mov     %o2, %o0
    jmp     %o7+4
    nop

    .global .rem
.rem:
    ba      2f
    nop
1:
    sub     %o0, %o1, %o0
2:
    cmp     %o0, %o1
    bge     1b
    nop
    jmp     %o7+4
    nop

    .global .udiv
.udiv:
    sra     %o0, 0x1f, %o2
    wr      %o2, %y
    nop
    nop
    nop
    udiv    %o0, %o1, %o0
    retl

    .global .urem
.urem:
    sra     %o0, 0x1f, %o2
    wr      %o2, %y
    nop
    nop
    nop
    udiv    %o0, %o1, %o2
    umul    %o1, %o2, %o1
    sub     %o0, %o1, %o0
    retl

    .global .umul
.umul:
    umul    %o0, %o1, %o0
    rd      %y, %o1
    retl
