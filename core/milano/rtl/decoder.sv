/***************************************
#
#			Filename:decoder.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-27 22:22:20
#
***************************************/
module decoder(
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
    //output logic [6:0] opcode,
    ////func
    output logic [2:0] funct3,          //fun3
    output logic [6:0] funct7,          //fun7

);
    import milano_pkg::*;
    logic [31:0] instr =  instr_rdata_i;
    opcode_e    opcode;

    assign opcode       = instr_rdata_i[6:0];
    assign rd_addr_o    = instr_rdata_i[11:7];
    assign funct3       = instr_rdata_i[14:12];
    assign rs1_addr_o   = instr_rdata_i[19:15];
    assign rs2_addr_o   = instr_rdata_i[24:20];
    assign funct7       = instr_rdata_i[25:31];
//  assign imm
    always_comb begin
        opcode          = opcode_e'(instr[6:0]);
        case (opcode)
            OPCODE_OP : begin


endmodule
