//*****************************************************************************
//    # #              Name   : regrw.c
//  #     #            Date   : Feb. 12, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 2.0
//    # #  #    #   #
//
// This module is the register read/write control.
// 
// Change History:
//  VER.   Author         DATE              Change Description
//  1.0    Qiwei Wu       Dec. 23, 2020     Initial Release
//  2.0    Qiwei Wu       Feb. 12, 2021     New codes
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
// Functions
//*****************************************************************************
int main(int argc, char **argv)
{
   int fd;
   volatile unsigned int *regAddress;
   unsigned int  address;
   unsigned int  rData;
   unsigned int  wData;

   fd = open("/dev/mem", O_RDWR | O_SYNC);
   if (fd < 0)
   {
      printf("Cannot open /dev/mem. \n");
      exit(1);
   }

   m_MapAddress = mmap(0, 0x00100000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, (__off_t)REGCTRL_BASEADDR);

   if(m_MapAddress == (void *) -1)
   {
      printf("Can't map the 0x%x to the user space. \n", REGCTRL_BASEADDR);
   }

   if (argc != 2 && argc != 3)
   {
      printf("Usage :\n");
      printf("%s address <write value>\n", argv[0]);
      return 0;
   }

   // Read
   if(argc == 2)
   {
      address = StrToIntCtrl(argv[1], strlen(argv[1]));
      rData = regRead((u32)m_MapAddress + address * 0x10);
      printf("Reading 0x%x from 0x%x\n", rData, address);
   }
   // Write
   else if(argc == 3)
   {
      address = StrToIntCtrl(argv[1], strlen(argv[1]));
      wData = StrToIntCtrl(argv[2], strlen(argv[2]));
      regWrite((u32)m_MapAddress + address * 0x10, wData);
      printf("Writing 0x%x to 0x%x\n", wData, address);
   }
   munmap(m_MapAddress, 0x00100000);

   return 0;
}
