//*****************************************************************************
//    # #              Name   : BmpRead.c
//  #     #            Date   : Feb. 12, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// BMP picture reading.
//*****************************************************************************

#include "BmpRead.h"

//*****************************************************************************
// Functions
//*****************************************************************************
int BmpRead(char *fileName, void *memAddress)
{
   int           fd;
   int           ret;
   u32           bmpWidth;
   u32           bmpHeight;
   u32           index;
   unsigned char bmpHdr[64];
   u32           x;
   u32           y;
   u32           z;

   fd = open(fileName, O_RDONLY);
   if(fd < 0)
   {
      printf("Cannot open %s. \n", fileName);
      return -1;
   }

   ret = read(fd, bmpHdr, 64);
   if(ret < 0)
   {
      printf("Cannot read %s. \n", fileName);
      return -1;
   }

   bmpWidth = (unsigned int)bmpHdr[19]*256+bmpHdr[18];
   bmpHeight = (unsigned int)bmpHdr[23]*256+bmpHdr[22];
   index = (bmpHeight - 1) * bmpWidth * 3;

   unsigned char bmpDat[bmpWidth * 3];

   printf("%s:Get BMP width:%d, height:%d.\r\n", __func__, bmpWidth, bmpHeight);

   for(y = 0; y < bmpHeight ; y++)
   {
      read(fd, bmpDat, bmpWidth * 3);

      for(x = 0; x < bmpWidth; x++)
      {
         for(z = 0; z < 3; z++)
         {
            frameBuf[x * 3 + index + z] = bmpDat[x * 3 + z];
         }
      }

      index -= bmpWidth * 3;
   }

   // Swap RGB
   unsigned char rData;
   unsigned char bData;
   unsigned char gData;

   for(x = 0; x < bmpWidth * bmpHeight * 3; x = x + 3)
   {
      bData = frameBuf[x + 2];
      rData = frameBuf[x + 1];
      gData = frameBuf[x + 0];

      frameBuf[x + 0] = gData;
      frameBuf[x + 1] = bData;
      frameBuf[x + 2] = rData;
   }

   close(fd);

   printf("%s:Writing data into 0x%x. \r\n", __func__, (u32)memAddress);

   memcpy(memAddress, (const void *)frameBuf, BMP_HEIGHT*BMP_WIDTH);

   printf("%s:Done! \r\n", __func__);

   return 0;
}
