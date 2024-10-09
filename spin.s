.section .text
.global _entry
_entry:
    set 0xdeadbeef, %g1
    set 0, %g2
    nop
1:  
    inc %g2
    ba 1b
    nop
    nop
    nop
