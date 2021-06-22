/*
    Madushanka H.M.K
    E/16/221
    Code for Testbench
*/
`timescale 1ns/100ps

`include "control_unit.v"
`include "icache.v"
`include "branch_add.v"
`include "branch_mux.v"
`include "signextend.v"
`include "adder.v"
`include "alu.v"
`include "mux.v"
`include "reg.v"
`include "twos.v"
`include "dcache.v"


module testbench;

//reg[7:0] instruction_arr[1023:0];
//reg [31:0] instruction;
reg clk,reset,busy;
wire[31:0] pc;
reg[31:0] PC;
integer i;
wire[31:0] instructionFromCache;
wire icache_busy;
reg[31:0] instruction;

cpu mycpu(pc,instruction, clk, reset, busy);
ins_cache myins_cache(clk, reset, PC, icache_busy, instructionFromCache);


initial begin

    $dumpfile("cpu_wavedata.vcd");//GTK wave file
	$dumpvars(0, mycpu);
    $dumpvars(0, myins_cache);

    for(i = 0; i < 8; i = i + 1)begin
        $dumpvars(0, mycpu.myreg.register[i]);
    end

    PC = pc;
    busy = icache_busy;
    instruction = instructionFromCache;

	clk = 1'b1;
    reset = 1'b1;

    #2
    reset = 1'b0;

	#3000
	$finish;
end
    always @(*)begin
        PC = pc;
        busy = icache_busy;
        instruction = instructionFromCache;
    end

	always
        #4 clk = ~clk;
endmodule