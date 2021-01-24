//*****************************************************************************
//    # #              Name   : VdmaConfig.c
//  #     #            Date   : Jan. 24, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// VDMA configuration.
//*****************************************************************************

#include "VdmaConfig.h"

//*****************************************************************************
// Functions
//*****************************************************************************
// init
int VdmaInit(unsigned int baseAddress)
{
   m_VdmaBaseAddress = baseAddress;

   printf("%s Done.\r\n", __func__);

   return 0;
}

// Configure Write
void VdmaCfgWrite(u8 dest, u32 startAddress, u32 width, u32 height)
{
   // Enable run, Circular_Park, GenlockEn, GenlockSrc, RepeatEn
   Xil_Out32(m_VdmaBaseAddress + 0x30, 0x808B);

   // Start address
   Xil_Out32(m_VdmaBaseAddress + 0xAC + dest * 0x4, startAddress);

   // The number of cache bytes per line
   Xil_Out32(m_VdmaBaseAddress + 0xA8, width);

   // The number of pixel bytes per line
   Xil_Out32(m_VdmaBaseAddress + 0xA4, width);

   // The number of lines per frame
   Xil_Out32(m_VdmaBaseAddress + 0xA0, height);

   printf("%s Done.\r\n", __func__);
}

// Configure Read
void VdmaCfgRead(u8 dest, u32 startAddress, u32 width, u32 height)
{
   // Enable run, Circular_Park, GenlockEn, and GenlockSrc
   Xil_Out32(m_VdmaBaseAddress + 0x00, 0x8B);

   // Start address
   Xil_Out32(m_VdmaBaseAddress + 0x5C + dest * 0x4, startAddress);

   // The number of cache bytes per line
   Xil_Out32(m_VdmaBaseAddress + 0x58, width);

   // The number of pixel bytes per line
   Xil_Out32(m_VdmaBaseAddress + 0x54, width);

   // The number of lines per frame
   Xil_Out32(m_VdmaBaseAddress + 0x50, height);

   printf("%s Done.\r\n", __func__);
}

void VdmaRcv()
{
   unsigned int regValue;

   regValue = Xil_In32(m_VdmaBaseAddress + 0x34);

   if(regValue & 0x1)
   {
      // Reset
      Xil_Out32(m_VdmaBaseAddress + 0x30, 0x04);
      usleep(1000000);
      // Enable run, Circular_Park, GenlockEn, GenlockSrc, RepeatEn
      Xil_Out32(m_VdmaBaseAddress + 0x30, 0x808B);

      printf("%s due to 0x%x!\r\n", __func__, regValue);
   }
}
