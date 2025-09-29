PREFIX=sparc-elf

CC=$(PREFIX)-gcc
AS=$(PREFIX)-gcc
LD=$(PREFIX)-ld

LIBDIR=$(HOME)/cross/$(PREFIX)/lib

CFLAGS=-g -mcpu=v8
ASFLAGS=-g

BOOTRAM_OBJECTS=uart.o early_uart.o trap.o main.o window.o xmodem.o \
		muldiv.o shell.o mmus.o mmu.o bootram_startup.o

USERCODE_OBJECTS=usermain.o muldiv.o

default: prom.elf

sim/ram.srec: bootram.elf
	$(PREFIX)-objcopy -O srec -j '.text*' -j '.rodata*' $< $@

bootram.bin: bootram.elf
	$(PREFIX)-objcopy -O binary  $< $@

prom.srec: prom.elf
	$(PREFIX)-objcopy -O srec -j '.text*' -j '.rodata*' $< $@

bootram.elf: $(BOOTRAM_OBJECTS) linkram
	$(LD) -T linkram $(BOOTRAM_OBJECTS) -L$(LIBDIR) -lc -o bootram.elf

usercode.elf: $(USERCODE_OBJECTS) linkuser0
	$(LD) -T linkuser0 $(USERCODE_OBJECTS) -L$(LIBDIR) -lc -o usercode.elf

usercode.bin: usercode.elf
	$(PREFIX)-objcopy -O binary usercode.elf usercode.bin

prom-minimal: prom-minimal.o linkprom-minimal
	$(LD) -T linkprom-minimal prom-minimal.o --defsym _startup=_LINKSCRIPT_DDR2_START -o prom.elf

prom-dev: prom-minimal.o earlyboot.o early_uart.o linkprom-minimal
	$(LD) -T linkprom-minimal prom-minimal.o earlyboot.o early_uart.o -o prom.elf

DDR2PROM_OBJECTS=prom-minimal.o earlyboot.o early_uart.o ddr2spa.o \
				 trap.o window.o main.o muldiv.o xmodem.o	\
				 uart.o list.o shell.o mmu.o mmus.o

prom-ddr2: $(DDR2PROM_OBJECTS) linkprom
	$(LD) -T linkprom $(DDR2PROM_OBJECTS) -o prom.elf -L$(LIBDIR) -lc

prom-sim: $(DDR2PROM_OBJECTS) linkprom
	$(LD) -T linkprom-sim $(DDR2PROM_OBJECTS) -o prom.elf -L$(LIBDIR) -lc

prom.elf: prom-sim

prom.bin: prom.elf
	$(PREFIX)-objcopy -O binary -j '.text*' -j '.rodata*' prom.elf prom.bin

flash-image.bin: prom.bin bitfile-headerless
	cp bitfile-headerless flash-image.bin
	truncate -s 4M flash-image.bin
	cat prom.bin >> flash-image.bin

sim: sim/build

sim/build: sim/ram.srec sim/ahbrom.vhd
	cd sim && ruby build.rb build

run: sim/build
	cd sim && ruby build.rb run

sim/ahbrom.vhd: prom.srec ahbrom.vhd.erb
	erb ahbrom.vhd.erb > sim/ahbrom.vhd

clean:
	rm -f *.o *.elf *.bin *.srec sim/*.srec sim/ahbrom.vhd
	cd sim && rm -rf build
