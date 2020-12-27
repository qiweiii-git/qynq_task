#add constraints
add_files -fileset constrs_1 -norecurse ../../.depend/qynq_base/build/constraints/pinout.xdc

#add source
add_files ./source/qynq03_regrw.sv

add_files ../../code/firmware/Define.vh
add_files ../../code/firmware/RegDef.vh

add_files ../../.depend/qynq_base/fpgatools/qwiregctrl.v
