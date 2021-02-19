//*****************************************************************************
//    # #              Name   : qynq07_sdp2hdmi.c
//  #     #            Date   : Feb. 18, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.2
//    # #  #    #   #
//
// This module is the main process of SD picture to HDMI output project.
//
// Change History:
//  VER.   Author         DATE              Change Description
//  1.0    Qiwei Wu       Feb. 12, 2021     Initial Release
//  1.1    Qiwei Wu       Feb. 17, 2021     Add threads
//  1.2    Qiwei Wu       Feb. 18, 2021     Add BMP swap and led thread
//*****************************************************************************

//*****************************************************************************
// Project Defines
//*****************************************************************************
#define PRJ_N "qynq07_sdp2hdmi"
#define H_VER 1
#define L_VER 2

//*****************************************************************************
// Includes
//*****************************************************************************
#include "VdmaConfig.h"
#include "BmpRead.h"
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
u32         m_BmpSel = 0;

//*****************************************************************************
// Initialization
//*****************************************************************************
int init()
{
   // Configure
   // change format to 720p60
   regWrite((u32)regCtrlAddr + REG_FMT_DEF , 1);

   // BMP read
   // Waiting for find out the SD card device name
   BmpRead("/mnt/init.bmp", frameBuf0Addr);
   BmpRead("/mnt/init_next.bmp", frameBuf1Addr);

   // VDMA control
   VdmaInit((u32)vdmaCtrlAddr);
   VdmaCfgRead(0, (u32)0x10000000, BMP_WIDTH, BMP_HEIGHT);
   VdmaCfgRead(1, (u32)0x10000000, BMP_WIDTH, BMP_HEIGHT);
   VdmaCfgRead(2, (u32)0x10000000, BMP_WIDTH, BMP_HEIGHT);
   VdmaCfgRead(3, (u32)0x10000000, BMP_WIDTH, BMP_HEIGHT);
}

//*****************************************************************************
// System maintain
//*****************************************************************************
void *SysMaintain(void *arg)
{
   u32 rData;
   u32 ledOn;

   while(1)
   {
      // 500 milisecond thread
      usleep(500000);

      // Swap NO.1 Led status
      ledOn = regRead((u32)regCtrlAddr + REG_LED_CTRL);
      if(ledOn & 0x1)
      {
         ledOn &= 0xE;
      }
      else
      {
         ledOn |= 0x1;
      }
      regWrite((u32)regCtrlAddr + REG_LED_CTRL, ledOn);

      // Swap init BMP pic
      rData = regRead((u32)regCtrlAddr + REG_BMP_SEL);
      if(rData != m_BmpSel)
      {
         printf("%s:Swap BMP Picture. \r\n", __func__);
         if(rData & 0x2)
         {
            BmpRead("/mnt/user_bmp.bmp", frameBuf2Addr);
            VdmaCfgRead(0, (u32)0x10C00000, BMP_WIDTH, BMP_HEIGHT);
            VdmaCfgRead(1, (u32)0x10C00000, BMP_WIDTH, BMP_HEIGHT);
            VdmaCfgRead(2, (u32)0x10C00000, BMP_WIDTH, BMP_HEIGHT);
            VdmaCfgRead(3, (u32)0x10C00000, BMP_WIDTH, BMP_HEIGHT);
         }
         else if(rData & 0x1)
         {
            VdmaCfgRead(0, (u32)0x10600000, BMP_WIDTH, BMP_HEIGHT);
            VdmaCfgRead(1, (u32)0x10600000, BMP_WIDTH, BMP_HEIGHT);
            VdmaCfgRead(2, (u32)0x10600000, BMP_WIDTH, BMP_HEIGHT);
            VdmaCfgRead(3, (u32)0x10600000, BMP_WIDTH, BMP_HEIGHT);
         }
         else
         {
            VdmaCfgRead(0, (u32)0x10000000, BMP_WIDTH, BMP_HEIGHT);
            VdmaCfgRead(1, (u32)0x10000000, BMP_WIDTH, BMP_HEIGHT);
            VdmaCfgRead(2, (u32)0x10000000, BMP_WIDTH, BMP_HEIGHT);
            VdmaCfgRead(3, (u32)0x10000000, BMP_WIDTH, BMP_HEIGHT);
         }
      }
      m_BmpSel = rData;
   }
}

//*****************************************************************************
// Error Check Return
//*****************************************************************************
void *ErrorCheckRet(void *arg)
{
   while(1)
   {
      // 1 second thread
      usleep(1000000);

      // VDMA recovery
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
   pthread_t threadId[2];

   printf("\r\n========================================\r\n");
   printf("=   Project: %s. Ver:v%d.%d =\r\n", PRJ_N, H_VER, L_VER);
   printf("=   Date: %s, %s        =\r\n", __DATE__, __TIME__);
   printf("========================================\r\n");

   // Memory map
   regCtrlAddr  = xil_MMap(REGCTRL_BASEADDR, 0x2000);
   vdmaCtrlAddr = xil_MMap(VDMA0_BASEADDR, 0x10000);
   // could not map to 0x0
   frameBuf0Addr = xil_MMap(0x10000000, 0x600000); // 1920x1080x3 = 0x600000
   frameBuf1Addr = xil_MMap(0x10600000, 0x600000); // 1920x1080x3 = 0x600000
   frameBuf2Addr = xil_MMap(0x10C00000, 0x600000); // 1920x1080x3 = 0x600000

   // Get the FW version
   regValue = regRead((u32)regCtrlAddr + REG_FW_VER);
   printf("%s:Reg_0x%x:0x%x.\r\n", __func__ , REG_FW_VER, regValue);

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
   // Thread 2 for system maintain
   ret = pthread_create(&threadId[1], NULL, SysMaintain, NULL);
   if(ret != 0)
   {
      printf("Create thread failed!\r\n");
      return -1;
   }

   // Wait for all threads
   pthread_exit(NULL);

   return 0;
}
