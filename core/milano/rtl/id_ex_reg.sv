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
    //input from id
    ////rs1,rs2 rdata
    input  logic [31:0] rs1_data_i  ,
    input  logic [31:0] rs2_data_i  ,
    ////rd
    input  logic [4:0]  rd_addr_i   ,       //destination reg addr
    input  logic        rd_we_i     ,

    //output to ex 
    ////rs1,rs2 rdata
    output logic [31:0] rs1_data_ex_o,
    output logic [31:0] rs2_data_ex_o,
    ////rd
    output logic [4:0]  rd_addr_ex_o ,       //destination reg addr
    output logic        rd_we_ex_o   

);

    always_ff @(posedge clk_i,negedge rst_ni)begin
        if (!rst_ni)begin
            rs1_data_ex_o <=    'h0;
            rs2_data_ex_o <=    'h0;
            rd_addr_ex_o  <=    'h0;
            rd_we_ex_o    <=    'h0;
        end else begin
            rs1_data_ex_o <=    rs1_data_i  
            rs2_data_ex_o <=    rs2_data_i  
            rd_addr_ex_o  <=    rd_addr_i   
            rd_we_ex_o    <=    rd_we_i     
        end
    end

endmodule

