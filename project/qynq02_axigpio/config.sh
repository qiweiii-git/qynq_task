#!/bin/bash

#*****************************************************************************
# Build setting
#*****************************************************************************
buildUboot='0'
buildKernel='1'
buildFw='0'
buildBootBin='0'
buildSw='1'

#*****************************************************************************
# Build sources
#*****************************************************************************
apps=('led/LedGpioTest' 'code/software/subsystems')
