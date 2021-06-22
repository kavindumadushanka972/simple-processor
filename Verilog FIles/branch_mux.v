/*	Madushanka H.M.K
	E/16/221
	Code for get decision to branch or not
*/
`timescale 1ns/100ps

module branch_mux(input[7:0] val, input ZERO, output[7:0] addval); /*getting output ZERO value from alu
and if ZERO == 0 dont consider any jump or beq condition, otherwise consider jump or beq value*/

reg addval;

always@(*)begin
	if(ZERO == 1)begin
		addval = val; //sending output value(number of instructions to jump) to sign extender
	end
	else begin
		addval = 8'b0;	//setting add value to zero
	end
end
endmodule
