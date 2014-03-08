`timescale 1ns / 1ps

module testbench();

reg clk, nrst;

wire [31:0] inst, data_in;
wire [31:0] inst_addr, data_addr, data_out;
wire data_write;

integer file_desc;
integer file_read;
reg file_op;

reg write_check, write_check_del;
reg [31:0] port_check, ans;

instmem instmem(
	.clk(clk),
	.inst_addr(inst_addr),
	.inst(inst)
);

datamem datamem(
	.clk(clk),
	.data_addr(data_addr),
	.memwr(data_write),
	.din(data_in),
	.dout(data_out)
);

mips uut(
	.CLK(clk),
	.NRST(nrst),
	.INST(inst),
	.DATA_IN(data_in),
	.INST_ADDR(inst_addr),
	.DATA_ADDR(data_addr),
	.DATA_OUT(data_out),
	.DATA_WRITE(data_write)
);

always@(negedge clk or negedge nrst) begin
	if(~nrst) begin
		write_check <= 1'b0;
		write_check_del <= 1'b0;
		port_check <= 32'h0;
		file_op = 1'b0;
	end else begin
		port_check <= data_out;
		write_check <= data_write;
		write_check_del <= write_check;
		if((port_check == 32'hFFFFFFFF) && ({write_check,write_check_del} == 2'b10) && file_op) begin
			$fclose(file_desc);		// close file
			$display("Answer compare terminated with signal 32'hFFFFFFFF");
			$display();
			file_op = 1'b0;			// file status closed
			$finish;
		end 
		else if ({write_check,write_check_del} == 2'b10) begin
			if (!file_op) begin 		
				file_desc = $fopen("answers.txt","r");
				file_op = 1'b1;
			end
			if (file_desc == 0) $display("File open failed");
			else begin
				file_read = $fscanf(file_desc,"%h", ans);			// scan for the answer 
				if (file_read == 0) $display("EOF reached or answer key read failure");	// if EOF terminate
				else result_comp(ans,port_check);	//else compare answer with the result_reg
			end
		end
	end
end

task result_comp;
	input [31:0] right_ans;
	input [31:0] actual_ans;	

	begin
		if (actual_ans == right_ans) $display("Actual answer = right answer = %h", actual_ans);	
		else begin 
			$display("Actual answer = %h Right answer = %h. ANSWER MISMATCH.", actual_ans, right_ans);
			$display("Please check log file to pinpoint errant instruction");
		end
		$display();
	end

endtask


always #10 clk = !clk;

initial
begin 
	$vcdplusfile("top_tb.vpd");
	$vcdpluson;
	
	clk = 1'b0;
	nrst = 1'b0;

	#23
	nrst = 1'b1;
	#30000
	$finish;
end

endmodule


