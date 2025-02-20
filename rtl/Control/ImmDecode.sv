`include "include/ControlTypeDefs.svh"
module ImmDecode(
  input  InstructionTypes    iInstructionType,
  input  InstructionSubTypes iInstructionSubType,
  /* verilator lint_off UNUSED */
  input  logic [31:0]        iInstruction,
  /* verilator lint_on UNUSED */
  output logic [31:0]        oImmExt
);

/////////////////////////////////////////////////////////////////////////////////////////////
////   Logic To Determine Immediate Operand Given Instructino Type and Sub Type        //////
/////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin

    //Init Output
    oImmExt = {32{1'b0}};

    case(iInstructionType)
    
      IMM_COMPUTATION : begin      
        oImmExt[11:0]  = iInstruction[31:20];
        oImmExt[31:12] = {20{oImmExt[11]}};
      end

      LOAD : begin      
        oImmExt[11:0]  = iInstruction[31:20];
        oImmExt[31:12] = {20{oImmExt[11]}};
      end

      UPPER : begin
        oImmExt[11:0]  = {12{1'b0}};
        oImmExt[31:12] = iInstruction[31:12];
      end
  
      STORE : begin      
        oImmExt[4:0]   = iInstruction[11:7];
        oImmExt[11:5]  = iInstruction[31:25];
        oImmExt[31:12] = {20{oImmExt[11]}};
      end

      JUMP : begin
        if(iInstructionSubType == JUMP_LINK_REG) begin        
          oImmExt[11:0]  = iInstruction[31:20];
          oImmExt[31:12] = {20{oImmExt[11]}};
        end

        else begin
          oImmExt[0]      = 1'b0;    // Align address to be multiple of 2
          oImmExt[10:1]   = iInstruction[30:21];
          oImmExt[11]     = iInstruction[20];
          oImmExt[19:12]  = iInstruction[19:12];
          oImmExt[31:20]  = {12{iInstruction[31]}};
        end
      end

      BRANCH : begin      
        oImmExt[0]     = 1'b0;        // Align address to be multiple of 2 
        oImmExt[4:1]   = iInstruction[11:8];
        oImmExt[12:5]  = {iInstruction[31], iInstruction[7], iInstruction[30:25]};
        oImmExt[31:13] = {19{iInstruction[31]}};
      end

      default : oImmExt = {32{1'b0}}; //set imm20 to 0 by default
      
    endcase
  end


endmodule
