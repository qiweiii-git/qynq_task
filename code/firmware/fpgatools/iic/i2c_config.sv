//*****************************************************************************
//    # #              Name   : i2c_config.sv
//  #     #            Date   : Jan. 08, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// This module is the IIC configure module.
//*****************************************************************************

module i2c_config
(
   input             reset,
   input             clk_24m,

   input             configure_en,
   input      [31:0] configure_data,
   output reg        configure_rdy,

   output            i2c_sclk,
   inout             i2c_sdat
);

//*****************************************************************************
// Signals
//*****************************************************************************
reg  [11:0]       clk_20k_cnt;
reg               clk_20k;
wire              configure_en_p;
reg  [31:0]       i2c_data;
reg               start;

//*****************************************************************************
// 20kHz clock generate
//*****************************************************************************
always @(posedge clk_24m)
begin
   if(reset)
      clk_20k_cnt <= 0;
   else if(clk_20k_cnt < 1199)
      clk_20k_cnt <= clk_20k_cnt + 1;
   else
      clk_20k_cnt <= 0;
end

always @(posedge clk_24m)
begin
   if(reset)
      clk_20k <= 0;
   else if(clk_20k_cnt >= 1199)
      clk_20k <= ~clk_20k;
end

//*****************************************************************************
// iic start
//*****************************************************************************
edge_detect u_edge_detect
(
   .CLK   ( clk_20k ),
   .DI    ( configure_en ),
   .DP    ( configure_en_p ),
   .DN    ( )
);

always @(posedge clk_20k)
begin
   if(reset)
      start <= 1'b0;
   else if(configure_en_p)
      start <= 1'b1;
   else if(tr_end)
      start <= 1'b0;
end

always @(posedge clk_20k)
begin
   if(configure_en_p)
      i2c_data <= configure_data;
end

always @(posedge clk_20k)
begin
   configure_rdy <= ~start;
end

//*****************************************************************************
// iic write command
//*****************************************************************************
i2c_com i2c_com
(
   .clk           ( clk_20k ),
   .rstn          ( ~reset ),
   .ack           ( ),
   .i2c_data      ( i2c_data ),
   .start         ( start ),
   .tr_end        ( tr_end ),
   .i2c_sclk      ( i2c_sclk ),
   .i2c_sdat      ( i2c_sdat )
);

endmodule
