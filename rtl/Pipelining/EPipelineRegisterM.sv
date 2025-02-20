`include "include/ControlTypeDefs.svh"
module EPipelineRegisterM(
    input   logic               iClk,
    //input   logic               iFlushE,
    input   InstructionTypes    iInstructionTypeE,
    input   InstructionSubTypes iInstructionSubTypeE,
    input   logic [31:0]        iPCE,
    input   logic [31:0]        iImmExtE,

    input   logic [31:0]        iAluOutE,
    input   logic [31:0]        iMemDataInE,
    input   logic [4:0]         iDestRegE,
    input   logic [2:0]         iResultSrcE,
    input   logic               iRegWriteEnE,
    input   logic               iMemWriteEnE,

    output  InstructionTypes    oInstructionTypeM,
    output  InstructionSubTypes oInstructionSubTypeM,
    output  logic [31:0]        oPCM,
    output  logic [31:0]        oImmExtM,

    output  logic [31:0]        oAluOutM,
    output  logic [31:0]        oMemDataInM,
    output  logic [4:0]         oDestRegM,
    output  logic [2:0]         oResultSrcM,
    output  logic               oRegWriteEnM,
    output  logic               oMemWriteEnM
);

    always_ff @ (posedge iClk) begin 

        /*if (iFlushE) begin
            oInstructionTypeM    <= NULLINS;
            oInstructionSubTypeM.NULL <= 4'b1111;
            oPCM                 <= 32'b0;
            oImmExtM             <= 32'b0;
            oAluOutM             <= 32'b0;
            oMemDataInM          <= 32'b0;
            oDestRegM            <= 5'b0;
            oResultSrcM          <= 3'b0;
            oRegWriteEnM         <= 1'b0;
            oMemWriteEnM         <= 1'b0;
        end*/

        //else begin
            oInstructionTypeM    <= iInstructionTypeE;
            oInstructionSubTypeM <= iInstructionSubTypeE;
            oPCM                 <= iPCE;
            oImmExtM             <= iImmExtE;
            oAluOutM             <= iAluOutE;
            oMemDataInM          <= iMemDataInE;
            oDestRegM            <= iDestRegE;
            oResultSrcM          <= iResultSrcE;
            oRegWriteEnM         <= iRegWriteEnE;
            oMemWriteEnM         <= iMemWriteEnE;
        //end

    end
    
endmodule
