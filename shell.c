#include "shell.h"
#include "bios.h"
#include "mmu.h"

#include <string.h>
#include <stdlib.h>

extern void putn(int n);
extern long xmodem_recv(unsigned long addr);

static struct list ** get_tail(struct list ** head)
{
      if (*head == NULL) {
            return head;
      }
      struct list * cursor = *head;

      while (cursor->next != NULL) {
            cursor = cursor->next;
      }
      return &(cursor->next);
}

static struct command * command_head;
static struct addr_var * addr_head;

struct addr_var * get_addr_var(char * name)
{
      struct addr_var * var = addr_head;
      while (var != NULL) {
            if (!strcmp(var->name, name)) {
                  return var;
            }
            var = var->next;
      }
      return 0;
}

int set_addr_var(struct addr_var * var)
{
      struct list ** tail = get_tail((struct list **) &addr_head);
      *tail = (struct list *) var;
      return 0;
}
      
static struct command * find_command(char * name)
{
      struct command * cmd = command_head;
      while (cmd != NULL) {
            if (!strcmp(name, cmd->name)) {
                  break;
            }
            cmd = cmd->next;
      }
      return cmd;
}

static struct addr_var var_buffer[32];

static int fn_help()
{
      struct command * cmd = command_head;
      while (cmd != NULL) {
            bios_puts("\t");
            bios_puts(cmd->name);
            bios_puts("\t- ");
            bios_puts(cmd->help);
            bios_puts("\n");
            cmd = cmd->next;
      }

      bios_puts("\n");
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
                  bios_puts("Unable to determine offset\n");
                  return -1;
            }
            offset = var->val;
      }
      bios_puts("\nGo ");
      putn(offset);
      bios_putc('\n');

      if (save_shell_frame()) {
            int ret = ((int (*)(void)) offset)();
            bios_puts("User code returned: ");
            putn(ret);
            bios_putc('\n');
            return 0;
      } else {
            bios_puts("Recovered from segfault\n");
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
                  bios_puts("Unable to determine offset\n");
                  return -1;
            }
            offset = var->val;
      }
      bios_puts("Loading to offset ");
      putn(offset);
      bios_putc('\n');
      int ret = xmodem_recv(0x40010000);
      bios_getc();
      bios_putc('\n');
      if (ret > 0) {
            bios_puts("Received bytes: ");
            putn(ret);
            bios_putc('\n');
      } else {
            bios_puts("Err: ");
            putn(ret);
            bios_putc('\n');
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
      bios_putc('\n');
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

int register_command(struct command * new)
{
      struct list ** tail = get_tail((struct list **) &command_head);

      *tail = (struct list *) new;

      return 0;
}

void shell_entry()
{
      register_command(&cmd_help);
      register_command(&cmd_xrecv);
      register_command(&cmd_go);
      register_command(&cmd_getvar);

      register_mmu_commands();

      set_addr_var(&defuser_var);
      set_addr_var(&ramboot_var);

      char buf[128];
      for(;;) {
            bios_puts("BOOTLOADER> ");
            bios_readline(buf, 128);

            char * name = strtok(buf, " ");
            struct command * cmd = find_command(name);
            if (cmd != NULL) {
                  cmd->fn();
            } else {
                  bios_puts("Invalid command\n");
            }
      }
}
