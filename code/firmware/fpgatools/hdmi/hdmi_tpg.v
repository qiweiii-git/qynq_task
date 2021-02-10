//*****************************************************************************
// hdmi_tpg.v
//
// This module is the hdmi video test pattern generator.
//
// Change History:
//  VER.   Author         DATE              Change Description
//  1.0    Qiwei Wu       Apr. 12, 2020     Initial Release
//*****************************************************************************

module hdmi_tpg
(
   input                   clk,

   input       [2:0]       fmt_def,
   input       [11:0]      ppl,
   input       [11:0]      lpf,

   output      [23:0]      rbg
);

//*****************************************************************************
// Includes
//*****************************************************************************
`include "Define.vh"

//*****************************************************************************
// Signals
//*****************************************************************************
reg  [11:0] ppl_i;
reg  [11:0] lpf_i;
reg  [2:0]  ppl_seed;
reg  [2:0]  lpf_seed;
reg  [2:0]  seed;

//*****************************************************************************
// Processes
//*****************************************************************************
always @(posedge clk)
begin
   if(ppl <= FMT_TIMING[fmt_def][`HBLAK_END])
      ppl_i <= 0;
   else
      ppl_i <= ppl - FMT_TIMING[fmt_def][`HBLAK_END];
end

always @(posedge clk)
begin
   if(lpf <= FMT_TIMING[fmt_def][`VBLAK_END])
      lpf_i <= 0;
   else
      lpf_i <= lpf - FMT_TIMING[fmt_def][`VBLAK_END];
end

always @(posedge clk)
begin
   if(ppl_i >= (FMT_TIMING[fmt_def][`ACTPPL_CNT] >> 3) * 7)
      ppl_seed <= 7;
   else if(ppl_i >= (FMT_TIMING[fmt_def][`ACTPPL_CNT] >> 3) * 6)
      ppl_seed <= 6;
   else if(ppl_i >= (FMT_TIMING[fmt_def][`ACTPPL_CNT] >> 3) * 5)
      ppl_seed <= 5;
   else if(ppl_i >= (FMT_TIMING[fmt_def][`ACTPPL_CNT] >> 3) * 4)
      ppl_seed <= 4;
   else if(ppl_i >= (FMT_TIMING[fmt_def][`ACTPPL_CNT] >> 3) * 3)
      ppl_seed <= 3;
   else if(ppl_i >= (FMT_TIMING[fmt_def][`ACTPPL_CNT] >> 3) * 2)
      ppl_seed <= 2;
   else if(ppl_i >= (FMT_TIMING[fmt_def][`ACTPPL_CNT] >> 3) * 1)
      ppl_seed <= 1;
   else if(ppl_i >= (FMT_TIMING[fmt_def][`ACTPPL_CNT] >> 3) * 0)
      ppl_seed <= 0;
end

always @(posedge clk)
begin
   if(lpf_i >= (FMT_TIMING[fmt_def][`ACTLPF_CNT] >> 3) * 7)
      lpf_seed <= 7;
   else if(lpf_i >= (FMT_TIMING[fmt_def][`ACTLPF_CNT] >> 3) * 6)
      lpf_seed <= 6;
   else if(lpf_i >= (FMT_TIMING[fmt_def][`ACTLPF_CNT] >> 3) * 5)
      lpf_seed <= 5;
   else if(lpf_i >= (FMT_TIMING[fmt_def][`ACTLPF_CNT] >> 3) * 4)
      lpf_seed <= 4;
   else if(lpf_i >= (FMT_TIMING[fmt_def][`ACTLPF_CNT] >> 3) * 3)
      lpf_seed <= 3;
   else if(lpf_i >= (FMT_TIMING[fmt_def][`ACTLPF_CNT] >> 3) * 2)
      lpf_seed <= 2;
   else if(lpf_i >= (FMT_TIMING[fmt_def][`ACTLPF_CNT] >> 3) * 1)
      lpf_seed <= 1;
   else if(lpf_i >= (FMT_TIMING[fmt_def][`ACTLPF_CNT] >> 3) * 0)
      lpf_seed <= 0;
end

always @(*)
begin
   seed = ppl_seed + lpf_seed;
end

assign rbg = {RGB_TABLE[seed][`RGB_R], RGB_TABLE[seed][`RGB_B], RGB_TABLE[seed][`RGB_G]};

endmodule
