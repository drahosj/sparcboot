#include "uart_registers.h"

    .seg "text"
    .global bios_uart_puts
bios_uart_puts:
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

    .global bios_uart_write
bios_uart_write:
    set     UART_BASE, %o2
3:
    deccc   %o1
    bneg    1f
    nop

    ldub    [%o0], %o4

/* Wait for TE */
2:
    ld      [%o2 + UART_STATUS_OFFSET], %o3
    andcc   %o3, UART_STATUS_TE, %g0
    bz      2b
    nop

    stub    %o4, [%o2 + UART_DATA_OFFSET]
    ba      3b
    add     %o0, 1, %o0

1: 
    retl
    nop

    .global bios_uart_putc
bios_uart_putc:
    set     UART_BASE, %o2

2:
    ld      [%o2 + UART_STATUS_OFFSET], %o3
    andcc   %o3, UART_STATUS_TE, %g0
    bz      2b
    nop
    stub    %o1, [%o2 + UART_DATA_OFFSET]
    retl
    nop

    .global bios_uart_getc
bios_uart_getc:
    set     UART_BASE, %o2
    
1:
    ld      [%o2 + UART_STATUS_OFFSET], %o3
    btst    UART_STATUS_DR, %o3
    bz      1b
    nop     
    ld      [%o2 + UART_DATA_OFFSET], %o0
    retl
    and     %o0, 0xff, %o0

    .global bios_uart_getc_nonblock
bios_uart_getc_nonblock:
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
