#include "uart.h"

#include "bios.h"

static inline int loadmem(int addr)
{
	int tmp;
	asm volatile (" ld [%1], %0 "
			: "=r"(tmp)
			: "r"(addr)
			);
	return tmp;
}

void uart_init()
{
	struct uart * uart = (struct uart *) UART_BASE;
	uart->control = 0x00000000;
	uart->status = 0x00000000;
      /* Computed for 9600 baud from 70 MHz sysclk */
      uart->scaler = 911;
	uart->control = UART_CONTROL_ENABLE_TX | UART_CONTROL_ENABLE_RX;
}

void uart_putc(int c)
{
	struct uart * uart = (struct uart *) UART_BASE;
	while (!(loadmem(UART_STATUS) & UART_STATUS_TE)) {}

	uart->data = c;
}

int uart_readline(char * buf, int len)
{
      int c;
      int i = 0;
	do {
		c = bios_getc();
		buf[i++] = c & 0x7f;
		bios_putc(c);
            if (c == '\b') {
                  i -= 2;
            }
	} while ((c != '\n') && (i < len));
	buf[i - 1] = '\0';
      return i;
}
