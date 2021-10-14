/***************************************
#
#			Filename:decoder.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-27 22:22:20
#
***************************************/

`default_nettype none


module decoder(
    input   logic                   clk_i,
    input   logic                   rst_ni,

    // from IF-ID pipeline register
    input   logic   [31:0]          instr_rdata_i,   //instr data
    input   logic   [31:0]          instr_addr_i,    //instr addr

    // from register file
    input   logic   [31:0]          rs1_rdata_i,     //source reg1 read data
    input   logic   [31:0]          rs2_rdata_i,     //source reg2 read data

    // output to register file
    output  logic   [4:0]           rs1_addr_o,      //source reg1 addr
    output  logic   [4:0]           rs2_addr_o,      //source reg2 addr

    // output to ID-EX pipeline register
    output  logic   [31:0]          instr_addr_o,
    output  logic   [4:0]           rd_addr_o,       //destination reg addr
    output  logic                   rd_wr_en_o,      //destination reg write enable
    output  logic                   alu_sel_o,
    output  logic   [31:0]          operand_a_o,
    output  logic   [31:0]          operand_b_o,
    output  milano_pkg::alu_opt_e   alu_operate_o,
    output  logic                   lsu_we_o,
    output  logic                   lsu_req_o,
    output  milano_pkg::lsu_opt_e   lsu_operate_o,

    output  logic                   cond_jump_instr_o,
    //output  logic   [31:0]          jump_imm_o,
    output  milano_pkg::jump_opt_e  jump_operate_o

);
    import milano_pkg::*;
    opcode_e    opcode;
    logic [31:0] instr;
    logic [11:0] i_type_imm;
    logic [11:0] s_type_imm;
    logic [11:0] b_type_imm;
    logic [31:0] cond_jump_imm_ext;

    assign instr_addr_o = instr_addr_i;
    assign instr =  instr_rdata_i;
    assign i_type_imm = instr[31:20];
    assign s_type_imm = {instr[31:25],instr[11:7]};
    assign b_type_imm = {instr[30],instr[7],instr[30:25],instr[11:8]};
    assign cond_jump_imm_ext = {{19{b_type_imm[11]}},b_type_imm,1'b0}; 
//    assign rs1_addr_o      = instr[19:15];
//    assign rs2_addr_o      = instr[24:20];
//    assign funct           = function_e'({instr[31:25],instr[14:12]});
//    assign opcode       = instr_rdata_i[6:0];
//    assign rd_addr_o    = instr_rdata_i[11:7];
//    assign funct3       = instr_rdata_i[14:12];
//    assign rs1_addr_o   = instr_rdata_i[19:15];
//    assign rs2_addr_o   = instr_rdata_i[24:20];
//    assign funct7       = instr_rdata_i[31:25];  
    always_comb begin
        if(!rst_ni)begin
            rs1_addr_o          = 'h0;
            rs2_addr_o          = 'h0;
            operand_a_o         = 'h0;
            operand_b_o         = 'h0;
            alu_sel_o           = 'h0;
            alu_operate_o       = ALU_NONE;
            rd_addr_o           = 'h0;
            rd_wr_en_o          = 'h0;
            opcode              = OPCODE_DEFAULT;
            rd_wr_en_o          = 1'b0;
            lsu_we_o            = 1'b0;
            lsu_req_o           = 1'b0;
            lsu_operate_o       = LSU_NONE;

            cond_jump_instr_o   = 1'b0;
            //jump_imm_o          = 32'h0;
            jump_operate_o      = JUMP_NONE;
        end else begin
            opcode              = opcode_e'(instr[6:0]);
            rs1_addr_o          = instr[19:15];
            rs2_addr_o          = instr[24:20];
            alu_sel_o           = 'h0;
            operand_a_o         = 'h0;
            operand_b_o         = 'h0;
            alu_operate_o       = ALU_NONE;
            rd_addr_o           = instr[11:7];
            rd_wr_en_o          = 'h0;
            rd_wr_en_o          = 1'b0;
            lsu_we_o            = 1'b0;
            lsu_req_o           = 1'b0;
            lsu_operate_o       = LSU_NONE;

            cond_jump_instr_o   = 1'b0;
            //jump_imm_o          = 32'h0;
            jump_operate_o      = JUMP_NONE;
            unique case (opcode)
                OPCODE_OP : begin
                    operand_a_o = rs1_rdata_i;
                    operand_b_o = rs2_rdata_i;
                    rd_wr_en_o  = 1'b1;
                    alu_sel_o   = 1'b1;
                    unique case ({instr[31:25], instr[14:12]})  //funct7,funct3
                        {7'b000_0000, 3'b000}: alu_operate_o = ALU_ADD;
                        {7'b010_0000, 3'b000}: alu_operate_o = ALU_SUB;
                        {7'b000_0000, 3'b100}: alu_operate_o = ALU_XOR;
                        {7'b000_0000, 3'b110}: alu_operate_o = ALU_OR;
                        {7'b000_0000, 3'b111}: alu_operate_o = ALU_AND;
                        {7'b000_0000, 3'b001}: alu_operate_o = ALU_SLL;
                        {7'b000_0000, 3'b101}: alu_operate_o = ALU_SRL;
                        {7'b010_0000, 3'b101}: alu_operate_o = ALU_SRA;
                        {7'b000_0000, 3'b010}: alu_operate_o = ALU_SLT;
                        {7'b000_0000, 3'b011}: alu_operate_o = ALU_SLTU;
                        default: ;
                    endcase
                end
                OPCODE_OP_IMM : begin
                    operand_a_o = rs1_rdata_i;
                    operand_b_o = {{20{i_type_imm[11]}},i_type_imm};
                    rd_wr_en_o  = 1'b1;
                    alu_sel_o   = 1'b1;
                    unique case (instr[14:12])                      //funct3
                        3'b000 : alu_operate_o = ALU_ADD;           //ADDI
                        3'b100 : alu_operate_o = ALU_XOR;           //XORI
                        3'b110 : alu_operate_o = ALU_OR;            //ORI
                        3'b111 : alu_operate_o = ALU_AND;           //ANDI
                        3'b001 : if (instr[31:25]==7'h00) alu_operate_o = ALU_SLL;        //SLLI
                        3'b101 : if (instr[31:25]==7'h00) begin 
                                    alu_operate_o = ALU_SRL;        //SRLI
                                 end else if (instr[31:25]==7'h20) begin 
                                    alu_operate_o = ALU_SRA;        //SRAI
                                 end
                        3'b010 : alu_operate_o = ALU_SLT;           //SLTI
                        3'b011 : alu_operate_o = ALU_SLTU;          //SLTUI
                        default: ;
                    endcase
                end
                OPCODE_LOAD : begin
                    operand_a_o = rs1_rdata_i;
                    operand_b_o = {{20{i_type_imm[11]}},i_type_imm};
                    alu_sel_o   = 1'b0; 
                    rd_wr_en_o  = 1'b1;
                    lsu_we_o    = 1'b0;
                    lsu_req_o   = 1'b1;
                    unique case (instr[14:12]) 
                        3'b000 : lsu_operate_o = LSU_LB;        //LB
                        3'b001 : lsu_operate_o = LSU_LH;        //LH
                        3'b010 : lsu_operate_o = LSU_LW;        //LW
                        3'b100 : lsu_operate_o = LSU_LBU;       //LB(U)
                        3'b101 : lsu_operate_o = LSU_LHU;       //LH(U)
                        default: ;
                    endcase
                end
                OPCODE_STORE : begin
                    operand_a_o = rs1_rdata_i;
                    operand_b_o = {{20{s_type_imm[11]}},s_type_imm};
                    alu_sel_o   = 1'b0;
                    rd_wr_en_o  = 1'b0;
                    lsu_we_o    = 1'b1;
                    lsu_req_o   = 1'b1;
                    unique case (instr[14:12]) 
                        3'b000 : lsu_operate_o = LSU_SB;        //SB
                        3'b001 : lsu_operate_o = LSU_SH;        //SH
                        3'b010 : lsu_operate_o = LSU_SW;        //SW
                        default: ;
                    endcase
                end
                OPCODE_BRANCH : begin

                    operand_a_o = instr_addr_i;
                    operand_a_o = cond_jump_imm_ext;
                    cond_jump_instr_o= 1'b1;
                    //jump_imm_o  ={{19{b_type_imm[11]}},b_type_imm,1'b0};
                    unique case (instr[14:12])
                        3'b000 : jump_operate_o = JUMP_BEQ;
                        3'b001 : jump_operate_o = JUMP_BNE;
                        3'b100 : jump_operate_o = JUMP_BLT;
                        3'b101 : jump_operate_o = JUMP_BGE;
                        3'b110 : jump_operate_o = JUMP_BLTU;
                        3'b111 : jump_operate_o = JUMP_BGEU;
                        default: ;
                    endcase
                end
                default: ;
            endcase
        end
    end
endmodule

