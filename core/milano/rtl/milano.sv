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
        input  logic clk_i,
        input  logic rst_ni,
        //input from boot sel
        input  logic [31:0] boot_addr_i,
        //output to system bus
        output logic [31:0] instr_addr_o,
        //from instr ram
        input  logic [31:0] instr_rdata_i,
        //output to instr ramid_stage
        output logic fetch_enable_o       
);




/********** if stage unit  ***********/
    logic [31:0]instr_data_if2id;
    logic [31:0]instr_addr_if2id;
if_stage u_if_stage(
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .boot_addr_i(boot_addr_i),
	    //input form ram
        .instr_rdata_i(instr_rdata_i),
	    //outputs to instr ram/ID
        .instr_addr_o(instr_addr_o),
        .fetch_enable_o(fetch_enable_o),
	    //outputs to ID
        .instr_rdata_id_o(instr_data_if2id),
        .instr_addr_id_o(instr_addr_if2id)
);

/********** id stage unit  **********/
    logic [4:0]             rd_addr_id2ex;
    logic                   rd_wr_en_id2ex;
    logic [31:0]            rs1_data_id2ex;
    logic [31:0]            rs2_data_id2ex;
    milano_pkg::alu_opt_e   alu_operate_id2ex;
    logic                   we_ex2id;
    logic [4:0]             waddr_ex2id;
    logic [31:0]            wdata_ex2id;

id_stage u_id_stage(
    .clk_i              ( clk_i             ),
    .rst_ni             ( rst_ni            ),
    // from IF-ID pipeline register
    .instr_rdata_i      ( instr_data_if2id  ),  //instr data
    .instr_addr_i       ( instr_addr_if2id  ),  //instr address
    // output to EX
    ////rd addr
    .rd_addr_ex_o       ( rd_addr_id2ex     ),  //rd register address
    .rd_wr_en_ex_o      ( rd_wr_en_id2ex    ),  //rd register write enable
    ////rs1_data,rs2_data 
    .rs1_data_ex_o      ( rs1_data_id2ex    ),  //rs1 register data
    .rs2_data_ex_o      ( rs2_data_id2ex    ),  //rs2 register data
    .alu_operate_ex_o   ( alu_operate_id2ex ),
    // from EX
    .we_i               ( we_ex2id          ),
    .waddr_i            ( waddr_ex2id       ),
    .wdata_i            ( wdata_ex2id       )

);
/********** ex stage unit  **********/

ex_stage u_ex_stage(
    .clk_i      ( clk_i             ),
    .rst_ni     ( rst_ni            ),
    // from ID-EX pipeline register
    .operator_i ( alu_operate_id2ex ),  //alu operate type
    .operand_a_i( rs1_data_id2ex    ),  //rs1 register data
    .operand_b_i( rs2_data_id2ex    ),  //rs2 register data
    .rd_addr_i  ( rd_addr_id2ex     ),  //rd  register address
    .rd_wr_en_i ( rd_wr_en_id2ex    ),  //rd  register write enable
    // Write back, to MEM/regs
    .reg_we_o   ( we_ex2id          ),
    .wr_addr_o  ( waddr_ex2id       ),
    .rd_wdata_o ( wdata_ex2id       )
);
endmodule
