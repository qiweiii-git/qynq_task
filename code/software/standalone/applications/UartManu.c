//*****************************************************************************
//    # #              Name   : UartManu.c
//  #     #            Date   : Jan. 20, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
//
//*****************************************************************************

#include "UartManu.h"

// Init
int UartManuInit(unsigned int baseAddress)
{
   m_UartBaseAddress = baseAddress;
   m_CharCnt = 0;
   m_Addr = 0;
   m_WrEnable = false;

   return 0;
}

// Get char
int UartGetChar(char *charData)
{
   if(XUartPs_IsReceiveData(m_UartBaseAddress))
   {
      // Read data from uart
      *charData = XUartPs_RecvByte(m_UartBaseAddress);
      return 1;
   }
   else
   {
      return 0;
   }
}

// Put char
int UartPutChar(char charData)
{
   XUartPs_SendByte(m_UartBaseAddress, charData);

   return 0;
}

// Put string
int UartPutString(const char *charData)
{
   while(*charData)
   {
      UartPutChar(*charData);
      charData++;
   }

   return 0;
}

// UartManu
int UartManu()
{
   unsigned int ret;
   char charData;
   int intData;
   int rData;

   ret = UartGetChar(&charData);

   if(ret == 1)
   {
      if(charData == '\r' || charData == '\n')
      {
         intData = StrToIntCtrl(m_CharData, m_CharCnt);
         if(m_WrEnable == true)
         {
            regWrite(REGCTRL_BASEADDR + m_Addr * 0x10, intData);
            printf("\r\nWriting 0x%x to 0x%x\r\n", intData, m_Addr);
         }
         else
         {
            rData = regRead(REGCTRL_BASEADDR + intData * 0x10);
            printf("\r\nReading 0x%x from 0x%x\r\n", rData, intData);
         }

         m_Addr = 0;
         m_CharCnt = 0;
         m_WrEnable = false;

         UartPutString("\r\n");
      }
      else if(charData == ' ')
      {
         m_Addr = StrToIntCtrl(m_CharData, m_CharCnt);
         m_WrEnable = true;
         m_CharCnt = 0;
         UartPutChar(charData);
      }
      else
      {
         m_CharData[m_CharCnt] = charData;
         m_CharCnt++;

         UartPutChar(charData);
      }
   }

   return 0;
}

