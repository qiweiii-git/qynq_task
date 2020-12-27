
//*****************************************************************************
// Headers
//*****************************************************************************
#include <stdio.h>
#include <stdlib.h>
#include <StrToInt.h>

int main(int argc, char *argv[])
{
   int intValue;

   char str[] = "0x10354143";
   intValue = StrToIntCtrl(str);

   printf("The int of %s is %d\n", str, intValue);

   return 0;
}