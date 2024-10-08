PREFIX=sparc-elf

CC=$(PREFIX)-gcc
AS=$(PREFIX)-gcc
LD=$(PREFIX)-ld

LIBDIR=$(HOME)/cross/$(PREFIX)/lib

CFLAGS=-g -mcpu=v8
ASFLAGS=-g

OBJECTS=uart.o bios_uart.o trap.o startup.o main.o window.o bios.o xmodem.o \
		muldiv.o shell.o mmus.o mmu.o

USERCODE_OBJECTS=usermain.o muldiv.o

default: bootram.elf usercode.bin prom.elf

sim/ram.srec: bootram.elf
	$(PREFIX)-objcopy -O srec -j '.text' $< $@

prom.srec: prom.elf
	$(PREFIX)-objcopy -O srec -j '.text' $< $@

bootram.elf: $(OBJECTS) linkram
	$(LD) -T linkram $(OBJECTS) -L$(LIBDIR) -lc -o bootram.elf

usercode.elf: $(USERCODE_OBJECTS) linkuser0
	$(LD) -T linkuser0 $(USERCODE_OBJECTS) -L$(LIBDIR) -lc -o usercode.elf

usercode.bin: usercode.elf
	$(PREFIX)-objcopy -O binary usercode.elf usercode.bin

prom.elf: prom-minimal.o linkprom-minimal
	$(LD) -T linkprom-minimal prom-minimal.o -o prom.elf

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
