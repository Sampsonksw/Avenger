/***************************************
#
#			Filename:alu.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-10-01 15:09:11
#
***************************************/

`default_nettype none


module alu(
    input   logic                       rst_ni          ,
    input   milano_pkg::alu_opt_e       operate_i       ,
    input   logic   [31:0]              operand_a_i     ,
    input   logic   [31:0]              operand_b_i     ,
    input   logic   [4:0]               rd_addr_i       ,
    input   logic                       rd_we_i         ,
    output  logic                       alu_rd_we_o     ,
    output  logic   [4:0]               alu_rd_waddr_o  ,
    output  logic   [31:0]              alu_rd_wdata_o  ,
    output  logic   [31:0]              add_op_a_op_b
);
    import milano_pkg::*;
    //temp alu result
    //logic [31:0] add_op_a_op_b;
    logic [31:0] sub_op_a_op_b;
    logic [31:0] xor_op_a_op_b;
    logic [31:0] or_op_a_op_b;
    logic [31:0] and_op_a_op_b;
    logic [31:0] sll_op_a_op_b;
    logic [31:0] srl_op_a_op_b;
    logic [31:0] sra_op_a_op_b;
    logic [31:0] slt_op_a_op_b;
    logic [31:0] sltu_op_a_op_b;
    logic [31:0] mask_sr_shift; 
    assign mask_sr_shift= (32'hffff) >> operand_b_i;

    assign add_op_a_op_b = operand_a_i + operand_b_i;
    assign sub_op_a_op_b = operand_a_i - operand_b_i;
    assign xor_op_a_op_b = operand_a_i ^ operand_b_i;
    assign or_op_a_op_b  = operand_a_i | operand_b_i;
    assign and_op_a_op_b = operand_a_i & operand_b_i;
    assign sll_op_a_op_b = operand_a_i << operand_b_i[4:0];
    assign srl_op_a_op_b = operand_a_i >> operand_b_i[4:0];
    assign sra_op_a_op_b = operand_a_i[31] ? ((srl_op_a_op_b)|(~mask_sr_shift&({32{operand_a_i[31]}}))) : srl_op_a_op_b;
    assign slt_op_a_op_b = ($signed(operand_a_i) < $signed(operand_b_i)) ? 32'h1 : 32'h0;
    assign sltu_op_a_op_b= (operand_a_i < operand_b_i)? 32'h1 : 32'h0;
    //assign slt_op_a_op_b = (operand_a_i[31] ^ operand_b_i[31]) ? (operand_a_i[31] ? 32'h1 : 32'h0) : sltu_op_a_op_b;

    always_comb begin
        if(!rst_ni)begin
            alu_rd_we_o    =  1'h0;
            alu_rd_waddr_o   = 32'h0;
            alu_rd_wdata_o  = 32'h0;
        end else begin
            case(operate_i)
                ALU_ADD: begin
                    alu_rd_we_o = rd_we_i;
                    alu_rd_waddr_o=rd_addr_i;
                    alu_rd_wdata_o = add_op_a_op_b;
                end
                ALU_SUB: begin
                    alu_rd_we_o = rd_we_i;
                    alu_rd_waddr_o=rd_addr_i;
                    alu_rd_wdata_o = sub_op_a_op_b;
                end
                ALU_XOR: begin
                    alu_rd_we_o = rd_we_i;
                    alu_rd_waddr_o=rd_addr_i;
                    alu_rd_wdata_o = xor_op_a_op_b;
                end
                ALU_OR:  begin
                    alu_rd_we_o = rd_we_i;
                    alu_rd_waddr_o=rd_addr_i;
                    alu_rd_wdata_o = or_op_a_op_b;
                end
                ALU_AND: begin
                    alu_rd_we_o = rd_we_i;
                    alu_rd_waddr_o=rd_addr_i;
                    alu_rd_wdata_o = and_op_a_op_b;
                end
                ALU_SLL: begin      // Shfit Left Logic
                    alu_rd_we_o = rd_we_i;
                    alu_rd_waddr_o=rd_addr_i;
                    alu_rd_wdata_o = sll_op_a_op_b;
                end
                ALU_SRL: begin      // Shfit Right Logic
                    alu_rd_we_o = rd_we_i;
                    alu_rd_waddr_o=rd_addr_i;
                    alu_rd_wdata_o = srl_op_a_op_b;
                end
                ALU_SRA: begin      // Shfit Right Arithmatic
                    alu_rd_we_o = rd_we_i;
                    alu_rd_waddr_o=rd_addr_i;
                    alu_rd_wdata_o = sra_op_a_op_b;
                end
                ALU_SLT: begin      // Set Less Than
                    alu_rd_we_o = rd_we_i;
                    alu_rd_waddr_o=rd_addr_i;
                    alu_rd_wdata_o = slt_op_a_op_b;
                end
                ALU_SLTU: begin     // Set Less Than Unsigned
                    alu_rd_we_o = rd_we_i;
                    alu_rd_waddr_o=rd_addr_i;
                    alu_rd_wdata_o = sltu_op_a_op_b;
                end
                default: begin 
                end
            endcase
        end
    end
endmodule
