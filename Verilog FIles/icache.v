/*	Madushanka H.M.K
	E/16/221
	Code for INSTRUCTION CACHE
*/

`timescale 1ns/100ps
`include "imemory.v"

module ins_cache(
	CLK, 
	RESET, 
	PC, 
	icache_busy, 
	instruction
	);
	
	/*signals related to instruction cache*/
	input CLK, RESET; //input clock and reset signals from testbench
	input [31:0] PC; //input pc value from cpu
	output [31:0] instruction; //instruction output from instruction cache
	output reg icache_busy; //busy signal from instruction cache to testbench

	/*signals related to instruction memory*/
	wire imem_busy; //input busy signal from instruction memory
	wire [127:0] imem_readdata; //input block of data from instruction memory
	reg imem_read; //instruction memory read enabling signal
	reg[5:0] imem_address; //address to read
	
	/*instruction cache special variables*/
	reg signed[10:0] address; //assign signed values because we considering pc = -4
	reg [127:0] icache[7:0]; //cache memory
	reg[127:0] icache_data;
	reg [2:0] tag_array[7:0];
	reg [7:0] valid_array;
	wire valid;
	wire hit;
	wire [2:0] index, tag;
	wire tagCheck;
	integer i;

	inst_data_memory my_inst_data_memory(CLK, imem_read,imem_address,imem_readdata,imem_busy);

	always @(PC)begin
		address = PC[10:0];
		if(address == -4)begin //ignore busy when pc value = -4
			icache_busy = 0;
		end
		else begin
			icache_busy = 1; //otherwise set busy signal and check if it is a hit or miss
		end
	end

	assign index = address[6:4];

	always @(*)begin
		#1 icache_data = icache[index];
	end

	assign #1 tag = tag_array[index];
	assign #1 valid = valid_array[index];
	assign #0.9 tagCheck = (tag == address[9:7]) ? 1 : 0;
	
	assign hit = valid && tagCheck;

	always @(posedge CLK)begin //is it is a hit, disable busy signal
		if(hit)
			icache_busy = 0;
	end
	// always@(*)begin
	// 	#1
	// 	if(address[3:2] == 2'b00 && hit == 1)
	// 		instruction = icache_data[31:0];
	// 	if(address[3:2] == 2'b01 && hit == 1)
	// 		instruction = icache_data[63:32];
	// 	if(address[3:2] == 2'b10 && hit == 1)
	// 		instruction = icache_data[95:64];
	// 	if(address[3:2] == 2'b11 && hit == 1)
	// 		instruction = icache_data[127:96];
	// end

	//passign instructions to the cpu
	assign #1 instruction = ((address[3:2] == 2'b00) && hit) ? icache_data[31:0] :
							((address[3:2] == 2'b01) && hit) ? icache_data[63:32] :
							((address[3:2] == 2'b10) && hit) ? icache_data[95:64] : icache_data[127:96];

	always @(posedge RESET)begin //when reset == 1, set all instruction cache registers to zero
		for(i = 0; i < 8; i = i +1)begin
			icache[i] = 0;
			tag_array[i] = 0;
			valid_array[i] = 0;
		end
	end

	parameter IDLE = 2'b00, INSTRUCTION_READ = 2'b01, CACHE_WRITE = 2'b10;
	reg [2:0] state, next_state;

	//combinational next state logic
	always @(*)
	begin
	  case(state)
	    IDLE:
	        if((address != -4) && !hit) 
	            next_state = INSTRUCTION_READ; //if it is a miss, reading instruction memory       
	        else
	            next_state = IDLE;

	    INSTRUCTION_READ:
	        if(!imem_busy)
	            next_state = CACHE_WRITE;      
	        else
	            next_state = INSTRUCTION_READ;

	    CACHE_WRITE:
	        next_state = IDLE;
	  endcase
	end

	//combinational output logic
	always @(state)
	begin
	  case(state)
	    IDLE:
	    begin
	      imem_read = 0;
	      imem_address = 6'bx;  
	    end

	    INSTRUCTION_READ:
	    begin                             
	      imem_read = 1;        
	      imem_address = (address[9:4]);
	    end

	    CACHE_WRITE:
	    begin
	      imem_read = 0;
	      imem_address = 6'bx;
	      /*updating cache after reading instruction memory*/
	      #1  
	      icache[index] = imem_readdata;
	      tag_array[index] = address[9:7];
	      valid_array[index] = 1;
	    end
	  endcase
	end


	//sequential logic for state transitioning
	always @(posedge CLK,RESET)
	begin
	  if(RESET)
	    state = IDLE;
	  else
	    state = next_state;
	end
endmodule