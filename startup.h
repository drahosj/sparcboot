#define MCFG1 0x10380133
#define MCFG2 0xe6B8165f
#define MCFG3 0x000ff000
#define ASDCFG 0xfff00100
#define DSDCFG 0x922083cd
#define L2MCTRLIO 0x80000000
#define IRQCTRL   0x80000200
#define RAMSTART  0x40000000
#define RAMSIZE   0x08000000

/*
#define DDR2CTRLIO      0xfff00100
#define DDR2CFG1    0x86208491
#define DDR2CFG3    0x02d10000
//#define DDR2CFG3    0x12d00000
#define DDR2CFG4    0x00000100
#define DDR2CFG5    0x10530104
*/

.extern main
.extern start
