/***************************************
#
#			Filename:id_ex_reg.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-27 22:15:35
#
***************************************/

`default_nettype none


module id_ex_reg(
    input   logic                   clk_i               ,
    input   logic                   rst_ni              ,
    input   logic                   stall_from_ctrl_i   ,
    //from decoder
    input   logic   [31:0]          instr_addr_i        ,
    input   logic   [4:0]           rd_addr_i           ,
    input   logic                   rd_wr_en_i          ,
    input   logic                   alu_sel_i           ,
    input   logic                   md_sel_i            ,
    input   logic   [31:0]          rs1_rdata_i         ,
    input   logic   [31:0]          rs2_rdata_i         ,
    input   logic   [31:0]          alu_operand_a_i     ,
    input   logic   [31:0]          alu_operand_b_i     ,
    input   milano_pkg::alu_opt_e   alu_operate_i       ,
    input   logic   [31:0]          md_operand_a_i      ,
    input   logic   [31:0]          md_operand_b_i      ,
    input   milano_pkg::md_opt_e    md_operate_i        ,
    input   logic                   lsu_we_i            ,
    input   logic                   lsu_req_i           ,
    input   milano_pkg::lsu_opt_e   lsu_operate_i       ,
    input   logic                   cond_jump_instr_i   ,
    input   logic   [31:0]          jump_imm_i          ,
    input   milano_pkg::jump_opt_e  jump_operate_i      ,
    input   logic                   csr_wr_en_i         ,
    input   logic   [11:0]          csr_addr_i          ,
    input   logic                   csr_sel_i           ,
    input   logic   [31:0]          csr_rdata_temp_i    ,
    input   logic   [31:0]          csr_imm_i           ,
    input   milano_pkg::csr_opt_e   csr_operate_i       ,
    
    //to EX
    output  logic   [31:0]          instr_addr_ex_o     ,
    output  logic   [4:0]           rd_addr_ex_o        ,
    output  logic                   rd_wr_en_ex_o       ,
    output  logic                   alu_sel_ex_o        ,
    output  logic                   md_sel_ex_o         ,
    output  logic   [31:0]          rs1_rdata_ex_o      ,
    output  logic   [31:0]          rs2_rdata_ex_o      ,
    output  logic   [31:0]          alu_operand_a_ex_o  ,
    output  logic   [31:0]          alu_operand_b_ex_o  ,
    output  milano_pkg::alu_opt_e   alu_operate_ex_o    ,
    output  logic   [31:0]          md_operand_a_ex_o   ,
    output  logic   [31:0]          md_operand_b_ex_o   ,
    output  milano_pkg::md_opt_e    md_operate_ex_o     ,
    output  logic                   lsu_we_ex_o         ,
    output  logic                   lsu_req_ex_o        ,
    output  milano_pkg::lsu_opt_e   lsu_operate_ex_o    ,
    output  logic                   cond_jump_instr_ex_o,
    output  logic   [31:0]          jump_imm_ex_o       ,
    output  milano_pkg::jump_opt_e  jump_operate_ex_o   ,
    output  logic                   csr_wr_en_ex_o      ,
    output  logic   [11:0]          csr_addr_ex_o       ,
    output  logic                   csr_sel_ex_o        ,
    output  logic   [31:0]          csr_rdata_temp_ex_o ,
    output  logic   [31:0]          csr_imm_ex_o        ,
    output  milano_pkg::csr_opt_e   csr_operate_ex_o    

);
    import milano_pkg::*;
    always_ff @(posedge clk_i,negedge rst_ni)begin
        if (!rst_ni)begin
            instr_addr_ex_o         <= 32'h0;
            rd_addr_ex_o            <= 5'h0;
            rd_wr_en_ex_o           <= 1'h0;
            alu_sel_ex_o            <= 1'h0;
            md_sel_ex_o             <= 1'h0;
            rs1_rdata_ex_o          <= 32'h0;
            rs2_rdata_ex_o          <= 32'h0;
            alu_operand_a_ex_o      <= 32'h0;
            alu_operand_b_ex_o      <= 32'h0;
            alu_operate_ex_o        <= ALU_NONE;
            md_operand_a_ex_o       <= 32'h0;
            md_operand_b_ex_o       <= 32'h0;
            md_operate_ex_o         <= MD_OP_NONE;
            lsu_we_ex_o             <= 1'b0; 
            lsu_req_ex_o            <= 1'b0; 
            lsu_operate_ex_o        <= LSU_NONE;
            cond_jump_instr_ex_o    <= 1'h0;
            jump_imm_ex_o           <= 32'h0;
            jump_operate_ex_o       <= JUMP_NONE;
            csr_wr_en_ex_o          <= 1'h0;
            csr_addr_ex_o           <= 12'h0;
            csr_sel_ex_o            <= 1'h0;
            csr_rdata_temp_ex_o     <= 32'h0;
            csr_imm_ex_o            <= 32'h0;
            csr_operate_ex_o        <= CSR_NONE;
        end else if(stall_from_ctrl_i)begin
            instr_addr_ex_o         <= instr_addr_ex_o;         
            rd_addr_ex_o            <= rd_addr_ex_o;            
            rd_wr_en_ex_o           <= rd_wr_en_ex_o;           
            alu_sel_ex_o            <= alu_sel_ex_o;  
            md_sel_ex_o             <= md_sel_ex_o;
            rs1_rdata_ex_o          <= rs1_rdata_ex_o;          
            rs2_rdata_ex_o          <= rs2_rdata_ex_o;          
            alu_operand_a_ex_o      <= alu_operand_a_ex_o;      
            alu_operand_b_ex_o      <= alu_operand_b_ex_o;      
            alu_operate_ex_o        <= alu_operate_ex_o;        
            md_operand_a_ex_o       <= md_operand_a_ex_o;       
            md_operand_b_ex_o       <= md_operand_b_ex_o;       
            md_operate_ex_o         <= md_operate_ex_o;         
            lsu_we_ex_o             <= lsu_we_ex_o;             
            lsu_req_ex_o            <= lsu_req_ex_o;            
            lsu_operate_ex_o        <= lsu_operate_ex_o;        
            cond_jump_instr_ex_o    <= cond_jump_instr_ex_o;    
            jump_imm_ex_o           <= jump_imm_ex_o;           
            jump_operate_ex_o       <= jump_operate_ex_o;
            csr_wr_en_ex_o          <= csr_wr_en_ex_o;
            csr_addr_ex_o           <= csr_addr_ex_o;
            csr_sel_ex_o            <= csr_sel_ex_o;
            csr_rdata_temp_ex_o     <= csr_rdata_temp_ex_o;
            csr_imm_ex_o            <= csr_imm_ex_o;
            csr_operate_ex_o        <= csr_operate_ex_o;
        end else begin
            instr_addr_ex_o         <= instr_addr_i;
            rd_addr_ex_o            <= rd_addr_i;
            rd_wr_en_ex_o           <= rd_wr_en_i;
            alu_sel_ex_o            <= alu_sel_i;
            md_sel_ex_o             <= md_sel_i;
            rs1_rdata_ex_o          <= rs1_rdata_i;
            rs2_rdata_ex_o          <= rs2_rdata_i;
            alu_operand_a_ex_o      <= alu_operand_a_i;
            alu_operand_b_ex_o      <= alu_operand_b_i;
            alu_operate_ex_o        <= alu_operate_i;
            md_operand_a_ex_o       <= md_operand_a_i;
            md_operand_b_ex_o       <= md_operand_b_i;
            md_operate_ex_o         <= md_operate_i;
            lsu_we_ex_o             <= lsu_we_i ;
            lsu_req_ex_o            <= lsu_req_i ;
            lsu_operate_ex_o        <= lsu_operate_i;
            cond_jump_instr_ex_o    <= cond_jump_instr_i;
            jump_imm_ex_o           <= jump_imm_i;
            jump_operate_ex_o       <= jump_operate_i;
            csr_wr_en_ex_o          <= csr_wr_en_i;
            csr_addr_ex_o           <= csr_addr_i;
            csr_sel_ex_o            <= csr_sel_i;
            csr_rdata_temp_ex_o     <= csr_rdata_temp_i;
            csr_imm_ex_o            <= csr_imm_i;
            csr_operate_ex_o        <= csr_operate_i;
        end
    end

endmodule

