#include "list.h"
#include "shell.h"

#include <stdio.h>

void early_uart_puts(char * s)
{
      printf("%s", s);
}

void early_uart_putc(int c)
{
      putchar(c);
}

int early_uart_getc()
{
      return getchar();
}

void xmodem_recv()
{
      printf("pretend xmodem happened");
}

void uart_init()
{
}

void putn(int n)
{
      printf("%d", n);
}

int save_shell_frame()
{
      return 1;
}

int uart_readline(char * buf, int len)
{
      int c;
      int i = 0;
	do {
		c = early_uart_getc();
		buf[i++] = c & 0x7f;
		early_uart_putc(c);
            if (c == '\b') {
                  i -= 2;
            }
	} while ((c != '\n') && (c != '\r') && (i < len));
      early_uart_putc('\n');
	buf[i - 1] = '\0';
      return i;
}

int main()
{
      shell_entry();
}
