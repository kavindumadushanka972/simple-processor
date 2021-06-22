/*  Madushanka H.M.K
    E/16/221
    Code for Mux
*/
`timescale 1ns/100ps

module mux(input[7:0] input_mux_1,input_mux_2, output[7:0] output_mux, input select);

reg output_mux;
//if select = 0 , output is input 1 otherwise ouytput is input 2
always @(*)begin
	if(select == 1'b0)begin
		output_mux = input_mux_1;
	end
	else if(select == 1'b1)begin
		output_mux = input_mux_2;
	end
end

endmodule
