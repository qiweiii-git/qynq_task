//*****************************************************************************
//    # #              Name   : cam_wrapper.sv
//  #     #            Date   : Jan. 10, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// This module is the wrapper of OV5640 camera process.
//*****************************************************************************

module cam_wrapper
(
   input              CLK_24M,
   // OV5640 camera
   input              CAM_VSYNC,  //camera vsync
   input              CAM_HREF,   //camera hsync refrence
   input              CAM_PCLK,   //camera pixel clock
   input     [9:2]    CAM_DATA,   //camera data
   inout              CAM_SCL,    //camera i2c clock
   inout              CAM_SDA,    //camera i2c data
   output             CAM_RSTN,   //camera reset
   output             CAM_XCLK,
   output             CAM_PWDN,
   // OV5640 configure
   input              CAM_RESET,
   input              CONFIG_EN,
   input     [31:0]   CONFIG_DA,
   // AXIS
   input              ACLK,       //AXI4-Stream clock
   output    [15:0]   AXIS_TDATA, //AXI4-Stream data
   output             AXIS_TVALID,//AXI4-Stream valid 
   input              AXIS_TREADY,//AXI4-Stream ready 
   output             AXIS_TUSER, //AXI4-Stream tuser (SOF)
   output             AXIS_TLAST, //AXI4-Stream tlast (EOL)
   output    [1:0]    AXIS_TKEEP, //AXI4-Stream tkeep
   // Debugs
   output    [31:0]   STATUS,
   output    [31:0]   DEBUG
);

//*****************************************************************************
// Signals
//*****************************************************************************
wire [15:0]           cam_16bit_da;
wire                  cam_16bit_en;
wire                  vid_act;
wire                  vid_vsync;

//*****************************************************************************
// Processes
//*****************************************************************************
assign CAM_PWDN = 1'b0;
assign CAM_XCLK = CLK_24M;

assign vid_act  = CAM_HREF;
assign vid_vsync= CAM_VSYNC;

//*****************************************************************************
// Camera reset
//*****************************************************************************
cam_reset u_cam_reset
(
   .reset             ( CAM_RESET ),
   .clk               ( CLK_24M ),//I2C clock 24MHz, 1 clock = 41.666667ns
   .cam_rst_n         ( CAM_RSTN ),
   .cam_pwnd          ( ),
   .initial_en        ( STATUS[0] )
);

//*****************************************************************************
// Camera configure
//*****************************************************************************
`ifndef AUTO_CONFIG
i2c_config u_cam_config
(
   .reset             ( ~CAM_RSTN ),
   .clk_24m           ( CLK_24M ),

   .configure_en      ( CONFIG_EN ),
   .configure_data    ( CONFIG_DA ),
   .configure_rdy     ( STATUS[1] ),

   .i2c_sclk          ( CAM_SCL ),
   .i2c_sdat          ( CAM_SDA )
);
`else
reg_config u_reg_config
(
   .clk_24m           ( CLK_24M ),
   .cam_rstn          ( CAM_RSTN ),
   .initial_en        ( STATUS[0] ),
   .reg_conf_done     ( STATUS[1] ),
   .i2c_sclk          ( CAM_SCL ),
   .i2c_sdat          ( CAM_SDA )
);
`endif

//*****************************************************************************
// Camera 8bits -> 16bits
//*****************************************************************************
cam_8b16b u_cam_8b16b
(
   .rst               ( ~CAM_RSTN || vid_vsync ),
   .pixel_clk         ( CAM_PCLK ),
   .data_i            ( CAM_DATA ),
   .data_de_i         ( CAM_HREF ),

   .data_o            ( cam_16bit_da ),
   .data_de_o         ( cam_16bit_en )
);

//*****************************************************************************
// Camera video data to axis
//*****************************************************************************
vid2axis
#(
   .BUF_AWID          ( 12 )
)
u_vid2axis
(
   .reset             ( ~CAM_RSTN ),
   .vid_clk           ( CAM_PCLK ),
   .vid_act           ( vid_act ),
   .vid_vsync         ( vid_vsync ),
   .vid_data          ( cam_16bit_da ),
   .vid_de            ( cam_16bit_en ),

   .axis_clk          ( ACLK ),
   .axis_tdata        ( AXIS_TDATA ),
   .axis_tvalid       ( AXIS_TVALID ),
   .axis_tready       ( AXIS_TREADY ),
   .axis_tuser        ( AXIS_TUSER ),
   .axis_tlast        ( AXIS_TLAST ),
   .axis_tkeep        ( AXIS_TKEEP )
);

endmodule
