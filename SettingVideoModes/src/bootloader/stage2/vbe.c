#include "vbe.h"
#include "x86.h"
#include "memory.h"

bool VBE_GetControllerInfo(VbeInfoBlock* info)
{
    if (x86_Video_GetVbeInfo(info) == 0)
    {
        // convert from seg:off to a linear address
        info->VideoModePtr = SEGOFF2LIN(info->VideoModePtr);
        return true;
    }
    return false;
}
bool VBE_GetModeInfo(uint16_t mode, VbeModeInfo* info)
{
    if (x86_Video_GetModeInfo(mode, info) == 0)
    {
        // convert from seg:off to a linear address
        return true;
    }
    return false;
}

bool VBE_SetMode(uint16_t mode)
{
    return x86_Video_SetMode(mode) == 0;
}