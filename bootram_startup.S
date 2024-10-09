// Relocate trap base register

.section .text
.global start
start:
    set _LINKSCRIPT_RAM_START, %g1
    mov %g1, %tbr
    nop
    call shell_entry
    nop
    nop
1:
    ba 1b
    nop
    nop
