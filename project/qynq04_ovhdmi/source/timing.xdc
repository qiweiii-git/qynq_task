
set_clock_groups -asynchronous \
-group [get_clocks -of_objects [get_pins u_clk_74p25m/CLKOUT0]] \
-group [get_clocks clk_fpga_0] \
-group [get_clocks clk_fpga_1]
