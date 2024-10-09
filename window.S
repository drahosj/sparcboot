    .section ".rodata"
str_ovf_spill1: .string "Spilled ins.\r\n"
str_ovf_spill2: .string "Spilled locals.\r\n"

    .seg    "text"
    .align  4
    
    .global ovf_handler
ovf_handler:
    /* Unset WIM */
    mov %g0, %wim
    nop
    nop
    nop

    save
    /* Spill ins */
    st  %i0, [%sp+0x00]
    st  %i1, [%sp+0x04]
    st  %i2, [%sp+0x08]
    st  %i3, [%sp+0x0c]
    st  %i4, [%sp+0x10]
    st  %i5, [%sp+0x14]
    st  %i6, [%sp+0x18]
    st  %i7, [%sp+0x1c]

    /* Spill locals */
    st  %l0, [%sp+0x20]
    st  %l1, [%sp+0x24]
    st  %l2, [%sp+0x28]
    st  %l3, [%sp+0x2c]
    st  %l4, [%sp+0x30]
    st  %l5, [%sp+0x34]
    st  %l6, [%sp+0x38]
    st  %l7, [%sp+0x3c]

    /* Back to ISR's window */
    restore

    /* Update WIM */
    /* nwindows in %l3 */
    mov     %asr17, %l3
    and     %l3, 0x1f, %l3

    /* CWP of old invalid window in %l4 */
    mov     %psr, %l4
    and     %l4, 0x1f, %l4
    
    /* New invalid window = CWP - 1 */
    subcc   %l4, 1, %l4
    bpos    1f
    or      %g0, 1, %l5
    mov     %l3, %l4 /* Set to NWINDOWS if underflows 0 */
1:  sll     %l5, %l4, %l5
    mov     %l5, %wim

    /* Return */
    jmp     %l1
    rett    %l2
    
    .global unf_handler
unf_handler:
    mov %g0, %wim
    nop
    nop
    nop
    
    restore
    restore

    /* Fill ins */
    ld      [%sp+0x00], %i0
    ld      [%sp+0x04], %i1
    ld      [%sp+0x08], %i2
    ld      [%sp+0x0c], %i3
    ld      [%sp+0x10], %i4
    ld      [%sp+0x14], %i5
    ld      [%sp+0x18], %i6
    ld      [%sp+0x1c], %i7

    /* Fill locals */
    ld      [%sp+0x20], %l0
    ld      [%sp+0x24], %l1
    ld      [%sp+0x28], %l2
    ld      [%sp+0x2c], %l3
    ld      [%sp+0x30], %l4
    ld      [%sp+0x34], %l5
    ld      [%sp+0x38], %l6
    ld      [%sp+0x3c], %l7

    save
    /* Update WIM */
    /* nwindows in %l3 */
    mov     %asr17, %l3
    and     %l3, 0x1f, %l3
    add     %l3, 1, %l3 /* nwindows += 1 to make modulo math easier */

    /* CWP of current window in %l4 */
    mov     %psr, %l4
    and     %l4, 0x1f, %l4
    
    /* New invalid window = CWP + 1 */
    add     %l4, 2, %l4
    subcc   %l4, %l3, %g0
    bl      1f
    or      %g0, 1, %l5
    sub     %l4, %l3, %l4 /* Subtract (NWINDOWS+1) from new invalid window */
1:  sll     %l5, %l4, %l5
    mov     %l5, %wim

    /* Return */
    save
    jmp     %l1
    rett    %l2
