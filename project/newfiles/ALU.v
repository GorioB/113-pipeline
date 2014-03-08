`timescale 1ns / 1ps
module ALU(
	a,b,
	aluop,
	o,z);

	input [31:0] a,b;
	input [2:0]aluop;
	output [31:0] o;
	output z;

	reg [31:0] o;
	wire [31:0] diff;
	assign diff = a-b;
	assign z = ~|o;

	always@(*)begin
		case(aluop)
			3'd0:o<=a+b;
			3'd1:o<=a-b;
			3'd2:o<=a&b;
			3'd3:o<=a|b;
			3'd4:o<=a^b;
			3'd5:o<=~(a|b);
			3'd6:begin
				o<={31'd0,diff[31]};
			end
			3'd7:o<={b,16'h0};
			default:o<=0;
		endcase
	end
endmodule
