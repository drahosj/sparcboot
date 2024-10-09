#include "uart_registers.h"

.section .text
.global early_uart_init
early_uart_init:
    set     UART_BASE, %o0
    st      %g0, [%o0 + UART_CONTROL_OFFSET]
    st      %g0, [%o0 + UART_STATUS_OFFSET]
    
    set     911, %o1
    st      %o1, [%o0 + UART_SCALER_OFFSET]
    set     (UART_CONTROL_ENABLE_TX | UART_CONTROL_ENABLE_RX), %o1
    st      %o1, [%o0 + UART_CONTROL_OFFSET]
    retl
    nop
    nop
    

.global early_uart_puthexb
early_uart_puthexb:
    save
    srl     %i0, 4, %o0
    and     %o0, 0xf, %o0
    subcc   %o0, 10, %g0
    bl      1f
    nop
    add     %o0, 7, %o0
1: 
    call    early_uart_putc
    add     %o0, 0x30, %o0
    
    and     %i0, 0xf, %o0
    subcc   %o0, 10, %g0
    bl      1f
    nop
    add     %o0, 7, %o0
1: 
    call    early_uart_putc
    add     %o0, 0x30, %o0
    restore
    retl
    nop
    
.global early_uart_puthexw
early_uart_puthexw:
    save
    call    early_uart_puthexb
    srl     %i0, 24, %o0
    
    call    early_uart_puthexb
    srl     %i0, 16, %o0
    
    call    early_uart_puthexb
    srl     %i0, 8, %o0
    
    call    early_uart_puthexb
    mov     %i0, %o0
    
    restore
    retl
    nop
    
    

    save
    set     8, %l0
puthex_dochar:
    srl     %i0, 28, %o0
    and     %o0, 0xf, %o0
    or      %o0, 0x30, %o0
    call    early_uart_putc
    subcc   %l0, 1, %l0
    bnz     puthex_dochar
    sll     %i0, 4, %i0
    restore
    ret
    nop
    
    .seg "text"
    .global early_uart_puts
early_uart_puts:
    set     UART_BASE, %o2
3:
    ldub    [%o0], %o1
    orcc    %o1, %o1, %g0
    bz      1f
    nop

/* Wait for TE */
2:
    ld      [%o2 + UART_STATUS_OFFSET], %o3
    andcc   %o3, UART_STATUS_TE, %g0
    bz      2b
    nop

    stub    %o1, [%o2 + UART_DATA_OFFSET]
    ba      3b
    add     %o0, 1, %o0

1: 
    retl
    nop

    .global early_uart_putc
early_uart_putc:
    set     UART_BASE, %o2

2:
    ld      [%o2 + UART_STATUS_OFFSET], %o3
    andcc   %o3, UART_STATUS_TE, %g0
    bz      2b
    nop
    stub    %o0, [%o2 + UART_DATA_OFFSET]
    retl
    nop
    

    .global early_uart_getc
early_uart_getc:
    set     UART_BASE, %o2
    
1:
    ld      [%o2 + UART_STATUS_OFFSET], %o3
    btst    UART_STATUS_DR, %o3
    bz      1b
    nop     
    ld      [%o2 + UART_DATA_OFFSET], %o0
    retl
    and     %o0, 0xff, %o0

    .global early_uart_getc_nonblock
early_uart_getc_nonblock:
    set     UART_BASE, %o2
    
    ld      [%o2 + UART_STATUS_OFFSET], %o3
    btst    UART_STATUS_DR, %o3
    bz,a    1f
    set     -1, %o0

    ld      [%o2 + UART_DATA_OFFSET], %o0
    and     %o0, 0xff, %o0
1:
    retl
    nop
