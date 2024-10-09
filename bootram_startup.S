// Relocate trap base register

.section .text
.global start
start:
! point at trap table in RAM
    set _LINKSCRIPT_RAM_START, %g1
    mov %g1, %tbr
    nop

! zero BSS
    set _bss_start, %g1
    set _bss_end, %g2
1:
    st      %g0, [%g1]
    add     %g1, 4, %g1
    subcc   %g2, %g1, %g0
    bne     1b
    nop

    call shell_entry
    nop
    nop
1:
    ba 1b
    nop
    nop
