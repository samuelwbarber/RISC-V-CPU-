`include "include/ControlTypeDefs.svh"
module InstructionDecode(
  input  logic [6:0]         iOpCode,
  input  logic [2:0]         iFunct3,
  input  logic [6:0]         iFunct7,

  output InstructionTypes    oInstructionType,
  output InstructionSubTypes oInstructionSubType
);

//////////////////////////////////////////////////
////   Internal Logic - Instruction Types   //////
//////////////////////////////////////////////////

  TypeR r_type;
  TypeI i_type;
  TypeU u_type;
  TypeS s_type;
  TypeJ j_type;
  TypeB b_type;

  InstructionTypes instruction_type;


/////////////////////////////////////////////////////////////////////////////////////////////
////   Logic To Determine Instruction Type and Sub Type Given OpCode, funct3, funct7   //////
/////////////////////////////////////////////////////////////////////////////////////////////

  always_comb begin

    case(iOpCode)

      7'd51 : begin
        instruction_type = REG_COMMPUTATION;
        
        i_type = NULL_I;
        u_type = NULL_U;
        s_type = NULL_S;
        j_type = NULL_J;
        b_type = NULL_B;
        
        case(iFunct3)

          3'b000  : begin
            if      (iFunct7 == 7'b0000000) r_type = ADD;
            else if (iFunct7 == 7'b0100000) r_type = SUB;
            else                            r_type = NULL_R;
          end

          3'b001  : r_type = SHIFT_LEFT_LOGICAL;
          3'b010  : r_type = SET_LESS_THAN;
          3'b011  : r_type = USET_LESS_THAN;
          3'b100  : r_type = XOR;
          
          3'b101  : begin
            if      (iFunct7 == 7'b0000000) r_type = SHIFT_RIGHT_LOGICAL;
            else if (iFunct7 == 7'b0100000) r_type = SHIFT_RIGHT_ARITHMETIC  ;
            else                            r_type = NULL_R;
          end

          3'b110  : r_type = OR;
          3'b111  : r_type = AND;    

        endcase
      end


      7'd19 : begin
        instruction_type = IMM_COMPUTATION;
        
        r_type = NULL_R;
        u_type = NULL_U;
        s_type = NULL_S;
        j_type = NULL_J;
        b_type = NULL_B;

        case(iFunct3)
          3'b000  : i_type = IMM_ADD;
          3'b001  : i_type = IMM_SHIFT_LEFT_LOGICAL;
          3'b010  : i_type = IMM_SET_LESS_THAN;
          3'b011  : i_type = IMM_USET_LESS_THAN;
          3'b100  : i_type = IMM_XOR;
          
          3'b101  : begin
            if      (iFunct7 == 7'b0000000) i_type = IMM_SHIFT_RIGHT_LOGICAL;
            else if (iFunct7 == 7'b0100000) i_type = IMM_SHIFT_RIGHT_ARITHMETIC  ;
            else                            i_type = NULL_I;
          end

          3'b110  : i_type = IMM_OR;
          3'b111  : i_type = IMM_AND;    
        endcase
      end


      7'd3 : begin
        instruction_type = LOAD;

        r_type = NULL_R;
        u_type = NULL_U;
        s_type = NULL_S;
        j_type = NULL_J;
        b_type = NULL_B;

        case(iFunct3)
          3'b000  : i_type = LOAD_BYTE;
          3'b001  : i_type = LOAD_HALF;
          3'b010  : i_type = LOAD_WORD;
          3'b100  : i_type = ULOAD_BYTE;
          3'b101  : i_type = ULOAD_HALF;     
          default : i_type = NULL_I;
        endcase
      end


      7'd23 : begin
        instruction_type = UPPER;

        j_type = NULL_J;
        r_type = NULL_R;
        i_type = NULL_I;
        u_type = ADD_UPPER_PC;
        s_type = NULL_S;
        b_type = NULL_B;
      end


      7'd55 : begin
        instruction_type = UPPER;

        u_type = LOAD_UPPER_IMM;
        r_type = NULL_R;
        i_type = NULL_I;
        s_type = NULL_S;
        j_type = NULL_J;
        b_type = NULL_B;
      end


      7'd103 : begin
        instruction_type = JUMP;

        j_type = JUMP_LINK_REG;
        r_type = NULL_R;
        u_type = NULL_U;
        i_type = NULL_I;
        s_type = NULL_S;
        b_type = NULL_B;
      end


      7'd111 : begin
        instruction_type = JUMP;

        j_type = JUMP_LINK;
        r_type = NULL_R;
        u_type = NULL_U;
        i_type = NULL_I;
        s_type = NULL_S;
        b_type = NULL_B;
      end


      7'd99 : begin
        instruction_type = BRANCH;

        r_type = NULL_R;
        u_type = NULL_U;
        i_type = NULL_I;
        s_type = NULL_S;
        j_type = NULL_J;

        case(iFunct3)
          3'b000  : b_type = BEQ;
          3'b001  : b_type = BNE;
          3'b100  : b_type = BLT;
          3'b101  : b_type = BGE;
          3'b110  : b_type = BLTU;
          3'b111  : b_type = BGEU;      
          default : b_type = NULL_B;
        endcase
      end


      7'd35 : begin
        instruction_type = STORE;

        r_type = NULL_R;
        u_type = NULL_U;
        i_type = NULL_I;
        j_type = NULL_J;
        b_type = NULL_B;
        
        case(iFunct3)
          3'b000  : s_type = STORE_BYTE;
          3'b001  : s_type = STORE_HALF;
          3'b010  : s_type = STORE_WORD;
          default : s_type = NULL_S;
        endcase
      end

      default : instruction_type = NULLINS;
    endcase
  end


/////////////////////////////////////////////////////////////
////       Assign Instruction Type and Sub Type        //////
/////////////////////////////////////////////////////////////

  always_comb begin

    case(instruction_type)
      REG_COMMPUTATION : oInstructionSubType.R    = r_type;
      IMM_COMPUTATION  : oInstructionSubType.I    = i_type;
      LOAD             : oInstructionSubType.I    = i_type;
      UPPER            : oInstructionSubType.U    = u_type;
      STORE            : oInstructionSubType.S    = s_type;
      JUMP             : oInstructionSubType.J    = j_type;
      BRANCH           : oInstructionSubType.B    = b_type;
      default          : oInstructionSubType.NULL = 4'b1111;
    endcase

    oInstructionType = instruction_type;
  end


endmodule
