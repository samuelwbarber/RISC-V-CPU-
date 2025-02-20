`include "include/ControlTypeDefs.svh"
module ControlDecode(
  input  InstructionTypes    iInstructionType,
  input  InstructionSubTypes iInstructionSubType,

  output logic    [2:0]      oResultSrc,
  output logic               oAluSrc,
  output logic               oRegWrite,
  output logic               oMemWrite
);

////////////////////////////////////////////////////////////////////////////////////////////////
//// Logic to Determine Src Signals Given Current Instruction executing and Zero Flag Value ////
////////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin

    //Initialise Output Signals
    oRegWrite   = 1'b0;
    oAluSrc     = 1'b0;
    oResultSrc  = 3'b000;
    oMemWrite   = 1'b0;

    case(iInstructionType)

      REG_COMMPUTATION : oRegWrite = 1'b1;


      IMM_COMPUTATION  : begin
        oRegWrite = 1'b1;
        oAluSrc   = 1'b1;
      end


      LOAD   : begin
        oRegWrite  = 1'b1;
        oResultSrc = 3'b001;
        oAluSrc = 1'b1;
      end


      UPPER  : begin
        if (iInstructionSubType == LOAD_UPPER_IMM) begin
          oRegWrite  = 1'b1;
          oAluSrc    = 1'b1;
          oResultSrc = 3'b011;
        end

        //Add Upper Immediate
        else begin
          oResultSrc = 3'b100; //Data written to register will come from the result selector 
        end
      end


      STORE  : begin
        oMemWrite = 1'b1;
        oAluSrc   = 1'b1;
      end


      JUMP   : begin
        oResultSrc = 3'b010;  //Store PC + 4 to destination reg
        oRegWrite  = 1'b1;    //Since we write PC+4 to destination for JAL
      end

      default : begin
        oRegWrite   = 1'b0;
        oAluSrc     = 1'b0;
        oResultSrc  = 3'b000;
        oMemWrite   = 1'b0;
      end

    endcase
  end

endmodule
