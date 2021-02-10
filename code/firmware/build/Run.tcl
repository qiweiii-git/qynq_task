#******************************************************************************
#    # #              Name   : Run.tcl
#  #     #            Date   : Feb. 18, 2019
# #    #  #  #     #  Author : Qiwei Wu
#  #     #  # #  # #  Version: 2.0
#    # #  #    #   #
#
# This module is the tcl script of building project.
#
# Change History:
#  VER.   Author         DATE              Change Description
#  1.0    Qiwei Wu       Feb. 18, 2019     Initial Release
#  1.1    Qiwei Wu       Mar. 29, 2020     Create the process
#  1.2    Qiwei Wu       Apr. 06, 2020     Add system build
#  1.3    Qiwei Wu       Sep. 15, 2020     Add local build process
#  1.4    Qiwei Wu       Nov. 21, 2020     Add FSBL build process
#  1.5    Qiwei Wu       Jan. 25, 2021     Add Standalone software build process
#  2.0    Qiwei Wu       Jan. 31, 2021     Add Vitis2020.2 build process
#******************************************************************************

proc RunFw { buildName chipType localBuild version} {
   # Set CPU count
   set cores 1
   if {![catch {open "/proc/cpuinfo"} f]} {
      set coreNum [regexp -all -line {^processor\s} [read $f]]
      close $f

      if {$coreNum > 0} {
         set cores $coreNum
      }
   }

   if {$localBuild >= 1} {
      # create a new temporary folder for building project
      file delete -force ../.build
      file copy -force ./ ../.build

      cd ../.build
   }

   # create project
   create_project $buildName -part $chipType

   # add working path
   set current_path [pwd]

   # add source file to project
   source ./FileList.tcl

   # create embedding subsystem
   if {$version == 2020} {
      source ./System2020.tcl
   } else {
      source ./System.tcl
   }


   # Gobal run generate subsystem
   set_property synth_checkpoint_mode None [get_files ./$buildName.srcs/sources_1/bd/system/system.bd]
   generate_target -force all [get_files ./$buildName.srcs/sources_1/bd/system/system.bd]

   # set top
   set_property top $buildName [current_fileset]
   update_compile_order -fileset sources_1

   # synthesize
   reset_run synth_1
   launch_runs synth_1 -jobs $cores
   wait_on_run synth_1

   # Generate the HDF for the SDK.
   file mkdir $buildName.sdk
   if {$version == 2020} {
      #set_property pfm_name {} [get_files -all ./$buildName.srcs/sources_1/bd/system/system.bd]
      write_hw_platform -fixed -force -file $buildName.sdk/$buildName.xsa
   } else {
      write_hwdef -force -file $buildName.sdk/$buildName.hdf
   }

   # implement
   launch_runs impl_1 -jobs $cores
   wait_on_run impl_1

   # Generate the bitstream.
   launch_runs impl_1 -to_step write_bitstream -jobs $cores
   wait_on_run impl_1
}

proc RunFsbl { buildName } {
   set proc ps7_cortexa9_0
   set os standalone
   sdk set_workspace ./sw_workspace

   sdk create_hw_project -name $buildName\_hw -hwspec $buildName.hdf

   sdk create_app_project -name $buildName\_fsbl -hwproject $buildName\_hw -proc ps7_cortexa9_0 -os standalone -lang C -app {Zynq FSBL}

   # Enable runing the ps7_post_config
   # Set the replace list
   set strOld "if(BitstreamFlag)"
   set strNew "/* if(BitstreamFlag) */"
   set strList [list $strOld $strNew]

   # Read necessary file
   set readFile [open ./sw_workspace/$buildName\_fsbl/src/main.c r]
   set strFile [read -nonewline $readFile]
   close $readFile

   # Replace the string and then rewrite the file
   set strFileNew [string map $strList $strFile]
   set writeFile [open ./sw_workspace/$buildName\_fsbl/src/main.c w]
   puts $writeFile $strFileNew
   close $writeFile

   sdk build_project -type all

   # exit
   exit
}

proc RunFsbl2020 { buildName } {
   # Set Vitis workspace
   setws ./sw_workspace

   # Create application project
   app create -name $buildName\_fsbl -hw $buildName.xsa -os standalone -proc ps7_cortexa9_0 -template {Zynq FSBL}
   app config -name $buildName\_fsbl define-compiler-symbols {FSBL_DEBUG_INFO}
   app build -name $buildName\_fsbl

   # exit
   exit
}

proc RunStandalone { buildName } {
   # set workspace
   sdk set_workspace ./sw_workspace
   sdk create_hw_project -name $buildName\_hw -hwspec $buildName.hdf
   sdk create_bsp_project -name $buildName\_bsp -hwproject $buildName\_hw -proc $proc -os standalone
   sdk create_app_project -name $buildName\_sw -hwproject $buildName\_hw -proc ps7_cortexa9_0 -os standalone -lang C -bsp $buildName\_bsp -app {Empty Application}

   # copy files
   eval file copy -force [glob ../source/*] ./sw_workspace/$buildName\_sw/src/
   eval file copy -force [glob ../../../code/software/standalone/*] ./sw_workspace/$buildName\_sw/src/
   eval file copy -force [glob ../../../code/software/utils/*] ./sw_workspace/$buildName\_sw/src/applications/

   # build
   sdk build_project -type bsp -name $buildName\_bsp
   sdk build_project -type app -name $buildName\_sw

   # exit
   exit
}

proc RunStandalone2020 { buildName } {
   # Set Vitis workspace
   setws ./sw_workspace

   # Create application project
   app create -name $buildName\_sw -hw $buildName.xsa -proc ps7_cortexa9_0 -os standalone -lang C -template {Empty Application}

   # copy files
   eval file copy -force [glob ../source/*] ./sw_workspace/$buildName\_sw/src/
   eval file copy -force [glob ../../../code/software/standalone/*] ./sw_workspace/$buildName\_sw/src/
   eval file copy -force [glob ../../../code/software/utils/*] ./sw_workspace/$buildName\_sw/src/applications/

   # build
   app build -name $buildName\_sw

   # exit
   exit
}

# RunFw qwi00_led xc7z020clg400-2 0
# RunFsbl qwi00_led
