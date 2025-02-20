module ResultMuxW(
  input  logic [2:0]  iResultSrcW,
  input  logic [31:0] iMemDataOutW,
  input  logic [31:0] iAluResultW,
  input  logic [31:0] iPCW,
  input  logic [31:0] iUpperImmW,

  output logic [31:0] oRegDataInW
);

  always_comb begin
    case(iResultSrcW)
      3'b000   : oRegDataInW = iAluResultW;       // Alu Operation
      3'b001   : oRegDataInW = iMemDataOutW;      // Memory Read Operation (Load)
      3'b010   : oRegDataInW = iPCW + 32'd4;      // Jumps 
      3'b011   : oRegDataInW = iUpperImmW;        // Load Upper Immediate
      3'b100   : oRegDataInW = iPCW + iUpperImmW;  // Add Upper Immediate To PC
      default  : oRegDataInW = iAluResultW;       // Default - Alu Operation
    endcase
  end

endmodule
