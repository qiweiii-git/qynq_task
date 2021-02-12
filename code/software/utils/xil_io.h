//*****************************************************************************
//    # #              Name   : xil_io.h
//  #     #            Date   : Feb. 12, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
//
//*****************************************************************************

#ifndef __XIL_IO__
#define __XIL_IO__

//*****************************************************************************
// Headers
//*****************************************************************************
#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>

typedef unsigned char  u8;
typedef unsigned short u16;
typedef unsigned int   u32;

static void * xil_MMap(u32 address, u32 length)
{
   int fd;

   fd = open("/dev/mem", O_RDWR | O_SYNC);
   if (fd < 0)
   {
      printf("Cannot open /dev/mem. \n");
      return (void *)-1;
   }

   return mmap(0, length, PROT_READ | PROT_WRITE, MAP_SHARED, fd, (__off_t)address);
}

static u32 Xil_In32(u32 address)
{
   return *(volatile u32 *) address;
}

static u32 Xil_Out32(u32 address, u32 data)
{
   *(volatile u32 *) address = data;
}

#endif