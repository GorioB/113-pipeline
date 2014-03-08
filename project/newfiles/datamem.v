`timescale 1ns / 1ps

module datamem(
  clk,
  data_addr,
  memwr,
  din,
  dout
  );

  parameter memsize = 1024;
  
  input clk;
  input memwr;
  input [31:0] data_addr;
  input [31:0] dout; //out from proc
  output [31:0] din; //in to proc

  reg [7:0] data[0:memsize-1];

  initial
    $readmemh("datamem.txt",data);

  reg [31:0] din;
  always@(data_addr)
    din <= {data[data_addr],data[data_addr+1],data[data_addr+2],data[data_addr+3]};

  always@(posedge clk)
    if (memwr)
    begin
      data[data_addr]   <= dout[31:24];
      data[data_addr+1] <= dout[23:16];
      data[data_addr+2] <= dout[15:8];
      data[data_addr+3] <= dout[7:0];
    end

endmodule
