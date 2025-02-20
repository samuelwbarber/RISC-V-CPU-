module JumpBranchHandlerF(
  input  logic [31:0] iPCF,
  input  logic [31:0] iInstructionF,
  output logic [31:0] oJBTarget,
  output logic        oTakeJBF
);

  logic [31:0] branch_target;

  always_comb begin

    branch_target = iPCF + {{20{iInstructionF[31]}}, iInstructionF[7], iInstructionF[30:25], iInstructionF[11:8], 1'b0};
    
    if (iInstructionF[6:0] == 7'd99 & branch_target < iPCF) begin
      oTakeJBF   = 1'b1;
      oJBTarget  = branch_target; 
    end

    else if (iInstructionF[6:0] == 7'd111) begin
      oTakeJBF  = 1'b1;
      oJBTarget = iPCF + {{12{iInstructionF[31]}}, iInstructionF[19:12], iInstructionF[20], iInstructionF[30:21], 1'b0};
    end

    else begin
      oTakeJBF   = 1'b0;    
      oJBTarget  = 32'b0;
    end
  end

endmodule
