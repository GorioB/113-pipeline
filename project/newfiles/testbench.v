`timescale 1ns / 1ps

module testbench();

reg clk, nrst;

wire [31:0] inst, data_in;
wire [31:0] inst_addr, data_addr, data_out;
wire data_write;

integer file_desc;
integer file_read;
reg file_op;

reg write_check;
reg [31:0] port_check, ans, addr_check;
reg [31:0] inst_check1, inst_check2;
reg [31:0] cycle_counter;


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

processor uut(
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
		addr_check <= 32'h0;
		port_check <= 32'h0;
		file_op = 1'b0;
	end else begin
		port_check <= data_out;
		write_check <= data_write;
		addr_check <= data_addr;
		if((port_check == 32'hFFFFFFFF) && (write_check) && file_op) begin
			$fclose(file_desc);		// close file
			$display("Answer compare terminated with signal 0xFFFFFFFF");
			$display("Finished in %d clock cycles", cycle_counter); 
			$display();
			file_op = 1'b0;			// file status closed
			$finish;
		end 
		else if (write_check) begin
			if (!file_op) begin 		
				file_desc = $fopen("answers.txt","r");
				file_op = 1'b1;
			end
			if (file_desc == 0) $display("File open failed");
			else begin
				file_read = $fscanf(file_desc,"%h", ans);			// scan for the answer 
				if (file_read == 0) $display("EOF reached or answer key read failure");	// if EOF terminate
				else begin
					$display("At data memory address %h...", addr_check);	
					result_comp(ans,port_check);	//else compare answer with the result_reg
				end
			end
		end
	end
end

always@(negedge clk or negedge nrst) begin
	if(~nrst) begin
		inst_check1 <= 32'h0;
		inst_check2 <= 32'h1;
	end else begin
		inst_check1 <= inst;
		inst_check2 <= inst_check1;
		if(inst_check1 == inst_check2) begin
			$display("PC is stalled at instruction 0x%h", inst_check2);
		end
	end
end 

always@(negedge clk or negedge nrst) begin
	if(~nrst) begin
		cycle_counter <= 32'h0;
	end else begin
		cycle_counter <= cycle_counter + 1;
	end
end

task result_comp;
	input [31:0] right_ans;
	input [31:0] actual_ans;	

	begin
		if (actual_ans == right_ans) $display("Actual answer = right answer = 0x%h", actual_ans);	
		else begin 
			$display("Actual answer = 0x%h Right answer = 0x%h. ANSWER MISMATCH.", actual_ans, right_ans);
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
	#30000000000
	$display("Finished due to simulator timeout");
	$finish;
end

endmodule


