
`timescale 1ns/1ns
module t_fifo();

wire [9:0] rdlevel;
wire       rden;
reg        rdclk = 1;
reg        rst = 1;
reg        wrclk = 1;
reg        wr;
wire [31:0]wd;
reg  [31:0]cnt = 0;

initial #1000 rst = ~rst;
always  #3 wrclk = ~wrclk;
always  #2 rdclk = ~rdclk;

always @(posedge wrclk)
begin
   wr <= |cnt[2:0];
   if(!rst)
      cnt <= cnt + 1;
end

assign wd = cnt;

assign rden = 1'b1;

fifo
#(
   .DWID   ( 32 ),
   .AWID   ( 10 ),
   .SYNC   ( "false" )
)
u_fifo
(
   .RST    ( rst ),
   .WRCLK  ( wrclk ),
   .WRENA  ( wr ),
   .WRDAT  ( wd ),
   .WRLEV  ( ),

   .RDCLK  ( rdclk),
   .RDENA  ( rden && |rdlevel ),
   .RDDAT  ( ),
   .RDLEV  ( rdlevel )
);

endmodule
