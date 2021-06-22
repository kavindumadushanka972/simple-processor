/*  Madushanka H.M.K
    E/16/221
    Code for Register File
*/
`timescale 1ns/100ps

module reg_file(CLK, RESET, WRITE, IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, busywait);

input[7:0] IN;  //8-bit input data to write
input[2:0] OUT1ADDRESS, OUT2ADDRESS, INADDRESS; //register addresses of read and write
output reg[7:0] OUT1, OUT2; //output data from reading registers
input WRITE, CLK, RESET;    //inputs to enable write,clock and reset
input busywait;
reg[7:0] register[7:0];     //8 registers array to store 8-bit data

always@(posedge(CLK)) begin //write command will work according to clk(synchronously)
    #1;    //1 time units delay
    if(WRITE == 1'b1 && !busywait)begin  //if write command given
        register[INADDRESS] = IN;  //write into given register 
    end
end

always@(register[OUT1ADDRESS], register[OUT2ADDRESS])begin  //reading asynchronously    
    #2; //2 time units delay
    //assigning output data
    OUT1 = register[OUT1ADDRESS];  
    OUT2 = register[OUT2ADDRESS];
end

always@(RESET)begin 
    if(RESET == 1'b1)begin  //if reset is set
    #2; //register file reset delay
    //set all values in registers to zero
    register[0] = 0;
    register[1] = 0;
    register[2] = 0;
    register[3] = 0;
    register[4] = 0;
    register[5] = 0;
    register[6] = 0;
    register[7] = 0; 
    end
end
endmodule
    
