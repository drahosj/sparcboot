#include "ddr2spa.h"

    .section .rodata
.align 4
.global ddr2cfg_values
ddr2cfg_values:
    .word DDR2CFG1
    .word DDR2CFG2
    .word DDR2CFG3
    .word DDR2CFG4
    .word DDR2CFG5

.section .text
.global configure_ddr2
configure_ddr2:
    set DDR2SPA_BASE, %o1
    set ddr2cfg_values, %o2
    ld  [%o2], %o0
    st  %o0, [%o1]

    add %o1, 4, %o1
    add %o2, 4, %o2
    ld  [%o2], %o0
    st  %o0, [%o1]

    add %o1, 4, %o1
    add %o2, 4, %o2
    ld  [%o2], %o0
    st  %o0, [%o1]

    add %o1, 4, %o1
    add %o2, 4, %o2
    ld  [%o2], %o0
    st  %o0, [%o1]

    add %o1, 4, %o1
    add %o2, 4, %o2
    ld  [%o2], %o0
    st  %o0, [%o1]

    retl
    nop
