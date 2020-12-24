#!/bin/bash

depends=('u-boot-xlnx' 'git clone https://github.com/Xilinx/u-boot-xlnx.git' 
         'linux-Digilent-Dev' 'git clone http://github.com/Digilent/linux-Digilent-Dev' 
         'qynq_base' 'git clone http://github.com/qiweiii-git/qynq_base.git')

patchs=( 'u-boot-xlnx' 'u-boot.patch' )
