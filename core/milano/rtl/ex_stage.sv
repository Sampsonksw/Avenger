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
    input   logic   [31:0]          instr_data_i        ,
    input   logic                   alu_sel_i           ,
    input   logic                   md_sel_i            ,
    input   milano_pkg::alu_opt_e   alu_operate_i       ,
    input   milano_pkg::md_opt_e    md_operate_i        ,
    input   logic   [31:0]          alu_operand_a_i     ,
    input   logic   [31:0]          alu_operand_b_i     ,
    input   logic   [31:0]          md_operand_a_i      ,
    input   logic   [31:0]          md_operand_b_i      ,
    input   logic   [31:0]          rs1_rdata_i         ,
    input   logic   [31:0]          rs2_rdata_i         ,
    input   logic   [4:0]           rd_addr_i           ,
    input   logic                   rd_we_i             ,
    input   logic                   lsu_mem_we_i        ,
    input   logic                   lsu_mem_req_i       ,
    input   milano_pkg::lsu_opt_e   lsu_operate_i       ,

    input   logic                   csr_we_i            ,
    input   logic   [11:0]          csr_addr_i          ,
    input   logic                   csr_sel_i           ,
    input   logic   [31:0]          csr_rdata_temp_i    ,
    input   logic   [31:0]          csr_imm_i           ,
    input   milano_pkg::csr_opt_e   csr_operate_i       ,
 
    input   logic                   cond_jump_instr_i   ,
    input   logic   [31:0]          jump_imm_i          ,
    input   milano_pkg::jump_opt_e  jump_operate_i      ,

    input   logic                   ecall_flag_i        ,
    input   logic                   ebreak_flag_i       ,
    // rd register wirte interface
    output  logic                   rd_we_o             ,
    output  logic   [4:0]           rd_waddr_o          ,
    output  logic   [31:0]          rd_wdata_o          ,
    // csr reg write interface
    output  logic                   csr_we_o            ,
    output  logic   [11:0]          csr_waddr_o         ,
    output  logic   [31:0]          csr_wdata_o         ,


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
    output  logic   [31:0]          jump_addr_o         ,
    // to ctrl
    output  logic                   stallreq_o          ,
    output  logic                   ecall_exce_o        ,
    output  logic                   ebreak_exce_o       ,
    output  logic   [31:0]          instr_addr_o        ,
    output  logic   [31:0]          instr_data_o        , 
    // from ctrl
    input   logic                   refresh_pip_i       

);
    
    import milano_pkg::*;

    logic   [31:0]  add_op_a_op_b;

    logic   [31:0]  alu_rd_wdata_o, lsu_rd_wdata_o, md_rd_wdata_o, csr_rd_wdata_o;
    logic           alu_rd_we_o, lsu_rd_we_o, md_rd_we_o, csr_rd_we_o;
    logic   [4:0]   alu_rd_waddr_o, lsu_rd_waddr_o, md_rd_waddr_o, csr_rd_waddr_o;
    assign  instr_addr_o = instr_addr_i;
    assign  instr_data_o = instr_data_i;
    always_comb begin
        if(alu_sel_i)begin
            rd_wdata_o  = alu_rd_wdata_o;
            rd_we_o     = alu_rd_we_o;
            rd_waddr_o  = alu_rd_waddr_o;
        end else if(md_sel_i)begin
            rd_wdata_o  = md_rd_wdata_o;
            rd_we_o     = md_rd_we_o;
            rd_waddr_o  = md_rd_waddr_o;
        end else if(csr_sel_i)begin
            rd_wdata_o  = csr_rd_wdata_o;
            rd_we_o     = csr_rd_we_o;
            rd_waddr_o  = csr_rd_waddr_o;
        end else begin
            rd_wdata_o  = lsu_rd_wdata_o;
            rd_we_o     = lsu_rd_we_o;
            rd_waddr_o  = lsu_rd_waddr_o;
        end
    end

alu u_alu(
    .rst_ni         ( rst_ni            ),
    .operate_i      ( alu_operate_i     ),
    .operand_a_i    ( alu_operand_a_i   ),
    .operand_b_i    ( alu_operand_b_i   ),
    .rd_addr_i      ( rd_addr_i         ),
    .rd_we_i        ( rd_we_i           ),
    .instr_addr_i   ( instr_addr_i      ),
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
    .lsu_mem_addr_i ( add_op_a_op_b     ),
    //Write back, to MEM/regs
    .lsu_rd_we_o    ( lsu_rd_we_o       ),
    .lsu_rd_waddr_o ( lsu_rd_waddr_o    ),
    .lsu_rd_wdata_o ( lsu_rd_wdata_o    )

);
// Multiply

    logic                   div_done;
    logic                   div_busy;
    logic                   div_start;

    assign  div_start = (((md_operate_i ==MD_OP_DIV) || (md_operate_i ==MD_OP_DIVU) || (md_operate_i ==MD_OP_REM) || (md_operate_i ==MD_OP_REMU))&&~div_done) ? 1'b1 : 1'b0;
    //assign    div_start = ((md_operate_i inside {MD_OP_DIV, MD_OP_DIVU, MD_OP_REM, MD_OP_REM }) &&~div_done ) ? 1'b1 : 1'b0;
multdiv u_multdiv(
    .clk_i          ( clk_i             ),
    .rst_ni         ( rst_ni            ),

    .rd_addr_i      ( rd_addr_i         ),
    .rd_we_i        ( rd_we_i           ),
    .md_operate_i   ( md_operate_i      ),
    .md_operand_a_i ( md_operand_a_i    ),
    .md_operand_b_i ( md_operand_b_i    ),
    .div_start      ( div_start         ),

    .md_rd_we_o     ( md_rd_we_o        ),
    .md_rd_waddr_o  ( md_rd_waddr_o     ),
    .md_rd_wdata_o  ( md_rd_wdata_o     ),
    .div_done       ( div_done          ),
    .div_busy       ( div_busy          ),
    .refresh_pip_i  ( refresh_pip_i     )

    );




    //JUMP
    logic   rs1_equal_rs2, rs1_less_rs2, rs1_less_rs2_unsigned;
    logic   beq_jump_enable, bne_jump_enable, blt_jump_enable, bge_jump_enable, bltu_jump_enable, bgeu_jump_enable;

    assign  rs1_equal_rs2   =   rs1_rdata_i == rs2_rdata_i;
    assign  rs1_less_rs2    =   rs1_rdata_i < rs2_rdata_i;
    assign  rs1_less_rs2_unsigned = $unsigned(rs1_rdata_i) < $unsigned(rs2_rdata_i);

    assign  beq_jump_enable =   rs1_equal_rs2  ? 1'b1 : 1'b0;
    assign  bne_jump_enable =   ~rs1_equal_rs2 ? 1'b1 : 1'b0;
    assign  blt_jump_enable =   rs1_less_rs2   ? 1'b1 : 1'b0;
    assign  bge_jump_enable =   ~rs1_less_rs2  ? 1'b1 : 1'b0;
    assign  bltu_jump_enable=   rs1_less_rs2_unsigned ? 1'b1 : 1'b0;
    assign  bgeu_jump_enable=   ~rs1_less_rs2_unsigned? 1'b1 : 1'b0;

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
                JUMP_BNE :  begin
                    jump_flag_o = bne_jump_enable && cond_jump_instr_i;
                    jump_addr_o = add_op_a_op_b;
                end
                JUMP_BLT :  begin
                    jump_flag_o = blt_jump_enable && cond_jump_instr_i;
                    jump_addr_o = add_op_a_op_b;
                end
                JUMP_BGE :  begin
                    jump_flag_o = bge_jump_enable && cond_jump_instr_i;
                    jump_addr_o = add_op_a_op_b;
                end
                JUMP_BLTU:  begin
                    jump_flag_o = bltu_jump_enable && cond_jump_instr_i;
                    jump_addr_o = add_op_a_op_b;
                end
                JUMP_BGEU : begin
                    jump_flag_o = bgeu_jump_enable && cond_jump_instr_i;
                    jump_addr_o = add_op_a_op_b;
                end
                JUMP_JAL :  begin
                    jump_flag_o = 1'b1;
                    jump_addr_o = jump_imm_i + instr_addr_i;
                end
                JUMP_JALR : begin
                    jump_flag_o = 1'b1;
                    jump_addr_o = jump_imm_i + rs1_rdata_i;
                end
                default: jump_flag_o = 1'h0;
            endcase
        end
    end

    // CSR


    always_comb begin
        if(!rst_ni)begin
            csr_we_o        =  1'h0; 
            csr_waddr_o     = 12'h0;
            csr_wdata_o     = 32'h0;
            csr_rd_we_o     =  1'h0;
            csr_rd_wdata_o  = 32'h0;
            csr_rd_waddr_o  =  5'h0;
        end else begin
            csr_we_o        = csr_we_i;
            csr_waddr_o     = csr_addr_i;
            csr_wdata_o     = 32'h0;
            csr_rd_we_o     = rd_we_i;
            csr_rd_wdata_o  = csr_rdata_temp_i;
            csr_rd_waddr_o  = rd_addr_i;
            unique case(csr_operate_i)
                CSR_RW  :   begin
                    csr_wdata_o =  rs1_rdata_i;
                end
                CSR_RS  :   begin
                    csr_wdata_o =  csr_rdata_temp_i | rs1_rdata_i;
                end
                CSR_RC  :   begin
                    csr_wdata_o =  csr_rdata_temp_i & rs1_rdata_i;
                end
                CSR_RWI :   begin
                    csr_wdata_o =   csr_imm_i;
                end
                CSR_RSI :   begin
                    csr_wdata_o =   csr_rdata_temp_i | csr_imm_i;
                end
                CSR_RCI :   begin
                    csr_wdata_o =   csr_rdata_temp_i & csr_imm_i;
                end
                default: begin
                    csr_we_o        =  1'h0; 
                    csr_waddr_o     = 12'h0;
                    csr_wdata_o     = 32'h0;
                    csr_rd_we_o     =  1'h0;
                    csr_rd_wdata_o  = 32'h0;
                    csr_rd_waddr_o  =  5'h0;
                end
            endcase
        end
    end

// stall
    logic           stallreq_from_multdiv;
    assign  stallreq_from_multdiv = div_busy ||div_start;
    assign  stallreq_o = stallreq_from_multdiv && ~refresh_pip_i;

// exce
    assign  ebreak_exce_o = ebreak_flag_i;
    assign  ecall_exce_o = ecall_flag_i;


endmodule


`default_nettype wire

