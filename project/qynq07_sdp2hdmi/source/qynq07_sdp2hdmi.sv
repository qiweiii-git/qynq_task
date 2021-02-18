//*****************************************************************************
//    # #              Name   : qynq07_sdp2hdmi.sv
//  #     #            Date   : Dec. 27, 2020
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// This module is the top wrapper of qynq07_sdp2hdmi project.
//*****************************************************************************

module qynq07_sdp2hdmi
(
   // 50Mhz input
   input              CLK,
   // DDR interface
   inout     [14:0]   DDR_addr,
   inout     [2:0]    DDR_ba,
   inout              DDR_cas_n,
   inout              DDR_ck_n,
   inout              DDR_ck_p,
   inout              DDR_cke,
   inout              DDR_cs_n,
   inout     [3:0]    DDR_dm,
   inout     [31:0]   DDR_dq,
   inout     [3:0]    DDR_dqs_n,
   inout     [3:0]    DDR_dqs_p,
   inout              DDR_odt,
   inout              DDR_ras_n,
   inout              DDR_reset_n,
   inout              DDR_we_n,
   // FIXED_IO interface
   inout              FIXED_IO_ddr_vrn,
   inout              FIXED_IO_ddr_vrp,
   inout     [53:0]   FIXED_IO_mio,
   inout              FIXED_IO_ps_clk,
   inout              FIXED_IO_ps_porb,
   inout              FIXED_IO_ps_srstb,
   // ov5640
   input              CAM_VSYNC, //camera vsync
   input              CAM_HREF,  //camera hsync refrence
   input              CAM_PCLK,  //camera pxiel clock - 84MHz clock now
   input     [9:2]    CAM_DATA,  //camera data
   inout              CAM_SCL,   //camera i2c clock
   inout              CAM_SDA,   //camera i2c data
   output             CAM_RSTN,  //camera reset
   output             CAM_XCLK,
   output             CAM_PWDN,
   // HDMI
   input              HDMI_HPD,
   inout              HDMI_DDC_SCL,
   inout              HDMI_DDC_SDA,
   output             HDMI_OEN,
   output             TMDS_CLKN,
   output             TMDS_CLKP,
   output    [2:0]    TMDS_DATN,
   output    [2:0]    TMDS_DATP,
   // LED
   output    [3:0]    LED
);

//*****************************************************************************
// Includes
//*****************************************************************************
`include "Define.vh"

//*****************************************************************************
// Parameters
//*****************************************************************************

//*****************************************************************************
// Reg control
//*****************************************************************************
reg  [11:0] sys_rst_cnt;
reg         sys_rst;
wire [12:0] reg_ctrl_addr;
wire        reg_ctrl_clk;
wire [31:0] reg_ctrl_din;
wire [31:0] reg_ctrl_dout;
wire        reg_ctrl_en;
wire        reg_ctrl_rst;
wire [3:0]  reg_ctrl_we;

wire [31:0] reg_fw_ver;
wire [31:0] reg_led_ctrl;
wire [31:0] reg_fmt_def;
wire [31:0] reg_cam_config_en;
wire [31:0] reg_cam_config_da;
wire [31:0] cam_pclk_cnt;
wire [31:0] clk_74p25m_cnt;
wire [31:0] axisi_debug_cnt;
wire [31:0] axiso_debug_cnt;
wire [31:0] axis_bmp_sel;
wire [31:0] cam_status;
wire [31:0] NULL0, NULL1, NULL2, NULL3, NULL4, NULL5;

//*****************************************************************************
// Signals
//*****************************************************************************
wire        clk_24m;
wire        clk_100m;
wire        clk_74p25m;
wire        clk_74p25m_bufg;
wire        clk_74p25m_fb;
wire        clk_371p25m;
wire        clk_371p25m_bufg;
wire        vid_mmcm_locked;

//*****************************************************************************
// Ifs
//*****************************************************************************
if_axi_stream #(.DATA_WID(24)) axis_i();
if_axi_stream #(.DATA_WID(24)) axis_o();
if_native_stream vtg_i();
if_native_stream natv_o();

//*****************************************************************************
// Debugs
//*****************************************************************************
(* MARK_DEBUG="true" *)wire       debug_cam_href;
(* MARK_DEBUG="true" *)wire       debug_cam_vsync;
(* MARK_DEBUG="true" *)wire [7:0] debug_cam_data;

assign debug_cam_href  = CAM_HREF;
assign debug_cam_vsync = CAM_VSYNC;
assign debug_cam_data  = CAM_DATA;

(* MARK_DEBUG="true" *)wire [23:0] debug_axis_tdata;
(* MARK_DEBUG="true" *)wire        debug_axis_tlast;
(* MARK_DEBUG="true" *)wire        debug_axis_tuser;
(* MARK_DEBUG="true" *)wire        debug_axis_tvalid;
(* MARK_DEBUG="true" *)wire        debug_axis_tready;

assign debug_axis_tdata  = axis_i.tdata;
assign debug_axis_tlast  = axis_i.tlast;
assign debug_axis_tuser  = axis_i.tuser;
assign debug_axis_tvalid = axis_i.tvalid;
assign debug_axis_tready = axis_i.tready;

(* MARK_DEBUG="true" *)wire        debug_vid_active;
(* MARK_DEBUG="true" *)wire [23:0] debug_vid_data;
(* MARK_DEBUG="true" *)wire        debug_vid_hsync;
(* MARK_DEBUG="true" *)wire        debug_vid_vsync;

assign debug_vid_active = natv_o.active;
assign debug_vid_data   = natv_o.data;
assign debug_vid_hsync  = natv_o.hsync;
assign debug_vid_vsync  = natv_o.vsync;

//*****************************************************************************
// Process
//*****************************************************************************
assign LED = reg_led_ctrl[3:0];

//*****************************************************************************
// CLOCKS
//*****************************************************************************
MMCME2_BASE
#(
   .BANDWIDTH              ( "OPTIMIZED" ),
   .CLKFBOUT_MULT_F        ( 37.125 ),
   .CLKFBOUT_PHASE         ( 0.0 ),
   .CLKIN1_PERIOD          ( 10.000 ),
   // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
   .CLKOUT0_DIVIDE_F       ( 10.000 ),
   .CLKOUT1_DIVIDE         ( 2 ),
   // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
   .CLKOUT0_DUTY_CYCLE     ( 0.5 ),
   .CLKOUT1_DUTY_CYCLE     ( 0.5 ),
   // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
   .CLKOUT0_PHASE          ( 0.0 ),
   .CLKOUT1_PHASE          ( 0.0 ),
   .CLKOUT4_CASCADE        ( "FALSE" ),
   .DIVCLK_DIVIDE          ( 5 ),
   .REF_JITTER1            ( 0.0 ),
   .STARTUP_WAIT           ( "FALSE" )
)
u_clk_74p25m
(
   // Clock Outputs: 1-bit (each) output: User configurable clock outputs
   .CLKOUT0                ( clk_74p25m ),
   .CLKOUT0B               ( ),
   .CLKOUT1                ( clk_371p25m ),
   .CLKOUT1B               ( ),
   // Feedback Clocks: 1-bit (each) output: Clock feedback ports
   .CLKFBOUT               ( clk_74p25m_fb ),
   .CLKFBOUTB              ( ),
   // Status Ports: 1-bit (each) output: MMCM status ports
   .LOCKED                 ( vid_mmcm_locked ),
   // Clock Inputs: 1-bit (each) input: Clock input
   .CLKIN1                 ( clk_100m ),
   // Control Ports: 1-bit (each) input: MMCM control ports
   .PWRDWN                 ( 1'b0 ),
   .RST                    ( 1'b0 ),
   // Feedback Clocks: 1-bit (each) input: Clock feedback ports
   .CLKFBIN                ( clk_74p25m_fb )
);

BUFG u2_bufg
(
   .O                      ( clk_74p25m_bufg ),
   .I                      ( clk_74p25m )
);

BUFG u3_bufg
(
   .O                      ( clk_371p25m_bufg ),
   .I                      ( clk_371p25m )
);

//*****************************************************************************
// Maps
//*****************************************************************************
system u_system
(
   // DDR interface
   .DDR_addr               ( DDR_addr ),
   .DDR_ba                 ( DDR_ba ),
   .DDR_cas_n              ( DDR_cas_n ),
   .DDR_ck_n               ( DDR_ck_n ),
   .DDR_ck_p               ( DDR_ck_p ),
   .DDR_cke                ( DDR_cke ),
   .DDR_cs_n               ( DDR_cs_n ),
   .DDR_dm                 ( DDR_dm ),
   .DDR_dq                 ( DDR_dq ),
   .DDR_dqs_n              ( DDR_dqs_n ),
   .DDR_dqs_p              ( DDR_dqs_p ),
   .DDR_odt                ( DDR_odt ),
   .DDR_ras_n              ( DDR_ras_n ),
   .DDR_reset_n            ( DDR_reset_n ),
   .DDR_we_n               ( DDR_we_n ),
   // FIXED_IO interface
   .FIXED_IO_ddr_vrn       ( FIXED_IO_ddr_vrn ),
   .FIXED_IO_ddr_vrp       ( FIXED_IO_ddr_vrp ),
   .FIXED_IO_mio           ( FIXED_IO_mio ),
   .FIXED_IO_ps_clk        ( FIXED_IO_ps_clk ),
   .FIXED_IO_ps_porb       ( FIXED_IO_ps_porb ),
   .FIXED_IO_ps_srstb      ( FIXED_IO_ps_srstb ),
   // Clock
   .CLK_100M               ( clk_100m ),
   .CLK_24M                ( clk_24m ),
   // Reg control
   .REG_CTRL_addr          ( reg_ctrl_addr ),
   .REG_CTRL_clk           ( reg_ctrl_clk ),
   .REG_CTRL_din           ( reg_ctrl_din ),
   .REG_CTRL_dout          ( reg_ctrl_dout ),
   .REG_CTRL_en            ( reg_ctrl_en ),
   .REG_CTRL_rst           ( reg_ctrl_rst ),
   .REG_CTRL_we            ( reg_ctrl_we ),
   // VDMA
   .AXIS_ACLK              ( clk_100m ),
   .AXIS_RSTN              ( ~sys_rst ),
   .AXIS_MM2S_tdata        ( axis_o.tdata ),
   .AXIS_MM2S_tkeep        ( axis_o.tkeep ),
   .AXIS_MM2S_tlast        ( axis_o.tlast ),
   .AXIS_MM2S_tready       ( axis_o.tready ),
   .AXIS_MM2S_tuser        ( axis_o.tuser ),
   .AXIS_MM2S_tvalid       ( axis_o.tvalid )
);

//*****************************************************************************
// System reset
//*****************************************************************************
always @(posedge reg_ctrl_clk)
begin
   sys_rst_cnt <= sys_rst_cnt + ~&sys_rst_cnt;
end

always @(posedge reg_ctrl_clk)
begin
   if(&sys_rst_cnt)
      sys_rst <= 1'b0;
   else
      sys_rst <= 1'b1;
end

//*****************************************************************************
// Reg control
//*****************************************************************************
qwiregctrl
#(
   .REGCNT                 ( REG_CNT ),
   .AWID                   ( 9 ),
   .DWID                   ( 32 )
)
u_qwiregctrl
(  
   .sys_rst                ( sys_rst ),
   .reg_ce                 ( reg_ctrl_en ),
   .reg_rst                ( reg_ctrl_rst ),
   .reg_clk                ( reg_ctrl_clk ),
   .reg_we                 ( reg_ctrl_we ),
   .reg_addr               ( reg_ctrl_addr[12:4] ),
   .reg_wrd                ( reg_ctrl_din ),
   .reg_rdd                ( reg_ctrl_dout ),

   .reg_out                ( {
                              { axis_bmp_sel },
                              { NULL4 },
                              { NULL3 },
                              { NULL2 },
                              { NULL1 },
                              { NULL0 },
                              { reg_cam_config_da },
                              { reg_cam_config_en },
                              { reg_fmt_def },
                              { reg_led_ctrl },
                              { reg_fw_ver }} ),
   .reg_in                 ( {
                              { axis_bmp_sel },
                              { axiso_debug_cnt },
                              { {31'h0, axis_o.tready} },
                              { clk_74p25m_cnt },
                              { cam_pclk_cnt },
                              { cam_status },
                              { reg_cam_config_da },
                              { reg_cam_config_en },
                              { reg_fmt_def },
                              { reg_led_ctrl },
                              { reg_fw_ver }} )
);

//*****************************************************************************
// VTG
//*****************************************************************************
hdmi_vtg u_hdmi_vtg
(
   .clk                    ( clk_74p25m_bufg ),
   .gen_ce                 ( vtg_i.vtg_ce ),
   .fmt_def                ( reg_fmt_def[2:0] ),

   .ppl                    ( vtg_i.ppl ),
   .lpf                    ( vtg_i.lpf ),
   .hsync                  ( vtg_i.hsync ),
   .vsync                  ( vtg_i.vsync ),
   .hblank                 ( vtg_i.hblank ),
   .vblank                 ( vtg_i.vblank ),
   .active                 ( vtg_i.active )
);

//*****************************************************************************
// AXIS2NATV
//*****************************************************************************
axis2native
#(
   .VTG_MASTER             ( "true" )
)
u_axis2native
(
   .rst                    ( !vid_mmcm_locked ),
   .axis_clk               ( clk_100m ),
   .natv_clk               ( clk_74p25m_bufg ),

   .axis_i                 ( axis_o ),
   .vtg_i                  ( vtg_i ),
   .natv_o                 ( natv_o )
);

//*****************************************************************************
// HDMI OUT
//*****************************************************************************
assign HDMI_OEN = 1'b1;
rgb2dvi u_rbg2dvi
(
   .PixelClk               ( clk_74p25m_bufg ),
   .SerialClk              ( clk_371p25m_bufg ),
   .aRst                   ( ),
   .aRst_n                 ( vid_mmcm_locked ),
   .vid_pData              ( natv_o.data ),
   .vid_pVDE               ( natv_o.active ),
   .vid_pHSync             ( natv_o.hsync ),
   .vid_pVSync             ( natv_o.vsync ),
   .TMDS_Clk_p             ( TMDS_CLKP ),
   .TMDS_Clk_n             ( TMDS_CLKN ),
   .TMDS_Data_p            ( TMDS_DATP ),
   .TMDS_Data_n            ( TMDS_DATN )
);

//*****************************************************************************
// Monitors
//*****************************************************************************
clock_meter
#(
   .REFCLK_FREQ            ( 100_000_000 )
)
u0_clock_meter
(
   .CLK_REF                ( clk_100m ),
   .CLK_TST                ( CAM_PCLK ),
   .CLK_CNT                ( cam_pclk_cnt )
);

clock_meter
#(
   .REFCLK_FREQ            ( 100_000_000 )
)
u1_clock_meter
(
   .CLK_REF                ( clk_100m ),
   .CLK_TST                ( clk_74p25m_bufg ),
   .CLK_CNT                ( clk_74p25m_cnt )
);

axis_monitor
#(
   .REFCLK_FREQ            ( 100_000_000 )
)
u0_axis_monitor
(
   .ACLK                   ( clk_100m ),
   .AXIS_TUSER             ( axis_i.tuser ),
   .AXIS_TLAST             ( axis_i.tlast ),
   .AXIS_TVALID            ( axis_i.tvalid && axis_i.tready ),

   .AXIS_TUSER_CNT         ( axisi_debug_cnt[31:24] ),
   .AXIS_TLAST_CNT         ( axisi_debug_cnt[23:12] ),
   .AXIS_TVALID_CNT        ( axisi_debug_cnt[11:0] )
);

axis_monitor
#(
   .REFCLK_FREQ            ( 100_000_000 )
)
u1_axis_monitor
(
   .ACLK                   ( clk_100m ),
   .AXIS_TUSER             ( axis_o.tuser ),
   .AXIS_TLAST             ( axis_o.tlast ),
   .AXIS_TVALID            ( axis_o.tvalid && axis_o.tready ),

   .AXIS_TUSER_CNT         ( axiso_debug_cnt[31:24] ),
   .AXIS_TLAST_CNT         ( axiso_debug_cnt[23:12] ),
   .AXIS_TVALID_CNT        ( axiso_debug_cnt[11:0] )
);

endmodule
