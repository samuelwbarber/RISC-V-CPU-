module ResultMux(
  input  logic        iMemToRegW,
  input  logic [31:0] iReadDataW,
  input  logic [31:0] iALUOutW,

  output logic [31:0] oResultW
);

  always_comb begin
    if(iMemToRegW) oResultW = iReadDataW;       // Memory Read Operation (Load)
    else oResultW  =  iALUOutW;                 // Alu Operation
  end

endmodule
