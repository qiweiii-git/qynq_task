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

//*****************************************************************************
// Reg define
//*****************************************************************************
#define REG_FW_VER            0x00
#define REG_LED_CTRL          0x10
#define REG_FMT_DEF           0x20
#define REG_CAM_CONFIG_EN     0x30
#define REG_CAM_CONFIG_DATA   0x40
#define REG_CAM_CONFIG_STATUS 0x50
#define REG_CAM_PCLK_FREQ     0x60
#define REG_CLK_74P25_FREQ    0x70
#define REG_AXISI_DEBUG       0x80
#define REG_AXISO_DEBUG       0x90
#define REG_BMP_SEL           0xA0

//*****************************************************************************
// Defines
//*****************************************************************************
#define regRead  Xil_In32
#define regWrite Xil_Out32

//#define printf xil_printf

#define false 1
#define true 0

#define REGCTRL_BASEADDR 0x41000000
#define VDMA0_BASEADDR   0x41100000

#define BMP_WIDTH  1280*3
#define BMP_HEIGHT 720

#endif
