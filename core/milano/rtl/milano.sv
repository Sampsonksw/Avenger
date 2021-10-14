/***************************************
#
#			Filename:milano.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-29 15:09:11
#
***************************************/

`default_nettype none


module milano(
        input   logic               clk_i           ,
        input   logic               rst_ni          ,
        // input from boot sel
        input   logic   [31:0]      boot_addr_i     ,
        // output to system bus
        output  logic   [31:0]      instr_addr_o    ,
        // from instr ram
        input   logic   [31:0]      instr_rdata_i   ,
        // output to instr ramid_stage
        output  logic               fetch_enable_o  ,
        // data interface
        output  logic               data_req_o      ,
        input   logic               data_gnt_i      ,
        input   logic               data_rvalid_i   ,
        output  logic   [31:0]      data_addr_o     ,
        output  logic               data_we_o       ,
        output  logic   [3:0]       data_be_o       ,
        output  logic   [31:0]      data_wdata_o    ,
        input   logic   [31:0]      data_rdata_i    
);




/********** if stage unit  ***********/

    logic   [31:0]      instr_data_if2id;
    logic   [31:0]      instr_addr_if2id;
    logic               jump_flag_o;
    logic   [31:0]      jump_addr_o;
if_stage u_if_stage(
        .clk_i              ( clk_i             ),
        .rst_ni             ( rst_ni            ),
        .boot_addr_i        ( boot_addr_i       ),
	    //input form ram    
        .instr_rdata_i      ( instr_rdata_i     ),
	    //outputs to instr ram/ID
        .instr_addr_o       ( instr_addr_o      ),
        .fetch_enable_o     ( fetch_enable_o    ),
	    //outputs to ID
        .instr_rdata_id_o   ( instr_data_if2id  ),
        .instr_addr_id_o    ( instr_addr_if2id  ),
        //from ex 
        .jump_flag_i        ( jump_flag_o       ),
        .jump_addr_i        ( jump_addr_o       )
);

/********** id stage unit  **********/
    logic   [31:0]          instr_addr_id2ex;
    logic   [4:0]           rd_addr_id2ex;
    logic                   rd_wr_en_id2ex;
    logic                   alu_sel_id2ex;
    logic   [31:0]          rs1_rdata_id2ex;
    logic   [31:0]          rs2_rdata_id2ex;
    logic   [31:0]          operand_a_id2ex;
    logic   [31:0]          operand_b_id2ex;
    milano_pkg::alu_opt_e   alu_operate_id2ex;
    logic                   lsu_mem_we_id2ex;  
    logic                   lsu_mem_req_id2ex; 
    milano_pkg::lsu_opt_e   lsu_operate_id2ex;
    logic                   cond_jump_instr_id2ex;
    //logic   [31:0]          jump_imm_id2ex;
    milano_pkg::jump_opt_e  jump_operate_id2ex;
    logic                   we_ex2id;
    logic   [4:0]           waddr_ex2id;
    logic   [31:0]          wdata_ex2id;

id_stage u_id_stage(
    .clk_i                  ( clk_i                 ),
    .rst_ni                 ( rst_ni                ),
    // from IF-ID pipeline register
    .instr_rdata_i          ( instr_data_if2id      ),  //instr data
    .instr_addr_i           ( instr_addr_if2id      ),  //instr address
    // output to EX
    ////instr addr
    .instr_addr_ex_o        ( instr_addr_id2ex      ),
    ////rd addr
    .rd_addr_ex_o           ( rd_addr_id2ex         ),  //rd register address
    .rd_wr_en_ex_o          ( rd_wr_en_id2ex        ),  //rd register write enable
    ////
    .alu_sel_ex_o           ( alu_sel_id2ex         ),
    .rs1_rdata_ex_o         ( rs1_rdata_id2ex       ),
    .rs2_rdata_ex_o         ( rs2_rdata_id2ex       ),
    .operand_a_ex_o         ( operand_a_id2ex       ),  //operand_a data
    .operand_b_ex_o         ( operand_b_id2ex       ),  //operand_b data
    .alu_operate_ex_o       ( alu_operate_id2ex     ),
    .lsu_we_ex_o            ( lsu_mem_we_id2ex      ),
    .lsu_req_ex_o           ( lsu_mem_req_id2ex     ),
    .lsu_operate_ex_o       ( lsu_operate_id2ex     ),
    .cond_jump_instr_ex_o   ( cond_jump_instr_id2ex ),
    //.jump_imm_ex_o          ( jump_imm_id2ex        ),
    .jump_operate_ex_o      ( jump_operate_id2ex    ),
    // from EX
    .we_i                   ( we_ex2id              ),
    .waddr_i                ( waddr_ex2id           ),
    .wdata_i                ( wdata_ex2id           )

);

/********** ex stage unit  **********/

ex_stage u_ex_stage(
    .clk_i              ( clk_i                 ),
    .rst_ni             ( rst_ni                ),
    // from ID-EX pipeline register
    .instr_addr_i       ( instr_addr_id2ex      ),
    .alu_sel_i          ( alu_sel_id2ex         ),
    .alu_operate_i      ( alu_operate_id2ex     ),  //alu operate type
    .alu_operand_a_i    ( operand_a_id2ex       ),  //operand_a data
    .alu_operand_b_i    ( operand_b_id2ex       ),  //operand_b data
    .rs1_rdata_i        ( rs1_rdata_id2ex       ),
    .rs2_rdata_i        ( rs2_rdata_id2ex       ),
    .rd_addr_i          ( rd_addr_id2ex         ),  //rd  register address
    .rd_we_i            ( rd_wr_en_id2ex        ),  //rd  register write enable
    .lsu_mem_we_i       ( lsu_mem_we_id2ex      ),
    .lsu_mem_req_i      ( lsu_mem_req_id2ex     ),
    .lsu_operate_i      ( lsu_operate_id2ex     ),

    .cond_jump_instr_i  ( cond_jump_instr_id2ex ),
    //.jump_imm_i         ( jump_imm_id2ex        ),
    .jump_operate_i     ( jump_operate_id2ex    ),
    // Write back, to MEM/regs
    .rd_we_o            ( we_ex2id              ),
    .rd_waddr_o         ( waddr_ex2id           ),
    .rd_wdata_o         ( wdata_ex2id           ),
    // data interface
    .data_req_o         ( data_req_o            ),
    .data_gnt_i         ( data_gnt_i            ),
    .data_rvalid_i      ( data_rvalid_i         ),
    .data_addr_o        ( data_addr_o           ),
    .data_we_o          ( data_we_o             ),
    .data_be_o          ( data_be_o             ),
    .data_wdata_o       ( data_wdata_o          ),
    .data_rdata_i       ( data_rdata_i          ),

    // to pc fetch reg
    .jump_flag_o        ( jump_flag_o           ),    
    .jump_addr_o        ( jump_addr_o           )
);

endmodule
