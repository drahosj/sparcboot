#include "mmu_bits.h"

    .section .text

    .global mmu_set_contextptr
mmu_set_contextptr:
    set     MMU_CTXTPTR_OFFSET, %o1
    sta     %o0, [%o1]MMU_ASI
    retl
    nop

    .global mmu_set_context
mmu_set_context:
    set     MMU_CTXTREG_OFFSET, %o1
    sta     %o0, [%o1]MMU_ASI
    retl
    nop

    .global mmu_enable
mmu_enable:
    set     MMU_CTRL_OFFSET, %o1
    lda     [%o1]MMU_ASI, %o0
    or      %o0, MMU_CTRL_EN, %o0
    sta     %o0, [%o1]MMU_ASI
    retl
    nop

    .global mmu_disable
mmu_disable:
    set     MMU_CTRL_OFFSET, %o1
    lda     [%o1]MMU_ASI, %o0
    and     %o0, 0xFFFFFFFE, %o0
    sta     %o0, [%o1]MMU_ASI
    retl
    nop
