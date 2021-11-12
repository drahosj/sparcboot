    .section ".text"
    .align 32
    .global .div
.div:
    sra     %o0, 0x1f, %o2
    wr      %o2, %y
    nop
    nop
    nop
    sdiv    %o0, %o1, %o0
    retl

    .global .rem
.rem:
    sra     %o0, 0x1f, %o2
    wr      %o2, %y
    nop
    nop
    nop
    sdiv    %o0, %o1, %o2
    smul    %o2, %o1, %o1
    sub     %o0, %o1, %o0
    retl

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
