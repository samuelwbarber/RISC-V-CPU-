`include "include/ControlTypeDefs.svh"
module DPipelineRegisterE(
    input   logic                   iClk,
    input   logic                   iFlushE,

    input   InstructionTypes        iInstructionTypeD,
    input   InstructionSubTypes     iInstructionSubTypeD,
    input   logic [31:0]            iPCD, 
    input   logic [31:0]            iImmExtD,

    input   logic [ 2:0]            iResultSrcD,
    input   logic [ 3:0]            iAluControlD,
    input   logic                   iAluSrcD,

    input   logic [31:0]            iRegDataOut1D,
    input   logic [31:0]            iRegDataOut2D,
    input   logic [ 4:0]            iRs1D,
    input   logic [ 4:0]            iRs2D,
    input   logic [ 4:0]            iRdD,
    input   logic                   iRegWriteEnD,
    input   logic                   iMemWriteEnD,
    output  InstructionTypes    oInstructionTypeE,
    output  InstructionSubTypes oInstructionSubTypeE,
    output  logic [31:0]        oPCE,
    output  logic [31:0]        oImmExtE,

    output  logic [2:0]         oResultSrcE,
    output  logic [3:0]         oAluControlE,
    output  logic               oAluSrcE,

    output  logic [31:0]        oRegDataOut1E,
    output  logic [31:0]        oRegDataOut2E,
    output  logic [4:0]         oRs1E,
    output  logic [4:0]         oRs2E,
    output  logic [4:0]         oRdE,
    output  logic               oRegWriteEnE,
    output  logic               oMemWriteEnE
);

    always_ff @ (posedge iClk) begin
        if(iFlushE) begin
            // Reset all outputs to default values on flush
            oInstructionTypeE         <= NULLINS;
            oInstructionSubTypeE.NULL <= 4'b1111;
            oPCE                 <= 32'b0;
            oImmExtE             <= 32'b0;
            oResultSrcE          <= 3'b000;
            oAluControlE         <= 4'b1111;
            oAluSrcE             <= 1'b0;
            oRegDataOut1E        <= 32'b0;
            oRegDataOut2E        <= 32'b0;
            oRs1E                <= 5'b0;
            oRs2E                <= 5'b0;
            oRdE                 <= 5'b0;
            oRegWriteEnE         <= 1'b0;
            oMemWriteEnE         <= 1'b0;
        end 
        
        else begin

            // Transfer input values to outputs
            oInstructionTypeE    <= iInstructionTypeD;
            oInstructionSubTypeE <= iInstructionSubTypeD;
            oPCE                 <= iPCD;
            oImmExtE             <= iImmExtD;
            oResultSrcE          <= iResultSrcD;
            oAluControlE         <= iAluControlD;
            oAluSrcE             <= iAluSrcD;
            oRegDataOut1E        <= iRegDataOut1D;
            oRegDataOut2E        <= iRegDataOut2D;
            oRs1E                <= iRs1D;
            oRs2E                <= iRs2D;
            oRdE                 <= iRdD;
            oRegWriteEnE         <= iRegWriteEnD;
            oMemWriteEnE         <= iMemWriteEnD;
        end
    end
endmodule
