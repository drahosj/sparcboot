#ifndef _mmu_h
#define _mmu_h

typedef unsigned int mmu_pte;

struct mmu_ptd {
    union {
        void * ptp;
        mmu_pte pte;
        unsigned int ptv;
    };
};

int mmu_init_layout(void);
int mmu_map_page(int c, unsigned int p, unsigned int v);
int mmu_map_page_verbose(int c, unsigned int p, unsigned int v);
int mmu_enable(void);
int mmu_disable(void);

int register_mmu_commands(void);

#define PTD_TO_PTR(x) ((unsigned int *) ((x & ~0x03) << 4))
#define PTR_TO_PTD(x) (((unsigned int) x >> 4) | 0x01)

#endif
