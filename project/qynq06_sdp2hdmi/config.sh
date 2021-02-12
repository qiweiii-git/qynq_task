#!/bin/bash

#*****************************************************************************
# Build setting
#*****************************************************************************
buildKernel='1'
buildFw='0'
buildBootBin='1'
buildPetaLinux='0' # hard to use

#*****************************************************************************
# Build sources
#*****************************************************************************
ver='2020'
elf=('uboot')
drvs=('reg/RegDrv' 'code/software/drivers')
apps=('reg/regrw' 'code/software/subsystems')
