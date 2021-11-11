/* Some trap handlers */
    .seg    "text"
    .align  4
_unimpl_trap: 
    ba _unimpl_trap
    nop
    nop
    nop

/* Extern'd trap handlers */
.extern start
.extern ovf_handler
.extern ovf_handler

#define ISR_JUMP(x)             \
    sethi   %hi(x), %l0;        \
    or      %l0, %lo(x), %l0;   \
    jmp     %l0        ;        \
    nop

	.section	".text.tt"
	.proc	0
	.align	4
	.global trap_table
trap_table:
/* TT = 0x00 */
    ISR_JUMP(start)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(ovf_handler)
    ISR_JUMP(unf_handler)
    ISR_JUMP(_unimpl_trap)

/* TT = 0x08 */
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
    ISR_JUMP(_unimpl_trap)
