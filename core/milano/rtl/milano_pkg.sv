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
  OPCODE_MISC_MEM = 7'h0f,//0001111, FENCE
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

typedef enum logic [3:0] {
  // Multiplier/divider
  MD_OP_MUL,
  MD_OP_MULH,
  MD_OP_MULSU,
  MD_OP_MULU,
  MD_OP_DIV,
  MD_OP_DIVU,
  MD_OP_REM,
  MD_OP_REMU,
  MD_OP_NONE
} md_opt_e;

typedef enum logic [3:0] {
  // Multiplier/divider
  CSR_RW,
  CSR_RS,
  CSR_RC,
  CSR_RWI,
  CSR_RSI,
  CSR_RCI,
  CSR_NONE
} csr_opt_e;

typedef enum logic [11:0] {
  // Machine information
  CSR_MHARTID   = 12'hF14,

  // Machine trap setup
  CSR_MSTATUS   = 12'h300,
  CSR_MISA      = 12'h301,
  CSR_MIE       = 12'h304,
  CSR_MTVEC     = 12'h305,
  
  // Machine trap handling
  CSR_MSCRATCH  = 12'h340,
  CSR_MEPC      = 12'h341,
  CSR_MCAUSE    = 12'h342,
  CSR_MTVAL     = 12'h343,
  CSR_MIP       = 12'h344,

  // Machine Counter/Timers
  CSR_MCYCLE    = 12'hB00,
  CSR_MINSTRET  = 12'hB02,
  CSR_MCYCLEH   = 12'hB80,
  CSR_MINSTRETH = 12'hB82
} csr_num_e;


// STATUS machine
typedef enum logic [3:0] {
    IDLE,
    EXCE,
    HANDLE,
    QUIT
} exce_hand_state_e;

typedef enum logic [3:0] {
    WR_IDLE,
    WR_MCAUSE,
    WR_MEPC,
    WR_MTVAL,
    WR_MSTATUS
} csr_ctrl_state_e;
endpackage
