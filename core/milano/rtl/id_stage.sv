/***************************************
#
#			Filename:id_stage.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-29 15:41:06
#
***************************************/

module id_stage(
    input logic clk_i,
    input logic rst_ni,
    // from IF-ID pipeline register
    input logic [31:0] instr_rdata_i,   //instr data 
    // output to register file
    output logic [4:0] rs1_addr_o,      //source reg1 addr
    output logic [4:0] rs2_addr_o,      //source reg2 addr
    ////rd
    output logic [4:0] rd_addr_o,       //destination reg addr
    // output to alu
    ////imm
    output logic imm,
    ////opcode
    output logic [6:0] opcode,
    ////func
    output logic [2:0] funct3,          //fun3
    output logic [6:0] funct7,          //fun7
);
