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
int mmu_enable(void);
int mmu_disable(void);

int register_mmu_commands(void);

#endif
