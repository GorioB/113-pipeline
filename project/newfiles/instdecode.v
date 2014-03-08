`timescale 1ns / 1ps
module InstDecode(
	inst,

	CommandString
	);

	input [31:0] inst;
	output [9:0]CommandString;
	reg[1:0] PCSource;
	reg WriteEnable;
	reg ALUSrcB;
	reg WriteAddr;
	reg MemWrite;
	reg WriteData;
	wire [2:0] ALUControl;

	assign CommandString={PCSource,WriteEnable,
		ALUSrcB,WriteAddr,
		MemWrite,WriteData,
		ALUControl};

	functoaluop falop(
		.func(inst[5:0]),
		.opcode(inst[31:26]),
		.aluop(ALUControl)
		);
	always@(*)begin
		case(inst[31:26])
			6'd0:begin//r-type
				PCSource<=2'd0;
				WriteEnable<=1'b1;
				if(inst[5:0]==5'd0)WriteEnable<=1'b0;
				ALUSrcB<=1'b0;
				WriteAddr<=1'b1;
				MemWrite<=1'b0;
				WriteData<=1'b0;
			end
			6'b001000:begin//addi
				PCSource <=2'd0;
				WriteEnable<=1'b1;
				ALUSrcB<=1'b1;
				WriteAddr<=1'b0;
				MemWrite<=1'b0;
				WriteData<=1'b0;
			end
			6'b001100:begin//andi
				PCSource <=2'd0;
				WriteEnable<=1'b1;
				ALUSrcB<=1'b1;
				WriteAddr<=1'b0;
				MemWrite<=1'b0;
				WriteData<=1'b0;
			end
			6'b001111:begin//lui
				PCSource <=2'd0;
				WriteEnable<=1'b1;
				ALUSrcB<=1'b1;
				WriteAddr<=1'b0;
				MemWrite<=1'b0;
				WriteData<=1'b0;
			end
			6'b001101:begin//ori
				PCSource <=2'd0;
				WriteEnable<=1'b1;
				ALUSrcB<=1'b1;
				WriteAddr<=1'b0;
				MemWrite<=1'b0;
				WriteData<=1'b0;
			end
			6'b001010:begin//sli
				PCSource <=2'd0;
				WriteEnable<=1'b1;
				ALUSrcB<=1'b1;
				WriteAddr<=1'b0;
				MemWrite<=1'b0;
				WriteData<=1'b0;
			end
			6'b000100:begin//beq
				PCSource<=2'd1;
				WriteEnable<=1'b0;
				ALUSrcB<=1'b0;
				WriteAddr<=1'b0;
				MemWrite<=1'b0;
				WriteData<=1'b0;
			end
			6'b010101:begin//bne
				PCSource<=2'd3;
				WriteEnable<=1'b0;
				ALUSrcB<=1'b0;
				WriteAddr<=1'b0;
				MemWrite<=1'b0;
				WriteData<=1'b0;
			end
			6'b100011:begin//lw
				PCSource<=2'd0;
				WriteEnable<=1'b1;
				ALUSrcB<=1'b1;
				WriteAddr<=1'b0;
				MemWrite<=1'b0;
				WriteData<=1'b1;
			end
			6'b101011:begin//sw
				PCSource<=2'd0;
				WriteEnable<=1'b0;
				ALUSrcB<=1'b1;
				WriteAddr<=1'b0;
				MemWrite<=1'b1;
				WriteData<=1'b0;
			end
			6'b000010:begin//jump
				PCSource<=2'd2;
				WriteEnable<=1'b0;
				ALUSrcB<=1'b0;
				WriteAddr<=1'b0;
				MemWrite<=1'b0;
				WriteData<=1'b0;
			end
			default:begin
				PCSource<=2'd0;
				WriteEnable<=1'b0;
				ALUSrcB<=1'b0;
				WriteAddr<=1'b0;
				MemWrite<=1'b0;
				WriteData<=1'b0;
			end





		endcase

	end

endmodule
