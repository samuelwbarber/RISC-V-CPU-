module PCAdderD(  
  input  InstructionTypes    iInstructionType,
  input  InstructionSubTypes iInstructionSubType,
  input  logic               iRecoverPCD,
  input  logic [31:0]        iPCD,
  input  logic [31:0]        iImmExt,
  input  logic [31:0]        iRegOffset,
  output logic [31:0]        oPCTarget
);

  logic [31:0] jb_target;

  always_comb begin
    case(iInstructionType)

      JUMP : begin
        if (iInstructionSubType == JUMP_LINK_REG) begin
          jb_target      = iImmExt + iRegOffset;  //Potential RAW hazard
          jb_target[0]   = 1'b0;
        end

        //No need to worry about alignment as iImmExt is already aligned for JAL and Branch instructions (from immdecode)
        else    jb_target = iPCD + iImmExt;  
      end

      BRANCH  : jb_target = iPCD + iImmExt;

      default : jb_target = iPCD + iImmExt;
      
    endcase

    oPCTarget = iRecoverPCD ? iPCD + 32'd4 : jb_target;

  end

endmodule
