#include <stddef.h>
#include "list.h"
struct list * get_tail(struct list * cursor)
{
      while (cursor->next != NULL) {
            cursor = cursor->next;
      }
      return cursor;
}

int list_append(struct list * head, struct list * new)
{
	struct list * tail = get_tail(head);
      tail->next = new;

      return 0;
}

