//*****************************************************************************
// i2c_com.v
// 
// Qiwei.Wu
// May 5, 2018
//
// This module is the control process of the iic write command.
// Revision 
// 0.01 - File Created
//*****************************************************************************

module i2c_com
(
   input                 clk,        //0-400khz，此处为20khz
   input                 rstn,
   input       [31:0]    i2c_data,
   input                 start,      //开始传输标志
   output                ack,        //应答信号
   output reg            tr_end,     //传输结束标志
   output                i2c_sclk,   //FPGA与camera iic时钟接口
   inout                 i2c_sdat    //FPGA与camera iic数据接口
); 

//*****************************************************************************
// Signals
//*****************************************************************************
reg [5:0]   cyc_count     ;
reg         reg_sdat      ;
reg         sclk          ;
reg         ack1          ;
reg         ack2          ;
reg         ack3          ;

//*****************************************************************************
// Processes
//*****************************************************************************
assign ack      = ack1 | ack2 | ack3;
assign i2c_sclk = sclk | (((cyc_count>=4)&(cyc_count<=39))? ~clk : 0);
assign i2c_sdat = reg_sdat? 1'bz : 0; 

always@(posedge clk or  negedge rstn)
begin
   if(!rstn)
     cyc_count<=6'b111111;
   else 
   begin
      if(start==0)
         cyc_count<=0;
      else if(cyc_count<6'b111111)
         cyc_count<=cyc_count+1;
   end
end

always@(posedge clk or negedge rstn)
begin
   if(!rstn)
   begin
      tr_end   <= 0;
      ack1     <= 1;
      ack2     <= 1;
      ack3     <= 1;
      sclk     <= 1;
      reg_sdat <= 1;
   end
   else
      case(cyc_count)
         0  : 
         begin 
              ack1     <= 1           ;
              ack2     <= 1           ;
              ack3     <= 1           ;
              tr_end   <= 0           ;
              sclk     <= 1           ;
              reg_sdat <= 1           ;
         end
         1  : reg_sdat <= 0           ;//transfer start
         2  : sclk     <= 0           ;
         3  : reg_sdat <= i2c_data[31];
         4  : reg_sdat <= i2c_data[30];
         5  : reg_sdat <= i2c_data[29];
         6  : reg_sdat <= i2c_data[28];
         7  : reg_sdat <= i2c_data[27];
         8  : reg_sdat <= i2c_data[26];
         9  : reg_sdat <= i2c_data[25];
         10 : reg_sdat <= i2c_data[24];
         11 : reg_sdat <= 1           ;                
         12 : 
         begin 
              reg_sdat <= i2c_data[23];
              ack1     <= i2c_sdat    ;
         end
         13 : reg_sdat <= i2c_data[22];
         14 : reg_sdat <= i2c_data[21];
         15 : reg_sdat <= i2c_data[20];
         16 : reg_sdat <= i2c_data[19];
         17 : reg_sdat <= i2c_data[18];
         18 : reg_sdat <= i2c_data[17];
         19 : reg_sdat <= i2c_data[16];
         20 : reg_sdat <= 1           ;        
         21 : 
         begin 
              reg_sdat <= i2c_data[15];
              ack1     <= i2c_sdat    ;
         end
         22 : reg_sdat <= i2c_data[14];
         23 : reg_sdat <= i2c_data[13];
         24 : reg_sdat <= i2c_data[12];
         25 : reg_sdat <= i2c_data[11];
         26 : reg_sdat <= i2c_data[10];
         27 : reg_sdat <= i2c_data[9];
         28 : reg_sdat <= i2c_data[8];
         29 : reg_sdat <= 1          ;                     
         30 : 
         begin 
              reg_sdat <= i2c_data[7];
              ack2     <= i2c_sdat   ;
         end
         31 : reg_sdat <= i2c_data[6];
         32 : reg_sdat <= i2c_data[5];
         33 : reg_sdat <= i2c_data[4];
         34 : reg_sdat <= i2c_data[3];
         35 : reg_sdat <= i2c_data[2];
         36 : reg_sdat <= i2c_data[1];
         37 : reg_sdat <= i2c_data[0];
         38 : reg_sdat <= 1          ;                     
         39 : 
         begin 
              ack3     <= i2c_sdat   ;
              sclk     <= 0          ;
              reg_sdat <= 0          ;
         end
         40 : sclk     <= 1          ;
         41 : 
         begin 
              reg_sdat <= 1          ;
              tr_end   <= 1          ;
         end
         default :
         begin 
              reg_sdat <= 1          ;
              tr_end   <= 1          ;
         end
      endcase
end

endmodule