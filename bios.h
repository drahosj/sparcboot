#ifndef __bios_h
#define __bios_h

void bios_puts(char *);
void bios_putc(char);
int bios_getc(void);
int bios_getc_nb(void);
void bios_wait(int);

int bios_readline(char *, int);
#endif
