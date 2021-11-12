#include "bios.h"

#include <stdlib.h>
#include <string.h>

int fib(int);

int main()
{
      char buf[128];
      bios_puts("USER> ");
      bios_readline(buf, 128);

      char * cmd = strtok(buf, " ");

      if (!strcmp("fib", cmd)) {
            bios_puts("Executing fib...\n");
            return fib(strtol(strtok(NULL, " "), NULL, 0));
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
