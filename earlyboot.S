
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
    
    set     'B', %o0
    call    early_uart_putc
    nop
    
    set     '\r', %o0
    call    early_uart_putc
    nop
    
    set     '\n', %o0
    call    early_uart_putc
    nop
    
    set     hellostr, %o0
    call    early_uart_puts
    nop
    /*
    
    set     0x15, %o0
    call    early_uart_puthexb
    nop
    
    call    early_uart_puthexb
    set     0xde, %o0
    
    set     '\r', %o0
    call    early_uart_putc
    nop
    set     '\n', %o0
    call    early_uart_putc
    nop
    
    
    set     0x13247680, %o0
    call    early_uart_puthexw
    nop
    
    call    early_uart_putc
    add     %g0, '\r', %o0
    call    early_uart_putc
    add     %g0, '\n', %o0
    nop
    
    set     0xdeadbeef, %o0
    call    early_uart_puthexw
    nop
    
    call    early_uart_putc
    add     %g0, '\r', %o0
    call    early_uart_putc
    add     %g0, '\n', %o0
    nop
    
    set     hellostr, %o0
    call    early_uart_puts
    nop
    
    set     '\r', %o0
    call    early_uart_putc
    nop
    set     '\n', %o0
    call    early_uart_putc
    nop
    */
    call    early_uart_puthexw
    mov     %fp, %o0
    
    call    early_uart_putc
    or      %g0, '\r', %o0
    call    early_uart_putc
    or      %g0, '\n', %o0
    
    set     _LINKSCRIPT_DDR2_START, %l0
    jmp     %l0
    nop
    nop
    nop
    nop
    nop
loop:
    ba      loop
    nop
    nop

    /*
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
    */
