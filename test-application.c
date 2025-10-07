#include "early_uart.h"

__attribute__((section (".text.entry"))) void main()
{
      early_uart_puts("Hello from main");
}
