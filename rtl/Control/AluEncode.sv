`include "include/ControlTypeDefs.svh"
module AluEncode(
  input  InstructionTypes    iInstructionType,
  input  InstructionSubTypes iInstructionSubType,

  output AluOp               oAluCtrl
);

  always_comb begin
    case(iInstructionType)

      REG_COMMPUTATION : oAluCtrl.REG_COMPUTATION  = iInstructionSubType.R; 
      IMM_COMPUTATION  : oAluCtrl.IMM_COMPUTATION  = iInstructionSubType.I;
      STORE            : oAluCtrl.IMM_COMPUTATION  = IMM_ADD; 
      LOAD             : oAluCtrl.IMM_COMPUTATION  = IMM_ADD;
      BRANCH           : oAluCtrl.NULL  = 4'b1111;        //Comparator now compares reg
      JUMP             : oAluCtrl.NULL = 4'b1111;
      UPPER            : oAluCtrl.NULL = 4'b1111;
      default          : oAluCtrl.NULL = 4'b1111;

    endcase
  end

endmodule
