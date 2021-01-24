//*****************************************************************************
//    # #              Name   : BaseDef.h
//  #     #            Date   : Jan. 20, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
//
//*****************************************************************************

#ifndef __BASE_DEFINE__
#define __BASE_DEFINE__

//*****************************************************************************
// Includes
//*****************************************************************************
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"

//*****************************************************************************
// Reg define
//*****************************************************************************
#define REG_FW_VER            0x0
#define REG_LED_CTRL          0x1
#define REG_FMT_DEF           0x2
#define REG_CAM_CONFIG_EN     0x3
#define REG_CAM_CONFIG_DATA   0x4
#define REG_CAM_CONFIG_STATUS 0x5
#define REG_CAM_PCLK_FREQ     0x6
#define REG_CLK_74P25_FREQ    0x7
#define REG_AXIS_DEBUG        0x8

//*****************************************************************************
// Defines
//*****************************************************************************
#define regRead  Xil_In32
#define regWrite Xil_Out32

//#define printf xil_printf

#define false 1
#define true 0

#define REGCTRL_BASEADDR XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR

#endif
