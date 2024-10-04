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

default: bootram.elf usercode.bin sim/ram.srec bootrom.elf rom.srec

sim/bootram.srec: bootram.elf
	$(PREFIX)-objcopy -O srec -j '.text' $< $@

rom.srec: bootrom.elf
	$(PREFIX)-objcopy -O srec -j '.text' $< $@

bootram.elf: $(OBJECTS) linkram
	$(LD) -T linkram $(OBJECTS) -L$(LIBDIR) -lc -o bootram.elf

usercode.elf: $(USERCODE_OBJECTS) linkuser0
	$(LD) -T linkuser0 $(USERCODE_OBJECTS) -L$(LIBDIR) -lc -o usercode.elf

usercode.bin: usercode.elf
	$(PREFIX)-objcopy -O binary usercode.elf usercode.bin

bootrom.elf: $(OBJECTS) linkrom
	$(LD) -T linkrom $(OBJECTS) -L$(LIBDIR) -lc -o bootrom.elf

clean:
	rm -f *.o *.elf *.bin
