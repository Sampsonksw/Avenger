package milano_pkg;
/////////////
// Opcodes //
/////////////

typedef enum logic [6:0] {
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

typedef enum logic [9:0] {
  ALU_ADD,
  ALU_SUB

} alu_opt_e;

endpackage
