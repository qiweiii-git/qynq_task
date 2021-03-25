
module t_fifo();

wire [9:0] wrlevel;
wire [9:0] rdlevel;
reg  [9:0] wradr = 0;
reg  [9:0] rdadr = 0;
wire       re;
reg        rden;
reg        rdclk = 1;
reg        start = 0;
reg        rst = 1;
reg        wrclk = 1;
reg        wr;
wire [31:0]wd;
wire [31:0]rd;
wire [31:0]rddat;
reg  [31:0]wrcnt = 0;
reg  [31:0]rdcnt = 0;
reg        err_data = 0;

always  #3 wrclk = ~wrclk;
always  #2 rdclk = ~rdclk;

always @(posedge wrclk)
begin
   if(~&wrlevel && start)
      wr <= {$random} % 2;
   else
      wr <= 1'b0;

   if(wr)
      wrcnt <= wrcnt + 1;
end

assign wd = wrcnt;

always @(posedge rdclk)
begin
   rden <= {$random} % 2;

   if(re)
      rdcnt <= rdcnt + 1;
end

assign re = rden && |rdlevel;

initial
begin
   $display("%t: Info: %m task is starting......", $time);
   $dumpfile("top.vcd");
   $dumpvars(0, t_fifo);
   start = 0;
   rst   = 1;

   #100
      rst = ~rst;

   #100
      start = 1;

   #100000
   $display("%t: Info: %m task is ending......", $time);
   $finish;
end

always @(posedge rdclk)
begin
   if(re && rd != rdcnt)
   begin
      err_data <= 1;
      $display("%t: Error: The output data from uut is not expected %d != %d ", $time, rd, rdcnt);
   end

   if(re && rddat != rdcnt)
   begin
      err_data <= 1;
      $display("%t: Error: The output data from uut_ram is not expected %d != %d ", $time, rddat, rdcnt);
   end
end

fifo
#(
   .DWID   ( 32 ),
   .AWID   ( 10 ),
   .SYNC   ( "false" )
)
uut
(
   .RST    ( rst ),
   .WRCLK  ( wrclk ),
   .WRENA  ( wr ),
   .WRDAT  ( wd ),
   .WRLEV  ( wrlevel ),

   .RDCLK  ( rdclk),
   .RDENA  ( re ),
   .RDDAT  ( rd ),
   .RDLEV  ( rdlevel )
);

// RAM task
always @(posedge wrclk)
begin
   if(wr)
      wradr <= wradr + 1;
end

always @(posedge rdclk)
begin
   if(re)
      rdadr <= rdadr + 1;
end

ram
#(
   .DWID   ( 32 ),
   .AWID   ( 10 )
)
uut_ram
(
   .RST    ( rst ),
   .WRCLK  ( wrclk ),
   .WRENA  ( wr ),
   .WRADR  ( wradr ),
   .WRDAT  ( wd ),
   .RDCLK  ( rdclk ),
   .RDENA  ( re ),
   .RDADR  ( rdadr ),
   .RDDAT  ( rddat )
);

endmodule
