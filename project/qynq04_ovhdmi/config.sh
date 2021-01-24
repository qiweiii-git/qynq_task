#!/bin/bash

#*****************************************************************************
# Build setting
#*****************************************************************************
buildKernel='0'
buildFw='1'
buildBootBin='1'

#*****************************************************************************
# Build sources
#*****************************************************************************
elf=('qynq04_ovhdmi' 'project/qynq04_ovhdmi/source/main.c')
drvs=('reg/RegDrv' 'code/software/drivers')
apps=('reg/regrw' 'code/software/subsystems')
