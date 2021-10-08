/***************************************
#
#			Filename:milano.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-29 15:09:11
#
***************************************/

module milano(
        input  logic clk_i,
        input  logic rst_ni,
        //input from boot sel
        input  logic [31:0] boot_addr_i,
        //output to system bus
        output logic [31:0] instr_addr_o.
        //from eflash
        input  logic [31:0] instr_rdata_i,
);




/********** if stage unit  ***********/
    logic [31:0]instr_rdata;
if_stage u_if_stage(
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .boot_addr_i(boot_addr_i),
	    //input form ram
        .instr_rdata_i(instr_rdata_i),
	    //outputs to instr ram/ID
        .instr_addr_o(instr_addr_o),
	    //outputs to ID
        .instr_rdata_id_o()
        //output logic [31:0] pc_id_o
);

/********** id stage unit  **********/
    logic [4:0]     rd_addr_ex_o;
    logic [31:0]    rs1_data_ex_o;
    logic [31:0]    rs2_data_ex_o;
    logic           alu_operate_ex_o;
    logic           we_i;
    logic [4:0]     waddr_i;
    logic [31:0]    wdata_i;

id_stage u_id_stage(
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        // from IF-ID pipeline register
        .instr_rdata_i(instr_rdata_i),   //instr data 
        // output to EX
        ////rd addr
        .rd_addr_ex_o(rd_addr_ex_o),       //destination reg addr
        ////rs1_data,rs2_data
        .rs1_data_ex_o(rs1_data_ex_o),
        .rs2_data_ex_o(rs2_data_ex_o),
        .alu_operate_ex_o(alu_operate_ex_o),
        // from EX
        .we_i(we_i),
        .waddr_i(waddr_i),
        .wdata_i(wdata_i)

);
/********** ex stage unit  **********/
ex_stage u_ex_stage(
    .clk_i(clk_i),
    .rst_ni(rst_ni),      
);
endmodule
