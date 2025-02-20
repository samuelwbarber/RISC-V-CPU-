`include "include/ControlTypeDefs.svh"
module oldDataMem #(
    parameter DATA_WIDTH = 32
 )(
    input  logic                     iClk,             // clock
    input  logic                     iWriteEn,        // write enable
    input  InstructionTypes          iInstructionType,
    input  InstructionSubTypes       iMemoryInstructionType,
    input  logic [31:0]              iAddress,        // Write Address
    input  logic [DATA_WIDTH-1:0]    iMemData,        // Write Data
    output logic [DATA_WIDTH-1:0]    oMemData         // output
);



//////////////////////////////////////////////
////  Internal Memory, Data and Addresses  ////
//////////////////////////////////////////////

    //RAM Array : Accomodate for Address starting at : 0x10000 to 0x1FFFF
    logic [31:0] mem_array [2**17 - 1  : 0]; 

    /* verilator lint_off UNOPTFLAT */
    //Holds the data out of memory cell 
    logic [31:0] mem_data;
    /* verilator lint_on UNOPTFLAT */

    //Word address and byte offset within the address
    logic [31:0] word_aligned_address;
    logic [1:0]  byte_offset;

    //Memory Bytes - Data stored in memory location we want to access
    logic [7:0] byte1;
    logic [7:0] byte2;
    logic [7:0] byte3;
    logic [7:0] byte4;

    initial begin
        $readmemh("pdf.hex", mem_array, 20'h10000);
    end

////////////////////////////////////////
////     Read/Write Data Flip Flop  ////
////////////////////////////////////////

    //Write or Read data on rising edge of clk
    always_ff @(negedge iClk) begin
        if (iWriteEn) begin
            mem_array[word_aligned_address + 32'd3][7:0] <= byte4;
            mem_array[word_aligned_address + 32'd2][7:0] <= byte3;
            mem_array[word_aligned_address + 32'd1][7:0] <= byte2;
            mem_array[word_aligned_address][7:0]         <= byte1;
        end
    end

    always_latch begin  
        if (iWriteEn==0) begin
            oMemData   = mem_data;            
        end
    end


//////////////////////////////////////////////
////      Internal Signal Initialisation  ///
/////////////////////////////////////////////



/////////////////////////////////////////////////
////   Logic to compute what is written/read  ///
/////////////////////////////////////////////////
    always_comb begin        
        word_aligned_address = {{iAddress[31:2]}, {2'b00}};                 //Word aligned address -> multiple of 4
        byte_offset          = iAddress[1:0];                               //2 LSBs of iAddress define byte offset within the word
        
        byte4 =   mem_array[word_aligned_address + 32'd3 ][7:0];
        byte3 =   mem_array[word_aligned_address + 32'd2][7:0];
        byte2 =   mem_array[word_aligned_address + 32'd1][7:0];
        byte1 =   mem_array[word_aligned_address][7:0];
        case (iInstructionType) 

            //Write Operation
            STORE : begin
                
                case (iMemoryInstructionType)

                    STORE_BYTE : begin
                        case (byte_offset) 
                            2'b00 : byte1 = iMemData[7:0];
                            2'b01 : byte2 = iMemData[7:0];
                            2'b10 : byte3 = iMemData[7:0];
                            2'b11 : byte4 = iMemData[7:0];
                        endcase
                    end
                    
                    
                    STORE_HALF : begin
                        case (byte_offset) 
                            2'b00 : begin 
                                byte1 = iMemData[7:0];
                                byte2 = iMemData[15:8];
                            end

                            2'b01 : begin
                                byte2 = iMemData[7:0];
                                byte3 = iMemData[15:8];
                            end
                            2'b10 : begin
                                byte3 = iMemData[7:0];
                                byte4 = iMemData[15:8];
                            end
                            2'b11 : begin
                                byte3 = iMemData[7:0];
                                byte4 = iMemData[15:8];
                            end
                        endcase
                    end
                    
                    STORE_WORD : begin
                        byte4 = iMemData[31:24];
                        byte3 = iMemData[23:16];
                        byte2 = iMemData[15:8];
                        byte1 = iMemData[7:0];
                    end

                    default    : begin
                        byte4 = iMemData[31:24];
                        byte3 = iMemData[23:16];
                        byte2 = iMemData[15:8];
                        byte1 = iMemData[7:0];
                    end

                endcase
            end

            //Read Operation
            /* verilator lint_off ALWCOMBORDER */
            LOAD : begin  
                //oWriteCache=mem_data;
                case(iMemoryInstructionType)
                    
                    LOAD_BYTE  : begin

                        case (byte_offset) 
                            2'b00 : mem_data[7:0] = byte1;
                            2'b01 : mem_data[7:0] = byte2;
                            2'b10 : mem_data[7:0] = byte3;
                            2'b11 : mem_data[7:0] = byte4;
                        endcase

                        mem_data[31:8] = {24{mem_data[7]}}; //sign extend
                    end

                    LOAD_HALF  : begin

                        case (byte_offset) 
                            2'b00 : mem_data[15:0] = {byte2, byte1};
                            2'b01 : mem_data[15:0] = {byte3, byte2};
                            2'b10 : mem_data[15:0] = {byte4, byte3};
                            2'b11 : mem_data[15:0] = {byte4, byte3};
                        endcase
                        
                        mem_data[31:16] = {16{mem_data[15]}}; //sign extend
                    end

                    ULOAD_BYTE : begin            

                        case (byte_offset) 
                            2'b00 : mem_data[7:0] = byte1;
                            2'b01 : mem_data[7:0] = byte2;
                            2'b10 : mem_data[7:0] = byte3;
                            2'b11 : mem_data[7:0] = byte4;
                        endcase

                        mem_data[31:8] = {24{1'b0}}; //zero extend

                    end

                    ULOAD_HALF : begin

                        case (byte_offset) 
                            2'b00 : mem_data[15:0] = {byte2, byte1};
                            2'b01 : mem_data[15:0] = {byte3, byte2};
                            2'b10 : mem_data[15:0] = {byte4, byte3};
                            2'b11 : mem_data[15:0] = {byte4, byte3};
                        endcase

                        mem_data[31:16] = {16{1'b0}}; //Zero extend

                    end

                    LOAD_WORD  : mem_data = {byte4, byte3, byte2, byte1};               

                    default    : mem_data = {byte4, byte3, byte2, byte1};
                endcase
            end

            default : mem_data = {byte4, byte3, byte2, byte1};

        endcase
        /* verilator lint_on ALWCOMBORDER */
    end

endmodule
