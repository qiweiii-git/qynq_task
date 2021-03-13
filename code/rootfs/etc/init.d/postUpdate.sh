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
#  1.0    Qiwei Wu       Dec. 27, 2020     Initial Release
#*****************************************************************************
#!/bin/bash

rm -f /mnt/*
tar -xzvf /tmp/upgrade.tar.gz /mnt/
