//*****************************************************************************
//    # #              Name   : server.c
//  #     #            Date   : Feb. 19, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.1
//    # #  #    #   #
//
// This module is the WEB server.
//
// Change History:
//  VER.   Author         DATE              Change Description
//  1.0    Qiwei Wu       Feb. 18, 2021     Initial Release
//  1.1    Qiwei Wu       Feb. 19, 2021     Add LED swap
//*****************************************************************************

//*****************************************************************************
// Headers
//*****************************************************************************
#include <sys/mman.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <StrToInt.h>
#include <BaseDef.h>

//*****************************************************************************
// Variables
//*****************************************************************************
static void *m_MapAddress;

//*****************************************************************************
// Swap LED status
//*****************************************************************************
void SwapLed(void)
{
   u32 rData;

   // Swap NO.2 LED status
   rData = regRead((u32)m_MapAddress + REG_LED_CTRL);
   if(rData & 0x2)
   {
      rData &= 0xD;
   }
   else
   {
      rData |= 0x2;
   }

   regWrite((u32)m_MapAddress + REG_LED_CTRL, rData);
}

//*****************************************************************************
// Swap BMP
//*****************************************************************************
void SwapBmp(void)
{
   u32 rData;

   rData = regRead((u32)m_MapAddress + REG_BMP_SEL);
   if(rData & 0x2)
   {
      rData &= 0XFFFFFFFD;
   }
   else
   {
      rData |= 0x2;
   }

   regWrite((u32)m_MapAddress + REG_BMP_SEL, rData);
}

//*****************************************************************************
// Main
//*****************************************************************************
int main(int argc, char **argv)
{
   int fd;
   int len;
   char *postStr,inputData[512];
   int funcSel = 0;

   fd = open("/dev/mem", O_RDWR | O_SYNC);
   if (fd < 0)
   {
      printf("Cannot open /dev/mem. \n");
      exit(1);
   }

   m_MapAddress = mmap(0, 0x2000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, (__off_t)REGCTRL_BASEADDR);

   if(m_MapAddress == (void *) -1)
   {
      printf("Can't map the 0x%x to the user space. \n", REGCTRL_BASEADDR);
   }

   // Get the value from FORM
   postStr=getenv("CONTENT_LENGTH");
   if(postStr != NULL)
   {
      len=atoi(postStr);
      fgets(inputData,len+2,stdin);

      if(strstr(inputData, "toggle"))
      {
         //sscanf(inputdata,"toggleLED=%[^&]&toggle=%[^&]", toggleLED, toggle);
         funcSel = 1;
      }
      else if(strstr(inputData, "swap"))
      {
         funcSel = 2;
      }
   }

   // Swap LED status
   if(funcSel == 1)
   {
      SwapLed();
   }
   else if(funcSel == 2)
   {
      SwapBmp();
   }

   munmap(m_MapAddress, 0x2000);

   return 0;
}
