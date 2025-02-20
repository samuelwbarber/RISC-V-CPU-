`ifndef CONTROL_TYPE_DEFS_SVH //Header Guards - Prevent recursive inclusion
`define CONTROL_TYPE_DEFS_SVH
  typedef enum logic[3:0] { 
    BRANCH, 
    LOAD, 
    STORE, 
    UPPER, 
    IMM_COMPUTATION, 
    REG_COMMPUTATION, 
    JUMP,
    NULLINS = 4'b1111
  } InstructionTypes;

  typedef enum logic[3:0] {    
    ADD, 
    SUB, 
    SHIFT_LEFT_LOGICAL, 
    SET_LESS_THAN, 
    USET_LESS_THAN,  
    XOR,
    SHIFT_RIGHT_LOGICAL, 
    SHIFT_RIGHT_ARITHMETIC,   
    OR, 
    AND, 
    NULL_R = 4'b1111
  } TypeR;

  typedef enum logic [3:0] {   
    IMM_ADD,
    IMM_SHIFT_LEFT_LOGICAL = 2,
    IMM_SET_LESS_THAN, 
    IMM_USET_LESS_THAN, 
    IMM_XOR,
    IMM_SHIFT_RIGHT_LOGICAL, 
    IMM_SHIFT_RIGHT_ARITHMETIC,  
    IMM_OR, 
    IMM_AND,
    LOAD_BYTE, 
    LOAD_HALF, 
    LOAD_WORD, 
    ULOAD_BYTE, 
    ULOAD_HALF,  
    NULL_I = 4'b1111
  } TypeI;

  typedef enum logic[3:0] {
    ADD_UPPER_PC,
    LOAD_UPPER_IMM,
    NULL_U = 4'b1111
  } TypeU;

  typedef enum logic[3:0] {
    STORE_BYTE,
    STORE_HALF,
    STORE_WORD,
    NULL_S = 4'b1111
  } TypeS;

  typedef enum logic[3:0] {
    JUMP_LINK_REG,
    JUMP_LINK,
    NULL_J = 4'b1111
  } TypeJ;

  typedef enum logic[3:0] { 
    BEQ, 
    BNE, 
    BLT, 
    BGE, 
    BLTU, 
    BGEU, 
    NULL_B = 4'b1111
  } TypeB;

  typedef union packed{ 
    TypeR R;
    TypeI I;
    TypeU U;
    TypeS S;
    TypeJ J;
    TypeB B;
    logic [3:0] NULL;
  } InstructionSubTypes;

  typedef union packed{
    TypeR REG_COMPUTATION;
    TypeI IMM_COMPUTATION;
    logic [3:0] NULL;
  } AluOp;

`endif // CONTROL_TYPE_DEFS_SVH
