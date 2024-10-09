#include "xmodem.h"

    .section ".text"
.extern early_uart_putc
.extern early_uart_getc
.extern early_uart_getc_nonblock

    .global xmodem_recv
xmodem_recv:
    save
    mov     %i0, %i1
    set     1, %l0

sync:
    call    early_uart_putc
    set     NAK, %o0
    set     500000, %l1
check:
    call    early_uart_getc_nonblock
    nop
    cmp     %o0, 0
    bg      sync_enter
    nop

    deccc   %l1
    bnz     check
    nop

    ba      sync
    nop

begin_block:
    call    early_uart_getc
    set     0, %l7

sync_enter:

    cmp     %o0, EOT
    be      begin_exit
    nop

    cmp     %o0, SOH
    bne,a   end
    set     -ENOSOH, %i0

    call    early_uart_getc
    nop
    mov     %o0, %l1
    call    early_uart_getc
    nop
    add     %o0, %l1, %o0
    cmp     %o0, 0xff
    bne,a   1f
    set     1, %l7
1:
    cmp     %l1, %l0
    bg,a    end
    set     -ESKIPPED, %i0

    set     0, %l2
recv_data:
    call    early_uart_getc
    nop
    stub    %o0, [%i0 + %l2]
    inc     %l2
    cmp     %l2, 128
    bl      recv_data
    nop

    call    early_uart_getc
    nop
    /* ignore checksum */

    cmp     %l7, 0
    bnz     nack_block
    nop

    add     %i0, %l2, %i0
    inc     %l0
    call    early_uart_putc
    set     ACK, %o0
    ba      begin_block

nack_block:
    call    early_uart_putc
    set     NAK, %o0
    ba      begin_block
    
begin_exit:
    call early_uart_putc
    set     ACK, %o0

#ifdef EXPECT_ETB
    call early_uart_getc
    nop
    
    cmp     %o0, ETB
    bne,a   1f
    set     -ENOETB, %i0
#endif

    sub     %i0, %i1, %i0
    call    early_uart_putc
    set     ACK, %o0
    ba      end
    nop
1:
    call    early_uart_putc
    set     NAK, %o0
end:
    ret     
    restore
