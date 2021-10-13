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
    input   logic                   clk_i           ,
    input   logic                   rst_ni          ,
    //from decoder
    input   logic   [4:0]           rd_addr_i       ,
    input   logic                   rd_wr_en_i      ,
    input   logic                   alu_sel_i       ,
    input   logic   [31:0]          operand_a_i     ,
    input   logic   [31:0]          operand_b_i     ,
    input   milano_pkg::alu_opt_e   alu_operate_i   ,
    input   logic                   lsu_we_i        ,
    input   logic                   lsu_req_i       ,
    input   milano_pkg::lsu_opt_e   lsu_operate_i   ,
    //to EX
    output  logic   [4:0]           rd_addr_ex_o    ,
    output  logic                   rd_wr_en_ex_o   ,
    output  logic                   alu_sel_ex_o    ,
    output  logic   [31:0]          operand_a_ex_o  ,
    output  logic   [31:0]          operand_b_ex_o  ,
    output  milano_pkg::alu_opt_e   alu_operate_ex_o,
    output  logic                   lsu_we_ex_o     ,
    output  logic                   lsu_req_ex_o    ,
    output  milano_pkg::lsu_opt_e   lsu_operate_ex_o   


);
    import milano_pkg::*;
    always_ff @(posedge clk_i,negedge rst_ni)begin
        if (!rst_ni)begin
            rd_addr_ex_o    <= 5'h0;
            rd_wr_en_ex_o   <= 1'h0;
            alu_sel_ex_o    <= 1'b0;
            operand_a_ex_o  <= 32'h0;
            operand_b_ex_o  <= 32'h0;
            alu_operate_ex_o<= ALU_NONE;
            lsu_we_ex_o     <= 1'b0; 
            lsu_req_ex_o    <= 1'b0; 
            lsu_operate_ex_o<= LSU_NONE;
        end else begin
            rd_addr_ex_o    <= rd_addr_i;
            rd_wr_en_ex_o   <= rd_wr_en_i;
            alu_sel_ex_o    <= alu_sel_i;
            operand_a_ex_o  <= operand_a_i;
            operand_b_ex_o  <= operand_b_i;
            alu_operate_ex_o<= alu_operate_i;
            lsu_we_ex_o     <= lsu_we_i ;
            lsu_req_ex_o    <= lsu_req_i ;
            lsu_operate_ex_o<= lsu_operate_i;
        end
    end

endmodule

