//*****************************************************************************
//    # #              Name   : regrw.c
//  #     #            Date   : Dec. 23, 2020
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// This module is the register read/write control.
//*****************************************************************************

//*****************************************************************************
// Headers
//*****************************************************************************
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <StrToInt.h>

//*****************************************************************************
// Functions
//*****************************************************************************
int main(int argc, char **argv)
{
   int fd;
   int address;
   int rData;
   int wData;

   fd = open("/dev/regctrl", O_RDWR);
   if (fd < 0)
   {
      printf("Cannot open REG Controller\n");
      exit(1);
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
      address = StrToIntCtrl(argv[1]);
      read(fd, &rData, address);
      printf("Reading 0x%x from 0x%x\n", rData, address);
   }
   // Write
   else if(argc == 3)
   {
      address = StrToIntCtrl(argv[1]);
      wData = StrToIntCtrl(argv[2]);
      write(fd, &wData, address);
      printf("Writing 0x%x to 0x%x\n", wData, address);
   }

   return 0;
}
