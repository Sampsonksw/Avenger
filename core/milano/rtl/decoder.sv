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
    input logic             clk_i,
    input logic             rst_ni,

    // from IF-ID pipeline register
    input logic [31:0]      instr_rdata_i,   //instr data
    input logic [31:0]      instr_addr_i,    //instr addr

    // from register file
    input logic [31:0]      rs1_rdata_i,     //source reg1 read data
    input logic [31:0]      rs2_rdata_i,     //source reg2 read data

    // output to register file
    output logic [4:0]      rs1_addr_o,      //source reg1 addr
    output logic [4:0]      rs2_addr_o,      //source reg2 addr

    // output to ID-EX pipeline register
    output logic [4:0]      rd_addr_o,       //destination reg addr
    output logic            rd_wr_en_o,      //destination reg write enable
    output logic [31:0]     rs1_data,
    output logic [31:0]     rs2_data,
    output milano_pkg::alu_opt_e alu_operate_o
);
    import milano_pkg::*;
    opcode_e    opcode;
    logic [31:0] instr;
    assign instr =  instr_rdata_i;
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
            rs1_addr_o      = 'h0;
            rs2_addr_o      = 'h0;
            rs1_data        = 'h0;
            rs2_data        = 'h0;
            alu_operate_o   = 'h0;
            rd_addr_o       = 'h0;
            rd_wr_en_o      = 'h0;
        end else begin
            opcode          = opcode_e'(instr[6:0]);
            rs1_addr_o      = instr[19:15];
            rs2_addr_o      = instr[24:20];
            rs1_data        = 'h0;
            rs2_data        = 'h0;
            alu_operate_o   = 'h0;
            rd_addr_o       = instr[11:7];
            rd_wr_en_o      = 'h0;
            unique case (opcode)
                OPCODE_OP : begin
                    rs1_data = rs1_rdata_i;
                    rs2_data = rs2_rdata_i;
                    //rd_addr_o = instr[11:7];
                    rd_wr_en_o= 1'b1;
                    unique case ({instr[31:25], instr[14:12]})
                        {7'b000_0000, 3'b000}: alu_operate_o = ALU_ADD;
                        {7'b010_0000, 3'b000}: alu_operate_o = ALU_SUB;
                        default: ;
                    endcase
                end
                default: ;
            endcase
    end
endmodule

