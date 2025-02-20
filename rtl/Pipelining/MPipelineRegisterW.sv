module MPipelineRegisterW(
    input   logic        iClk,
    input   logic [31:0] iPCM,
    input   logic [31:0] iImmExtM,
    input   logic [31:0] iMemDataOutM,
    input   logic [31:0] iAluOutM,
    input   logic [ 4:0] iDestRegM,
    input   logic [ 2:0] iResultSrcM,
    input   logic        iRegWriteEnM,

    output  logic [31:0] oPCW,
    output  logic [31:0] oImmExtW,
    output  logic [31:0] oMemDataOutW,
    output  logic [31:0] oAluOutW,
    output  logic [4:0]  oDestRegW,
    output  logic [ 2:0] oResultSrcW,
    output  logic        oRegWriteEnW
);
  
    always_ff @ (posedge iClk) begin 
        oPCW         <= iPCM;
        oImmExtW     <= iImmExtM;
        oMemDataOutW <= iMemDataOutM;
        oAluOutW     <= iAluOutM;
        oDestRegW    <= iDestRegM;
        oResultSrcW  <= iResultSrcM;
        oRegWriteEnW <= iRegWriteEnM;
    end
    
endmodule
