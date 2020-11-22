#add constraints
add_files -fileset constrs_1 -norecurse ../../.depend/qynq_base/build/constraints/pinout.xdc

#add source
add_files ./source/qynq00_linux.sv

#global define
#set_property is_global_include true [get_files define.vh]
