#include "uart.h"
#include "early_uart.h"
#include "shell.h"
#include "xmodem.h"

#include <string.h>
#include <stdlib.h>

extern int xmodem_recv(void *);
extern unsigned int _LINKSCRIPT_RAM_START;

void f9() { early_uart_puts("Made it to 9\r\n"); }
void f8() { f9(); early_uart_puts("f8 returning\r\n");}
void f7() { f8(); early_uart_puts("f7 returning\r\n");}
void f6() { f7(); early_uart_puts("f6 returning\r\n");}
void f5() { f6(); early_uart_puts("f5 returning\r\n");}
void f4() { f5(); early_uart_puts("f4 returning\r\n");}
void f3() { f4(); early_uart_puts("f3 returning\r\n");}
void f2() { f3(); early_uart_puts("f2 returning\r\n");}
void f1() { f2(); early_uart_puts("f1 returning\r\n");}

#define TEST_STACK
#define TEST_MULDIV
#define TEST_FIB

char data_msg[] = "Message from .data segment\n";

void _write(char *b, int len)
{
      for (int i = 0; i < len; i++) {
            early_uart_putc(b[i]);
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
            early_uart_puts("-");
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
      early_uart_puts(buf2);
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
      early_uart_puts("0x");
      early_uart_puts(buf2);
}

int main()
{
      early_uart_puts("In main\r\n");
      early_uart_putc('H');
      early_uart_putc('e');
      early_uart_putc('l');
      early_uart_putc('l');
      early_uart_putc('o');
      early_uart_putc(' ');
      early_uart_putc('w');
      early_uart_putc('o');
      early_uart_putc('r');
      early_uart_putc('l');
      early_uart_putc('d');
      early_uart_putc('!');
      early_uart_putc('\r');
      early_uart_putc('\n');
      
#ifdef TEST_STACK
      f1();
      early_uart_puts("Made it back\r\n");
#endif

#ifdef TEST_MULDIV
      int ans = 2;

      if (7 / 3 == ans) 
            early_uart_puts("division is good\r\n");

      if (22 % 4 == ans) 
            early_uart_puts("mod is good\r\n");
#endif

      putn(7);
      putn(42);

#ifdef TEST_FIB
      if (fib(0) == 0)
            early_uart_puts("fib(0) good\r\n");
      if (fib(1) == 1)
            early_uart_puts("fib(1) good\r\n");
      if (fib(2) == 1)
            early_uart_puts("fib(2) good\r\n");
      if (fib(3) == 2)
            early_uart_puts("fib(3) good\r\n");
      if (fib(4) == 3)
            early_uart_puts("fib(4) good\r\n");
      if (fib(5) == 5)
            early_uart_puts("fib(5) good\r\n");
      if (fib(6) == 8)
            early_uart_puts("fib(6) good\r\n");
      if (fib(7) == 13)
            early_uart_puts("fib(7) good\r\n");
      if (fib(8) == 21)
            early_uart_puts("fib(8) good\r\n");
      if (fib(9) == 34)
            early_uart_puts("fib(9) good\r\n");
      if (fib(10) == 55)
            early_uart_puts("fib(10) good\r\n");
      if (fib(11) == 89)
            early_uart_puts("fib(11) good\r\n");
      if (fib(12) == 144)
            early_uart_puts("fib(12) good\r\n");
#endif

      char * foo = "Hello, world\r\n";
      char buf[128];
      strcpy(buf, foo);

      early_uart_puts(buf);
      early_uart_putc('Z');
      early_uart_putc('X');
      early_uart_putc('\n');

      early_uart_puts("324 is ");
      putn(atoi("324"));
      early_uart_putc('\n');

      early_uart_puts("0x3bfa is ");
      puth(strtol("0x3bfa", NULL, 0));
      early_uart_putc('\n');

      early_uart_puts(data_msg);

#ifdef ALWAYS_LOAD_XMODEM
      early_uart_puts("Receiving code over xmodem to ");
      early_uart_puthexw((unsigned int)  &_LINKSCRIPT_RAM_START);
      early_uart_puts(" ...");

      xmodem_recv(&_LINKSCRIPT_RAM_START);

      early_uart_puts("\n\n\n");
      early_uart_puts("Done!\n");
      early_uart_getc();
      early_uart_puts("Received and loaded. Ready to continue\n");
      early_uart_getc();

      early_uart_puts("Jumping to load address. Here we go!\n\n\n");

#endif 
      early_uart_puts("About to call shell_entry\n");
      shell_entry();
      early_uart_puts("somehow shell returned\n");
}
