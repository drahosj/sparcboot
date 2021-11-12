module core.bios;

extern (C) int bios_getc();
extern (C) int bios_getc_nb();
extern (C) void bios_putc();
extern (C) void bios_puts(const char *);
extern (C) void bios_wait(int);
extern (C) int bios_readline(const char *, int);
extern (C) void bios_write(const char *, int);

char[] readline(char[] buf)
{
    int len = bios_readline(buf.ptr, buf.length);
    return buf[0..len];
}

void write(const(char)[] buf)
{
    bios_write(buf.ptr, buf.length);
}
