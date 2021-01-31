//*****************************************************************************
//    # #              Name   : main.c
//  #     #            Date   : Jan. 31, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// This module is the main process of OV5640 camera and HLS project.
//*****************************************************************************

//*****************************************************************************
// Project Defines
//*****************************************************************************
#define PRJ_N "qynq05_hlshdmi"
#define H_VER 1
#define L_VER 0

//*****************************************************************************
// Includes
//*****************************************************************************
#include "applications/UartManu.h"
#include "applications/CamConfig.h"
#include "applications/VdmaConfig.h"

//*****************************************************************************
// Error check
//*****************************************************************************
void ErrorCheck()
{
   unsigned int regValue;

   regValue = regRead(REGCTRL_BASEADDR + 0x80);
   if((regValue & 0xfff) != 0x4ff)
   {
     printf("%s:Reg_0x%x:0x%x.\r\n", __func__ , 0x8, regValue);
   }
   regValue = regRead(REGCTRL_BASEADDR + 0x90);
   if((regValue & 0xfff) != 0x4ff)
   {
     printf("%s:Reg_0x%x:0x%x.\r\n", __func__ , 0x9, regValue);
   }
}

//*****************************************************************************
// Main
//*****************************************************************************
int main()
{
   u32 regValue;

   printf("\r\n========================================\r\n");
   printf("=   Project: %s. Ver:v%d.%d   =\r\n", PRJ_N, H_VER, L_VER);
   printf("=   Date: %s, %s        =\r\n", __DATE__, __TIME__);
   printf("========================================\r\n");

   // Get the FW version
   regValue = regRead(REGCTRL_BASEADDR + 0x0);
   printf("%s:Reg_0x%x:0x%x.\r\n", __func__ , 0x0, regValue);

   // Uart init
   UartManuInit(XPAR_PS7_UART_1_BASEADDR);

   // Camera init
   CamInit();
   usleep(100000);

   // VDMA control
   VdmaInit(XPAR_AXI_VDMA_0_BASEADDR);
   VdmaCfgWrite(0, 0x10000000, 1280*4, 720);
   VdmaCfgRead(0, 0x10000000, 1280*4, 720);

   VdmaCfgWrite(1, 0x11000000, 1280*4, 720);
   VdmaCfgRead(1, 0x11000000, 1280*4, 720);

   VdmaCfgWrite(2, 0x12000000, 1280*4, 720);
   VdmaCfgRead(2, 0x12000000, 1280*4, 720);

   VdmaCfgWrite(3, 0x13000000, 1280*4, 720);
   VdmaCfgRead(3, 0x13000000, 1280*4, 720);

   // main while
   while(1)
   {
      UartManu();
      VdmaRcv();
      ErrorCheck();
   }

   return 0;
}
