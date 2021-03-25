#*****************************************************************************
#    # #              Name   : start.sh
#  #     #            Date   : Mar. 13, 2021
# #    #  #  #     #  Author : Qiwei Wu
#  #     #  # #  # #  Version: 1.0
#    # #  #    #   #
# postUpdate.sh.
# 
# Change History:
#  VER.   Author         DATE              Change Description
#  1.0    Qiwei Wu       Mar. 13, 2021     Initial Release
#*****************************************************************************
#!/bin/bash

if [[ -e /tmp/upgrade ]]; then
   echo "Updatting"
   rm -f /mnt/*
   cd /mnt/
   tar -xvf /tmp/upgrade
   echo "rebooting"
   reboot
else
   echo "no update software file"
fi

