PREFIX=sparc-elf

CC=$(PREFIX)-gcc
AS=$(PREFIX)-gcc
LD=$(PREFIX)-ld

LIBDIR=$(HOME)/cross/$(PREFIX)/lib

CFLAGS=-g
ASFLAGS=-g

OBJECTS=uart.o bios_uart.o trap.o startup.o main.o window.o bios.o

default: bootram.elf

bootram.elf: $(OBJECTS) linkram
	$(LD) -T linkram $(OBJECTS) -L$(LIBDIR) -lc -o bootram.elf

clean:
	rm *.o *.elf
