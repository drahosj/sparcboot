#ifndef _list_h
#define _list_h

struct list {
    struct list * next;
};

int list_append(struct list * head, struct list * item);

#endif
