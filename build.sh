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
projectName='qynq07_sdp2hdmi'

if [[ -n "$1" ]]; then
   projectName=$1
fi

teamcityBuild=0
if [[ -n "$2" ]]; then
   teamcityBuild=1
   echo "Info: Build from Teamcity!"
fi

teamcityBuildId=0
if [[ -n "$3" ]]; then
   teamcityBuildId=$3
   teamcityBuildId=${teamcityBuildId: 0 :6}
   echo "Info: Now teamcity build ID is $teamcityBuildId!"
   #let "teamcityBuildId=$teamcityBuildId-1"
   #echo "Info: Last teamcity build ID is $teamcityBuildId!"
fi

source ./depends.sh
source ./project/$projectName/config.sh
source ./project/$projectName/UpgradeConfig.sh

dependCnt=${#depends[*]}
patchsCnt=${#patchs[*]}
appCnt=${#apps[*]}
drvCnt=${#drvs[*]}
upgradeFileCnt=${#upgradeFiles[*]}

workDir=$(pwd)
#*****************************************************************************
# Set environment
#*****************************************************************************
if [[ $ver -eq '2020' ]]; then
   source /tools/Xilinx/Vivado/2020.2/settings64.sh
   source /tools/Xilinx/Vitis/2020.2/settings64.sh
   source /tools/Xilinx/petalinux/2020.2/settings.sh
else
   source /tools/Xilinx/SDK/2015.4/settings64.sh
   source /tools/Xilinx/Vivado/2015.4/settings64.sh
fi

#*****************************************************************************
# Get depends
#*****************************************************************************
GetDepends() {
   if [ ! -d .depend ]; then
      mkdir .depend
      echo "Info: .depend created"

      if [[ dependCnt > 0 ]]; then
         cd .depend
         for((i=0; i<dependCnt; i=i+2))
         do
            if [ ! -d ${depends[i]} ]; then
               if [[ -d /tools/Xilinx/source/${depends[i]} ]]; then
                  echo "Getting ${depends[i]} from local"
                  cp -ra /tools/Xilinx/source/${depends[i]} ./
               else
                  echo "Getting ${depends[i]} from URL"
                  ${depends[i+1]}
               fi
            fi
         done
         cd $workDir
         echo "Info: All depends got"
      fi

      if [[ patchsCnt > 0 ]]; then
         cd .depend
         dependDir=$(pwd)
         for((i=0; i<patchsCnt; i=i+2))
         do
            cd $dependDir
            cd ${patchs[i]}
            echo "Applying patch ${patchs[i+1]}"
            patch -p1 < $workDir/code/patchs/${patchs[i+1]}
         done
         #sudo chmod 0755 -R ./
         cd $workDir
         echo "Info: All patchs applied"
      fi
   fi
}

#*****************************************************************************
# Copy files
#*****************************************************************************
MkdirBuild() {
   sudo rm -rf .build
   mkdir .build
   cp -ra ./* .build
   #cp -ra ./.depend .build
}

#*****************************************************************************
# Build standalone
#*****************************************************************************
BuildStandalone() {
   cp -f code/firmware/build/Run.tcl .build/project/$projectName/bin

   cd .build/project/$projectName/bin
   if [[ $ver -eq '2020' ]]; then
      echo "RunStandalone2020 $projectName " >> Run.tcl
      xsct Run.tcl
   else
      echo "RunStandalone $projectName " >> Run.tcl
      xsdk -batch -source Run.tcl
   fi

   cp sw_workspace/$projectName\_sw/Debug/$projectName\_sw.elf $workDir/project/$projectName/bin
   cd $workDir
}

#*****************************************************************************
# Build u-boot
#*****************************************************************************
BuildUboot() {
   cd $workDir
   cd .depend/u-boot-xlnx
   git add ./ --all
   git reset --hard HEAD
   git checkout xilinx-v2015.4

   if [[ $patchsCnt > 0 ]]; then
      for((i=0; i<patchsCnt; i=i+2))
      do
         if [[ ${patchs[i]} -eq 'u-boot-xlnx' ]]; then
            echo "Applying patch for ${patchs[i]}"
            patch -p1 < $workDir/code/patchs/${patchs[i+1]}
         fi
      done
   fi

   make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- qynq_config
   make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-

   cp u-boot $workDir/project/$projectName/bin
   make clean
   make mrproper
   git add ./ --all
   git reset --hard HEAD
   cd $workDir
}

#*****************************************************************************
# Get u-boot
#*****************************************************************************
GetUboot() {
   cd $workDir
   cp $workDir/code/files/u-boot $workDir/project/$projectName/bin
}

#*****************************************************************************
# Build kernel
#*****************************************************************************
BuildKernel() {
   cd $workDir
   cd .depend/linux-Digilent-Dev

   sudo cp $workDir/code/linux/arch ./ -rf

   make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi- qynq_defconfig uImage LOADADDR=0x00008000
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
# Get kernel
#*****************************************************************************
GetKernelFile() {
   cd $workDir
   cp $workDir/code/files/uImage $workDir/project/$projectName/bin
   cp $workDir/code/files/devicetree.dtb $workDir/project/$projectName/bin
}

#*****************************************************************************
# Build drivers
#*****************************************************************************
BuildDrv() {
   drvDir=$1
   makeDir=$2
   cd .build/$makeDir

   if [[ drvCnt > 0 ]]; then
      for((i=0; i<drvCnt; i=i+2))
      do
         echo "obj-m += ${drvs[i]}.o" >> Makefile
      done
   fi

   make ARCH=arm CROSS_COMPILE=arm-xilinx-linux-gnueabi-

   if [[ drvCnt > 0 ]]; then
      for((i=0; i<drvCnt; i=i+2))
      do
         cp ${drvs[i]}.ko $workDir/project/$projectName/bin
      done
   fi

   cd $workDir
}

#*****************************************************************************
# Build softwares
#*****************************************************************************
BuildSw() {
   appDir=$1
   makeDir=$2
   cd .build/$makeDir

   if [[ $appDir = *cgi* ]]; then
      # build CGI
      if [[ $appDir = *upload* ]]; then
         arm-xilinx-linux-gnueabi-gcc -I../utils -I../applications -I../cgic -o $appDir.cgi \
            $appDir.c ../utils/*.c ../applications/*.c ../cgic/*.c
         cp $appDir.cgi $workDir/project/$projectName/bin
      else
         arm-xilinx-linux-gnueabi-gcc -I../utils -I../applications -o $appDir.cgi \
            $appDir.c ../utils/*.c ../applications/*.c
         cp $appDir.cgi $workDir/project/$projectName/bin
      fi
   else
      arm-xilinx-linux-gnueabi-gcc -lpthread -I../utils -I../applications -o $appDir \
         $appDir.c ../utils/*.c ../applications/*.c
      cp $appDir $workDir/project/$projectName/bin
   fi
   cd $workDir
}

#*****************************************************************************
# Build rootfs
#*****************************************************************************
BuildRootfs() {
   cd $workDir
   mkdir -p .build/rootfs/
   cp -f code/rootfs/arm_ramdisk.image.gz .build/rootfs/

   cd .build/rootfs/
   gunzip arm_ramdisk.image.gz
   chmod u+rwx arm_ramdisk.image
   mkdir tmp_mnt
   sudo mount -o loop arm_ramdisk.image tmp_mnt/

   if [[ -d $workDir/code/rootfs/var/www ]]; then
      sudo rm -rf tmp_mnt/var/www
   fi
   sudo mkdir -p $workDir/code/rootfs/var/www/cgi-bin

   sudo cp $workDir/code/rootfs/etc tmp_mnt/ -rf
   sudo cp $workDir/code/rootfs/var tmp_mnt/ -rf
   sudo cp $workDir/code/rootfs/usr tmp_mnt/ -rf

   if [[ appCnt > 0 ]]; then
      for((i=0; i<appCnt; i=i+2))
      do
         appName=${apps[i]##*/}
         if [[ $appName = server ]]; then
            sudo cp $workDir/project/$projectName/bin/$appName.cgi tmp_mnt/var/www/cgi-bin/
         elif [[ $appName = upload ]]; then
            sudo cp $workDir/project/$projectName/bin/$appName.cgi tmp_mnt/var/www/cgi-bin/
         else
            sudo cp $workDir/project/$projectName/bin/$appName tmp_mnt/usr/sbin/
         fi
      done
   fi

   if [[ drvCnt > 0 ]]; then
      for((i=0; i<drvCnt; i=i+2))
      do
         drvName=${drvs[i]##*/}
         sudo cp $workDir/project/$projectName/bin/$drvName.ko tmp_mnt/lib/modules
      done
   fi

   sudo umount tmp_mnt/
   gzip arm_ramdisk.image

   mkimage -A arm -T ramdisk -C gzip -d arm_ramdisk.image.gz uramdisk.image.gz

   cp uramdisk.image.gz $workDir/project/$projectName/bin

   cd $workDir
}

#*****************************************************************************
# Get or Build Firmware
#*****************************************************************************
GetOrBuildFw() {
   getFw=1
   verUrl="http://39.98.121.216:8111/repository/download/QynqTask_Build/$teamcityBuildId:id/.ver/ver.txt"

   lastVer=$(wget -q -O - $verUrl | grep "firmware" | tr -d [:space:][:alpha:])
   echo "lastVer is $lastVer"
   thisVer=$(git log -n 1 code/firmware/ | head -n 1 | tr -d [:space:][:alpha:])
   echo "thisVer is $thisVer"

   if [[ ! $lastVer -eq $thisVer ]]; then
      getFw=0
   fi
   echo "firmware $thisVer" >> $workDir/../.ver/ver.txt

   lastVer=$(wget -q -O - $verUrl | grep "fwTop" | tr -d [:space:][:alpha:])
   echo "lastVer is $lastVer"
   thisVer=$(git log -n 1 project/$projectName/source | head -n 1 | tr -d [:space:][:alpha:])
   echo "thisVer is $thisVer"

   if [[ ! $lastVer -eq $thisVer ]]; then
      getFw=0
   fi
   echo "fwTop $thisVer" >> $workDir/../.ver/ver.txt

   if [[ $getFw == 1 ]]; then
      echo "Get firmware!"
      cd $workDir/project/$projectName/bin
      fwUrl="http://39.98.121.216:8111/repository/download/QynqTask_Build/$teamcityBuildId:id/.bin/$projectName.bit"
      wget $fwUrl
      fwUrl="http://39.98.121.216:8111/repository/download/QynqTask_Build/$teamcityBuildId:id/.bin/$projectName.hdf"
      wget $fwUrl
      rptFile=$projectName\_rpt
      fwUrl="http://39.98.121.216:8111/repository/download/QynqTask_Build/$teamcityBuildId:id/.bin/$rptFile.tar.gz"
      wget $fwUrl
      cd $workDir
   else
      echo "Build firmware!"
      MkdirBuild
      BuildFw
   fi
}

#*****************************************************************************
# Get Firmware from Local
#*****************************************************************************
GetFwFromLocal() {
   cd $workDir
   cp $workDir/../code/firmware/platform/firmware.bit        $workDir/project/$projectName/bin/$projectName.bit -f
   cp $workDir/../code/firmware/platform/firmware.bit        $workDir/project/$projectName/bin/firmware.bit -f
   cp $workDir/../code/firmware/platform/firmware.hdf        $workDir/project/$projectName/bin/$projectName.hdf -f
   cp $workDir/../code/firmware/platform/firmware_rpt.tar.gz $workDir/project/$projectName/bin/$projectName\_rpt.tar.gz -f
   cd $workDir
}

#*****************************************************************************
# Build firmware
#*****************************************************************************
BuildFw() {
   cd $workDir
   cp -f code/firmware/build/Run.tcl .build/code/firmware/build

   cd .build/code/firmware/build
   if [[ $ver -eq '2020' ]]; then
      echo "RunFw platform xc7z020clg400-2 0 2020 " >> Run.tcl
   else
      echo "RunFw platform xc7z020clg400-2 0 2015" >> Run.tcl
   fi
   vivado -mode batch -source Run.tcl

   cp platform.runs/impl_1/platform.bit $workDir/code/firmware/platform/firmware.bit

   tar -zcvf platform_rpt.tar.gz \
      platform.runs/impl_1/platform_timing_summary_routed.rpt \
      platform.runs/impl_1/platform_utilization_placed.rpt
   cp platform_rpt.tar.gz $workDir/code/firmware/platform/firmware_rpt.tar.gz

   if [[ $ver -eq '2020' ]]; then
      cp platform.sdk/platform.xsa $workDir/code/firmware/platform/firmware.xsa
   else
      cp platform.sdk/platform.hdf $workDir/code/firmware/platform/firmware.hdf
   fi
   cd $workDir
}

#*****************************************************************************
# Build FSBL
#*****************************************************************************
BuildBootBin() {
   cp -f code/firmware/build/Run.tcl .build/project/$projectName/bin

   cd .build/project/$projectName/bin
   if [[ $ver -eq '2020' ]]; then
      echo "RunFsbl2020 $projectName " >> Run.tcl
      xsct Run.tcl
   else
      echo "RunFsbl $projectName " >> Run.tcl
      xsdk -batch -source Run.tcl
   fi

   cp sw_workspace/$projectName\_fsbl/Debug/$projectName\_fsbl.elf $workDir/project/$projectName/bin

   sleep 10
   # Build BOOT.BIN
   cp sw_workspace/$projectName\_fsbl/Debug/$projectName\_fsbl.elf ./ -f

   echo "the_ROM_image:"                           >> image.bif
   echo "{"                                        >> image.bif
   echo "   [bootloader]./"$projectName"_fsbl.elf" >> image.bif
   #echo "   ./$projectName.bit"                    >> image.bif
   if [[ ! $elf -eq 'uboot' ]]; then
      echo "   ./"$elf"\_sw.elf"                   >> image.bif
   else
      cp u-boot u-boot.elf
      echo "   ./u-boot.elf"                       >> image.bif
   fi
   echo "}"                                        >> image.bif
   echo "exec bootgen -arch zynq -image image.bif -w -o BOOT.BIN" >> RunBoot.tcl
   if [[ $ver -eq '2020' ]]; then
      xsct RunBoot.tcl
   else
      xsdk -batch -source RunBoot.tcl
   fi
   cp BOOT.BIN $workDir/project/$projectName/bin -f

   cd $workDir
}

#*****************************************************************************
# Build FSBL
#*****************************************************************************
BuildPetaLinux() {
   # hard to use
   cd .build/project/$projectName/bin
   petalinux-create --type project --template zynq --name qynq06_sdp2hdmi
   cd qynq06_sdp2hdmi
   petalinux-config --get-hw-description ../qynq06_sdp2hdmi.xsa
   #/tools/Xilinx/source/u-boot-xlnx
   #/tools/Xilinx/source/linux-xlnx 
   petalinux-config -c u-boot
   petalinux-config -c kernel
   petalinux-config -c rootfs
   petalinux-build
   petalinux-package --boot --fsbl ./images/linux/zynq_fsbl.elf --fpga ../qynq06_sdp2hdmi.bit --uboot --force
}

#*****************************************************************************
# Build u-boot 2020
#*****************************************************************************
BuildUboot2020() {
   cd $workDir
   cp -r .depend/u-boot-xlnx .build
   cd .build/u-boot-xlnx

   export CROSS_COMPILE=arm-linux-gnueabihf-
   export ARCH=arm
   make xilinx_zynq_virt_defconfig
   export DEVICE_TREE="zynq-zc702"
   make

   cp u-boot $workDir/project/$projectName/bin
   cd $workDir
}

#*****************************************************************************
# Build kernel2020
#*****************************************************************************
BuildKernel2020() {
   cd $workDir
   #cp -r .depend/linux-xlnx .build
   cd .depend/linux-xlnx

   make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- xilinx_zynq_defconfig uImage UIMAGE_LOADADDR=0x00008000
   make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

   cp arch/arm/boot/uImage ../../project/$projectName/bin
   cd $workDir/.depend/

   # Build dtb
   cd linux-xlnx/arch/arm/boot/dts
   cp $workDir/code/dts/qynq.dts ./
   dtc -I dts -O dtb -o devicetree.dtb qynq.dts
   cp devicetree.dtb $workDir/project/$projectName/bin
   cd $workDir
}

#*****************************************************************************
# Teamcity Prepare
#*****************************************************************************
TeamcityPre() {
   echo "Info: Build from Teamcity!"

   cd $workDir
   sudo rm -rf .bin
   mkdir .bin

   if [[ ! -d .ver ]]; then
      mkdir .ver
      touch .ver/ver.txt
   fi

   mkdir .tcb
   cp -ra ./* .tcb
   cp -ra ./.git .tcb
   cd .tcb
   workDir=$(pwd)
   sudo rm -rf $workDir/project/$projectName/bin
}

#*****************************************************************************
# Teamcity Push
#*****************************************************************************
TeamcityPushResult() {
   cp $workDir/project/$projectName/bin/* $workDir/../.bin -f
}

#*****************************************************************************
# Teamcity Post
#*****************************************************************************
TeamcityPost() {
   cd ../
   workDir=$(pwd)
   rm -rf .tcb
}

#*****************************************************************************
# Local building Post
#*****************************************************************************
LocalPost() {
   sudo rm -rf .bin
   mkdir .bin
   rm -rf .build

   cp $workDir/project/$projectName/bin/* $workDir/.bin -f
}

#*****************************************************************************
# Local building Post
#*****************************************************************************
PushUpgradeFile() {
   cd $workDir/.bin

   if [[ upgradeFileCnt > 0 ]]; then
      for((i=0; i<upgradeFileCnt; i=i+2))
      do
         if [[ ${upgradeFiles[i]} -eq 'userFile' ]]; then
            cp $workDir/project/$projectName/bin/${upgradeFiles[i+1]} ./ -f
         fi

         if [[ $i == 0 ]]; then
            tar -cvf $projectName\_upgrade.tar.gz ${upgradeFiles[i+1]}
         else
            tar -rvf $projectName\_upgrade.tar.gz ${upgradeFiles[i+1]}
         fi
      done
   fi

   rm -rf $workDir/.upgrade
   mkdir $workDir/.upgrade
   mv $projectName\_upgrade.tar.gz $workDir/.upgrade/$projectName\_$teamcityBuildId\_upgrade.tar.gz

   cd $workDir
}

#*****************************************************************************
# Main
#*****************************************************************************
if [[ $teamcityBuild == 1 ]]; then
   TeamcityPre
fi

GetDepends

if [ ! -d $workDir/project/$projectName/bin ]; then
   mkdir $workDir/project/$projectName/bin
   echo "Info: /Bin created"
fi

if [[ $buildFw -eq 1 ]]; then
   MkdirBuild
   BuildFw
else
   if [[ $teamcityBuild == 1 ]]; then
      echo "We would not build Firmware in teamcity since we do not have enough memory!"
      GetFwFromLocal
   fi
fi

if [[ $teamcityBuild == 1 ]]; then
   TeamcityPushResult
fi

if [[ $buildKernel -eq 1 ]]; then
   MkdirBuild

   if [[ $ver -eq '2020' ]]; then
      BuildKernel2020
   else
      BuildKernel
   fi
else
   GetKernelFile
fi

MkdirBuild
if [[ drvCnt > 0 ]]; then
   for((i=0; i<drvCnt; i=i+2))
   do
      echo "Building ${drvs[i]}"
      BuildDrv ${drvs[i]} ${drvs[i+1]}
   done
fi

if [[ appCnt > 0 ]]; then
   for((i=0; i<appCnt; i=i+2))
   do
      echo "Building ${apps[i]}"
      BuildSw ${apps[i]} ${apps[i+1]}
   done
fi

BuildRootfs

if [[ $teamcityBuild == 1 ]]; then
   TeamcityPushResult
fi

if [[ $buildBootBin -eq 1 ]]; then
   MkdirBuild
   if [[ ${elf[i]} != 'uboot' ]]; then
      BuildStandalone
   else
      if [[ $ver -eq '2020' ]]; then
         BuildUboot2020
      else
         BuildUboot
      fi
   fi
else
   GetUboot
fi

sleep 10
MkdirBuild
BuildBootBin

if [[ $teamcityBuild == 1 ]]; then
   TeamcityPushResult
fi

if [[ $buildPetaLinux -eq 1 ]]; then
   MkdirBuild
   BuildPetaLinux
fi

if [[ $teamcityBuild == 1 ]]; then
   TeamcityPushResult
fi

if [[ $teamcityBuild == 1 ]]; then
   TeamcityPost
else
   LocalPost
fi

PushUpgradeFile

echo "Info: All builds got"
