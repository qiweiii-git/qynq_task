//*****************************************************************************
//    # #              Name   : RegDef.vh
//  #     #            Date   : Dec. 25, 2020
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.1
//    # #  #    #   #
//
// RegDef.vh.
//
// Change History:
//  VER.   Author         DATE              Change Description
//  1.0    Qiwei Wu       Dec. 25, 2020     Initial Release
//  1.1    Qiwei Wu       Feb. 18, 2021     Add AXIS_BMP_SEL
//*****************************************************************************

//*****************************************************************************
// reg defines
//*****************************************************************************
localparam FW_VER         = 0,
           LED_CTRL       = 1,
           FMT_DEF        = 2,
           CAM_CONEN      = 3,
           CAM_CONDA      = 4,
           CAM_STATUS     = 5,
           CAM_PCLK_CNT   = 6,
           CLK_74P25M_CNT = 7,
           AXISI_DEBUG_CNT= 8,
           AXISO_DEBUG_CNT= 9,
           AXIS_BMP_SEL   = 10,
           REG_CNT        = 11;

//*****************************************************************************
// reg initialized value
//*****************************************************************************
wire [31:0] REG_INIT[0:REG_CNT-1];

assign REG_INIT[FW_VER]  = 32'h0006_1001;
assign REG_INIT[LED_CTRL] = 32'h0000_000F;
assign REG_INIT[FMT_DEF] = 32'h0000_0001;
