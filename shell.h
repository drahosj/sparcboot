#ifndef _shell_h
#define _shell_h

#include "list.h"

struct command {
    struct list list;
    char * name;
    char * help;
    int (*fn)(void);
};

struct addr_var {
	struct list list;
    char * name;
    long val;
};



int set_addr_var(struct addr_var * var);
struct addr_var * get_addr_var(char * name);


void shell_entry(void);
int register_command(struct command *);

#endif
