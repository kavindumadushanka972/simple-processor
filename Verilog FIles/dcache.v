/*
    Madushanka H.M.K
    E/16/221
    Code for Data Cache
*/

`timescale 1ns/100ps
`include "data_mem.v"


module dcache (
        CLK, 
        RESET, 
        readEn, // read enable bit 
        writeEn, //write enable bit
        address, //read, write addresses
        dataIn, //to write data to cache from cpu
        dataOut, //sending data to processor
        busy //wait flag
    );

    output reg busy; //busy signal to the processor
    wire busyMem, valid, dirty; //busy state of MainMemory, valid or dirty
    
    input CLK, RESET, readEn, writeEn; /*clk, reset and read, write control
                                        signals*/ 
    input[7:0] address; //address from alu
    input[7:0] dataIn; //data input
    output [7:0] dataOut; //data to cpu
    wire [7:0] dataOut;
    wire [31:0] dataFromM; //from data memory to cache
    reg[31:0] dataToM; //from cache to memory

    reg  writeM, readM, writeFromM; //data memory read/write control signals
    reg[5:0] dataMaddress; //data block address(7 bits)
    reg [31:0] data;
    

    //data mem declare here
    data_memory myMem2(CLK, RESET, readM, writeM, dataMaddress, dataToM, dataFromM, busyMem);

    //cache special variables------------

    reg[2:0] TAG [7:0]; //8 tags of 3 bits
    reg V [7:0]; //8 valid bits
    reg D [7:0]; // 8 dirty bits

    reg [31:0] cacheData[7:0]; // 8 blocks of 4 byte data

    wire[1:0] offset;
    wire[2:0] tag;
    wire[2:0] index;
    wire tagCheck;
    integer i;
    wire hit;

    always @(readEn ,writeEn)begin
    	if(readEn || writeEn)
    		busy = 1; //stall cpu when readEnable or WriteEnable signal asserted
    	else
   			busy = 0; //otherwise zero the signal
    end

    //assign offset = address[1:0];
    //assign index = address[4:2];
   
    assign #1 valid = V[address[4:2]];
    assign #1 dirty = D[address[4:2]];
    assign #1 tag = TAG[address[4:2]];

    always @(*)begin
    	#1
    	data = cacheData[address[4:2]];
    end

    // always @(*) begin //extract data from cache
    //     #1
    //     if(V[index])begin
    //         dataOut = cacheData[index][offset];
    //     end
    // end
    // always@(*)begin //tag comparison and check if it is a hit or a miss
    // 	if(tag == address[7:5])
    // 		#0.9
    // 		tagCheck = 1;
    // 	else
    // 		#0.9
    // 		tagCheck = 0;
    // end

    assign #0.9 tagCheck = (tag == address[7:5]) ? 1 : 0;
	assign hit = tagCheck && valid;

    // always@(*)
    // begin  
    //   if (hit == 1 && readEn == 1) begin   //if it is a hit and read Enabled                 
    //     case (address[1:0])	//according to offset, sending data to CPU
    //         2'b00:  dataOut = data[7:0];     
    //         2'b01:  dataOut = data[15:8];
    //         2'b10:  dataOut = data[23:16];
    //         2'b11:  dataOut = data[31:24];
    //         default:  dataOut = data[31:24];
    //     endcase

    //   end 
    // end

    assign dataOut = ((address[1:0] == 2'b01) && readEn && hit) ? data[15:8] :
    				 ((address[1:0] == 2'b10) && readEn && hit) ? data[23:16] :
    				 ((address[1:0] == 2'b11) && readEn && hit) ? data[31:24] : data[7:0];
    
    always@ (posedge CLK)
    begin
      if(hit == 1 && writeEn == 1) begin  //if it is a hit and writeEnabled                
        
        case (address[1:0]) //writing data to cache according to offset
            2'b00:  #1 cacheData[address[4:2]][7:0] = dataIn;     
            2'b01:  #1 cacheData[address[4:2]][15:8] = dataIn;
            2'b10:  #1 cacheData[address[4:2]][23:16] = dataIn;
            2'b11:  #1 cacheData[address[4:2]][31:24] = dataIn;
            default: #1 cacheData[address[4:2]][31:24] = dataIn;
        endcase 
        D[address[4:2]] = 1; //set Dirty bit                  
      end
    end

    always@ (posedge CLK)begin //posedge CLK
      if(hit)begin   
          busy = 0;  //if it is a hit, clear the busywait signal and fetch instructions   
      end
    end
    
    /* Cache Controller FSM Start*/

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE=3'b010, CACHE_WRITE=3'b011;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE: 
                if ((readEn || writeEn) && !dirty && !hit)  
                    next_state = MEM_READ;
                else if ((readEn || writeEn) && dirty && !hit)
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;
            
            MEM_READ: 
                if (!busyMem)
                    next_state = CACHE_WRITE;
                else    
                    next_state = MEM_READ;

            CACHE_WRITE:
                    next_state = IDLE;
                
            MEM_WRITE: 
                if(!busyMem)
                    next_state =MEM_READ;
                else
                    next_state= MEM_WRITE;
        endcase
    end

    // combinational output logic
    always @(state) //previous there was state, that is not working,, * is working
    begin
        case(state)
            IDLE:
            begin
                readM = 0;
                writeM = 0;
                dataMaddress = 6'dx;
                dataToM = 32'dx;
                busy = 0;
                //writeFromM = 0;  
            end
         
            MEM_READ: 
            begin
                readM = 1;
                writeM = 0;
                dataMaddress = address[7:2];
                dataToM = 32'dx;
                //busy = 1;
                //writeFromM = 0;
            end

            CACHE_WRITE:
            begin
                readM = 0;
                writeM = 0;
                dataMaddress = 6'dx;
                dataToM = 32'dx;
                //busy = 0;
                //busy = 1;
                //writeFromM = 1;

                #1
                cacheData[address[4:2]] = dataFromM;
                TAG[address[4:2]] = address[7:5];
                V[address[4:2]] = 1;
                D[address[4:2]] = 0;
            end

            MEM_WRITE:
            begin
                readM = 0;
                writeM =1;
                dataMaddress = {tag, address[4:2]};
                dataToM = data;
                //busy = 1;
                //writeFromM = 0;
            end
            
        endcase
    end

    //Reset cache blocks 
    always @(RESET)begin
        for (i=0; i<8; i=i+1)begin
            cacheData[i] = 0;
            TAG[i] = 0;
            V[i] = 0;
            D[i] = 0;
        end
    end

    // sequential logic for state transitioning 
    always @(posedge CLK, RESET)
    begin
        if(RESET)
            state = IDLE;
        else
            state = next_state;
    end

    /*Cache Controller FSM End*/

endmodule