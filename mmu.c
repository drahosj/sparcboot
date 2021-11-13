#include "mmu_bits.h"
#include "mmu.h"

#include "uart_registers.h"

#include "bios.h"
#include "shell.h"

#include <string.h>
#include <stdlib.h>

extern struct mmu_ptd _pt_start;

#define MMU_L1_NTBLS 2
#define MMU_L23_NTBLS 16

static struct mmu_ptd * next_free_l1;
static struct mmu_ptd * next_free_l23;

static struct mmu_ptd * ctx_tbl;
static struct mmu_ptd * l1tables;
static struct mmu_ptd * l23tables;

extern void mmu_set_contextptr(unsigned int ctxt);
extern void mmu_set_context(int ctxt);

extern void putn(int);
extern void puth(int);

extern char _RAM_END;

static int fn_map(void);

static struct command cmd_init = {
      .name = "mmu-init",
      .help = "Initialize MMU and register initial pages for context 0",
      .fn = mmu_init_layout,
};

static struct command cmd_en = {
      .name = "mmu-en",
      .help = "Set MMU as enabled",
      .fn = mmu_enable,
};

static struct command cmd_dis = {
      .name = "mmu-dis",
      .help = "Set MMU as disabled",
      .fn = mmu_disable,
};


static struct command cmd_map = {
      .name = "mmu-map",
      .help = "mmu-map <P> <V>: Map physical P at virtual address V",
      .fn = fn_map,
};


int mmu_map_page(int ctx, unsigned int p, unsigned int v)
{
      bios_puts("Mapping P(");
      puth(p);
      bios_puts(") at V(");
      puth(v);
      bios_puts(")\n");
      unsigned int i1 = (v >> 24) & 0xff;
      unsigned int i2 = (v >> 18) & 0x3f;
      unsigned int i3 = (v >> 12) & 0x3f;

      /* hardcode noncacheable and full rwx/rwx */
      mmu_pte pte = ((p >> 4) & 0x0fffff00) | (0x03 << 2) | 0x02;

      struct mmu_ptd * l1tbl = (struct mmu_ptd *) 
            ((ctx_tbl[ctx].ptv & (~0x3)) << 4);

      if (l1tbl == NULL) {
            bios_puts("Allocating new L1 table\n");
            l1tbl = next_free_l1;
            next_free_l1 += 1024;
            ctx_tbl[ctx].ptv = ((unsigned int ) l1tbl >> 4) | 0x01;
            memset(l1tbl, 0, sizeof(struct mmu_ptd) * 256);
      }
      bios_puts("L1 table: ");
      puth((unsigned int) l1tbl);
      bios_puts("\nL1 index: ");
      puth(i1);
      bios_putc('\n');

      struct mmu_ptd * l2tbl = (struct mmu_ptd *) 
            ((l1tbl[i1].ptv & (~0x3)) << 4);
      if (l2tbl == NULL) {
            bios_puts("Allocating L2 table\n");
            l2tbl = next_free_l23;
            next_free_l23 += 64;
            l1tbl[i1].ptv = ((unsigned int ) l2tbl >> 4) | 0x01;
            memset(l2tbl, 0, sizeof(struct mmu_ptd) * 64);
      }
      bios_puts("L2 table: ");
      puth((unsigned int) l2tbl);
      bios_puts("\nL2 index: ");
      puth(i2);
      bios_putc('\n');

      struct mmu_ptd * l3tbl = (struct mmu_ptd *) 
            ((l2tbl[i2].ptv & (~0x3)) << 4);
      if (l3tbl == NULL) {
            bios_puts("Allocating L3 table\n");
            l3tbl = next_free_l23;
            next_free_l23 += 64;
            l2tbl[i2].ptv = ((unsigned int ) l3tbl >> 4) | 0x01;
            memset(l3tbl, 0, sizeof(struct mmu_ptd) * 64);
      }
      bios_puts("L3 table: ");
      puth((unsigned int) l3tbl);
      bios_puts("\nL3 index: ");
      puth(i3);
      bios_puts("\nPTE value: ");
      puth(pte);
      bios_putc('\n');

      l3tbl[i3].pte = pte;

      return 0;
}

int mmu_init_layout()
{
      ctx_tbl = &_pt_start;
      l1tables =  ctx_tbl + MMU_CTXT_TBLSIZE;
      l23tables = l1tables + (MMU_L1_TBLSIZE * MMU_L1_NTBLS);

      memset(ctx_tbl, 0, MMU_CTXT_TBLSIZE * sizeof(struct mmu_ptd));

      next_free_l1 = l1tables;
      next_free_l23 = l23tables;

      bios_puts("Context start: ");
      puth((unsigned int) ctx_tbl);
      bios_putc('\n');
      bios_puts("L1 table space: ");
      puth((unsigned int) next_free_l1);
      bios_putc('\n');
      bios_puts("L23 table space: ");
      puth((unsigned int) next_free_l23);
      bios_putc('\n');


      /* Map beginning of RAM at its actual address */
      for (int i = 0; i < 16; i += 1) {
            mmu_map_page(0, 0x40000000 + (i << 12), 0x40000000 + (i << 12));
      }

      /* And map end of ram for stack pointer purposes */
      for (int i = 1; i < 5; i += 1) {
            unsigned int sp_top = (unsigned int) &_RAM_END;
            mmu_map_page(0, sp_top -  (i << 12), sp_top - (i << 12));
      }

      /* Map uart */
      mmu_map_page(0, UART_BASE & ~0xfff, UART_BASE & ~0xfff);

      mmu_set_context(0);
      mmu_set_contextptr((unsigned int) ctx_tbl >> 4);

      return 0;
}

int fn_map()
{
      unsigned int p = strtol(strtok(NULL, " "), NULL, 0);
      unsigned int v = strtol(strtok(NULL, " "), NULL, 0);

      return mmu_map_page(0, p, v);
}

int register_mmu_commands()
{
      register_command(&cmd_init);
      register_command(&cmd_en);
      register_command(&cmd_dis);
      register_command(&cmd_map);
}
