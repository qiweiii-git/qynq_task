#!/bin/bash

#*****************************************************************************
# Build setting
#*****************************************************************************
buildKernel='0'
buildFw='0'
buildBootBin='0'

#*****************************************************************************
# Build sources
#*****************************************************************************
elf='uboot'
#drvs=('reg/RegDrv' 'code/software/drivers')
apps=('reg/regrw' 'code/software/subsystems'
      'apps/qynq07_sdp2hdmi' 'code/software/subsystems'
      'apps/ovss' 'code/software/subsystems'
      'cgi/server' 'code/software/subsystems'
      'cgi/upload' 'code/software/subsystems')
