#include "shell.h"
#include <stdio.h>
#include <string.h>

int main()
{
      shell_entry();

      return 0;
}

void xmodem_recv()
{
      puts("Unimplemented xmodem function called");
}

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

void putn(int n)
{
      printf("%d", n);
}

void save_shell_frame()
{
}

void register_mmu_commands()
{
}

void uart_readline(char * buf, int len)
{
      fgets(buf, len, stdin);
      int n = strlen(buf);
      if (n > 0) {
            buf[n-1] = '\0';
      }
}
