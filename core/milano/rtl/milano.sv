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
        input   logic   [31:0]      data_rdata_i    ,
        //timer interrupt
        input   logic               timer_irq_i
);

//==============================================================================
//==  If Stage Signals =========================================================
//==============================================================================

    logic   [31:0]      instr_data_if2id;       //output
    logic   [31:0]      instr_addr_if2id;       //output

//==============================================================================
//==  Id Stage Signals =========================================================
//==============================================================================

    logic   [11:0]          csr_addr_o;                                                                         //output
    logic   [31:0]          instr_addr_id2ex,instr_data_id2ex;                                                  //output
    logic   [4:0]           rd_addr_id2ex;                                                                      //output
    logic                   rd_wr_en_id2ex, csr_wr_en_id2ex;                                                    //output
    logic                   alu_sel_id2ex,md_sel_id2ex, csr_sel_id2ex;                                          //output
    logic   [31:0]          rs1_rdata_id2ex, rs2_rdata_id2ex;                                                   //output
    logic   [31:0]          alu_operand_a_id2ex, alu_operand_b_id2ex, md_operand_a_id2ex, md_operand_b_id2ex;   //output
    milano_pkg::alu_opt_e   alu_operate_id2ex;                                                                  //output
    milano_pkg::md_opt_e    md_operate_id2ex;                                                                   //output
    logic                   lsu_mem_we_id2ex, lsu_mem_req_id2ex;                                                //output
    milano_pkg::lsu_opt_e   lsu_operate_id2ex;                                                                  //output
    logic                   cond_jump_instr_id2ex;                                                              //output
    logic   [31:0]          jump_imm_id2ex;                                                                     //output
    milano_pkg::jump_opt_e  jump_operate_id2ex;                                                                 //output
    logic   [11:0]          csr_addr_id2ex;                                                                     //output
    logic   [31:0]          csr_rdata_temp_id2ex;                                                               //output
    logic   [31:0]          csr_imm_id2ex;                                                                      //output
    milano_pkg::csr_opt_e   csr_operate_id2ex;                                                                  //output
    logic                   ecall_flag_id2ex, ebreak_flag_id2ex;                                                //output   


//==============================================================================
//==  Ex Stage Signals =========================================================
//==============================================================================

    logic                   we_ex2csr;                                                                          //output 
    logic   [11:0]          waddr_ex2csr;                                                                       //output 
    logic   [31:0]          wdata_ex2csr;                                                                       //output 
    logic                   stallreq_from_ex_o;                                                                 //output 
    logic                   ecall_exce_o;                                                                       //output 
    logic                   ebreak_exce_o;                                                                      //output 
    logic                   jump_flag_o;                                                                        //output
    logic   [31:0]          jump_addr_o;                                                                        //output
    logic                   we_ex2id;                                                                           //output
    logic   [4:0]           waddr_ex2id;                                                                        //output
    logic   [31:0]          wdata_ex2id;                                                                        //output

//==============================================================================
//==  Ctrl Signals =============================================================
//==============================================================================

    logic                   stall_from_ctrl;                                                                    //output
    logic                   refresh_pip_from_ctrl;                                                              //output
    logic   [31:0]          exce_jump_addr_o;                                                                   //output
    logic                   exce_jump_en_o;                                                                     //output
    logic                   we_ctrl2csr;                                                                        //output
    logic   [11:0]          waddr_ctrl2csr;                                                                     //output
    logic   [31:0]          wdata_ctrl2csr;                                                                     //output
    logic   [31:0]          instr_addr_ex2ctrl;                                                                 //output
    logic   [31:0]          instr_data_ex2ctrl;                                                                 //output

//==============================================================================
//==  Csr reg Signals ==========================================================
//==============================================================================

    logic   [31:0]          csr_rdata_i;                                                                        //output    
    logic   [31:0]          mstatus;                                                                            //output
    logic   [31:0]          mepc;                                                                               //output
    logic   [31:0]          mtvec;                                                                              //output
    logic   [31:0]          mie;                                                                                //output
    logic   [31:0]          mip;                                                                                //output




/********** if stage unit  ***********/

if_stage u_if_stage(
    .clk_i              ( clk_i                 ),
    .rst_ni             ( rst_ni                ),
     //stall from ctrl
    .stall_from_ctrl_i  ( stall_from_ctrl       ),
    //refresh from ctrl
    .refresh_pip_i      ( refresh_pip_from_ctrl ),
    .boot_addr_i        ( boot_addr_i           ),
	//input form ram    
    .instr_rdata_i      ( instr_rdata_i         ),
	//outputs to instr ram/ID
    .instr_addr_o       ( instr_addr_o          ),
    .fetch_enable_o     ( fetch_enable_o        ),
	//outputs to ID
    .instr_rdata_id_o   ( instr_data_if2id      ),
    .instr_addr_id_o    ( instr_addr_if2id      ),
    //from ex 
    .jump_flag_i        ( jump_flag_o           ),
    .jump_addr_i        ( jump_addr_o           ),
    //from ctrl
    .ctrl_jump_flag_i   ( exce_jump_en_o        ),
    .ctrl_jump_addr_i   ( exce_jump_addr_o      )
);

/********** id stage unit  ***********/
id_stage u_id_stage(
    .clk_i                  ( clk_i                 ),
    .rst_ni                 ( rst_ni                ),
    //  stall from ctrl
    .stall_from_ctrl_i      ( stall_from_ctrl       ),
    // refresh form ctrl
    .refresh_pip_i          ( refresh_pip_from_ctrl ),
    // from IF-ID pipeline register
    .instr_rdata_i          ( instr_data_if2id      ),  //instr data
    .instr_addr_i           ( instr_addr_if2id      ),  //instr address
    // csr reg read
    .csr_rdata_i            ( csr_rdata_i           ),
    .csr_addr_o             ( csr_addr_o            ),
    // output to EX
    ////instr addr
    .instr_addr_ex_o        ( instr_addr_id2ex      ),
    .instr_data_ex_o        ( instr_data_id2ex      ),
    ////rd addr
    .rd_addr_ex_o           ( rd_addr_id2ex         ),  //rd register address
    .rd_wr_en_ex_o          ( rd_wr_en_id2ex        ),  //rd register write enable
    ////
    .alu_sel_ex_o           ( alu_sel_id2ex         ),
    .md_sel_ex_o            ( md_sel_id2ex          ),
    .rs1_rdata_ex_o         ( rs1_rdata_id2ex       ),
    .rs2_rdata_ex_o         ( rs2_rdata_id2ex       ),
    .alu_operand_a_ex_o     ( alu_operand_a_id2ex   ),  //alu_operand_a data
    .alu_operand_b_ex_o     ( alu_operand_b_id2ex   ),  //alu_operand_b data
    .alu_operate_ex_o       ( alu_operate_id2ex     ),
    .md_operand_a_ex_o      ( md_operand_a_id2ex    ),  //md_operand_a data
    .md_operand_b_ex_o      ( md_operand_b_id2ex    ),  //md_operand_b data
    .md_operate_ex_o        ( md_operate_id2ex      ),
    .lsu_we_ex_o            ( lsu_mem_we_id2ex      ),
    .lsu_req_ex_o           ( lsu_mem_req_id2ex     ),
    .lsu_operate_ex_o       ( lsu_operate_id2ex     ),
    .cond_jump_instr_ex_o   ( cond_jump_instr_id2ex ),
    .jump_imm_ex_o          ( jump_imm_id2ex        ),
    .jump_operate_ex_o      ( jump_operate_id2ex    ),
    .csr_wr_en_ex_o         ( csr_wr_en_id2ex       ),
    .csr_addr_ex_o          ( csr_addr_id2ex        ),
    .csr_sel_ex_o           ( csr_sel_id2ex         ),
    .csr_rdata_temp_ex_o    ( csr_rdata_temp_id2ex  ),
    .csr_imm_ex_o           ( csr_imm_id2ex         ),
    .csr_operate_ex_o       ( csr_operate_id2ex     ),
    .ecall_flag_ex_o        ( ecall_flag_id2ex      ),
    .ebreak_flag_ex_o       ( ebreak_flag_id2ex     ),
    .crtl_jump_flag_i       ( exce_jump_en_o        ),
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
    .instr_data_i       ( instr_data_id2ex      ),
    .alu_sel_i          ( alu_sel_id2ex         ),
    .md_sel_i           ( md_sel_id2ex          ),
    .alu_operate_i      ( alu_operate_id2ex     ),  //alu operate type
    .md_operate_i       ( md_operate_id2ex      ),  //alu operate type
    .alu_operand_a_i    ( alu_operand_a_id2ex   ),  //alu_operand_a data
    .alu_operand_b_i    ( alu_operand_b_id2ex   ),  //alu_operand_b data
    .md_operand_a_i     ( md_operand_a_id2ex    ),  //alu_operand_a data
    .md_operand_b_i     ( md_operand_b_id2ex    ),  //alu_operand_b data
    .rs1_rdata_i        ( rs1_rdata_id2ex       ),
    .rs2_rdata_i        ( rs2_rdata_id2ex       ),
    .rd_addr_i          ( rd_addr_id2ex         ),  //rd  register address
    .rd_we_i            ( rd_wr_en_id2ex        ),  //rd  register write enable
    .lsu_mem_we_i       ( lsu_mem_we_id2ex      ),
    .lsu_mem_req_i      ( lsu_mem_req_id2ex     ),
    .lsu_operate_i      ( lsu_operate_id2ex     ),

    .csr_we_i           ( csr_wr_en_id2ex       ), 
    .csr_addr_i         ( csr_addr_id2ex        ), 
    .csr_sel_i          ( csr_sel_id2ex         ), 
    .csr_rdata_temp_i   ( csr_rdata_temp_id2ex  ), 
    .csr_imm_i          ( csr_imm_id2ex         ), 
    .csr_operate_i      ( csr_operate_id2ex     ), 

    .cond_jump_instr_i  ( cond_jump_instr_id2ex ),
    .jump_imm_i         ( jump_imm_id2ex        ),
    .jump_operate_i     ( jump_operate_id2ex    ),

    .ecall_flag_i       ( ecall_flag_id2ex      ),
    .ebreak_flag_i      ( ebreak_flag_id2ex     ),
    // rd register wirte interface
    .rd_we_o            ( we_ex2id              ),
    .rd_waddr_o         ( waddr_ex2id           ),
    .rd_wdata_o         ( wdata_ex2id           ),
    // csr reg write interface
    .csr_we_o           ( we_ex2csr             ),
    .csr_waddr_o        ( waddr_ex2csr          ),
    .csr_wdata_o        ( wdata_ex2csr          ),
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
    .jump_addr_o        ( jump_addr_o           ),
    //to ctrl
    .stallreq_o         ( stallreq_from_ex_o    ),
    .ecall_exce_o       ( ecall_exce_o          ),
    .ebreak_exce_o      ( ebreak_exce_o         ),
    .instr_addr_o       ( instr_addr_ex2ctrl    ),
    .instr_data_o       ( instr_data_ex2ctrl    ),
    // from ctrl
    .refresh_pip_i      ( refresh_pip_from_ctrl )
);

/********** ctrl unit  **********/

ctrl u_ctrl(
    .clk_i              ( clk_i                 ),
    .rst_ni             ( rst_ni                ),

    .stallreq_from_ex_i ( stallreq_from_ex_o    ),
    .stall_o            ( stall_from_ctrl       ),
    // from ex_stage
    .instr_addr_i       ( instr_addr_id2ex      ),
    .instr_data_i       ( instr_data_id2ex      ),
    .ecall_exce_i       ( ecall_exce_o          ),
    .ebreak_exce_i      ( ebreak_exce_o         ),
    .ex_jump_flag_i     ( jump_flag_o           ),
    // from csr_reg
    .csr_mstatus        ( mstatus               ),
    .csr_mepc           ( mepc                  ),
    .csr_mtvec          ( mtvec                 ),
    .csr_mie            ( mie                   ),
    .csr_mip            ( mip                   ),

    // to if stage
    .exce_jump_addr_o   ( exce_jump_addr_o      ),
    .exce_jump_en_o     ( exce_jump_en_o        ),
    // csr reg interface
    .csr_we_o           ( we_ctrl2csr           ),
    .csr_waddr_o        ( waddr_ctrl2csr        ),
    .csr_wdata_o        ( wdata_ctrl2csr        ),

    .refresh_pip_o      ( refresh_pip_from_ctrl )
);


/********** csr_reg unit *******/

csr_reg u_csr_reg(
    .clk_i          ( clk_i             ),
    .rst_ni         ( rst_ni            ),
    // ex access interface
    // write
    .ex_waddr_i     ( waddr_ex2csr      ),
    .ex_wdata_i     ( wdata_ex2csr      ),
    .ex_we_i        ( we_ex2csr         ),
    // ctrl access interface
    .ctrl_waddr_i   ( waddr_ctrl2csr    ),
    .ctrl_wdata_i   ( wdata_ctrl2csr    ),
    .ctrl_we_i      ( we_ctrl2csr       ),
    // id access interface
    // read
    .id_raddr_i     ( csr_addr_o        ),
    .id_rdata_o     ( csr_rdata_i       ),

    // to ctrl
    .mstatus        ( mstatus           ),
    .mepc           ( mepc              ),
    .mtvec          ( mtvec             ),
    .mie            ( mie               ),
    .mip            ( mip               ),

    // from local interrupt
    .timer_irq_i    ( timer_irq_i       )
);
endmodule
