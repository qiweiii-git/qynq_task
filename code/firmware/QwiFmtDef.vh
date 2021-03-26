//*****************************************************************************
// QwiFmtDef.vh.
//
// Change History:
//  VER.   Author         DATE              Change Description
//  1.0    Qiwei Wu       Apr. 11, 2020     Initial Release
//  1.1    Qiwei Wu       Mar. 26, 2021     Add RGB defines
//*****************************************************************************

//*****************************************************************************
// foramt defines
//*****************************************************************************
localparam FMT_720P50  = 0,
           FMT_720P60  = 1,
           FMT_1080P30 = 2,
           FMT_1080P60 = 3,
           FMT_CNT     = 4;

//*****************************************************************************
// timing defines
//*****************************************************************************
`define HSYNC_START 11:0
`define HSYNC_END   23:12
`define VSYNC_START 35:24
`define VSYNC_END   47:36
`define HBLAK_START 59:48
`define HBLAK_END   71:60
`define VBLAK_START 83:72
`define VBLAK_END   95:84
`define ACTPPL_CNT  107:96
`define ACTLPF_CNT  119:108
`define TOLPPL_CNT  131:120
`define TOLLPF_CNT  143:132
`define TIMING_TOL  144

wire [`TIMING_TOL-1:0] FMT_TIMING[0:FMT_CNT-1];

//                                TOLLPF_CNT TOLPPL_CNT  ACTLPF_CNT ACTPPL_CNT
assign FMT_TIMING[FMT_720P50] = { {12'd750}, {12'd1980}, {12'd720}, {12'd1280},
//                                VBLAK_END  VBLAK_START HBLAK_END HBLAK_START
                                  {12'd030}, {12'd001}, {12'd700}, {12'd001},
//                                VSYNC_END  VSYNC_START HSYNC_END HSYNC_START
                                  {12'd010}, {12'd006}, {12'd481}, {12'd441} };

//                                TOLLPF_CNT TOLPPL_CNT  ACTLPF_CNT ACTPPL_CNT
assign FMT_TIMING[FMT_720P60] = { {12'd750}, {12'd1650}, {12'd720}, {12'd1280},
//                                VBLAK_END  VBLAK_START HBLAK_END HBLAK_START
                                  {12'd030}, {12'd001}, {12'd370}, {12'd001},
//                                VSYNC_END  VSYNC_START HSYNC_END HSYNC_START
                                  {12'd010}, {12'd006}, {12'd151}, {12'd111} };

//                                 TOLLPF_CNT  TOLPPL_CNT  ACTLPF_CNT ACTPPL_CNT
assign FMT_TIMING[FMT_1080P30] = { {12'd1125}, {12'd2200}, {12'd1080}, {12'd1920},
//                                 VBLAK_END  VBLAK_START HBLAK_END HBLAK_START
                                   {12'd045}, {12'd001}, {12'd280}, {12'd001},
//                                 VSYNC_END  VSYNC_START HSYNC_END HSYNC_START
                                   {12'd009}, {12'd005}, {12'd133}, {12'd089} };

assign FMT_TIMING[FMT_1080P60] = FMT_TIMING[FMT_1080P30];

//*****************************************************************************
// RGB defines
//*****************************************************************************
`define RGB_B 7:0
`define RGB_G 15:8
`define RGB_R 23:16

localparam RGB_RED = 0,
           RGB_ORA = 1,
           RGB_YEL = 2,
           RGB_GRE = 3,
           RGB_CYA = 4,
           RGB_BLU = 5,
           RGB_PUR = 6,
           RGB_WHI = 7,
           RGB_BLA = 8,
           RGB_CNT = 9;

wire [23:0] RGB_TABLE[0:RGB_CNT-1];

assign RGB_TABLE[RGB_RED] = 24'hFF0000;
assign RGB_TABLE[RGB_ORA] = 24'hFFA500;
assign RGB_TABLE[RGB_YEL] = 24'hFFFF00;
assign RGB_TABLE[RGB_GRE] = 24'h00FF00;
assign RGB_TABLE[RGB_CYA] = 24'h00FFFF;
assign RGB_TABLE[RGB_BLU] = 24'h0000FF;
assign RGB_TABLE[RGB_PUR] = 24'hA020F0;
assign RGB_TABLE[RGB_WHI] = 24'hFFFFFF;
assign RGB_TABLE[RGB_BLA] = 24'h000000;
