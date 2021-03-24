
module t_autobus();

reg         clk = 1;
reg  [15:0] sop_len;
reg  [15:0] sof_len;
reg  [15:0] pkt_interval;
reg         rdy;
wire        sop;
wire        eop;
wire        sof;
wire        eof;
wire [15:0] dat;
wire        dav;
reg  [15:0] expect_data = 0;
reg         err_data = 0;

always #2 clk = ~clk;

initial
begin
   $display("Info: %m task is starting......");
      sop_len = 256;
      sof_len = 256;
      pkt_interval = 256;
   #200
      rdy = 1;
   #10000
      rdy = 0;
   $display("Info: %m task is ending......");
   $finish;
end

always @(posedge clk)
begin
   if(eop && dav)
      expect_data <= 0;
   else if(dav)
      expect_data <= expect_data + ~&expect_data;
end

autobus
#(
   .DWID         ( 16 )
)
uut
(
   .clk          ( clk ),
   .sop_len      ( sop_len ),
   .sof_len      ( sof_len ),
   .pkt_interval ( pkt_interval ),

   .rdy          ( rdy ),
   .sop          ( sop ),
   .eop          ( eop ),
   .sof          ( sof ),
   .eof          ( eof ),
   .dat          ( dat ),
   .dav          ( dav )
);

always @(posedge clk)
begin
   if(sop && dav && dat != 0)
   begin
      err_data <= 1;
      $display("Error: The output data from uut is not expected %d != %d ", dat, expect_data);
   end
   else if(dav && dat != expect_data)
   begin
      err_data <= 1;
      $display("Error: The output data from uut is not expected %d != %d ", dat, expect_data);
   end
   else if(eop && dav && err_data == 0)
   begin
      $display("Info: The output data from uut is all expected");
   end
end

endmodule
