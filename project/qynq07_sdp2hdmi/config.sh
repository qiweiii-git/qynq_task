#!/bin/bash

#*****************************************************************************
# Build setting
#*****************************************************************************
buildKernel='1'
buildFw='1'
buildBootBin='1'

#*****************************************************************************
# Build sources
#*****************************************************************************
elf='uboot'
#drvs=('reg/RegDrv' 'code/software/drivers')
apps=('reg/regrw' 'code/software/subsystems' 
      'apps/qynq07_sdp2hdmi' 'code/software/subsystems' 
      'cgi/server' 'code/software/subsystems' 
      'cgi/upload' 'code/software/subsystems')
