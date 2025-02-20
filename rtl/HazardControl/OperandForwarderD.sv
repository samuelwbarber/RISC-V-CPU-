module OperandForwarderD(
  input  logic [31:0] iRegData1D,
  input  logic [31:0] iRegData2D,
  input  logic [31:0] iAluResultOutM,
  input  logic        iCompOp1Select,
  input  logic        iCompOp2Select,
  input  logic        iForwardRegOffset,

  output logic [31:0] oCompOp1,
  output logic [31:0] oCompOp2,
  output logic [31:0] oRegOffset
);

  always_comb begin 
    oCompOp1   = iCompOp1Select ? iAluResultOutM : iRegData1D;
    oCompOp2   = iCompOp2Select ? iAluResultOutM : iRegData2D;
    oRegOffset = iForwardRegOffset ? iAluResultOutM : iRegData1D;
  end

endmodule
