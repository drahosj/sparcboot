#ifndef _early_uart_h
#define _early_uart_h

void early_uart_init();
void early_uart_puthexb(char c);
void early_uart_puthexw(unsigned int n);
void early_uart_puts(char * s);
void early_uart_putc(char c);
char early_uart_getc(void);
int early_uart_getc_nonblock(void);

#endif
