//******************************************************************************
//    # #              Name   : autobus.v
//  #     #            Date   : Mar. 24, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
//
// This module is the auto bus testpattern.
//
// Change History:
//  VER.   Author         DATE              Change Description
//  1.0    Qiwei Wu       Mar. 24, 2021     Initial Release
//******************************************************************************

module autobus
#(
   parameter               DWID = 16
)
(
   input                   clk,
   input      [15:0]       sop_len,
   input      [15:0]       sof_len,
   input      [15:0]       pkt_interval,

   input                   rdy,
   output reg              sop,
   output reg              eop,
   output reg              sof,
   output reg              eof,
   output reg [DWID-1:0]   dat,
   output reg              dav
);

//*****************************************************************************
// Signals
//*****************************************************************************
reg  [15:0]                delay_cnt = 0;
reg  [15:0]                sop_cnt = 0;
reg  [15:0]                sof_cnt = 0;

//*****************************************************************************
// Pattern generate
//*****************************************************************************
always @(posedge clk)
begin
   if(rdy && sop_cnt >= sop_len - 1)
      delay_cnt <= 0;
   else
      delay_cnt <= delay_cnt + ~&delay_cnt;
end

always @(posedge clk)
begin
   if(rdy)
   begin
      if(sop_cnt >= sop_len - 1)
         sop_cnt <= 0;
      else if(delay_cnt >= pkt_interval - 1)
         sop_cnt <= sop_cnt + ~&sop_cnt;

      if(sof_cnt >= sof_len - 1 && sop_cnt >= sop_len - 1)
         sof_cnt <= 0;
      else
         sof_cnt <= sof_cnt + ~&sof_cnt;
   end
end

always @(*)
begin
   if(rdy)
   begin
      sop = sop_cnt == 0 && delay_cnt >= pkt_interval - 1;
      eop = sop_cnt >= sop_len - 1;
      sof = sof_cnt == 0 && sop;
      eof = sof_cnt >= sof_len - 1 && eop;
      dav = delay_cnt >= pkt_interval - 1;
      dat = sop_cnt[DWID-1:0];
   end
   else
   begin
      sop = 0;
      eop = 0;
      sof = 0;
      eof = 0;
      dav = 0;
   end
end

endmodule
