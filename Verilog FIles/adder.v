/*	Madushanka H.M.K
	E/16/221
	Code for PC ADDER
*/
`timescale 1ns/100ps

module adder(input[31:0] PC,pc_branch_out, input ZERO, busywait, output[31:0] PC_OUT);

reg PC_OUT;

always @(PC, busywait)begin
	if(busywait == 1'b0)begin
		#5//pc update delay(had to set this as 5 to get the correct functuality, this don't affect to the process anyway)
		case(ZERO)
			1'b0 : begin
				PC_OUT <= PC + 32'd4; //if it is a normal instruction read
			end
			1'b1 : begin //if it is a jump situation
				PC_OUT <= PC + pc_branch_out + 32'd4;
			end
			default : PC_OUT <= PC + 32'd4; //in case of ZERO has no value
		endcase
	end
end
endmodule