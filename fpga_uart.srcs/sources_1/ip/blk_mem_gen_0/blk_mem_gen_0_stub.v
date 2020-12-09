// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Fri Dec  4 12:09:53 2020
// Host        : clmDesktop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               a:/Documents/Engineering/fpga_uart/fpga_uart.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_stub.v
// Design      : blk_mem_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module blk_mem_gen_0(clka, ena, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[1:0],addra[3:0],dina[15:0],douta[15:0]" */;
  input clka;
  input ena;
  input [1:0]wea;
  input [3:0]addra;
  input [15:0]dina;
  output [15:0]douta;
endmodule
