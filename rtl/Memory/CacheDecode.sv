module CacheDecode (
    /* verilator lint_off UNUSED */
    input  logic [31:0] iAddress,
    input logic [31:0] iFlushAddress,
    /* verilator lint_on UNUSED */
    output logic [3:0] oIndexFlush,
    output logic [25:0] oTag,
    output logic [3:0] oIndex
);
//////////////////////////////////////////////
////       Decodes address and flush      ////
//////////////////////////////////////////////
always_comb begin

    oTag =iAddress[31:6];
    oIndex = iAddress[5:2];
    oIndexFlush = iFlushAddress[5:2];
    
end
endmodule
