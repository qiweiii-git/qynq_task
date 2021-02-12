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
// Defines
//*****************************************************************************
#define REG_CTRL_ADDRESS 0x40000000

//*****************************************************************************
// Headers
//*****************************************************************************
#include <sys/mman.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <StrToInt.h>

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
   unsigned int* rData;
   unsigned int  wData;

   fd = open("/dev/mem", O_RDWR | O_SYNC);
   if (fd < 0)
   {
      printf("Cannot open /dev/mem. \n");
      exit(1);
   }

   m_MapAddress = mmap(0, 0x00100000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, (__off_t)REG_CTRL_ADDRESS);

   if(m_MapAddress == (void *) -1)
   {
      printf("Can't map the 0x%x to the user space. \n", REG_CTRL_ADDRESS);
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
      address = StrToIntCtrl(argv[1], 1);
      regAddress = ((volatile unsigned int *)m_MapAddress + address * 0x4);
      *rData = *regAddress;
      printf("Reading 0x%x from 0x%x\n", rData, address);
   }
   // Write
   else if(argc == 3)
   {
      address = StrToIntCtrl(argv[1], 1);
      wData = StrToIntCtrl(argv[2], 1);
      regAddress = ((volatile unsigned int *)m_MapAddress + address * 0x4);
      *regAddress = wData;
      printf("Writing 0x%x to 0x%x\n", wData, address);
   }

   return 0;
}
