module mips_tb;
	
	reg NRST;
	reg CLK;
	wire [31:0] DATA_IN;
		
	wire [31:0] INST_ADDR;
	wire [31:0] DATA_ADDR;
	wire [31:0] DATA_OUT;
	wire [31:0] INST;
	wire DATA_WRITE;
		
	mips UUT(
		.CLK(CLK),
		.NRST(NRST),
		.INST(INST),
		.DATA_IN(DATA_IN),
		.INST_ADDR(INST_ADDR),
		.DATA_ADDR(DATA_ADDR),
		.DATA_OUT(DATA_OUT),
		.DATA_WRITE(DATA_WRITE)
		);
	instmem imem(
		.clk(CLK),.nrst(NRST),
		.addr(INST_ADDR),
		.in(32'b0),
		.write(1'b0),
		.out(INST)
		);
	
	mipsmem dmem(
		.clk(CLK),.nrst(NRST),
		.addr(DATA_ADDR),
		.in(DATA_OUT),
		.write(DATA_WRITE),
		.out(DATA_IN)
		);
		
				
	always #10 CLK=~CLK;
		
	initial begin
		$vcdplusfile("mipstb.vpd");
		$vcdpluson;
		
		NRST = 0;
		CLK=0;
		#20
		NRST=1;
		#100000;
		$finish;
	end
endmodule
