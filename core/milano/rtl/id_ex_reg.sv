/***************************************
#
#			Filename:id_ex_reg.sv
#
#			Developer:ske
#			Description:---
#			CreatTime:2021-09-27 22:15:35
#
***************************************/
module id_ex_reg(
    input  logic clk_i,
    input  logic rst_ni,
    //from decoder
    input  logic [4:0]  rd_addr_i,
    input  logic [31:0] rs1_data_i,
    input  logic [31:0] rs2_data_i,
    input  logic        alu_operate_i,
    //to EX
    output  logic [4:0]  rd_addr_ex_o,
    output  logic [31:0] rs1_data_ex_o,
    output  logic [31:0] rs2_data_ex_o,
    output  logic        alu_operate_ex_o

);

    always_ff @(posedge clk_i,negedge rst_ni)begin
        if (!rst_ni)begin
            rd_addr_ex_o    <= 5'h0;
            rs1_data_ex_o   <= 32'h0;
            rs2_data_ex_o   <= 32'h0;
            alu_operate_ex_o<= 'h0;    
        end else begin
            rd_addr_ex_o    <= rd_addr_i; 
            rs1_data_ex_o   <= rs1_data_i;
            rs2_data_ex_o   <= rs2_data_i;
            alu_operate_ex_o<= alu_operate_i;
        end
    end

endmodule

