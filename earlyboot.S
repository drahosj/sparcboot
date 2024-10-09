.extern early_uart_puts

.section .rodata
hellostr:
    .string "Hello, world (EARLY BOOT VERSION)\r\n"
secondstring:
    .string "Copied to stack (if stack works...)\r\n"

.section .text
.global _startup
_startup:
    call    early_uart_init
    nop
    nop
    set     'B', %o1
    call    early_uart_putc
    nop
    nop
    set     '\r', %o1
    call    early_uart_putc
    nop
    nop
    set     '\n', %o1
    call    early_uart_putc
    nop
    nop
    set     hellostr, %o0
    call    early_uart_puts
    nop
    nop
    nop
    
    set     _LINKSCRIPT_DDR2_START, %l0
    jmp     %l0
    nop
    nop
loop:
    ba      loop
    nop
    nop

strcpy:
    ld      [%o1], %o2
    tst     %o2
    bz      strcpy_done
    st      %o2, [%o0]
    add     %o0, 4, %o0
    ba      strcpy
    add     %o1, 4, %o1
strcpy_done:
    retl
    nop
