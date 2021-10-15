/***************************************
#
#			Filename:milano_pkg.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-10-01 12:07:56
#
***************************************/

package milano_pkg;
/////////////
// Opcodes //
/////////////

typedef enum logic [6:0] {
  OPCODE_DEFAULT  = 7'h00,
  OPCODE_LOAD     = 7'h03,//0000011, load  , I-type
  OPCODE_MISC_MEM = 7'h0f,//0001111
  OPCODE_OP_IMM   = 7'h13,//0010011, imm opt, I-type
  OPCODE_AUIPC    = 7'h17,//0010111, Add Upper Imm to PC, U-type
  OPCODE_STORE    = 7'h23,//0100011, store opt , S-type
  OPCODE_OP       = 7'h33,//0110011, Regitser to Register, R-type
  OPCODE_LUI      = 7'h37,//0110111, Load Upper Imm, U-type
  OPCODE_BRANCH   = 7'h63,//1100011, conditional Jump, B-type
  OPCODE_JALR     = 7'h67,//1100111, Jump link register, i-type
  OPCODE_JAL      = 7'h6f,//1101111, Unconditional jump, J-type
  OPCODE_SYSTEM   = 7'h73 //1110011, Environment Call/Break, I-type
} opcode_e;

typedef enum logic [5:0] {
  // Arithmetics
  ALU_ADD,
  ALU_SUB,
  // Logic
  ALU_XOR,
  ALU_OR,
  ALU_AND,
  // Shift
  ALU_SLL,
  ALU_SRL,
  ALU_SRA,
  // Set lower than
  ALU_SLT,
  ALU_SLTU,
  // AUIPC
  AUIPC,

  ALU_NONE        = 6'h3f

} alu_opt_e;

typedef enum logic [3:0] {
  // Load
  LSU_LW    , //4'b0010
  LSU_LH    , //4'b0001
  LSU_LB    , //4'b0000
  LSU_LBU   , //4'b0110
  LSU_LHU   , //4'b0101
  // Store
  LSU_SB    , //4'b
  LSU_SH    ,
  LSU_SW    ,


  LSU_NONE  

} lsu_opt_e;

typedef enum logic [3:0] {
  JUMP_BEQ  ,
  JUMP_BNE  ,
  JUMP_BLT  ,
  JUMP_BGE  ,
  JUMP_BLTU ,
  JUMP_BGEU ,
  JUMP_JAL  ,
  JUMP_JALR ,

  JUMP_NONE
} jump_opt_e;

endpackage
