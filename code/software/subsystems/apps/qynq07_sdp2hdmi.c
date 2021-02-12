//*****************************************************************************
//    # #              Name   : qynq07_sdp2hdmi.c
//  #     #            Date   : Feb. 12, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// This module is the main process of SD picture to HDMI output project.
//*****************************************************************************

//*****************************************************************************
// Project Defines
//*****************************************************************************
#define PRJ_N "qynq07_sdp2hdmi"
#define H_VER 1
#define L_VER 0

//*****************************************************************************
// Includes
//*****************************************************************************
#include "VdmaConfig.h"
#include "BmpRead.h"

//*****************************************************************************
// Main
//*****************************************************************************
int main()
{
   u32 regValue;
   static void *regCtrlAddr;
   static void *vdmaCtrlAddr;

   printf("\r\n========================================\r\n");
   printf("=   Project: %s. Ver:v%d.%d   =\r\n", PRJ_N, H_VER, L_VER);
   printf("=   Date: %s, %s        =\r\n", __DATE__, __TIME__);
   printf("========================================\r\n");

   // Memory map
   regCtrlAddr  = xil_MMap(REGCTRL_BASEADDR, 0x00100000);
   vdmaCtrlAddr = xil_MMap(0x41100000, 0x00100000);

   // Get the FW version
   regValue = regRead((u32)regCtrlAddr + 0x0);
   printf("%s:Reg_0x%x:0x%x.\r\n", __func__ , 0x0, regValue);

   // BMP read
   // Waiting for find out the SD card device name
   BmpRead("/?/init.bmp", 0x0);

   // VDMA control
   VdmaInit((u32)vdmaCtrlAddr);
   VdmaCfgRead(0, 0x0, 1920*3, 1080);
}
