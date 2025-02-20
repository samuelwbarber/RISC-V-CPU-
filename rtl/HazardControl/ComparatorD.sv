`include "include/ControlTypeDefs.svh"
module ComparatorD(
  input  InstructionTypes    iInstructionTypeD,
  input  InstructionSubTypes iJBTypeD,
  input  logic [31:0]        iRegData1D,
  input  logic [31:0]        iRegData2D,
  input  logic               iTakeJBD,
  output logic               oRecoverPC,
  output logic               oFlushD,
  output logic               oPCSrcD
);

always_comb begin

  case(iInstructionTypeD)

    BRANCH : begin

      case(iJBTypeD)

        BEQ : begin

          if      (iRegData1D == iRegData2D & iTakeJBD == 1'b0) begin // If registers are equal and we didnt take the branch
            oPCSrcD    = 1'b1;
            oFlushD    = 1'b1; //note that flushd = pcsrcd
            oRecoverPC = 1'b0; 
          end 

          else if (iRegData1D != iRegData2D & iTakeJBD == 1'b1) begin // If registers aren't equal and we did take the branch
            oPCSrcD    = 1'b1;
            oFlushD    = 1'b1;
            oRecoverPC = 1'b1; //If we have branched when we were not supposed to -> must recover PC of instruction after BEQ
          end

          else begin //This covers the registers being equal and branch being taken or registers being not equal and branch not taken
            oPCSrcD    = 1'b0;
            oFlushD    = 1'b0;
            oRecoverPC = 1'b0;
          end
          
        end

        BNE : begin

          if      (iRegData1D != iRegData2D & iTakeJBD == 1'b0) begin // If registers arent equal and we didnt take the branch
            oPCSrcD    = 1'b1;
            oFlushD    = 1'b1;
            oRecoverPC = 1'b0;
          end 

          else if (iRegData1D == iRegData2D & iTakeJBD == 1'b1) begin // If registers are equal and we did take the branch
            oPCSrcD    = 1'b1;
            oFlushD    = 1'b1;
            oRecoverPC = 1'b1;
          end

          else begin //This covers the registers being equal and branch not being taken or registers being not equal and branch taken
            oPCSrcD    = 1'b0;
            oFlushD    = 1'b0;
            oRecoverPC = 1'b0;
          end

        end

        default : begin
            oPCSrcD    = 1'b0;
            oFlushD    = 1'b0;
            oRecoverPC = 1'b0;
        end

      endcase
    end

    JUMP : begin

      case(iJBTypeD)

        JUMP_LINK_REG : begin
          oPCSrcD    = 1'b1;
          oFlushD    = 1'b1;
          oRecoverPC = 1'b0;
        end

        default : begin
          oPCSrcD    = 1'b0;
          oFlushD    = 1'b0;
          oRecoverPC = 1'b0;
        end

      endcase
    end

    default : begin
      oPCSrcD    = 1'b0;
      oFlushD    = 1'b0;
      oRecoverPC = 1'b0;
    end

  endcase
end

endmodule
