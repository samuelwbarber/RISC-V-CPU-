`include "include/ControlTypeDefs.svh"
module ControlPathD(
  input  logic [31:0]        iInstruction,

  output InstructionTypes    oInstructionType,
  output InstructionSubTypes oInstructionSubType,
  output logic [31:0]        oImmExt,

  output logic [ 3:0]        oAluControl,  
  output logic [ 2:0]        oResultSrc,
  output logic               oAluSrc,
  output logic               oMemWrite,
  output logic               oRegWrite,  
  
  output logic [ 4:0]        oRs1,
  output logic [ 4:0]        oRs2,
  output logic [ 4:0]        oRd
);

/////////////////////////////////////////////////////////
////      Internal Logic - OpCode, funct3, funct7    ////
/////////////////////////////////////////////////////////

  logic [6:0] op_code;
  logic [6:0] funct7;
  logic [2:0] funct3;


//////////////////////////////////////////////////////////////////////////////////////
////   Initialise Internal Logic and Output Source/Destination Register Addresses ////
//////////////////////////////////////////////////////////////////////////////////////

  always_comb begin
    op_code = iInstruction[6:0];
    funct7  = iInstruction[31:25];
    funct3  = iInstruction[14:12];

    oRs1 = iInstruction[19:15];
    oRs2 = iInstruction[24:20];
    oRd  = iInstruction[11:7];
  end

//////////////////////////////////////////////////////////////
////    Internal Logic - Instruction Type and Sub Type    ////
//////////////////////////////////////////////////////////////

  InstructionTypes instruction_type;
  InstructionSubTypes instruction_sub_type;


//////////////////////////////////////////////////
////          Instruction Decoder             ////
//////////////////////////////////////////////////

  /*
    This decoder is used to determine what instruction is currently executing
  */

InstructionDecode InstructionDecoder(
  .iOpCode(op_code),
  .iFunct3(funct3),
  .iFunct7(funct7),
  .oInstructionType(instruction_type),
  .oInstructionSubType(instruction_sub_type)
);

always_comb begin
  oInstructionType    = instruction_type;
  oInstructionSubType = instruction_sub_type;
end


//////////////////////////////////////////////////
////       Immediate Operand Decoder          ////
//////////////////////////////////////////////////

  /*
    This decoder is used to generate the sign extended Immediate Operand
  */

ImmDecode ImmediateOperandDecoder(
  .iInstructionType(instruction_type),
  .iInstructionSubType(instruction_sub_type),
  .iInstruction(iInstruction),
  .oImmExt(oImmExt)
);


/////////////////////////////////
///   Control Signal Decoder  ///
/////////////////////////////////

  /*
    This decoder is used to generate the various Src signals
  */

ControlDecode ControlSignalDecoder(
  .iInstructionType(instruction_type),
  .iInstructionSubType(instruction_sub_type),
  .oResultSrc(oResultSrc),
  .oAluSrc(oAluSrc),
  .oRegWrite(oRegWrite),
  .oMemWrite(oMemWrite)
);


/////////////////////////////////
///   Alu Operation Encoder   ///
/////////////////////////////////

  /*
    This component is used to generate a 4-bit control signal
    that tells the ALU what operation to perform
  */

AluEncode AluControlEncoder(
  .iInstructionType(instruction_type),
  .iInstructionSubType(instruction_sub_type),
  .oAluCtrl(oAluControl)
);


endmodule
