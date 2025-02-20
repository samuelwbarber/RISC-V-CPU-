module AluE #(
    parameter  OP_WIDTH = 4,
               DATA_WIDTH =32
)(
    input  logic [OP_WIDTH-1:0]     iAluControl /*verilator public*/,
    input  logic [DATA_WIDTH-1:0]   iAluOp1 /*verilator public*/,
    input  logic [DATA_WIDTH-1:0]   iAluOp2 /*verilator public*/,
    output logic [DATA_WIDTH-1:0]   oAluResult /*verilator public*/,

    output logic                    oZero 
);

////////////////////////////////
////      Internal Logic    ////
////////////////////////////////

    logic [DATA_WIDTH-1:0] out;


///////////////////////////////////////////////////////////////////////////////
////   Perform Operation Specified By iAluControl On iAluOp1 and iAluOp2   ////
///////////////////////////////////////////////////////////////////////////////

    always_comb begin

        //Init Output
        oAluResult = {DATA_WIDTH{1'b0}};

        case (iAluControl)

            4'b0000: out = iAluOp1 + iAluOp2;                                          //Addition
            4'b0001: out = iAluOp1 - iAluOp2;                                          //Subtraction
            4'b0010: out = iAluOp1 << iAluOp2;                                         //Left shift
            4'b0011: out = ($signed(iAluOp1)   >   $signed(iAluOp2))  ? 32'b0 : 32'b1; //Set less then
            4'b0100: out = ($unsigned(iAluOp1) > $unsigned(iAluOp2))  ? 32'b0 : 32'b1; //Unsigned set less than
            4'b0101: out = iAluOp1 ^ iAluOp2;                                          //XOR
            4'b0110: out = iAluOp1 >> iAluOp2;                                         //Right shift logical
            4'b0111: out = iAluOp1 >>> iAluOp2;                                        //Right shift arithmetic
            4'b1000: out = iAluOp1 | iAluOp2;                                          //OR
            4'b1001: out = iAluOp1 & iAluOp2;                                          //AND
            default: out = 32'd5;

        endcase

        //Result is 0
        if (out==32'b0) begin
            oZero      = 1'b1;
            oAluResult = 32'b0;
        end

        else begin
            oZero      = 1'b0;
            oAluResult = out;
        end

    end


endmodule
