#ifndef __uart_h
#define __uart_h

#include "uart_registers.h"

#define UART_GET_TCNT(x) ((x & 0xfc000000) >> 26)
#define UART_GET_RCNT(x) ((x & 0x03f00000) >> 20)

struct uart
{
   volatile int data;
   volatile int status;
   volatile int control;
   volatile int scaler;
};

void uart_init(void);
void uart_putc(int c);
int uart_getc(void);
int uart_readline(char * buf, int len);

#endif
