/* Template boot-code for LEON3 test benches */

/* "absolute minimal" PROM example, just performs IU/FPU
 * initialization and jump to RAM.
 *
 * This is suitable for sim usage where RAM can just be magically
 * loaded, bss/data already set up, etc
 * 
 * Also suitable for external loading e.g. PCIe or debugger
 *
 */

#include "prom-minimal.h"

#ifndef STACKSIZE
#define STACKSIZE 0x00020000
#endif


	.seg	"text"
	.proc	0
	.align	4
	.global start
start:

	flush
	set 0x10e0, %g1		! init IU
	mov %g1, %psr
	mov %g0, %wim
	mov %g0, %tbr       ! Should be changed by later startup code
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
2:
	mov %asr17, %g3     ! NWINDOWS
	and %g3, 0x1f, %g3
	mov %g0, %g4
	mov %g0, %g5
	mov %g0, %g6
	mov %g0, %g7
1:                      ! Zero locals loop
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

	mov	2, %g1
	mov	%g1, %wim
	set 0x10e0, %g1		! enable traps
	mov %g1, %psr
	nop; nop; nop;

	mov %psr, %g1
	srl %g1, 12, %g1
	andcc %g1, 1, %g0
	be 1f               ! Skip FPU init if !EF
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
	nop
	nop
	faddd %f0, %f2, %f4
	nop
	nop
	nop
	nop
	ba  1f	
	nop
	
	
1:
	mov %asr17, %g3
	srl %g3, 28, %g3        ! Processor index
	andcc %g3, 0x0f, %g3
	bne 1f                  ! Skip memory initialization if not CPU0

    /* DDR2 initialization removed */

    /* LEON2 RAM controller initialization
     * Used for sim RAM
     */
	set L2MCTRLIO, %g1
	set MCFG1, %g2
	st  %g2, [%g1]
	set MCFG2, %g2
	st  %g2, [%g1+4]
	set MCFG3, %g2
	st  %g2, [%g1+8]
	set IRQCTRL, %g1
	set 0x0ffff, %g2
	st  %g2, [%g1+0x10]

    /* SD controller initialization removed */

/* Set initial FP based on CPU index */
	mov %asr17, %g3
	srl %g3, 28, %g3        ! Processor index
	andcc %g3, 0x0f, %g3

1:	set STACKSIZE, %g2
    mov %g0, %g1
2:	subcc %g3, 0, %g0
	be 3f
	nop
	add %g1, %g2, %g1
	ba 2b
	sub %g3, 1, %g3

! %g1 = STACKSIZE * CPUINDEX


3:	set STACKTOP-32, %fp
	sub %fp, %g1, %fp
	sub %fp, 96, %sp

.global jump_to_startup
jump_to_startup:
	set _startup, %g1

	jmp %g1
	nop

.section .rodata
_fsrxx:
	.word 0
	.word 0

.align	32
