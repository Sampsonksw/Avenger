/***************************************
#
#			Filename:id_stage.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-29 15:41:06
#
***************************************/

module id_stage(
    input logic         clk_i,
    input logic         rst_ni,
    // from IF-ID pipeline register
    input logic [31:0]  instr_rdata_i,   //instr data 
    // output to EX
    ////rd addr
    output logic [4:0]  rd_addr_ex_o,       //destination reg addr
    ////rs1_data,rs2_data
    output logic [31:0] rs1_data_ex_o,
    output logic [31:0] rs2_data_ex_o,
    output logic        alu_operate_ex_o,
    // from EX
    input  logic        we_i,
    input  logic [4:0]  waddr_i,
    input  logic [31:0] wdata_i

);

logic [31:0]    rs1_rdata_i,rs2_rdata_i;
logic [4:0]     rs1_addr_o,rs2_addr_o,rd_addr_o;
logic [31:0]    rs1_data,rs2_data;
logic           alu_operate_o;
/************	decoder inst	******************/
decoder u_decoder(
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    // from IF-ID pipeline register
    .instr_rdata_i(instr_rdata_i),   //instr data 
    // from register file
    .rs1_rdata_i(rs1_rdata_i),     //source reg1
    .rs2_rdata_i(rs2_rdata_i),     //source reg2
    // output to register file
    .rs1_addr_o(rs1_addr_o),      //source reg1 addr
    .rs2_addr_o(rs2_addr_o),      //source reg2 addr
    // output to ID-EX pipeline register
    .rd_addr_o(rd_addr_o),       //destination reg addr
    .rs1_data (rs1_data),
    .rs2_data (rs2_data),
    .alu_operate_o(alu_operate_o)

);

/************	id_ex_reg inst	******************/
id_ex_reg u_id_ex_reg(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    //from decoder
    .rd_addr_i(rd_addr_o),
    .rs1_data_i(rs1_data),
    .rs2_data_i(rs2_data),
    .alu_operate_i(alu_operate_o),
    //to EX
    .rd_addr_ex_o(rd_addr_ex_o),
    .rs1_data_ex_o(rs1_data_ex_o),
    .rs2_data_ex_o(rs2_data_ex_o),
    .alu_operate_ex_o(alu_operate_ex_o)
);

/************	regs file inst	******************/
regs_file u_regs_file(
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),

    // from ex
    ////write port w1
    .we_i(we_i),
    .waddr_i(waddr_i),
    .wdata_i(wdata_i),

    // from id
    ////read port R1
    .raddr_a_i(rs1_addr_o),
    .rdata_a_o(rs1_rdata_i),
    ////reda port R2
    .raddr_b_i(rs2_addr_o),
    .rdata_b_o(rs2_rdata_i)
);

endmodule
