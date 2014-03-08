`timescale 1ns / 1ps
module adder(
	a,b,
	o
	);

	input [31:0] a;
	input [31:0] b;
	output [31:0] o;

	assign o=a+b;
endmodule
