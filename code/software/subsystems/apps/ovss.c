//*****************************************************************************
//    # #              Name   : ovss.c
//  #     #            Date   : May. 05, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.2
//    # #  #    #   #
//
// This module is the main process of OV5640 camera input.
//
// Change History:
//  VER.   Author         DATE              Change Description
//  1.0    Qiwei Wu       May. 05, 2021     Initial Release
//*****************************************************************************

//*****************************************************************************
// Project Defines
//*****************************************************************************
#define PRJ_N "ovss"
#define H_VER 1
#define L_VER 0

//*****************************************************************************
// Includes
//*****************************************************************************
#include "VdmaConfig.h"
#include "CamConfig.h"
#include <pthread.h>
#include <stdbool.h>

//*****************************************************************************
// Variables
//*****************************************************************************
static void *regCtrlAddr;
static void *vdmaCtrlAddr;
static void *frameBuf0Addr;
static void *frameBuf1Addr;
static void *frameBuf2Addr;
static void *frameBuf3Addr;
u32         m_BmpSel = 0;

//*****************************************************************************
// Initialization
//*****************************************************************************
int init()
{
   // Camera init
   CamInit((u32)regCtrlAddr);
   usleep(100000);

   // Configure
   // change format to 720p60
   regWrite((u32)regCtrlAddr + REG_FMT_DEF , 1);

   // VDMA control
   VdmaInit((u32)vdmaCtrlAddr);
   VdmaCfgWrite(0, (u32)0x10000000, 1280*4, 720);
   VdmaCfgWrite(1, (u32)0x10600000, 1280*4, 720);
   VdmaCfgWrite(2, (u32)0x10C00000, 1280*4, 720);
   VdmaCfgWrite(3, (u32)0x11200000, 1280*4, 720);
   VdmaCfgRead (0, (u32)0x10000000, 1280*4, 720);
   VdmaCfgRead (1, (u32)0x10600000, 1280*4, 720);
   VdmaCfgRead (2, (u32)0x10C00000, 1280*4, 720);
   VdmaCfgRead (3, (u32)0x11200000, 1280*4, 720);
}

//*****************************************************************************
// Error check
//*****************************************************************************
void *ErrorCheckRet(void *arg)
{
   while(1)
   {
      // 1 second thread
      usleep(1000000);

      // VDMA recovery
      VdmaWrRcv();
      VdmaRdRcv();
   }
}

//*****************************************************************************
// Main
//*****************************************************************************
int main()
{
   u32 regValue;
   u32 ret;
   pthread_t threadId[1];

   printf("\r\n========================================\r\n");
   printf("=   Project: %s. Ver:v%d.%d   =\r\n", PRJ_N, H_VER, L_VER);
   printf("=   Date: %s, %s        =\r\n", __DATE__, __TIME__);
   printf("========================================\r\n");

   // Memory map
   regCtrlAddr  = xil_MMap(REGCTRL_BASEADDR, 0x2000);
   vdmaCtrlAddr = xil_MMap(VDMA0_BASEADDR, 0x10000);
   // could not map to 0x0
   frameBuf0Addr = xil_MMap(0x10000000, 0x600000); // 1920x1080x3 = 0x600000
   frameBuf1Addr = xil_MMap(0x10600000, 0x600000); // 1920x1080x3 = 0x600000
   frameBuf2Addr = xil_MMap(0x10C00000, 0x600000); // 1920x1080x3 = 0x600000
   frameBuf3Addr = xil_MMap(0x11200000, 0x600000); // 1920x1080x3 = 0x600000

   // Initial
   init();

   // Threads
   // Thread 1 for Error check return
   ret = pthread_create(&threadId[0], NULL, ErrorCheckRet, NULL);
   if(ret != 0)
   {
      printf("Create thread failed!\r\n");
      return -1;
   }

   // Wait for all threads
   pthread_exit(NULL);

   return 0;
}
