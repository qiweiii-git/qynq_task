//*****************************************************************************
// cam_8b16b.v
// 
// Qiwei.Wu
// April 30, 2018
//
// This module is the module of the camera data interface.
//    Convert the data width from 8 bit to 16 bit.
// Revision 
// 0.01 - File Created
// 0.2  - Fixed de_o&data_o gen 
// 0.3  - Fixed some issues after simulation
// 1.0  - Release at May 5, 2018
//*****************************************************************************

module cam_8b16b
(
   input             rst      ,
	input             pixel_clk,
	input      [7:0]  data_i   ,
	input             data_de_i,

	output reg [15:0] data_o   ,
	output reg        data_de_o
);

//*****************************************************************************
// Signals
//*****************************************************************************
reg   [7:0]   data_i_ff0;
reg           data_en   ;

//*****************************************************************************
// Processes
//*****************************************************************************
always @(posedge pixel_clk)
begin
   data_i_ff0 <= data_i;
end

always @(posedge pixel_clk, posedge rst)
begin
   if(rst)
      data_en <= 1'b0;
   else if(data_de_i)
      data_en <= ~data_en;
end

//data_de_o
always @(posedge pixel_clk, posedge rst)
begin
   if(rst)
      data_de_o <= 1'b0;
   else if(data_de_i && data_en)
      data_de_o <= 1'b1;
   else
      data_de_o <= 1'b0;
end

//data_o
always @(posedge pixel_clk, posedge rst)
begin
   if(rst)
      data_o <= 16'h0;
   else if(data_de_i && data_en)
      data_o <= {data_i_ff0, data_i};
   else
      data_o <= 16'h0;
end

endmodule 