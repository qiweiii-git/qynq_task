#add constraints
add_files -fileset constrs_1 -norecurse ../../.depend/qynq_base/build/constraints/pinout.xdc
add_files -fileset constrs_1 -norecurse ./source/timing.xdc

#add source
add_files ./source/qynq06_sdp2hdmi.sv

add_files ../../code/firmware/Define.vh
add_files ../../code/firmware/RegDef.vh
add_files ../../code/firmware/QwiFmtDef.vh

add_files ../../.depend/qynq_base/fpgatools/qwiregctrl.v
add_files ../../.depend/qynq_base/fpgatools/axis/vid2axis.v
add_files ../../.depend/qynq_base/fpgatools/axis/axis2native.sv
add_files ../../.depend/qynq_base/fpgatools/hdmi/hdmi_vtg.v
add_files ../../.depend/qynq_base/fpgatools/rgb2dvi/ClockGen.vhd
add_files ../../.depend/qynq_base/fpgatools/rgb2dvi/DVI_Constants.vhd
add_files ../../.depend/qynq_base/fpgatools/rgb2dvi/OutputSERDES.vhd
add_files ../../.depend/qynq_base/fpgatools/rgb2dvi/rgb2dvi.vhd
add_files ../../.depend/qynq_base/fpgatools/rgb2dvi/SyncAsync.vhd
add_files ../../.depend/qynq_base/fpgatools/rgb2dvi/SyncAsyncReset.vhd
add_files ../../.depend/qynq_base/fpgatools/rgb2dvi/TMDS_Encoder.vhd
add_files ../../.depend/qynq_base/fpgatools/qwicom.sv
add_files ../../.depend/qynq_base/fpgatools/qwifmtdef.vh
add_files ../../.depend/qynq_base/fpgatools/qwiif.sv
