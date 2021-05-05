#add constraints
add_files -fileset constrs_1 -norecurse ./constraints/pinout.xdc
add_files -fileset constrs_1 -norecurse ./constraints/timing.xdc

#add source
add_files ../platform.sv
add_files ../ov5640/cam_wrapper.v

add_files ../Define.vh
add_files ../RegDef.vh
add_files ../QwiFmtDef.vh

add_files ../fpgatools/qwiregctrl.v
add_files ../fpgatools/axis/vid2axis.v
add_files ../fpgatools/axis/axis2native.sv
add_files ../fpgatools/hdmi/hdmi_vtg.v
add_files ../fpgatools/iic/i2c_com.v
add_files ../fpgatools/iic/i2c_config.sv
add_files ../fpgatools/others/cam_8b16b.v
add_files ../fpgatools/others/cam_reset.v
add_files ../fpgatools/rgb2dvi/ClockGen.vhd
add_files ../fpgatools/rgb2dvi/DVI_Constants.vhd
add_files ../fpgatools/rgb2dvi/OutputSERDES.vhd
add_files ../fpgatools/rgb2dvi/rgb2dvi.vhd
add_files ../fpgatools/rgb2dvi/SyncAsync.vhd
add_files ../fpgatools/rgb2dvi/SyncAsyncReset.vhd
add_files ../fpgatools/rgb2dvi/TMDS_Encoder.vhd
add_files ../fpgatools/qwicom.sv
add_files ../fpgatools/qwiif.sv
