#*****************************************************************************
#    # #              Name   : Makefile
#  #     #            Date   : Dec. 24, 2020
# #    #  #  #     #  Author : Qiwei Wu
#  #     #  # #  # #  Version: 1.0
#    # #  #    #   #
# Makefile.
#*****************************************************************************

objs += $(obj)

#CFLAGS = -Werror -std=c99
CFLAGS = -Werror
CINC = -I../../code

task:
	arm-xilinx-linux-gnueabi-gcc -o ./led/LedGpioTest ./led/LedGpioTest.c

clean:
	rm *.d

distclean:
	rm $(deps)

.PHONY:clean
.PHONY:distclean