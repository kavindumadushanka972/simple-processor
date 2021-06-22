/*	Madushanka H.M.K
	E/16/221
	Code for calculate jump value in 32bit to add to pc value
*/
`timescale 1ns/100ps

module branch_add(input[31:0] outextend,output [31:0] pc_branch_out);

	reg pc_branch_out;

	always @(*)begin
		pc_branch_out = outextend<<2; //left shift by two(multiply by 4)
	end
endmodule

