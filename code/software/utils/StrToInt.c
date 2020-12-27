//*****************************************************************************
//    # #              Name   : StrToInt.c
//  #     #            Date   : Dec. 27, 2020
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// Convert String to Int.
//*****************************************************************************

#include <StrToInt.h>

//*****************************************************************************
// Functions
//*****************************************************************************
int StrToIntCtrl(char *str)
{
   int i = 0;
   int hexValue = 0;
   int intValue = 0;
   int intValueSel = 0;
   int strLen = 0;
   long long baseValue = 1;
   int baseCoef = 10;

   while(*str == '0')
   {
      str++;
   }

   if(*str == 'x')
   {
      hexValue = 1;
      str++;
   }

   strLen = strlen(str);

   if(hexValue == 1)
   {
      baseCoef = 16;
   }
   else
   {
      baseCoef = 10;
   }

   for(i =0; i < strLen; i++)
   {
      baseValue = baseCoef*baseValue;
   }

   while(*str)
   {
      if(isdigit(*str))//'0'
      {
         intValueSel = *str - '0';
      }
      else if(isupper(*str))//'A'
      {
         intValueSel = *str - 55;
      }
      else//'a'
      {
         intValueSel = *str - 87;
      }

      baseValue /= baseCoef;
      intValue += intValueSel * baseValue;

      //printf("str %c strLen %d intValue %d\n", *str, strLen, intValue);

      str++;
   }

   return intValue;
}
