# qynq_task
 ZYNQ开发工程目录
 00-04为采用vivado2015.4及sdk2015.4编译
 05开始采用vivado2020.2及vitis2020.2编译

## qynq00_linux
 ZYNQ linux工程，运行官方u-boot，内核，ZED开发板设备树及Rootfs。

## qynq01_uboot
 修改Xilinx官方u-boot及添加设备树，使适配AX7020开发板。
 
## qynq02_axigpio
 添加AXI GPIO控制LED功能。

## qynq03_regrw
 寄存器控制工程。

## qynq04_ovhdmi
 OV5640输入至HDMI输出工程。

## qynq05_hls
 在qynq04_ovhdmi基础上添加HLS应用。
