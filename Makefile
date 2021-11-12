PREFIX=sparc-elf

CC=$(PREFIX)-gcc
AS=$(PREFIX)-gcc
LD=$(PREFIX)-ld

LIBDIR=$(HOME)/cross/$(PREFIX)/lib

LDC_TRIPLE=-mtriple=$(PREFIX)

DFLAGS=$(LDC_TRIPLE) -g -mcpu=v8
CFLAGS=-g -mcpu=v8
ASFLAGS=-g

OBJECTS=uart.o bios_uart.o trap.o startup.o main.o window.o bios.o xmodem.o \
		muldiv.o shell.o core/string.o core/bios.o

USERCODE_OBJECTS=usermain.o muldiv.o

%.o: %.d
	ldc2 -betterC $(DFLAGS) -c -of=$@ $<

default: bootram.elf usercode.bin

bootram.elf: $(OBJECTS) linkram
	$(LD) -T linkram $(OBJECTS) -L$(LIBDIR) -lc -o bootram.elf

usercode.elf: $(USERCODE_OBJECTS) linkuser
	$(LD) -T linkuser $(USERCODE_OBJECTS) -L$(LIBDIR) -lc -o usercode.elf

usercode.bin: usercode.elf
	$(PREFIX)-objcopy -O binary usercode.elf usercode.bin

clean:
	rm -f *.o *.elf core/*.o
