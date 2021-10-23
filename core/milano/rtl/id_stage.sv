/***************************************
#
#			Filename:id_stage.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-29 15:41:06
#
***************************************/

`default_nettype none


module id_stage(
    input   logic                   clk_i                   ,
    input   logic                   rst_ni                  ,
    input   logic                   stall_from_ctrl_i       ,
    // from IF-ID pipeline register
    input   logic   [31:0]          instr_rdata_i           ,   //instr data
    input   logic   [31:0]          instr_addr_i            ,
    // csr reg read
    input   logic   [31:0]          csr_rdata_i             ,
    output  logic   [11:0]          csr_addr_o              ,
    // output to EX
    ////instr addr
    output  logic   [31:0]          instr_addr_ex_o         ,
    ////rd addr
    output  logic   [4:0]           rd_addr_ex_o            ,       //destination reg addr
    output  logic                   rd_wr_en_ex_o           ,
    ////
    output  logic                   alu_sel_ex_o            ,
    output  logic                   md_sel_ex_o             ,
    output  logic   [31:0]          rs1_rdata_ex_o          ,
    output  logic   [31:0]          rs2_rdata_ex_o          ,
    output  logic   [31:0]          alu_operand_a_ex_o      ,
    output  logic   [31:0]          alu_operand_b_ex_o      ,
    output  milano_pkg::alu_opt_e   alu_operate_ex_o        ,
    output  logic   [31:0]          md_operand_a_ex_o       ,
    output  logic   [31:0]          md_operand_b_ex_o       ,
    output  milano_pkg::md_opt_e    md_operate_ex_o         ,
    output  logic                   lsu_we_ex_o             ,
    output  logic                   lsu_req_ex_o            ,
    output  milano_pkg::lsu_opt_e   lsu_operate_ex_o        ,
    output  logic                   cond_jump_instr_ex_o    ,
    output  logic   [31:0]          jump_imm_ex_o           ,
    output  milano_pkg::jump_opt_e  jump_operate_ex_o       ,
    // ctroll to csr_reg
    output  logic                   csr_wr_en_ex_o          ,
    output  logic   [11:0]          csr_addr_ex_o           ,
    output  logic                   csr_sel_ex_o            ,
    output  logic   [31:0]          csr_rdata_temp_ex_o     ,
    output  logic   [31:0]          csr_imm_ex_o            ,
    output  milano_pkg::csr_opt_e   csr_operate_ex_o        ,
    // from EX
    input   logic                   we_i                    ,
    input   logic   [4:0]           waddr_i                 ,
    input   logic   [31:0]          wdata_i

);

    import milano_pkg::*;
    logic   [31:0]          instr_addr_o;
    logic   [31:0]          rs1_rdata_i, rs2_rdata_i, rs1_rdata_o, rs2_rdata_o, csr_rdata_temp_o;
    logic   [4:0]           rs1_addr_o, rs2_addr_o,rd_addr_o;
    logic   [11:0]          csr_addr;
    logic   [31:0]          alu_operand_a, alu_operand_b;
    logic   [31:0]          md_operand_a, md_operand_b;
    milano_pkg::alu_opt_e   alu_operate_o;
    milano_pkg::md_opt_e    md_operate_o;
    logic                   rd_wr_en_o, csr_wr_en_o, alu_sel_o, md_sel_o, csr_sel_o;
    logic                   lsu_we, lsu_req;
    milano_pkg::lsu_opt_e   lsu_operate_o;
    logic                   cond_jump_instr_o;
    logic   [31:0]          jump_imm_o, csr_imm_o;
    milano_pkg::jump_opt_e  jump_operate_o;
    milano_pkg::csr_opt_e   csr_operate_o;

    assign  csr_addr_o = csr_addr;
/************	decoder inst	******************/
decoder u_decoder(
    .clk_i              ( clk_i             ),
    .rst_ni             ( rst_ni            ),
    // from IF-ID pipeline register
    .instr_rdata_i      ( instr_rdata_i     ),      //instr data
    .instr_addr_i       ( instr_addr_i      ),      //instr addr
    // from register file
    .rs1_rdata_i        ( rs1_rdata_i       ),      //source reg1
    .rs2_rdata_i        ( rs2_rdata_i       ),      //source reg2
    // from csr reg
    .csr_rdata_i        ( csr_rdata_i       ),
    // output to register file
    .rs1_addr_o         ( rs1_addr_o        ),      //source reg1 addr
    .rs2_addr_o         ( rs2_addr_o        ),      //source reg2 addr
    // output to ID-EX pipeline register    
    .instr_addr_o       ( instr_addr_o      ),
    .rd_addr_o          ( rd_addr_o         ),      //destination reg addr
    .rd_wr_en_o         ( rd_wr_en_o        ),
    .alu_sel_o          ( alu_sel_o         ),
    .md_sel_o           ( md_sel_o          ),
    .alu_operand_a_o    ( alu_operand_a     ),
    .alu_operand_b_o    ( alu_operand_b     ),
    .alu_operate_o      ( alu_operate_o     ),
    .md_operand_a_o     ( md_operand_a      ),
    .md_operand_b_o     ( md_operand_b      ),
    .md_operate_o       ( md_operate_o      ),
    .lsu_we_o           ( lsu_we            ),
    .lsu_req_o          ( lsu_req           ),
    .lsu_operate_o      ( lsu_operate_o     ),
    .cond_jump_instr_o  ( cond_jump_instr_o ),
    .jump_imm_o         ( jump_imm_o        ),
    .jump_operate_o     ( jump_operate_o    ),
    .csr_wr_en_o        ( csr_wr_en_o       ),
    .csr_addr_o         ( csr_addr          ),
    .csr_sel_o          ( csr_sel_o         ),
    .csr_rdata_temp_o   ( csr_rdata_temp_o  ),
    .csr_imm_o          ( csr_imm_o         ),
    .csr_operate_o      ( csr_operate_o     )

);

/************	id_ex_reg inst	******************/
id_ex_reg u_id_ex_reg(
    .clk_i                  ( clk_i                 ),
    .rst_ni                 ( rst_ni                ),
    .stall_from_ctrl_i      ( stall_from_ctrl_i     ),
    //from decoder
    .instr_addr_i           ( instr_addr_o          ),
    .rd_addr_i              ( rd_addr_o             ),
    .rd_wr_en_i             ( rd_wr_en_o            ),
    .alu_sel_i              ( alu_sel_o             ),
    .md_sel_i               ( md_sel_o              ),
    .rs1_rdata_i            ( rs1_rdata_i           ),              
    .rs2_rdata_i            ( rs2_rdata_i           ), 
    .alu_operand_a_i        ( alu_operand_a         ),
    .alu_operand_b_i        ( alu_operand_b         ),
    .alu_operate_i          ( alu_operate_o         ),
    .md_operand_a_i         ( md_operand_a          ),
    .md_operand_b_i         ( md_operand_b          ),
    .md_operate_i           ( md_operate_o          ),
    .lsu_we_i               ( lsu_we                ), 
    .lsu_req_i              ( lsu_req               ), 
    .lsu_operate_i          ( lsu_operate_o         ),
    .cond_jump_instr_i      ( cond_jump_instr_o     ),
    .jump_imm_i             ( jump_imm_o            ),
    .jump_operate_i         ( jump_operate_o        ),
    .csr_wr_en_i            ( csr_wr_en_o           ),
    .csr_addr_i             ( csr_addr              ),
    .csr_sel_i              ( csr_sel_o             ),
    .csr_rdata_temp_i       ( csr_rdata_temp_o      ),
    .csr_imm_i              ( csr_imm_o             ),
    .csr_operate_i          ( csr_operate_o         ),


    //to EX
    
    .instr_addr_ex_o        ( instr_addr_ex_o       ),
    .rd_addr_ex_o           ( rd_addr_ex_o          ),
    .rd_wr_en_ex_o          ( rd_wr_en_ex_o         ),
    .alu_sel_ex_o           ( alu_sel_ex_o          ),
    .md_sel_ex_o            ( md_sel_ex_o           ),
    .rs1_rdata_ex_o         ( rs1_rdata_ex_o        ),
    .rs2_rdata_ex_o         ( rs2_rdata_ex_o        ),
    .alu_operand_a_ex_o     ( alu_operand_a_ex_o    ),
    .alu_operand_b_ex_o     ( alu_operand_b_ex_o    ),
    .alu_operate_ex_o       ( alu_operate_ex_o      ),
    .md_operand_a_ex_o      ( md_operand_a_ex_o     ),
    .md_operand_b_ex_o      ( md_operand_b_ex_o     ),
    .md_operate_ex_o        ( md_operate_ex_o       ),
    .lsu_we_ex_o            ( lsu_we_ex_o           ),
    .lsu_req_ex_o           ( lsu_req_ex_o          ),
    .lsu_operate_ex_o       ( lsu_operate_ex_o      ),
    .cond_jump_instr_ex_o   ( cond_jump_instr_ex_o  ),
    .jump_imm_ex_o          ( jump_imm_ex_o         ),
    .jump_operate_ex_o      ( jump_operate_ex_o     ),
    .csr_wr_en_ex_o         ( csr_wr_en_ex_o        ),
    .csr_addr_ex_o          ( csr_addr_ex_o         ),
    .csr_sel_ex_o           ( csr_sel_ex_o          ),
    .csr_rdata_temp_ex_o    ( csr_rdata_temp_ex_o   ),
    .csr_imm_ex_o           ( csr_imm_ex_o          ),
    .csr_operate_ex_o       ( csr_operate_ex_o      )

);

/************	regs file inst	******************/
regs_file u_regs_file(
    .clk_i      ( clk_i     ),
    .rst_ni     ( rst_ni    ),

    // from ex
    ////write port w1
    .we_i       ( we_i      ),
    .waddr_i    ( waddr_i   ),
    .wdata_i    ( wdata_i   ),

    // from id
    ////read port R1
    .raddr_a_i  ( rs1_addr_o    ),
    .rdata_a_o  ( rs1_rdata_i   ),
    ////reda port R2
    .raddr_b_i  ( rs2_addr_o    ),
    .rdata_b_o  ( rs2_rdata_i   )
);

endmodule
