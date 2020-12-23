#*****************************************************************************
#    # #              Name   : build.sh
#  #     #            Date   : Nov. 21, 2020
# #    #  #  #     #  Author : Qiwei Wu
#  #     #  # #  # #  Version: 1.0
#    # #  #    #   #
# build.sh.
#*****************************************************************************
#!/bin/bash

#*****************************************************************************
# Build setting
#*****************************************************************************
projectName='qynq02_axigpio'
buildUboot='0'
buildKernel='1'
buildFw='0'
buildBootBin='0'
buildSw='1'

if [ ! $1 -eq '' ]; then
   projectName=$1
   buildUboot=$2
   buildKernel=$3
   buildFw=$4
   buildBootBin=$5
fi

depends=('u-boot-xlnx' 'git clone https://github.com/Xilinx/u-boot-xlnx.git' 
         'linux-Digilent-Dev' 'git clone http://github.com/Digilent/linux-Digilent-Dev' 
         'qynq_base' 'git clone http://github.com/qiweiii-git/qynq_base.git')

patchs=( 'u-boot-xlnx' 'u-boot.patch' )

#*****************************************************************************
# Set environment
#*****************************************************************************
source /opt/Xilinx/SDK/2015.4/settings64.sh
source /opt/Xilinx/Vivado/2015.4/settings64.sh

#*****************************************************************************
# Get depends
#*****************************************************************************
workDir=$(pwd)

if [ ! -d .depend ]; then
   mkdir .depend
   echo "Info: .depend created"
fi

dependCnt=${#depends[*]}
patchsCnt=${#patchs[*]}

if (( $dependCnt > 0 )); then
   cd .depend
   for((i=0; i<dependCnt; i=i+2))
   do
      if [ ! -d ${depends[i]} ]; then
         echo "Getting ${depends[i]}"
         ${depends[i+1]}
      fi
   done
   cd $workDir
   echo "Info: All depends got"
fi

#*****************************************************************************
# Copy files
#*****************************************************************************
MkdirBuild() {
   rm -rf .build
   mkdir .build
   cp -ra ./* .build
   #cp -ra ./.depend .build
}
MkdirBuild

#*****************************************************************************
# Build u-boot
#*****************************************************************************
BuildUboot() {
   cd .depend/u-boot-xlnx
   git checkout xilinx-v2015.4

   patchApply='0'
   if (( $patchsCnt > 0 )); then
      for((i=0; i<patchsCnt; i=i+2))
      do
         if [[ ${patchs[i]} -eq 'u-boot-xlnx' ]]; then
            echo "Applying patch for ${patchs[i]}"
            patch -p1 < $workDir/code/patchs/${patchs[i+1]}
            patchApply='1'
         fi
      done
   fi

   if [[ $patchApply -eq '1' ]]; then
      make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- qynq_config
   else
      make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- zynq_zed_config
   fi
   make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-

   cp u-boot $workDir/project/$projectName/bin
   make clean
   make mrproper
   git add ./ --all
   git reset --hard HEAD
   cd $workDir
}

#*****************************************************************************
# Build kernel
#*****************************************************************************
BuildKernel() {
   cd .depend/linux-Digilent-Dev
   #make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- xilinx_zynq_defconfig
   make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- uImage LOADADDR=0x00008000
   make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-

   cp arch/arm/boot/uImage ../../project/$projectName/bin
   cd ../../

   # Build dtb
   cd .depend/linux-Digilent-Dev/arch/arm/boot/dts
   cp $workDir/code/dts/qynq.dts ./
   dtc -I dts -O dtb -o devicetree.dtb qynq.dts
   cp devicetree.dtb $workDir/project/$projectName/bin
   cd $workDir
}

#*****************************************************************************
# Build softwares
#*****************************************************************************
BuildSw() {
   cd .build/code/software/drivers/led
   arm-xilinx-linux-gnueabi-gcc -o LedGpioTest LedGpioTest.c
   cp LedGpioTest $workDir/project/$projectName/bin
   cd $workDir
}

#*****************************************************************************
# Build rootfs
#*****************************************************************************
BuildRootfs() {
   mkdir -p .build/.depend/
   cp -ra .depend/qynq_base .build/.depend/

   cd .build/.depend/qynq_base/rootfs
   gunzip arm_ramdisk.image.gz
   chmod u+rwx arm_ramdisk.image
   mkdir tmp_mnt
   sudo mount -o loop arm_ramdisk.image tmp_mnt/
   sudo cp $workDir/project/$projectName/bin/LedGpioTest tmp_mnt/usr/sbin/
   sudo umount tmp_mnt/
   gzip arm_ramdisk.image

   mkimage -A arm -T ramdisk -C gzip -d arm_ramdisk.image.gz uramdisk.image.gz

   cp uramdisk.image.gz $workDir/project/$projectName/bin

   cd $workDir
}

#*****************************************************************************
# Build firmware
#*****************************************************************************
BuildFw() {
   mkdir -p .build/.depend/
   cp -ra .depend/qynq_base .build/.depend/
   cp -f .depend/qynq_base/build/Run.tcl .build/project/$projectName

   cd .build/project/$projectName
   echo "RunFw $projectName xc7z020clg400-2 0 " >> Run.tcl
   vivado -mode batch -source Run.tcl

   cp $projectName.runs/impl_1/$projectName.bit $workDir/project/$projectName/bin
   cp $projectName.sdk/$projectName.hdf $workDir/project/$projectName/bin
   cd $workDir
}

#*****************************************************************************
# Build FSBL
#*****************************************************************************
BuildBootBin() {
   MkdirBuild
   cp -f .depend/qynq_base/build/Run.tcl .build/project/$projectName/bin

   cd .build/project/$projectName/bin
   echo "RunFsbl $projectName " >> Run.tcl
   xsdk -batch -source Run.tcl

   cp sw_workspace/$projectName\_fsbl/Debug/$projectName\_fsbl.elf $workDir/project/$projectName/bin
   cd $workDir

   # Build BOOT.BIN
   MkdirBuild
   cd .build/project/$projectName/bin
   cp u-boot u-boot.elf

   echo "the_ROM_image:"                           >> image.bif
   echo "{"                                        >> image.bif
   echo "   [bootloader]./"$projectName"_fsbl.elf" >> image.bif
   echo "   ./$projectName.bit"                    >> image.bif
   echo "   ./u-boot.elf"                          >> image.bif
   echo "}"                                        >> image.bif
   echo "exec bootgen -arch zynq -image image.bif -w -o BOOT.BIN" >> RunBoot.tcl
   xsdk -batch -source RunBoot.tcl
   cp BOOT.BIN $workDir/project/$projectName/bin

   cd $workDir
}

#*****************************************************************************
# Main
#*****************************************************************************
if [[ $buildUboot -eq 1 ]]; then
   BuildUboot
fi

if [[ $buildKernel -eq 1 ]]; then
   BuildKernel
   BuildSw
   BuildRootfs
fi

if [[ $buildFw -eq 1 ]]; then
   BuildFw
fi

if [[ $buildBootBin -eq 1 ]]; then
   BuildBootBin
fi

echo "Info: All builds got"
