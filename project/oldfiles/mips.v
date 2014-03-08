module mips(
	CLK,NRST,
	INST,DATA_IN,
	INST_ADDR,DATA_ADDR,
	DATA_OUT,DATA_WRITE);

	input CLK;
	input NRST;
	input [31:0] INST;
	input [31:0] DATA_IN;

	output [31:0] INST_ADDR;
	output [31:0] DATA_ADDR;
	output [31:0] DATA_OUT;
	output DATA_WRITE;


	wire [4:0] ReadRegister1,
		ReadRegister2,
		RegDstMux1;

	wire [31:0] WriteData,
		ReadData1,
		ReadData2,
		WriteRegister,
		ShiftLeft,
		MuxMemToReg,
		ALUB3,
		ALUINPUT1,
		ALUINPUT2,
		ALURESULT,
		PCSourceOut,
		PCOUT;

	wire [2:0] ALUOP,
		TOALUPICKER;

	wire[15:0] SignExtend;
	wire [5:0] OpCode;
	wire ZERO,ZEROPRIME;
	reg [4:0] state;
	reg [13:0] command;
	wire PCWrite,IRWrite,RegDst,MemToReg,RegWrite,ALUSrcA,PCRelease;
	wire [1:0] ALUSrcB,SEL,PCSource;
	wire [31:0] ALUREGISTEROUT;
	assign PCWrite = (OpCode==6'b000100)? (ZEROPRIME&&command[13]): (OpCode==6'b010101)? (ZEROPRIME&&command[13]): command[13];
	assign DATA_WRITE = command[12];
	assign IRWrite = command[11];
	assign RegDst = command[10];
	assign MemToReg = command[9];
	assign RegWrite = command[8];
	assign ALUSrcA = command[7];
	assign ALUSrcB = command[6:5];
	assign SEL = command[4:3];
	assign PCSource = command[2:1];
	assign PCRelease = command[0];
	assign RegDstMux1 = SignExtend[15:11];
	assign DATA_ADDR = ALUREGISTEROUT;
	assign DATA_OUT = ReadData2;

	register IR(
		.clk(CLK),
		.nrst(NRST),
		.in(INST),
		.latch(IRWrite),
		.out({OpCode,ReadRegister1,ReadRegister2,SignExtend})
		);

	register MDR(
		.clk(CLK),
		.nrst(NRST),
		.in(DATA_IN),
		.latch(1'b1),
		.out(MuxMemToReg)
		);

	signext signext1(
		.in(SignExtend),
		.out(ShiftLeft)
		);

	shiftleft shiftleft1(
		.in(ShiftLeft),
		.out(ALUB3)
		);

	mux regDstMux(
		.in0({27'd0,ReadRegister2}),
		.in1({27'd0,RegDstMux1}),
		.in2(32'b0),
		.in3(32'b0),
		.select({1'b0,RegDst}),
		.muxout(WriteRegister)
		);

	mux mem2reg(
		.in0(ALUREGISTEROUT),
		.in1(MuxMemToReg),
		.in2(32'b0),
		.in3(32'b0),
		.select({1'b0,MemToReg}),
		.muxout(WriteData)
		);

	mux ALUA(
		.in0(INST_ADDR),
		.in1(ReadData1),
		.in2(32'b0),
		.in3(32'b0),
		.select({1'b0,ALUSrcA}),
		.muxout(ALUINPUT1)
		);

	mux ALUB(
		.in0(ReadData2),
		.in1(32'd4),
		.in2(ShiftLeft),
		.in3(ALUB3),
		.select(ALUSrcB),
		.muxout(ALUINPUT2)
		);

	ALU ALUnit(
		.a(ALUINPUT1),
		.b(ALUINPUT2),
		.aluop(ALUOP),
		.o(ALURESULT),
		.z(ZERO)
		);

	register ALURegister(
		.clk(CLK),
		.nrst(NRST),
		.in(ALURESULT),
		.latch(1'b1),
		.out(ALUREGISTEROUT)
		);

	mux PCSourceMux(
		.in0(ALURESULT),
		.in1(ALUREGISTEROUT),
		.in2({4'b0,ReadRegister1[4:0],ReadRegister2[4:0],SignExtend,2'b0}),
		.in3(32'b0),
		.select(PCSource),
		.muxout(PCSourceOut)
		);

	register PC(
		.clk(CLK),.nrst(NRST),
		.in(PCSourceOut),
		.latch(PCWrite),
		.out(PCOUT)
		);

	register PCHOLD(
		.clk(CLK),.nrst(NRST),
		.in(PCOUT),
		.latch(PCRelease),
		.out(INST_ADDR)
		);

	beqorbne bqbn(
		.opcode(OpCode),
		.zero(ZERO),
		.zeroprime(ZEROPRIME)
		);

	alupicker apicker(
		.sel(SEL),
		.functoaluop(TOALUPICKER),
		.aluop(ALUOP)
		);

	functoaluop faluop(
		.func(SignExtend[5:0]),
		.opcode(OpCode),
		.aluop(TOALUPICKER)
		);

	regfile regfile1(
		.clk(CLK),
		.nrst(NRST),
		.RegWrite(RegWrite),
		.rreg1(ReadRegister1),
		.rreg2(ReadRegister2),
		.wra(WriteRegister[4:0]),
		.wrd(WriteData),
		.rd1(ReadData1),
		.rd2(ReadData2)
		);

	always@(posedge CLK or negedge NRST)begin
		if(!NRST)begin
			state<=0;
			command<=14'b10100000100000;
		end
		else begin
			case (state)
				5'd0:begin
					state<=5'd1;
					command<=14'b00000001100000;
				end
				5'd1:begin
					case(OpCode)
						6'b000000:begin
							state<=5'd2;
							command<=14'b00000010001000;
						end
						6'b001000:begin
							state<=5'd12;
							command<=14'b00000011001000;
						end
						6'b001100:begin
							state<=5'd12;
							command<=14'b00000011001000;
						end
						6'b001111:begin
							state<=5'd12;
							command<=14'b00000011001000;
						end
						6'b001101:begin
							state<=5'd12;
							command<=14'b00000011001000;
						end
						6'b001010:begin
							state<=5'd12;
							command<=14'b00000011001000;
						end
						6'b000100:begin
							state<=5'd4;
							command<=14'b10000010010010;
						end
						6'b010101:begin
							state<=5'd4;
							command<=14'b10000010010010;
						end
						6'b100011:begin
							state<=5'd6;
							command<=14'b00000011000000;
						end
						6'b101011:begin
							state<=5'd6;
							command<=14'b00000011000000;
						end
						6'b000010:begin
							state<=5'd10;
							command<=14'b10000000000100;
						end
						default:begin
							state<=5'd0;
							command<=14'b10100000100000;
						end
					endcase
				end
				5'd2:begin
					state<=5'd3;
					command<=14'b00010100000001;
				end
				5'd3:begin
					state<=5'd0;
					command<=14'b10100000100000;
				end
				5'd4:begin
					state<=5'd5;
					command<=14'b00000000000001;
				end
				5'd5:begin
					state<=5'd0;
					command<=14'b10100000100000;
				end
				5'd6:begin
					if(OpCode==6'b101011)begin
						state<=5'd7;
						command<=14'b01000000000001;
					end
					else begin
						state<=5'd8;
						command<=14'b00000000000000;
					end
				end
				5'd7:begin
					state<=5'd0;
					command<=14'b10100000100000;
				end
				5'd8:begin
					state<=5'd9;
					command<=14'b00001100000001;
				end
				5'd9:begin
					state<=5'd0;
					command<=14'b10100000100000;
				end
				5'd10:begin
					state<=5'd11;
					command<=14'b00000000000001;
				end
				5'd11:begin
					state<=5'd0;
					command<=14'b10100000100000;
				end
				5'd12:begin
					state<=5'd13;
					command<=14'b00000100000001;
				end
				5'd13:begin
					state<=5'd0;
					command<=14'b10100000100000;
				end
				default:state<=5'd0;
			endcase
		end

	end

endmodule
