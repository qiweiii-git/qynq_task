//*****************************************************************************
//    # #              Name   : UartManu.h
//  #     #            Date   : Jan. 20, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
//
//*****************************************************************************

#ifndef __UARTMANU_DEFINE__
#define __UARTMANU_DEFINE__

//*****************************************************************************
// Includes
//*****************************************************************************
#include "xuartps.h"
#include "BaseDef.h"
#include "StrToInt.h"

//*****************************************************************************
// Variables
//*****************************************************************************
unsigned int m_UartBaseAddress;
char m_CharData[10];
unsigned int m_CharCnt;
unsigned int m_Addr;
_Bool m_WrEnable;

//*****************************************************************************
// Functions
//*****************************************************************************
int UartManuInit(unsigned int baseAddress);
int UartGetChar(char *charData);
int UartPutChar(char charData);
int UartPutString(const char *charData);
int UartManu();

#endif
