/* Some trap handlers */
    .seg    "text"
    .align  4
_unimpl_trap: 
    ba _unimpl_trap
    nop
    nop
    nop

/* Extern'd trap handlers */
.extern start
.extern ovf_handler
.extern ovf_handler

#define ISR_JUMP(x)             \
    sethi   %hi(x), %l0;        \
    or      %l0, %lo(x), %l0;   \
    jmp     %l0        ;        \
    nop

    
    .section ".bss"
saved_shell_pointers:
    .fill 2, 4, 0

    .section ".text"
    .global save_shell_frame
save_shell_frame:
    set     saved_shell_pointers, %o0
    mov     %wim, %o1
    set     0, %o2
    st      %sp, [%o0]
    st      %o7, [%o0 + 4]
    set     1, %i0
    retl
    nop
    

#include "mmu_bits.h"
segfault_handler:
    lda     [%g0]MMU_ASI, %l3
    and     %l3, ~MMU_CTRL_EN, %l3
    sta     %l3, [%g0]MMU_ASI
    mov     0, %wim
    nop
    nop
    nop
    restore
    mov     %psr, %sp
    and     %sp, 0x1f, %sp
    save
    set     1, %l3
    sll     %l3, %sp, %l3
    mov     %l3, %wim
    set     saved_shell_pointers, %l3
    ld      [%l3], %fp
    ld      [%l3+4], %l1
    add     %l1, 8, %l1
    add     %l1, 4, %l2
    lda     [%g0]MMU_ASI, %l3
    or      %l3, MMU_CTRL_EN, %l3
    sta     %l3, [%g0]MMU_ASI
    set     0, %i0
    jmpl    %l1,%g0
    rett    %l2
    
    
    

	.section	".text.tt"
	.proc	0
	.align	4
	.global trap_table
trap_table:
/* TT = 0x00 */
    ISR_JUMP(start)
    ISR_JUMP(segfault_handler)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(ovf_handler)
    ISR_JUMP(unf_handler)
    ISR_JUMP(_unimpl_trap)

/* TT = 0x08 */
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(segfault_handler)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
