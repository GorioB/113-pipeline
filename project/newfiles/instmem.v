`timescale 1ns / 1ps

module instmem(
  clk,
  inst_addr,
  inst
  );

  parameter no_inst = 1024;
  
  input clk;
  input [31:0] inst_addr;
  output [31:0] inst;


  reg [31:0] data[0:no_inst-1];

  initial
    $readmemh("instmem.txt",data);

  wire [31:0] word_addr;
  assign word_addr = {2'd0,inst_addr[31:2]};

  reg [31:0] inst;
  always@(word_addr)
    inst <= data[word_addr];

  always@(posedge clk)
    if (inst_addr[1:0]!=2'b00)
      $display("Instruction address not word aligned");

endmodule
