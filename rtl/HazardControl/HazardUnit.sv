`include "include/ControlTypeDefs.svh"
module HazardUnit (  
  input  InstructionTypes    iInstructionTypeD,
  input  InstructionSubTypes iInstructionSubTypeD,
  input  InstructionTypes    iInstructionTypeE,
  input  InstructionTypes    iInstructionTypeM,

  input  logic [4:0]     iSrcReg1D,
  input  logic [4:0]     iSrcReg2D,

  input  logic [4:0]     iDestRegE,
  input  logic [4:0]     iSrcReg1E,
  input  logic [4:0]     iSrcReg2E,
  input  logic           iRegWriteEnE,

  input  logic [4:0]     iDestRegM,
  input  logic           iRegWriteEnM,

  input  logic [4:0]     iDestRegW,
  input  logic           iRegWriteEnW,

  output logic [1:0]     oForwardAluOp1E,
  output logic [1:0]     oForwardAluOp2E,
  output logic           oForwardRegOffsetD,
  output logic           oForwardCompOp1D,
  output logic           oForwardCompOp2D,
  output logic           oStallF,
  output logic           oStallD,
  output logic           oFlushE
);

/*TO DO :
  - RESOLVE LW HAZARDS AND BRANCHES
  - MAKE SURE LOGIC MAKES SENSE
*/

  always_comb begin
    
    oForwardAluOp1E    = 2'b00;
    oForwardAluOp2E    = 2'b00;
    oForwardCompOp1D   = 1'b0;
    oForwardCompOp2D   = 1'b0;
    oForwardRegOffsetD = 1'b0;
    oStallF            = 1'b0;
    oStallD            = 1'b0;
    oFlushE            = 1'b0;

    //---------------------------------Check For Load Data Dependancy------------------------
    if (iInstructionTypeE == LOAD) begin 
      if (iDestRegE == iSrcReg1D | iDestRegE == iSrcReg2D) begin //Load Dependancy Detected
        oStallF = 1'b1;
        oStallD = 1'b1;
        oFlushE = 1'b1; //If flush is high iSrcReg1E and iSrcReg2E would be both 0 in the next clock cycle
      end  // Important for forwarding load value to execution stage - if reg wasnt flushed, there may be a chance that the statements following this (that compute what to forward) may end up forwarding the wrong thing since decode and fetch are stalled and execution stage holds values for the load instruction
    end


    //-------------------- Handle RAW Data Hazard Due To Branch Instructions-----------------
    if (iInstructionTypeD == BRANCH | (iInstructionTypeD == JUMP & iInstructionSubTypeD ==JUMP_LINK_REG)) begin

      if ((iSrcReg1D != 5'b0 & iRegWriteEnM) & iDestRegM == iSrcReg1D)  begin

        if (iInstructionTypeM != LOAD) begin

          if (iInstructionTypeD == BRANCH) oForwardCompOp1D   = 1'b1;
          else                             oForwardRegOffsetD = 1'b1; //For JALR register offset
        
        end

        else begin
          oStallF = 1'b1;
          oStallD = 1'b1;
          oFlushE = 1'b1;
        end

      end 

      else                             oForwardCompOp1D = 1'b0;
      

      if ((iSrcReg2D != 5'b0 & iRegWriteEnM) & iDestRegM == iSrcReg2D)  begin

        if (iInstructionTypeM != LOAD) oForwardCompOp2D = 1'b1;

        else begin
          oStallF = 1'b1;
          oStallD = 1'b1;
          oFlushE = 1'b1;
        end
      end

      else                             oForwardCompOp2D = 1'b0;

      if ((iDestRegE != 5'b0 & iRegWriteEnE) & (iDestRegE == iSrcReg1D | iDestRegE == iSrcReg2D)) begin
        oStallF          = 1'b1; 
        oStallF          = 1'b1;
        oStallD          = 1'b1;
        oFlushE          = 1'b1;
        oForwardCompOp1D = 1'b0;
        oForwardCompOp2D = 1'b0;
      end

    end

    //-------------------- Handle RAW Data Hazard Due To Other Instructions-----------------

    if (iInstructionTypeE != BRANCH) begin
      //If destination register in memory stage is the same as source1 register in execution stage
      if      (iSrcReg1E != 5'b0 & iRegWriteEnM & iDestRegM == iSrcReg1E) begin
        if (iInstructionTypeM != UPPER) oForwardAluOp1E = 2'b01;
        else                            oForwardAluOp1E = 2'b11;    //Forward writeback value to execution stage
      end

      else if (iSrcReg1E != 5'b0 & iRegWriteEnW & iDestRegW == iSrcReg1E) begin
        if (iInstructionTypeM != UPPER) oForwardAluOp1E = 2'b10;
        else                            oForwardAluOp1E = 2'b11; 
      end

      else                              oForwardAluOp1E = 2'b00;    //If there is no data dependancy hazard for source register 1

      //If destination register in memory stage is the same as source2 register in execution stage
      if      (iSrcReg2E != 5'b0 & iRegWriteEnM & iDestRegM == iSrcReg2E) oForwardAluOp2E = 2'b01;     //Forward data in memory stage to execution stage
      else if (iSrcReg2E != 5'b0 & iRegWriteEnW & iDestRegW == iSrcReg2E) oForwardAluOp2E = 2'b10;     //Forward writeback value to execution stage
      else                                                                oForwardAluOp2E = 2'b00;     //If there is no data dependancy hazard for source register 2
    end


  end


endmodule
