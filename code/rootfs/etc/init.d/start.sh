#*****************************************************************************
#    # #              Name   : start.sh
#  #     #            Date   : Feb. 17, 2021
# #    #  #  #     #  Author : Qiwei Wu
#  #     #  # #  # #  Version: 1.2
#    # #  #    #   #
# build.sh.
# 
# Change History:
#  VER.   Author         DATE              Change Description
#  1.0    Qiwei Wu       Dec. 27, 2020     Initial Release
#  1.1    Qiwei Wu       Feb. 17, 2021     Add chmod 777
#  1.2    Qiwei Wu       Feb. 17, 2021     Run apps
#*****************************************************************************
#!/bin/bash

echo "starting regctrl"
insmod /lib/modules/RegDrv.ko
mknod /dev/regctrl c 232 0
chmod 777 /usr/sbin/regrw
chmod 777 /usr/sbin/qynq07_sdp2hdmi

echo "starting apps"
qynq07_sdp2hdmi &
