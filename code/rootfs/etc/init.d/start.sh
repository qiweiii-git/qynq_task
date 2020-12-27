#*****************************************************************************
#    # #              Name   : start.sh
#  #     #            Date   : Dec. 27, 2020
# #    #  #  #     #  Author : Qiwei Wu
#  #     #  # #  # #  Version: 1.0
#    # #  #    #   #
# build.sh.
#*****************************************************************************
#!/bin/bash

echo "starting regctrl"
insmod /lib/modules/RegDrv.ko
mknod /dev/regctrl c 232 0
