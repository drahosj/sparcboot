#ifndef _mmu_bits_h
#define _mmu_bits_h

#define MMU_ASI 0x19

#define MMU_CTRL_OFFSET 0x000
#define MMU_CTXTPTR_OFFSET 0x100
#define MMU_CTXTREG_OFFSET 0x200
#define MMU_FSR_OFFSET 0x300
#define MMU_FAR_OFFSET 0x400

#define MMU_CTRL_EN 0x01

#define MMU_CTXT_TBLSIZE 0x400
#define MMU_L1_TBLSIZE 0x400
#define MMU_L23_TBLSIZE 0x100

#endif
