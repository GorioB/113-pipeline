`timescale 1ns / 1ps
module mux(
	in0,in1,in2,in3,
	select,
	muxout
	);

	input [31:0] in1;
	input [31:0] in2;
	input [31:0] in3;
	input [31:0] in0;
	input [1:0] select;
	output [31:0] muxout;

	assign muxout = (select == 2'd0 )? in0 : (select == 2'd1)? in1 : (select == 2'd2)? in2 : in3;

endmodule
