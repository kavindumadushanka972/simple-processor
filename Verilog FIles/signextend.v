/*	Madushanka H.M.K
	E/16/221
	Code for sign extend(8-bit => 32-bit)
*/
`timescale 1ns/100ps

module signextend(input[7:0] addval, output[31:0] outextend);/*getting input value of j or beq and make it a 32 bit value and 
send it to the branch add module*/
	reg outextend;

	always@(*)begin
			if(addval[7]==0)begin
				outextend = 32'b0;
				outextend = outextend + addval;
			end
			if(addval[7]==1)begin //if add val starts with 1
				outextend = 32'b11111111111111111111111100000000;
				outextend = outextend + addval;
			end
	end

endmodule

