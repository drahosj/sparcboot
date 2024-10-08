#include "uart.h"
#include "bios.h"
#include "shell.h"

#include <string.h>
#include <stdlib.h>

extern int xmodem_recv(unsigned int addr);

void f9() { bios_puts("Made it to 9\r\n"); }
void f8() { f9(); bios_puts("f8 returning\r\n");}
void f7() { f8(); bios_puts("f7 returning\r\n");}
void f6() { f7(); bios_puts("f6 returning\r\n");}
void f5() { f6(); bios_puts("f5 returning\r\n");}
void f4() { f5(); bios_puts("f4 returning\r\n");}
void f3() { f4(); bios_puts("f3 returning\r\n");}
void f2() { f3(); bios_puts("f2 returning\r\n");}
void f1() { f2(); bios_puts("f1 returning\r\n");}

void _write(char *b, int len)
{
      for (int i = 0; i < len; i++) {
            uart_putc(b[i]);
      }
}

int fib(int n)
{
      if (n <= 1) {
            return n;
      } else {
            return fib(n-1) + fib(n-2);
      }
}

void putn(int n)
{
      char buf[256];
      int i = 0;

      if (n < 0) {
            n = -n;
            bios_puts("-");
      }
      
      do {
            buf[i++] = (n % 10) + 0x30;
            n = n / 10;
      } while (n > 0);

      char buf2[256];
      for (int j = 0; j < i; j++) {
            buf2[j] = buf[(i - j) - 1];
      }
      buf2[i] = '\0';
      bios_puts(buf2);
}

void puth(unsigned int n)
{
      char buf[256];
      int i = 0;

      do {
            char c = (n % 16) + 0x30;
            if (c > '9') {
                  c += 0x27;
            }
            buf[i++] = c;
            n = n / 16;
      } while (n > 0);

      char buf2[256];
      for (int j = 0; j < i; j++) {
            buf2[j] = buf[(i - j) - 1];
      }
      buf2[i] = '\0';
      bios_puts("0x");
      bios_puts(buf2);
}

int main()
{
      uart_init();

      uart_putc('H');
      uart_putc('e');
      uart_putc('l');
      uart_putc('l');
      uart_putc('o');
      uart_putc(' ');
      uart_putc('w');
      uart_putc('o');
      uart_putc('r');
      uart_putc('l');
      uart_putc('d');
      uart_putc('!');
      uart_putc('\r');
      uart_putc('\n');

      bios_puts("BIOS PUTS TEST\r\n");
      bios_puts("Second BIOS message\r\n");
#if 1
      f1();
      bios_puts("Made it back\r\n");

      int ans = 2;

      if (7 / 3 == ans) 
            bios_puts("division is good\r\n");

      if (22 % 4 == ans) 
            bios_puts("mod is good\r\n");

      putn(7);
      putn(42);

      if (fib(0) == 0)
            bios_puts("fib(0) good\r\n");
      if (fib(1) == 1)
            bios_puts("fib(1) good\r\n");
      if (fib(2) == 1)
            bios_puts("fib(2) good\r\n");
      if (fib(3) == 2)
            bios_puts("fib(3) good\r\n");
      if (fib(4) == 3)
            bios_puts("fib(4) good\r\n");
      if (fib(5) == 5)
            bios_puts("fib(5) good\r\n");
      if (fib(6) == 8)
            bios_puts("fib(6) good\r\n");
      if (fib(7) == 13)
            bios_puts("fib(7) good\r\n");
      if (fib(8) == 21)
            bios_puts("fib(8) good\r\n");
      if (fib(9) == 34)
            bios_puts("fib(9) good\r\n");
      if (fib(10) == 55)
            bios_puts("fib(10) good\r\n");
      if (fib(11) == 89)
            bios_puts("fib(11) good\r\n");
      if (fib(12) == 144)
            bios_puts("fib(12) good\r\n");

      char * foo = "Hello, world\r\n";
      char buf[128];
      strcpy(buf, foo);

      bios_puts(buf);
      bios_putc('Z');
      bios_putc('X');
      bios_putc('\n');

      bios_puts("324 is ");
      putn(atoi("324"));
      bios_putc('\n');

      bios_puts("0x3bfa is ");
      puth(strtol("0x3bfa", NULL, 0));
      bios_putc('\n');

#endif
      bios_puts(" -- IF THIS IS THE LAST THING YOU SEE -- \r\n");
      bios_puts(" it's probably because the stock sim function of apbuart\r\n");
      bios_puts("handles \\n wrong and only commits the line on \\r, \r\n");
      bios_puts("\n\n");
      bios_puts("Been using \\r\\n until now which is weird\r\n");
      bios_puts("Need to patch grlib apbuart.vhd to print on LF not CR\r\n");

      bios_puts("ends with just \n");
      bios_puts("About to call shell_entry\n");
      shell_entry();
      bios_puts("somehow shell returned\n");

      for(;;);
}
