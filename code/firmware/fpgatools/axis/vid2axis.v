//*****************************************************************************
//    # #              Name   : vid2axis.sv
//  #     #            Date   : Jan. 10, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// This module used for converting the video data into axi-stream.
//*****************************************************************************

module vid2axis
#(
   parameter          BUF_AWID = 10
)
(
   input              reset,
   input              vid_clk,
   input              vid_act,
   input              vid_vsync,
   input     [15:0]   vid_data,
   input              vid_de,

   input              axis_clk,
   output    [15:0]   axis_tdata,
   output             axis_tvalid,
   input              axis_tready,
   output             axis_tuser,
   output             axis_tlast,
   output    [1:0]    axis_tkeep
);

//*****************************************************************************
// Signals
//*****************************************************************************
wire                  vid_vsync_p;
reg                   vid_sof_wait = 0;
reg  [15:0]           vid_data_r;
reg                   vid_de_r;
reg                   vid_act_r;
reg                   vid_eol_wait;
wire [BUF_AWID-1:0]   rdlevel;

//*****************************************************************************
// Sof detect
//*****************************************************************************
edge_detect u_edge_detect
(
   .CLK   ( vid_clk ),
   .DI    ( vid_vsync ),
   .DP    ( vid_vsync_p ),
   .DN    ( )
);

always @(posedge vid_clk)
begin
   if(vid_vsync_p)
      vid_sof_wait <= 1'b1;
   else if(vid_de_r)
      vid_sof_wait <= 1'b0;
end

//*****************************************************************************
// Eol detect
//*****************************************************************************
always @(posedge vid_clk)
begin
   vid_data_r <= vid_data;
   vid_de_r   <= vid_de;
   vid_act_r  <= vid_act;
end

always @(*)
begin
   if(vid_de_r && !vid_act)
      vid_eol_wait = 1'b1;
   else
      vid_eol_wait = 1'b0;
end

//*****************************************************************************
// Async FIFO
//*****************************************************************************
fifo
#(
   .DWID   ( 16 + 2 ),
   .AWID   ( BUF_AWID ),
   .SYNC   ( "false" )
)
u_fifo
(
   .RST    ( reset ),
   .WRCLK  ( vid_clk ),
   .WRENA  ( vid_de_r ),
   .WRDAT  ( {vid_sof_wait, vid_eol_wait, vid_data_r} ),
   .WRLEV  ( ),

   .RDCLK  ( axis_clk ),
   .RDENA  ( axis_tready && |rdlevel ),
   .RDDAT  ( {axis_tuser, axis_tlast, axis_tdata}),
   .RDLEV  ( rdlevel )
);

assign axis_tvalid = axis_tready && |rdlevel;
assign axis_tkeep  = 2'b11;

endmodule
