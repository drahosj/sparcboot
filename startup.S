/* derived from GRLIB boot code */

/* Template boot-code for LEON3 test benches */

#include "startup.h"

#ifndef STACKSIZE
#define STACKSIZE 0x00001000
#endif


.seg	"text"
.proc	0
.align	4
.global start
start:
! We get here via RESET trap probably
! In sim, ahbrom jumps to 0x40000000, which has the
! trap table loaded already, which jumps here
	! TRAP_TABLE_START = 0x40000000
! With LINKROM, trap table is at 0x0 (entry at RESET handler)
	! and TRAP_TABLE_START is left at 0x0 by the linker script
! so this is basically a NOP (leave trap table in ROM)
	flush
	set 0x10e0, %g1		! init IU
	mov %g1, %psr
	mov %g0, %wim
	set TRAP_TABLE_START, %g1
	mov %g1, %tbr
	mov %g0, %y
	mov %g0, %asr16
	nop
	set  0x81000f, %g1
	sta %g1, [%g0] 2
	mov %g0, %g2
	nop
	nop
	nop
	nop
	nop
	or %g2, %g2, %g0
	nop
	nop
	nop
	nop
	nop
#ifdef DSUADDR
	set	DSUADDR, %g2
	st	%g0, [%g2]
	st	%g0, [%g2+0x08]
	st	%g0, [%g2+0x20]
	st	%g0, [%g2+0x24]
	st	%g0, [%g2+0x40]
	st	%g0, [%g2+0x44]
	st	%g0, [%g2+0x50]
	st	%g0, [%g2+0x54]
	st	%g0, [%g2+0x58]
	st	%g0, [%g2+0x5C]
	st	%g0, [%g2+0x54]
#endif

	! Get NWINDOWS and zero all windows
	2:
	mov %asr17, %g3
	and %g3, 0x1f, %g3
	mov %g0, %g4
	mov %g0, %g5
	mov %g0, %g6
	mov %g0, %g7
	1:
	mov %g0, %l0
	mov %g0, %l1
	mov %g0, %l2
	mov %g0, %l3
	mov %g0, %l4
	mov %g0, %l5
	mov %g0, %l6
	mov %g0, %l7
	mov %g0, %o0
	mov %g0, %o1
	mov %g0, %o2
	mov %g0, %o3
	mov %g0, %o4
	mov %g0, %o5
	mov %g0, %o6
	mov %g0, %o7
	subcc %g3, 1, %g3
	bge 1b
	save

	! Set initial window
	mov	2, %g1
	mov	%g1, %wim
	set 0x10e0, %g1		! enable traps
	mov %g1, %psr
	nop; nop; nop;

	mov %psr, %g1
	srl %g1, 12, %g1
	andcc %g1, 1, %g0
	be 1f ! skip FPU init
	nop

	set _fsrxx, %g3
	ld [%g3], %fsr
	ldd [%g3], %f0
	ldd [%g3], %f2
	ldd [%g3], %f4
	ldd [%g3], %f6
	ldd [%g3], %f8
	ldd [%g3], %f10
	ldd [%g3], %f12
	ldd [%g3], %f14
	ldd [%g3], %f16
	ldd [%g3], %f18
	ldd [%g3], %f20
	ldd [%g3], %f22
	ldd [%g3], %f24
	ldd [%g3], %f26
	ldd [%g3], %f28
	ldd [%g3], %f30
	nop
	nop
	nop
	faddd %f0, %f2, %f4
	nop
	nop
1:

/* Early uart init and hello */
	nop
	.extern early_uart_init
	call early_uart_init
	nop
	.extern early_uart_putc
	set 'S', %o0
	call early_uart_putc
	nop
	set '\n', %o0
	call early_uart_putc
	nop
	set early_hello, %o0
	call early_uart_puts
	nop


#if MULTI_CORE
	/* Get core index into %g3 */
	mov %asr17, %g3
	srl %g3, 28, %g3
	andcc %g3, 0x0f, %g3
	bne 1f

	/* Only perform this on core0 */
#ifdef DDR2CTRLIO
	set DDR2CTRLIO, %g1
	set DDR2CFG1, %g2
	st  %g2, [%g1]
	set DDR2CFG3, %g2
	st  %g2, [%g1+0x8]
	set DDR2CFG4, %g2
	st  %g2, [%g1+0xc]
	set DDR2CFG5, %g2
	st  %g2, [%g1+0x10]

	set  DDR2CFG1, %g2
	set  0x10000, %g1
	or   %g2, %g1, %g2
	set DDR2CTRLIO, %g1
	st   %g2, [%g1]
#endif

#ifdef L2MCTRLIO
	set L2MCTRLIO, %g1
	set MCFG1, %g2
	st  %g2, [%g1]
	set MCFG2, %g2
	st  %g2, [%g1+4]
	set MCFG3, %g2
	st  %g2, [%g1+8]
#endif

	!	set IRQCTRL, %g1
	!	set 0x0ffff, %g2
	!	st  %g2, [%g1+0x10]

#ifdef ASDCFG
#ifndef SDCTRLPNP
#define SDCTRLPNP 0xFFFFF860
#endif
	set SDCTRLPNP, %g1
	ld  [%g1], %g2
	srl %g2, 12, %g2
	/* Checks if it's a SDRAM controller - probably unneeded*/
	set 0x01009, %g1
	subcc %g1, %g2, %g0
	bne 1f

	set ASDCFG, %g1
	set DSDCFG, %g2
	st  %g2, [%g1]
#endif

	! %g3 = cpu index
	1:	set STACKSIZE, %g2
	mov %g0, %g1
	2:	subcc %g3, 0, %g0
	be 3f
	nop
	add %g1, %g2, %g1
	ba 2b
	sub %g3, 1, %g3
#endif


	/*3:	set RAMSTART+ RAMSIZE-32, %fp*/
	3:  set RAM_END - 32, %fp
#ifdef MULTI_CORE
	sub %fp, %g1, %fp
#endif
	sub %fp, 96, %sp

	set __bss_start, %g1
	set _end, %g2

	/* zero BSS */
	1:
	clr [%g1]
	add %g1, 4, %g1
	cmp %g1, %g2
	bne 1b  
	nop

#define COPY_DATA
#ifdef COPY_DATA
    set _sdata, %g1
    set _data_load_start, %g2
    set _edata, %g3
1:
    ld  [%g2], %g4
    st  %g4, [%g1]
    add %g1, 4, %g1
    add %g2, 4, %g2
    cmp %g1, %g3
    bl  1b
    nop
#endif

	set main, %g1

	jmp %g1
	nop

	.align	32

.section ".rodata"
.align	8
_fsrxx:
.word 0
.word 0
early_hello:
.string "Hello, world."
