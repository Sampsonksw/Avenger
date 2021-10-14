/***************************************
#
#			Filename:ex_stage.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-28 23:16:45
#
***************************************/

`default_nettype none


module ex_stage(
    input   logic                   clk_i               ,
    input   logic                   rst_ni              ,
    // from ID-EX pipeline register
    input   logic   [31:0]          instr_addr_i        ,
    input   logic                   alu_sel_i           ,
    input   milano_pkg::alu_opt_e   alu_operate_i       ,
    input   logic   [31:0]          alu_operand_a_i     ,
    input   logic   [31:0]          alu_operand_b_i     ,
    input   logic   [31:0]          rs1_rdata_i         ,
    input   logic   [31:0]          rs2_rdata_i         ,
    input   logic   [4:0]           rd_addr_i           ,
    input   logic                   rd_we_i             ,
    input   logic                   lsu_mem_we_i        ,
    input   logic                   lsu_mem_req_i       ,
    input   milano_pkg::lsu_opt_e   lsu_operate_i       ,

    input   logic                   cond_jump_instr_i   ,
    //input   logic   [31:0]          jump_imm_i          ,
    input   milano_pkg::jump_opt_e  jump_operate_i      ,
    // Write back, to MEM/regs
    output  logic                   rd_we_o             ,
    output  logic   [4:0]           rd_waddr_o          ,
    output  logic   [31:0]          rd_wdata_o          ,
    // data interface
    output  logic                   data_req_o          ,
    input   logic                   data_gnt_i          ,
    input   logic                   data_rvalid_i       ,
    output  logic   [31:0]          data_addr_o         ,
    output  logic                   data_we_o           ,
    output  logic   [3:0]           data_be_o           ,
    output  logic   [31:0]          data_wdata_o        ,
    input   logic   [31:0]          data_rdata_i        ,   

    // to pc fetch reg
    output  logic                   jump_flag_o         ,    
    output  logic   [31:0]          jump_addr_o
);
    
    import milano_pkg::*;

    logic   [31:0]  add_op_a_op_b;

    logic   [31:0]  alu_rd_wdata_o, lsu_rd_wdata_o;
    logic           alu_rd_we_o, lsu_rd_we_o;
    logic   [4:0]   alu_rd_waddr_o, lsu_rd_waddr_o;

    assign rd_wdata_o = alu_sel_i ? alu_rd_wdata_o : lsu_rd_wdata_o;
    assign rd_we_o = alu_rd_we_o |  lsu_rd_we_o;
    assign rd_waddr_o = alu_sel_i ? alu_rd_waddr_o : lsu_rd_waddr_o;

alu u_alu(
    .rst_ni         ( rst_ni            ),
    .operate_i      ( alu_operate_i     ),
    .operand_a_i    ( alu_operand_a_i   ),
    .operand_b_i    ( alu_operand_b_i   ),
    .rd_addr_i      ( rd_addr_i         ),
    .rd_we_i        ( rd_we_i           ),
    .alu_rd_we_o    ( alu_rd_we_o       ),
    .alu_rd_waddr_o ( alu_rd_waddr_o    ),
    .alu_rd_wdata_o ( alu_rd_wdata_o    ),
    .add_op_a_op_b  ( add_op_a_op_b    )
);


lsu u_lsu(
    .clk_i          ( clk_i             ),  
    .rst_ni         ( rst_ni            ),
    // data interface
    .data_req_o     ( data_req_o        ),
    .data_gnt_i     ( data_gnt_i        ),
    .data_rvalid_i  ( data_rvalid_i     ),
    .data_addr_o    ( data_addr_o       ),
    .data_we_o      ( data_we_o         ),
    .data_be_o      ( data_be_o         ),
    .data_wdata_o   ( data_wdata_o      ),
    .data_rdata_i   ( data_rdata_i      ),
    // from ID-EX pipeline register
    .lsu_mem_we_i   ( lsu_mem_we_i      ),
    .lsu_mem_req_i  ( lsu_mem_req_i     ),
    .lsu_operate_i  ( lsu_operate_i     ),
    .rd_addr_i      ( rd_addr_i         ),
    .rd_we_i        ( rd_we_i           ),
    .rs1_rdata_i    ( rs1_rdata_i       ),
    .rs2_rdata_i    ( rs2_rdata_i       ),
    // from alu
    .lsu_mem_addr_i ( add_op_a_op_b    ),
    //Write back, to MEM/regs
    .lsu_rd_we_o    ( lsu_rd_we_o       ),
    .lsu_rd_waddr_o ( lsu_rd_waddr_o    ),
    .lsu_rd_wdata_o ( lsu_rd_wdata_o    )

);



    logic   beq_jump_enable;
    assign  beq_jump_enable = (rs1_rdata_i == rs2_rdata_i) ? 1'b1 : 1'b0;
    always_comb begin
        if(!rst_ni)begin
            jump_flag_o = 1'h0;
            jump_addr_o = 32'h0;
        end else begin
            jump_flag_o = 1'h0;
            jump_addr_o = 32'h0;
            unique case (jump_operate_i)
                JUMP_BEQ :  begin
                    jump_flag_o = beq_jump_enable && cond_jump_instr_i;
                    jump_addr_o = add_op_a_op_b;
                end
                default: ;
            endcase
        end
    end
endmodule
