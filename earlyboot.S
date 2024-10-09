
.section .rodata
hellostr:
    .string "Hello, world (EARLY BOOT VERSION)\r\n"
secondstr:
    .string "Copied to stack (if stack works...)\r\n"
crlf:
    .string "\r\n"
    
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

#define CONFIGURE_DDR2
#ifdef CONFIGURE_DDR2
    call    configure_ddr2
    nop
#endif
    
    set     0x15, %o0
    call    early_uart_puthexb
    nop
    
    call    early_uart_puthexb
    set     0xde, %o0
    
    set     crlf, %o0
    call    early_uart_puts
    nop
    
    set     0x13247680, %o0
    call    early_uart_puthexw
    nop
    
    set     crlf, %o0
    call    early_uart_puts
    nop
    
    set     0xdeadbeef, %o0
    call    early_uart_puthexw
    nop
    
    set     crlf, %o0
    call    early_uart_puts
    nop
    
    call    early_uart_puthexw
    mov     %fp, %o0
    
    
    set     crlf, %o0
    call    early_uart_puts
    nop
    
    set     secondstr, %o1
    sub     %sp, 64, %l0
    call    strcpy
    mov     %l0, %o0
    call    early_uart_puts
    mov     %l0, %o0
    
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
