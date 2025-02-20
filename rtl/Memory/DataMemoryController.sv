`include "include/ControlTypeDefs.svh"

module DataMemoryController #(
    parameter DATA_WIDTH = 32
 )(
    input  logic         iClk,
    input logic          iWriteEn,
    input InstructionTypes  iMemoryInstructionType, 
    input  InstructionTypes          iInstructionType,   
    input logic [DATA_WIDTH-1:0]   iAddress,
    input  logic [DATA_WIDTH-1:0]    iMemData,        // Write Data
    output logic [DATA_WIDTH-1:0]  oMemData, 
    //output logic [DATA_WIDTH-1:0]  oMemDatat,  
    output logic memt

);
logic [DATA_WIDTH-1:0] MemData;
logic [25:0] ATag;
logic [25:0] CTag;
logic [3:0]  AIndex;
logic [3:0]  FlushIndex;
logic CValid;
logic hit;
logic [DATA_WIDTH-1:0] iFlushAddress;
logic [DATA_WIDTH-1:0] cData; 
logic [DATA_WIDTH-1:0] mData;
/* verilator lint_off UNUSED */
logic [DATA_WIDTH-1:0] word_aligned_address;
/* verilator lint_on UNUSED */
logic [1:0] byte_offset;
logic [7:0] byte1;
logic [7:0] byte2;
logic [7:0] byte3;
logic [7:0] byte4;
logic [DATA_WIDTH-1:0] writeCache;

CacheDecode CacheDecode(
    .iAddress(iAddress),
    .iFlushAddress(iFlushAddress),
    .oIndexFlush(FlushIndex),
    .oTag(ATag),
    .oIndex(AIndex)
);

Cache Cache(
    .iIndex(AIndex),
    .iFlush(iWriteEn),
    .iAddress(iAddress),
    .iHit(hit),
    .iFlushAddress(FlushIndex),
    .iWriteCacheData(writeCache),
    .oTag(CTag),
    .oV(CValid),
    .oData(cData)
);

DataMemoryM DataMemoryM(
    .iClk(iClk),
    .iWriteEn(iWriteEn),
    .iInstructionType(iInstructionType),
    .iMemoryInstructionType(iMemoryInstructionType), 
    .iAddress(iAddress),
    .iMemData(iMemData),
    .oMemData(mData),
    .oWriteCache(writeCache)
);


FindHit FindHit(
    .iClk(iClk),
    .iV(CValid),
    .iTagCache(CTag),
    .iTagTarget(ATag),
    .iWriteEn(iWriteEn),
    .oHit(hit)
);

always_latch begin

    if (iWriteEn==1) begin
        iFlushAddress = iAddress;
    end
        
end

always_comb begin
    word_aligned_address = {{iAddress[31:2]}, {2'b00}};                 //Word aligned address -> multiple of 4
    byte_offset          = iAddress[1:0];                               //2 LSBs of iAddress define byte offset within the word
    byte4 =   cData[31:24];
    byte3 =   cData[23:16];
    byte2 =   cData[15:8];
    byte1 =   cData[7:0];
    case(iMemoryInstructionType)
        LOAD_BYTE  : begin

            case (byte_offset) 
                2'b00 : MemData[7:0] = byte1;
                2'b01 : MemData[7:0] = byte2;
                2'b10 : MemData[7:0] = byte3;
                2'b11 : MemData[7:0] = byte4;
            endcase

            MemData[31:8] = {24{MemData[7]}}; //sign extend
        end

        LOAD_HALF  : begin

            case (byte_offset) 
                2'b00 : MemData[15:0] = {byte2, byte1};
                2'b01 : MemData[15:0] = {byte3, byte2};
                2'b10 : MemData[15:0] = {byte4, byte3};
                2'b11 : MemData[15:0] = {byte4, byte3};
            endcase
                    
            MemData[31:16] = {16{MemData[15]}}; //sign extend
        end

        ULOAD_BYTE : begin            

            case (byte_offset) 
                2'b00 : MemData[7:0] = byte1;
                2'b01 : MemData[7:0] = byte2;
                2'b10 : MemData[7:0] = byte3;
                2'b11 : MemData[7:0] = byte4;
            endcase

            MemData[31:8] = {24{1'b0}}; //zero extend

        end

        ULOAD_HALF : begin

            case (byte_offset) 
                2'b00 : MemData[15:0] = {byte2, byte1};
                2'b01 : MemData[15:0] = {byte3, byte2};
                2'b10 : MemData[15:0] = {byte4, byte3};
                2'b11 : MemData[15:0] = {byte4, byte3};
            endcase

            MemData[31:16] = {16{1'b0}}; //Zero extend

        end

        LOAD_WORD  : begin
            MemData = {byte4, byte3, byte2, byte1};             
        end
        default    : begin 
            MemData = {byte4, byte3, byte2, byte1};
        end
    endcase
end

always_ff @(negedge iClk) begin
    if (hit==1 && iWriteEn==0) begin
        oMemData<=MemData;
    end
    else if (iWriteEn==0) begin
        oMemData <= mData;
        memt=memt+1;
    end   
end
endmodule


