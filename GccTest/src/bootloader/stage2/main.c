#include "stdio.h"
#include <stdint.h>

int __attribute__((cdecl)) _start(uint8_t bootDevice)
{
    clrscr();
    printf("Hello from GCC!\n");

    return 0;
}
