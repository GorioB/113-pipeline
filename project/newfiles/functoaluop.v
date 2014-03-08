`timescale 1ns / 1ps
module functoaluop(
	func,opcode,
	aluop
	);

	input [5:0] func;
	input [5:0] opcode;
	output [2:0] aluop;

	reg [2:0] aluop;
	always@(func or opcode)begin
		case (opcode)
			6'b000000:begin
				case(func)
					6'b100000:aluop<=3'd0;
					6'b100010:aluop<=3'd1;
					6'b100100:aluop<=3'd2;
					6'b100101:aluop<=3'd3;
					6'b100110:aluop<=3'd4;
					6'b100111:aluop<=3'd5;
					6'b101010:aluop<=3'd6;
					default:aluop<=3'd0;
				endcase
			end
			6'b001000:aluop<=3'd0;
			6'b001100:aluop<=3'd2;
			6'b001111:aluop<=3'd7;
			6'b001101:aluop<=3'd3;
			6'b001010:aluop<=3'd6;
			6'b000100:aluop<=3'd1;
			6'b010101:aluop<=3'd1;
			default:aluop<=3'd0;
		endcase
	end
endmodule
