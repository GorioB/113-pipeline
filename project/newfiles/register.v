`timescale 1ns / 1ps
module register(
	clk,nrst,
	in,latch,
	out);

	input clk;
	input nrst;
	input [31:0] in;
	input latch;
	output [31:0] out;

	reg [31:0] out;

	always@(posedge clk or negedge nrst)begin
		if(!nrst)out<= 32'd0;
		else if (!latch)out<=out;
		else out<=in;
	end
endmodule
