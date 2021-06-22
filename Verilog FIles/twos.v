/*  Madushanka H.M.K
    E/16/221
    Code for Twos Complement
*/
`timescale 1ns/100ps

module twos(input[7:0] input_num,output[7:0] output_num);

reg output_num;

always @(input_num)begin
	output_num = ~(input_num)+1'b1;
end

endmodule
