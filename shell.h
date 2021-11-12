#ifndef _shell_h
#define _shell_h

struct list {
    struct list * next;
};

struct command {
    struct command * next;
    char * name;
    char * help;
    int (*fn)(void);
};

struct addr_var {
    struct addr_var * next;
    char * name;
    long val;
};

int set_addr_var(struct addr_var * var);
struct addr_var * get_addr_var(char * name);


void shell_entry(void);
int register_command(struct command *);

#endif
