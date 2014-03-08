`timescale 1ns / 1ps
module processor(
	CLK,NRST,INST,DATA_IN,
	INST_ADDR,DATA_ADDR,DATA_OUT,DATA_WRITE
	);

	input CLK;
	input NRST;
	input [31:0] INST;
	input [31:0] DATA_IN;

	output [31:0] INST_ADDR;
	output [31:0] DATA_ADDR;
	output [31:0] DATA_OUT;
	output DATA_WRITE;

//IF wires
	wire [31:0] BranchComputationResult;
	wire [31:0] PCIncrementResult;
	wire [31:0] CurrentPC;
	wire [31:0] PCMuxResult;
	wire [9:0] CommandString;
	wire [31:0] PCIncrementResult_FU;
	wire [31:0] INST_FU;
	wire [31:0] CommandString_FU;

//ID wires
	wire [31:0] ID_PCIncrementResult;
	wire [31:0] ID_INST;
	wire [31:0] ID_COMMAND;
	wire [4:0] ReadReg1;
	wire [4:0] ReadReg2;
	wire [31:0] ReadData1;
	wire [31:0] ReadData2;
	wire [4:0] ReadDest;
	wire [15:0] Immediate;
	wire [31:0] SEImmediate;
	wire [31:0] SLImmediate;
	wire [31:0] ALUBMuxOut;
	wire [31:0] DestinationMuxOut;
	wire [31:0] ReadData1_FU;
	//wire [31:0] ALUBMuxOut_FU;
	wire [31:0] ReadData2_FU;
	wire IDEXE_1;
	wire [31:0] PCMUX3;
	wire [31:0] FU_IDEXE_COMMAND;
//EXE WIRES
	wire [31:0] EXE_RS;
	wire [31:0] EXE_RT;
	wire [31:0] EXE_INST;
	wire [31:0]EXE_PCIncrementResult;
	wire [31:0]ALUSrcA;
	wire [31:0]ALUSrcB;
	wire [31:0]EXE_SLImmediate;
	wire [31:0] StoreOperand;
	wire [31:0]DestAddress;
	wire [31:0]ALUResult;
	wire ZERO;
	wire [31:0]EXE_COMMAND;
	wire [31:0] ALUSrcA_FU;
	wire [31:0] StoreOperand_FU;
	wire [31:0] ALUSrcB_FU;
	wire IDEXE_2;

//MEM WIRES
	wire [31:0] MEM_INST;
	wire [31:0] AddressOrData;
	wire[31:0] MemWriteData;
	wire [31:0] MemReadData;
	wire [31:0] RFWriteData;
	wire [31:0] RFWriteAddress;
	wire [31:0]MEM_COMMAND;
	wire [31:0] StoreOperandInput_FU;

	wire [2:0] ALUControl;
//Output Assignments
	assign INST_ADDR = CurrentPC;
	assign DATA_ADDR = AddressOrData;
	assign DATA_OUT = MemWriteData;
	assign MemReadData = DATA_IN;

//ID Assignments
	wire [1:0] PCSource;
	assign ReadReg1 = ID_INST[25:21];
	assign ReadReg2 = ID_INST[20:16];
	assign ReadDest = ID_INST[15:11];
	assign Immediate = ID_INST[15:0];
	assign SEImmediate = {{16{Immediate[15]}},Immediate};
	assign SLImmediate = {SEImmediate[29:0],2'b0};
	assign WriteEnable= MEM_COMMAND[7];
	assign ALUSrcBControl = ID_COMMAND[6];
	assign WriteAddr = ID_COMMAND[5];
	assign ALUControl = EXE_COMMAND[2:0];
	assign DATA_WRITE = MEM_COMMAND[4];
	assign WriteData = MEM_COMMAND[3];
	assign WriteCommit = MEM_COMMAND[7];
	//assign WriteCommit = ((MEM_COMMAND[7]&&(MEM_INST[31:26]==6'b0||MEM_INST[31:29]==3'b100||MEM_INST[31:26]==6'b001010))||(MEM_COMMAND[4]&&MEM_INST[31:26]==6'b101011));
	//assign PCSource = (ID_COMMAND[9:8]==2'd2)? 2'd2 : (EXE_COMMAND[9:8]==2'd1) ? {1'b0,ZERO} : (EXE_COMMAND[9:8]==2'd3)?{1'b0,~ZERO}:2'd0;
	assign PCSource = (EXE_COMMAND[9:8]==2'd1&&ZERO)? {2'b01}: (EXE_COMMAND[9:8]==2'd3&&(~ZERO))? {2'b01}: (ID_COMMAND[9:8]==2'd2)? 2'd2:2'd0;
	assign ALUSrcA_FU = (|EXE_RS)? (RFWriteAddress==EXE_RS&&WriteCommit)? RFWriteData: ALUSrcA : 32'b0;
	//assign ALUSrcA_FU = (RFWriteAddress==EXE_RS&&(~EXE_COMMAND[6])&&(|EXE_RS))? RFWriteData : ALUSrcA;
	assign ALUSrcB_FU = ((RFWriteAddress==EXE_RT)&&(~EXE_COMMAND[6])&&WriteCommit)? RFWriteData : ALUSrcB;
	assign ReadData1_FU = (|ReadReg1)? (RFWriteAddress=={27'b0,ReadReg1}&&WriteCommit)? RFWriteData: ReadData1 :32'b0;
	//assign ReadData1_FU = (RFWriteAddress=={27'b0,ReadReg1}&&(~ID_COMMAND[6])&&(|ReadReg1))? RFWriteData : ReadData1;
	assign ReadData2_FU = (RFWriteAddress=={27'b0,ReadReg2}&&(~ID_COMMAND[6])&&(|ReadReg2)&&WriteCommit)? RFWriteData : ReadData2;
	//assign ALUBMuxOut_FU = (RFWriteAddress=={27'b0,ReadReg2}&&~ALUSrcBControl)? RFWriteData : ALUBMuxOut;
	assign StoreOperandInput_FU = (RFWriteAddress=={27'b0,ReadReg2})? RFWriteData : ReadData2_FU;
	assign StoreOperand_FU = (RFWriteAddress==EXE_RT) ? RFWriteData : StoreOperand;
	assign IFID_INST_LATCH = ID_COMMAND[9:8]!=2'd2;
	assign StallForB = (PCSource==2'd1);
	assign FU_WriteEnable_IFID = (StallForB)? CommandString : 0;
	assign FU_WriteEnable_IDEXE = (StallForB)? ID_COMMAND : 0;
	
	assign PCMUX3 = {ID_PCIncrementResult[31:28],ID_INST[25:0],2'b0};
	assign PCIncrementResult_FU = (IFID_INST_LATCH)? PCIncrementResult:0;
	assign INST_FU = (IFID_INST_LATCH)? INST:0;
	assign CommandString_FU = (IFID_INST_LATCH&&(PCSource!=2'd1))? {21'b0,CommandString}:0;
	assign FU_IDEXE_COMMAND = (PCSource==2'd1)? 0:ID_COMMAND;
	


//IF PCSource MUX
	mux PCSourceMux(
		.in0(PCIncrementResult),
		.in1(BranchComputationResult),
		.in2(PCMUX3),
		.in3(32'b0),
		.select(PCSource),
		.muxout(PCMuxResult)
		);
//PCReg
	register PCREG(
		.clk(CLK),
		.nrst(NRST),
		.in(PCMuxResult),
		.latch(1'b1),
		.out(CurrentPC)
		);
//IF PCIncrement ADDER
	adder PCIncrementAdder(
		.a(32'd4),
		.b(CurrentPC),
		.o(PCIncrementResult)
		);

//IF INST Decoder
	InstDecode IDEC(
		.inst(INST),
		.CommandString(CommandString)
		);

//IFID Registers go here

		
//PC  Register for ID
	register IFID_PC(
		.clk(CLK),
		.nrst(NRST),
		.in(PCIncrementResult_FU),
		.latch(1'b1),
		.out(ID_PCIncrementResult)
		);

//Instruction Register for ID
	register IFID_INST(
		.clk(CLK),
		.nrst(NRST),
		.in(INST_FU),
		.latch(1'b1),
		.out(ID_INST)
		);

//Register for Command Signals Propagation
	register IFID_COMMAND(
		.clk(CLK),
		.nrst(NRST),
		.in(CommandString_FU),
		.latch(1'b1),
		.out(ID_COMMAND)
		);

//ID REGFILE

	regfile rfile(
		.clk(CLK),
		.nrst(NRST),
		.RegWrite(WriteEnable),
		.rreg1(ReadReg1),
		.rreg2(ReadReg2),
		.wra(RFWriteAddress[4:0]),
		.wrd(RFWriteData),
		.rd1(ReadData1),
		.rd2(ReadData2)
		);

//ALUSRCBMUX

	mux ALUSRCBMUX(
		.in0(ReadData2_FU),
		.in1(SEImmediate),
		.in2(32'd0),
		.in3(32'd0),
		.select({1'b0,ALUSrcBControl}),
		.muxout(ALUBMuxOut)
		);

//DestAddrMux
	
	mux DestAddrMux(
		.in0({27'b0,ReadReg2}),
		.in1({27'b0,ReadDest}),
		.in2(32'b0),
		.in3(32'b0),
		.select({1'b0,WriteAddr}),
		.muxout(DestinationMuxOut)
		);
//IDEXE REGISTERS
//Idexe INST PROPAGATE
	register IDEXE_INST(
		.clk(CLK),
		.nrst(NRST),
		.in(ID_INST),
		.latch(1'b1),
		.out(EXE_INST)
		);
//IDEXE Rs PROPAGATE
	register IFID_RSP(
		.clk(CLK),
		.nrst(NRST),
		.in({27'b0,ReadReg1}),
		.latch(1'b1),
		.out(EXE_RS)
		);
//IDEXE RT Propagate
	register IFID_RTP(
		.clk(CLK),
		.nrst(NRST),
		.in({27'b0,ReadReg2}),
		.latch(1'b1),
		.out(EXE_RT)
		);
//IDEXE PC REG

	register IDEXE_PC(
		.clk(CLK),
		.nrst(NRST),
		.in(ID_PCIncrementResult),
		.latch(1'b1),
		.out(EXE_PCIncrementResult)
		);

//SLImmediate PIPELINE REG
	
	register SLIMreg(
		.clk(CLK),
		.nrst(NRST),
		.in(SLImmediate),
		.latch(1'b1),
		.out(EXE_SLImmediate)
		);

//ReadData1 PIPELINE REG

	register RD1(
		.clk(CLK),
		.nrst(NRST),
		.in(ReadData1_FU),
		.latch(1'b1),
		.out(ALUSrcA)
		);

//ALUSrcB PIPELINE REG
	
	register RD2(
		.clk(CLK),
		.nrst(NRST),
		.in(ALUBMuxOut),
		.latch(1'b1),
		.out(ALUSrcB)
		);

//DESTADDR PIPELINE REG

	register DEST(
		.clk(CLK),
		.nrst(NRST),
		.in(DestinationMuxOut),
		.latch(1'b1),
		.out(DestAddress)
		);

//COMMAND PIPELINE REG

	register EXE_COMMAND_REG(
		.clk(CLK),
		.nrst(NRST),
		.in(FU_IDEXE_COMMAND),
		.latch(1'b1),
		.out(EXE_COMMAND)
		);

//StoreOperand REG

	register SOR(
		.clk(CLK),
		.nrst(NRST),
		.in(StoreOperandInput_FU),
		.latch(1'b1),
		.out(StoreOperand)
		);

//branchcompadder
	
	adder bca(
		.a(EXE_PCIncrementResult),
		.b(EXE_SLImmediate),
		.o(BranchComputationResult)
		);

//ALU

	ALU ULA(
		.a(ALUSrcA_FU),
		.b(ALUSrcB_FU),
		.aluop(ALUControl),
		.o(ALUResult),
		.z(ZERO)
		);

//EXE MEM PIPELINE REGISTERS

	register ALUOUTMEM(
		.clk(CLK),
		.nrst(NRST),
		.in(ALUResult),
		.latch(1'b1),
		.out(AddressOrData)
		);
//EXEMEM INST PROPAGATE
	
	register EXEMEM_INST(
		.clk(CLK),
		.nrst(NRST),
		.in(EXE_INST),
		.latch(1'b1),
		.out(MEM_INST)
		);

//WRITE DATA REGISTER

	register WDR(
		.clk(CLK),
		.nrst(NRST),
		.in(StoreOperand_FU),
		.latch(1'b1),
		.out(MemWriteData)
		);

//MEM CMD Propagation
	register MCP(
		.clk(CLK),
		.nrst(NRST),
		.in(EXE_COMMAND),
		.latch(1'b1),
		.out(MEM_COMMAND)
		);

//Destination Register

	register DR(
		.clk(CLK),
		.nrst(NRST),
		.in(DestAddress),
		.latch(1'b1),
		.out(RFWriteAddress)
		);
//WB MUX

	mux wbmux(
		.in0(AddressOrData),
		.in1(MemReadData),
		.in2(32'b0),
		.in3(32'b0),
		.select({1'b0,WriteData}),
		.muxout(RFWriteData)
		);		



endmodule
