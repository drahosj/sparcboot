Working configuration

BITFILE
bitfiles/leon3mp-jtagdebug-ahbram.bit/bin
 - bin for qspi flash, bit for hot load

Links with linkprom
AHBROM + AHBRAM, as set by config.vhd.

QSPI boot isn't working, QSPI config with ahbrom boot is.

Notes on boot:
- AHBROM at 0x0000000, beginning with trap table
- AHBRAM at 0xa000000, 16k, stack grows from top

startup.S runs, does minimal init
Does not do any extra hardware init beyond the IU
init routines (FPU exists but is skipped at runtime)
and configures the uart

Multi-core init code was butchered pretty badly, probably won't work.

BSS is zeroed (I think)
.data is not handled
.text and .rodata are the only things linked into ROM

Known issues
.data not handled
 - variables are broken (segfault)

