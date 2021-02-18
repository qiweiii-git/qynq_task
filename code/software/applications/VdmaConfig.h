//*****************************************************************************
//    # #              Name   : VdmaConfig.h
//  #     #            Date   : Jan. 24, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// VDMA configuration.
//*****************************************************************************

#ifndef __VDMA_CONFIG_DEFINE__
#define __VDMA_CONFIG_DEFINE__

//*****************************************************************************
// Includes
//*****************************************************************************
#include "BaseDef.h"

//*****************************************************************************
// Variables
//*****************************************************************************
unsigned int m_VdmaBaseAddress;

//*****************************************************************************
// Functions
//*****************************************************************************
int VdmaInit(unsigned int baseAddress);
void VdmaCfgWrite(u8 dest, u32 startAddress, u32 width, u32 height);
void VdmaCfgRead(u8 dest, u32 startAddress, u32 width, u32 height);
void VdmaWrRcv();
void VdmaRdRcv();

#endif
