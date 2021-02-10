//*****************************************************************************
// cam_reset.v
// 
// Qiwei.Wu
// April 30, 2018
//
// This module is the module of the camera reset.
// Revision 
// 0.01 - File Created
// 1.0  - Release at May 5, 2018
//*****************************************************************************

module cam_reset
(
   input         reset     ,
   input         clk       ,//clock 24MHz, 1 clock = 41.666667ns
   output reg    cam_rst_n ,//0-reset
   output reg    cam_pwnd  ,
   output reg    initial_en
);

//*****************************************************************************
// parameters
//*****************************************************************************
parameter   time_pwnd   = 18'h4000 ;
parameter   time_rst    = 16'hffff ;
parameter   time_ini_en = 20'hfffff;

//*****************************************************************************
// Signals
//*****************************************************************************
reg  [17:0]   cnt_pwnd;
reg  [15:0]   cnt_rst ;
reg  [19:0]   cnt_init;

//*****************************************************************************
// Processes
//*****************************************************************************
//5ms, delay from sensor power up stable to pull down
always @(posedge clk)
begin
   if(reset)
      cnt_pwnd <= 0;
   else if(cnt_pwnd == time_pwnd)
      cnt_pwnd <= cnt_pwnd;
   else
      cnt_pwnd <= cnt_pwnd + 1;
end

always @(posedge clk)
begin
   if(cnt_pwnd == time_pwnd)
      cam_pwnd <= 1'b1;
   else
      cam_pwnd <= 1'b0;
end

//1.3ms, delay from pwdn low to reset pull up
always @(posedge clk)
begin
   if(cam_pwnd == 1'b0)
      cnt_rst <= 0;
   else if(cnt_rst == time_rst)
      cnt_rst <= cnt_rst;
   else
      cnt_rst <= cnt_rst + 1;
end

always @(posedge clk)
begin
   if(cnt_rst == time_rst)
      cam_rst_n <= 1'b1;
   else
      cam_rst_n <= 1'b0;
end

//21ms, delay from reset pull high to SCCB initialization
always @(posedge clk)
begin
   if(cam_rst_n == 1'b0)
      cnt_init <= 0;
   else if(cnt_init == time_ini_en)
      cnt_init <= cnt_init;
   else
      cnt_init <= cnt_init + 1;
end

always @(posedge clk)
begin
   if(cnt_init == time_ini_en)
      initial_en <= 1'b1;
   else
      initial_en <= 1'b0;
end

endmodule