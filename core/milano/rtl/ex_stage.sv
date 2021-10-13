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
    input  logic                    clk_i       ,
    input  logic                    rst_ni      ,
    // from ID-EX pipeline register
    input   logic                   alu_sel_i   ,
    input  milano_pkg::alu_opt_e    operator_i  ,
    input  logic    [31:0]          operand_a_i ,
    input  logic    [31:0]          operand_b_i ,
    input  logic    [4:0]           rd_addr_i   ,
    input  logic                    rd_wr_en_i  ,
    input  logic                    lsu_we_i    ,
    input  logic                    lsu_req_i   ,
    input  logic    [2:0]           lsu_type_i  ,
    // Write back, to MEM/regs
    output logic                    reg_we_o        ,
    output logic    [4:0]           wr_addr_o       ,
    output logic    [31:0]          rd_wdata_o      ,
    // data interface
    output  logic                   data_req_o      ,
    input   logic                   data_gnt_i      ,
    input   logic                   data_rvalid_i   ,
    output  logic   [31:0]          data_addr_o     ,
    output  logic                   data_we_o       ,
    output  logic   [3:0]           data_be_o       ,
    output  logic   [31:0]          data_wdata_o    ,
    input   logic   [31:0]          data_rdata_i    


);

    logic   [31:0]  rd_wdata_alu;
    logic   [31:0]  lsu_rdata_o;
    logic   [31:0]  lsu_addr_o;

    assign rd_wdata_o = alu_sel_i ? rd_wdata_alu : lsu_rdata_o;

alu u_alu(
    .rst_ni         ( rst_ni        ),
    .operator_i     ( operator_i    ),
    .operand_a_i    ( operand_a_i   ),
    .operand_b_i    ( operand_b_i   ),
    .rd_addr_i      ( rd_addr_i     ),
    .rd_wr_en_i     ( rd_wr_en_i    ),
    .reg_we_o       ( reg_we_o      ),
    .wr_addr_o      ( wr_addr_o     ),
    .rd_wdata_o     ( rd_wdata_alu  ),
    .add_op_a_op_b  ( lsu_addr_o    )
);


lsu u_lsu(
    .clk_i           ( clk_i        ),  
    .rst_ni          ( rst_ni       ),
    // data interface
    .data_req_o      ( data_req_o   ),
    .data_gnt_i      ( data_gnt_i   ),
    .data_rvalid_i   ( data_rvalid_i),
    .data_addr_o     ( data_addr_o  ),
    .data_we_o       ( data_we_o    ),
    .data_be_o       ( data_be_o    ),
    .data_wdata_o    ( data_wdata_o ),
    .data_rdata_i    ( data_rdata_i ),
    // from ID-EX pipeline register
    .lsu_we_i        ( lsu_we_i     ),
    .lsu_req_i       ( lsu_req_i    ),
    .lsu_type_i      ( lsu_type_i   ),
    // from alu
    .lsu_addr_i      ( lsu_addr_o   ),
       // to reg
    .lsu_rdata_o     ( lsu_rdata_o  )

);


endmodule
