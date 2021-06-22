/*	Madushanka H.M.K
	E/16/221
	Code for ALU
*/
`timescale 1ns/100ps

module alu(input[7:0] Data1,Data2,input[2:0] ALU_OP,output[7:0] Result, output ZERO);/*Data1 and Data2 are 8-bit inputs, Select variable is a 3-bit input
									Result variable is a 8-bit output(These are the logical inputs and 										outputs)*/
reg Result, ZERO, Flag;	//To hold the output values

 always @(*)begin
	if(ALU_OP == 3'b000 || 3'b110)begin //forwarding(loadi , mov instructions and memory access instructions)
		#1;	//delay
		Result = Data1;	//ignore source 1 from Results
		ZERO = 0;	//if ZERO value == 0, branch adder dont add any word value to pc
	end
end

always @(*)begin //add , sub
	if(ALU_OP == 3'b001)begin
		#2;	//delay
		Result = Data1 + Data2;
		ZERO = 0;
	end
end

always @(*)begin //and
	if(ALU_OP == 3'b010)begin
		#1;	//delay
		Result = Data1 & Data2;
		ZERO = 0;
	end
end

always @(*)begin //or
	if(ALU_OP == 3'b011)begin
		#1;	//delay
		Result = Data1 | Data2;
		ZERO = 0;
	end
end

always @(*)begin //jump
	if(ALU_OP == 3'b100)begin
		ZERO = 1;
	end
end

always @(*)begin //beq
	if(ALU_OP == 3'b101)begin
		Flag = 1;
		Result = Data1 + Data2;
		ZERO = ~(Flag && Result);
	end
end
endmodule
