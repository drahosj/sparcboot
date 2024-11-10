#include "shell.h"
#include "early_uart.h"
#include "uart.h"
#include "mmu.h"
#include "list.h"

#include <string.h>
#include <stdlib.h>

extern void putn(int n);
extern long xmodem_recv(unsigned long addr);

static struct list commands;
static struct list addr_vars;

struct addr_var * get_addr_var(char * name)
{
      struct addr_var * var = (struct addr_var *) addr_vars.next;
      while (var != NULL) {
            if (!strcmp(var->name, name)) {
                  return var;
            }
            var = (struct addr_var *) var->list.next;
      }
      return 0;
}

static struct command * find_command(char * name)
{
      struct command * cmd = (struct command *) commands.next;
      while (cmd != NULL) {
            if (!strcmp(name, cmd->name)) {
                  break;
            }
            cmd = (struct command *) cmd->list.next;
      }
      return cmd;
}

static struct addr_var var_buffer[32];

static int fn_help()
{
      struct command * cmd = (struct command *) commands.next;
      while (cmd != NULL) {
            early_uart_puts("\t");
            early_uart_puts(cmd->name);
            early_uart_puts("\t- ");
            early_uart_puts(cmd->help);
            early_uart_puts("\n");
            cmd = (struct command *) cmd->list.next;
      }

      early_uart_puts("\n");
      return 0;
}

static struct command cmd_help = {
      .name = "help",
      .help = "Help command",
      .fn = fn_help
};

extern int save_shell_frame(void);
static int fn_go()
{
      char * offset_str = strtok(NULL, " ");
      unsigned long offset = strtol(offset_str, NULL, 0);
      if (offset == 0) {
            struct addr_var * var = get_addr_var(offset_str);
            if (var == NULL) {
                  early_uart_puts("Unable to determine offset\n");
                  return -1;
            }
            offset = var->val;
      }
      early_uart_puts("\nGo ");
      putn(offset);
      early_uart_putc('\n');

      if (save_shell_frame()) {
            int ret = ((int (*)(void)) offset)();
            early_uart_puts("User code returned: ");
            putn(ret);
            early_uart_putc('\n');
            return 0;
      } else {
            early_uart_puts("Recovered from segfault\n");
      }
      return 0;
}

static struct command cmd_go = {
      .name = "go",
      .help = "go <addr>: begin execution at addr",
      .fn = fn_go
};

static int fn_xrecv()
{
      char * offset_str = strtok(NULL, " ");
      unsigned long offset = strtol(offset_str, NULL, 0);
      if (offset == 0) {
            struct addr_var * var = get_addr_var(offset_str);
            if (var == NULL) {
                  early_uart_puts("Unable to determine offset\n");
                  return -1;
            }
            offset = var->val;
      }
      early_uart_puts("Loading to offset ");
      putn(offset);
      early_uart_putc('\n');
      int ret = xmodem_recv(0x40010000);
      early_uart_getc();
      early_uart_putc('\n');
      if (ret > 0) {
            early_uart_puts("Received bytes: ");
            putn(ret);
            early_uart_putc('\n');
      } else {
            early_uart_puts("Err: ");
            putn(ret);
            early_uart_putc('\n');
      }
}

static struct command cmd_xrecv = {
      .name = "xrecv",
      .help = "xrecv <addr>: load over xmodem to addr",
      .fn = fn_xrecv
};

int fn_getvar()
{
      struct addr_var * val = get_addr_var(strtok(NULL, " "));
      if (val == NULL) {
            return -1;
      }
      putn(val->val);
      early_uart_putc('\n');
      return 0;
}

static struct command cmd_getvar = {
      .name = "get",
      .help = "get <var>: get variabl",
      .fn = fn_getvar
};

static struct addr_var defuser_var = {
      .name = "$user",
      .val = 0x40010000
};

static struct addr_var ramboot_var = {
      .name = "$ramboot",
      .val = 0x40000000
};

void shell_entry()
{
      early_uart_puts("Bootloader entry\n\n");
      list_append(&commands, (struct list *) &cmd_help);
      list_append(&commands, (struct list *) &cmd_xrecv);
      list_append(&commands, (struct list *) &cmd_go);
      list_append(&commands, (struct list *) &cmd_getvar);

      register_mmu_commands();

      list_append(&addr_vars, (struct list *) &defuser_var);
      list_append(&addr_vars, (struct list *) &ramboot_var);

      char buf[128];
      for(;;) {
            early_uart_puts("BOOTLOADER> ");
            uart_readline(buf, 128);

            char * name = strtok(buf, " ");
            struct command * cmd = find_command(name);
            if (cmd != NULL) {
                  cmd->fn();
            } else {
                  early_uart_puts("Invalid command\n");
            }
      }
}
