/* Extern'd BIOS implementations */

#define LONG_JUMP(x)            \
    sethi   %hi(x), %o5;        \
    or      %o5, %lo(x), %o5;   \
    jmp     %o5;                \
    nop

    .section    ".text"
    .align 4
    .global _bios_unimpl
_bios_unimpl:
    ba _bios_unimpl
    nop
    nop
    nop

	.section	".text.bios"
	.proc	0
	.align	4
	.global bios_table
bios_table:
/* BIOS = 0x00 */
    LONG_JUMP(uart_putc)
    LONG_JUMP(bios_uart_puts)
    LONG_JUMP(bios_uart_getc)
    LONG_JUMP(bios_uart_getc_nonblock)
    LONG_JUMP(bios_busywait)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)

/* BIOS = 0x80 */
    LONG_JUMP(uart_readline)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)

/* BIOS = 0x100 */
    LONG_JUMP(bios_uart_write)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)
    LONG_JUMP(_bios_unimpl)

bios_busywait:
    cmp     %o0, 0
    bz      1f
    set     30000, %o1
2:
    deccc   %o1
    bnz     2b
    nop
    ba      bios_busywait
    dec     %o0
    
1:
    retl
    nop
