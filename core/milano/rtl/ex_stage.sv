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
    input  logic                    clk_i,
    input  logic                    rst_ni,
    // from ID-EX pipeline register
    input  milano_pkg::alu_opt_e    operator_i,
    input  logic [31:0]             operand_a_i,
    input  logic [31:0]             operand_b_i,
    input  logic [4:0]              rd_addr_i,
    input  logic                    rd_wr_en_i,
    // Write back, to MEM/regs
    output logic                    reg_we_o,
    output logic [4:0]              wr_addr_o,
    output logic [31:0]             rd_wdata_o
);




alu u_alu(
    .operator_i(operator_i),
    .operand_a_i(operand_a_i),
    .operand_b_i(operand_b_i),
    .rd_addr_i(rd_addr_i),
    .rd_wr_en_i(rd_wr_en_i),
    .reg_we_o(reg_we_o),
    .wr_addr_o(wr_addr_o),
    .rd_wdata_o(rd_wdata_o)
);

endmodule
