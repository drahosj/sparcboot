#ifndef __bios_h
#define __bios_h

void bios_puts(char *);
void bios_putc(char);
int bios_getc(void);
int bios_getline(char *, int);

int bios_readline(char *, int);
#endif
