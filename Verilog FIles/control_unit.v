/*	Madushanka H.M.K
	E/16/221
	Code for CONTROL UNIT
*/
`timescale 1ns/100ps

module cpu(PC,INST,CLK,RESET,ICACHE_BUSY);

//declaring wires and register variables
input ICACHE_BUSY;
wire[31:0] PC_OUT, outextend, pc_branch_out;
output reg[31:0] PC;
input [31:0] INST;
input CLK, RESET;
reg WRITE,select_mux_1,select_mux_2, Read, Write_mem, select_mux_3;
wire[7:0] RESULT, output_num, output_mux_1, output_mux_2, Data1, Data2, addval, output_mux_3, dataout;
reg [7:0] input_num,  input_mux_1, input_mux_2;	
wire ZERO, busywait;
reg[2:0] ALU_OP, INADDRESS, OUT1ADDRESS, OUT2ADDRESS;

reg_file myreg(CLK, RESET, WRITE, output_mux_3, Data1, Data2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, busywait); //(CLK, RESET, WRITE, IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS)
twos mytwos(Data2, output_num); //(input[7:0] input_num,output[7:0] output_num)
mux mymux1(Data2, output_num, output_mux_1, select_mux_1); //(input[7:0] input_mux_1,input_mux_2, output[7:0] output_mux, input select)
mux mymux2(INST[7:0], output_mux_1, output_mux_2, select_mux_2); //(input[7:0] input_mux_1,input_mux_2, output[7:0] output_mux, input select)
mux mymux3(dataout, RESULT, output_mux_3, select_mux_3);
alu myalu(output_mux_2, Data1, ALU_OP, RESULT, ZERO); //(input[7:0] Data1,Data2,input[2:0] Select,output[7:0] Result)
branch_mux mybranch_mux(INST[23:16], ZERO, addval); //consider zero value and get the decision to branch or not to branch
signextend mysignextend(addval, outextend);	//making 32bit value out from 8bit jump instruction value
branch_add mybranch_add(outextend, pc_branch_out); /*adding to the pc value with correct number of words to jump by left shifting 
													extended value*/
adder myadder(PC, pc_branch_out, ZERO, busywait, PC_OUT); //(input[31:0] PC, output[31:0] PC_OUT)
//data_memory mydata_mem(CLK, RESET, Read, Write_mem, RESULT, Data1, readdata, busywait);//(clock,reset,read,write,address,writedata,readdata,busywait);
dcache myDcache(CLK, RESET, Read, Write_mem, RESULT, Data1, dataout, busywait);

always @(RESET)begin
	if(RESET == 1'b1)begin
		#1 //pc update delay
		PC = -4;	//if given reset, program restarts again
	end
end

always @(posedge(CLK))begin
	#1 //pc update delay
	if(busywait == 1'b0 && ICACHE_BUSY == 1'b0)begin
		PC = PC_OUT; //PC update
	end
end

always@(INST)begin
	/*set to zero all read and write enabling signals in data memory*/
	Read = 0;	
	Write_mem = 0;

	//sending register addresses to register file
	INADDRESS = INST[18:16];
	OUT1ADDRESS = INST[10:8];
	OUT2ADDRESS = INST[2:0];

end

always@(INST)begin
	#1 //decode delay
	if(INST[31:24] == 8'b00000000 && RESET == 1'b0)begin //consider loadi
		WRITE = 1'b1;
		select_mux_1 = 1'b0; //dont do twos compliment(actually this value dont need to this operation)
		select_mux_2 = 1'b0;  //selecting immediate value coming from instruction
		select_mux_3 = 1'b1;
		Read = 1'b0;
		Write_mem = 1'b0;
		ALU_OP = 3'b000;
	end
	else if(INST[31:24] == 8'b00000001 && RESET == 1'b0)begin //consider mov
		WRITE = 1'b1;
		select_mux_1 = 1'b0;
		select_mux_2 = 1'b1; //selecting value in the register(Data2)
		select_mux_3 = 1'b1;
		Read = 1'b0;
		Write_mem = 1'b0;
		ALU_OP = 3'b000;
	end
	else if(INST[31:24] == 8'b00000010 && RESET == 1'b0)begin //consider add
		WRITE = 1'b1;
		select_mux_1 = 1'b0; //do not consider twos compliment because substraction not involving
		select_mux_2 = 1'b1; //to select value coming from mux1 which is regout 2(Data2)
		select_mux_3 = 1'b1;
		Read = 1'b0;
		Write_mem = 1'b0;
		ALU_OP = 3'b001;
	end
	else if(INST[31:24] == 8'b00000011 && RESET == 1'b0)begin //consider sub
		WRITE = 1'b1;
		select_mux_1 = 1'b1; //consider twos compliment because substraction involving
		select_mux_2 = 1'b1; //to select value coming from mux1 which is regout 2(Data2)
		select_mux_3 = 1'b1;
		Read = 1'b0;
		Write_mem = 1'b0;
		ALU_OP = 3'b001;
	end
	else if(INST[31:24] == 8'b00000100 && RESET == 1'b0)begin //consider and
		WRITE = 1'b1;
		select_mux_1 = 1'b0;
		select_mux_2 = 1'b1;
		select_mux_3 = 1'b1;
		Read = 1'b0;
		Write_mem = 1'b0;
		ALU_OP = 3'b010;
	end
	else if(INST[31:24] == 8'b00000101 && RESET == 1'b0)begin //consider or
		WRITE = 1'b1;
		select_mux_1 = 1'b0;
		select_mux_2 = 1'b1;
		select_mux_3 = 1'b1;
		Read = 1'b0;
		Write_mem = 1'b0;
		ALU_OP = 3'b011;
	end
	else if(INST[31:24] == 8'b00000110 && RESET == 1'b0)begin //consider jump
		WRITE = 1'b0;
		select_mux_1 = 1'b0;
		select_mux_2 = 1'b0;
		select_mux_3 = 1'b1;
		Read = 1'b0;
		Write_mem = 1'b0;
		ALU_OP = 3'b100;
	end
	else if(INST[31:24] == 8'b00000111 && RESET == 1'b0)begin //consider beq
		WRITE = 1'b0;
		select_mux_1 = 1'b1; //to do twos compliment because the subtraction involving
		select_mux_2 = 1'b1; //to select the value coming from mux1 which is regout 2(Data2)
		select_mux_3 = 1'b1;
		Read = 1'b0;
		Write_mem = 1'b0;
		ALU_OP = 3'b101;
	end
	else if(INST[31:24] == 8'b00001000 && RESET == 1'b0)begin //consider lwd
		WRITE = 1'b1;
		select_mux_1 = 1'b0; 
		select_mux_2 = 1'b1; //select the data from register(no need of two's complement)
		select_mux_3 = 1'b0;
		Read = 1'b1;
		Write_mem = 1'b0;
		ALU_OP = 3'b110;
	end
	else if(INST[31:24] == 8'b00001001 && RESET == 1'b0)begin //consider lwi
		WRITE = 1'b1;
		select_mux_1 = 1'b0; 
		select_mux_2 = 1'b0; //select immediate value
		select_mux_3 = 1'b0;
		Read = 1'b1;
		Write_mem = 1'b0;
		ALU_OP = 3'b110;
	end
	else if(INST[31:24] == 8'b00001010 && RESET == 1'b0)begin //consider swd
		WRITE = 1'b0;
		select_mux_1 = 1'b0; 
		select_mux_2 = 1'b1; //select the data from register(no need of two's complement)
		select_mux_3 = 1'b0;
		Read = 1'b0;
		Write_mem = 1'b1;
		ALU_OP = 3'b110;
	end
	else if(INST[31:24] == 8'b00001011 && RESET == 1'b0)begin //consider swi
		WRITE = 1'b0;
		select_mux_1 = 1'b0; 
		select_mux_2 = 1'b0; //select immediate value
		select_mux_3 = 1'b0;
		Read = 1'b0;
		Write_mem = 1'b1;
		ALU_OP = 3'b110;
	end
end
endmodule


