#*****************************************************************************
#    # #              Name   : start.sh
#  #     #            Date   : Feb. 17, 2021
# #    #  #  #     #  Author : Qiwei Wu
#  #     #  # #  # #  Version: 1.3
#    # #  #    #   #
# build.sh.
# 
# Change History:
#  VER.   Author         DATE              Change Description
#  1.0    Qiwei Wu       Dec. 27, 2020     Initial Release
#  1.1    Qiwei Wu       Feb. 17, 2021     Add chmod 777
#  1.2    Qiwei Wu       Feb. 17, 2021     Run apps
#  1.3    Qiwei Wu       Feb. 18, 2021     Run Ethernet
#*****************************************************************************
#!/bin/bash

echo "starting Ethernet"
ifconfig eth0 169.254.22.77

echo "starting regctrl"
insmod /lib/modules/RegDrv.ko
mknod /dev/regctrl c 232 0
chmod 777 /var/www/cgi-bin/server.cgi
chmod 777 /usr/sbin/boa
chmod 777 /usr/sbin/regrw
chmod 777 /usr/sbin/qynq07_sdp2hdmi

echo "starting apps"
qynq07_sdp2hdmi &
